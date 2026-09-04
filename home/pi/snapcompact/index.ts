/**
 * snapcompact for plain pi — bitmap-frame context compression.
 *
 * Port of oh-my-pi's `strategy: "snapcompact"` compaction onto pi's public
 * extension API. Instead of asking an LLM to summarize discarded history,
 * the transcript is serialized and rendered into dense pixel-font PNG
 * frames that vision models read back directly. Rendering is fully local
 * (napi native addon) — compaction needs no LLM call and costs no tokens.
 *
 * Wiring:
 *  - `session_before_compact`: run the vendored snapcompact `compact()`,
 *    return its instruction summary as pi's compaction summary, and persist
 *    the archive (frames + source text) in the compaction entry's `details`.
 *  - `context` (fires before every LLM call, on a structuredClone): swap the
 *    plain-text compaction summary message for one carrying
 *    [summary, textHead, ...frames..., textTail] in exact reading order.
 *    Nothing image-shaped is ever persisted as a session message; frames are
 *    reconstructed from the archive on each request, exactly like upstream.
 *  - Re-compaction feeds the previous archive back via `previousPreserveData`
 *    so history re-renders cumulatively instead of stacking summaries.
 *
 * Degradation: if the active model lacks vision, frames are omitted via the
 * archive's own budget notice (text edges stay); if the extension errors,
 * returning nothing falls back to pi's default LLM compaction.
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { convertToLlm } from "@earendil-works/pi-coding-agent";
import * as sc from "./vendor/snapcompact";
import { nativesVariant, snapcompactSupportedChars } from "./vendor/natives";

/** Latest compaction entry on the active branch, or undefined. */
function latestCompactionEntry(ctx: ExtensionContext): any | undefined {
	const branch = ctx.sessionManager.getBranch();
	for (let i = branch.length - 1; i >= 0; i--) {
		const entry = branch[i] as any;
		if (entry.type === "compaction") return entry;
	}
	return undefined;
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("snapcompact", {
		description: "Show snapcompact status (loaded, natives variant, model vision, current archive)",
		handler: async (_args, ctx) => {
			const lines: string[] = [];
			try {
				const probe = snapcompactSupportedChars("8x13", "ok");
				lines.push(`natives: loaded (${nativesVariant()}, glyph probe "${probe}")`);
			} catch (error) {
				lines.push(`natives: FAILED — ${error instanceof Error ? error.message : String(error)}`);
			}
			const model = ctx.model;
			lines.push(
				model
					? `model: ${model.id} (${model.provider}) — vision ${model.input.includes("image") ? "yes: frames will be attached" : "NO: text edges only"}`
					: "model: none selected",
			);
			const entry = latestCompactionEntry(ctx);
			const archive = entry ? sc.getPreservedArchive(entry.details) : undefined;
			if (archive) {
				lines.push(
					`archive: ${archive.frames.length} frame${archive.frames.length === 1 ? "" : "s"}, ${archive.totalChars.toLocaleString()} chars archived` +
						(archive.truncatedChars ? `, ${archive.truncatedChars.toLocaleString()} chars aged out` : ""),
				);
			} else if (entry) {
				lines.push("archive: none on latest compaction (it predates this extension or used LLM fallback)");
			} else {
				lines.push("archive: no compaction yet this session — /compact to trigger one");
			}
			ctx.ui.notify(`snapcompact active\n${lines.join("\n")}`, "info");
		},
	});

	pi.on("session_before_compact", async (event, ctx) => {
		const { preparation } = event;
		try {
			const previous = latestCompactionEntry(ctx);
			const previousPreserveData =
				previous && sc.getPreservedArchive(previous.details) ? previous.details : undefined;

			const result = await sc.compact(
				{
					firstKeptEntryId: preparation.firstKeptEntryId,
					// pi hands us AgentMessage[]; snapcompact expects LLM messages.
					messagesToSummarize: convertToLlm(preparation.messagesToSummarize),
					turnPrefixMessages: convertToLlm(preparation.turnPrefixMessages),
					tokensBefore: preparation.tokensBefore,
					previousSummary: preparation.previousSummary,
					previousPreserveData,
					fileOps: preparation.fileOps,
				},
				{
					model: ctx.model ? { api: ctx.model.api, id: ctx.model.id } : undefined,
					// Never replay archived reasoning into future context
					// (upstream issue #6093 semantics).
					includeThinking: false,
				},
			);

			const frames = sc.getPreservedArchive(result.preserveData)?.frames.length ?? 0;
			ctx.ui.notify(
				result.shortSummary ?? `snapcompact: archived history onto ${frames} frame${frames === 1 ? "" : "s"}`,
				"info",
			);

			return {
				compaction: {
					summary: result.summary,
					firstKeptEntryId: preparation.firstKeptEntryId,
					tokensBefore: preparation.tokensBefore,
					// Archive rides on the persisted compaction entry; the
					// context handler below rebuilds frame blocks from it.
					details: result.preserveData,
				},
			};
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			ctx.ui.notify(`snapcompact failed, falling back to LLM compaction: ${message}`, "warning");
			return; // pi's default compaction takes over
		}
	});

	pi.on("context", (event, ctx) => {
		const entry = latestCompactionEntry(ctx);
		if (!entry) return;
		const archive = sc.getPreservedArchive(entry.details);
		if (!archive) return;

		const index = event.messages.findIndex(
			(m: any) => m.role === "compactionSummary" && m.summary === entry.summary,
		);
		if (index === -1) return;

		const vision = ctx.model?.input.includes("image") ?? false;
		// Non-vision models get the text edges plus the archive's own
		// "imaged middle omitted" notice (maxFrameDataBytes: 0 spills every
		// frame out of budget); vision models get the full frame run under
		// the default 3 MB per-request payload budget.
		const blocks = sc.historyBlocks(archive, vision ? {} : { maxFrameDataBytes: 0 });

		const messages = [...event.messages];
		const original = messages[index] as any;
		messages[index] = {
			role: "custom",
			customType: "snapcompact-archive",
			content: [{ type: "text", text: entry.summary }, ...blocks],
			display: false,
			timestamp: original.timestamp ?? Date.now(),
		} as any;
		return { messages };
	});
}
