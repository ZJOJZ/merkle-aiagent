export const parseJson = (input: string) => {
	try {
		const forbiddenWords = ["null", "undefined", "{}"]
		if (input in forbiddenWords) throw new Error()

		const parsedInput = JSON.parse(input)

		return parsedInput
	} catch (e) {
		return {}
	}
}
