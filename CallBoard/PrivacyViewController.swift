//
//  PrivacyViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/23.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift
import PKHUD


class PrivacyViewController: UIViewController {
    
    var privacyWeb: WKWebView!
    @IBOutlet weak var backButton: UIButton!
    
    var tiggerCount = BehaviorRelay<Int>(value: 0)
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            tiggerCount.accept(tiggerCount.value + 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tiggerCount.accept(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebVeiw()
        
        becomeFirstResponder()
        
        queryData()
        
        ServerHelper.shared.liveDataHasChanged.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (notification) in
            guard let block = notification else { return }
            let (_, object, _) = block
            guard let this = self else { return }
            
            guard let privacy = object as? AVObject, let isAlert = privacy.object(forKey: "isFristShow") as? Bool, let isShowButton = privacy.object(forKey: "backButtonHiden") as? Bool, let urlString = privacy.object(forKey: "privacyWebSite") as? String else { return }
            
            if let url = URL(string: urlString) {
                this.privacyWeb.load(URLRequest(url: url))
            } else {
                HUD.flash(.label("请设置正确的URL地址"), delay: 2)
            }
            
            if !isAlert {
                this.dismiss(animated: false, completion: nil)
            }
            this.backButton.isHidden = !isShowButton
            
            
            
        }).disposed(by: rx.disposeBag)
        
        changeEnvironment()
    }
    
    func setupWebVeiw() {
        let config = WKWebViewConfiguration()
        privacyWeb = WKWebView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 20), configuration: config)
        view.addSubview(privacyWeb)
        view.bringSubviewToFront(backButton)
    }
    
    func queryData() {
        let query = AVQuery(className: DatabaseKey.privacyTable)
        
        query.findObjectsInBackground {[weak self] (objs, _) in
            guard let this = self, let objc = objs?.first as? AVObject, let showButton = objc.object(forKey: "backButtonHiden") as? Bool, let urlString = objc.object(forKey: "privacyWebSite") as? String else { return }
            if let url = URL(string: urlString) {
                this.privacyWeb.load(URLRequest(url: url))
            } else {
                HUD.flash(.label("请设置正确的URL地址"), delay: 2)
            }
            this.backButton.isHidden = !showButton
        }
    }
    
    @IBAction func backTap(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    private func changeEnvironment() {
        tiggerCount.subscribe(onNext: {[weak self] (count) in
            if count == 3 {
                let alertVC = UIAlertController(title: "请输入管理员密码", message: nil, preferredStyle: .alert)
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入密码"
                    textField.keyboardType = .default
                }
                
                let confirmAction = UIAlertAction(title: "验证", style: .default) {[weak alertVC] (_) in
                    guard let alertController = alertVC, let textField = alertController.textFields?.first else { return }
                    
                    if textField.text == Keys.amdinPwd {
                        let changeVC: ChangeEnvironmentController = ViewLoader.Storyboard.controller(from: "Main")
                        self?.present(changeVC, animated: true, completion: nil)
                    }
                }
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertVC.addAction(confirmAction)
                alertVC.addAction(cancel)
                self?.present(alertVC, animated: true, completion: nil)
            }
        }).disposed(by: rx.disposeBag)
    }
}
