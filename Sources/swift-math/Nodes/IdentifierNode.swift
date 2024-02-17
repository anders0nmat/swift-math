
public struct IdentifierNode: Evaluable {
	public private(set) var identifier: String

	public init(_ identifier: String) {
		self.identifier = identifier
	}

	public mutating func customize(using arguments: [String]) -> Result<Nothing, ParseError> {
		guard let rawString = arguments.first, arguments.count == 1 else {
			return .failure(.init(message: .contextError(message: "Too many/few arguments")))
		}

		self = Self.init(rawString)
		return .success
	}

	public func evaluate() throws -> MathValue { .identifier(identifier) }
	public func evaluateType() -> MathType? { .identifier }
}