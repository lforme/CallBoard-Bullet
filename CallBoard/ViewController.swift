//
//  ViewController.swift
//  CallBoard
//
//  Created by mugua on 2019/5/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    fileprivate var _statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    fileprivate var baseNavigationVC: BaseNavigationController?
    let privacyQuery = AVQuery(className: DatabaseKey.privacyTable)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self._statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AVUser.current() == nil {
            AVUser.loginAnonymously { (user, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    print(user ?? "")
                    NotificationCenter.default.post(name: .loginStateDidChnage, object: true)
                }
            }
        }
        
        
        NotificationCenter.default.rx.notification(.statuBarDidChnage)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                if let style = noti.object as? UIStatusBarStyle {
                    self?._statusBarStyle = style
                }
            }).disposed(by: rx.disposeBag)
        
        setupChildController()
        
        ServerHelper.shared.liveDataHasChanged.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (notification) in
            guard let block = notification else { return }
            let (_, object, _) = block
            guard let this = self else { return }
            
            
            guard let p = object as? AVObject else {
                return 
            }
            guard let isAlert = p.object(forKey: "isFristShow") as? Bool else {
                return
            }
            
            if isAlert {
                let privacyVC: PrivacyViewController = ViewLoader.Storyboard.controller(from: "Main")
                 this.present(privacyVC, animated: false, completion: nil)
            }
        }).disposed(by: rx.disposeBag)
        
        
        privacyQuery.findObjectsInBackground {[weak self] (object, _) in
            
            guard let privacy = object?.first as? AVObject, let isAlert = privacy.object(forKey: "isFristShow") as? Bool, let this = self else { return }
            
            if isAlert {
                let privacyVC: PrivacyViewController = ViewLoader.Storyboard.controller(from: "Main")
                this.present(privacyVC, animated: false, completion: nil)
            }
        }

        
    }
    
    func setupChildController() {
        
        let LabelVC: LabelViewController = ViewLoader.Storyboard.controller(from: "Main")
        baseNavigationVC = BaseNavigationController(rootViewController: LabelVC)
        self.view.addSubview(baseNavigationVC!.view)
        self.addChild(baseNavigationVC!)
    }
}

