
public extension Operator {
	struct Parenthesis: FunctionEvaluable {
	    public var identifier: String { "(" }
		public static var functions = FunctionContainer {
			$0.addFunction { (a: Type._0) in a }
		}

		public var instance = SingleArgumentStorage(AnyNode())

		public var arguments = ArgumentPath(
			arguments: \.value)
	}
}
