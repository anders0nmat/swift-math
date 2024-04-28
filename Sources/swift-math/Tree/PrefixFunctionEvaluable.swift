
public protocol PrefixFunctionEvaluable: ContextEvaluable {
	static var functions: FunctionContainer { get set }
}

public extension PrefixFunctionEvaluable {
	fileprivate var allArguments: [Argument] {
		[self[keyPath: self.arguments.prefixPath!]] + 
		self.arguments.argumentsPath.map { self[keyPath: $0] }
	}

	func evaluate(in context: Node<Self>) throws -> MathValue {
		try Self.functions.evaluate(allArguments)
	}

	func evaluateType(in context: Node<Self>) -> MathType? {
		Self.functions.evaluateType(allArguments)
	}
}
