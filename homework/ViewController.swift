//
//  ViewController.swift
//  homework
//
//  Created by picopeak on 15/10/3.
//  Copyright © 2015年 fushan. All rights reserved.
//

import UIKit
import Kanna

extension NSDate {
    func daysSinces2000() -> Int {
        let interval = self.timeIntervalSinceReferenceDate
        let days = Int(interval / 86400)
        return days + 366
    }
    func days() -> Int {
        let interval = self.timeIntervalSince1970
        let days = Int(interval / 86400)
        return days
    }
    func dayofWeek() -> String {
        switch ((days() - 3) % 7) {
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
    func yesterday() -> NSDate {
        return NSDate(timeIntervalSince1970: self.timeIntervalSince1970 - 86400)
    }
}

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var left: UILabel!
    @IBOutlet weak var right: UILabel!
    var subView:[UITableView] = []
    var datasource:[MyData] = []
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var currentDate :NSDate = NSDate()
    let calendar = NSCalendar.currentCalendar()
    var viewState :String = ""

    func getDateStr(d :NSDate) -> String {
        let dateformatter: NSDateFormatter = NSDateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        
        return dateformatter.stringFromDate(d) + " (" + String(d.dayofWeek()) + ")"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DateLabel.text = getDateStr(currentDate)
        DateLabel.backgroundColor = UIColor.purpleColor()
        DateLabel.textColor = UIColor.whiteColor()
        left.backgroundColor = UIColor.purpleColor()
        left.textColor = UIColor.whiteColor()
        right.backgroundColor = UIColor.purpleColor()
        right.textColor = UIColor.whiteColor()
        
        for index in 0 ..< 3 {
            var frame: CGRect = CGRectMake(0, 0, 0, 0)
            let loc :CGPoint = (self.scrollView.superview?.convertPoint(self.scrollView.frame.origin, toView: nil))!
            frame.size.height = screenHeight - loc.y
            frame.size.width = screenWidth
            frame.origin.x = screenWidth * CGFloat(index)
            
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
        
        self.scrollView.contentSize = CGSizeMake(screenWidth * CGFloat(3), self.scrollView.frame.size.height)
        self.scrollView.contentOffset.x = screenWidth
        
        login_and_gethw()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lroundf(Float(self.scrollView.contentOffset.x / screenWidth))
        print("page =", page)
        if (page != 1) {
            if (page == 0) {
                currentDate = currentDate.dateByAddingTimeInterval(-86400.0)
            } else if (page == 2) {
                currentDate = currentDate.dateByAddingTimeInterval(86400.0)
            }
            DateLabel.text = getDateStr(currentDate)
            self.scrollView.contentOffset.x = screenWidth
        }
    }
    
    class MyData: NSObject, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate {
        var id: Int
        var tv: UITableView
        var wv: [Bool] = []
        var tableData :[String] = [ ]
        var tableDataHeights : [CGFloat] = [ ]
        
        init(id: Int, tv: UITableView) {
            self.id = id
            self.tv = tv
            // tableData.append(String(id))
            tableData.append("没有作业")
            tableDataHeights.append(1.0)
            self.wv.append(false)
        }
        
        func updateData(data :[String]) {
            tableData = data
            tableDataHeights[0] = 1.0
            wv[0] = false
            // tv.reloadData()
        }
        
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
                // print("create webView", id, indexPath.row)
                let htmlString = tableData[indexPath.row]
                let htmlHeight = tableDataHeights[indexPath.row]
                let frame: CGRect = CGRectMake(0, 0, tv.frame.size.width, htmlHeight)
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
            
            // cell.sizeToFit()
            return cell
        }
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
        {
            return tableDataHeights[indexPath.row]
        }
        
        func webViewDidFinishLoad(webView: UIWebView) {
            if (tableDataHeights[webView.tag] != 1.0)
            {
                // we already know height, no need to reload cell
                return
            }
            
            tableDataHeights[webView.tag] = getWebviewHeight(webView)
            // print("webViewDidfinishLoad", id, webView.tag, tableDataHeights[webView.tag])
            
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
    
    /* Main function to get homework */
    func login_and_gethw() {
        getOldViewState("http://www.fushanedu.cn/jxq/jxq_User.aspx") { (vs, error) in
            if (error != nil) {
                return
            }
            print("viewstate is ready 1")
            self.viewState = vs!
            self.login() { (hellomsg, error) in
                if (error != nil) {
                    return
                }
                if (true /* hellomsg == "" */) {
                    /* try again */
                    print("try to login again")
                    self.getOldViewState("http://www.fushanedu.cn/jxq/jxq_User.aspx") { (vs, error) in
                        if (error != nil) {
                            return
                        }
                        print("viewstate is ready 2")
                        self.viewState = vs!
                        self.login() { (hellomsg, error) in
                            if (error != nil) {
                                return
                            }
                            if (hellomsg == "") {
                                return
                            }
                            
                            self.getOldViewState("http://www.fushanedu.cn/jxq/jxq_User_jtzyck.aspx") { (vs, error) in
                                if (error != nil) {
                                    return
                                }
                                print("get new viewstate")
                                self.viewState = vs!
                                self.getHomework(self.currentDate, completion: { (vs, homework, error) -> Void in
                                    if (error != nil) {
                                        return
                                    }
                                
                                    var hw :[String] = [ "" ]
                                    hw = self.parseHomework(homework!)
                                    if (hw[0] == "") {
                                        // This is probably a workaround, because the fushan network is unstable, and some times
                                        // the normal read can return empty although there are some homeworks. So we will try it
                                        // again by reading homework yesterday.
                                        
                                        // Try yesterday first
                                        print("try yesterday")

                                        self.viewState = vs
                                        self.getHomework(self.currentDate.yesterday(), completion: { (vs, homework, error) -> Void in
                                            if (error != nil) {
                                                return
                                            }
                                            print("try current date again")
                                            // Try currentDate again
                                            self.viewState = vs
                                            self.getHomework(self.currentDate, completion: { (vs, homework, error) -> Void in
                                                if (error != nil) {
                                                    return
                                                }
                                                
                                                var hw :[String] = [ "" ]
                                                hw = self.parseHomework(homework!)
                                                if (hw[0] == "") {
                                                    return
                                                } else {
                                                    self.datasource[1].updateData(hw)
                                                    /* TODO: update to table view */
                                                }
                                            })
                                        })
                                    } else {
                                        self.datasource[1].updateData(hw)
                                        /* TODO: update to table view */
                                    }
                                })
                            }
                        }
                    }
                    
                    return
                }
                // Usually we will never encounter this situation!
            }
        }
    }

    func getViewState(data :NSData) -> String {
        var vs :String = ""
        let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let s = NSString(data: data, encoding: dec)
        let viewstate_regex = "<input[^<]*name=\"__VIEWSTATE\" value=\"([^\"]*)\""
        let viewstate_range = s!.rangeOfString(viewstate_regex, options: .RegularExpressionSearch)
        
        let re = try! NSRegularExpression(pattern: viewstate_regex, options: [.CaseInsensitive])
        let matches = re.matchesInString(s as! String, options: [], range: viewstate_range)
        // print("number of matches: \(matches.count)")
        for match in matches as [NSTextCheckingResult] {
            // range at index 0: full match
            // range at index 1: first capture group
            vs = s!.substringWithRange(match.rangeAtIndex(1))
            break
        }
        
        return vs;
    }
    
    func getOldViewState(url: String, completion: (vs: String?, error: NSError?) -> Void) {
        /* The example of view state string is as below,
           <input type="hidden" name="__VIEWSTATE" value="dDwtMzI3NTUwMjExO3Q8O2w8aTwxPjs+O2w8dDw7bDxpPDU... " /> */
        var vs = ""
        let request = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        print("Trying to get view state ...")
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            if (error != nil) {
                print("viewstate error=\(error)")
                return
            }

            let res = response as! NSHTTPURLResponse!
            print("Response code:", res.statusCode)

            if (data != nil) {
                vs = self.getViewState(data!)
                // print("viewstate:", vs)
                completion(vs: vs, error: nil)
            }
        }
        
        task.resume()
        /* No code should be after here. */
    }
    
    func login(completion: (hellomsg: String?, error: NSError?) -> Void) {
        /* %2B + , %2F / , %3D = , %3A : */
        let urlBase64CharacterSet :NSCharacterSet = NSCharacterSet(charactersInString: "/:+").invertedSet
        // let viewstate = vs.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        // let viewstate = vs.stringByAddingPercentEncodingWithAllowedCharacters(urlBase64CharacterSet)!
        let username = "&login:tbxUserName=20130825"
        let password = "&login:tbxPassword=5119642"
        let btnx="&login:btnlogin.x=27"
        let btny="&login:btnlogin.y=12"
        var postString = "__VIEWSTATE=" + viewState + username + password + btnx + btny
        postString = postString.stringByAddingPercentEncodingWithAllowedCharacters(urlBase64CharacterSet)!
        // print("post string is", postString)

        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        // let enc :NSStringEncoding = NSUTF8StringEncoding
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.fushanedu.cn/jxq/jxq_User.aspx")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        let paramsLength = postString.lengthOfBytesUsingEncoding(enc)
        let postStringLen = "\(paramsLength)"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(postStringLen, forHTTPHeaderField: "Content-Length")

        let encoded_postString :NSData = postString.dataUsingEncoding(enc)!
        request.HTTPBody = encoded_postString
        request.HTTPMethod = "POST"

        let session = NSURLSession.sharedSession()
        print("Trying to login ...")
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if (error != nil) {
                print("post error=\(error)")
                return
            }
            
            let res = response as! NSHTTPURLResponse!
            print("Response code:", res.statusCode)
            
            // print("response = \(response)")
            let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let rawdata = NSString(data: data!, encoding: dec)
            let hellomsg = rawdata as! String
            
            if (hellomsg.rangeOfString("您好！欢迎使用") == nil) {
                // print("rawdata = \(rawdata)")
                print("login failed!")
                completion(hellomsg: "", error: nil)
            } else {
                print("login passed!")
                completion(hellomsg: hellomsg, error: nil)
            }
        }
        task.resume()
        /* No code should be after here. */
    }
    
    func getHomework(toDate: NSDate, completion: (vs: String, homework: String?, error: NSError?) -> Void) {
        let urlBase64CharacterSet :NSCharacterSet = NSCharacterSet(charactersInString: "/:+").invertedSet
        var postString = "__EVENTTARGET=MyCalendar"
            + "&__EVENTARGUMENT=" + String(toDate.daysSinces2000())
            + "&__VIEWSTATE=" + viewState
            + "&SchoolName=7"
            + "&GradeName=304"
            + "&ClassName=1990"
        postString = postString.stringByAddingPercentEncodingWithAllowedCharacters(urlBase64CharacterSet)!
        // print("post string is", postString)
        
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.fushanedu.cn/jxq/jxq_User_jtzyck.aspx")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        let paramsLength = postString.lengthOfBytesUsingEncoding(enc)
        let postStringLen = "\(paramsLength)"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(postStringLen, forHTTPHeaderField: "Content-Length")
        let encoded_postString :NSData = postString.dataUsingEncoding(enc)!
        request.HTTPBody = encoded_postString
        request.HTTPMethod = "POST"
        
        let session = NSURLSession.sharedSession()
        print("Trying to get homework data ...")
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if (error != nil) {
                print("post error=\(error)")
                return
            }
            
            let res = response as! NSHTTPURLResponse!
            print("Response code:", res.statusCode)
            
            let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let rawdata = NSString(data: data!, encoding: dec)
            let homework = rawdata as! String
            let new_vs = self.getViewState(data!)
            
            if (homework.rangeOfString("您当前查看的是") == nil) {
                print("failed to obtain homework!")
                completion(vs: new_vs, homework: "", error: nil)
            } else {
                // print("rawdata = \(rawdata)")
                print("homework obtained!")
                completion(vs: new_vs, homework: homework, error: nil)
            }
        }
        task.resume()
        /* No code should be after here. */
    }

    func parseHomework(homework :String) -> [String] {
        var hw :[String] = [ ]
        let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        if let doc = Kanna.HTML(html: homework, encoding: dec) {
            // Search for nodes by XPath
            // let hw_name :[String] = [ "数学作业", "英语作业", "语文作业", "音乐作业", "体育作业", "美术作业", "自然作业", "信息作业", "劳技作业", "国际理解作业" ]
            let hw_index = doc.xpath("//b[contains(text(),'作业')]")
            for b in hw_index {
                let hw_content = doc.xpath("//b[contains(text(),'" + b.text! + "')]/../../following-sibling::tr[1]")
                hw.append(b.text! + hw_content.text!)
            }
            hw.append("测试今日作业")
        }
        print(hw)
        return hw
    }
}