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

    func testObserveState() {
        let mockCentralManager = MockCentralManager()
        sut = BluetoothManager(centralManager: mockCentralManager)
        let cancelable = sut.observeState().sink(receiveValue: { state in
            XCTAssertEqual(state, .poweredOff,
                           "Expected \(CBManagerState.poweredOff) got \(state)")
        })
        mockCentralManager.state = .poweredOff
        mockCentralManager.centralManagerDelegate?.centralManagerDidUpdateState(central: mockCentralManager)
        XCTAssertNotNil(cancelable)
    }
}

final class MockCentralManager: CentralManager {
    weak var centralManagerDelegate: CentralManagerDelegate?

    var isScanning: Bool = false

    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?) {
        ()
    }

    func stopScan() {
        ()
    }

    func connect(_ peripheral: CBPeripheral, options: [String: Any]?) {
        ()
    }

    var state: CBManagerState = .poweredOff

}
