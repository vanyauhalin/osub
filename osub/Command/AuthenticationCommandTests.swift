// swiftlint:disable trailing_closure
import Client
@testable
import Command
import Configuration
import State
import TestCase
import XCTest

final class AuthenticationLoginCommandTests: XCTestCase {
  func testLogins() async throws {
    var command = try AuthenticationLoginCommand.parse(["lynsey", "lawrence"])
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
      auth: MockedAuthenticationService(
        login: {
          Login(
            baseURL: URL(string: "http://localhost/"),
            token: "www"
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(command.config?.username, "lynsey")
    XCTAssertEqual(command.config?.password, "lawrence")
    XCTAssertEqual(command.state?.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(command.state?.token, "www")
  }
}

final class AuthenticationCommandLogoutTests: XCTestCase {
  func testLogouts() async throws {
    var command = try AuthenticationLogoutCommand.parse([])
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
      }
    )
    command.client = MockedClient(
      auth: MockedAuthenticationService(
        logout: {
          Information(
            message: "jackpot"
          )
        }
      )
    )
    try await command.run()
    XCTAssertNotNil(command.state)
    XCTAssertNil(command.state?.baseURL)
    XCTAssertNil(command.state?.token)
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
    var command = try AuthenticationRefreshCommand.parse([])
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
      }
    )
    command.client = MockedClient(
      auth: MockedAuthenticationService(
        login: {
          Login(
            baseURL: URL(string: "http://localhost/"),
            token: "www"
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(command.state?.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(command.state?.token, "www")
  }
}

final class AuthenticationCommandStatusTests: XCTestCase {
  func testStatus() async throws {
    var command = try AuthenticationStatusCommand.parse([])
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
            data: User(
              userID: 9000,
              remainingDownloads: 20
            )
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(command.user?.data.userID, 9000)
    XCTAssertEqual(command.user?.data.remainingDownloads, 20)
  }
}
