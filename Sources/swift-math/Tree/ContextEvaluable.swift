
//public typealias AnyEvaluable = any ContextEvaluable

public protocol ContextEvaluable {
	typealias ArgumentPath = ArgumentContainer<Self>
	typealias ArgumentInfo = ArgumentDetail<Self>

	associatedtype Storage: Codable = EmptyStorage
	var instance: Storage { get set }
	
	var arguments: ArgumentPath { get }
	var argumentInfo: ArgumentInfo { get }

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
	var argumentInfo: ArgumentInfo { ArgumentInfo([:]) }

	mutating func customize(using arguments: [String]) -> Bool { true }

	mutating func resetArguments() {
		if let prefixPath = arguments.prefixPath {
			self.instance[keyPath: prefixPath].node = Node.empty()
		}
		arguments.argumentsPath.forEach {
			self.instance[keyPath: $0].node = Node.empty()
		}

		if let restPath = arguments.restPath {
			self.instance[keyPath: restPath] = []
		}
	}
	
	func makeNode() -> any NodeProtocol { Node(self) }

	func evaluateType(in context: Node<Self>) -> MathType? { nil }

	mutating func childrenChanged() {}
	mutating func contextChanged() {}	
}

public extension ContextEvaluable where Storage == EmptyStorage {
	var instance: Storage {
		get { Storage() }
		set {}
	}
}

