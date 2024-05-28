
public extension Operator {
	struct Function: Evaluable {
		public struct Storage: Codable {
			public var args: [AnyNode]
		}
		public var instance: Storage
		public internal(set) var functions: FunctionContainer
		
		public internal(set) var arguments: ArgumentPath
		public let identifier: String

		public init(identifier: String, arguments: [AnyNode], functions: FunctionContainer) {
			self.identifier = identifier
			self.instance = Storage(args: arguments)
			self.arguments = ArgumentPath()
			self.functions = functions

			for idx in instance.args.indices {
				self.arguments.argumentsPath.append(\.args[idx])
			}
		}

		public func evaluate() throws -> MathValue { try functions.evaluate(instance.args) }
		public func evaluateType() -> MathType? { functions.evaluateType(instance.args) }
	}
}

public extension Operator.Function {
	init<T0, R>(identifier: String, function: @escaping (T0) throws -> R) 
	where T0: MathTypeConvertible, R: MathTypeConvertible {
		self.init(
			identifier: identifier,
			arguments: [AnyNode()],
			functions: FunctionContainer {
				$0.addFunction(function)
			}
		)
	}

	init<T0, T1, R>(identifier: String, function: @escaping (T0, T1) throws -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, R: MathTypeConvertible {
		self.init(
			identifier: identifier,
			arguments: [AnyNode(), AnyNode()],
			functions: FunctionContainer {
				$0.addFunction(function)
			}
		)
	}

	init<T0, T1, T2, R>(identifier: String, function: @escaping (T0, T1, T2) throws -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, T2: MathTypeConvertible, R: MathTypeConvertible {
		self.init(
			identifier: identifier,
			arguments: [AnyNode(), AnyNode(), AnyNode()],
			functions: FunctionContainer {
				$0.addFunction(function)
			}
		)
	}

	init<T0, T1, T2, T3, R>(identifier: String, function: @escaping (T0, T1, T2, T3) throws -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, T2: MathTypeConvertible, T3: MathTypeConvertible, R: MathTypeConvertible {
		self.init(
			identifier: identifier,
			arguments: [AnyNode(), AnyNode(), AnyNode(), AnyNode()],
			functions: FunctionContainer {
				$0.addFunction(function)
			}
		)
	}
}

