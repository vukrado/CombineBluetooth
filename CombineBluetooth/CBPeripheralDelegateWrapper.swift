//
//  CBPeripheralDelegateWrapper.swift
//
//
//  Created by Vuk Radosavljevic on 3/31/20.
//

import Combine
import CoreBluetooth
import os.log

final class CBPeripheralDelegateWrapper: NSObject, PeripheralDelegate {

    let didDiscoverServices = PassthroughSubject<(BluetoothPeripheral, Error?), Never>()
    let didDiscoverCharacteristicsForServices = PassthroughSubject<(BluetoothPeripheral, CBService, Error?), Never>()
    let didUpdateValueForCharacteristic = PassthroughSubject<(BluetoothPeripheral, CBCharacteristic, Error?), Never>()
    // swiftlint:disable identifier_name
    let didUpdateNotificationStateForCharacteristic = PassthroughSubject<(BluetoothPeripheral, CBCharacteristic), Never>()
    let didModifyServices = PassthroughSubject<(BluetoothPeripheral, [CBService]), Never>()

    func peripheral(peripheral: BluetoothPeripheral, didDiscoverServices error: Error?) {
        os_log("peripheral(_: didDiscoverServices:) %s", peripheral.services.debugDescription)
        didDiscoverServices.send((peripheral, error))
    }

    func peripheral(peripheral: BluetoothPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        os_log("peripheral(_: didDiscoverCharacteristicsFor: error:) %s", service.characteristics.debugDescription)
        didDiscoverCharacteristicsForServices.send((peripheral, service, error))
    }

    func peripheral(peripheral: BluetoothPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        os_log("peripheral(_: didUpdateNotificationStateFor: characteristic: error:) %s", characteristic.debugDescription)
        didUpdateNotificationStateForCharacteristic.send((peripheral, characteristic))
    }

    func peripheral(peripheral: BluetoothPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        os_log("peripheral(_: didUpdateValueFor: characteristic: error:) %s", characteristic.debugDescription)
        didUpdateValueForCharacteristic.send((peripheral, characteristic, error))
    }

    func peripheral(peripheral: BluetoothPeripheral, didModifyServices invalidatedServices: [CBService]) {
        os_log("peripheral(_: didModifyServices:) %s", invalidatedServices.debugDescription)
        didModifyServices.send((peripheral, invalidatedServices))
    }
}

// MARK: CBPeripheralDelegate
extension CBPeripheralDelegateWrapper: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.peripheral(peripheral: peripheral, didDiscoverServices: error)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        self.peripheral(peripheral: peripheral, didDiscoverCharacteristicsFor: service, error: error)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        self.peripheral(peripheral: peripheral, didUpdateNotificationStateFor: characteristic, error: error)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.peripheral(peripheral: peripheral, didUpdateValueFor: characteristic, error: error)
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        self.peripheral(peripheral: peripheral, didModifyServices: invalidatedServices)
    }
}
