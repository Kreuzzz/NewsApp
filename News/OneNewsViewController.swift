//
//  OneNewsViewController.swift
//  News
//
//  Created by Maxim Lebedev on 29.10.2020.
//  Copyright © 2020 Lebedev Maxim. All rights reserved.
//

import UIKit
import Kingfisher

class OneNewsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    var rssItem: RSSItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitle.text = rssItem?.title
        labelDescription.text = rssItem?.description
        guard let itemImage = rssItem?.enclouser[0] else { return }
        let url = URL(string: itemImage)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url)
    }
    func setItem(item: RSSItem) {
        self.rssItem = item
    }
}
