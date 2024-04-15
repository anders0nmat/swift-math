
public enum NodeEvent {
	case children
	case body
	case context
}

public typealias NodeEventCallback = (AnyNode, NodeEvent) -> Void

extension _Node {
	internal func fire(event: NodeEvent) {
		self.observers.forEach {
			$0(self, event)
		}
	}
}
