//
//  GlobalConfiguration.swift
//  CallBoard
//
//  Created by mugua on 2019/5/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation


struct GlobalConfiguration {
    
    typealias ConfigurationProperty = (name: String, value: Int)
    typealias ChangedBlock = (GlobalConfiguration) -> Void
    
    
    static var shared = GlobalConfiguration()
    
    var style: ConfigurationProperty {
        didSet {
            change?(self)
        }
    }
    var speed: ConfigurationProperty {
        didSet {
            change?(self)
        }
    }
    var font:  ConfigurationProperty {
        didSet {
            change?(self)
        }
    }
    var color: ConfigurationProperty {
        didSet {
            change?(self)
        }
    }
    var flash: ConfigurationProperty {
        didSet {
            change?(self)
        }
    }
    
    private var change: ChangedBlock?
    
    private init() {
        self.style = ConfigurationProperty("滚动", 1)
        self.speed = ConfigurationProperty("速度", 1)
        self.font = ConfigurationProperty("速度", 24)
        self.color = ConfigurationProperty("颜色", 1)
        self.flash = ConfigurationProperty("闪光灯", 0)
    }
    
    mutating func hasChangeBlock(call: @escaping ChangedBlock) {
        self.change = call
    }
    
}
