
public final class TokenParser {
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

	//public func 
}
