import Foundation
import swift_math

func flush() {
	fflush(stdout)
}

let parser = TokenParser(operators: [
	"#": NumberNode(0),
	"+": InfixNode(priority: 10, reducer: +, displayName: "+", children: []),
	"-": InfixNode(priority: 11, reducer: -, displayName: "-", children: []),
	"*": InfixNode(priority: 40, reducer: *, displayName: "*", children: []),
	"sin": SingleArgumentNode(displayName: "sin") { sin($0) },
	"cos": SingleArgumentNode(displayName: "cos") { cos($0) },
	"tan": SingleArgumentNode(displayName: "tan") { tan($0) },
	"exp": SingleArgumentNode(displayName: "exp") { exp($0) },
	"()": SingleArgumentNode(displayName: "()") { $0 },
	"pi": ConstantNode(.pi, displayName: "π"),
	"list": ListNode(),
])
let printer = NodePrinter()
var debugDraw = false

var lastResult = ""
calcLoop: while true {
	print(TerminalString.Cursor.clearScreen, TerminalString.Cursor.move(), separator: "", terminator: "")
	print("SwiftMath Calculator".styled([.bold]))
	print("Exit with", ":q".colored(.cyan), "Help with", ":h".colored(.cyan))
	print()
	if debugDraw {
		print(printer.debugDraw(node: parser.root, current: parser.current).map({"  " + $0}).joined(separator: "\n"))
	}
	else {
		print("  " + printer.prettyDraw(node: parser.root, current: parser.current))
	}
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
			case "d", "debug":
				debugDraw.toggle()
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

