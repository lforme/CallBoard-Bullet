//
//  LabelCell.swift
//  CallBoard
//
//  Created by mugua on 2019/5/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import MarqueeLabel
import SnapKit

class LabelCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    var myLabel: MarqueeLabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 3
        bgView.backgroundColor = UIColor.randomFlat
        
        myLabel = MarqueeLabel(frame: .zero, duration: 8.0, fadeLength: 8)
        myLabel.textColor = ColorHelper.white.getColor()
        bgView.addSubview(myLabel)
        myLabel.font = UIFont.boldSystemFont(ofSize: 32)
        myLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(self.bgView.snp.centerY)
            maker.left.equalToSuperview().offset(8)
            maker.right.equalToSuperview().offset(-8)
        }
        
        myLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    
    func bindData(model: LabelModel) {
        myLabel.text = model.displayText
        myLabel.textColor = ColorHelper(rawValue: model.color)?.getColor()
        if let t = model.createTime {
            timeLabel.text = "创建时间: \(t)"
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
