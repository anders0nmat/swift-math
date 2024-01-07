
public protocol ContextEvaluable {
	/*
	Path to arguments the function requires

	- Prefix: Argument that is immediately before the function itself
	- Arguments: Any amount of single-expression arguments
	- Rest: VarArg-like arguments, so zero or more expressions
	*/
	var prefixPath: ArgumentKey<Self>? { get }
	var argumentsPath: [ArgumentKey<Self>] { get }
	var restPath: ArgumentListKey<Self>? { get }

	/*
	Generic display name
	*/
	var displayName: String { get }

	/*
	Initialization for individual nodes.
	Required if you want something per-node initialized.
	Example: variable names, constant expression names
	*/
	mutating func customize(using arguments: [String]) -> Result<Nothing, ParseError>

	/*
	Function to call if evaluation is requested.
	Returns math-value or error
	*/
	func evaluate(in context: Node<Self>) -> MathResult
}

public extension ContextEvaluable {
	var prefixPath: ArgumentKey<Self>? { nil }
	var argumentsPath: [ArgumentKey<Self>] { [] }
	var restPath: ArgumentListKey<Self>? { nil }

	var displayName: String { String(describing: Self.self) }

	mutating func customize(using arguments: [String]) -> Result<Nothing, ParseError> { .success }

	mutating func resetArguments() {
		if let prefixPath {
			self[keyPath: prefixPath].node = Node.empty()
		}
		argumentsPath.forEach {
			self[keyPath: $0].node = Node.empty()
		}

		if let restPath {
			self[keyPath: restPath].nodeList = []
		}
	}
	
	func makeNode() -> AnyNode { Node(self) }
}

