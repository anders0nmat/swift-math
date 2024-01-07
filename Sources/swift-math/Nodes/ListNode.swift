
public struct ListNode: Evaluable {

	@ArgumentList var entries: [AnyNode]

	public var restPath: ArgumentListKey<Self>? = \.$entries

	public init() {}

    public func evaluate() -> MathResult {
        var list: MathList = []

		for e in entries {
			switch e.evaluate() {
				case .success(.number(let num)):
					list.append(num)
				case .success(.list(_)):
					return .failure(.evalError(message: "Lists only support scalars"))
				case .failure(let error):
					return .failure(error)
			}
		}

		return .success(.list(list))
    }
}