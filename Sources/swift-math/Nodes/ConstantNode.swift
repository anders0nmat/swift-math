
public struct ConstantNode: Evaluable {
	public private(set) var value: MathValue
	public var displayName: String

	public init(_ value: MathNumber, displayName: String) {
		self.value = .number(value)
		self.displayName = displayName
	}

	public init(_ value: MathList, displayName: String) {
		self.value = .list(value)
		self.displayName = displayName
	}

	public func evaluate() throws -> MathValue { value }

	public func evaluateType() -> MathType? { value.type }
}
