
public struct ListNode: Evaluable {

	var entries = ArgumentList()

	public var arguments = ArgumentPaths(rest: \.entries)

	public init() {}

    public func evaluate() throws -> MathValue {
        var list: MathList = []

		for e in entries.nodeList {
			try list.append(e.evaluate().asFloat())
		}

		return .list(list)
    }

	public func evaluateType() -> MathType? {
		let entryType = entries.nodeList.map { $0.evaluateType() }
		if let firstType = entryType.first, let firstType, entryType.allSatisfy({ $0 == firstType }) {
			return .list(firstType)
		}
		return nil
	}
}