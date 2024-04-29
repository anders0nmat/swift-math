
import Foundation

public extension Operator {
	static let addFunctions = FunctionContainer {
		$0.addFunction { (a: Type.Number, b: Type.Number) in a + b }
		$0.addFunction { (a: [Type._0], b: [Type._0]) in a + b }		
	}

	static let subtractFunctions = FunctionContainer {
		$0.addFunction { (a: Type.Number, b: Type.Number) in a - b }
	}
	
	static let multiplyFunctions = FunctionContainer {
		$0.addFunction(*)
	}
}
