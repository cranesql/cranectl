//===----------------------------------------------------------------------===//
//
// This source file is part of the Crane open source project
//
// Copyright (c) 2026 the Crane project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

public import ArgumentParser
package import Configuration
import Crane
package import Logging
import SystemPackage

#if PostgresNIO
import CranePostgresNIO
#endif

public struct CraneMigrate: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "migrate",
        abstract: "Apply pending database migrations."
    )

    @Option(
        name: .shortAndLong,
        help: "Path to a Crane configuration file.",
        completion: .file(extensions: ConfigFileExtension.allCases.map(\.rawValue))
    )
    var config: String?

    @OptionGroup var loggingArguments: LoggingArguments

    // All other flags are routed through swift-configuration's `CommandLineArgumentsProvider` so that
    // the libraries' config tree is the single source of truth. `.allUnrecognized` suppresses the
    // "unexpected argument" errors ArgumentParser would otherwise raise on `--paths`,
    // `--postgres-host`, etc.
    @Argument(
        parsing: .allUnrecognized,
        help: .init(
            "Arguments passed through to Crane and its migration targets.",
            discussion: "See https://github.com/cranesql/crane and migration target repositories for available flags.",
            valueName: "arg",
            visibility: .default
        )
    ) var passthrough: [String] = []

    public init() {}

    public func run() async throws {
        loggingArguments.bootstrapLoggingSystem()
        let logger = Logger(label: "cranectl")

        #if PostgresNIO
        // Wrap the migration pipeline so the eventual exit is just a non-zero code. The library
        // (crane and crane-postgres-nio) emits structured error logs before throwing, so we don't
        // need ArgumentParser to also auto-print the raw error description.
        do {
            let reader = try await makeConfigReader(logger: logger)
            let target = try PostgresMigrationTarget(reader: reader.scoped(to: "postgres"))
            let migrator = try Migrator(reader: reader, target: target)

            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { await target.run() }
                do {
                    try await migrator.apply()
                } catch {
                    group.cancelAll()
                    throw error
                }
                group.cancelAll()
            }
        } catch {
            throw ExitCode.failure
        }
        #else
        logger.critical("cranectl was built without any migration target. Enable at least one of the traits.")
        throw ExitCode.failure
        #endif
    }

    package func makeConfigReader(logger: Logger) async throws -> ConfigReader {
        var providers: [any ConfigProvider] = []

        // CLI flags map directly to config keys: `paths` → `--paths`, `postgres.host` → `--postgres-host`.
        // The provider sees the args ArgumentParser captured into `passthrough`,
        // prefixed with a placeholder program name so the provider's parser can do its own
        // argv[0]-skipping.
        let cliArguments = ["cranectl"] + passthrough
        providers.append(CommandLineArgumentsProvider(arguments: cliArguments))

        // Env vars retain the `CRANE_*` prefix (global namespace hygiene), so a reader query for
        // `paths` is rewritten to `crane.paths` before encoding to `CRANE_PATHS`.
        providers.append(EnvironmentVariablesProvider().prefixKeys(with: ["crane"]))

        if let config {
            providers.append(try await loadConfigFileProvider(at: config, logger: logger))
        }

        return ConfigReader(providers: providers)
    }

    private func loadConfigFileProvider(at config: String, logger: Logger) async throws -> any ConfigProvider {
        let filePath = FilePath(config)
        let provider: any ConfigProvider
        guard let fileExtension = filePath.extension.flatMap({ ConfigFileExtension(rawValue: $0.lowercased()) }) else {
            throw ValidationError(
                """
                Unsupported configuration file '\(config)'. \
                Supported extensions: \(ConfigFileExtension.allCases.map(\.rawValue).joined(separator: ", "))
                """
            )
        }

        switch fileExtension {
        case .json:
            provider = try await fileProvider(at: filePath, logger: logger) as FileProvider<JSONSnapshot>
        case .yml, .yaml:
            provider = try await fileProvider(at: filePath, logger: logger) as FileProvider<YAMLSnapshot>
        }

        logger.info("Loaded configuration file.", metadata: ["path": "\(config)"])
        return provider
    }

    private func fileProvider<Snapshot: FileConfigSnapshot>(
        at filePath: FilePath,
        logger: Logger
    ) async throws -> FileProvider<Snapshot> {
        do {
            return try await FileProvider<Snapshot>(filePath: filePath)
        } catch {
            logger.error("Failed to load configuration file.", error: error, metadata: ["path": "\(filePath)"])
            throw error
        }
    }

    private enum ConfigFileExtension: String, CaseIterable {
        case json
        case yaml
        case yml
    }
}
