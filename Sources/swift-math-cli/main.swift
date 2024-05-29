import Foundation
import swift_math

func flush() { fflush(stdout) }

var debugDraw = false
var clearScreen = true

var lastResult = ""
var events = [String]()

var parser = TreeParser(operators: operators)
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
	Command(["json"], description: "Output current expression as JSON") {
		lastResult = try String(data: parser.save(prettyPrint: true), encoding: .utf8) ?? ""

		/*let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		let data = try encoder.encode(AnyNode(parser.root))

		let jsonString = String(data: data, encoding: .utf8)!
		lastResult = jsonString*/
	},
	Command(["save"], description: "Save current expression to file <arg>") { path in 
		let url = URL(fileURLWithPath: path)
		//try parser.save(prettyPrint: true).write(to: url)
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		let data = try encoder.encode(parser)
		try data.write(to: url)

		lastResult = "Success! saved to \(url)".colored(.green)
		
		
		/*let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		let data = try encoder.encode(AnyNode(parser.root))
		try data.write(to: url)*/
	},
	Command(["load"], description: "Load expression in file <arg>") { path in 
		let url = URL(fileURLWithPath: path)
		//try parser.load(from: Data(contentsOf: url))
		let decoder = JSONDecoder()
		decoder.userInfo[.mathOperators] = operators
		let data = try Data(contentsOf: url)
		let globals = parser.root.variables.export()
		parser = try decoder.decode(TreeParser.self, from: data)
		parser.root.variables.import(globals)
		lastResult = "Success! Loaded from \(url)".colored(.green)
		
		/*let decoder = JSONDecoder()
		decoder.userInfo[.mathOperators] = parser.operators
		let data = try Data(contentsOf: url)
		let node = try decoder.decode(AnyNode.self, from: data)
		parser.assignRoot(node.node)*/
	},
	Command(["cls"], description: "Toggle Clear-Screen on command input") {
		clearScreen.toggle()
	}
]

func treeCallback(node: any NodeProtocol, event: NodeEvent) {
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

func addObserver(to tree: any NodeProtocol) {
	tree.observers = [treeCallback]
	tree.children.forEach(addObserver)
}

calcLoop: while true {
	if clearScreen {
		print(TerminalString.Cursor.clearScreen, TerminalString.Cursor.move(), separator: "", terminator: "")
	}
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

