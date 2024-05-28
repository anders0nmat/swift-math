
/*public typealias ArgumentKey<T> = WritableKeyPath<T, Argument>
public typealias ArgumentListKey<T> = WritableKeyPath<T, ArgumentList>*/

/*public struct Argument: Encodable {
	//public var name: String
	public var node: AnyNode

	public init(/*name: String = ""*/) {
		//self.name = name
		self.node = Node.empty()
	}

	func evaluate() throws -> MathValue { try node.evaluate() }
	var returnType: MathType? { node.returnType }
	var variables: VariableContainer { node.variables }
}

public struct ArgumentList: Encodable {
	//public var nameGenerator: (Array.Index) -> String
	public var nodeList: [AnyNode]

	public init(/*nameGenerator: @escaping (Array.Index) -> String = { _ in "" }*/) {
	//	self.nameGenerator = nameGenerator
		self.nodeList = []
	}

	func evaluate() throws -> [MathValue] {
		try nodeList.map { try $0.evaluate() }
	}
	var returnTypes: [MathType?] {
		nodeList.map(\.returnType)
	}
}*/
/*
public struct ArgumentInfo {
	var name: String

	init(name: String) {
		self.name = name
	}
}

public struct ArgumentListInfo {
	var nameGenerator: (Array.Index) -> String

	init(nameGenerator: @escaping (Array.Index) -> String) {
		self.nameGenerator = nameGenerator
	}
}
*/


public typealias ArgumentKey<T: ContextEvaluable> = WritableKeyPath<T.Storage, AnyNode>
public typealias ArgumentListKey<T: ContextEvaluable> = WritableKeyPath<T.Storage, [AnyNode]>

public struct ArgumentContainer<T: ContextEvaluable> {
	public var prefixPath: ArgumentKey<T>?
	public var argumentsPath: [ArgumentKey<T>]
	public var restPath: ArgumentListKey<T>?

	public init(
		prefix: ArgumentKey<T>? = nil,
		arguments: ArgumentKey<T>...,
		rest: ArgumentListKey<T>? = nil) {

		self.prefixPath = prefix
		self.argumentsPath = arguments
		self.restPath = rest
	}
}

