
extension TreeParser {
	public func parse(token: String, args: [String] = []) throws {
		try processToken(Token(name: token, args: args))
	}

	public func parse(command: String) throws {
		for command in command.split(separator: ";") {
			let parts = command.split(separator: ":")
			let name = String(parts[0])
			let args = parts.suffix(from: 1).map { String($0) }
			try parse(token: name, args: args)
		}
	}
}
