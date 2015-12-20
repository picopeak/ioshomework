//
//  ScoreViewController.swift
//  homework
//
//  Created by picopeak on 15/12/13.
//  Copyright © 2015年 fushan. All rights reserved.
//

import UIKit
import Kanna

protocol ScrollViewControllerDelegate {
    func didFinishScore(controller: ScoreViewController)
}

class ScoreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var scoreUIView: UIView!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var scoreView: UICollectionView!
    var delegate :ScrollViewControllerDelegate! = nil
    
    let courses :[String] = [ "语文", "数学", "英语" ]
    let grades :[String] = [ "六下", "六上", "五下", "五上", "四下", "四上", "三下", "三上", "二下", "二上", "一下", "一上" ]
    let terms :[String ] = [ "期末", "期中" ]
    
    var viewState :String = ""
    var scoremark :[String] = []
    var NumOfScore :Int = 1
    var Score :[[String]] = [[String]](count:72, repeatedValue: [])
    let reuseIdentifier = "ScoreCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        Score[0] = [ "课程", "年级", "学期", "成绩", "最高", "平均", "方差" ]
        // Do any additional setup after loading the view.
        downloadScore()
    }
    
    // Protocol of UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        cell.scoreData.text = Score[indexPath.row / 7][indexPath.row % 7]
        if (indexPath.row / 7 == 0) {
            cell.scoreData.backgroundColor = UIColor.purpleColor()
            cell.scoreData.textColor = UIColor.whiteColor()
        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NumOfScore * 7
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    // Set up 7 cells in a row
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width/7, 20)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0,0,0,0)
    }
    
    // End of protocol of UICollectionViewDataSource
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishScoreBtn(sender: UIButton) {
        delegate.didFinishScore(self)
    }

    override func viewWillAppear(animated: Bool) {
        scoreUIView.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
        scoreView.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)

        finishBtn.layer.borderColor = UIColor.grayColor().CGColor
        finishBtn.layer.borderWidth = 1.0
        finishBtn.layer.cornerRadius = 10; // this value vary as per your desire
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func downloadScoreMark(url :String, completion: (score: String?, error: NSError?) -> Void) {
        let urlBase64CharacterSet :NSCharacterSet = NSCharacterSet(charactersInString: "/:+").invertedSet
        var postString = "__VIEWSTATE=" + viewState
            + "&ShowOtherTermScores=%CF%D4%CA%BE%CB%F9%D3%D0%B2%E2%CA%D4%B3%C9%BC%A8%BC%C7%C2%BC%A3%A8%B0%FC%C0%A8%C6%E4%CB%FB%D1%A7%C6%DA%A3%A9"
        postString = postString.stringByAddingPercentEncodingWithAllowedCharacters(urlBase64CharacterSet)!
        // print("post string is", postString)
        
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let request = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
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
                return
            }
            
            // let res = response as! NSHTTPURLResponse!
            // print("Response code:", res.statusCode)
            
            let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let rawdata = NSString(data: data!, encoding: dec)
            let score = rawdata as! String
            self.viewState = ViewController.extractViewState(data!)
            
            // print(score)
            if (score.rangeOfString("欢迎使用") == nil) {
                print("failed to obtain homework!")
            } else {
                // print("rawdata = \(rawdata)")
                // print("homework obtained!")
                completion(score: score, error: nil)
            }
        }
        task.resume()
        /* No code should be after here. */
    }
    
    var items :[String] = [ "1", "2", "3" ]
    var item_id :Int = 0
    func downloadScore() {
        let url :String = "http://www.fushanedu.cn/jxq/jxq_User_xscjcx_Sh.aspx?SubjectID="+items[item_id]
        ViewController.obtainViewState(url) { (vs, error) in
            if (error != nil) {
                return
            }
            self.viewState = vs!
            self.downloadScoreMark(url, completion: { (score, error) -> Void in
                if (error != nil) {
                    return
                }
                
                self.parseScoreMark(score!)
                if (self.item_id >= 2) {
                    print(self.Score)
                    print("NumOfScore=", self.NumOfScore)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.scoreView.reloadData()
                    });
                    return
                }
                self.item_id++
                self.downloadScore()
            })
        }
    }
    
    func parseScoreMark(score :String) {
        var ScoreMark :[String] = [String](count:11, repeatedValue: "")
        var FindScore :Bool = false
        var term :String = "";
    
        let dec: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        if let doc = Kanna.HTML(html: score, encoding: dec) {
            // Search for nodes by XPath
            var i = 0
            let span_index = doc.xpath("//span")
            for b in span_index {
                let s :String = b.text!
                if (s.rangeOfString("欢迎使用") != nil) {
                    FindScore = true
                    continue
                }
                
				// Make sure score data is obtained, and return immediately otherwise.
                if (!FindScore) {
                    continue
                }
    
                // Skip the case like "2013学年第二学期", and keep the case like "2014学年第一学期二年级数学期中练习"
                if (s.rangeOfString("学年第") != nil && s.rangeOfString("年级") == nil) {
                    if (s.rangeOfString("第一") != nil) {
                        term="上"
                    }
                    else if (s.rangeOfString("第二") != nil) {
                        term="下"
                    }
                    continue
                }

                ScoreMark[i] = s
                i++
    
                // pass 考试名称 考试类型 成 绩 距均值 附加分 AB卷 满分 及格分 班最高分 班平均分 班标准差
                if (i>10) {
                    // Reset back to next score item
                    i = 0
    
                    Score[NumOfScore] = [String](count:7, repeatedValue: "")
    
                    let m :String = ScoreMark[0];
                    // check term
                    if (m.rangeOfString("第一") != nil) {
                        term="上"
                    }
                    else if (m.rangeOfString("第二") != nil) {
                        term="下"
                    }
                    // check course
                    if (m.rangeOfString("数学") != nil) {
                        Score[NumOfScore][0] = "数学"
                    }
                    else if (m.rangeOfString("语文") != nil) {
                        Score[NumOfScore][0] = "语文"
                    }
                    else if (m.rangeOfString("英语") != nil) {
                        Score[NumOfScore][0] = "英语"
                    }
                    // check grade
                    if (m.rangeOfString("一年级") != nil) {
                        Score[NumOfScore][1] = "一"
                    }
                    else if (m.rangeOfString("二年级") != nil) {
                        Score[NumOfScore][1] = "二"
                    }
                    else if (m.rangeOfString("三年级") != nil) {
                        Score[NumOfScore][1] = "三"
                    }
                    else if (m.rangeOfString("四年级") != nil) {
                        Score[NumOfScore][1] = "四"
                    }
                    else if (m.rangeOfString("五年级") != nil) {
                        Score[NumOfScore][1] = "五"
                    }
                    else if (m.rangeOfString("六年级") != nil) {
                        Score[NumOfScore][1] = "六"
                    }
                    Score[NumOfScore][1] = Score[NumOfScore][1] + term
                    let index = s.startIndex.advancedBy(0) //swift 2.0+
                    let index2 = s.startIndex.advancedBy(2) //swift 2.0+
                    let range = Range<String.Index>(start: index, end: index2)
                    Score[NumOfScore][2] = ScoreMark[1].substringWithRange(range)
                    Score[NumOfScore][3] = ScoreMark[2];
                    Score[NumOfScore][4] = ScoreMark[8];
                    Score[NumOfScore][5] = ScoreMark[9];
                    Score[NumOfScore][6] = ScoreMark[10];
                    
                    // Next Item
                    NumOfScore++;
                }
            }
        }
    }
    
    
}
