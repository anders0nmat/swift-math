
public typealias MathArgumentKey<T> = WritableKeyPath<T, MathArgument>
public typealias MathArgumentListKey<T> = WritableKeyPath<T, MathArgumentList>

public struct MathArgument {
	public var node: AnyNode

	public init() {
		self.node = Node.empty()
	}

	func evaluate() throws -> MathValue { try node.evaluate() }
	var returnType: MathType? { node.returnType }
	var variables: VariableContainer { node.variables }
}

public struct MathArgumentList {
	public var nodeList: [AnyNode]

	public init() {
		self.nodeList = []
	}
}

public struct MathArgumentPaths<T: ContextEvaluable> {
	public var prefixPath: MathArgumentKey<T>?
	public var argumentsPath: [MathArgumentKey<T>]
	public var restPath: MathArgumentListKey<T>?

	public init(prefix: MathArgumentKey<T>? = nil, arguments: MathArgumentKey<T>..., rest: MathArgumentListKey<T>? = nil) {
		self.prefixPath = prefix
		self.argumentsPath = arguments
		self.restPath = rest
	}
}

public protocol MathArgumentInfo {
	var hasPrefix: Bool { get }
	var hasArguments: Bool { get }
	var hasRest: Bool { get }

	var argumentCount: Int { get }

	var hasPriority: Bool { get }
	var priority: UInt? { get }

	var prefixArgument: MathArgument? { get }
	var arguments: [MathArgument] { get }
	var restArgument: MathArgumentList? { get }

	var prefixNode: AnyNode? { get }
	var argumentNodes: [AnyNode] { get }
	var restNodes: [AnyNode]? { get }

	var nodes: [AnyNode] { get set }
}

public struct MathNodeArguments<T: ContextEvaluable>: MathArgumentInfo {
	public var argumentPaths: MathArgumentPaths<T>
	public unowned var node: Node<T>

	public var hasPrefix: Bool { argumentPaths.prefixPath != nil }
	public var hasArguments: Bool { !argumentPaths.argumentsPath.isEmpty }
	public var hasRest: Bool { argumentPaths.restPath != nil }

	public var argumentCount: Int { argumentPaths.argumentsPath.count }

	public var hasPriority: Bool { T.self is any PriorityEvaluable }
	public var priority: UInt? { (node._body as? any PriorityEvaluable)?.priority }

	public var prefixArgument: MathArgument? { argumentPaths.prefixPath.map { node.body[keyPath: $0] } }
	public var arguments: [MathArgument] { argumentPaths.argumentsPath.map { node.body[keyPath: $0] } }
	public var restArgument: MathArgumentList? { argumentPaths.restPath.map { node.body[keyPath: $0] } }

	public var prefixNode: AnyNode? { prefixArgument?.node }
	public var argumentNodes: [AnyNode] { arguments.map(\.node) }
	public var restNodes: [AnyNode]? { restArgument?.nodeList }

	public var nodes: [AnyNode] {
		get {
				(prefixNode.map { [$0] } ?? [])
			+	(argumentNodes)
			+	(restNodes ?? [])
		}
		nonmutating set {
			var iterator = newValue.makeIterator()

			if let prefixPath = argumentPaths.prefixPath {
				node._body[keyPath: prefixPath].node = iterator.next() ?? Node<EmptyNode>.empty()
			}

			argumentPaths.argumentsPath.forEach {
				node._body[keyPath: $0].node = iterator.next() ?? Node.empty()
			}

			if let restPath = argumentPaths.restPath {
				node._body[keyPath: restPath].nodeList = Array(iterator)
			}
		}
	}
}

