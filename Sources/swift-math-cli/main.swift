import Foundation
import swift_math

func flush() { fflush(stdout) }

var debugDraw = false

var lastResult = ""
var events = [String]()

let parser = TreeParser(operators: operators)
//let printer = NodePrinter()
let commands: [Command] = [
	Command(["q", "quit"], description: "Quits the application") {
		exit(0)
	},
	Command(["h", "help"], description: "Show this help list") {
		lastResult = ""
		for cmd in commands {
			lastResult += cmd.getHelp(columnWidth: 15, prefix: "  ") + "\n"
		}
	},
	Command(["n", "new", "c", "clear"], description: "Starts a new equation. Keeps global variables") {
		let globals = parser.root.variables.export()
		parser.clear()
		parser.root.variables.import(globals)
	},
	Command(["s", "store"], description: "Stores current result in variable <arg>") { name in
		if let result = try? parser.root.evaluate() {
			(parser.root as! Node<Operator.Expression>).variables.set(name, to: result)
			lastResult = "Stored result in variable '\(name)'".colored(.green)
		}
		else {
			lastResult = "Cannot store error in vaiable"
		}
	},
	Command(["d", "debug"], description: "Toggles debug mode") {
		debugDraw.toggle()
	},
	Command(["e", "expr"], description: "Parse <arg> as one expression") { expr in
		addObserver(to: parser.root)
		events = []
		try parser.parse(expression: expr)
		lastResult = "Success!".colored(.green)
	},
	Command(["t", "token"], description: "Insert <arg> as a token") { command in
		addObserver(to: parser.root)
		events = []
		try parser.parse(command: command)
		lastResult = "Success!".colored(.green)
	},
	Command(["v", "vars"], description: "Shows all available variables") {
		guard let node = parser.current else { return }

		lastResult = node.variables
			.listDeclared()
			.map {
				let type = node.variables.getType($0)
				var value = ""
				if let v = node.variables.get($0) {
					value = " = \(v)"
				}
				return "\($0) : \(type != nil ? String(describing: type!) : "unknown")" + value
			}
			.joined(separator: "\n")
	},
	Command(["r", "remove"], description: "Remove selected expression") {
		parser.erase()
	},
]

func treeCallback(node: AnyNode, event: NodeEvent) {
	events.append("\(event) at \(node)")
}

func executeCommand(_ input: String) {
	guard !input.isEmpty else {
		lastResult = "Missing Command after ':'"
		return
	}
	let parts = input.split(separator: " ", maxSplits: 1)
	let command = String(parts[0])
	let arg = String(parts.count > 1 ? parts[1] : "")

	if let commandObject = commands.first(where: { $0.matches(command) }) {
		do {
			try commandObject.call(arg)
		}
		catch let e {
			lastResult = "Command error: \(e)".colored(.red)
		}
	}
	else {
		lastResult = "Unknown Command: \(command)".colored(.red)
	}
}

func addObserver(to tree: AnyNode) {
	tree.observers = [treeCallback]
	tree.children.forEach(addObserver)
}

calcLoop: while true {
	//print(TerminalString.Cursor.clearScreen, TerminalString.Cursor.move(), separator: "", terminator: "")
	print("SwiftMath Calculator".styled([.bold]))
	print("Exit with", ":q".colored(.cyan), "Help with", ":h".colored(.cyan))
	print()
	currentNode = parser.current
	if debugDraw {
		print(parser.root.debugDisplayStrings.map({ "  " + $0 }).joined(separator: "\n"))
	}
	else {
		print("  " + parser.root.displayString)
	}
	switch Result(catching: { try parser.root.evaluate() }) {
		case .success(let val):
			print("  =", String(describing: val).styled([.italic]))
		case .failure(let error):
			print("  =", String(describing: error).styled([.italic]).colored(.red))
	}		
	print()

	print(lastResult)
	print(">> ", terminator: "")
	flush()

	guard let input = readLine(strippingNewline: true) else { continue }

	if input.hasPrefix(":") {
		executeCommand(String(input.lowercased().dropFirst()))
		continue calcLoop
	}

	do {
		addObserver(to: parser.root)
		events = []
		try parser.parse(expression: input)

		lastResult = "Success!".colored(.green)
	}
	catch let err {
		lastResult = String(describing: err).colored(.red)
	}
}

