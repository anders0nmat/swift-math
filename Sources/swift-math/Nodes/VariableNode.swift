
public struct VariableNode: Evaluable {
	public private(set) var name: String
	public var displayName: String { name }

	public init(_ name: String) {
		self.name = name
	}

	public mutating func customize(using arguments: [String]) -> Result<Nothing, ParseError> {
		guard let name = arguments.first else { return .failure(.emptyHead) }

		self.name = name
		return .success
	}

	public func evaluate() -> MathResult {
		return .failure(.evalError(message: "Variable '\(name)' not found"))
	}
}
