//
//  ViewController.swift
//  homework
//
//  Created by picopeak on 15/10/3.
//  Copyright © 2015年 fushan. All rights reserved.
//

import UIKit

extension NSDate {
    func dayofWeek() -> String {
        let interval = self.timeIntervalSince1970
        let days = Int(interval / 86400)
        switch ((days - 3) % 7) {
        case 0: return "日"
        case 1: return "一"
        case 2: return "二"
        case 3: return "三"
        case 4: return "四"
        case 5: return "五"
        case 6: return "六"
        default: return ""
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var DateLabel: UILabel!
    var frame: CGRect = CGRectMake(0, 0, 0, 0)
    var subView:[UITableView] = []
    var datasource:[MyData] = []

    func getToday() -> String {
        let td: NSDate = NSDate()
        let dateformatter: NSDateFormatter = NSDateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        
        return dateformatter.stringFromDate(td) + " (" + String(td.dayofWeek()) + ")"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DateLabel.text = getToday()

        for index in 0 ..< 3 {
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            // Create table view
            subView.append(UITableView(frame: frame))
            datasource.append(MyData(id: index))
            subView[index].dataSource = datasource[index]
            subView[index].separatorInset = UIEdgeInsetsZero
            subView[index].layoutMargins = UIEdgeInsetsZero
            subView[index].tableFooterView = UIView()
            subView[index].registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            
            self.scrollView.addSubview(subView[index])
        }
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * CGFloat(3), self.scrollView.frame.size.height)
        self.scrollView.contentOffset.x = self.scrollView.frame.size.width
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class MyData: NSObject, UITableViewDataSource {
        var id: Int;
        init(id: Int) {
            self.id = id
            tableData.append(String(id))
        }
        
        var tableData = ["数学","语文","英语"]
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            return self.tableData.count
        }
        
        func tableView(tableView: UITableView,
            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        {
            let cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell")
            cell.textLabel?.text = self.tableData[indexPath.row]
            cell.separatorInset = UIEdgeInsetsZero;
            cell.layoutMargins = UIEdgeInsetsZero;
            
            return cell
        }
    }
}