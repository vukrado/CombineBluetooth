//
//  CBCentralDelegateWrapper.swift
//
//
//  Created by Vuk Radosavljevic on 3/23/20.
//

import CoreBluetooth
import Combine
import os.log

final class CBCentralManagerDelegateWrapper: NSObject, CentralManagerDelegate {

    let didUpdateState = PassthroughSubject<CBManagerState, Never>()
    let didDiscoverPeripheral = PassthroughSubject<CBPeripheral, Never>()
    let didConnectToPeripheral = PassthroughSubject<CBPeripheral, Never>()
    let didFailToConnectToPeripheral = PassthroughSubject<(CBPeripheral, Error?), Never>()
    let didDisconnectPeripheral = PassthroughSubject<(CBPeripheral, Error?), Never>()

    func centralManagerDidUpdateState(central: CentralManager) {
        os_log("centralManagerDidUpdateState(_) new state = %s", central.state.debugDescription)
        didUpdateState.send(central.state)
    }

    func centralManager(central: CentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        os_log("centralManager(didDiscover:) peripheral %s,", peripheral.name ?? "N/A")
        didDiscoverPeripheral.send(peripheral)
    }
    func centralManager(central: CentralManager, didConnect peripheral: CBPeripheral) {
        os_log("centralManager(_: didConnect:) to peripheral %s", peripheral.name ?? "N/A")
        didConnectToPeripheral.send(peripheral)
    }

    func centralManager(central: CentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        os_log("centralManager(_: didFailToConnect) to peripheral %s", peripheral.name ?? "N/A")
        didFailToConnectToPeripheral.send((peripheral, error))
    }

    func centralManager(central: CentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("centralManager(_: didDisconnectPeripheral) %s", peripheral.name ?? "N/A")
        didDisconnectPeripheral.send((peripheral, error))
    }
}

// MARK: - CBCentralManagerDelegate
extension CBCentralManagerDelegateWrapper: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.centralManagerDidUpdateState(central: central)
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        self.centralManager(central: central, didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager(central: central, didConnect: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.centralManager(central: central, didFailToConnect: peripheral, error: error)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        centralManager(central: central, didDisconnectPeripheral: peripheral, error: error)
    }

}

extension CBManagerState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .resetting:
            return "Resetting"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "Powered Off"
        case .poweredOn:
            return "Powered On"
        @unknown default:
            fatalError()
        }
    }
}
