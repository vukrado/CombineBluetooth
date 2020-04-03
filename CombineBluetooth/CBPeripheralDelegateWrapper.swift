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

    func peripheral(peripheral: BluetoothPeripheral, didDiscoverServices error: Error?) {
        os_log("peripheral(_: didDiscoverServices:) %s", peripheral.services.debugDescription)
        didDiscoverServices.send((peripheral, error))
    }

    func peripheral(peripheral: BluetoothPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        os_log("peripheral(_: didDiscoverCharacteristicsFor: error:) %s", service.characteristics.debugDescription)
        didDiscoverCharacteristicsForServices.send((peripheral, service, error))
    }

//    func peripheral(peripheral: BluetoothPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        os_log("peripheral(_: didUpdateValueFor: characteristic: error:) %s", characteristic.debugDescription)
//        didUpdateValueForCharacteristic.send((peripheral, characteristic, error))
//    }
//
//    func peripheral(peripheral: BluetoothPeripheral, didModifyServices invalidatedServices: [CBService]) {
//        os_log("peripheral(_: didModifyServices:) %s", invalidatedServices.debugDescription)
//    }
}

// MARK: CBPeripheralDelegate
extension CBPeripheralDelegateWrapper: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.peripheral(peripheral: peripheral, didDiscoverServices: error)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        self.peripheral(peripheral: peripheral, didDiscoverCharacteristicsFor: service, error: error)
    }

//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        self.peripheral(peripheral: peripheral, didUpdateValueFor: characteristic, error: error)
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
//        self.peripheral(peripheral: peripheral, didModifyServices: invalidatedServices)
//    }
}
