//
//  CBPeripheralDelegateWrapper.swift
//
//
//  Created by Vuk Radosavljevic on 3/31/20.
//

import Combine
import CoreBluetooth
import os.log

final class CBPeripheralDelegateWrapper: NSObject, CBPeripheralDelegate {

    let didDiscoverServices = PassthroughSubject<(CBPeripheral, Error?), Never>()
    let didDiscoverCharacteristicsForServices = PassthroughSubject<(CBPeripheral, CBService, Error?), Never>()
    let didUpdateValueForCharacteristic = PassthroughSubject<(CBPeripheral, CBCharacteristic, Error?), Never>()

    // MARK: CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        os_log("peripheral(_: didDiscoverServices:) %s", peripheral.services.debugDescription)
        didDiscoverServices.send((peripheral, error))
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        os_log("peripheral(_: didDiscoverCharacteristicsFor: error:) %s", service.characteristics.debugDescription)
        didDiscoverCharacteristicsForServices.send((peripheral, service, error))
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        os_log("peripheral(_: didUpdateValueFor: characteristic: error:) %s", characteristic.debugDescription)
        didUpdateValueForCharacteristic.send((peripheral, characteristic, error))
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        os_log("peripheral(_: didModifyServices:) %s", invalidatedServices.debugDescription)
    }

}
