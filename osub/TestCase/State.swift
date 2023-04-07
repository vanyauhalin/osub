import State

public final class MockedStateManager: StateManagerProtocol {
  public let mockedLoad: (() throws -> State)?

  public init(load: (() -> State)? = nil) {
    self.mockedLoad = load
  }

  public func load() throws -> State {
    guard let mockedLoad else {
      fatalError("The \(#function) is not implemented.")
    }
    return try mockedLoad()
  }

  public func write(state: State) throws {}

  public func merge(current: State, with new: State) -> State {
    StateManager.shared.merge(current: current, with: new)
  }
}
