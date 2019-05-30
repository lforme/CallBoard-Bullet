//
//  ChangeEnvironmentController.swift
//  CallBoard
//
//  Created by mugua on 2019/5/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import PKHUD

class ChangeEnvironmentController: UITableViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    typealias ChangeEnvironmentInput = (String, Bool)
    
    var postModel: AVObject?
    var saveAtion: Action<ChangeEnvironmentInput, Bool>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)
        fetchCloudData()
        bindRx()
    }
    
    func fetchCloudData() {
     let shareSig = Observable<AVObject?>.create { (ob) -> Disposable in
            
            let q = AVQuery(className: DatabaseKey.privacyTable)
            q.getFirstObjectInBackground {[unowned self] (obj, error) in
                if let e = error {
                    ob.onError(e)
                    print(e.localizedDescription)
                } else {
                    self.postModel = obj
                    ob.onNext(obj)
                    ob.onCompleted()
                }
            }
            return Disposables.create()
        }.share()
        
        shareSig.map { (obj) -> String? in
           return obj?.object(forKey: "privacyWebSite") as? String
        }.bind(to: textField.rx.text).disposed(by: rx.disposeBag)
        
        shareSig.map { (obj) -> Bool in
            guard let isShow = obj?.object(forKey: "isFristShow") as? Bool else {
                return false
            }
            return isShow
        }.bind(to: mySwitch.rx.value).disposed(by: rx.disposeBag)
        
    }
    
    func bindRx() {
        let buttonEnable = textField.rx.text.orEmpty.distinctUntilChanged().map { !$0.isEmpty }
        
        saveAtion = Action<ChangeEnvironmentInput, Bool>(enabledIf: buttonEnable, workFactory: {[weak self] (input) -> Observable<Bool> in
            guard let this = self else {
                return Observable.error(APPCommonError.msg("出错了"))
                
            }
            
            this.postModel?.setObject(input.0, forKey: "privacyWebSite")
            this.postModel?.setObject(input.1, forKey: "isFristShow")
            
            return Observable<Bool>.create({ (ob) -> Disposable in
                
                this.postModel?.saveInBackground({ (s, error) in
                    if let e = error {
                        ob.onError(e)
                    } else {
                        ob.onNext(s)
                        ob.onCompleted()
                    }
                })
                return Disposables.create()
            })
        })
        
        saveButton.rx.bind(to: saveAtion) {[unowned self] (_) -> ChangeEnvironmentInput in
            return ChangeEnvironmentInput(self.textField.text!, self.mySwitch.isOn)
        }
        
        saveAtion.executing.observeOn(MainScheduler.instance).bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: rx.disposeBag)
        saveAtion.errors.actionErrorShiftError().observeOn(MainScheduler.instance).bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
        
        saveAtion.elements.observeOn(MainScheduler.instance).subscribe(onNext: {[unowned self] (success) in
            if success {
                HUD.flash(.label("更换成功"), delay: 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1, execute: {
                    if let n = self.navigationController {
                        n.popViewController(animated: true)
                    } else {
                      self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }).disposed(by: rx.disposeBag)
    }
}
