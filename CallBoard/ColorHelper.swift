//
//  ColorHelper.swift
//  CallBoard
//
//  Created by mugua on 2019/5/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework


let allProjectColor = [UIColor.flatRed, UIColor.flatOrange, UIColor.flatYellow, UIColor.flatSand, UIColor.flatMagenta, UIColor.flatSkyBlue, UIColor.flatGreen, UIColor.flatWhite, UIColor.flatPurple, UIColor.flatGray, UIColor.flatPink, UIColor.flatLime]

enum ColorHelper: Int, CustomStringConvertible {
    
    case red = 0
    case orange
    case yellow
    case sand
    case magenta
    case skyBlue
    case green
    case white
    case purple
    case gray
    case pink
    case lime
    
    var description: String {
        switch self {
        case .red:
            return "气泡红色"
        case .orange:
            return "气泡橘色"
        case .yellow:
            return "气泡黄色"
        case .sand:
            return "气泡乳白色"
        case .magenta:
            return "气泡酒红色"
        case .skyBlue:
            return "气泡天空蓝色"
        case .green:
            return "气泡绿色"
        case .white:
            return "气泡白色"
        case .purple:
            return "气泡紫色"
        case .gray:
            return "气泡灰色"
        case .pink:
            return "气泡粉红色"
        case .lime:
            return "气泡嫩绿色"
        }
    }
    
    
    func getColor() -> UIColor {
        return allProjectColor[self.rawValue]
    }
    
    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        NotificationCenter.default.post(name: .statuBarDidChnage, object: style)
    }
    
}
