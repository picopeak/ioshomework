//
//  ViewController.swift
//  homework
//
//  Created by picopeak on 15/10/3.
//  Copyright © 2015年 fushan. All rights reserved.
//

import UIKit
import Kanna
import SQLite

extension NSDate {
    func daysSinces2000() -> Int {
        let interval = self.timeIntervalSinceReferenceDate + 8*3600
        let days = Int(interval / 86400)
        return days + 366
    }
    func days() -> Int {
        let interval = self.timeIntervalSince1970 + 8*3600
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
    func tomorrow() -> NSDate {
        return NSDate(timeIntervalSince1970: self.timeIntervalSince1970 + 86400)
    }
    func getDateStr() -> String {
        let dateformatter: NSDateFormatter = NSDateFormatter()
        dateformatter.timeZone = NSTimeZone(name: "HKT")
        // dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        // print(dateformatter.stringFromDate(self))
        dateformatter.dateFormat = "YYYY-MM-dd"
        return dateformatter.stringFromDate(self) + " (" + String(dayofWeek()) + ")"
    }
}

class ViewController: UIViewController, UIScrollViewDelegate, LoginViewControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var FushanLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var left: UILabel!
    @IBOutlet weak var right: UILabel!
    @IBOutlet weak var setupBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    
    var db :Connection
    let hwtable :Table
 
    let fushan_web2 = "www.psfshl.pudong-edu.sh.cn"
    let fushan_web1 = "www.fushanedu.cn"
    var fushan_web :String
    
