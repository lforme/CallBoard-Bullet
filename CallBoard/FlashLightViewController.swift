//
//  FlashLightViewController.swift
//  CallBoard
//
//  Created by mugua on 2019/5/31.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import RxSwift
import RxCocoa

class FlashLightViewController: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var modeSegment: UISegmentedControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    let motionManager = CMMotionManager()
    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
    
    
    let timer = Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance).share()
    
    deinit {
        print("Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactiveNavigationBarHidden = true
        setupButton()
        bindRx()
        
        if motionManager.isGyroAvailable {
            
            motionManager.deviceMotionUpdateInterval = 0.2
            guard let queue = OperationQueue.current else { return }
            motionManager.startDeviceMotionUpdates(to: queue) {[unowned self] (m, e) in
                guard let unwrappedAttitude = m?.attitude else {
                    return
                }
                
                let pitch = Float(unwrappedAttitude.pitch)
                if pitch > 1.1 {
                    self.device?.setTorch(intensity: 1)
                } else {
                    self.device?.setTorch(intensity: 0)
                }
            }
        }
    }
    
    func bindRx() {
        
        let offOn = modeSegment.rx.selectedSegmentIndex.map { $0 == 1 }.share()
        let frequencyOn =  timer.map { ($0 % 2) == 0 }
        
        Observable.combineLatest(offOn, frequencyOn) {(a, b) -> Bool in
            return a && b
            }.subscribe(onNext: {[weak self] (isOn) in
                if isOn {
                    self?.device?.setTorch(intensity: 1)
                } else {
                    self?.device?.setTorch(intensity: 0)
                }
            }).disposed(by: rx.disposeBag)
        
        
        offOn.subscribe(onNext: {[weak self] (isON) in
            if isON {
                self?.motionManager.stopDeviceMotionUpdates()
            } else {
                guard let queue = OperationQueue.current else { return }
                self?.motionManager.startDeviceMotionUpdates(to: queue) {(m, e) in
                    guard let unwrappedAttitude = m?.attitude else {
                        return
                    }
                    let pitch = Float(unwrappedAttitude.pitch)
                    if pitch > 1.1 {
                        self?.device?.setTorch(intensity: 1)
                    } else {
                        self?.device?.setTorch(intensity: 0)
                    }
                }
            }
        }).disposed(by: rx.disposeBag)
        
        offOn.map { (isOn) -> String in
            if !isOn {
                return "竖起手机, 闪光灯开始闪烁."
            } else {
                return "闪光灯一直闪烁."
            }
        }.bind(to: descriptionLabel.rx.text).disposed(by: rx.disposeBag)
    }
    
    
    func setupButton() {
        
        let img = UIImage(named: "back_button_icon")?.filled(withColor: UIColor.white)
        backButton.setImage(img, for: .normal)
        
        backButton.rx.tap.subscribe(onNext: {[unowned self] (_) in
            
            self.navigationController?.popViewController(animated: true)
            
        }).disposed(by: rx.disposeBag)
        
    }
}
