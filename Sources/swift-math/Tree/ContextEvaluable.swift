
public typealias AnyEvaluable = any ContextEvaluable

public protocol ContextEvaluable {
	typealias ArgumentPath = ArgumentContainer<Self>
	var arguments: ArgumentPath { get }

	/*
	Unique identifier for this operation
	*/
	var identifier: String { get }

	/*
	Initialization for individual nodes.
	Required if you want something per-node initialized.
	Example: variable names, constant expression names
	*/
	mutating func customize(using arguments: [String]) -> Bool

	/*
	Function to call if evaluation is requested.
	Returns math-value or error
	*/
	func evaluate(in context: Node<Self>) throws -> MathValue

	/*
	Indicates the return type of evaluate() or `nil` if unknown
	*/
	func evaluateType(in context: Node<Self>) -> MathType?

	mutating func childrenChanged()
	mutating func contextChanged()
}

public extension ContextEvaluable {
	var arguments: ArgumentPath { ArgumentPath() }

	mutating func customize(using arguments: [String]) -> Bool { true }

	mutating func resetArguments() {
		if let prefixPath = arguments.prefixPath {
			self[keyPath: prefixPath].node = Node.empty()
		}
		arguments.argumentsPath.forEach {
			self[keyPath: $0].node = Node.empty()
		}

		if let restPath = arguments.restPath {
			self[keyPath: restPath].nodeList = []
		}
	}
	
	func makeNode() -> AnyNode { Node(self) }

	func evaluateType(in context: Node<Self>) -> MathType? { nil }

	mutating func childrenChanged() {}
	mutating func contextChanged() {}	
}

