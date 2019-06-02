//
//  ServerHelper.swift
//  CallBoard
//
//  Created by mugua on 2019/5/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ServerHelper: NSObject {
    
    public typealias DataChangedNotification = (AVLiveQuery, object: AnyObject, updatedKeys: [String]?)
    
    public static let shared = ServerHelper()
    public var liveDataHasChanged = BehaviorRelay<DataChangedNotification?>(value: nil)
    public var adminPwd: String?
    
    /////////// 私有属性 私有方法/////////////////
    fileprivate var doingLiveQuery: AVLiveQuery?
    fileprivate var notificationBlock: DataChangedNotification?
    fileprivate let query = AVQuery(className: DatabaseKey.privacyTable)
    
    @discardableResult
    override init() {
        super.init()
        
        AVOSCloud.setApplicationId(Keys.leanCloudId, clientKey: Keys.leanCloudClentKey)
        self.doingLiveQuery = AVLiveQuery(query: query)
        self.doingLiveQuery?.subscribe(callback: { (s, error) in })
        self.doingLiveQuery?.delegate = self
        getAdminPwd()
    }
    
    
    func unsubscribe() {
        self.doingLiveQuery?.unsubscribe(callback: { (_, _) in
        })
    }
    
    func updatePrivacy(url: String, isFristShow: Bool = false, backButtonHiden: Bool = false) {
        let q = AVQuery(className: DatabaseKey.privacyTable)
        q.getFirstObjectInBackground { (obj, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            
            obj?.setObject(url, forKey: "privacyWebSite")
            obj?.setObject(isFristShow, forKey: "isFristShow")
            obj?.setObject(backButtonHiden, forKey: "backButtonHiden")
            obj?.saveInBackground()
        }
    }
    
    func createdPrivacyModel() {
        let objc = AVObject(className: DatabaseKey.privacyTable)
        objc.setObject("http://www.gaygaybar.cn", forKey: "privacyWebSite")
        objc.setObject(false, forKey: "isFristShow")
        objc.setObject(false, forKey: "backButtonHiden")
        objc.saveInBackground()
    }
    
    func makeAdminPwd() {
        let objc = AVObject(className: DatabaseKey.amdinPwdTable)
        objc.setObject(Bundle.main.bundleIdentifier, forKey: "bundleIdentifier")
        objc.setObject("bbqqdd123", forKey: "amdinPwd")
        objc.saveEventually()
    }
    
    private func getAdminPwd() {
        let q = AVQuery(className: DatabaseKey.amdinPwdTable)
        q.whereKey("bundleIdentifier", equalTo: Bundle.main.bundleIdentifier ?? "com.why.CallBoard")
        q.getFirstObjectInBackground {[unowned self] (objc, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                self.adminPwd = objc?.object(forKey: "amdinPwd") as? String
            }
        }
    }
    
}

extension ServerHelper: AVLiveQueryDelegate {
    
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidCreate object: Any) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, nil))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidUpdate object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidDelete object: Any) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, nil))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidEnter object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidLeave object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, userDidLogin user: AVUser) {
        liveDataHasChanged.accept((liveQuery, user, nil))
    }
}
