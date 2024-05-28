
public enum NodeEvent {
	case children
	case body
	case context
}

public typealias NodeEventCallback = (any NodeProtocol, NodeEvent) -> Void

extension NodeProtocol {
	internal func fire(event: NodeEvent) {
		self.observers.forEach {
			$0(self, event)
		}
	}
}
