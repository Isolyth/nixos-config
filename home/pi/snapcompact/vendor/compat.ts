// Node-compat shims replacing Bun-only / oh-my-pi-only imports in snapcompact.ts.
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));

export const fileOperationsTemplate = readFileSync(join(HERE, "prompts/file-operations.md"), "utf8");
export const snapcompactSummaryPrompt = readFileSync(join(HERE, "prompts/snapcompact-summary.md"), "utf8");

export const INTENT_FIELD = "i";

const ANSI_RE = new RegExp(
	"[\\u001B\\u009B][[\\]()#;?]*(?:" +
		"(?:(?:(?:;[-a-zA-Z\\d/#&.:=?%@~_]+)*|[a-zA-Z\\d]+(?:;[-a-zA-Z\\d/#&.:=?%@~_]*)*)?(?:\\u0007|\\u001B\\\\|\\u009C))" +
		"|(?:(?:\\d{1,4}(?:;\\d{0,4})*)?[\\dA-PR-TZcf-nq-uy=><~])" +
		")",
	"g",
);
const ESC_PAIR = new RegExp("\\u001B[\\s\\S]?", "g");

export function stripANSI(text: string): string {
	return text.replace(ANSI_RE, "").replace(ESC_PAIR, "");
}

// ---- vendored from @oh-my-pi/pi-utils src/path-tree.ts ----
const URL_LIKE_PATH_RE = /^[a-z][a-z0-9+.-]*:\/\//i;
function isUrlLikePath(filePath: string): boolean {
	return URL_LIKE_PATH_RE.test(filePath);
}
interface PathTreeNode {
	files: Array<{ name: string; key: string }>;
	fileNames: Set<string>;
	subdirs: Array<{ name: string; node: PathTreeNode }>;
	dirIndex: Map<string, PathTreeNode>;
}
function createNode(): PathTreeNode {
	return { files: [], fileNames: new Set(), subdirs: [], dirIndex: new Map() };
}
function addFile(node: PathTreeNode, name: string, key: string): void {
	if (node.fileNames.has(name)) return;
	node.fileNames.add(name);
	node.files.push({ name, key });
}
function buildPathTree(entries: Iterable<{ path: string; isDir: boolean; key?: string }>): PathTreeNode {
	const root = createNode();
	for (const { path: rawPath, isDir, key } of entries) {
		const normalized = rawPath.replace(/\\/g, "/");
		const fileKey = key ?? rawPath;
		if (isUrlLikePath(normalized)) {
			addFile(root, normalized, fileKey);
			continue;
		}
		const trimmed = normalized.endsWith("/") ? normalized.slice(0, -1) : normalized;
		if (trimmed.length === 0) continue;
		const segments = trimmed.split("/");
		const dirCount = isDir ? segments.length : segments.length - 1;
		let node = root;
		for (let i = 0; i < dirCount; i++) {
			const segment = segments[i]!;
			let child = node.dirIndex.get(segment);
			if (!child) {
				child = createNode();
				node.dirIndex.set(segment, child);
				node.subdirs.push({ name: segment, node: child });
			}
			node = child;
		}
		if (!isDir) addFile(node, segments[segments.length - 1]!, fileKey);
	}
	return root;
}
function* walkPathTree(
	node: PathTreeNode,
	depth = 0,
): Generator<{ kind: "dir" | "file"; depth: number; name: string; key: string }> {
	for (const file of node.files) yield { kind: "file", depth, name: file.name, key: file.key };
	for (const subdir of node.subdirs) {
		let dirNode = subdir.node;
		const parts = [subdir.name];
		while (dirNode.files.length === 0 && dirNode.subdirs.length === 1) {
			const only = dirNode.subdirs[0]!;
			parts.push(only.name);
			dirNode = only.node;
		}
		yield { kind: "dir", depth, name: parts.join("/"), key: "" };
		yield* walkPathTree(dirNode, depth + 1);
	}
}
export function formatGroupedPaths(paths: readonly string[], annotate?: (path: string) => string): string {
	if (paths.length === 0) return "";
	const tree = buildPathTree(paths.map(entry => ({ path: entry, isDir: entry.endsWith("/") })));
	const lines: string[] = [];
	for (const event of walkPathTree(tree)) {
		if (event.kind === "dir") lines.push(`${"#".repeat(event.depth + 1)} ${event.name}/`);
		else lines.push(annotate ? `${event.name}${annotate(event.key)}` : event.name);
	}
	return lines.join("\n");
}

