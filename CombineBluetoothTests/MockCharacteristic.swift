//
//  MockCharacteristic.swift
//
//
//  Created by Vuk Radosavljevic on 4/1/20.
//

import CoreBluetooth

final class MockCharacteristic: CBCharacteristic {

    private let cbuuid: CBUUID
    private let notifying: Bool
    private let data: Data?
    private let characteristicProperties: CBCharacteristicProperties

    override var uuid: CBUUID { return cbuuid }

    override var isNotifying: Bool { return notifying }

    override var value: Data? { return data }

    override var properties: CBCharacteristicProperties { return characteristicProperties }

    init(uuid: CBUUID,
         notifying: Bool,
         data: Data?,
         properties: CBCharacteristicProperties) {
        self.cbuuid = uuid
        self.notifying = notifying
        self.data = data
        self.characteristicProperties = properties
    }
}
