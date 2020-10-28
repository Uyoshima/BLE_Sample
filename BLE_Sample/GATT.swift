//
//  GATT.swift
//  BLE_Sample
//
//  Created by 丸山翔 on 2020/10/27.
//

import UIKit
import CoreBluetooth

enum Service {
    case myService
    
    func UUID() -> CBUUID {
        switch self {
        case .myService:
            return CBUUID(string: "B8A18F4F-2A2B-4084-AC2D-1ABC289EF05D")
        }
    }
    
    func mutableService() -> CBMutableService {
        switch self {
        case .myService:
            return CBMutableService(type: CBUUID(), primary: true)
        }
    }
}

enum Characteristic {
    case notif_read
    case write
    
    func UUID() -> CBUUID {
        switch self {
        case .notif_read:
            return CBUUID(string: "C2F0882D-2440-40F4-A4A9-95BE43B89EAE")
        case .write:
            return CBUUID(string: "C2F0882E-2440-40F4-A4A9-95BE43B89EAE")
        }
    }
    
    private func properties() -> CBCharacteristicProperties {
        switch self {
        case .notif_read:
            return [.notify, .read]
        case .write:
            return [.write]
        }
    }
    
    private func permissions() -> CBAttributePermissions {
        switch self {
        case .notif_read:
            return [.readable]
        case .write:
            return [.writeable]
        }
    }
    
    func mutableCharacteristic() -> CBMutableCharacteristic {
        return CBMutableCharacteristic(
            type: UUID(),
            properties: properties(),
            value: nil,
            permissions: permissions())
    }
}
