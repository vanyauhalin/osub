import Darwin

public protocol WindowProtocol {
  var columns: Int { get }
}

public final class Window: WindowProtocol {
  public static let shared: WindowProtocol = Window()

  public let columns: Int

  public init(columns: Int) {
    self.columns = columns
  }

  public init() {
    var size = winsize()
    guard ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == .zero else {
      self.columns = .zero
      return
    }
    self.columns = Int(size.ws_col)
  }
}
