// Minimal structural stand-ins for the four type-only imports from @oh-my-pi/pi-ai.
export type Api = string;

export interface TextContent {
	type: "text";
	text: string;
}
export interface ImageContent {
	type: "image";
	data: string;
	mimeType: string;
	detail?: "auto" | "low" | "high" | "original";
}
export interface ThinkingContent {
	type: "thinking";
	thinking: string;
}
export interface ToolCall {
	type: "toolCall";
	id: string;
	name: string;
	arguments: Record<string, unknown>;
	intent?: string;
}
export interface UserMessage {
	role: "user";
	content: string | (TextContent | ImageContent)[];
	timestamp: number;
}
export interface DeveloperMessage {
	role: "developer";
	content: string | (TextContent | ImageContent)[];
	timestamp: number;
}
export interface AssistantMessage {
	role: "assistant";
	content: (TextContent | ThinkingContent | ImageContent | ToolCall | { type: string; [k: string]: unknown })[];
	timestamp: number;
}
export interface ToolResultMessage<TDetails = unknown> {
	role: "toolResult";
	toolCallId: string;
	toolName: string;
	content: (TextContent | ImageContent)[];
	details?: TDetails;
	isError: boolean;
	useless?: boolean;
	timestamp: number;
}
export type Message = UserMessage | DeveloperMessage | AssistantMessage | ToolResultMessage;
