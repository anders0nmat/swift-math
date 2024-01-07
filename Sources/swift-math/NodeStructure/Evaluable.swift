
public protocol Evaluable: ContextEvaluable {
	/*
	Function to call if evaluation is requested.
	Returns math-value or error
	*/
	func evaluate() -> MathResult
}

public extension Evaluable {
	func evaluate(in context: Node<Self>) -> MathResult { evaluate() }
}

