import Foundation
import swift_math

func flush() {
	fflush(stdout)
}

func drawGeneric(node: AnyNode, current: AnyNode? = nil) -> String {
	let childDraw = node.children.map { draw(node: $0, current: current) }
	let result = "\(node.body.displayName)(\(childDraw.joined(separator: ", ")))"

	if node === current {
		return result.styled([.underline])
	}
	return result
}

func draw(node: AnyNode, current: AnyNode? = nil) -> String {
	let customDrawEvaluable: [ObjectIdentifier : (AnyNode)->String] = [
		ObjectIdentifier(InfixNode.self) : {
			let childDraw = node.children.map { draw(node: $0, current: current) }
			return childDraw.joined(separator: " \($0.body.displayName) ")
		},
		ObjectIdentifier(NumberNode.self) : {
			guard let node = $0 as? Node<NumberNode> else {
				return drawGeneric(node: $0, current: current)
			}
			return node.typedBody.numberString
		},
		ObjectIdentifier(ExpressionNode.self) : {
			guard let node = $0 as? Node<ExpressionNode> else {
				return drawGeneric(node: $0, current: current)
			}
			return ": " + draw(node: node.children[0], current: current)
		},
		ObjectIdentifier(EmptyNode.self) : {_ in
			return "[---]"
		},
		ObjectIdentifier(ConstantNode.self) : {
			guard let node = $0 as? Node<ConstantNode> else {
				return drawGeneric(node: $0, current: current)
			}
			return node.typedBody.displayName
		}
	]

	let result: String
	if let customDrawFunc = customDrawEvaluable[ObjectIdentifier(type(of: node.body))] {
		result = customDrawFunc(node)
	}
	else {
		result = drawGeneric(node: node, current: current)
	}

	if node === current {
		return result.styled([.underline])
	}
	return result
}

let parser = TokenParser(operators: [
	"#": NumberNode(0),
	"+": InfixNode(priority: 10, reducer: +, displayName: "+", children: []),
	"*": InfixNode(priority: 40, reducer: *, displayName: "*", children: []),
	"sin": FunctionNode(displayName: "sin") { sin($0) },
	"cos": FunctionNode(displayName: "cos") { cos($0) },
	"tan": FunctionNode(displayName: "tan") { tan($0) },
	"exp": FunctionNode(displayName: "exp") { exp($0) },
	"()": FunctionNode(displayName: "()") { $0 },
	"pi": ConstantNode(.pi, displayName: "π"),
])

var lastResult = ""
calcLoop: while true {
	print(TerminalString.Cursor.clearScreen, TerminalString.Cursor.move(), separator: "", terminator: "")
	print("SwiftMath Calculator".styled([.bold]))
	print("Exit with", ":q".colored(.cyan), "Help with", ":h".colored(.cyan))
	print()
	print("  " + draw(node: parser.root, current: parser.current))
	switch parser.root.evaluate() {
		case .success(.number(let val)):
			print("  =", String(val).styled([.italic]))
		case .success(.list(let val)):
			print("  =", String(describing: val).styled([.italic]))
		case .failure(let error):
			print("  =", String(describing: error).styled([.italic]).colored(.red))
	}		
	print()

	print(lastResult)
	print(">> ", terminator: "")
	flush()

	guard let command = readLine(strippingNewline: true) else { continue }

	if command.hasPrefix(":") {
		switch command.lowercased().suffix(from: command.index(after: command.startIndex)) {
			case "q", "quit":
				break calcLoop
			case "n", "new", "c", "clear":
				parser.clear()
				continue calcLoop
			case "h", "help":
				lastResult = """
				List of commands:
				  \(":q".colored(.cyan))   \(":quit".colored(.cyan)) : Quits the application
				  \(":n".colored(.cyan))   \(":new".colored(.cyan))
				  \(":c".colored(.cyan))   \(":clear".colored(.cyan)) : starts a new equation
				  \(":h".colored(.cyan))   \(":help".colored(.cyan))  : show this message
				List of known functions:
				  \(parser.operators.keys.joined(separator: "\n  "))
				"""
				continue calcLoop
			case let unknown:
				lastResult = "Unknown Command: \(unknown)".colored(.red)
				continue calcLoop
		}
	}

	let parseResult: TokenParser.ParseResult
	if 
		command == "+-" || 
		command == "." || 
		command.allSatisfy({ ("0"..."9").contains($0) }) ||
		Double(command) != nil {

		parseResult = parser.parse(token: "#", args: [command])
	}
	else {
		parseResult = parser.parse(command)
	}

	switch parseResult {
		case .success(_): lastResult = "Success!".colored(.green)
		case .failure(let error): lastResult = String(describing: error).colored(.red)
	}
}

