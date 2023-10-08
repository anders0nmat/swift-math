

public struct Nothing: Equatable {}

extension Result where Success == Nothing {
    static var success: Self {
        .success(Nothing())
    }
}
