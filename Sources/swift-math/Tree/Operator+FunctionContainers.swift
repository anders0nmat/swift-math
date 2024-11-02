
import Foundation

public extension Operator {
	static let addFunctions = FunctionContainer {
		// Scalar addition
		$0.addFunction { (a: Type.Number, b: Type.Number) in a + b }
		// List concatenation
		$0.addFunction { (a: [Type._0], b: [Type._0]) in a + b }		
	}

	static let subtractFunctions = FunctionContainer {
		// Scalar subtraction
		$0.addFunction { (a: Type.Number, b: Type.Number) in a - b }
	}
	
	static let multiplyFunctions = FunctionContainer {
		// Scalar multiplication
		$0.addFunction(*)
		// List multiplication
		$0.addFunction { (a: [Type._0], count: Type.Number) in
			var result = [Type._0]()
			let count = try count.asInt()
			for _ in 0..<count {
				result += a
			}
			return result
		}
	}
}
