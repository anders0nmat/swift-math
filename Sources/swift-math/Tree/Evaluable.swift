
/**
	Base protocol for any operator that does not require context information
*/
public protocol Evaluable: ContextEvaluable {
	/**
		Evaluate the result of this Operator
	*/
	func evaluate() throws -> MathValue

	/**
		Evaluate the type of the result of this Operator

		Used for type inference of some operators.
		`nil` can be returned to indicate that the type can not be known until evaluation through `evaluate()`
	*/
	func evaluateType() -> MathType?
}

public extension Evaluable {
	func evaluate(in context: Node<Self>) throws -> MathValue { try evaluate() }
	func evaluateType(in context: Node<Self>) -> MathType? { evaluateType() }

	func evaluateType() -> MathType? { nil }
}

