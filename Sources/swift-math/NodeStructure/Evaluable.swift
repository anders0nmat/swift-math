
public protocol Evaluable: ContextEvaluable {
	/*
	Function to call if evaluation is requested.
	Returns math-value or error
	*/
	func evaluate() throws -> MathValue

	/*
	Indicates the return type of evaluate() or `nil` if unknown
	*/
	func evaluateType() -> MathType?
}

public extension Evaluable {
	func evaluate(in context: Node<Self>) throws -> MathValue { try evaluate() }
	func evaluateType(in context: Node<Self>) -> MathType? { evaluateType() }

	func evaluateType() -> MathType? { nil }
}

