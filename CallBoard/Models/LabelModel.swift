//
//  LabelModel.swift
//  CallBoard
//
//  Created by mugua on 2019/5/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift

class LabelModel {
    
    var userId: String?
    var style: Int = 0
    var speed: Int = 15
    var font: Int = 24
    var color: Int = 0
    var flashOn: Int = 0
    var displayText: String = "这是一段展示的话"
    var createTime: String?
    
    private let query = AVQuery(className: DatabaseKey.labelTable)
    
    init(userId: String) {
        self.userId = userId
    }
    
    func saveToServer() -> Observable<Bool> {
        
        return Observable<Bool>.create({[unowned self] (o) -> Disposable in
            let obj = AVObject(className: DatabaseKey.labelTable)
            obj.setObject(self.userId, forKey: "userId")
            obj.setObject(self.style, forKey: "style")
            obj.setObject(self.speed, forKey: "speed")
            obj.setObject(self.font, forKey: "font")
            obj.setObject(self.flashOn, forKey: "flashOn")
            obj.setObject(self.color, forKey: "color")
            obj.setObject(self.displayText, forKey: "displayText")
            
            obj.saveEventually { (success, error) in
                if let e = error {
                    o.onError(e)
                } else {
                    o.onNext(success)
                    o.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
    
    func fetchLabelMoels(page: Int = 0) -> Observable<[LabelModel]> {
        
        return Observable<[LabelModel]>.create({[unowned self] (o) -> Disposable in
            guard let id = self.userId else {
                return Disposables.create()
            }
            self.query.whereKey("userId", equalTo: id)
            self.query.order(byDescending: "createdAt")
            self.query.limit = 10
            self.query.skip = 10 * page
            self.query.cachePolicy = AVCachePolicy.networkElseCache
            
            self.query.findObjectsInBackground { (objs, error) in
                if let e = error {
                    o.onError(e)
                } else {
                    let entities = objs?.compactMap({ (elem) -> LabelModel? in
                        guard let dict = elem as? AVObject else { return nil }
                        guard let uid = dict["userId"] as? String,
                            let style = dict["style"] as? Int,
                            let speed = dict["speed"] as? Int,
                            let font = dict["font"] as? Int,
                            let color = dict["color"] as? Int,
                            let flashOn = dict["flashOn"] as? Int,
                            let displayText = dict["displayText"] as? String,
                            let time = dict.createdAt?.localString() else { return nil }
                        
                        let m = LabelModel(userId: uid)
                        m.style = style
                        m.speed = speed
                        m.font = font
                        m.color = color
                        m.flashOn = flashOn
                        m.displayText = displayText
                        m.createTime = time
                        return m
                    })
                    
                    o.onNext(entities ?? [])
                    o.onCompleted()
                }
            }
            
            return Disposables.create()
        })
        
    }
}
