
public struct ListNode: Evaluable {

	@ArgumentList var entries: [AnyNode]

	//public var restPath: ArgumentListKey<Self>? = \.$entries

	public var arguments = Args(rest: \.$entries)

	public init() {}

    public func evaluate() throws -> MathValue {
        var list: MathList = []

		for e in entries {
			try list.append(e.evaluate().asFloat())
		}

		return .list(list)
    }

	public func evaluateType() -> MathType? {
		let entryType = entries.map { $0.evaluateType() }
		if let firstType = entryType.first, let firstType, entryType.allSatisfy({ $0 == firstType }) {
			return .list(firstType)
		}
		return nil
	}
}