//
//  CBPeripheralDelegateWrapperTests.swift
//  CombineBluetoothTests
//
//  Created by Vuk Radosavljevic on 4/3/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import XCTest
import Combine
import CoreBluetooth

final class CBPeripheralDelegateWrapperTests: XCTestCase {

    var sut: CBPeripheralDelegateWrapper!

    override func setUp() {
        sut = CBPeripheralDelegateWrapper()
    }

    override func tearDown() {
        sut = nil
    }

    func testDidDiscoverServicesEmitsPeripheral() {
        let mockCbPeripheral = MockCBPeripheral()
        mockCbPeripheral.addObserver(mockCbPeripheral,
                                     forKeyPath: "delegate",
                                     options: .new,
                                     context: nil)

        let cancellable = sut.didDiscoverServices.sink(receiveValue: { (peripheral, _) in
            guard let cbPeripheral = peripheral as? CBPeripheral else {
                XCTFail("Cast to CBPeripheral should not fail")
                return
            }
            XCTAssertEqual(cbPeripheral, mockCbPeripheral)
        })

        sut.peripheral(mockCbPeripheral, didDiscoverServices: nil)

        XCTAssertNotNil(cancellable)
    }

    func testDidDiscoverCharacteristicsForServiceEmitsPeripheral() {
        let mockCbPeripheral = MockCBPeripheral()
        mockCbPeripheral.addObserver(mockCbPeripheral,
                                     forKeyPath: "delegate",
                                     options: .new,
                                     context: nil)

        let mockService = CBMutableService(type: CBUUID(), primary: false)

        let cancellable = sut.didDiscoverCharacteristicsForServices.sink(receiveValue: { (peripheral, _, _) in
            guard let cbPeripheral = peripheral as? CBPeripheral else {
                XCTFail("Cast to CBPeripheral should not fail")
                return
            }
            XCTAssertEqual(cbPeripheral, mockCbPeripheral)
        })

        sut.peripheral(mockCbPeripheral, didDiscoverCharacteristicsFor: mockService, error: nil)

        XCTAssertNotNil(cancellable)
    }

}
