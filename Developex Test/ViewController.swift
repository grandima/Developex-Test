//
//  ViewController.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/21/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var maxDownloadsTextField: UITextField!
    @IBOutlet weak var textToFindTextField: UITextField!
    @IBOutlet weak var maxURLTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTableView(_:)), name: "OccuranceUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateStatusLabel(_:)), name: "Finished", object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        if sender is UIButton {
            CrawlManager.sharedManager.start(Settings.startURL)
            statusLabel.text = "Started"
        }
        
    }
    @IBAction func stopButtonPressed(sender: AnyObject) {
        if sender is UIButton {
            CrawlManager.sharedManager.stop()
            statusLabel.text = "Stopped"
        }
    }
    
    func updateTableView(notification: NSNotification) {
        tableView.reloadData()
    }
    func updateStatusLabel(notification: NSNotification) {
        statusLabel.text = "Finished"
    }

}


extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CrawlManager.sharedManager.results.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Identifier") as! TableViewCell
        cell.configure(CrawlManager.sharedManager.results[indexPath.row])
        return cell
    }
    
}

