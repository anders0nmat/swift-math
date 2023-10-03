
public final class TokenParser {
	public typealias Token = (name: String, args: [String])
	public typealias ParseResult = Result<Void, ParseError>

	private var root: AnyNode
	private weak var current: AnyNode?

	private var operators: [String : any Evaluable]

	public init(operators: [String : any Evaluable]) {
		self.root = Node.empty()
		self.current = nil
		self.operators = operators
	}

	public func addOperator(_ node: any Evaluable, name: String) {
		self.operators[name] = node
	}

	internal func processNumber(_ token: Token) -> ParseResult {
		let decimalNumbers = "0123456789"

		if token == ("+-", []) {
			// Switch prefix of number
		}
		else if token == (".", []) {
			// Add decimal point
		}
		else if case let ("#number", args) = token, let number = args.first?.asCharacter(), args.count == 1 &&  decimalNumbers.contains(number) {
			// Add decimal number in "number"
		}
		return .failure(.unknownToken)
	}

	internal func parsePriorityOperator(_ token: Token) -> ParseResult {
		return .failure(.unknownToken)
	}

	internal func processOperator(_ token: Token) -> ParseResult {
		guard var op = operators[token.name] else { return .failure(.unknownToken) }
		
		op.children = [] // Will reset children to EmptyNode
		if case .failure(let error) = op.customize(using: token.args) {
			return .failure(error)
		}

		// Fully copied op at this point
		// Now insert...

		if op.hasPrefix {
			if current is Node<EmptyNode> {
				// TODO: Allow prefix arguments to be empty?
				return .failure(.init(message: .contextError(message: "Empty Node on prefix argument"), currentRoot: root, currentHead: current))
			}
			else {
				let newNode = op.makeNode()
				op.children[0] = current!
				current?.replaceSelf(with: newNode)
				current = op.children[1]
				return .success
			}
		}
		else {
			if current is Node<EmptyNode> {
				current?.replaceSelf(with: op.makeNode())
				current = op.children[0]
				return .success
			}
			else {
				return .failure(.init(message: .contextError(message: "Tried to insert operation on non-empty node"), currentRoot: root, currentHead: current))
			}
		}
	}

	internal func processNavigation(_ token: Token) -> ParseResult {
		return .failure(.unknownToken)
	}

	public func parse(token: Token) -> ParseResult {
		// Order matters! First to return success aborts processing
		let handlers = [
			processNavigation,
			processNumber,
			processOperator,
		]

		for handler in handlers {
			let result = handler(token)
			switch result {
				case .success: return .success
				case .failure(let error) where error.message != .unknownToken:
					return result
				default: break
			}
		}

		return .failure(.unknownToken)
	}

	public func parse(token: String, args: [String] = []) -> ParseResult {
		parse(token: (name: token, args: args))
	}
}

private extension String {
	func asCharacter() -> Character? {
		guard count == 1 else { return nil }
		return Character(self)
	}
}
