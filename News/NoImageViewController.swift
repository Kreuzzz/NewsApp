//
//  NoImageViewController.swift
//  News
//
//  Created by Maxim Lebedev on 30.10.2020.
//  Copyright © 2020 Lebedev Maxim. All rights reserved.
//

import UIKit

class NoImageViewController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelDescription: UILabel!
    
    var rssItem: RSSItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitle.text = rssItem?.title
        labelDescription.text = rssItem?.description
        
    }
    func setItem(item: RSSItem) {
        self.rssItem = item
    }
    
}
