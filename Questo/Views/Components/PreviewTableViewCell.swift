//
//  PreviewTableViewCell.swift
//  Questo
//
//  Created by Taichi Kato on 11/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit

class PreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var answer: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UI.addShadow(view: containerView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
