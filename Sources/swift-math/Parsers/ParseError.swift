
public enum ParseError: Error {
	case unknownToken(TreeParser.Token)
	case noHead

	case unexpectedHead
	case customizationFailed(for: [String], on: any ContextEvaluable)

	case syntaxError

	case unknown(Error)
}

public struct ParseErrorContainer: Error {
	var error: ParseError
	weak var root: (any NodeProtocol)?
	weak var current: (any NodeProtocol)?
}

extension ParseErrorContainer: CustomStringConvertible {
	public var description: String {
		"\(error) at (current: \(current != nil ? String(describing: current!) : "nil"), root: \(root != nil ? String(describing: root!) : "nil"))"
	}
}
