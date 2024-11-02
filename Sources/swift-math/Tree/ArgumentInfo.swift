
/**
	Holds additional information about an operator argument

	May be used for UI-related information like display names.
*/
public struct ArgumentData {
	var name: String
}

/**
	Holds information about an operator vararg-argument

	May be used for UI-related information like display names
*/
public struct ArgumentListData {
	var nameGenerator: (Array.Index) -> String
}

/**
	Provides further information linked to arguments of an operator

	Holds further information for arguments of an operation, indexed by their
	KeyPath.
*/
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

	public func data(for argument: ArgumentKey<T>) -> ArgumentData? {
		argumentInfo[argument]
	}

	public func data(for argument: ArgumentListKey<T>) -> ArgumentListData? {
		restArgumentInfo[argument]
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

