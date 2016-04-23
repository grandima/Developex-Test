//
//  TableViewCell.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/23/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configure(representable: ViewRepresentable) {
        urlLabel.text = representable.urlRepresentable
        statusLabel.text = representable.statusRepresentable
    }
}
