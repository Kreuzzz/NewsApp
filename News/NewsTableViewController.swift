//
//  NewsTableViewController.swift
//  News
//
//  Created by Maxim Lebedev on 27.10.2020.
//  Copyright © 2020 Lebedev Maxim. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet var table: UITableView!
    
    private var selectedCategory = String()
    private var isSorted = false
    private var sortedItems = [RSSItem]()
    private var setOfCategory = Set<String>()
    private var rssItems: [RSSItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.refreshControl = myRefreshControl
        tableView.estimatedRowHeight = 155.0
        tableView.rowHeight = UITableView.automaticDimension
        
        fetchData()
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        title = "News"
        isSorted = false
        fetchData()
        table.reloadData()
        sender.endRefreshing()
    }
    @IBAction func sorting(_ sender: UIBarButtonItem) {
        createPickerViewOfCategories()
    }
    
    private func fetchData(){
        let feedParser = FeedParser()
        feedParser.parseFeed(url: "https://www.vesti.ru/vesti.rss") { (rssItems, setOfCategory) in
            self.rssItems = rssItems
            self.setOfCategory = setOfCategory
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSorted ? sortedItems.count : rssItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? NewsTableViewCell else {
            fatalError("Cast to cell is unavailable")
        }
        guard !isSorted else {
            let sortedDate = sortedItems[indexPath.row].pubDate.replacingOccurrences(of: ":00 +0300", with: "")
            cell.configure(title: sortedItems[indexPath.row].title, pudDate: sortedDate)
            return cell
        }
        let itemDate = rssItems[indexPath.row].pubDate.replacingOccurrences(of: ":00 +0300", with: "")
        cell.configure(title: rssItems[indexPath.row].title, pudDate: itemDate)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let imageVC = storyboard?.instantiateViewController(
            withIdentifier: "goToOneNews"
            ) as? OneNewsViewController  else {
                fatalError("TableView setup is not correct!")
        }
        guard isSorted || rssItems[indexPath.row].enclouser[0].isEmpty else {
            imageVC.setItem(item: rssItems[indexPath.row])
            self.navigationController?.pushViewController(imageVC, animated: true)
            return
        }
        guard !isSorted || sortedItems[indexPath.row].enclouser[0].isEmpty else {
            imageVC.setItem(item: sortedItems[indexPath.row])
            self.navigationController?.pushViewController(imageVC, animated: true)
            return
        }
        guard let NoImageVC = storyboard?.instantiateViewController(
            withIdentifier: "goToOneNewsNoImage"
            ) as? NoImageViewController else {
                fatalError("TableView setup is not correct!")
        }
        guard isSorted || !rssItems[indexPath.row].enclouser[0].isEmpty else {
            NoImageVC.setItem(item: rssItems[indexPath.row])
            self.navigationController?.pushViewController(NoImageVC, animated: true)
            return
        }
        guard !isSorted || !sortedItems[indexPath.row].enclouser[0].isEmpty else {
            NoImageVC.setItem(item: sortedItems[indexPath.row])
            self.navigationController?.pushViewController(NoImageVC, animated: true)
            return
        }
    }
    
    private func createPickerViewOfCategories() {
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 400, height: 250)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 400, height: 250))
        pickerView.delegate = self
        pickerView.dataSource = self
        viewController.view.addSubview(pickerView)
        let alertController = UIAlertController(title: "Выберите категорию", message: "", preferredStyle: .actionSheet)
        alertController.setValue(viewController, forKey: "contentViewController")
        alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.sortedItems = self.rssItems.filter { $0.category == self.selectedCategory }
            self.isSorted = true
            self.title = self.selectedCategory
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
}

extension NewsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return setOfCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(setOfCategory)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = Array(setOfCategory)[row]
    }
    
}




