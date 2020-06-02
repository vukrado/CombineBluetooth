//
//  PeripheralTests.swift
//  CombineBluetoothTests
//
//  Created by Vuk Radosavljevic on 4/2/20.
//  Copyright © 2020 Vuk Radosavljevic. All rights reserved.
//

import XCTest
import CoreBluetooth
import Combine

final class PeripheralTests: XCTestCase {

    var sut: Peripheral!

    override func tearDown() {
        sut = nil
    }

    func testNameReturnsCorrectNameWhenNotNil() {
        let mockPeripheral = MockBluetoothPeripheral()
        mockPeripheral.name = "MockPeripheral"
        sut = Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager())
        XCTAssertEqual(sut.name, "MockPeripheral")
    }

    func testNameReturnsNAWhenNil() {
        let mockPeripheral = MockBluetoothPeripheral()
        sut = Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager())
        XCTAssertEqual(sut.name, "N/A")
    }

    func testIsConnectedReturnsFalseWhenNotConnected() {
        let mockPeripheral = MockBluetoothPeripheral()
        mockPeripheral.state = .disconnected
        sut = Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager())
        XCTAssertEqual(sut.isConnected, false)
    }

    func testIsConnectedReturnsTrueWhenConnected() {
        let mockPeripheral = MockBluetoothPeripheral()
        mockPeripheral.state = .connected
        sut = Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager())
        XCTAssertEqual(sut.isConnected, true)
    }

    func testServicesReturnServicesWhenNotNil() {
        let mockPeripheral = MockBluetoothPeripheral()
        let mockService = CBMutableService(type: CBUUID(), primary: false)
        mockPeripheral.services = [mockService]
        sut = Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager())
        XCTAssertNotNil(sut.services)
        XCTAssertEqual(sut.services?.count, 1)
    }

    func testServicesReturnsNil() {
        let mockPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        sut = Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager())
        XCTAssertNil(sut.services)
    }

    func testStateIsDisconnected() {
        let mockPeripheral = MockCBPeripheral()
        mockPeripheral.addObserver(mockPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        sut = Peripheral(peripheral: mockPeripheral, bluetoothManager: BluetoothManager())
        XCTAssertEqual(sut.state, .disconnected)
    }

    func testDiscoverServicesEmitsArrayOfServices() {
        let mockBluetoothPeripheral = MockBluetoothPeripheral()
        let mockService = CBMutableService(type: CBUUID(), primary: false)
        mockBluetoothPeripheral.services = [mockService]
        let mockCentralManager = MockCentralManager()
        let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
        sut = Peripheral(peripheral: mockBluetoothPeripheral, bluetoothManager: bluetoothManager)
        let cancellable = sut
            .discoverServices(nil)
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .finished)
            },
                  receiveValue: { services in
                    XCTAssertEqual(services.first?.uuid, mockService.uuid)
            })

        mockBluetoothPeripheral.peripheralDelegate?.peripheral(peripheral: mockBluetoothPeripheral, didDiscoverServices: nil)

        XCTAssertNotNil(cancellable)
    }

    func testDiscoverServicesEmitsErrorWhenServicesIsNil() {
        let mockBluetoothPeripheral = MockBluetoothPeripheral()
        let mockCentralManager = MockCentralManager()
        let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
        sut = Peripheral(peripheral: mockBluetoothPeripheral, bluetoothManager: bluetoothManager)
        let cancellable = sut
            .discoverServices(nil)
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .failure(.noServicesForPeripheral))
            },
                  receiveValue: { services in
                    XCTFail("Should not receive a value, received \(services)")
            })

        mockBluetoothPeripheral.peripheralDelegate?.peripheral(peripheral: mockBluetoothPeripheral, didDiscoverServices: nil)

        XCTAssertNotNil(cancellable)
    }

    func testDiscoverServicesEmitsErrorWhenErrorDiscoveringServices() {
        let mockBluetoothPeripheral = MockBluetoothPeripheral()
        let mockCentralManager = MockCentralManager()
        let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
        sut = Peripheral(peripheral: mockBluetoothPeripheral, bluetoothManager: bluetoothManager)
        let cancellable = sut
            .discoverServices(nil)
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .failure(.failedToDiscoverServices))
            },
                  receiveValue: { services in
                    XCTFail("Should not receive a value, received \(services)")
            })

        mockBluetoothPeripheral.peripheralDelegate?.peripheral(peripheral: mockBluetoothPeripheral, didDiscoverServices: NSError())

        XCTAssertNotNil(cancellable)
    }

    func testDiscoverCharacteristicsEmitsCharacteristics() {
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
        sut = Peripheral(peripheral: mockBluetoothPeripheral, bluetoothManager: bluetoothManager)
        let cancellable = sut
            .discoverCharacteristics(nil, for: Service(service: mockService, peripheral: sut))
            .sink(receiveCompletion: { completion in
                    XCTAssertEqual(completion, .finished)
                },
                  receiveValue: { characteristics in
                    XCTAssertEqual(characteristics.first?.uuid, mockCharacteristic.uuid)
                })

        mockBluetoothPeripheral.peripheralDelegate?.peripheral(peripheral: mockBluetoothPeripheral,
                                                               didDiscoverCharacteristicsFor: mockService,
                                                               error: nil)

        XCTAssertNotNil(cancellable)
    }

    func testDiscoverCharacteristicsEmitsFailureWhenErrorIsNotNil() {
        let mockBluetoothPeripheral = MockBluetoothPeripheral()
        let mockService = CBMutableService(type: CBUUID(), primary: false)
        mockBluetoothPeripheral.services = [mockService]
        let mockCentralManager = MockCentralManager()
        let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
        sut = Peripheral(peripheral: mockBluetoothPeripheral, bluetoothManager: bluetoothManager)
        let cancellable = sut
            .discoverCharacteristics(nil, for: Service(service: mockService, peripheral: sut))
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .failure(.failedToDiscoverCharacteristics))
                },
                  receiveValue: { characteristics in
                    XCTFail("Should not receive value, received \(characteristics)")
                })

        mockBluetoothPeripheral.peripheralDelegate?.peripheral(peripheral: mockBluetoothPeripheral,
                                                               didDiscoverCharacteristicsFor: mockService,
                                                               error: NSError())

        XCTAssertNotNil(cancellable)
    }

    func testDiscoverCharacteristicsEmitsFailureWhenNoCharacteristicsFound() {
        let mockBluetoothPeripheral = MockBluetoothPeripheral()
        let mockService = CBMutableService(type: CBUUID(), primary: false)
        mockBluetoothPeripheral.services = [mockService]
        let mockCentralManager = MockCentralManager()
        let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
        sut = Peripheral(peripheral: mockBluetoothPeripheral, bluetoothManager: bluetoothManager)
        let cancellable = sut
            .discoverCharacteristics(nil, for: Service(service: mockService, peripheral: sut))
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .failure(.noCharacteristicsForService))
                },
                  receiveValue: { characteristics in
                    XCTFail("Should not receive value, received \(characteristics)")
                })

        mockBluetoothPeripheral.peripheralDelegate?.peripheral(peripheral: mockBluetoothPeripheral,
                                                               didDiscoverCharacteristicsFor: mockService,
                                                               error: nil)

        XCTAssertNotNil(cancellable)
    }

    func testEstablishConnectionEmitsPeripheralOnConnection() {
        let mockCbPeripheral = MockCBPeripheral()
        mockCbPeripheral.addObserver(mockCbPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        let mockCentralManager = MockCentralManager()
        let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
        sut = Peripheral(peripheral: mockCbPeripheral, bluetoothManager: bluetoothManager)
        let cancellable = sut
            .establishConnection()
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(completion, .finished)
            },
                  receiveValue: { peripheral in
                    guard let cbPeripheral = peripheral.peripheral as? CBPeripheral else {
                        XCTFail("Should not fail to cast to CBPeripheral")
                        return
                    }
                    XCTAssertEqual(cbPeripheral, mockCbPeripheral)
            })

        mockCentralManager.centralManagerDelegate?.centralManager(central: mockCentralManager, didConnect: mockCbPeripheral)
        XCTAssertNotNil(cancellable)
    }

    func testObserveConnectionEmitTrueOnConnectionEvent() {
        let mockCbPeripheral = MockCBPeripheral()
        mockCbPeripheral.addObserver(mockCbPeripheral, forKeyPath: "delegate", options: .new, context: nil)
        let mockCentralManager = MockCentralManager()
        let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
        sut = Peripheral(peripheral: mockCbPeripheral, bluetoothManager: bluetoothManager)
        let cancellable = sut
            .observeConnection()
            .sink(receiveValue: { connected in
                XCTAssertEqual(connected, true)
            })

        mockCentralManager.centralManagerDelegate?.centralManager(central: mockCentralManager, didConnect: mockCbPeripheral)
        XCTAssertNotNil(cancellable)
    }

    func testObserveConnectionEmitsFalseOnDisconnection() {
            let mockCbPeripheral = MockCBPeripheral()
            mockCbPeripheral.addObserver(mockCbPeripheral, forKeyPath: "delegate", options: .new, context: nil)
            let mockCentralManager = MockCentralManager()
            let bluetoothManager = BluetoothManager(centralManager: mockCentralManager)
            sut = Peripheral(peripheral: mockCbPeripheral, bluetoothManager: bluetoothManager)
            let cancellable = sut
                .observeConnection()
                .sink(receiveValue: { connected in
                    XCTAssertEqual(connected, false)
                })

            mockCentralManager.centralManagerDelegate?.centralManager(central: mockCentralManager,
                                                                      didDisconnectPeripheral: mockCbPeripheral,
                                                                      error: nil)
            XCTAssertNotNil(cancellable)
    }
}

final class MockBluetoothPeripheral: BluetoothPeripheral {
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) { }

    func readValue(for characteristic: CBCharacteristic) { }

    weak var peripheralDelegate: PeripheralDelegate?

    var state: CBPeripheralState = .disconnected

    var services: [CBService]?

    var name: String?

    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {}

    func discoverServices(_ serviceUUIDs: [CBUUID]?) { }

}
