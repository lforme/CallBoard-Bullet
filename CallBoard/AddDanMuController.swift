//
//  AddDanMuController.swift
//  CallBoard
//
//  Created by mugua on 2019/5/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD
import AlignedCollectionViewFlowLayout
import RxDataSources
import MarqueeLabel
import LTMorphingLabel
import AVFoundation
import Action

class AddDanMuController: UITableViewController {
    
    @IBOutlet weak var styleCollection: UICollectionView!
    @IBOutlet weak var speedCollection: UICollectionView!
    @IBOutlet weak var fontCollection: UICollectionView!
    @IBOutlet weak var colorCollection: UICollectionView!
    @IBOutlet weak var flashSwitch: UISwitch!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textfield: UITextField!
    
    
    let marLabel = MarqueeLabel(frame: .zero, duration: 12, fadeLength: 60)
    var ltmLabel: LTMorphingLabel?
    
    var styleCVDatasource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, SettingModel>>!
    var speedCVDatasource: [SettingModel] = []
    var fontCVDatasource: [SettingModel] = []
    var colorCVDatasource: [SettingModel] = []

    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
    
    var postModel: LabelModel!
    var saveAction: Action<LabelModel?, Bool>!
    
    deinit {
        print("Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = AVUser.current()?.objectId {
            postModel = LabelModel(userId: id)
        }
        
        title = "添加弹幕"
        tableView.tableFooterView = UIView(frame: .zero)
        setupCV()
        setupStyleCollection()
        setupSpeedCollectionView()
        setupSpeedCollectionView()
        setupFontCollectionView()
        setupColorCollectionView()
        setupDisplayLabel()
        observeBlock()
        setupSwitch()
        setupTextfield()
        
        setupRightNavigationItem()
        
    }
    
