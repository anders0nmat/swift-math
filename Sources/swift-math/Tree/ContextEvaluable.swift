
/**
	Base protocol for any operator that requires context information
*/
public protocol ContextEvaluable {
	typealias ArgumentPath = ArgumentContainer<Self>
	typealias ArgumentInfo = ArgumentDetail<Self>

	associatedtype Storage: Codable = EmptyStorage
	/**
		Holds all instance data of the operator

		Instance data is all data unique to this _instance_ of the operator, e.g. arguments.
		Some examples for instance data and non-instance data:
		```
		<< x
		>> Variable(instance: "x")

		<< add(2, 3)
		>> AddFunction(instance: Storage(a: Number(2), b: Number(3)))
		
		<< addThree(5)
		>> AddNFunction(addValue: 3, instance: Number(5))
		
		<< pi
		>> Constant(value: 3.141, instance: Storage())
		```

		The `addOne`-function in the example shows the difference well:
		A generic operator `AddNFunction` could be defined, each of which could
		store the increment (3 in the example). This increment is the same for all instances
		of `addThree`. The argument however (5 in the example), is special to this specific call of `addThree`,
		therefore it lives in the `instance` variable.
	*/
	var instance: Storage { get set }
	
	/**
		Stores a KeyPath to all visible arguments of the operator
	*/
	var arguments: ArgumentPath { get }
	/**
		Stores additional information (e.g. display names) to arguments
	*/
	var argumentInfo: ArgumentInfo { get }

	/**
		Unique identifier for this operator
	*/
	var identifier: String { get }

	/**
		Custom initialize operator from token

		The parser creates operators from tokens in the form of
		`<identifier>:<arguments>`
		where `<identifier>` is the identifier of the operator
		and `<arguments>` is a list of `:`-separated strings.

		This function is called every time a new operator is created from a token,
		passing the arguments of the token as the `arguments`-parameter.

		Allows for a single operator to be created with additional information.
		
		Example: Variables

		Variables have a name that is required upon creation, therefore it can be passed with the token:
		`variable:x`
		would result in a call to `Variable().customize(using: ["x"])`.
		This argument can be used to initialize the instance of `Variable`.
	*/
	mutating func customize(using arguments: [String]) -> Bool

	/**
		Evaluate the result of this Operator

		Receives the owning node, which allows access to the entire context of the operator,
		such as variables.
	*/
	func evaluate(in context: Node<Self>) throws -> MathValue

	/**
		Evaluate the type of the result of this Operator

		Used for type inference of some operators.
		`nil` can be returned to indicate that the type can not be known until evaluation through `evaluate()`
	*/
	func evaluateType(in context: Node<Self>) -> MathType?

	/**
		Context event callback

		Will be called when the decendants (children, grand-children, ...) are changed.

		Used to change behavior depending on properties of children.

		Example: Number iteration to list iteration

		The sigma-style summation in mathmatics takes four arguments:
		- Variable name `name`
		- Lower Bound `lower`
		- Upper Bound `upper`
		- Expression `expr`
		It can be written in swift like this:
		```swift
		for <name> in <lower>...<upper> {
			<expr>
		}
		```

		However, it is common to have a list of values we want to iterate over. This form would require the arguments:
		- Variable name `name`
		- List of values `list`
		- Expression `expr`
		This too can be written in swift like the following:
		```swift
		for <name> in <list> {
			<expr>
		}
		```

		Merging the two function signatures results in:
		sum(name, (list | lower, upper), expr)

		Choosing the right signature is possible once the second argument is available:
		- If it evaluates to a list, tale the list-iteration signature
		- Otherwise take the range-based iteration

		By defining `childrenChanged()` we can implement this switch, for example:
		```swift
		let varName, start, end, expression: AnyNode

		mutating func childrenChanged() {
			switch start.returnType {
				case .list(let elementType):
					arguments.argumentsPath = [\.varName, \.start, \.expression]
				default:
					arguments.argumentsPath = [\.varName, \.start, \.end, \.expression]
			}
		}
		```
	*/
	mutating func childrenChanged()

	/**
		Context event callback

		Will be called when the the context (variables) changes.

		Used to change behavior depending on properties of variables.
	*/
	mutating func contextChanged()
}

public extension ContextEvaluable {
	var arguments: ArgumentPath { ArgumentPath() }
	var argumentInfo: ArgumentInfo { ArgumentInfo([:]) }

	mutating func customize(using arguments: [String]) -> Bool { true }

	/**
		Clear all arguments

		Assigns `Node.empty()` to all arguments and `Array()` to the rest-argument
	*/
	mutating func resetArguments() {
		if let prefixPath = arguments.prefixPath {
			self.instance[keyPath: prefixPath].node = Node.empty()
		}
		arguments.argumentsPath.forEach {
			self.instance[keyPath: $0].node = Node.empty()
		}

		if let restPath = arguments.restPath {
			self.instance[keyPath: restPath] = []
		}
	}
	
	func makeNode() -> any NodeProtocol { Node(self) }

	func evaluateType(in context: Node<Self>) -> MathType? { nil }

	mutating func childrenChanged() {}
	mutating func contextChanged() {}	
}

public extension ContextEvaluable where Storage == EmptyStorage {
	var instance: Storage {
		get { Storage() }
		set {}
	}
}

