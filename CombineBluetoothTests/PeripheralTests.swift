//
//  PeripheralTests.swift
//  CombineBluetoothTests
//
//  Created by Vuk Radosavljevic on 4/2/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import XCTest

final class PeripheralTests: XCTestCase {

    var sut: Peripheral!

    override func setUp() {
        sut = Peripheral(peripheral: MockPeripheral(), bluetoothManager: BluetoothManager())
    }

    override func tearDown() {

    }

    func testNameReturnsNA() {
        XCTAssertEqual(sut.name, "N/A")
    }

    func testIsConnected() {
        XCTAssertEqual(sut.isConnected, false)
    }

    func testServicesReturnsNil() {
        XCTAssertNil(sut.services)
    }

    func testStateIsDisconnected() {
        XCTAssertEqual(sut.state, .disconnected)
    }

}
