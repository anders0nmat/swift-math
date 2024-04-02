
public protocol PriorityEvaluable: Evaluable {
	var priority: UInt { get }

	/*
		Returns a merged version of `self` and `other` or `nil` if not possible.
		Used to keep tree structure flat on infix operations which
		usually come as binary operations
	*/
	func merge(with other: any PriorityEvaluable) -> (any PriorityEvaluable)?
}

public extension PriorityEvaluable {
	func merge(with other: any PriorityEvaluable) -> (any PriorityEvaluable)? { nil }
}
