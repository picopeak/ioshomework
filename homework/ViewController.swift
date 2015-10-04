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
            var frame: CGRect = CGRectMake(0, 0, 0, 0)
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            // Create table view
            let tv :UITableView = UITableView(frame: frame)
            let hw :MyData = MyData(id: index, tv: tv)
            tv.dataSource = hw
            tv.delegate = hw
            tv.rowHeight = UITableViewAutomaticDimension
            tv.separatorInset = UIEdgeInsetsZero
            tv.layoutMargins = UIEdgeInsetsZero
            tv.tableFooterView = UIView()
            tv.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            self.scrollView.addSubview(tv)
            
            // Record table views and data sources
            subView.append(tv)
            datasource.append(hw)
        }
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * CGFloat(3), self.scrollView.frame.size.height)
        self.scrollView.contentOffset.x = self.scrollView.frame.size.width
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class MyData: NSObject, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate {
        var id: Int
        var tv: UITableView
        init(id: Int, tv: UITableView) {
            self.id = id
            self.tv = tv
            tableData.append(String(id))
        }
        
        var tableData = ["<html><head><title>数学</title></head><body>数学（汉语拼音：shù xué；希腊语：μαθηματικ；英语：Mathematics），源自于古希腊语的μθημα（máthēma），其有学习、学问、科学之意．古希腊学者视其为哲学之起点，“学问的基础”．另外，还有个较狭隘且技术性的意义——“数学研究”．即使在其语源内，其形容词意义凡与学习有关的，亦会被用来指数学的．</body></html>",
            "语文",
            "英语"]
        var tableDataHeights : [CGFloat] = [0.0, 0.0, 0.0, 0.0]
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            return self.tableData.count
        }
        
        func tableView(tableView: UITableView,
            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        {
            let cell :UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell")
            cell.separatorInset = UIEdgeInsetsZero;
            cell.layoutMargins = UIEdgeInsetsZero;
            
            /* Create a web view */
            let htmlString = tableData[indexPath.row]
            let htmlHeight = tableDataHeights[indexPath.row]
            let frame: CGRect = CGRectMake(0, 0, cell.frame.size.width, htmlHeight)
            let wv :UIWebView = UIWebView(frame: frame)
            wv.loadHTMLString(htmlString, baseURL: nil)
            wv.delegate = self
            wv.tag = indexPath.row
            cell.addSubview(wv)
            
            return cell
        }
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return tableDataHeights[indexPath.row]
        }
        
        func webViewDidFinishLoad(webView: UIWebView) {
            if (tableDataHeights[webView.tag] != 0.0)
            {
                // we already know height, no need to reload cell
                return
            }
            
            tableDataHeights[webView.tag] = 200 // webView.scrollView.contentSize.height
            tv.reloadRowsAtIndexPaths([NSIndexPath(forRow: webView.tag, inSection: 0)], withRowAnimation: .Automatic)
        }
    }
}