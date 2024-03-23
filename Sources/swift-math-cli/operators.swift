import swift_math
import Foundation


let operators: [AnyEvaluable] = [
	NumberNode(0),
	ListNode(),
	VariableNode(""),
	IdentifierNode(""),
	ConstantNode(MathNumber.pi, displayName: "π", identifier: "pi"),
	FunctionNode(identifier: "(") { (a: Math._0) in a },
	InfixNode(priority: 10, identifier: "+") {
		$0.addFunction { (a: MathNumber, b: MathNumber) in a + b }
		$0.addFunction { (a: [MathNumber], b: [MathNumber]) in a + b }
	},
	InfixNode(priority: 11, identifier: "-") {
		$0.addFunction { (a: MathNumber, b: MathNumber) in a - b }
	},
	InfixNode(priority: 40, identifier: "*") {
		$0.addFunction(*)
	},
	PrefixFunctionNode(identifier: "/", arguments: [MathArgument()]) { 
		$0.addFunction(/)
	},
	PrefixFunctionNode(identifier: "pow", arguments: [MathArgument()]) { 
		$0.addFunction(pow)
	},

	FunctionNode(identifier: "sin", function: sin),
	FunctionNode(identifier: "cos", function: cos),
	FunctionNode(identifier: "tan", function: tan),
	FunctionNode(identifier: "exp", function: exp),
	IterateNode(identifier: "sum", initialValue: 0, reducer: +),
	FunctionNode(identifier: "len") { (a: [Math._0]) in MathNumber(a.count)	},

	PrefixFunctionNode(identifier: "at") {
		(arr: [Math._0], num: MathNumber) in
		let idx = try num.asInt()
		if arr.indices.contains(idx) {
			return arr[idx]
		}
		throw MathError.valueError
	},
	FunctionNode(identifier: "repeat") {
		(element: Math._0, times: MathNumber) -> [Math._0] in
		let i = try times.asInt()
		guard i >= 0 else {
			throw MathError.valueError
		}

		return [Math._0](repeating: element, count: i)
	}
]
