
public extension Operator {
	struct Identifier: Evaluable {
		public var identifier: String { "#identifier" }

		/*public struct Storage: Codable {
			public let name: String
		}
		public var instance: Storage*/
		public var instance: SingleValueStorage<Type.Identifier>

		public init(_ identifier: Type.Identifier) {
			self.instance = SingleValueStorage(identifier)
		}

		public mutating func customize(using arguments: [String]) -> Bool {
			guard let rawString = arguments.first else { return false }
			guard arguments.count == 1 else { return false }

			self = Self.init(rawString)
			return true
		}

		public func evaluate() throws -> MathValue { .identifier(instance.value) }
		public func evaluateType() -> MathType? { .identifier }
	}
}

public extension Node where Body == Operator.Identifier {
	static func identifier(_ name: Type.Identifier) -> Self { Self(Body(name)) }
}