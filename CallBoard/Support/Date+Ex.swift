//
//  Date+Ex.swift
//  CallBoard
//
//  Created by mugua on 2019/5/30.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation

extension Date {
    
    func localString(dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> String {
        return DateFormatter.localizedString(from: self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
}
