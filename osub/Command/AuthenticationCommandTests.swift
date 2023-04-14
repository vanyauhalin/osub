// swiftlint:disable trailing_closure
import Client
@testable
import Command
import Configuration
import State
import TestCase
import XCTest

final class AuthenticationListCommandTests: XCTestCase {
  func testRuns() throws {
    let output = MockedTextOutputStream()
    var command = try AuthenticationListCommand.parse([])
    command.output = output
    command.stateManager = MockedStateManager(
      load: {
        State(
          baseURL: URL(string: "http://localhost/"),
          token: "www"
        )
      }
    )
    try command.run()
    XCTAssertEqual(
      output.string,
      """
      base_url=http://localhost/
      token=www\n
      """
    )
  }
}

final class AuthenticationLoginCommandTests: XCTestCase {
  func testRuns() async throws {
    let output = MockedTextOutputStream()
    var config: Configuration?
    var state: State?
    var command = try AuthenticationLoginCommand.parse(["lynsey", "lawrence"])
    command.output = output
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration()
      },
      write: { writing in
        config = writing
      }
    )
    command.stateManager = MockedStateManager(
      load: {
        State()
      },
      write: { writing in
        state = writing
      }
    )
    command.client = MockedClient(
      auth: MockedAuthenticationService(
        login: {
          LoginEntity(
            baseURL: URL(string: "http://localhost/"),
            token: "www"
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(config?.username, "lynsey")
    XCTAssertEqual(config?.password, "lawrence")
    XCTAssertEqual(state?.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(state?.token, "www")
    XCTAssertEqual(
      output.string,
      """
      The authentication token has been successfully generated.\n
      """
    )
  }
}

final class AuthenticationCommandLogoutTests: XCTestCase {
  func testRuns() async throws {
    let output = MockedTextOutputStream()
    var state: State?
    var command = try AuthenticationLogoutCommand.parse([])
    command.output = output
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration()
      }
    )
    command.stateManager = MockedStateManager(
      load: {
        State(
          baseURL: URL(string: "http://localhost/"),
          token: "www"
        )
      },
      write: { writing in
        state = writing
      }
    )
    command.client = MockedClient(
      auth: MockedAuthenticationService(
        logout: {
          InformationEntity(
            message: "jackpot"
          )
        }
      )
    )
    try await command.run()
    XCTAssertNotNil(state)
    XCTAssertNil(state?.baseURL)
    XCTAssertNil(state?.token)
    XCTAssertEqual(
      output.string,
      """
      The authentication token has been successfully destroyed.
      jackpot\n
      """
    )
  }
}

final class AuthenticationRefreshCommandTests: XCTestCase {
  func testThrowsAnErrorWhenTheConfigurationIsEmpty() async throws {
    var command = try AuthenticationRefreshCommand.parse([])
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration()
      }
    )
    command.stateManager = MockedStateManager(
      load: {
        State()
      }
    )
    command.client = MockedClient()
    do {
      try await command.run()
      XCTFail()
    } catch {}
  }

  func testRefreshesWhenTheConfigurationIsNotEmpty() async throws {
    let output = MockedTextOutputStream()
    var state: State?
    var command = try AuthenticationRefreshCommand.parse([])
    command.output = output
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration(
          username: "lynsey",
          password: "lawrence"
        )
      }
    )
    command.stateManager = MockedStateManager(
      load: {
        State()
      },
      write: { writing in
        state = writing
      }
    )
    command.client = MockedClient(
      auth: MockedAuthenticationService(
        login: {
          LoginEntity(
            baseURL: URL(string: "http://localhost/"),
            token: "www"
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(state?.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(state?.token, "www")
    XCTAssertEqual(
      output.string,
      """
      The authentication token has been successfully refreshed.\n
      """
    )
  }
}

final class AuthenticationCommandStatusTests: XCTestCase {
  func testRuns() async throws {
    let output = MockedTextOutputStream()
    var command = try AuthenticationStatusCommand.parse(["--no-frame"])
    command.output = output
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration()
      }
    )
    command.stateManager = MockedStateManager(
      load: {
        State()
      }
    )
    command.client = MockedClient(
      info: MockedInformationService(
        user: {
          DatumedEntity(
            data: UserEntity(
              userID: 9000,
              remainingDownloads: 20
            )
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(
      output.string,
      """
      USER ID  REMAINING DOWNLOADS
      9000     20                 \n
      """
    )
  }
}
