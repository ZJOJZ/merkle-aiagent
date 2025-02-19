import type { Plugin } from "@elizaos/core";
import bitcoinReverseSignal from "./actions/bitcoinReverseSignal.ts";


const merkleExampleSnsPlugin: Plugin = {
	name: "merkle-example-sns",
	description: "Merkle Example SNS Plugin for Eliza",
	actions: [bitcoinReverseSignal],
	evaluators: [],
	providers: [],
};

export { merkleExampleSnsPlugin };
export default merkleExampleSnsPlugin;
