//
//  BluetoothManager.swift
//
//
//  Created by Vuk Radosavljevic on 3/22/20.
//

import CoreBluetooth
import Combine

/// Class that provides a Combine API that wraps all Core Bluetooth Manager's functions allowing you to scan and connect to peripheral's.
///
/// To start discovering peripherals nearby you can ovserve the state and wait for bluetooth to be powered on. You can then chain operators
/// to scan for peripherals with an array of services you provide, filter by name, and then establish a connection with it.
/// ```
/// bluetoothManager
///     .observeState()
///     .filter { $0 == .poweredOn }
///     .scanForPeripheral(withServices: AuxBox.services)
///     .filter { $0.name.prefix(4) == serialNumber }
///     .flatMap { $0.establishConnection() }
///     .timeout(60, schedular: DispatchQueue.main)
///     .retry(3)
///     .sink { recieveValue: peripheral in
///         print(peripheral.name)
///     }
/// ```
public final class BluetoothManager: NSObject {

    // MARK: Properties
    private var centralManager: CentralManager
    private let centralManagerDelegateWrapper: CBCentralManagerDelegateWrapper

    private var scanCancellable: Cancellable?
    private var connectPeripheralCancellable: Cancellable?

    // MARK: State
    /// The current state of the manager.
    var state: CBManagerState { centralManager.state }

    // MARK: Initialization
    init(centralManager: CentralManager = CBCentralManager(),
         centralManagerDelegate: CBCentralManagerDelegateWrapper = CBCentralManagerDelegateWrapper()) {
        self.centralManager = centralManager
        self.centralManagerDelegateWrapper = centralManagerDelegate
        self.centralManager.centralManagerDelegate = centralManagerDelegate
    }

    // MARK: - Methods
    /// Emits changes when the central manager’s state updated.
    /// - Returns: A publisher that continously emits changes to the central manager.
    func observeState() -> AnyPublisher<CBManagerState, Never> {
        centralManagerDelegateWrapper.didUpdateState.eraseToAnyPublisher()
    }

    /// Emits a `Peripheral` when the central manager connects to it.
    /// - Returns: A publisher that continously emits connected `Peripheral`s.
    func observeConnect() -> AnyPublisher<Peripheral, Never> {
        return centralManagerDelegateWrapper.didConnectToPeripheral
            .map { Peripheral(peripheral: $0, bluetoothManager: self) }
            .eraseToAnyPublisher()
    }

    /// Emits a `Peripheral` when the central manager disconnected from it.
    /// - Returns: A publisher that contiously emits `Peripheral`s that get disconnected.
    func observeDisconnect() -> AnyPublisher<Peripheral, Never> {
        return centralManagerDelegateWrapper.didDisconnectPeripheral
            .map { peripheral, _ in
                Peripheral(peripheral: peripheral, bluetoothManager: self)
            }.eraseToAnyPublisher()
    }

    /// Scans for  `Peripheral`s  that are advertising services.
    /// - Parameter serviceUUIDs: An array of CBUUID objects that the app is interested in.
    /// Each CBUUID object represents the UUID of a service that a peripheral advertises.
    /// - Parameter options: A dictionary of options for customizing the scan. For available options, see
    /// [Peripheral Scanning Options](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/peripheral_scanning_options)
    func scanForPeripheral(withServices serviceUUIDs: [CBUUID]?,
                           options: [String: Any]? = nil) -> AnyPublisher<Peripheral, BluetoothError> {

        let scanSubject = PassthroughSubject<Peripheral, BluetoothError>()

        if centralManager.state != .poweredOn {
            scanSubject.send(completion: .failure(.bluetoothNotOn))
        }

        if centralManager.isScanning {
            scanSubject.send(completion: .failure(.scanInProgress))
        }

        scanCancellable = centralManagerDelegateWrapper.didDiscoverPeripheral.sink { [weak self] (discoveredPeripheral) in
            guard let self = self else {
                scanSubject.send(completion: .failure(.objectDestroyed))
                return
            }
            scanSubject.send(Peripheral(peripheral: discoveredPeripheral, bluetoothManager: self))
            scanSubject.send(completion: .finished)
            self.centralManager.stopScan()
            self.scanCancellable?.cancel()
        }

        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)

        return scanSubject.eraseToAnyPublisher()
    }

    // swiftlint:disable line_length
    /// Establishes a local connection to a `Peripheral`.
    /// - Parameter peripheral: The `Peripheral` to which the central is attempting to connect.
    /// - Parameter options: An optional dictionary to customize the behavior of the connection. For available options, see
    /// [Peripheral Connection Options](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/peripheral_connection_options).
    func connectToPeripheral(_ peripheral: Peripheral,
                             options: [String: Any]? = nil) -> AnyPublisher<Peripheral, BluetoothError> {
        let connectSubject = PassthroughSubject<Peripheral, BluetoothError>()

        connectPeripheralCancellable = centralManagerDelegateWrapper.didConnectToPeripheral
            .sink { (cbPeripheral) in
                connectSubject.send(Peripheral(peripheral: cbPeripheral, bluetoothManager: self))
                connectSubject.send(completion: .finished)
                self.connectPeripheralCancellable = nil
            }

        _ = centralManagerDelegateWrapper.didFailToConnectToPeripheral
            .sink(receiveValue: { _ in
                connectSubject.send(completion: .failure(.failedToConnect))
            })

        centralManager.connect(peripheral.peripheral, options: nil)

        return connectSubject.eraseToAnyPublisher()
    }
}

protocol CentralManager {
    var centralManagerDelegate: CentralManagerDelegate? { get set }
    var isScanning: Bool { get }
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?)
    func stopScan()
    func connect(_ peripheral: CBPeripheral, options: [String: Any]?)
    var state: CBManagerState { get }
}

protocol CentralManagerDelegate: class {
    func centralManagerDidUpdateState(central: CentralManager)
}

extension CBCentralManager: CentralManager {
    // swiftlint:disable force_cast implicit_getter
    var centralManagerDelegate: CentralManagerDelegate? {
        get { return delegate as! CentralManagerDelegate? }
        set { delegate = newValue as! CBCentralManagerDelegate? }
    }
}


protocol BluetoothPeripheral {
    var name: String? { get }
    var state: CBPeripheralState { get }
    var services: [CBService]? { get }
    var delegate: CBPeripheralDelegate? { get set }
    func discoverServices(_ serviceUUIDs: [CBUUID]?)
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService)
}

extension CBPeripheral: BluetoothPeripheral {
    
}
