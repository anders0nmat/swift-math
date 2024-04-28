import swift_math
import Foundation


let operators: [AnyEvaluable] = 
	Operator.builtins +
	Operator.basicArithmetic +
	Operator.constants +
	Operator.trigonometry +
	Operator.listManipulation + 

	[	
	Operator.PrefixFunction(identifier: "pow", arguments: [Argument()]) { 
		$0.addFunction(pow)
	},

	Operator.Function(identifier: "exp", function: exp),
	Operator.Iterate(identifier: "sum", initialValue: 0, reducer: +),
	]
