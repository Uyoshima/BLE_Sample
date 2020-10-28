//
//  BLEPeripheralViewController.swift
//  BLE_Sample
//
//  Created by 丸山翔 on 2020/10/27.
//

import UIKit
import CoreBluetooth

class BLEPeripheralViewController: UIViewController {
    
    private var peripheralManager: CBPeripheralManager!
    private var notifRead_characteristic: CBMutableCharacteristic!
    private var write_characteristic: CBMutableCharacteristic!
    private var service: CBMutableService!
    private var value: Data = "はろー".data(using: .utf8)!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    @IBAction func didPushstartAdvertising(_ sender: Any) {
        notifRead_characteristic = Characteristic.notif_read.mutableCharacteristic()
        write_characteristic    = Characteristic.write.mutableCharacteristic()

        service = Service.myService.mutableService()
        service.characteristics = [notifRead_characteristic, write_characteristic]
        peripheralManager.add(service)
        peripheralManager.startAdvertising( [CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
    }
    
    @IBAction func didPushSendValue(_ sender: Any) {
        notifRead_characteristic.value = value
        
        //通知更新
        peripheralManager.updateValue(value,
                                      for: notifRead_characteristic,
                                      onSubscribedCentrals: nil)
    }
    
    func showAlert(text: String) {
        let alert = UIAlertController(title: "来たよ！", message: text, preferredStyle: .alert)
        let close = UIAlertAction(title: "閉じる", style: .default, handler: nil)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
}

extension BLEPeripheralViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("■peripheral.state：\(peripheral.state)")
        switch peripheral.state {
        case .poweredOn:
            break
        case .poweredOff:
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unknown:
            break
        case .unsupported:
            break
        default:
            break
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            print("サービスの追加エラー：\(error!.localizedDescription)")
            return
        }
        print("サービスの追加完了")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if (error != nil) {
            print("アドバタイズのエラー：\(error!.localizedDescription)")
        }
        print("アドバタイズの成功")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("書き込み通知の開始")

        for request in requests where request.characteristic.uuid == write_characteristic.uuid {
            guard let data = request.value,
                  let text = String(data: data, encoding: .utf8) else {
                return
            }
            showAlert(text: text)
        }
    }
}
