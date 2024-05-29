import swift_math
import Foundation


let operators = TreeParser.expandOperatorArray(
	Operator.builtins +
	Operator.basicArithmetic +
	Operator.advancedArithmetic +
	Operator.constants +
	Operator.trigonometry +
	Operator.listManipulation + 

	[
	Operator.Function(identifier: "exp", function: exp),
	Operator.Iterate(identifier: "sum", initialValue: .number(0), functions: Operator.addFunctions),
	]
)
