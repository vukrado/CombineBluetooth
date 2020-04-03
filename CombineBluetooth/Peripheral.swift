//
//  Peripheral.swift
//
//
//  Created by Vuk Radosavljevic on 3/22/20.
//

import CoreBluetooth
import Combine

/// Combine wrapper for CoreBluetooth's [CBPeripheral](https://developer.apple.com/documentation/corebluetooth/cbperipheral)
public final class Peripheral {

    // MARK: - Properties
    private unowned let bluetoothManager: BluetoothManager
    private let peripheralDelegateWrapper: CBPeripheralDelegateWrapper

    private var servicesCancellable: Cancellable?
    private var discoverCharacteristicsCancellable: Cancellable?

    /// Underlying instance of  a `CBPeripheral`.
    public var peripheral: BluetoothPeripheral

    /// The connection state of the peripheral.
    public var state: CBPeripheralState { peripheral.state }

    /// A list of a `Service`s discovered by the `Peripheral`.
    public var services: [Service]? {
        peripheral.services?.map { Service(service: $0, peripheral: self) }
    }

    /// The name of the peripheral or N/A if no name exists.
    public var name: String {
        peripheral.name ?? "N/A"
    }

    /// True if current connection state of the peripheral is `CBPeriperhalState.connected`.
    public var isConnected: Bool {
        peripheral.state == .connected
    }

    // MARK: Initialization
    init(peripheral: BluetoothPeripheral,
         peripheralDelegateWrapper: CBPeripheralDelegateWrapper = CBPeripheralDelegateWrapper(),
         bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        self.peripheral = peripheral
        self.peripheralDelegateWrapper = peripheralDelegateWrapper
        self.peripheral.peripheralDelegate = peripheralDelegateWrapper
    }

    // MARK: - Methods
    /// Continous value indicating if the peripheral is in a connected state.
    /// - Returns: `True` if the `Peripheral` is in a connected state as a `AnyPublisher<Bool, Never>`.
    public func observeConnection() -> AnyPublisher<Bool, Never> {
        let connected = bluetoothManager.observeConnect().map { _ in true }
        let disconnected = bluetoothManager.observeDisconnect().map { _ in false }
        return connected.merge(with: disconnected).eraseToAnyPublisher()
    }

    ///
    public func establishConnection(options: [String: Any]? = nil) -> AnyPublisher<Peripheral, BluetoothError> {
        return bluetoothManager.connectToPeripheral(self, options: options)
    }

    /// Discovers the specified services for the peripheral
    public func discoverServices(_ serviceUUIDs: [CBUUID]?) -> AnyPublisher<[Service], BluetoothError> {

        let deferred = Deferred {
            Future<[Service], BluetoothError> { promise in
                self.servicesCancellable = self.peripheralDelegateWrapper.didDiscoverServices.sink(receiveValue: { (peripheral, error) in
                        if error == nil {
                            guard let cbServices = peripheral.services else { return promise(.failure(.noServicesForPeripheral))}
                            let services = cbServices.map { Service(service: $0, peripheral: self)}
                            return promise(.success(services))
                        }
                        promise(.failure(.failedToDiscoverServices))
                })
            }
        }.eraseToAnyPublisher()

        peripheral.discoverServices(serviceUUIDs)

        return deferred
    }

    public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?,
                                        for service: Service) -> AnyPublisher<[Characteristic], BluetoothError> {

        let discoverCharacteristicsSubject = PassthroughSubject<[Characteristic], BluetoothError>()

        self.discoverCharacteristicsCancellable = peripheralDelegateWrapper
            .didDiscoverCharacteristicsForServices
            .sink(receiveValue: {(_, cbService, error) in
                guard error == nil else {
                    discoverCharacteristicsSubject.send(completion: .failure(.failedToDiscoverCharacteristics))
                    return
                }

                if service.service == cbService {
                    guard let cbCharacteristics = cbService.characteristics else {
                        discoverCharacteristicsSubject.send(completion: .failure(.noCharacteristicsForService))
                        return
                    }
                    let charactistics = cbCharacteristics.map { Characteristic(characteristic: $0) }
                    discoverCharacteristicsSubject.send(charactistics)
                    discoverCharacteristicsSubject.send(completion: .finished)
                }
            })

        peripheral.discoverCharacteristics(characteristicUUIDs, for: service.service)

        return discoverCharacteristicsSubject.eraseToAnyPublisher()
    }
}

public protocol BluetoothPeripheral {
    var peripheralDelegate: PeripheralDelegate? { get set }
    var state: CBPeripheralState { get }
    var services: [CBService]? { get }
    var name: String? { get }
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService)
    func discoverServices(_ serviceUUIDs: [CBUUID]?)
}

public protocol PeripheralDelegate: class {
    func peripheral(peripheral: BluetoothPeripheral, didDiscoverServices error: Error?)
    func peripheral(peripheral: BluetoothPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
//    func peripheral(peripheral: BluetoothPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
//    func peripheral(peripheral: BluetoothPeripheral, didModifyServices invalidatedServices: [CBService])
}

extension CBPeripheral: BluetoothPeripheral {
    // swiftlint:disable force_cast
    public var peripheralDelegate: PeripheralDelegate? {
        get { return delegate as! PeripheralDelegate? }
        set { delegate = newValue as! CBPeripheralDelegate? }
    }
}

// MARK: - Equatable
extension Peripheral: Equatable {
    public static func == (lhs: Peripheral, rhs: Peripheral) -> Bool {
        return lhs.peripheral as! CBPeripheral == rhs.peripheral as! CBPeripheral
    }
}
