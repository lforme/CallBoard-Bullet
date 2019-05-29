//
//  TextCell.swift
//  CallBoard
//
//  Created by mugua on 2019/5/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class TextCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                self.label.backgroundColor = UIColor.white
                self.label.textColor = UIColor.flatBlack
            } else {
                self.label.backgroundColor = UIColor.clear
                self.label.textColor = UIColor.white
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.label.clipsToBounds = true

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.layer.cornerRadius = self.label.bounds.height / 2
        
    }
}
