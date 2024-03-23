
public enum MathError: Error {
	case missingVariable(name: String)
	case unexpectedType(expected: MathType, found: MathType? = nil)
	case valueError
	case missingArgument
	case noMatchingFunction(signature: [MathType])

	case unknown(Error)
}

public struct MathErrorContainer: Error {
	public var error: MathError
	public weak var origin: AnyNode?
}

extension MathErrorContainer: CustomStringConvertible {
	public var description: String {
		"Error: \(error)" + (origin != nil ? " at \(origin!)" : "")
	}
}

public typealias MathResult = Result<MathValue, MathErrorContainer>

