//
//  CharacteristicTests.swift
//  CombineBluetoothTests
//
//  Created by Vuk Radosavljevic on 4/1/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import XCTest
import CoreBluetooth

final class CharacteristicTests: XCTestCase {

    var sut: Characteristic!

    override func tearDown() {
        sut = nil
    }

    func testCharacteristicValueReturnsData() {
        let mockCharacteristic = MockCharacteristic(uuid: CBUUID(), notifying: false, data: Data(), properties: .read)
        sut = Characteristic(characteristic: mockCharacteristic)
        XCTAssertNotNil(sut.value)
        XCTAssertEqual(sut.value, mockCharacteristic.value)
    }

    func testCharacteristicValueReturnsNil() {
        let mockCharacteristic = MockCharacteristic(uuid: CBUUID(), notifying: false, data: nil, properties: .read)
        sut = Characteristic(characteristic: mockCharacteristic)
        XCTAssertNil(sut.value)
        XCTAssertEqual(sut.value, mockCharacteristic.value)
    }

    func testCharacteristicReturnsUUID() {
        let uuid = CBUUID()
        let mockCharacteristic = MockCharacteristic(uuid: uuid, notifying: false, data: nil, properties: .read)
        sut = Characteristic(characteristic: mockCharacteristic)
        XCTAssertEqual(sut.uuid, uuid)
    }

    func testCharacteristicIsNotifying() {
        let mockCharacteristic = MockCharacteristic(uuid: CBUUID(), notifying: true, data: nil, properties: .read)
        sut = Characteristic(characteristic: mockCharacteristic)
        XCTAssertTrue(sut.isNotifying, "Characteristic should not be notifying")
    }

    func testCharacteristicProperties() {
        let mockCharacteristic = MockCharacteristic(uuid: CBUUID(), notifying: false, data: nil, properties: .read)
        sut = Characteristic(characteristic: mockCharacteristic)
        XCTAssertEqual(sut.properties, .read)
    }
}
