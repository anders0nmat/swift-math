
public typealias MathArgumentKey<T> = WritableKeyPath<T, MathArgument>
public typealias MathArgumentListKey<T> = WritableKeyPath<T, MathArgumentList>

public struct MathArgument {
	public var node: AnyNode

	public init() {
		self.node = Node.empty()
	}

	func evaluate() throws -> MathValue { try node.evaluate() }
	func evaluateType() -> MathType? { node.evaluateType() }
}

public struct MathArgumentList {
	public var nodeList: [AnyNode]

	public init() {
		self.nodeList = []
	}
}

public struct MathArgumentPaths<T> {
	public var prefixPath: MathArgumentKey<T>?
	public var argumentsPath: [MathArgumentKey<T>]
	public var restPath: MathArgumentListKey<T>?

	public init(prefix: MathArgumentKey<T>? = nil, arguments: MathArgumentKey<T>..., rest: MathArgumentListKey<T>? = nil) {
		self.prefixPath = prefix
		self.argumentsPath = arguments
		self.restPath = rest
	}
}

