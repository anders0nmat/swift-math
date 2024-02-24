
enum CommandError: Error {
	case unexpectedArgument
	case missingArgument
}

struct Command {
	var names: [String]
	var description: String
	var action: (String) throws -> Void
	var hasArgument: Bool

	init(_ names: [String], description: String, action: @escaping (String) throws -> Void) {
		self.names = names
		self.description = description
		self.action = action
		self.hasArgument = true
	}

	init(_ names: [String], description: String, action: @escaping () throws -> Void) {
		self.names = names
		self.description = description
		self.action = {_ in try action() }
		self.hasArgument = false
	}

	func call(_ arg: String) throws {
		if hasArgument {
			try action(arg)
		}
		else if !arg.isEmpty {
			throw CommandError.unexpectedArgument
		}
		else {
			try action(arg)
		}
	}

	func matches(_ name: String) -> Bool {
		names.contains(name)
	}

	func getHelp(columnWidth: Int, prefix: String = "") -> String {
		let arg = hasArgument ? " <arg>" : ""

		var result: [String] = []
		var it = names.makeIterator()
		while let name = it.next() {
			var s = ":" + name + arg
			let diff = columnWidth - s.count
			if diff < 1 {
				result.append(s)
				continue
			}
			
			s += String(repeating: " ", count: diff)

			if let name = it.next() {
				var s2 = ":" + name + arg
				let diff = columnWidth - s2.count
				if diff < 1 {
					result.append(s)
					result.append(s2)
					continue
				}
				s2 += String(repeating: " ", count: diff)
				s += s2
				result.append(s)
			}
		}

		if !description.isEmpty {
			var last = result.last!
			let descDiff = 2 * columnWidth - last.count
			last += String(repeating: " ", count: descDiff)
			last += ": " + description
			result.removeLast()
			result.append(last)
		}

		return result
			.map {prefix + $0}
			.joined(separator: "\n")
	}
}
