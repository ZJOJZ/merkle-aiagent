/**
 * Fetches token price from the Pyth network
 * @param query Token query to search for
 * @returns Price feed data
 */
export async function getTokenPrice(query: string): Promise<any> {
	try {
		const assetDataResponse = await fetch(`https://hermes.pyth.network/v2/price_feeds?query=${query}&asset_type=crypto`)

		const assetData = await assetDataResponse.json()

		const formattedData = assetData.map((data: any) => {
			return {
				id: data.id,
				displayName: data.attributes.display_symbol,
				symbol: data.attributes.symbol,
			}
		})

		const assetIdArray = formattedData.map((data: any) => data.id)

		if (assetIdArray.length === 0) {
			throw new Error("No assets found for the given query")
		}
		const assetPriceDataResponse = await fetch(
			`https://hermes.pyth.network/v2/updates/price/latest?ids[]=${assetIdArray.join("&ids[]=")}`
		)

		const assetPriceData = await assetPriceDataResponse.json()

		const priceFeed = formattedData.map((data: any) => {
			const priceData = assetPriceData.parsed.find((price: any) => price.id === data.id)

			return {
				...data,
				price:
					(Number(priceData.price.price) / 10 ** Math.abs(priceData.price.expo)).toLocaleString() ||
					Number(priceData.price.price).toLocaleString(),
			}
		})

		return priceFeed
	} catch (error: any) {
		throw new Error(`Token transfer failed: ${error.message}`)
	}
}
