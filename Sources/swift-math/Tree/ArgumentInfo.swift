
public struct ArgumentData {
	var name: String
}

public struct ArgumentListData {
	var nameGenerator: (Array.Index) -> String
}

public struct ArgumentDetail<T: ContextEvaluable> {
	private var argumentInfo: [ArgumentKey<T> : ArgumentData]
	private var restArgumentInfo: [ArgumentListKey<T> : ArgumentListData]

	public init(
		_ info: [ArgumentKey<T> : ArgumentData],
		restArgument: [ArgumentListKey<T> : ArgumentListData] = [:]) {
		
		self.argumentInfo = info
		self.restArgumentInfo = restArgument
	}

	public func contains(_ argument: ArgumentKey<T>) -> Bool {
		argumentInfo.keys.contains(argument)
	}

	public func contains(_ argument: ArgumentListKey<T>) -> Bool {
		restArgumentInfo.keys.contains(argument)
	}
}

/*
	Property access:
	- Name
*/
public extension ArgumentDetail {
	func name(of argument: ArgumentKey<T>) -> String? { argumentInfo[argument]?.name }
	func name(of argument: ArgumentListKey<T>) -> ((Array.Index) -> String)? { restArgumentInfo[argument]?.nameGenerator }
}

