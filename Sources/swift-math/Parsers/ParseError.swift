
public struct ParseError: Error {
    public enum Message {
        case contextError(message: String? = nil)

		case unexpectedHead
		case emptyHead
		case noEmptyHead
		case noHead
        case unknownToken
    }

    var message: Message
    weak var currentRoot: AnyNode?
    weak var currentHead: AnyNode?
}

extension ParseError {
    static var unknownToken: Self { .init(message: .unknownToken) }
	static var noHead: Self       { .init(message: .noHead) }
	static var emptyHead: Self    { .init(message: .emptyHead) }
	static var unexpectedNode: Self { .init(message: .unexpectedHead) }

	static func noEmptyHead(head: AnyNode) -> Self { .init(message: .noEmptyHead, currentHead: head) }
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
