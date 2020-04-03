//
//  MockCentralManager.swift
//  CombineBluetoothTests
//
//  Created by Vuk Radosavljevic on 4/2/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import CoreBluetooth

final class MockCentralManager: CentralManager {
    weak var centralManagerDelegate: CentralManagerDelegate?

    var isScanning: Bool = false

    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?) { }

    func stopScan() {
        isScanning = false
    }

    func connect(_ peripheral: CBPeripheral, options: [String: Any]?) { }

    var state: CBManagerState = .poweredOff

}
