//
//  DisplayController.swift
//  CallBoard
//
//  Created by mugua on 2019/5/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import MarqueeLabel
import LTMorphingLabel
import RxCocoa
import RxSwift
import PKHUD

class DisplayController: UIViewController {
    
    var model: LabelModel!
    
    let marLabel = MarqueeLabel(frame: .zero, duration: 12, fadeLength: 60)
    let ltmLabel = LTMorphingLabel.init(frame: .zero)
    let timer = Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance).share()
    let hideButtonTimer = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance).share()
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    deinit {
        print("Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactiveNavigationBarHidden = true
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        setupLabels()
        setupButton()
        setupGes()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func setupGes() {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        tap.rx.event.subscribe(onNext: {[unowned self] (recognizer) in
            if recognizer.numberOfTapsRequired == 2{
                self.backButton.alpha = 1
                self.deleteButton.alpha = 1
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupButton() {
        let img = UIImage(named: "back_button_icon")?.filled(withColor: UIColor.white)
        backButton.setImage(img, for: .normal)
        
        backButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        backButton.alpha = 0
        deleteButton.alpha = 0
        
        hideButtonTimer.subscribe(onNext: {[weak self] (_) in
            UIView.animate(withDuration: 2, delay: 2, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self?.backButton.alpha = 0
                self?.deleteButton.alpha = 0
            }, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupLabels() {
        view.addSubview(marLabel)
        view.addSubview(ltmLabel)
    
        marLabel.text = "双击屏幕可以看到返回按钮"
        marLabel.font = UIFont.systemFont(ofSize: 18)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.marLabel.text = self?.model.displayText
        }
        
        ltmLabel.text = "双击屏幕可以看到返回按钮"
        ltmLabel.font = UIFont.systemFont(ofSize: 18)
        
        marLabel.textAlignment = .center
        marLabel.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
        }
        
        ltmLabel.textAlignment = .center
        ltmLabel.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
        }
        
        marLabel.textColor = ColorHelper(rawValue: model.color)?.getColor()
        ltmLabel.textColor = ColorHelper(rawValue: model.color)?.getColor()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {[unowned self] in
            self.marLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(self.model!.font))
            self.ltmLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(self.model!.font))
        }
        
        marLabel.speed = .duration(CGFloat(model.speed))
        
        if model.style == 0 {
            marLabel.isHidden = false
            ltmLabel.isHidden = true
        } else {
            marLabel.isHidden = true
            ltmLabel.isHidden = false
            
            switch model.style {
            case 1:
                ltmLabel.morphingEffect = .scale
            case 2:
                ltmLabel.morphingEffect = .evaporate
            case 3:
                ltmLabel.morphingEffect = .fall
            case 4:
                ltmLabel.morphingEffect = .pixelate
            case 5:
                ltmLabel.morphingEffect = .sparkle
            case 6:
                ltmLabel.morphingEffect = .burn
            case 7:
                ltmLabel.morphingEffect = .anvil
            default: break
            }
            
            timer.delay(.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
                self?.ltmLabel.text = ""
                self?.ltmLabel.text = self?.model.displayText
            }).disposed(by: rx.disposeBag)
        }
    }
    
    @IBAction func deleteTap(_ sender: UIButton) {
        
        let q = AVQuery(className: DatabaseKey.labelTable)
        q.whereKey("displayText", equalTo: model.displayText)
        let label = q.findObjects()?.last as? AVObject
        guard let id = label?.objectId else {
            return
        }
        
        AVQuery.doCloudQueryInBackground(withCQL: "delete from \(DatabaseKey.labelTable) where objectId='\(id)'", callback: {[weak self] (_, error) in
            if let e = error {
                HUD.flash(.label(e.localizedDescription), delay: 2)
            } else {
                self?.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: .refreshState, object: nil)
            }
        })
    }
    
}
