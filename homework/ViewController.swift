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
        
        getHomeWork()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class MyData: NSObject, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate {
        var id: Int
        var tv: UITableView
        var wv: [Bool]
        
        init(id: Int, tv: UITableView) {
            self.id = id
            self.tv = tv
            self.wv = [false, false, false, false]
            tableData.append(String(id))
        }
        
        var tableData = [
            "数学（汉语拼音：shù xué；希腊语：μαθηματικ；英语：Mathematics），源自于古希腊语的μθημα（máthēma），其有学习、学问、科学之意．古希腊学者视其为哲学之起点，“学问的基础”．另外，还有个较狭隘且技术性的意义——“数学研究”．即使在其语源内，其形容词意义凡与学习有关的，亦会被用来指数学的．",
            "语文 是口头语言和书面语言，也是或语言和文学的简称。相对来说，口头语言较随意，直接易懂；而书面语言讲究准确和语法。此解释概念较狭窄，因为语文中的文章不但有文艺文（文学、曲艺等），还有很多实用文（应用文）。通俗的说，语言就是说话艺术．",
            "英语 属于印欧语系中日耳曼语族下的西日耳曼语支，是由古代从德国、荷兰及丹麦等斯堪的纳维亚半岛周边移民至不列颠群岛的盎格鲁、撒克逊和朱特部落的日耳曼人所说的语言演变而来，并通过英国的殖民活动传播到了世界各地。由于在历史上曾和多种民族语言接触，它的词汇从一元变为多元，语法从“多屈折”变为“少屈折”，语音也发生了规律性的变化．"]
        var tableDataHeights : [CGFloat] = [40.0, 40.0, 40.0, 40.0]
        
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
            if (!wv[indexPath.row]) {
                print("create webView", id, indexPath.row)
                let htmlString = tableData[indexPath.row]
                let htmlHeight = tableDataHeights[indexPath.row]
                let frame: CGRect = CGRectMake(0, 0, cell.frame.size.width, htmlHeight)
                let hw_webview :UIWebView = UIWebView(frame: frame)
                hw_webview.loadHTMLString(htmlString, baseURL: nil)
                hw_webview.delegate = self
                hw_webview.tag = indexPath.row
                hw_webview.scrollView.scrollEnabled = false
                // hw_webview.scalesPageToFit = true
                hw_webview.allowsInlineMediaPlayback = true
                cell.addSubview(hw_webview)
                wv[indexPath.row] = true
            }
            
            return cell
        }
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
        {
            return tableDataHeights[indexPath.row]
        }
        
        func webViewDidFinishLoad(webView: UIWebView) {
            if (tableDataHeights[webView.tag] != 40.0)
            {
                // we already know height, no need to reload cell
                return
            }
            
            tableDataHeights[webView.tag] = getWebviewHeight(webView)
            print("webViewDidfinishLoad", id, webView.tag, tableDataHeights[webView.tag])
            
            tv.reloadData()
            // tv.reloadRowsAtIndexPaths([NSIndexPath(forRow: webView.tag, inSection: 0)], withRowAnimation: .Automatic)
        }
        
        // Get the height of a webview. This is a very tricky implementation, but it works!
        func getWebviewHeight(webView: UIWebView) -> CGFloat {
            webView.scrollView.scrollEnabled = false
            
            var frame :CGRect = webView.frame
            // Your desired width here.
            // frame.size.width = 200;
            frame.size.height = 1
            webView.frame = frame
            
            /* Solution 1 : */
            /*
            let fittingSize :CGSize = webView.sizeThatFits(CGSizeZero);
            frame.size = fittingSize;
            */
            
            /* Solution 2 : */
            frame.size.height = webView.scrollView.contentSize.height;
            
            // Set the scrollView contentHeight back to the frame itself.
            webView.frame = frame;
            return webView.frame.height
        }
    }
    
    /*
    <input type="hidden" name="__EVENTTARGET" value="" />
    <input type="hidden" name="__EVENTARGUMENT" value="" />
    <input type="hidden" name="__VIEWSTATE" value="dDwtMzI3NTUwMjExO3Q8O2w8aTwxPjs+O2w8dDw7bDxpPDU+O2k8Nz47PjtsPHQ8O2w8aTwxPjs+O2w8dDw7bDxpPDE ... " />
    */
    
    func getOldViewState() -> String {
        let url = NSURL(string: "http://www.fushanedu.cn/jxq/jxq_User.aspx")
        
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if (data != nil) {
                let s = NSString(data: data!, encoding: enc)
                // let viewstate_regex = "<input[^<]*name=\"__VIEWSTATE\" value=\"[^\"]*\""
                let viewstate = s!.rangeOfString("title", options: .RegularExpressionSearch)
            
                // println(NSString(data: data, encoding: enc))
                print(viewstate)
                // println(s)
            }
        }
        
        task.resume()
        return ""
    }
    
    func getHomeWork() -> String {
        /*
        let url = NSURL(string: "http://www.fushanedu.cn/jxq/jxq.aspx")
        
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
        println(NSString(data: data, encoding: enc))
        }
        
        task.resume()
        */
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.fushanedu.cn/jxq/jxq_User.aspx")!)
        request.HTTPMethod = "POST"
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let viewstate = getOldViewState()
        let username = "login:tbxUserName=20130825&"
        let password = "login:tbxPassword=5119642&"
        let btnx="login:btnlogin.x=27&"
        let btny="login:btnlogin.y=12&"
        let postString = viewstate + username + password + btnx + btny
        request.HTTPBody = postString.dataUsingEncoding(enc)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            let responseString = NSString(data: data!, encoding: enc)
            print("responseString = \(responseString)")
        }
        task.resume()
        return ""
    }

}