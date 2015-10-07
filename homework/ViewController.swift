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

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var DateLabel: UILabel!
    var subView:[UITableView] = []
    var datasource:[MyData] = []
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var currentDate :NSDate = NSDate()

    func getDateStr(d :NSDate) -> String {
        let dateformatter: NSDateFormatter = NSDateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        
        return dateformatter.stringFromDate(d) + " (" + String(d.dayofWeek()) + ")"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DateLabel.text = getDateStr(currentDate)

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
        var wv: [Bool]
        
        init(id: Int, tv: UITableView) {
            self.id = id
            self.tv = tv
            self.wv = [false, false, false, false]
            tableData.append(String(id))
        }
        
        var tableData = [
            "数学 <a href=\"http://www.w3school.com.cn\">W3School</a>（汉语拼音：shù xué；希腊语：μαθηματικ；英语：Mathematics），源自于古希腊语的μθημα（máthēma），其有学习、学问、科学之意．古希腊学者视其为哲学之起点，“学问的基础”．另外，还有个较狭隘且技术性的意义——“数学研究”．即使在其语源内，其形容词意义凡与学习有关的，亦会被用来指数学的．数学起源于人类早期的生产活动，古巴比伦人从远古时代开始已经积累了一定的数学知识，并能应用实际问题．从数学本身看，他们的数学知识也只是观察和经验所得，没有综合结论和证明，但也要充分肯定他们对数学所做出的贡献．",
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
            if (tableDataHeights[webView.tag] != 40.0)
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
        getOldViewState() { (vs, error) in
            if (error != nil) {
                return
            }
            print("viewstate is ready")
            self.login(vs!) { (hellomsg, error) in
                if (error != nil) {
                    return
                }
                // TODO: Check Hello Message here!
                print("login is ready")
                self.getHomework({ (homework, error) -> Void in
                    if (error != nil) {
                        return
                    }
                    print(homework!)
                    /* TODO: Extract homework and update view */
                })
            }
        }
    }

    func getOldViewState(completion: (vs: String?, error: NSError?) -> Void) {
        /* The example of view state string is as below,
           <input type="hidden" name="__VIEWSTATE" value="dDwtMzI3NTUwMjExO3Q8O2w8aTwxPjs+O2w8dDw7bDxpPDU... " /> */
        var vs = ""
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.fushanedu.cn/jxq/jxq_User.aspx")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        let postString = ""
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(enc)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            if (error != nil) {
                print("viewstate error=\(error)")
                return
            }

            let res = response as! NSHTTPURLResponse!
            print("Response code:", res.statusCode)

            if (data != nil) {
                let s = NSString(data: data!, encoding: enc)
                let viewstate_regex = "<input[^<]*name=\"__VIEWSTATE\" value=\"([^\"]*)\""
                let viewstate_range = s!.rangeOfString(viewstate_regex, options: .RegularExpressionSearch)
                
                let re = try! NSRegularExpression(pattern: viewstate_regex, options: [.CaseInsensitive])
                let matches = re.matchesInString(s as! String, options: [], range: viewstate_range)
                print("number of matches: \(matches.count)")
                for match in matches as [NSTextCheckingResult] {
                    // range at index 0: full match
                    // range at index 1: first capture group
                    vs = s!.substringWithRange(match.rangeAtIndex(1))
                    break
                }

                // print("viewstate:", vs)
                completion(vs: vs, error: nil)
            }
        }
        
        task.resume()
        /* No code should be after here. */
    }
    
    func login(vs: String, completion: (hellomsg: String?, error: NSError?) -> Void) {
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        /* %2B + , %2F / , %3D = , %3A : */
        let urlBase64CharacterSet :NSCharacterSet = NSCharacterSet(charactersInString: "/:+=").invertedSet
        // let viewstate = vs.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let viewstate = vs.stringByAddingPercentEncodingWithAllowedCharacters(urlBase64CharacterSet)!
        let username = "&login%3AtbxUserName=20130825"
        let password = "&login%3AtbxPassword=5119642"
        let btnx="&login%3Abtnlogin.x=27"
        let btny="&login%3Abtnlogin.y=12"
        let postString = "__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE＝" + viewstate + "&__VIEWSTATEGENERATOR=AC07AF0C" + username + password + btnx + btny

        // print("post string is", postString)

        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.fushanedu.cn/jxq/jxq_User.aspx")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(enc)
        // request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if (error != nil) {
                print("post error=\(error)")
                return
            }
            
            let res = response as! NSHTTPURLResponse!
            print("Response code:", res.statusCode)
            
            // print("response = \(response)")
            let rawdata = NSString(data: data!, encoding: enc)
            let hellomsg = rawdata as! String
            
            if (hellomsg.rangeOfString("您好") == nil) {
                // print("rawdata = \(rawdata)")
                print("login failed!")
               return
            }
            
            completion(hellomsg: hellomsg, error: nil)
        }
        task.resume()
        /* No code should be after here. */
    }
    
    func getHomework(completion: (homework: String?, error: NSError?) -> Void) {
        completion(homework: "No Homework yet!", error: nil)
    }
}