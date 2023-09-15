
@propertyWrapper
public struct Argument {
	public var wrappedValue: AnyNode

	public var projectedValue: Argument { 
		get { self }
		set { self = newValue }
	}

	public init(wrappedValue: AnyNode) {
		self.wrappedValue = wrappedValue
	}
}

