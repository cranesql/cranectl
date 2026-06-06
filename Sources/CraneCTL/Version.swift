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

// The Dockerfile build rewrites the line below via `sed`, substituting `nil` for the value of
// the `CRANECTL_VERSION` build arg. Local `swift build` invocations leave it nil — `--version`
// is suppressed entirely in that case (ArgumentParser hides the flag when `version: ""`).
let cranectlVersion: String? = nil
