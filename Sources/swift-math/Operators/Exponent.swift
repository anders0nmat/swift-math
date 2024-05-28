
import Foundation

public extension Operator {
	struct Exponent: PrefixFunctionEvaluable {
	    public var identifier: String { "^" }
		public static var functions = FunctionContainer {
			$0.addFunction(pow)
		}

		public struct Storage: Codable {
			public var base = AnyNode()
			public var exponent = AnyNode()
		}
		public var instance = Storage()
		
		public var argumentInfo = ArgumentInfo([
			\.base : .init(name: "base"),
			\.exponent : .init(name: "exponent"),
		])

		public var arguments = ArgumentPath(
			prefix: \.base,
			arguments: \.exponent)
	}
}
