
public struct VariableNode: ContextEvaluable {
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

	public func evaluate(in context: Node<Self>) throws -> MathValue {
		if let value = context.variables[name] {
			return value
		}
		throw MathError.missingVariable(name: name)
	}

	public func evaluateType(in context: Node<VariableNode>) -> MathType? {
		context.variables[name]?.type
	}
}
