import State

public final class MockedStateManager: StateManagerProtocol {
  public let mockedLoad: (() -> State)?
  public let mockedWrite: ((State) -> Void)?

  public init(
    load: (() -> State)? = nil,
    write: ((State) -> Void)? = nil
  ) {
    self.mockedLoad = load
    self.mockedWrite = write
  }

  public func load() throws -> State {
    guard let mockedLoad else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedLoad()
  }

  public func write(state: State) throws {
    guard let mockedWrite else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedWrite(state)
  }

  public func merge(current: State, with new: State) -> State {
    StateManager.shared.merge(current: current, with: new)
  }
}
