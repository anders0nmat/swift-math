
extension TreeParser {
	internal struct Scanner {
		enum Token {
			case number(String)
			case identifier(String)
			case name(String)
			case symbol(String)
			case exitFunction
			case nextArgument
			case startList
			case endList

			case endOfString
			case syntaxError
		}


		var source: String
		var index: String.Index
		var isAtEnd: Bool { index == source.endIndex }
		var current: Character {
			isAtEnd ? "\0" : source[index]
		}

		init(source: String) {
			self.source = source
			self.index = self.source.startIndex
		}

		@discardableResult
		mutating func advance() -> Character {
			defer {
				source.formIndex(after: &index)
			}
			return source[index]
		}

		mutating func match(_ expected: Character) -> Bool {
			if isAtEnd { return false }
			if current != expected { return false }
			advance()
			return true
		}

		mutating func skipWhitespace() {
			while current.isWhitespace { advance() }
		}

		func isNameChar(_ c: Character) -> Bool {
				isNameStartChar(c)
			||	("0"..."9").contains(c)
		}

		func isNameStartChar(_ c: Character) -> Bool {
				("a"..."z").contains(c)
			||	("A"..."Z").contains(c)
			||	"_" == c	
		}

		mutating func scanToken() -> Token {
			skipWhitespace()
			if isAtEnd {
				return .endOfString
			}
			
			let c = advance()

			switch c {
				case "(": return .symbol("(")
				case ")": return .exitFunction
				case ",": return .nextArgument
				case "+": return .symbol("+")
				case "-": return .symbol("-")
				case "*": return .symbol("*")
				case "/": return .symbol("/")
				case "[": return .startList
				case "]": return .endList
				case "\"":
					var str = ""//String(current)
					while current != "\"" && !isAtEnd {
						str.append(current)
						advance()
					}

					if isAtEnd {
						return .syntaxError
					}

					advance()

					return .identifier(str)
				case "0"..."9", ".":
					var num = String(c)
					if num != "." {
						while ("0"..."9").contains(current) {
							num.append(current)
							advance()
						}
						if current != "." {
							return .number(num)
						}
						num.append(current)
						advance()
						while ("0"..."9").contains(current) {
							num.append(current)
							advance()
						}
					}
					else {
						while ("0"..."9").contains(current) {
							num.append(current)
							advance()
						}
					}

					return .number(num)
				case let c where isNameStartChar(c):
					var iden = String(c)
					while isNameChar(current) {
						iden.append(current)
						advance()
					}
					return .name(iden)
				default: return .syntaxError
			}
		}
		
	}
	
	public func parse(expression: String) throws {
		var scanner = Scanner(source: expression)

		var previous = scanner.scanToken()
		var current = scanner.scanToken()

		func advance() {
			previous = current
			current = scanner.scanToken()
		}

		while true {
			switch previous {
			case let .number(num):
				try processToken(Token("#number", [num]))
			case let .identifier(iden):
				try processToken(Token("#identifier", [iden]))
			case let .name(name):
				// Name of variable, constant or function call
				if case .symbol("(") = current {
					// Function call
					try processToken(Token(name))
					advance()
					if case .exitFunction = current {
						advance() // Consume closing bracket on empty-argument functions
					}
				}
				else if operators.keys.contains(name) {
					// Constant
					try processToken(Token(name))
				}
				else {
					// Variable
					try processToken(Token("#variable", [name]))
				}
			case let .symbol(symbol):
				// Assume operator?
				if self.current is Node<Operator.Empty>, symbol == "-" {
					try processToken(Token("#number", ["+-"]))	
				}
				else {
					try processToken(Token(symbol))
				}
			case .exitFunction:
				if let parent = self.current?.parent {
					self.current = parent
				} // else current == root -> Do nothing
			case .nextArgument:
				if let parent = self.current?.parent {
					let next = nextChild(of: parent, from: .child(self.current!))
					if next !== parent {
						self.current = next
					}
					else {
						throw ParseError.syntaxError
					}
				} // else current == root -> Do nothing
			case .startList:
				try processToken(Token("#list"))
			case .endList:
				if let parent = self.current?.parent as? Node<Operator.List> {
					self.current = parent
				}
				else {
					throw ParseError.syntaxError
				}
			case .syntaxError:
				throw ParseError.syntaxError
			case .endOfString:
				return
			}
			
			advance()
		}
	}
}
