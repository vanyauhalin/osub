import Darwin

public protocol WindowProtocol {
  var columns: Int { get }
}

public final class Window: WindowProtocol {
  public static let shared: WindowProtocol = Window()

  public let columns: Int

  public init() {
    var size = winsize()
    guard ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == 0 else {
      self.columns = 0
      return
    }
    self.columns = Int(size.ws_col)
  }
}
