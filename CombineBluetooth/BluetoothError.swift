//
//  BluetoothError.swift
//
//
//  Created by Vuk Radosavljevic on 3/27/20.
//

/// An error that can occur while scanning for peripherals.
public enum BluetoothError: Error {
    case bluetoothNotOn
    case failedToConnect
    case failedToDiscoverCharacteristics
    case failedToDiscoverServices
    case noCharacteristicsForService
    case noServicesForPeripheral
    case objectDestroyed
    case scanInProgress
    case scanTimedOut
}
