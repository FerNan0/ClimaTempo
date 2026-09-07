//
//  ClimaAgoraTests.swift
//  ClimaAgoraTests
//
//  Created by Fernando on 17/03/26.
//

import Testing
@testable import ClimaAgora

struct ClimaAgoraTests {

    @Test func weatherPreviewHasValidCity() async throws {
        #expect(!Weather.preview.city.isEmpty)
    }

}
