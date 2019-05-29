//
//  SettingModel.swift
//  CallBoard
//
//  Created by mugua on 2019/5/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation


enum SettingType: Int, CustomStringConvertible {
    
    case style = 0
    case speed
    case font
    case color
    case flashLight
    
    var description: String {
        switch self {
        case .style:
            return "样式"
        case .speed:
            return "速度"
        case .font:
            return "字体"
        case .color:
            return "颜色"
        case .flashLight:
            return "闪光灯"
        }
    }
}

struct SettingModel: Hashable {
    let type: Int
    let itemName: String
    let value: Int
    var select: Bool
    
    init(type: Int, itemName: String, value: Int, select: Bool = false) {
        self.type = type
        self.itemName = itemName
        self.value = value
        self.select = select
    }
    
    func getTypeName() -> String {
        return SettingType(rawValue: type)!.description
    }
}

