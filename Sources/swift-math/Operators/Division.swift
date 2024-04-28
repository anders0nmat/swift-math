
public extension Operator {
	struct Division: PrefixFunctionEvaluable {
	    public var identifier: String { "/" }
		public static var functions = FunctionContainer {
			$0.addFunction(/)
		}

		public var divident = Argument()
		public var divisor = Argument()
		public var arguments = ArgumentPath(
			arguments: \.divident, \.divisor)
	}
}
