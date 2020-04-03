//
//  BluetoothManagerTests.swift
//  CombineBluetoothTests
//
//  Created by Vuk Radosavljevic on 4/2/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import XCTest
import CoreBluetooth
import Combine

final class BluetoothManagerTests: XCTestCase {

    var sut: BluetoothManager!
    var mockCentralManager: MockCentralManager!

    override func setUp() {
        mockCentralManager = MockCentralManager()
        sut = BluetoothManager(centralManager: mockCentralManager)
    }

    override func tearDown() {
        mockCentralManager = nil
        sut = nil
    }

    func testObserveState() {
        let cancelable = sut.observeState().sink(receiveValue: { state in
            XCTAssertEqual(state, .poweredOff)
        })
        mockCentralManager.state = .poweredOff
        mockCentralManager.centralManagerDelegate?.centralManagerDidUpdateState(central: mockCentralManager)
        XCTAssertNotNil(cancelable)
    }

    func testObserveConnect() {
        let mockPeripheral: MockCBPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        let cancellable = sut.observeConnect().sink(receiveValue: { peripheral in
            // swiftlint:disable force_cast
            XCTAssertEqual(peripheral.peripheral as! MockCBPeripheral, mockPeripheral)
        })

        mockCentralManager.centralManagerDelegate?.centralManager(central: mockCentralManager, didConnect: mockPeripheral)
        XCTAssertNotNil(cancellable)
    }

    func testObserveDisconnectEmitsPeripheralOnDidDisconnect() {
        let mockPeripheral: MockCBPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        let cancellable = sut
            .observeDisconnect()
            .sink(receiveCompletion: { XCTFail("Received \($0) when we shouldn't have")},
                  receiveValue: { peripheral in
                    // swiftlint:disable force_cast
                    XCTAssertEqual(peripheral.peripheral as! MockCBPeripheral, mockPeripheral)
            })
        mockCentralManager.centralManagerDelegate?.centralManager(central: mockCentralManager,
                                                                  didDisconnectPeripheral: mockPeripheral,
                                                                  error: nil)
        XCTAssertNotNil(cancellable)
    }

    func testStateReturnsCorrectCentralManagerState() {
        mockCentralManager.state = .poweredOn
        XCTAssertEqual(sut.state, .poweredOn)
    }

    func testScanForPeripheralsEmitsPeripheralThenFinishedEvent() {
        mockCentralManager.state = .poweredOn
        let mockPeripheral: MockCBPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        let cancellable = sut
            .scanForPeripheral(withServices: nil)
            .sink(receiveCompletion: { completion in
                    XCTAssertEqual(completion, .finished)
                },
                  receiveValue: { peripheral in
                    // swiftlint:disable force_cast
                    XCTAssertEqual(peripheral.peripheral as! MockCBPeripheral, mockPeripheral)
                })
        mockCentralManager.centralManagerDelegate?.centralManager(central: mockCentralManager,
                                                                  didDiscover: mockPeripheral,
                                                                  advertisementData: ["": ""],
                                                                  rssi: 1)
        XCTAssertNotNil(cancellable)
    }

    func testScanForPeripheralEmitsFailureWhenBluetoothIsNotPoweredOn() {
        let cancellable = sut
            .scanForPeripheral(withServices: nil)
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .failure(.bluetoothNotOn))
            }, receiveValue: { peripheral in
                XCTFail("Should not receive peripheral, received \(peripheral)")
            })

        XCTAssertNotNil(cancellable)
    }

    func testScanForPeripheralEmitsFailureWhenScanIsInProgress() {
        mockCentralManager.state = .poweredOn
        mockCentralManager.isScanning = true

        let cancellable = sut
            .scanForPeripheral(withServices: nil)
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .failure(.scanInProgress))
            }, receiveValue: { peripheral in
                XCTFail("Should not receive peripheral, received \(peripheral)")
            })

        XCTAssertNotNil(cancellable)
    }

    func testConnectToPeripheralEmitsPeripheral() {
        mockCentralManager.state = .poweredOn
        let mockPeripheral: MockCBPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        let peripheral = Peripheral(peripheral: mockPeripheral, bluetoothManager: sut)
        let cancellable = sut
            .connectToPeripheral(peripheral)
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .finished)
            }, receiveValue: { connectedPeripheral in
                XCTAssertEqual(connectedPeripheral, peripheral)
            })

        mockCentralManager.centralManagerDelegate?.centralManager(central: mockCentralManager, didConnect: mockPeripheral)
        XCTAssertNotNil(cancellable)
    }

    func testConnectToPeripheralEmitsFailure() {
        mockCentralManager.state = .poweredOn
        let mockPeripheral: MockCBPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        let peripheral = Peripheral(peripheral: mockPeripheral, bluetoothManager: sut)
        let cancellable = sut
            .connectToPeripheral(peripheral)
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .failure(.failedToConnect))
            }, receiveValue: { connectedPeripheral in
                XCTFail("Should not receive a peripheral but received \(connectedPeripheral)")
            })

        mockCentralManager.centralManagerDelegate?.centralManager(central: mockCentralManager, didFailToConnect: mockPeripheral, error: nil)
        XCTAssertNotNil(cancellable)
    }

    func testStateDebugDescriptions() {
        var state = CBManagerState.poweredOff
        XCTAssertEqual(state.debugDescription, "Powered Off")
        state = .poweredOn
        XCTAssertEqual(state.debugDescription, "Powered On")
        state = .unknown
        XCTAssertEqual(state.debugDescription, "Unknown")
        state = .unsupported
        XCTAssertEqual(state.debugDescription, "Unsupported")
        state = .unauthorized
        XCTAssertEqual(state.debugDescription, "Unauthorized")
        state = .resetting
        XCTAssertEqual(state.debugDescription, "Resetting")
    }
}
