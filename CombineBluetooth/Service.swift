//
//  Service.swift
//
//
//  Created by Vuk Radosavljevic on 3/25/20.
//

import Combine
import CoreBluetooth

/// Combine wrapper for CoreBluetooth's [CBService](https://developer.apple.com/documentation/corebluetooth/cbservice)
public final class Service {

    // MARK: Properties
    public let service: CBService

    public let peripheral: Peripheral

    /// 128-bit UUID of the attribute.
    public var uuid: CBUUID { service.uuid }

    /// A list of `Characteristic`s discovered in this service.
    public var characteristics: [Characteristic]? {
        service.characteristics?.map({ Characteristic(characteristic: $0) })
    }

    // MARK: - Initialization
    init(service: CBService, peripheral: Peripheral) {
        self.service = service
        self.peripheral = peripheral
    }

    // MARK: - Methods
    /// Discovers the specified characteristics of a service.
    public func discoverCharacteristics(_ characteristicUUID: [CBUUID]?) -> AnyPublisher<[Characteristic], BluetoothError> {
        return peripheral.discoverCharacteristics(characteristicUUID, for: self)
    }
}
