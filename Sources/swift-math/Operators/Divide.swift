
public extension Operator {
	struct Divide: PrefixFunctionEvaluable {
	    public var identifier: String { "/" }
		public static var functions = FunctionContainer {
			$0.addFunction(/)
		}

		public struct Storage: Codable {
			public var divident = AnyNode()
			public var divisor = AnyNode()
		}
		public var instance = Storage()

		public var argumentInfo = ArgumentInfo([
			\.divident : .init(name: "divident"),
			\.divisor : .init(name: "divisor"),
		])

		public var arguments = ArgumentPath(
			prefix: \.divident,
			arguments: \.divisor)
	}
}
