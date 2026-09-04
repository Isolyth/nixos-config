// Minimal Node loader for the two snapcompact entry points of
// @oh-my-pi/pi-natives (napi-rs addon). Replaces the upstream
// loader-state.js (staging/embedded-addon machinery is Bun-standalone
// plumbing we don't need). The .node binaries are placed next to this
// file by the nix derivation in home/modules/pi.nix.
//
// Variant selection mirrors upstream detectAvx2Support(): linux-x64
// reads /proc/cpuinfo; "modern" (AVX2) preferred, "baseline" fallback.
import { readFileSync } from "node:fs";
import { createRequire } from "node:module";

const require_ = createRequire(import.meta.url);

function hasAvx2(): boolean {
	if (process.arch !== "x64") return false;
	try {
		return /\bavx2\b/i.test(readFileSync("/proc/cpuinfo", "utf8"));
	} catch {
		return false;
	}
}

let loadedVariant = "none";

function loadNative(): any {
	const tag = `${process.platform}-${process.arch}`;
	const candidates = hasAvx2()
		? [`./pi_natives.${tag}-modern.node`, `./pi_natives.${tag}-baseline.node`]
		: [`./pi_natives.${tag}-baseline.node`];
	const errors: string[] = [];
	for (const candidate of candidates) {
		try {
			const addon = require_(candidate);
			loadedVariant = candidate.includes("-modern") ? "modern/avx2" : "baseline";
			return addon;
		} catch (err) {
			errors.push(`${candidate}: ${err instanceof Error ? err.message : String(err)}`);
		}
	}
	throw new Error(`snapcompact: failed to load pi-natives addon:\n${errors.join("\n")}`);
}

const native = loadNative();

/** Which .node binary actually loaded ("modern/avx2" | "baseline"). */
export function nativesVariant(): string {
	return loadedVariant;
}

export const renderSnapcompactPng: (text: string, options: unknown) => Promise<string> =
	native.renderSnapcompactPng;
export const snapcompactSupportedChars: (font: string, chars: string) => string =
	native.snapcompactSupportedChars;
