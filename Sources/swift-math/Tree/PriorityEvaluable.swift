
public protocol PriorityEvaluable: Evaluable {
	var priority: UInt { get }

	/*
		Merges `self` with `other` operator
		
		Result indicates success
	*/
	mutating func merge(with other: any PriorityEvaluable) -> Bool
	mutating func merge(with other: Self) -> Bool
}

extension PriorityEvaluable {
	public mutating func merge(with other: any PriorityEvaluable) -> Bool {
		guard let other = other as? Self else { return false }
		return merge(with: other)
	}

	public mutating func merge(with other: Self) -> Bool { false }
}

extension _Node {
	internal func mergeBody(with other: any PriorityEvaluable) -> Bool {
		if
		var body = self.body as? any PriorityEvaluable,
		body.merge(with: other) {
			self.body = body as! Body
			return true
		}
		return false
	}
}