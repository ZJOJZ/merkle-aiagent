import { defineConfig } from "tsup";

export default defineConfig({
	entry: ["src/index.ts"],
	outDir: "dist",
	sourcemap: true,
	clean: true,
	format: ["esm"],
	dts: true,
	minify: false,
	splitting: false,
	external: [
		"@elizaos/core",
		"@aptos-labs/ts-sdk",
		"bignumber",
		"bignumber.js",
		"dotenv",
		"fs",
		"path",
		"@reflink/reflink",
		"@node-llama-cpp",
		"https",
		"http",
		"agentkeepalive",
		"safe-buffer",
		"base-x",
		"bs58",
		"borsh",
		"stream",
		"buffer",
		"querystring",
		"amqplib",
	],
	noExternal: [],
	esbuildOptions(options) {
		options.platform = "node";
	},
});
