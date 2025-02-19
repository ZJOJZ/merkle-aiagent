import { z } from "zod";

export const OpenOrderSchema = z.object({
	coinSymbol: z.string().toUpperCase(),
	pay: z.number(),
	leverage: z.number(),
	type: z.enum(["MARKET", "LIMIT"]),
	side: z.enum(["LONG", "SHORT"]),
  limitOrderPrice: z.number().optional().nullable(),
});

export const FullyClosePositionSchema = z.object({
  coinSymbol: z.string().toUpperCase(),
  side: z.enum(["LONG", "SHORT"]),
});

export const GetPriceSchema = z.object({
  coinSymbol: z.string().toUpperCase(),
});
