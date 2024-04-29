
public extension Operator {
	struct Divide: PrefixFunctionEvaluable {
	    public var identifier: String { "/" }
		public static var functions = FunctionContainer {
			$0.addFunction(/)
		}

		public var divident = Argument(name: "Divident")
		public var divisor = Argument(name: "Divisor")
		public var arguments = ArgumentPath(
			prefix: \.divident,
			arguments: \.divisor)
	}
}
