//
//  MockCharacteristic.swift
//
//
//  Created by Vuk Radosavljevic on 4/1/20.
//

import CoreBluetooth

final class MockCharacteristic: BluetoothCharacteristic {

    private(set) var uuid: CBUUID

    private(set) var isNotifying: Bool

    private(set) var value: Data?

    private(set) var properties: CBCharacteristicProperties

    init(type uuid: CBUUID,
         properties: CBCharacteristicProperties,
         value: Data?,
         isNotifying: Bool) {
        self.uuid = uuid
        self.isNotifying = isNotifying
        self.value = value
        self.properties = properties
    }
}
