
/**
	Generic Operator definition for overloadable native functions

	Allows for quick definition of overloadable functions through a `FunctionContainer`.
	Default implementation provided for the `Evaluable`-Protocol
*/
public protocol FunctionEvaluable: ContextEvaluable {
	/**
		Contains all function overloads for the operator
	*/
	static var functions: FunctionContainer { get set }
}

public extension FunctionEvaluable {
	fileprivate var allArguments: [AnyNode] {
		self.arguments.argumentsPath.map { self.instance[keyPath: $0] }
	}

	func evaluate(in context: Node<Self>) throws -> MathValue {
		try Self.functions.evaluate(allArguments)
	}

	func evaluateType(in context: Node<Self>) -> MathType? {
		Self.functions.evaluateType(allArguments)
	}
}
