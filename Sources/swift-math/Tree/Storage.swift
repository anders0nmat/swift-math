
public struct EmptyStorage: Codable {}

public struct SingleValueStorage<Value: Codable>: Codable {
	public var value: Value

	public init(_ value: Value) {
		self.value = value
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		self.value = try container.decode(Value.self)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(value)
	}
}

public typealias SingleArgumentStorage = SingleValueStorage<AnyNode>

