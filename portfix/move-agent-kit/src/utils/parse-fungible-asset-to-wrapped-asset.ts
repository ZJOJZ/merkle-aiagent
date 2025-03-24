import type { MoveStructId } from "@aptos-labs/ts-sdk"

export const parseFungibleAssetAddressToWrappedAssetAddress = (assetAddress: MoveStructId | string): MoveStructId => {
	if (assetAddress === "0x357b0b74bc833e95a115ad22604854d6b0fca151cecd94111770e5d6ffc9dc2b") {
		return "0x9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::fa_to_coin_wrapper::WrappedUSDT"
	}
	return assetAddress as MoveStructId
}
