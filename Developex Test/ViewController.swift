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
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround() 
        configureInitialData()
        tableView.estimatedRowHeight = 44
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTableView(_:)), name: Occurrence.updateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateStatusLabel(_:)), name: CrawlManager.statusNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(progressChanged(_:)), name: CrawlManager.progressChangedNotification, object: nil)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        guard let button = sender as? UIButton else { return }
        switch button {
        case startButton:
            stopButton.enabled = true
            pauseButton.enabled = true
            startButton.enabled = false
            pauseButton.setTitle("Pause", forState: .Normal)
            statusLabel.text = "In Process"
            enableTextFields(false)
            setProgressForViews(0)
            manager.start(Settings.sharedSettings.startURL)
        case pauseButton:
            if pauseButton.titleLabel?.text == "Unpause" {
                pauseButton.setTitle("Pause", forState: .Normal)
                statusLabel.text = "In Process"
                manager.resume()
            }else {
                pauseButton.setTitle("Unpause", forState: .Normal)
                manager.pause()
            }
        case stopButton:
            stopButton.enabled = false
            pauseButton.enabled = false
            manager.stop()
            
        default: break
        }
    }
    
    func updateTableView(notification: NSNotification) {
        tableView.reloadData()
    }
    func updateStatusLabel(notification: NSNotification) {
        guard let status = notification.userInfo?["status"] as? String else { return }
        
        statusLabel.text = status
        
        switch status {
        case "Stoping": setEnabledButtons(false)
        case "Pausing": setEnabledButtons(false)
        case "Paused":
            startButton.enabled = false
            pauseButton.enabled = true
            
            stopButton.enabled = true
        case "Stopped":
            startButton.enabled = true
            setProgressForViews(0)
            statusLabel.text = "Stopped"
            enableTextFields(true)
        case "Finished":
            pauseButton.enabled = false
            stopButton.enabled = false
            startButton.enabled = true
            enableTextFields(true)
            setProgressForViews(1)
        default: break
        }
    }
    
    @IBAction func textDidChanged(sender: AnyObject) {
        guard let textField = sender as? UITextField else { return }
        guard let text = textField.text else { startButton.enabled = false; return }
        switch textField {
            
        case urlTextField:
            let regex = "http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            let condition = predicate.evaluateWithObject(sender.text)
            if condition {
                settings.startURL = text
                startButton.enabled = true
            } else { setEnabledButtons(false) }
            
            
        case maxDownloadsTextField:
            guard let number = Int(text) else { startButton.enabled = false; return }
            if number > 0 {
                settings.maxConcurrentOperationCount = number
                startButton.enabled = true
            } else { setEnabledButtons(false) }
            
        case textToFindTextField:
            settings.textToFind = text
            startButton.enabled = true
            
        case maxURLTextField:
            guard let number = Int(text) else { startButton.enabled = false; return }
            if number > 0 {
                settings.maxURLNumber = number
                startButton.enabled = true
            } else { setEnabledButtons(false) }
            
        default: startButton.enabled = false
        
        }
    }
    
    func progressChanged(notification: NSNotification) {
        let max = Settings.sharedSettings.maxURLNumber
        let count = CrawlManager.sharedManager.results.countForStatus(forStatus: .Finished(.NotFound))
        let result = Float(count)/Float(max)
        setProgressForViews(result)
    }
    
    func setProgressForViews(result: Float) {
        progressView.setProgress(result, animated: true)
        progressLabel.text = "\(Int(result*100))" + " %"
    }
    
    //MARK: - Private
    
    private var manager = CrawlManager.sharedManager
    private var settings = Settings.sharedSettings
    private func configureInitialData() {
        settings.startURL = "http://stackoverflow.com/questions/28915954/nsattributedstring-initwithdata-and-nshtmltextdocumenttype-crash-if-not-on-main"
        urlTextField.text = settings.startURL
        
        settings.maxConcurrentOperationCount = 5
        maxDownloadsTextField.text = String(settings.maxConcurrentOperationCount)
        
        settings.textToFind = "Objective-C"
        textToFindTextField.text = settings.textToFind

        settings.maxURLNumber = 100
        maxURLTextField.text = String(settings.maxURLNumber)
    }
    private func setEnabledButtons(enabled: Bool) {
        startButton.enabled = enabled
        pauseButton.enabled = enabled
        stopButton.enabled = enabled
    }
    private func enableTextFields(enabled: Bool) {
        urlTextField.enabled = enabled
        maxDownloadsTextField.enabled = enabled
        textToFindTextField.enabled = enabled
        maxURLTextField.enabled = enabled
    }
    
    
}

extension ViewController: UITableViewDelegate {}

extension ViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Occurrences"
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

extension ViewController: UITextFieldDelegate {
    
}

