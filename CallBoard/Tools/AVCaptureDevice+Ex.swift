//
//  AVCaptureDevice+Ex.swift
//  CallBoard
//
//  Created by mugua on 2019/5/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureDevice {
    var isLocked: Bool {
        do {
            try lockForConfiguration()
            return true
        } catch {
            print(error)
            return false
        }
    }
    func setTorch(intensity: Float) {
        guard hasTorch && isLocked else { return }
        defer { unlockForConfiguration() }
        if intensity > 0 {
            if torchMode == .off {
                torchMode = .on
            }
            do {
                try setTorchModeOn(level: intensity)
            } catch {
                print(error)
            }
        } else {
            torchMode = .off
        }
    }
}