// ---- minimal handlebars subset used by the two snapcompact templates ----
// Supported: {{var}}, {{#if var}}…{{else}}…{{/if}}, {{#xml "tag"}}…{{/xml}}
type Ctx = Record<string, unknown>;

function renderTemplate(tpl: string, ctx: Ctx): string {
	let i = 0;
	const parse = (stopTags: string[]): { out: string; stopped: string | null } => {
		let out = "";
		while (i < tpl.length) {
			const open = tpl.indexOf("{{", i);
			if (open === -1) {
				out += tpl.slice(i);
				i = tpl.length;
				break;
			}
			out += tpl.slice(i, open);
			const close = tpl.indexOf("}}", open);
			if (close === -1) {
				out += tpl.slice(open);
				i = tpl.length;
				break;
			}
			const tag = tpl.slice(open + 2, close).trim();
			i = close + 2;
			if (stopTags.includes(tag)) return { out, stopped: tag };
			if (tag.startsWith("#if ")) {
				const key = tag.slice(4).trim();
				const truthy = Boolean(ctx[key]);
				const first = parse(["else", "/if"]);
				let second = { out: "", stopped: null as string | null };
				if (first.stopped === "else") second = parse(["/if"]);
				out += truthy ? first.out : second.out;
			} else if (tag.startsWith("#xml ")) {
				const name = tag.slice(5).trim().replace(/^["']|["']$/g, "");
				const body = parse(["/xml"]);
				const content = body.out.trim();
				if (content) out += `<${name}>\n${content}\n</${name}>`;
			} else if (tag.startsWith("!")) {
				// comment
			} else {
				const v = ctx[tag];
				out += v === undefined || v === null ? "" : String(v);
			}
		}
		return { out, stopped: null };
	};
	const r = parse([]);
	return r.out;
}

/** Port of pi-utils `prompt.format()` for the default (post-render) options:
 *  trailing-whitespace trim, blank-run collapse, and blank lines dropped before
 *  a closing XML tag line. */
function format(content: string): string {
	const lines = content.split("\n");
	const result: string[] = [];
	let inCodeBlock = false;
	for (let idx = 0; idx < lines.length; idx++) {
		let line = lines[idx].trimEnd();
		const trimmedStart = line.trimStart();
		if (trimmedStart.startsWith("```") || trimmedStart.startsWith("~~~")) {
			inCodeBlock = !inCodeBlock;
			result.push(line);
			continue;
		}
		if (inCodeBlock) {
			result.push(line);
			continue;
		}
		const isClosing = /^<\/[a-z_-]+>$/.test(trimmedStart);
		if (line.trim().length === 0) {
			const next = lines[idx + 1];
			if (next === undefined || next.trim().length === 0) {
				while (result.length > 0 && result[result.length - 1].length === 0) result.pop();
				let j = idx + 1;
				while (j < lines.length && lines[j].trim().length === 0) j++;
				idx = j - 1;
				continue;
			}
			if (result.length === 0 || result[result.length - 1].length === 0) continue;
			line = "";
		}
		if (isClosing) {
			while (result.length > 0 && result[result.length - 1].length === 0) result.pop();
		}
		result.push(line);
	}
	while (result.length > 0 && result[result.length - 1].length === 0) result.pop();
	return result.join("\n");
}

export const prompt = {
	render(template: string, context: Ctx = {}): string {
		return format(renderTemplate(template, context));
	},
};
