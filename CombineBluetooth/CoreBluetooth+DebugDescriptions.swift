//
//  CoreBluetooth+DebugDescriptions.swift
//  CombineBluetooth
//
//  Created by Vuk Radosavljevic on 4/3/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import CoreBluetooth

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
        @unknown default: fatalError()
        }
    }
}
