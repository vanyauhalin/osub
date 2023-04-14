import Command

public final class MockedTextOutputStream: StandardTextOutputStream {
  public var string = ""

  override public func write(_ string: String) {
    self.string += string
  }
}
