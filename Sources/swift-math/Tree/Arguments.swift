
public typealias ArgumentKey<T> = WritableKeyPath<T, Argument>
public typealias ArgumentListKey<T> = WritableKeyPath<T, ArgumentList>

public struct Argument {
	public var name: String
	public var node: AnyNode

	public init(name: String = "") {
		self.name = name
		self.node = Node.empty()
	}

	func evaluate() throws -> MathValue { try node.evaluate() }
	var returnType: MathType? { node.returnType }
	var variables: VariableContainer { node.variables }
}

public struct ArgumentList {
	public var nameGenerator: (Array.Index) -> String
	public var nodeList: [AnyNode]

	public init(nameGenerator: @escaping (Array.Index) -> String = {_ in "" }) {
		self.nameGenerator = nameGenerator
		self.nodeList = []
	}
}

public struct ArgumentContainer<T: ContextEvaluable> {
	public var prefixPath: ArgumentKey<T>?
	public var argumentsPath: [ArgumentKey<T>]
	public var restPath: ArgumentListKey<T>?

	public init(prefix: ArgumentKey<T>? = nil, arguments: ArgumentKey<T>..., rest: ArgumentListKey<T>? = nil) {
		self.prefixPath = prefix
		self.argumentsPath = arguments
		self.restPath = rest
	}
}

