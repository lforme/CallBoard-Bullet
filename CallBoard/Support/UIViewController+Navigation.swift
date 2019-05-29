//
//  UIViewController+Navigation.swift
//  Dingo
//
//  Created by mugua on 2019/5/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    override open var next: UIResponder? {
        UIViewController.awake
        return super.next
    }
}


private var interactiveNavigationBarHiddenAssociationKey: UInt8 = 0
extension UIViewController {
    
    private static let _currentNavigationBarColor = ObjectAssociation<UIColor>()
    
    public var currentNavigationBarColor: UIColor? {
        get {
            return UIViewController._currentNavigationBarColor[self]
        }
        set {
            UIViewController._currentNavigationBarColor[self] = newValue
            navigationController?.navigationBar.barTintColor = newValue
        }
    }
    
    
    @IBInspectable public var interactiveNavigationBarHidden: Bool {
        get {
            var associateValue = objc_getAssociatedObject(self, &interactiveNavigationBarHiddenAssociationKey)
            if associateValue == nil {
                associateValue = false
            }
            return associateValue as! Bool;
        }
        set {
            objc_setAssociatedObject(self, &interactiveNavigationBarHiddenAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate static let awake : Void  = {
        replaceInteractiveMethods()
        return
    }()
    
    fileprivate static func replaceInteractiveMethods() {
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(UIViewController.viewWillAppear(_:)))!,
            class_getInstanceMethod(self, #selector(UIViewController.cb_interactiveViewWillAppear(_:)))!)
        
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(UIViewController.viewDidLoad))!,
            class_getInstanceMethod(self, #selector(UIViewController.cb_swizzled_viewDidLoad))!
        )
    }
    
    
    @objc func cb_interactiveViewWillAppear(_ animated: Bool) {
        cb_interactiveViewWillAppear(animated)
        navigationController?.setNavigationBarHidden(interactiveNavigationBarHidden, animated: animated)
    }
    
    @objc func leftNavigationItemAction() {
        let parentVC = self.navigationController?.popViewController(animated: true)
        guard let p = parentVC else {
            return
        }
        p.dismiss(animated: true, completion: nil)
    }
    
    @objc func cb_swizzled_viewDidLoad() {
        cb_swizzled_viewDidLoad()
        if (self is UINavigationController) && (self is UIImagePickerController) {
            return
        }
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
            let img = UIImage(named: "back_button_icon")?.filled(withColor: UIColor.white)
            
            button.setImage(img, for: .normal)
            button.contentMode = .left
            button.addTarget(self, action: #selector(leftNavigationItemAction), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
}

