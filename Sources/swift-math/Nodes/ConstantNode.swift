
public struct ConstantNode: Evaluable {
	public private(set) var value: MathValue
	public var displayName: String
	public var identifier: String

	public init<T: MathTypeConvertible>(_ value: T, displayName: String, identifier: String) {
		self.value = value.mathValue
		self.displayName = displayName
		self.identifier = identifier
	}

	public func evaluate() throws -> MathValue { value }
	public func evaluateType() -> MathType? { value.type }
}
