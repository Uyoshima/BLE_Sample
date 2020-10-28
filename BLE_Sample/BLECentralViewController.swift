//
//  BLECentralViewController.swift
//  BLE_Sample
//
//  Created by 丸山翔 on 2020/10/27.
//

import UIKit
import CoreBluetooth

class BLECentralViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var centralManager: CBCentralManager!

    private var peripherals: [CBPeripheral] = []
    private var connectedPeripheral: CBPeripheral!
    
    private var currentValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate   = self
        tableView.dataSource = self
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func didPushButton(_ sender: Any) {
        centralManager.scanForPeripherals(withServices: [Service.myService.UUID()], options: nil)
    }
    
    func showAlert(peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic) {
        let alert = UIAlertController(title: "現在の値", message: "\(currentValue)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Say Hello", style: .default) { (action) in
            self.sayHello(peripheral: peripheral, didUpdateNotificationStateFor: characteristic)
        }
        let close = UIAlertAction(title: "閉じる", style: .default, handler: nil)
        alert.addAction(action)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
    func sayHello(peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic) {
        let data = Data(base64Encoded: "ハロー")!
        connectedPeripheral.writeValue(data,
                                       for: characteristic,
                                       type: .withResponse)
    }
}

extension BLECentralViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                print("■ central.state：.poweredOn")
                break
            case .poweredOff:
                print("■ central.state：.poweredOff")
                break
            case .resetting:
                print("■ central.state：.resetting")
                break
            case .unknown:
                print("■ central.state：.unknown")
                break
            case .unsupported:
                print("■ central.state：.unsupported")
                break
            case .unauthorized:
                print("■ central.state：.unauthorized")
                break
            default:
                break
        }
    }
    
    // ペリフェラル検出
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discover Target peripheral: \(peripheral.name ?? "名前無し")")
        let uuidString = peripheral.identifier.uuidString
        if uuidString == Service.myService.UUID().uuidString {
            central.stopScan()
        }
        peripherals.append(peripheral)
        tableView.reloadData()
    }
    
    // ペリフェラル接続完了
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("ペリフェラルに接続完了")
        print("ペリフェラルのサービスの検出開始...")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
}

extension BLECentralViewController: CBPeripheralDelegate {
    // ペリフェラルのサービス検出
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("ペリフェラルのサービスの検出完了")
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            print("Discovered service：\(service)")
            print("サービスの特性を検出開始...")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        for chara in characteristics {
            print("サービスの特性を検出完了")
            print("■Discovered characteristic")
            print("characteristic.uuid：\(chara.uuid.uuidString)")
            print("characteristic.properties：\(chara.properties)")
            print("characteristic.value：\(String(describing: chara.value))")
            print("characteristic.isNotifying：\(chara.isNotifying)")
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value,
              let valueString = String(data: data, encoding: .utf8),
              let value = Int(valueString) else {
            return
        }
        
        currentValue += value
        
    }
}

extension BLECentralViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = peripherals[indexPath.row].name
        return cell
    }
}

extension BLECentralViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        centralManager.connect(peripheral, options: nil)
        connectedPeripheral = peripheral
    }
}