    required init?(coder aDecoder: NSCoder) {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        db = try! Connection("\(path)/db.sqlite3.homework")
        hwtable = Table("homework")
        fushan_web = fushan_web1
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        db = try! Connection("\(path)/db.sqlite3.homework")
        hwtable = Table("homework")
        fushan_web = fushan_web1
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    var subView :[UITableView] = []
    var datasource :[HomeWorkData] = []
    var screenWidth = UIScreen.mainScreen().bounds.width
    var screenHeight = UIScreen.mainScreen().bounds.height
    var currentDate :NSDate = NSDate()
    let calendar = NSCalendar.currentCalendar()
    var viewState :String = ""
    // This is a map from DateLabel string to homework.
    var homework = [String:[String]]()
    var isLoggedIn :Bool = false
    var refreshControl :[UIRefreshControl] = []
    
    var username :String = ""
    var password :String = ""
    var username2 :String = ""
    var password2 :String = ""
    var name :String = ""
    
    var isUser2 :Bool = false
    var isBigFont :Bool = false
    var currentusername :String = ""
    var currentpassword :String = ""

    func presentLoginView() {
        // Pass data into login View Controller
        let vc :LoginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! LoginViewController
        vc.delegate = self
        vc.updateInfo(self.username, password: self.password, username2: self.username2, password2: self.password2, isUser2: self.isUser2, isBigFont: self.isBigFont, name: self.name)
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    var loginTried :Bool = false {
        didSet {
            if (isLoggedIn == false && loginTried == true) {
                presentLoginView()
            }
        }
    }
    
    @IBAction func showToday(sender: UIButton) {
        self.currentDate = NSDate()
        DateLabel.text = currentDate.getDateStr()
        self.show_homework(self.currentDate, id: 1)
        self.show_homework(self.currentDate.yesterday() ,id: 0)
        self.show_homework(self.currentDate.tomorrow(), id: 2)
        // login_and_gethw()
    }
    
    @IBAction func setup(sender: UIButton) {
        presentLoginView()
    }
    
    func didFinishLogin(controller: LoginViewController, username: String, password: String, username2: String, password2: String, isUser2 :Bool, isBigFont :Bool) {
        // Recieved the info passed from Login View.
        print("username", username, "password", password, "username2", username2, "password2", password2, "isUser2", isUser2, "isBigFont", isBigFont)
        controller.dismissViewControllerAnimated(false, completion: nil)
        
        // Update current user
        if (isUser2) {
            currentusername = username2
            currentpassword = password2
        } else {
            currentusername = username
            currentpassword = password
        }
        
        if (self.isUser2 == isUser2) {
            if (isUser2) {
                if (self.username2 == username2 && self.password2 == password2) {
                    self.username = username
                    self.password = password
                    self.isBigFont = isBigFont
                    show_homework(self.currentDate, id: 1)
                    return
                }
            } else {
                if (self.username == username && self.password == password) {
                    self.username2 = username2
                    self.password2 = password2
                    self.isBigFont = isBigFont
                    show_homework(self.currentDate, id: 1)
                    return
                }
            }
        }
        
        self.username = username
        self.password = password
        self.username2 = username2
        self.password2 = password2
        self.isBigFont = isBigFont
        self.isUser2 = isUser2
        
        storeUserData()

        // user is changed, so now try to logout and login again
        logout_and_login_gethw()
    }
    
    func loadUserData() {
        print("load setup data")
        let defaults = NSUserDefaults.standardUserDefaults()
        let usernameObj = defaults.objectForKey("username")
        let passwordObj = defaults.objectForKey("password")
        let username2Obj = defaults.objectForKey("username2")
        let password2Obj = defaults.objectForKey("password2")
        if (usernameObj != nil && passwordObj != nil) {
            username = usernameObj as! String
            password = passwordObj as! String
        }
        if (username2Obj != nil && password2Obj != nil) {
            username2 = username2Obj as! String
            password2 = password2Obj as! String
        }
        
        let isUser2Obj = defaults.objectForKey("isUser2")
        if (isUser2Obj != nil && ((isUser2Obj as! Bool) == true)) {
            isUser2 = true
            currentusername = username2
            currentpassword = password2
        } else {
            isUser2 = false
            currentusername = username
            currentpassword = password
        }
        
        let isBigFontObj = defaults.objectForKey("isBigFont")
        if (isBigFontObj != nil) {
            isBigFont = isBigFontObj as! Bool
        }
        let nameObj = defaults.objectForKey("name")
        if (nameObj != nil) {
            self.name = nameObj as! String
        }
    }
    
    func storeUserData() {
        print("store setup data")
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.username, forKey: "username")
        defaults.setObject(self.password, forKey: "password")
        defaults.setObject(self.username2, forKey: "username2")
        defaults.setObject(self.password2, forKey: "password2")
        defaults.setObject(self.isUser2, forKey: "isUser2")
        defaults.setObject(self.isBigFont, forKey: "isBigFont")
        defaults.setObject(self.name, forKey: "name")
    }

    func createOneHWRecord(user :String, date :String, course :String, content :String) -> Int64 {
        let user_field = Expression<String>("user")
        let date_field = Expression<String>("date")
        let course_field = Expression<String>("course")
        let content_field = Expression<String>("content")
        return try! db.run(hwtable.insert(user_field <- user, date_field <- date, course_field <- course, content_field <- content))
    }
    
    func getCourseName(c :String ) -> String {
        if (c.rangeOfString("数学作业") != nil) {
            return "数学作业"
        }
        if (c.rangeOfString("英语作业") != nil) {
            return "英语作业";
        }
        if (c.rangeOfString("语文作业") != nil) {
            return "语文作业";
        }
        if (c.rangeOfString("音乐作业") != nil) {
            return "音乐作业";
        }
        if (c.rangeOfString("体育作业") != nil) {
            return "体育作业";
        }
        if (c.rangeOfString("美术作业") != nil) {
            return "美术作业";
        }
        if (c.rangeOfString("自然作业") != nil) {
            return "自然作业";
        }
        if (c.rangeOfString("信息作业") != nil) {
            return "信息作业";
        }
        if (c.rangeOfString("劳技作业") != nil) {
            return "劳技作业";
        }
        if (c.rangeOfString("国际理解作业") != nil) {
            return "国际理解作业";
        }
        return "";
    }

    func createHWRecords(user :String, date :String, HW :[String]) {
        // Remove old records from database
        let user_field = Expression<String>("user")
        let date_field = Expression<String>("date")
        let myhw = hwtable.filter(user_field == user && date_field == date)
        print("deleting old homework record")
        _ = try? db.run(myhw.delete())
        
        // Insert new records into database
        print("writing new homework record")
        var HasHomework :Bool = false;
        for hw in HW {
            if (hw != "") {
                createOneHWRecord(user, date: date, course: getCourseName(hw), content: hw);
                HasHomework = true;
            }
        }
        
        if (!HasHomework) {
            createOneHWRecord(user, date: date, course: "", content: "今日没有作业");
        }
    }
    
    func getHWRecords(user :String, date :String) -> [String] {
        let user_field = Expression<String>("user")
        let date_field = Expression<String>("date")
        let content_field = Expression<String>("content")
        let query = hwtable.select(content_field).filter(user_field == user && date_field == date)
        
        var homework :[String] = []
        print("querying homework record "+date)
        for hw in try! db.prepare(query) {
            homework.append(hw[content_field])
        }
        return homework
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DateLabel.text = currentDate.getDateStr()
        DateLabel.backgroundColor = UIColor.purpleColor()
        DateLabel.textColor = UIColor.whiteColor()
        left.backgroundColor = UIColor.purpleColor()
        left.textColor = UIColor.whiteColor()
        right.backgroundColor = UIColor.purpleColor()
        right.textColor = UIColor.whiteColor()
        setupBtn.layer.borderColor = UIColor.grayColor().CGColor
        setupBtn.layer.borderWidth = 1.0
        setupBtn.layer.cornerRadius = 10; // this value vary as per your desire
        todayBtn.layer.borderColor = UIColor.grayColor().CGColor
        todayBtn.layer.borderWidth = 1.0
        todayBtn.layer.cornerRadius = 10; // this value vary as per your desire

        for index in 0 ..< 3 {
            var frame: CGRect = CGRectMake(0, 0, 0, 0)
            let loc :CGPoint = (self.scrollView.superview?.convertPoint(self.scrollView.frame.origin, toView: nil))!
            frame.size.height = screenHeight - loc.y
            // frame.size.height = scrollView.frame.height
            frame.size.width = screenWidth
            frame.origin.x = screenWidth * CGFloat(index)
            
            // Create table view
            let tv :UITableView = UITableView(frame: frame)

            let refresh :UIRefreshControl = UIRefreshControl()
            refresh.attributedTitle = NSAttributedString(string: "更新作业数据...")
            refresh.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
            self.refreshControl.append(refresh)
            
            let hw :HomeWorkData = HomeWorkData(id: index, tv: tv, refresh: refresh)
            tv.dataSource = hw
            tv.delegate = hw
            tv.rowHeight = UITableViewAutomaticDimension
            tv.separatorInset = UIEdgeInsetsZero
            tv.layoutMargins = UIEdgeInsetsZero
            tv.tableFooterView = UIView()
            tv.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tv.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            tv.separatorColor = UIColor.purpleColor()
            tv.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
            tv.addSubview(refresh)
            self.scrollView.addSubview(tv)
            
            // Record table views and data sources
            subView.append(tv)
            datasource.append(hw)
        }
        
        self.scrollView.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
        self.scrollView.superview!.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
        self.scrollView.contentSize = CGSizeMake(screenWidth * CGFloat(3), 0)
        self.scrollView.contentOffset.x = screenWidth
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        // Create database now
        let id_field = Expression<Int64>("id")
        let user_field = Expression<String>("user")
        let date_field = Expression<String>("date")
        let course_field = Expression<String>("course")
        let content_field = Expression<String>("content")
   
        _ = try? db.run(hwtable.create(ifNotExists: true) { t in
            t.column(id_field, primaryKey: true)
            t.column(user_field)
            t.column(date_field)
            t.column(course_field)
            t.column(content_field)
            })
        
        loadUserData()
        dispatch_async(dispatch_get_main_queue(), {
            self.FushanLabel.text = "福外作业 - " + self.name + " 🔴"
            if (self.username == "" && self.username2 == "") {
                self.presentLoginView()
                return
            }
        });
        
        self.show_homework(self.currentDate, id: 1)
        self.show_homework(self.currentDate.yesterday() ,id: 0)
        self.show_homework(self.currentDate.tomorrow(), id: 2)
        login_and_gethw()
    }
    
    func alertmsg(str :String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.FushanLabel.text = "福外作业 - " + self.name + " 🔴"
        });
        let alert = UIAlertController(title: "Alert", message: str, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func refresh(sender:AnyObject)
    {
        print("refreshing ...")
        let refreshC = (self.subView[1].dataSource as! HomeWorkData).refresh
        refreshC.endRefreshing()
        login_and_gethw_current_date()
        // downloadhw(self.currentDate, id: 1)
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        if (screenHeight < screenWidth) {
            let tmp = screenHeight
            screenHeight = screenWidth
            screenWidth = tmp
        }
       return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if (screenHeight < screenWidth) {
            let tmp = screenHeight
            screenHeight = screenWidth
            screenWidth = tmp
        }
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if (screenHeight < screenWidth) {
            let tmp = screenHeight
            screenHeight = screenWidth
            screenWidth = tmp
        }
        return UIInterfaceOrientation.Portrait
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        // TODO: fix bugs around rotation
        /*
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        
        scrollView.pagingEnabled = true
        self.scrollView.contentSize = CGSizeMake(screenWidth * CGFloat(3), self.scrollView.frame.size.height)
        self.scrollView.contentOffset.x = screenWidth
        
        let loc :CGPoint = (self.scrollView.superview?.convertPoint(self.scrollView.frame.origin, toView: nil))!
        let height = screenHeight - loc.y
        
        subView[0].frame = CGRectMake(0, 0, screenWidth, height)
        subView[1].frame = CGRectMake(screenWidth, 0, screenWidth, height)
        subView[2].frame = CGRectMake(screenWidth*2, 0, screenWidth, height)
        scrollView.contentOffset.x = screenWidth
        subView[0].reloadData()
        subView[1].reloadData()
        subView[2].reloadData()
        (subView[0].dataSource as! HomeWorkData).refreshData()
        (subView[1].dataSource as! HomeWorkData).refreshData()
        (subView[2].dataSource as! HomeWorkData).refreshData()
        */
    }
    
    func get_homework(date :String) -> [String]? {
        if (homework[date] != nil) {
            return homework[date]
        } else {
            let hw = getHWRecords(currentusername, date: date)
            if (hw != []) {
                homework[date] = hw
                return hw
            }
        }
        
        return nil
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lroundf(Float(self.scrollView.contentOffset.x / screenWidth))
        print("page =", page)

        // Switch table view to make scroll view can slide forever on one direction
        let frame0 : CGRect = subView[0].frame
        let frame1 : CGRect = subView[1].frame
        let frame2 : CGRect = subView[2].frame
        if (page == 0) {
            currentDate = currentDate.dateByAddingTimeInterval(-86400.0)

            let tempTV :UITableView = subView[2]
            subView[2] = subView[1]
            subView[1] = subView[0]
            subView[0] = tempTV
        } else if (page == 2) {
            currentDate = currentDate.dateByAddingTimeInterval(86400.0)

            let tempTV :UITableView = subView[0]
            subView[0] = subView[1]
            subView[1] = subView[2]
            subView[2] = tempTV
        }
        subView[0].frame = frame0
        subView[1].frame = frame1
        subView[2].frame = frame2
        self.scrollView.contentOffset.x = screenWidth
        
        if (page == 0) {
            // Update data for new yesterday
            show_and_download(self.currentDate.yesterday(), id: 0)
        } else if (page == 2) {
            // Update data for new tomorrow
            show_and_download(self.currentDate.tomorrow(), id: 2)
        }
        
        DateLabel.text = currentDate.getDateStr()
    }
    
    // show only
    func show_homework(date :NSDate, id: Int) {
        let day :String = date.getDateStr()
        var HW = get_homework(day)
        if (HW == nil) {
            HW = ["没有本地作业数据!"]
        }
        updateView(day ,hw: HW!)
    }
    
    // download only for today or no homework yet, e.g. support sliding left or right.
    func show_and_download(date :NSDate, id: Int) {
        let day :String = date.getDateStr()
        let HW = get_homework(day)
        if (HW != nil) {
            updateView(day ,hw: HW!)
            
            // Check if we need to update today, and we always update for today!
            var viewToday :Bool = false
            if (id == 0) {
                viewToday = (date.tomorrow().getDateStr() == NSDate().getDateStr())
            } else if (id == 2) {
                viewToday = (date.yesterday().getDateStr() == NSDate().getDateStr())
            } else if (id == 0) {
                viewToday = (date.getDateStr() == NSDate().getDateStr())
            }
            if (viewToday) {
                gethw(self.currentDate, id: id)
            }
        } else {
            updateView(day ,hw: ["没有本地作业数据!"])
            gethw(date, id: id)
        }
    }

    // Always download, e.g. supporting refresh
    func show_and_always_download(date :NSDate, id: Int) {
        show_homework(date, id: id)
        gethw(date, id: id)
    }

    class HomeWorkData: NSObject, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate {
        var id: Int
        var tv: UITableView
        var refresh: UIRefreshControl
        var webview :[UIWebView] = [ ]
        var tableData :[String] = [ ]
        var tableDataHeights : [CGFloat] = [ ]
        var hwcount :Int = 0
        var isBigFont :Bool = false
        
        init(id: Int, tv: UITableView, refresh :UIRefreshControl) {
            self.id = id
            self.tv = tv
            self.refresh = refresh

            // print("create all webViews")
            for i in 0...9 {
                tableData.append("")
                tableDataHeights.append(0.0)
                let frame: CGRect = CGRectMake(0, 0, tv.frame.size.width, 0.0)
                let hw_webview :UIWebView = UIWebView(frame: frame)
                hw_webview.tag = i
                hw_webview.scrollView.scrollEnabled = false
                hw_webview.scalesPageToFit = false
                hw_webview.allowsInlineMediaPlayback = true
                hw_webview.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
                hw_webview.opaque = false
                webview.append(hw_webview)
            }
            // tableData[0] = "没有作业"
        }
        
        func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            let link :NSString = request.URL!.relativeString!
            if (link == "about:blank") {
                return true
            } else {
                print(request.URL?.relativeString)
                UIApplication.sharedApplication().openURL(request.URL!)
                return false
            }
        }
        
        func enhance_html(html :String, isBigFont :Bool) -> String {
            /* disable user text selection in uiwebview. */
            // let new_html = "<style type=\"text/css\"> * { -webkit-touch-callout: none; -webkit-user-select: none; /* Disable selection/copy in UIWebView */ } </style>" + html
            let new_html = html
            if (isBigFont == true) {
                var hw_html = new_html
                hw_html = hw_html.stringByReplacingOccurrencesOfString("<font size=\"8\">", withString: "<font size=\"9\">")
                hw_html = hw_html.stringByReplacingOccurrencesOfString("<font size=\"7\">", withString: "<font size=\"8\">")
                hw_html = hw_html.stringByReplacingOccurrencesOfString("<font size=\"6\">", withString: "<font size=\"7\">")
                hw_html = hw_html.stringByReplacingOccurrencesOfString("<font size=\"5\">", withString: "<font size=\"6\">")
                hw_html = hw_html.stringByReplacingOccurrencesOfString("<font size=\"4\">", withString: "<font size=\"5\">")
                hw_html = hw_html.stringByReplacingOccurrencesOfString("<font size=\"3\">", withString: "<font size=\"4\">")
                hw_html = hw_html.stringByReplacingOccurrencesOfString("<font size=\"2\">", withString: "<font size=\"3\">")
                hw_html = hw_html.stringByReplacingOccurrencesOfString("<font size=\"1\">", withString: "<font size=\"2\">")
                return "<html><head><style type=\"text/css\">body {font-size: 22.0;}</style></head><body>"+hw_html+"</body></html>"
            }
            
            return new_html
        }
        
        func removeGuestureFromView(view: UIWebView) {
            if view.gestureRecognizers != nil {
                for gesture in view.gestureRecognizers! {
                    if let recognizer = gesture as? UISwipeGestureRecognizer {
                        view.removeGestureRecognizer(recognizer)
                    }
                }
            }
        }
        
        func refreshData(isBigFont :Bool) {
            // print("update data", data)
            let l = tableData.count
            hwcount = 0
            for i in 0...(l-1) {
                if (i < l) {
                    // let frame: CGRect = CGRectMake(0, 0, tv.frame.size.width, 0.0)
                    // webview[i].frame = frame
                    tableDataHeights[i] = 1.0
                    webview[i].delegate = self
                    NSURLCache.sharedURLCache().removeAllCachedResponses()
                    NSURLCache.sharedURLCache().diskCapacity = 0
                    NSURLCache.sharedURLCache().memoryCapacity = 0
                    self.removeGuestureFromView(webview[i])
                    webview[i].loadHTMLString(enhance_html(tableData[i], isBigFont: isBigFont), baseURL: nil)
                } else {
                    tableData[i] = ""
                    tableDataHeights[i] = 0.0
                }
            }
            hwcount = tableData.count
        }

        func updateData(data :[String], isBigFont :Bool) {
            // print("update data", data)
            self.tableData = data
            self.isBigFont = isBigFont
            refreshData(isBigFont)
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            // return self.tableData.count
            return hwcount
        }
        
        func tableView(tableView: UITableView,
            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        {
            let cell :UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell")
            
            // Reset cell, because cell is randomly reused from queue, and it may destroied before or reused fromm other cell.
            for view in cell.subviews  as [UIView] {
                if let web = view as? UIWebView {
                    web.removeFromSuperview()
                }
            }

            // Add webview back to current cell
            // print("add subview", indexPath.row)
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            cell.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
            /*
            let frame: CGRect = CGRectMake(0, 0, tv.frame.size.width, 0.0)
            let hw_webview :UIWebView = UIWebView(frame: frame)
            hw_webview.scrollView.scrollEnabled = false
            hw_webview.scalesPageToFit = false
            hw_webview.allowsInlineMediaPlayback = true
            hw_webview.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
            hw_webview.opaque = false
            */
            
            cell.addSubview(webview[indexPath.row])
            // webview[indexPath.row].loadHTMLString(enclose_fontsize(self.tableData[indexPath.row], isBigFont: isBigFont), baseURL: nil)
            return cell
        }
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
        {
            // Add an extra budget to show separator line.
            return tableDataHeights[indexPath.row] + 5.0
        }
        
        func webViewDidFinishLoad(webView: UIWebView) {
            if (tableDataHeights[webView.tag] != 1.0)
            {
                // we already know height, no need to reload cell
                return
            }
            
            tableDataHeights[webView.tag] = getWebviewHeight(webView)
            if (tableData[webView.tag] == "") {
                tableDataHeights[webView.tag] = 0.0
            }
            // print("webViewDidfinishLoad", id, webView.tag, tableDataHeights[webView.tag])
            // webView.stringByEvaluatingJavaScriptFromString("document[0].style.background='#2E2E2E'")
            dispatch_async(dispatch_get_main_queue(), {
                self.tv.reloadData()
            })
            // tv.reloadRowsAtIndexPaths([NSIndexPath(forRow: webView.tag, inSection: 0)], withRowAnimation: .Automatic)
        }
        
        // Get the height of a webview. This is a very tricky implementation, but it works!
        func getWebviewHeight(webView: UIWebView) -> CGFloat {
            webView.scrollView.scrollEnabled = false
            
            var frame :CGRect = webView.frame

            frame.size.height = 1
            // This statement is important to reset frame to a smaller one
            webView.frame = frame
            
            /* Solution 1 : */
            // let fittingSize :CGSize = webView.sizeThatFits(CGSizeZero);
            // frame.size = fittingSize;
            
            /* Solution 2 : */
            // frame.size.height = webView.scrollView.contentSize.height;
            
            /* Solution 3 : */
            // print(webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML"))
            let heightStr :String = webView.stringByEvaluatingJavaScriptFromString("document.height")!
            let height :CGFloat = CGFloat(NSNumberFormatter().numberFromString(heightStr)!)
            frame.size.height = height;
            
            webView.frame = frame;
            print("webview height =", frame.size.height)
            return webView.frame.height
        }
    }
    
    func updateView(date :String, hw :[String]) {
        var item :Int = -1;
        if (date == self.currentDate.getDateStr()) {
            item = 1
        }
        else if (date == self.currentDate.yesterday().getDateStr()) {
            item = 0
        }
        else if (date == self.currentDate.tomorrow().getDateStr()) {
            item = 2
        } else {
            return
        }
        
        (self.subView[item].dataSource as! HomeWorkData).updateData(hw, isBigFont: isBigFont)
        let refreshC = (self.subView[item].dataSource as! HomeWorkData).refresh
        refreshC.endRefreshing()
    }

    /* Assume login is successful and download homework content for current date.
       And then inform all tableviews by updating data sources. */
    func gethw(toDate :NSDate, id: Int) {
        if (!isLoggedIn) {
            return
        }
        
        downloadhw(toDate, id: id)
    }
    
    func downloadhw(toDate :NSDate, id: Int) {
        let dateStr = toDate.getDateStr()
        // updateView(dateStr ,hw: ["正在下载作业数据..."])
        dispatch_async(dispatch_get_main_queue(), {
            self.FushanLabel.text = "福外作业 - " + self.name + " ⬇️"
        });
        
        print("downloading homework", dateStr, "for page", id)
        self.downloadHomework(toDate, completion: { (vs, date, homework, error) -> Void in
            var hw :[String] = [ "" ]
            hw = self.parseHomework(date, homework: homework!)
            if (hw == []) {
                // This is probably a workaround, because the fushan network is unstable, and some times
                // the normal read can return empty although there are some homeworks. So we will try it
                // again by reading homework yesterday.
                
                // Try yesterday first
                print("try yesterday")
                
                self.viewState = vs
                self.downloadHomework(toDate.yesterday(), completion: { (vs, date, homework, error) -> Void in
                    print("try current date again")
                    // Try currentDate again
                    self.viewState = vs
                    self.downloadHomework(toDate, completion: { (vs, date, homework, error) -> Void in
                        var hw :[String] = [ "" ]
                        hw = self.parseHomework(date, homework: homework!)
                        if (hw == []) {
                            return
                        }
                        self.updateView(date, hw: hw)
                        dispatch_async(dispatch_get_main_queue(), {
                            print("refreshing data...")
                            self.FushanLabel.text = "福外作业 - " + self.name + " 🔵"
                            // self.subView[item].reloadData()
                        });
                    })
                })
            } else {
                self.updateView(date, hw: hw)
                dispatch_async(dispatch_get_main_queue(), {
                    print("refreshing data...")
                    self.FushanLabel.text = "福外作业 - " + self.name + " 🔵"
                    // self.subView[item].reloadData()
                });
            }
        })
    }
    
    /* Main function to get homework */
    func login_and_gethw() {
        ViewController.obtainViewState("http://"+self.fushan_web+"/jxq/jxq_User.aspx") { (vs, error) in
            if (error != nil) {
                self.alertmsg("请检查网络连接!")
                self.fushan_web = self.fushan_web2
                return
            }
            // print("viewstate is ready 1")
            self.viewState = vs!
            self.login() { (hellomsg, error) in
                /* try again */
                print("try again ...")
                ViewController.obtainViewState("http://"+self.fushan_web+"/jxq/jxq_User.aspx") { (vs, error) in
                    if (error != nil) {
                        self.alertmsg("请检查网络连接!")
                        return
                    }
                    // print("viewstate is ready 2")
                    self.viewState = vs!
                    self.login() { (hellomsg, error) in
                        if (hellomsg == "") {
                            // Fail due to incorrect username or password
                            self.loginTried = true
                            dispatch_async(dispatch_get_main_queue(), {
                                self.FushanLabel.text = "福外作业 - " + self.name + " 🔴"
                            });
                            return
                        }
                        self.isLoggedIn = true
                        ViewController.obtainViewState("http://"+self.fushan_web+"/jxq/jxq_User_jtzyck.aspx") { (vs, error) in
                            if (error != nil) {
                                self.alertmsg("请检查网络连接!")
                                return
                            }
                            print("got useful viewstate")
                            self.viewState = vs!
                            self.show_and_download(self.currentDate, id: 1)
                            self.show_and_download(self.currentDate.yesterday() ,id: 0)
                            self.show_and_download(self.currentDate.tomorrow(), id: 2)
                        }
                    }
                }
                // Usually we will never encounter this situation!
            }
        }
    }

    func logout_and_login_gethw() {
        ViewController.obtainViewState("http://"+self.fushan_web+"/jxq/jxq_User.aspx") { (vs, error) in
            if (error != nil) {
                self.alertmsg("请检查网络连接!")
                return
            }
            // print("viewstate is ready 1")
            self.viewState = vs!
            self.logout() {
                self.login_and_gethw()
            }
        }
    }

    /* Main function to get homework */
    func login_and_gethw_current_date() {
        dispatch_async(dispatch_get_main_queue(), {
            print("refreshing data...")
            self.FushanLabel.text = "福外作业 - " + self.name + " ⬇️"
        });
        ViewController.obtainViewState("http://"+self.fushan_web+"/jxq/jxq_User.aspx") { (vs, error) in
            if (error != nil) {
                self.alertmsg("请检查网络连接!")
                return
            }
            // print("viewstate is ready 1")
            self.viewState = vs!
            self.login() { (hellomsg, error) in
                /* try again */
                print("try again ...")
                ViewController.obtainViewState("http://"+self.fushan_web+"/jxq/jxq_User.aspx") { (vs, error) in
                    if (error != nil) {
                        self.alertmsg("请检查网络连接!")
                        return
                    }
                    // print("viewstate is ready 2")
                    self.viewState = vs!
                    self.login() { (hellomsg, error) in
                        if (hellomsg == "") {
                            // Fail due to incorrect username or password
                            self.loginTried = true
                            self.alertmsg("请检查用户名或口令!")
                            return
                        }
                        self.isLoggedIn = true
                        ViewController.obtainViewState("http://"+self.fushan_web+"/jxq/jxq_User_jtzyck.aspx") { (vs, error) in
                            if (error != nil) {
                                self.alertmsg("请检查网络连接!")
                                return
                            }
                            print("got useful viewstate")
                            self.viewState = vs!
                            
                            self.show_and_always_download(self.currentDate, id: 1)
                        }
                    }
                }
                // Usually we will never encounter this situation!
            }
        }
    }

    static func extractViewState(data :NSData) -> String {
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
        
        print("view state is extracted.")
        return vs;
    }
    
    static func obtainViewState(url: String, completion: (vs: String?, error: NSError?) -> Void) {
        /* The example of view state string is as below,
           <input type="hidden" name="__VIEWSTATE" value="dDwtMzI3NTUwMjExO3Q8O2w8aTwxPjs+O2w8dDw7bDxpPDU... " /> */
        let request = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        // print("Trying to get view state ...")
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            if (error != nil) {
                print("viewstate error=\(error)")
                completion(vs: nil, error: error)
                return
            }

            // let res = response as! NSHTTPURLResponse!
            // print("Response code:", res.statusCode)

            if (data != nil) {
                let vs = ViewController.extractViewState(data!)
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
        print("user="+self.currentusername+" password="+self.currentpassword)
        let username = "&login:tbxUserName="+self.currentusername
        let password = "&login:tbxPassword="+self.currentpassword
        let btnx="&login:btnlogin.x=27"
        let btny="&login:btnlogin.y=12"
        let vs_generator="&__VIEWSTATEGENERATOR=AC07AF0C"
        var postString = "__VIEWSTATE=" + viewState + vs_generator + username + password + btnx + btny
        postString = postString.stringByAddingPercentEncodingWithAllowedCharacters(urlBase64CharacterSet)!
        // print("post string is", postString)

        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        // let enc :NSStringEncoding = NSUTF8StringEncoding
        let request = NSMutableURLRequest(URL: NSURL(string: "http://"+self.fushan_web+"/jxq/jxq_User.aspx")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
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
                self.alertmsg("请检查网络连接!")
                return
            }
            
            // let res = response as! NSHTTPURLResponse!
            // print("Response code:", res.statusCode)
            
            // print("response = \(response)")
            let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let rawdata = NSString(data: data!, encoding: dec)
            let hellomsg = rawdata as! String
            
            if (hellomsg.rangeOfString("您好！欢迎使用") == nil) {
                // print("rawdata = \(rawdata)")
                print("login failed!")
                dispatch_async(dispatch_get_main_queue(), {
                    self.FushanLabel.text = "福外作业 - " + self.name + " 🔴"
                });
                completion(hellomsg: "", error: nil)
            } else {
                let names = self.matchesForRegexInText(">([^>]*)\\(家长\\)", text: hellomsg)
                self.name = names[0]
                let s = self.name.startIndex.advancedBy(1)
                let e = self.name.endIndex.advancedBy(-5)
                self.name = self.name.substringFromIndex(s).substringToIndex(e)
                self.storeUserData()
                print(self.name + " login passed!")
                dispatch_async(dispatch_get_main_queue(), {
                    self.FushanLabel.text = "福外作业 - " + self.name + " 🔵"
                    self.FushanLabel.setNeedsDisplay();
                });
                completion(hellomsg: hellomsg, error: nil)
            }
        }
        task.resume()
        /* No code should be after here. */
    }

    func logout(completion: () -> Void) {
        /* %2B + , %2F / , %3D = , %3A : */
        let urlBase64CharacterSet :NSCharacterSet = NSCharacterSet(charactersInString: "/:+").invertedSet
        // let viewstate = vs.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        // let viewstate = vs.stringByAddingPercentEncodingWithAllowedCharacters(urlBase64CharacterSet)!
        print("Logout: user="+self.currentusername+" password="+self.currentpassword)
        let btnx="&login:btnlogout.x=35"
        let btny="&login:btnlogout.y=13"
        var postString = "__VIEWSTATE=" + viewState + btnx + btny
        postString = postString.stringByAddingPercentEncodingWithAllowedCharacters(urlBase64CharacterSet)!
        // print("post string is", postString)
        
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        // let enc :NSStringEncoding = NSUTF8StringEncoding
        let request = NSMutableURLRequest(URL: NSURL(string: "http://"+self.fushan_web+"/jxq/jxq_User.aspx")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        let paramsLength = postString.lengthOfBytesUsingEncoding(enc)
        let postStringLen = "\(paramsLength)"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(postStringLen, forHTTPHeaderField: "Content-Length")
        
        let encoded_postString :NSData = postString.dataUsingEncoding(enc)!
        request.HTTPBody = encoded_postString
        request.HTTPMethod = "POST"
        
        let session = NSURLSession.sharedSession()
        print("Trying to logout ...")
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if (error != nil) {
                print("post error=\(error)")
                self.alertmsg("请检查网络连接!")
                return
            }
            
            // let res = response as! NSHTTPURLResponse!
            // print("Response code:", res.statusCode)
            
            // print("response = \(response)")
            let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let rawdata = NSString(data: data!, encoding: dec)
            let hellomsg = rawdata as! String
            
            if (hellomsg.rangeOfString("用户名：") == nil) {
                // print("rawdata = \(rawdata)")
                print("logout failed!")
            } else {
                print("logout passed!")
                dispatch_async(dispatch_get_main_queue(), {
                    self.FushanLabel.text = "福外作业"
                    self.FushanLabel.setNeedsDisplay();
                });
                completion()
            }
        }
        task.resume()
        /* No code should be after here. */
    }

    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func downloadHomework(toDate: NSDate, completion: (vs: String, date: String, homework: String?, error: NSError?) -> Void) {
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
        let request = NSMutableURLRequest(URL: NSURL(string: "http://"+self.fushan_web+"/jxq/jxq_User_jtzyck.aspx")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        let paramsLength = postString.lengthOfBytesUsingEncoding(enc)
        let postStringLen = "\(paramsLength)"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(postStringLen, forHTTPHeaderField: "Content-Length")
        let encoded_postString :NSData = postString.dataUsingEncoding(enc)!
        request.HTTPBody = encoded_postString
        request.HTTPMethod = "POST"
        
        let session = NSURLSession.sharedSession()
        // print("Trying to get homework data ...")
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if (error != nil) {
                print("post error=\(error)")
                self.alertmsg("请检查网络连接!")
                return
            }
            
            // let res = response as! NSHTTPURLResponse!
            // print("Response code:", res.statusCode)
            
            let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let rawdata = NSString(data: data!, encoding: dec)
            let homework = rawdata as! String
            self.viewState = ViewController.extractViewState(data!)
            
            if (homework.rangeOfString("您当前查看的是") == nil) {
                print("failed to obtain homework!")
                completion(vs: self.viewState, date: toDate.getDateStr(), homework: "", error: nil)
            } else {
                // print("rawdata = \(rawdata)")
                // print("homework obtained!")
                completion(vs: self.viewState, date: toDate.getDateStr(), homework: homework, error: nil)
            }
        }
        task.resume()
        /* No code should be after here. */
    }

    func parseHomework(date: String, homework :String) -> [String] {
        var hw :[String] = [ ]
        let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        if let doc = Kanna.HTML(html: homework, encoding: dec) {
            // Search for nodes by XPath
            let hw_index = doc.xpath("//b[contains(text(),'作业')]")
            for b in hw_index {
                let hw_content = doc.xpath("//b[contains(text(),'" + b.text! + "')]/../../following-sibling::tr[1]")
                var hw_html = hw_content.toHTML!
                hw_html = hw_html.stringByReplacingOccurrencesOfString("/jxq/UpLoadFolder/", withString: "http://"+self.fushan_web+"/jxq/UpLoadFolder/")
                hw_html = hw_html.stringByReplacingOccurrencesOfString("/WEBADMIN/", withString: "http://"+self.fushan_web+"/")
                hw.append(b.toHTML! + "<BR><BR>" + hw_html)
            }
            // hw.append("测试今日作业")
        }
        
        if (hw == []) {
            hw.append("今日没有作业")
        }
        print("Got homework for", date)
        
        // write to both memory and database
        self.homework[date] = hw
        createHWRecords(currentusername, date: date, HW: hw)
        
        // print(hw)
        return hw
    }
}