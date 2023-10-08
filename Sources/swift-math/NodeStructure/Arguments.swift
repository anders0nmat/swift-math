
public typealias ArgumentKey<T> = WritableKeyPath<T, Argument>
public typealias ArgumentListKey<T> = WritableKeyPath<T, ArgumentList>

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

	public init(wrappedValue: [AnyNode]) {
		self.wrappedValue = wrappedValue
	}
}


struct Value {
	var value: Int
}