    func setupTextfield() {
        
        textfield.rx.text.orEmpty.distinctUntilChanged().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (text) in
            self?.postModel.displayText = text
        }).disposed(by: rx.disposeBag)
    }
    
    func setupRightNavigationItem() {
        saveAction = Action<LabelModel?, Bool>(workFactory: { (post) -> Observable<Bool> in
            guard let p = post else {
                return Observable.error(APPCommonError.msg("出错了"))
            }
            return p.saveToServer()
        })
        let button = createdRightNavigationItem(title: "保存", image: nil)
        
        button.rx.bind(to: saveAction) {[weak self] (_) -> LabelModel? in
            guard let this = self else {
                return nil
            }
            return this.postModel
        }
        
        saveAction.executing.bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: rx.disposeBag)
        saveAction.errors.actionErrorShiftError().bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
        saveAction.elements.subscribe(onNext: {[weak self] (s) in
            if s {
                NotificationCenter.default.post(name: .refreshState, object: nil)
                self?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func observeBlock() {
        
        GlobalConfiguration.shared.hasChangeBlock {[unowned self] (config) in
            
            self.postModel.style = config.style.value
            self.postModel.font = config.font.value
            self.postModel.color = config.color.value
            self.postModel.speed = config.speed.value
            self.postModel.flashOn = config.flash.value
            
            if config.style.value == 0 {
                self.marLabel.isHidden = false
                self.ltmLabel?.isHidden = true
            } else {
                self.marLabel.isHidden = true
                
                switch config.style.value {
                case 1:
                    self.setupLTMLabel(effect: .scale)
                case 2:
                    self.setupLTMLabel(effect: .evaporate)
                case 3:
                    self.setupLTMLabel(effect: .fall)
                case 4:
                    self.setupLTMLabel(effect: .pixelate)
                case 5:
                    self.setupLTMLabel(effect: .sparkle)
                case 6:
                    self.setupLTMLabel(effect: .burn)
                case 7:
                    self.setupLTMLabel(effect: .anvil)
                default: break
                }
            }
            
            self.marLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(config.font.value))
            self.ltmLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(config.font.value))
            
            self.marLabel.textColor = ColorHelper(rawValue: config.color.value)?.getColor()
            self.ltmLabel?.textColor = ColorHelper(rawValue: config.color.value)?.getColor()
            
            self.marLabel.speed = .duration(CGFloat(config.speed.value))
            self.ltmLabel?.morphingDuration = Float(config.speed.value)
            self.marLabel.restartLabel()
        }
    }
    
    func setupDisplayLabel() {
        marLabel.text = "这是一段测试文字, 可以很长很长, 可以很长很长"
        marLabel.font = UIFont.boldSystemFont(ofSize: 24)
        marLabel.textColor = UIColor.white
        marLabel.textAlignment = .center
        marLabel.isHidden = false
        
        bgView.addSubview(marLabel)
        
        marLabel.snp.makeConstraints { (maker) in
            maker.center.equalTo(self.bgView)
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
        }
    }
    
    func setupLTMLabel(effect: LTMorphingEffect) {
        ltmLabel?.stop()
        ltmLabel?.removeFromSuperview()
        ltmLabel = nil
        ltmLabel = LTMorphingLabel(frame: .zero)
        ltmLabel?.numberOfLines = 0
        ltmLabel?.isHidden = false
        ltmLabel?.morphingEffect = effect
        bgView.addSubview(ltmLabel!)
        ltmLabel!.snp.makeConstraints { (maker) in
            maker.center.equalTo(self.bgView)
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
        }
        
        ltmLabel?.text = "这是一段测试文字"
        ltmLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        ltmLabel?.textColor = UIColor.white
        ltmLabel?.textAlignment = .center
    }
    
    
    func setupSwitch() {
        
        GlobalConfiguration.shared.flash = ("闪光灯", 0)
        flashSwitch.rx.value.observeOn(MainScheduler.instance).subscribe(onNext: { (isOn) in
            GlobalConfiguration.shared.flash = ("闪光灯", isOn ? 1 : 0)
            if isOn {
                self.device?.setTorch(intensity: 1)
            } else {
                self.device?.setTorch(intensity: 0)
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    func setupCV() {
        
        [styleCollection, speedCollection, fontCollection, colorCollection].forEach { (cv) in
            
            let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .justified, verticalAlignment: .center)
            alignedFlowLayout.estimatedItemSize = CGSize(width: 60, height: 60)
            alignedFlowLayout.minimumLineSpacing = 10
            alignedFlowLayout.minimumInteritemSpacing = 10
            alignedFlowLayout.scrollDirection = .horizontal
            
            cv?.backgroundColor = UIColor.clear
            cv?.register(UINib(nibName: "TextCell", bundle: nil), forCellWithReuseIdentifier: "TextCell")
            cv?.collectionViewLayout = alignedFlowLayout
            cv?.contentInset = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        }
    }
    
    func setupStyleCollection() {
        
        styleCVDatasource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, SettingModel>>(configureCell: { (ds, cv, ip, item) -> TextCell in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "TextCell", for: ip) as! TextCell
            cell.label.text = item.itemName
            cell.isSelected = item.select
            return cell
        })
        
        let model0 = SettingModel(type: 0, itemName: "滚动", value: 0)
        let model1 = SettingModel(type: 0, itemName: "缩放", value: 1)
        let model2 = SettingModel(type: 0, itemName: "蒸发", value: 2)
        let model3 = SettingModel(type: 0, itemName: "掉落", value: 3)
        let model4 = SettingModel(type: 0, itemName: "像素", value: 4)
        let model5 = SettingModel(type: 0, itemName: "闪耀", value: 5)
        let model6 = SettingModel(type: 0, itemName: "燃烧", value: 6)
        let model7 = SettingModel(type: 0, itemName: "气化", value: 7)
        
        let models = [model0, model1, model2, model3, model4, model5, model6, model7]
        let temp = [SectionModel<String, SettingModel>(model: "样式", items: models)]
        
        Observable.just(temp).bind(to: styleCollection.rx.items(dataSource: styleCVDatasource)).disposed(by: rx.disposeBag)
        
        Observable.zip(styleCollection.rx.itemSelected, styleCollection.rx.modelSelected(SettingModel.self)) {($0, $1) }.bind { (ip, item) in
            
            GlobalConfiguration.shared.style = (item.itemName, item.value)
            
            }.disposed(by: rx.disposeBag)
    }
    
    func setupSpeedCollectionView() {
        
        speedCollection.dataSource = self
        speedCollection.delegate = self
        
        let model0 = SettingModel(type: 1, itemName: "慢速", value: 15)
        let model1 = SettingModel(type: 1, itemName: "中速", value: 8)
        let model2 = SettingModel(type: 1, itemName: "快速", value: 4)
        let model3 = SettingModel(type: 1, itemName: "超快", value: 2)
        speedCVDatasource = [model0, model1, model2, model3]
    }
    
    func setupFontCollectionView() {
        
        fontCollection.dataSource = self
        fontCollection.delegate = self
        
        let model0 = SettingModel(type: 2, itemName: "24", value: 24)
        let model1 = SettingModel(type: 2, itemName: "36", value: 36)
        let model2 = SettingModel(type: 2, itemName: "48", value: 48)
        let model3 = SettingModel(type: 2, itemName: "64", value: 64)
        let model4 = SettingModel(type: 2, itemName: "72", value: 72)
        let model5 = SettingModel(type: 2, itemName: "108", value: 108)
        fontCVDatasource = [model0, model1, model2, model3, model4, model5]
    }
    
    func setupColorCollectionView() {
        
        colorCollection.dataSource = self
        colorCollection.delegate = self
        
        let model0 = SettingModel(type: 3, itemName: "", value: 0)
        let model1 = SettingModel(type: 3, itemName: "", value: 1)
        let model2 = SettingModel(type: 3, itemName: "", value: 2)
        let model3 = SettingModel(type: 3, itemName: "", value: 3)
        let model4 = SettingModel(type: 3, itemName: "", value: 4)
        let model5 = SettingModel(type: 3, itemName: "", value: 5)
        let model6 = SettingModel(type: 3, itemName: "", value: 6)
        let model7 = SettingModel(type: 3, itemName: "", value: 7)
        let model8 = SettingModel(type: 3, itemName: "", value: 8)
        let model9 = SettingModel(type: 3, itemName: "", value: 9)
        let model10 = SettingModel(type: 3, itemName: "", value: 10)
        let model11 = SettingModel(type: 3, itemName: "", value: 11)
        
        colorCVDatasource = [model0, model1, model2, model3, model4, model5, model6, model7, model8, model9, model10, model11]
    }
}

extension AddDanMuController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == colorCollection {
            let item = colorCVDatasource[indexPath.item]
            let cell = colorCollection.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            cell.label.text = item.itemName
            cell.isSelected = item.select
            cell.backgroundColor = ColorHelper(rawValue: item.value)?.getColor()
            
            return cell
        }
        
        if collectionView == speedCollection {
            let item = speedCVDatasource[indexPath.item]
            let cell = speedCollection.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            cell.label.text = item.itemName
            cell.isSelected = item.select
            return cell
        }
        
        if collectionView == fontCollection {
            let item = fontCVDatasource[indexPath.item]
            let cell = fontCollection.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            cell.label.text = item.itemName
            cell.isSelected = item.select
            return cell
        }
        
        fatalError()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == speedCollection {
            
            return speedCVDatasource.count
        }
        
        if collectionView == fontCollection {
            
            return fontCVDatasource.count
        }
        
        if collectionView == colorCollection {
            
            return colorCVDatasource.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == speedCollection {
            var item = speedCVDatasource[indexPath.item]
            item.select = true
            GlobalConfiguration.shared.speed = (item.itemName, item.value)
        }
        
        if collectionView == fontCollection {
            var item = fontCVDatasource[indexPath.item]
            item.select = true
            GlobalConfiguration.shared.font = (item.itemName, item.value)
        }
        
        if collectionView == colorCollection {
            var item = colorCVDatasource[indexPath.item]
            item.select = true
            GlobalConfiguration.shared.color = (item.itemName, item.value)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == speedCollection {
            var item = speedCVDatasource[indexPath.item]
            item.select = false
            
        }
        
        if collectionView == fontCollection {
            var item = fontCVDatasource[indexPath.item]
            item.select = false
        }
        
        if collectionView == colorCollection {
            var item = colorCVDatasource[indexPath.item]
            item.select = false
        }
    }
}


