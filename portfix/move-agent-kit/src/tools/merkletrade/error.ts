import type { CommittedTransactionResponse } from "@aptos-labs/ts-sdk"

export class MerkleBaseError extends Error {
	readonly code: string
	readonly status: string

	constructor(status: string, code: string, message: string) {
		super(message)
		this.code = code
		this.status = status

		Object.setPrototypeOf(this, MerkleBaseError.prototype)
	}
}

export class PositionNotFoundError extends MerkleBaseError {
	readonly pair: string
	readonly isLong: boolean

	constructor(pair: string, isLong: boolean, message: string) {
		super("error", "POSITION_NOT_FOUND", message)
		this.pair = pair
		this.isLong = isLong
	}
}

export class FailedSendTransactionError extends MerkleBaseError {
	readonly tx: CommittedTransactionResponse
	constructor(message: string, tx: CommittedTransactionResponse) {
		super("error", "FAILED_SEND_TRANSACTION", message)
		this.tx = tx
	}
}
