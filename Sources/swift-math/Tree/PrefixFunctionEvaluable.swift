
public protocol PrefixFunctionEvaluable: ContextEvaluable {
	static var functions: FunctionContainer { get set }
}

public extension PrefixFunctionEvaluable {
	fileprivate var allArguments: [AnyNode] {
		[self.instance[keyPath: self.arguments.prefixPath!]] + 
		self.arguments.argumentsPath.map { self.instance[keyPath: $0] }
	}

	func evaluate(in context: Node<Self>) throws -> MathValue {
		try Self.functions.evaluate(allArguments)
	}

	func evaluateType(in context: Node<Self>) -> MathType? {
		Self.functions.evaluateType(allArguments)
	}
}
