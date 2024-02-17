
public typealias ArgumentKey<T> = WritableKeyPath<T, Argument>
public typealias ArgumentListKey<T> = WritableKeyPath<T, ArgumentList>

// TODO: Translate @propertyWrapper Argument to just Argument

@propertyWrapper
public struct Argument {
	public var wrappedValue: AnyNode
	public var node: AnyNode {
		get { wrappedValue }
		set { wrappedValue = newValue }
	}

	public var projectedValue: Argument { 
		get { self }
		set { self = newValue }
	}

	public init(wrappedValue: AnyNode = Node.empty()) {
		self.wrappedValue = wrappedValue
	}
}

@propertyWrapper
public struct ArgumentList {
	public var wrappedValue: [AnyNode]
	public var nodeList: [AnyNode] {
		get { wrappedValue }
		set { wrappedValue = newValue }
	}

	public var projectedValue: ArgumentList {
		get { self }
		set { self = newValue }
	}

	public init(wrappedValue: [AnyNode] = []) {
		self.wrappedValue = wrappedValue
	}
}

public struct ArgumentPaths<T> {
	public var prefixPath: ArgumentKey<T>?
	public var argumentsPath: [ArgumentKey<T>]
	public var restPath: ArgumentListKey<T>?

	public init(prefix: ArgumentKey<T>? = nil, arguments: ArgumentKey<T>..., rest: ArgumentListKey<T>? = nil) {
		self.prefixPath = prefix
		self.argumentsPath = arguments
		self.restPath = rest
	}
}

