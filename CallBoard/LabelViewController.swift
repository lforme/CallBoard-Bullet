//
//  LabelViewController.swift
//  CallBoard
//
//  Created by mugua on 2019/5/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

class LabelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: MoveButton!
    var tiggerCount = BehaviorRelay<Int>(value: 0)
    private var page = 0
    var vm: LabelModel!
    var datasource: [LabelModel] = []
    
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
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let userId = AVUser.current()?.objectId {
            vm = LabelModel(userId: "5cee15a17b968a00767fbcc5")
//        }
        
        ColorHelper.changeStatusBarStyle(.lightContent)
        title = "弹幕列表"
        setupTableView()
        changeEnvironment()
        becomeFirstResponder()
        
        AVUser.loginAnonymously { (user, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                print(user ?? "")
                NotificationCenter.default.post(name: .loginStateDidChnage, object: true)
            }
        }
        
        NotificationCenter.default.rx.notification(.refreshState)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
                self?.tableView.mj_header.beginRefreshing()
            }).disposed(by: rx.disposeBag)
    }
    
    func setupTableView() {
        tableView.rowHeight = 100
        tableView.register(UINib.init(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.flatBlack
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] in
            self.vm.fetchLabelMoels(page: 0).subscribe(onNext: { (data) in
                self.datasource = data
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
            }, onError: { (error) in
                HUD.flash(.label(error.localizedDescription), delay: 2)
            }).disposed(by: self.rx.disposeBag)
        })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[unowned self] in
            self.page += 1
            self.vm.fetchLabelMoels(page: self.page).subscribe(onNext: { (models) in
                self.datasource += models
                if models.count == 0 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                self.tableView.reloadData()
            }, onError: { (error) in
                HUD.flash(.label(error.localizedDescription), delay: 2)
            }).disposed(by: self.rx.disposeBag)
           
        })
        
        tableView.mj_header.beginRefreshing()

    }
    
    
    @IBAction func addTap(_ sender: MoveButton) {
        let addVC: AddDanMuController = ViewLoader.Storyboard.controller(from: "Main")
        navigationController?.pushViewController(addVC, animated: true)
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
                        self?.navigationController?.pushViewController(changeVC, animated: true)
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



extension LabelViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
        let item = datasource[indexPath.row]
        cell.bindData(model: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = datasource[indexPath.row]
        let displayVC: DisplayController = ViewLoader.Storyboard.controller(from: "Main")
        
        displayVC.model = item
        navigationController?.pushViewController(displayVC, animated: true)
    }
}


