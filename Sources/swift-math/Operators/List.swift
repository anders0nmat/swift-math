
public extension Operator {
	struct List: Evaluable {
		public var identifier: String { "#list" }
		public var arguments = ArgumentPath(rest: \.value)

		/*public struct Storage: Codable {
			public var entries: [AnyNode] = []
		}
		public var instance = Storage()
		*/
		public var instance = SingleValueStorage([AnyNode]())

		public init() {}

		public func evaluate() throws -> MathValue {
			var list = Type.List()

			for e in instance.value {
				try list.append(e.evaluate())
			}

			return .list(list)
		}

		public func evaluateType() -> MathType? {
			if instance.value.isEmpty {
				return .list(nil)
			}
			let entryType = instance.value.map { $0.returnType }
			if let firstType = entryType.first, let firstType, entryType.allSatisfy({ $0 == firstType }) {
				return .list(firstType)
			}
			return nil
		}
	}
}