
public struct MathError: Error {
	public enum Message {
		case evalError(message: String)

		case genericError(message: String?)
	}

	var message: Message
	var origin: AnyNode?

	func withOrigin(_ node: AnyNode?) -> Self {
		.init(message: message, origin: node)
	}
}

extension MathError {
	static func evalError(message: String) -> MathError {
		.init(message: .evalError(message: message))
	}

	static func genericError(message: String? = nil) -> MathError {
		.init(message: .genericError(message: message))
	}
}

extension MathError: Equatable {
    public static func == (lhs: MathError, rhs: MathError) -> Bool {
		return
			lhs.message == rhs.message &&
			lhs.origin === rhs.origin
    }
}

extension MathError.Message: Equatable {}
