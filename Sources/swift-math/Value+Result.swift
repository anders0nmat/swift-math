
public typealias MathFloat = Double
public typealias MathList = [MathFloat]

public enum MathValue: Equatable {
	case number(MathFloat)
	case list(MathList)
}

public typealias MathResult = Result<MathValue, MathError>
