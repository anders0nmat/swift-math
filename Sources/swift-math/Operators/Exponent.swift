
import Foundation

public extension Operator {
	struct Exponent: PrefixFunctionEvaluable {
	    public var identifier: String { "^" }
		public static var functions = FunctionContainer {
			$0.addFunction(pow)
		}

		public var base = Argument(name: "Base")
		public var exponent = Argument(name: "Exponent")
		public var arguments = ArgumentPath(
			prefix: \.base,
			arguments: \.exponent)
	}
}
