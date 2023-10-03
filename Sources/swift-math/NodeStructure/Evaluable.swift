
public protocol Evaluable {
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
	Initialization for individual nodes.
	Required if you want something per-node initialized.
	Example: variable names, constant expression names
	*/
	mutating func customize(using arguments: [String]) -> Result<Void, ParseError>

	/*
	Function to call if evaluation is requested.
	Returns math-value or error
	*/
	func evaluate() -> MathResult
}

public extension Evaluable {
	var prefixPath: ArgumentKey<Self>? { nil }
	var argumentsPath: [ArgumentKey<Self>] { [] }
	var restPath: ArgumentListKey<Self>? { nil }

	var hasPrefix: Bool { self.prefixPath != nil }
	var hasRest: Bool { self.restPath != nil }

	mutating func customize(using arguments: [String]) -> Result<Void, ParseError> { .success }

	var children: [AnyNode] {
		get {
			var result: [AnyNode] = []

			if let prefixPath {
				result += [self[keyPath: prefixPath].node]
			}

			result += argumentsPath.map { self[keyPath: $0].node }

			if let restPath {
				result += self[keyPath: restPath].nodeList
			}

			return result
		}

		set {
			// Put new values in matching place and fill with EmptyNode if neccessary
			var nodeIterator = newValue.makeIterator()

			if let prefixPath {
				self[keyPath: prefixPath].node = nodeIterator.next() ?? Node.empty()
			}

			argumentsPath.forEach {
				self[keyPath: $0].node = nodeIterator.next() ?? Node.empty()
			}

			if let restPath {
				self[keyPath: restPath].nodeList = Array(nodeIterator)
			}
		}
	}

	func makeNode() -> AnyNode {
		return Node(self)
	}
}

