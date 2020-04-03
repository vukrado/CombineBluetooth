//
//  ServiceTests.swift
//  CombineBluetoothTests
//
//  Created by Vuk Radosavljevic on 4/3/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import XCTest
import CoreBluetooth

class ServiceTests: XCTestCase {

    var sut: Service!

    func testUUID() {
        let mockPeripheral = MockCBPeripheral()
        let mockService = CBMutableService(type: CBUUID(), primary: false)
        sut = Service(service: mockService, peripheral: Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager()))
        XCTAssertEqual(sut.uuid, mockService.uuid)
    }

    func testCharacteristicsNil() {
        let mockPeripheral = MockCBPeripheral()
        let mockService = CBMutableService(type: CBUUID(), primary: false)
        sut = Service(service: mockService, peripheral: Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager()))
        XCTAssertNil(sut.characteristics)
    }

    func testCharacteristicsReturnsCharacteristicsWhenNotNil() {
        let mockPeripheral = MockCBPeripheral()
        let mockService = CBMutableService(type: CBUUID(), primary: false)
        let mockCharacteristic = CBMutableCharacteristic(type: CBUUID(),
                                                         properties: .read,
                                                         value: nil,
                                                         permissions: .readable)
        mockService.characteristics = [mockCharacteristic]
        sut = Service(service: mockService, peripheral: Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager()))
        XCTAssertNotNil(sut.characteristics)
        XCTAssertEqual(sut.characteristics?.count, 1)
    }

    func testDiscoverChracteristicsEmitsCharacteristics() {
        let mockBluetoothPeripheral = MockBluetoothPeripheral()
        let mockService = CBMutableService(type: CBUUID(), primary: false)
        let mockCharacteristic = CBMutableCharacteristic(type: CBUUID(),
                                                         properties: .read,
                                                         value: nil,
                                                         permissions: .readable)
        mockService.characteristics = [mockCharacteristic]
        mockBluetoothPeripheral.services = [mockService]
        let mockCentralManager = MockCentralManager()
        let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
        let peripheral = Peripheral(peripheral: mockBluetoothPeripheral, bluetoothManager: bluetoothManager)
        sut = Service(service: mockService, peripheral: peripheral)
        let cancellable = sut
            .discoverCharacteristics(nil)
        .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .finished)
            },
              receiveValue: { characteristics in
                XCTAssertEqual(characteristics.first?.uuid, mockCharacteristic.uuid)
            })
        mockBluetoothPeripheral
            .peripheralDelegate?.peripheral(peripheral: mockBluetoothPeripheral, didDiscoverCharacteristicsFor: mockService, error: nil)

        XCTAssertNotNil(cancellable)
    }

}
