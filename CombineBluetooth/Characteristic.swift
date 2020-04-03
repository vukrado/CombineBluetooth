//
//  Characteristic.swift
//
//
//  Created by Vuk Radosavljevic on 3/31/20.
//

import CoreBluetooth

/// Combine wrapper for CoreBluetooth's [CBCharacteristic](https://developer.apple.com/documentation/corebluetooth/cbcharacteristic)
public final class Characteristic {

    /// A characteristic of a remote   `Peripheral`s `Service`.
    public let characteristic: BluetoothCharacteristic

    /// A 128-bit UUID that identifies this characteristic.
    public var uuid: CBUUID { characteristic.uuid }

    /// A Boolean value that indicates whether the characteristic is currently notifying a subscribed central of its value.
    public var isNotifying: Bool { characteristic.isNotifying }

    /// The value of the characteristic.
    public var value: Data? { characteristic.value }

    /// The properties of the characteristic.
    public var properties: CBCharacteristicProperties { characteristic.properties }

    // MARK: - Initialization
    init(characteristic: BluetoothCharacteristic) {
        self.characteristic = characteristic
    }
}

extension Characteristic: CustomDebugStringConvertible {
    public var debugDescription: String {
        return String(describing: uuid)
    }
}

public protocol BluetoothCharacteristic {
    var uuid: CBUUID { get }
    var isNotifying: Bool { get }
    var value: Data? { get }
    var properties: CBCharacteristicProperties { get }
}

extension CBCharacteristic: BluetoothCharacteristic { }
