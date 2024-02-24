
public struct VariableNode: ContextEvaluable {
	public var identifier: String { "#variable" }
	public private(set) var name: String

	public init(_ name: String) {
		self.name = name
	}

	public mutating func customize(using arguments: [String]) -> Bool {
		guard let name = arguments.first else { return false }

		self.name = name
		return true
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
