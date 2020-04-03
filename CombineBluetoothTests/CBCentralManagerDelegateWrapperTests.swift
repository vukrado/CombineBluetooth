//
//  CBCentralManagerDelegateWrapperTests.swift
//  CombineBluetoothTests
//
//  Created by Vuk Radosavljevic on 4/3/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import XCTest
import CoreBluetooth

final class CBCentralManagerDelegateWrapperTests: XCTestCase {

    var sut: CBCentralManagerDelegateWrapper!

    override func setUp() {
        sut = CBCentralManagerDelegateWrapper()
    }

    override func tearDown() {
        sut = nil
    }

    func testCentralManagerDidUpdateStateForwardsCallToCentralManagerDelegate() {
        let centralManager = CBCentralManager()
        let cancellable = sut.didUpdateState.sink(receiveValue: {
            XCTAssertEqual($0, .unknown)
        })
        sut.centralManagerDidUpdateState(centralManager)
        XCTAssertNotNil(cancellable)
    }

    func testCentralManagerDidDiscoverPeripheralEmitsPeripheral() {
        let centralManager = CBCentralManager()
        let mockPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral,
                                   forKeyPath: "delegate",
                                   options: .new,
                                   context: nil)

        let cancellable = sut.didDiscoverPeripheral.sink(receiveValue: { peripheral in
            XCTAssertEqual(peripheral, mockPeripheral)
        })

        sut.centralManager(centralManager,
                           didDiscover: mockPeripheral,
                           advertisementData: ["": ""],
                           rssi: 1)

        XCTAssertNotNil(cancellable)
    }

    func testCentralManagerDidConnectToPeripheralEmitsPeripheral() {
        let centralManager = CBCentralManager()
        let mockPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral,
                                   forKeyPath: "delegate",
                                   options: .new,
                                   context: nil)

        let cancellable = sut.didConnectToPeripheral.sink(receiveValue: { peripheral in
            XCTAssertEqual(peripheral, mockPeripheral)
        })

        sut.centralManager(centralManager,
                           didConnect: mockPeripheral)

        XCTAssertNotNil(cancellable)
    }

    func testCentralManagerDidFailToConnectEmitsPeripheral() {
        let centralManager = CBCentralManager()
        let mockPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral,
                                   forKeyPath: "delegate",
                                   options: .new,
                                   context: nil)

        let cancellable = sut.didFailToConnectToPeripheral.sink(receiveValue: { (peripheral, _) in
            XCTAssertEqual(peripheral, mockPeripheral)
        })

        sut.centralManager(centralManager,
                           didFailToConnect: mockPeripheral,
                           error: nil)

        XCTAssertNotNil(cancellable)
    }

    func testDidDisconnectPeripheralEmitsPeripheral() {
        let centralManager = CBCentralManager()
        let mockPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral,
                                   forKeyPath: "delegate",
                                   options: .new,
                                   context: nil)

        let cancellable = sut.didDisconnectPeripheral.sink(receiveValue: { (peripheral, _) in
            XCTAssertEqual(peripheral, mockPeripheral)
        })

        sut.centralManager(centralManager,
                           didDisconnectPeripheral: mockPeripheral,
                           error: nil)

        XCTAssertNotNil(cancellable)
    }
}
