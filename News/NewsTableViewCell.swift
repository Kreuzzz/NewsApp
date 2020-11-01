//
//  NewsTableViewCell.swift
//  News
//
//  Created by Maxim Lebedev on 27.10.2020.
//  Copyright © 2020 Lebedev Maxim. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel:UILabel! {
        didSet {
            titleLabel.numberOfLines = 3
        }
    }
    
    @IBOutlet weak var dateLabel:UILabel!
    
    
    
    var item: RSSItem!
    func configure(title: String, pudDate: String) {
        titleLabel.text = title
        dateLabel.text = pudDate
    }
    
}
