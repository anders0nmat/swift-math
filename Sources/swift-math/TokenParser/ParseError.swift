
public struct ParseError: Error {
    public enum Message {
        case contextError(message: String? = nil)

        case unknownToken
    }

    var message: Message
    weak var currentRoot: AnyNode?
    weak var currentHead: AnyNode?
}

extension ParseError {
    static var unknownToken: ParseError {
        .init(message: .unknownToken)
    }
}

extension ParseError: Equatable {
    public static func == (lhs: ParseError, rhs: ParseError) -> Bool {
		return
			lhs.message == rhs.message &&
			lhs.currentRoot === rhs.currentRoot &&
			lhs.currentHead === rhs.currentHead
    }
}

extension ParseError.Message: Equatable {}
