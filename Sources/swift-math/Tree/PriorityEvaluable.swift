
public protocol PriorityEvaluable: Evaluable {
	var priority: UInt { get }

	func merge(with other: any PriorityEvaluable) -> (any PriorityEvaluable)?
}

public extension PriorityEvaluable {
	func merge(with other: any PriorityEvaluable) -> (any PriorityEvaluable)? { nil }
}
