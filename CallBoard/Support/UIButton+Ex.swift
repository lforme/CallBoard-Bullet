//
//  UIButton+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

extension UIButton {
    
    open func dgSetImage(_ image: UIImage?) {
        setImage(image, for: UIControl.State.normal)
        if let i = image {
            let disableColor = AverageColorFromImage(i).withAlphaComponent(0.4)
            setImage(i.filled(withColor: disableColor), for: UIControl.State.disabled)
        }
    }
    
    open func dgSetBackgroundImage(_ image: UIImage?) {
        setBackgroundImage(image, for: UIControl.State.normal)
        if let i = image {
            let disableColor = AverageColorFromImage(i).withAlphaComponent(0.4)
            setBackgroundImage(i.filled(withColor: disableColor), for: UIControl.State.disabled)
            let textDisableColor = titleLabel?.textColor!.withAlphaComponent(0.4)
            setTitleColor(textDisableColor, for: UIControl.State.disabled)
        }
    }
    
    func setupDgStyle() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    func underlineButton(text: String) {
        
        guard let l = self.titleLabel else {
            return
        }
        
        let yourAttributes : [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : l.font!,
            NSAttributedString.Key.foregroundColor : l.textColor!,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
        
        let attributeString = NSMutableAttributedString(string: text,
                                                        attributes: yourAttributes)
        setAttributedTitle(attributeString, for: .normal)
        
    }
    
    enum Position {
        case top, bottom, left, right
    }
    
    func set(image: UIImage?, title: String, titlePosition: Position, additionalSpacing: CGFloat, state: UIControl.State){
//        imageView?.contentMode = .center
        setImage(image, for: state)
        setTitle(title, for: state)
//        titleLabel?.contentMode = .center
        
        adjust(title: title as NSString, at: titlePosition, with: additionalSpacing)
        
    }
    
    func set(image: UIImage?, attributedTitle title: NSAttributedString, at position: Position, width spacing: CGFloat, state: UIControl.State){
        imageView?.contentMode = .center
        setImage(image, for: state)
        
        adjust(attributedTitle: title, at: position, with: spacing)
        
        titleLabel?.contentMode = .center
        setAttributedTitle(title, for: state)
    }
    
    private func adjust(title: NSString, at position: Position, with spacing: CGFloat) {
        let imageRect: CGRect = self.imageRect(forContentRect: frame)
        
        // Use predefined font, otherwise use the default
        let titleFont: UIFont = titleLabel?.font ?? UIFont()
        let titleSize: CGSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont])
        
        arrange(titleSize: titleSize, imageRect: imageRect, atPosition: position, withSpacing: spacing)
    }
    
    private func adjust(attributedTitle: NSAttributedString, at position: Position, with spacing: CGFloat) {
        let imageRect: CGRect = self.imageRect(forContentRect: frame)
        let titleSize = attributedTitle.size()
        
        arrange(titleSize: titleSize, imageRect: imageRect, atPosition: position, withSpacing: spacing)
    }
    
    private func arrange(titleSize: CGSize, imageRect:CGRect, atPosition position: Position, withSpacing spacing: CGFloat) {
        switch (position) {
        case .top:
            titleEdgeInsets = UIEdgeInsets(top: -(imageRect.height + titleSize.height + spacing), left: -(imageRect.width), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
            contentEdgeInsets = UIEdgeInsets(top: spacing / 2 + titleSize.height, left: -imageRect.width/2, bottom: 0, right: -imageRect.width/2)
        case .bottom:
            titleEdgeInsets = UIEdgeInsets(top: (imageRect.height + titleSize.height + spacing), left: -(imageRect.width), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: -imageRect.width/2, bottom: spacing / 2 + titleSize.height, right: -imageRect.width/2)
        case .left:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageRect.width * 2), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -(titleSize.width * 2 + spacing))
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing / 2)
        case .right:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing / 2)
        }
    }
    
}
