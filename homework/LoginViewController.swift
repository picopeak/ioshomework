//
//  LoginViewController.swift
//  homework
//
//  Created by picopeak on 15/10/24.
//  Copyright © 2015年 fushan. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func didFinishLogin(controller :LoginViewController, username :String, password :String)
}

class LoginViewController: UIViewController {

    @IBOutlet var loginView: UIView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName2: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var delegate :LoginViewControllerDelegate! = nil
    
    private var oldUsername :String = ""
    private var oldPassword :String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        userName.text = oldUsername
        password.text = oldPassword
    }
    
    override func viewWillAppear(animated: Bool) {
        loginView.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
        userName.layer.borderColor = UIColor.blackColor().CGColor
        userName.layer.borderWidth = 1.0
        userName.layer.backgroundColor = UIColor.whiteColor().CGColor
        userName.becomeFirstResponder()
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(sender: AnyObject) {
        delegate.didFinishLogin(self, username: userName.text!, password: password.text!)
    }

    func updateInfo(username :String, password :String) {
        oldUsername = username
        oldPassword = password
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
