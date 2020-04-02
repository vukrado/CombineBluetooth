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
        let mockCharacteristic = MockCharacteristic(type: CBUUID(),
                                                         properties: .read,
                                                         value: Data(base64Encoded: "test"),
                                                         isNotifying: false)
        sut = Characteristic(characteristic: mockCharacteristic)
        XCTAssertNotNil(sut.value)
        XCTAssertEqual(sut.value, mockCharacteristic.value)
    }

    func testCharacteristicValueReturnsNil() {
        let mockCharacteristic = CBMutableCharacteristic(type: CBUUID(),
                                                         properties: .read,
                                                         value: nil,
                                                         permissions: .readable)
        sut = Characteristic(characteristic: mockCharacteristic)
        XCTAssertNil(sut.value)
        XCTAssertEqual(sut.value, mockCharacteristic.value)
    }

    func testCharacteristicReturnsUUID() {

//        let testMock = MockCharacteristic(type: CBUUID())
//
//        sut = Characteristic(characteristic: testMock)
//        XCTAssertEqual(sut.uuid, mockCharacteristic.uuid)
    }
}




