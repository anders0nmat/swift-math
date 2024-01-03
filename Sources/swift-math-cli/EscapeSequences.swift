
typealias TerminalString = String

private let ESC = "\u{1b}"
private let CSI = ESC + "["

extension TerminalString {
	enum Cursor {
		static func up(cells: Int = 1) -> TerminalString { "\(CSI)\(cells)A" }
		static func down(cells: Int = 1) -> TerminalString { "\(CSI)\(cells)B" }
		static func forward(cells: Int = 1) -> TerminalString { "\(CSI)\(cells)C" }
		static func back(cells: Int = 1) -> TerminalString { "\(CSI)\(cells)D" }
		
		static func move(x: Int = 1, y: Int = 1) -> TerminalString { "\(CSI)\(y);\(x)H" }
		static let clearScreen: TerminalString = "\(CSI)2J"
		static let clearLine: TerminalString = "\(CSI)2K"
	}

	enum Style {
		static let reset: TerminalString = "\(CSI)0m"
		enum FontStyle: UInt {
			case bold = 1, faint
			case italic
			case underline
			case slowBlink, fastBlink

			case noBold = 22
			case noBlink = 25
			case noItalic = 23
			case noUnderline = 24

			var normal: FontStyle {
				return switch self {
					case .bold, .faint, .noBold: .noBold
					case .italic, .noItalic: .noItalic
					case .underline, .noUnderline: .noUnderline
					case .slowBlink, .fastBlink, .noBlink: .noBlink
				}
			}
		}

		static func style(_ style: [FontStyle]) -> TerminalString {
			style.isEmpty ? "" : "\(CSI)\(style.map({ String($0.rawValue) }).joined(separator: ";"))m"
		}
		
		enum Color: UInt {
			case black
			case red
			case green
			case yellow
			case blue
			case magenta
			case cyan
			case white

			case `default` = 9
		}

		static func color(_ foreground: Color) -> TerminalString { "\(CSI)\(foreground.rawValue + 30)m" }
		static func color(_ foreground: Color, background: Color) -> TerminalString { "\(CSI)\(foreground.rawValue + 30);\(background.rawValue + 40)m" }
		static func color(background: Color) -> TerminalString { "\(CSI)\(background.rawValue + 40)m" }

		static let resetColor: TerminalString = "\(CSI)39;49m"
	}

	func colored(_ foreground: Style.Color) -> TerminalString {
		Style.color(foreground) + self + Style.color(.default)
	}

	func colored(_ foreground: Style.Color, background: Style.Color) -> TerminalString {
		Style.color(foreground, background: background) + self + Style.resetColor
	}

	func colored(background: Style.Color) -> TerminalString {
		Style.color(background: background) + self + Style.color(background: .default)
	}

	func styled(_ style: [Style.FontStyle]) -> TerminalString {
		Style.style(style) + self + Style.style(style.map(\.normal))
	}
}
