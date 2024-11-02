
/**
	Path of an operator to its arguments, used for indexing and identifying
*/
public typealias ArgumentKey<T: ContextEvaluable> = WritableKeyPath<T.Storage, AnyNode>

/**
	Path of an operator to its vararg-argument, used for indexing and identifying
*/
public typealias ArgumentListKey<T: ContextEvaluable> = WritableKeyPath<T.Storage, [AnyNode]>

/**
	Defines all visible arguments of an operator

	Visible arguments are those that can be interacted with through the parser
	or other front-facing means.
	An argument is represented by an instance of `AnyNode` and can be registered and addressed
	by its KeyPath.
	An operator may have the following argument types:
	
	- Zero or one _prefix_ argument
	- Zero or more _arguments_
	- Zero or one _rest_ argument, indicating vararg-like behavior if present

	The _prefix_ argument, if present, is handled by the parser by taking the currently active operator and passing
	it to the prefix node as indicated by the _prefix_ argument.

	The _rest_ argument lets the operator take unlimited (zero or more) trailing arguments in its call.
	
	Example use: Max Operator
	
	The `max()`-function allows for _at least_ two but may take an unlimited amount of arguments to be computed.
	An implementation could look like this:
	```swift
	struct MaxFunction: Evaluable {
		var arguments = ArgumentContainer<List>(
			prefix: nil,
			arguments: [\.a, \.b],
			rest: \.others)
		
		var a = AnyNode()
		var b = AnyNode()
		var others: [AnyNode] = []

		func evaluate(...) -> MathValue {
			let values = [a, b] + others
			return values.max()
		}
	}
	```
	Example call:
	```
	<< max(7, 2)
	>> MaxFunction(a: Number(7), b: Number(2), others: [])
	<< max(9, 5, 1, 3, 0)
	>> MaxFunction(a: Number(9), b: Number(5), others: [Number(1), Number(3), Number(0)])
	```
*/
public struct ArgumentContainer<T: ContextEvaluable> {
	public var prefixPath: ArgumentKey<T>?
	public var argumentsPath: [ArgumentKey<T>]
	public var restPath: ArgumentListKey<T>?

	public init(
		prefix: ArgumentKey<T>? = nil,
		arguments: ArgumentKey<T>...,
		rest: ArgumentListKey<T>? = nil) {

		self.prefixPath = prefix
		self.argumentsPath = arguments
		self.restPath = rest
	}
}

