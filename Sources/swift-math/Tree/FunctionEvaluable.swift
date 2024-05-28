
public protocol FunctionEvaluable: ContextEvaluable {
	static var functions: FunctionContainer { get set }
}

public extension FunctionEvaluable {
	fileprivate var allArguments: [any NodeProtocol] {
		self.arguments.argumentsPath.map { self.instance[keyPath: $0].node }
	}

	func evaluate(in context: Node<Self>) throws -> MathValue {
		try Self.functions.evaluate(allArguments)
	}

	func evaluateType(in context: Node<Self>) -> MathType? {
		Self.functions.evaluateType(allArguments)
	}
}
