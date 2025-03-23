export const removeLastInterestRateIndex = (obj: any): any => {
	if (!obj || typeof obj !== "object") {
		return obj
	}

	if (Array.isArray(obj)) {
		return obj.map((item) => removeLastInterestRateIndex(item))
	}

	return Object.entries(obj).reduce((acc: { [key: string]: any }, [key, value]) => {
		if (key === "last_interest_rate_index") {
			return acc
		}

		acc[key] = removeLastInterestRateIndex(value)
		return acc
	}, {})
}
