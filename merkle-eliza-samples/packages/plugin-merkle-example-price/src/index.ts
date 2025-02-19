import type { Plugin } from "@elizaos/core";
import PriceListener from "./price-listener";
import AgentObserver from "./agent-observer";

const merkleExamplePricePlugin: Plugin = {
	name: "merkle-example-price",
	description: "Merkle Example Price Plugin for Eliza",
  clients: [new PriceListener(), new AgentObserver()],
	evaluators: [],
	providers: [],
};

export { merkleExamplePricePlugin };
export default merkleExamplePricePlugin;
