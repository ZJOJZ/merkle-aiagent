import type { Plugin } from "@elizaos/core";
import openOrder from "./actions/openOrder.ts";
import fullyClosePosition from "./actions/fullyClosePosition.ts";
import getOrder from "./actions/getOrder.ts";
import getPosition from "./actions/getPosition.ts";
import getBalance from "./actions/getBalance.ts";
import getPrice from "./actions/getPrice.js";

const merklePlugin: Plugin = {
	name: "merkle",
	description: "Merkle Plugin for Eliza",
	actions: [openOrder, fullyClosePosition, getOrder, getPosition, getBalance, getPrice],
	evaluators: [],
  services: [],
	providers: [],
};

export * from "./services.ts";
export * from "./utils";
export { merklePlugin };
export default merklePlugin;
