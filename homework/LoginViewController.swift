//
//  LoginViewController.swift
//  homework
//
//  Created by picopeak on 15/10/24.
//  Copyright © 2015年 fushan. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func didFinishLogin(controller :LoginViewController, username :String, password :String, username2 :String, password2 :String, isUser2 :Bool, isBigFont :Bool)
}

class LoginViewController: UIViewController {

    @IBOutlet var loginView: UIView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName2: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userSwitch: UISwitch!
    @IBOutlet weak var fontSwitch: UISwitch!
    
    var delegate :LoginViewControllerDelegate! = nil
    
    private var oldUsername :String = ""
    private var oldPassword :String = ""
    private var oldUsername2 :String = ""
    private var oldPassword2 :String = ""
    private var oldisUser2 :Bool = false
    private var oldisBigFont :Bool = false
    private var newisUser2 :Bool = false
    private var newisBigFont :Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        userName.text = oldUsername
        password.text = oldPassword
        userName2.text = oldUsername2
        password2.text = oldPassword2
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        loginView.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
        userName.layer.borderColor = UIColor.blackColor().CGColor
        userName.layer.borderWidth = 1.0
        userName.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        password.layer.borderColor = UIColor.blackColor().CGColor
        password.layer.borderWidth = 1.0
        password.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        userName2.layer.borderColor = UIColor.blackColor().CGColor
        userName2.layer.borderWidth = 1.0
        userName2.layer.backgroundColor = UIColor.whiteColor().CGColor
        userName2.becomeFirstResponder()
        
        password2.layer.borderColor = UIColor.blackColor().CGColor
        password2.layer.borderWidth = 1.0
        password2.layer.backgroundColor = UIColor.whiteColor().CGColor

        loginBtn.layer.borderColor = UIColor.grayColor().CGColor
        loginBtn.layer.borderWidth = 1.0
        loginBtn.layer.cornerRadius = 10; // this value vary as per your desire
        
        userSwitch.setOn(oldisUser2, animated: false)
        fontSwitch.setOn(oldisBigFont, animated: false)
        
        if (oldisUser2) {
            userName2.becomeFirstResponder()
        } else {
            userName.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(sender: AnyObject) {
        delegate.didFinishLogin(self, username: userName.text!, password: password.text!, username2: userName2.text!, password2: password2.text!, isUser2: newisUser2, isBigFont: newisBigFont)
    }

    func updateInfo(username :String, password :String, username2 :String, password2 :String, isUser2 :Bool, isBigFont :Bool) {
        oldUsername = username
        oldPassword = password
        oldUsername2 = username2
        oldPassword2 = password2
        oldisUser2 = isUser2
        oldisBigFont = isBigFont
        newisUser2 = isUser2
        newisBigFont = isBigFont
    }
    
    @IBAction func applyUser2(sender: UISwitch) {
        newisUser2 = sender.on
        if (newisUser2) {
            userName2.becomeFirstResponder()
        } else {
            userName.becomeFirstResponder()
        }
    }
    
    @IBAction func applyBigFont(sender: UISwitch) {
        newisBigFont = sender.on
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
