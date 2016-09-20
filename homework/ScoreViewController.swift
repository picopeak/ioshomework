//
//  ScoreViewController.swift
//  homework
//
//  Created by picopeak on 15/12/13.
//  Copyright © 2015年 fushan. All rights reserved.
//

import UIKit
import Kanna
import SQLite

protocol ScoreViewControllerDelegate {
    func didFinishScore(_ controller: ScoreViewController)
}

class ScoreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var scoreUIView: UIView!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var scoreView: UICollectionView!
    @IBOutlet weak var scoreTitle: UILabel!
    var delegate :ScoreViewControllerDelegate! = nil
    
    let courses :[String] = [ "语文", "数学", "英语" ]
    let grades :[String] = [ "六下", "六上", "五下", "五上", "四下", "四上", "三下", "三上", "二下", "二上", "一下", "一上" ]
    let terms :[String ] = [ "期末", "期中" ]
    
    var viewState :String = ""
    var scoremark :[String] = []
    var NumOfScore :Int = 1
    var NumOfScoreDisplaied = 1
    var Score :[[String]] = [[String]](repeating: [], count: 72)
    var ScoreInCourse :[[String]] = [[String]](repeating: [], count: 72)
    var ScoreInGrade :[[String]] = [[String]](repeating: [], count: 72)
    let reuseIdentifier :String = "ScoreCell"
    var username :String = ""
    var cellWidth :CGFloat = 0.0

    var db :Connection
    let scoretable :Table
    required init?(coder aDecoder: NSCoder) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        db = try! Connection("\(path)/db.sqlite3.homework")
        scoretable = Table("scoremark")
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        db = try! Connection("\(path)/db.sqlite3.homework")
        scoretable = Table("scoremark")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Score[0] = [ "课程", "年级", "学期", "成绩", "最高", "平均", "方差" ]
        ScoreInCourse[0] = [ "课程", "年级", "学期", "成绩", "最高", "平均", "方差" ]
        ScoreInGrade[0] = [ "课程", "年级", "学期", "成绩", "最高", "平均", "方差" ]
        
        // Create database now
        let id_field = Expression<Int64>("id")
        let user_field = Expression<String>("user")
        let course_field = Expression<String>("course")
        let grade_field = Expression<String>("grade")
        let term_field = Expression<String>("term")
        let score_mark_field = Expression<String>("score_mark")
        let top_field = Expression<String>("top")
        let avg_field = Expression<String>("avg")
        let score_variance_field = Expression<String>("score_variance")
        
        _ = try? db.run(scoretable.create(ifNotExists: true) { t in
            t.column(id_field, primaryKey: true)
            t.column(user_field)
            t.column(course_field)
            t.column(grade_field)
            t.column(term_field)
            t.column(score_mark_field)
            t.column(top_field)
            t.column(avg_field)
            t.column(score_variance_field)
        })

        // Load data from database first
        print("Reading score mark into database.")
        getScoreRecords(self.username)
        DispatchQueue.main.async(execute: {
            self.scoreView.reloadData()
        });
        
        // Do any additional setup after loading the view.
        NumOfScore = 1
        downloadScore()
    }

    func createScoreRecords(_ user :String) {
        // Remove old records from database
        let user_field = Expression<String>("user")
        let myscore = scoretable.filter(user_field == user)
        print("deleting old score record")
        _ = try? db.run(myscore.delete())
        
        // Insert new records into database
        print("writing new score record")
        for s in Score {
            if (s != [] && s[0] != "课程") {
                let user_field = Expression<String>("user")
                let course_field = Expression<String>("course")
                let grade_field = Expression<String>("grade")
                let term_field = Expression<String>("term")
                let score_mark_field = Expression<String>("score_mark")
                let top_field = Expression<String>("top")
                let avg_field = Expression<String>("avg")
                let score_variance_field = Expression<String>("score_variance")
                
                try! db.run(scoretable.insert(user_field <- username, course_field <- s[0], grade_field <- s[1], term_field <- s[2], score_mark_field <- s[3], top_field <- s[4], avg_field <- s[5], score_variance_field <- s[6]))
            }
        }
    }
    
    func getScoreRecords(_ user :String) {
        let user_field = Expression<String>("user")
        let course_field = Expression<String>("course")
        let grade_field = Expression<String>("grade")
        let term_field = Expression<String>("term")
        let score_mark_field = Expression<String>("score_mark")
        let top_field = Expression<String>("top")
        let avg_field = Expression<String>("avg")
        let score_variance_field = Expression<String>("score_variance")
        let query = scoretable.select(course_field, grade_field, term_field, score_mark_field, top_field, avg_field, score_variance_field).filter(user_field == user)
        
        print("querying score records")
        var i :Int = 1
        for s in try! db.prepare(query) {
            Score[i].append(s[course_field])
            Score[i].append(s[grade_field])
            Score[i].append(s[term_field])
            Score[i].append(s[score_mark_field])
            Score[i].append(s[top_field])
            Score[i].append(s[avg_field])
            Score[i].append(s[score_variance_field])
            i += 1
        }
        NumOfScoreDisplaied = i
    }

    func updateInfo(_ username :String) {
        self.username = username
    }
    
    // Protocol of UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.scoreData.text = Score[(indexPath as NSIndexPath).row / 7][(indexPath as NSIndexPath).row % 7]
        if ((indexPath as NSIndexPath).row / 7 == 0) {
            cell.scoreData.textColor = UIColor.white
            cell.scoreData.backgroundColor = UIColor.purple
            if ((indexPath as NSIndexPath).row % 7 == 0 || (indexPath as NSIndexPath).row % 7 == 1) {
                cell.scoreData.textColor = UIColor.black
                cell.scoreData.backgroundColor = UIColor.white
                cell.scoreData.layer.borderWidth = 1.0
                cell.scoreData.layer.cornerRadius = 5
            }
            // cell.scoreData.layer.borderWidth = 1.0;
        } else {
            cell.scoreData.backgroundColor = UIColor(red: (CGFloat)(117.0/255.0), green: (CGFloat)(70.0/255.0), blue: (CGFloat)(146.0/255.0), alpha: 0.4)
            cell.scoreData.textColor = UIColor.black
            cell.scoreData.layer.borderWidth = 0
            cell.scoreData.layer.cornerRadius = 0
            // cell.scoreData.layer.borderWidth = 1.0;
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NumOfScoreDisplaied * 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).row == 0) {
            // In grade order
            var m :Int = 1
            for j in 0..<courses.count {
                let g :String = courses[j]
                for k in 0..<terms.count {
                    let t :String = terms[k]
                    for i in 0..<NumOfScore {
                        let gr :String = Score[i][1];
                        let te :String = Score[i][2];
                        if (g != gr || t != te) {
                            continue
                        }
                        ScoreInGrade[m] = []
                        for n in 0..<7 {
                            ScoreInGrade[m].append(Score[i][n])
                        }
                        m += 1
                    }
                }
            }
            // In course order
            DispatchQueue.main.async(execute: {
                self.Score = self.ScoreInCourse
                self.NumOfScoreDisplaied = self.NumOfScore
                self.scoreView.reloadData()
            });
        } else if ((indexPath as NSIndexPath).row == 1) {
            // In grade order
            var m :Int = 1
            for j in 0..<grades.count {
                let g :String = grades[j]
                for k in 0..<terms.count {
                    let t :String = terms[k]
                    for i in 0..<NumOfScore {
                        let gr :String = Score[i][1];
                        let te :String = Score[i][2];
                        if (g != gr || t != te) {
                            continue
                        }
                        ScoreInGrade[m] = []
                        for n in 0..<7 {
                            ScoreInGrade[m].append(Score[i][n])
                        }
                        m += 1
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.Score = self.ScoreInGrade
                self.NumOfScoreDisplaied = self.NumOfScore
                self.scoreView.reloadData()
            });
        }
    }
    
    // Set up 7 cells in a row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellWidth = CGFloat(Int(collectionView.frame.size.width) / 7);
        // print("collectionView.frame.size.width = ", collectionView.frame.size.width, "cellWidth = ", cellWidth)
        return CGSize(width: cellWidth - 1, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0,0,0,0)
    }
    
    // End of protocol of UICollectionViewDataSource
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishScoreBtn(_ sender: UIButton) {
        delegate.didFinishScore(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        scoreUIView.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
        scoreView.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)

        finishBtn.layer.borderColor = UIColor.gray.cgColor
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

    func downloadScoreMark(_ url :String, completion: @escaping (_ score: String?, _ error: NSError?) -> Void) {
        let urlBase64CharacterSet :CharacterSet = CharacterSet(charactersIn: "/:+").inverted
        var postString = "__VIEWSTATE=" + viewState
            + "&ShowOtherTermScores=%CF%D4%CA%BE%CB%F9%D3%D0%B2%E2%CA%D4%B3%C9%BC%A8%BC%C7%C2%BC%A3%A8%B0%FC%C0%A8%C6%E4%CB%FB%D1%A7%C6%DA%A3%A9"
        postString = postString.addingPercentEncoding(withAllowedCharacters: urlBase64CharacterSet)!
        // print("post string is", postString)
        
        let enc: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
        let request = NSMutableURLRequest(url: URL(string: url)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData /* UseProtocolCachePolicy */, timeoutInterval:60.0)
        let paramsLength = postString.lengthOfBytes(using: enc)
        let postStringLen = "\(paramsLength)"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(postStringLen, forHTTPHeaderField: "Content-Length")
        let encoded_postString :Data = postString.data(using: enc)!
        request.httpBody = encoded_postString
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        // print("Trying to get homework data ...")
        let task = session.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if (error != nil) {
                print("post error=\(error)")
                DispatchQueue.main.async(execute: {
                    self.scoreTitle.text = self.username + " 成绩 🔴"
                });
                return
            }
            
            // let res = response as! NSHTTPURLResponse!
            // print("Response code:", res.statusCode)
            
            let dec: String.Encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let rawdata = NSString(data: data!, encoding: dec)
            let score = rawdata as! String
            self.viewState = ViewController.extractViewState(data!)
            
            // print(score)
            if (score.range(of: "欢迎使用") == nil) {
                print("failed to obtain homework!")
            } else {
                // print("rawdata = \(rawdata)")
                // print("homework obtained!")
                completion(score: score, error: nil)
            }
        }) 
        task.resume()
        /* No code should be after here. */
    }
    
    var items :[String] = [ "1", "2", "3" ]
    var item_id :Int = 0
    func downloadScore() {
        scoreTitle.text = self.username + " 成绩 ⬇️"
        
        let url :String = "http://www.fushanedu.cn/jxq/jxq_User_xscjcx_Sh.aspx?SubjectID="+items[item_id]
        ViewController.obtainViewState(url) { (vs, error) in
            if (error != nil) {
                DispatchQueue.main.async(execute: {
                    self.scoreTitle.text = self.username + " 成绩 🔴"
                });
                return
            }
            self.viewState = vs!
            self.downloadScoreMark(url, completion: { (score, error) -> Void in
                self.parseScoreMark(score!)
                if (self.item_id >= 2) {
                    print(self.Score)
                    print("NumOfScore=", self.NumOfScore)
                    print("Writing score mark into database.")
                    self.createScoreRecords(self.username)
                    DispatchQueue.main.async(execute: {
                        self.NumOfScoreDisplaied = self.NumOfScore
                        self.scoreTitle.text = self.username + " 成绩 🔵"
                        self.ScoreInCourse = self.Score
                        self.scoreView.reloadData()
                    });
                    return
                }
                self.item_id = self.item_id + 1
                self.downloadScore()
            })
        }
    }
    
    func parseScoreMark(_ score :String) {
        var ScoreMark :[String] = [String](repeating: "", count: 11)
        var FindScore :Bool = false
        var term :String = "";
    
        let dec: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
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
                i += 1
    
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
                    let range = Range<String.Index>(index..<index2)
                    Score[NumOfScore][2] = ScoreMark[1].substringWithRange(range)
                    Score[NumOfScore][3] = ScoreMark[2];
                    Score[NumOfScore][4] = ScoreMark[8];
                    Score[NumOfScore][5] = ScoreMark[9];
                    Score[NumOfScore][6] = ScoreMark[10];
                    
                    // Next Item
                    NumOfScore += 1;
                }
            }
        }
    }
}
