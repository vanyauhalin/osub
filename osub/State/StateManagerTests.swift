import Configuration
@testable
import State
import TestCase
import XCTest

final class StateManagerStateFileTests: XCTestCase {
  func testSets() {
    let manager = StateManager()
    XCTAssertEqual(manager.stateFile.lastPathComponent, "state.json")
  }
}

final class StateManagerLoadTests: XCTestCase {
  func testLoadsAnEmptyStateIfItDoesNotExist() throws {
    let directory = try FileManager.default.temporaryDirectory()
    let manager = StateManager(
      configManager: MockedConfigurationManager(
        stateDirectory: directory
      )
    )
    let state = try manager.load()
    XCTAssertNil(state.baseURL)
    XCTAssertNil(state.token)
  }

  func testLoadsAValidState() throws {
    let directory = try FileManager.default.temporaryDirectory()
    let file = directory.appending2(path: "state.json")
    let content = """
      {
        "base_url": "http://localhost/",
        "token": "www"
      }
      """
    try content.write(to: file, atomically: true, encoding: .utf8)
    let manager = StateManager(
      configManager: MockedConfigurationManager(
        stateDirectory: directory
      )
    )
    let state = try manager.load()
    XCTAssertEqual(state.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(state.token, "www")
  }

  func testThrowsAnErrorWhenLoadingAnInvalidState() throws {
    let directory = try FileManager.default.temporaryDirectory()
    let file = directory.appending2(path: "state.json")
    let content = """
      invalid
      """
    try content.write(to: file, atomically: true, encoding: .utf8)
    let manager = StateManager(
      configManager: MockedConfigurationManager(
        stateDirectory: directory
      )
    )
    XCTAssertThrowsError(try manager.load())
  }
}

final class StateManagerWriteTests: XCTestCase {
  func testWritesTheState() throws {
    let directory = (try FileManager.default.temporaryDirectory())
      .appending2(path: "non-existing-directory", isDirectory: true)
    let manager = StateManager(
      configManager: MockedConfigurationManager(
        stateDirectory: directory
      )
    )
    try manager.write(
      state: State(
        baseURL: URL(string: "http://localhost/"),
        token: "www"
      )
    )
    let state = try manager.load()
    XCTAssertEqual(state.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(state.token, "www")
  }
}

final class StateManagerMergeTests: XCTestCase {
  func testMergesTheState() {
    let manager = StateManager()
    let merged = manager.merge(
      current: State(
        baseURL: URL(string: "http://localhost/"),
        token: "www"
      ),
      with: State()
    )
    XCTAssertEqual(merged.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(merged.token, "www")
  }
}
