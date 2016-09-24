//
//  LoginViewController.swift
//  homework
//
//  Created by picopeak on 15/10/24.
//  Copyright © 2015年 fushan. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func didFinishLogin(_ controller :LoginViewController, username :String, password :String, username2 :String, password2 :String, isUser2 :Bool, isBigFont :Bool)
}

class LoginViewController: UIViewController, ScoreViewControllerDelegate {

    @IBOutlet var loginView: UIView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName2: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userSwitch: UISwitch!
    @IBOutlet weak var fontSwitch: UISwitch!
    @IBOutlet weak var scoreBtn: UIButton!
    
    var delegate :LoginViewControllerDelegate! = nil
    
    fileprivate var oldUsername :String = ""
    fileprivate var oldPassword :String = ""
    fileprivate var oldUsername2 :String = ""
    fileprivate var oldPassword2 :String = ""
    fileprivate var oldisUser2 :Bool = false
    fileprivate var oldisBigFont :Bool = false
    fileprivate var newisUser2 :Bool = false
    fileprivate var newisBigFont :Bool = false
    fileprivate var name :String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scoreBtn.layer.borderColor = UIColor.gray.cgColor
        scoreBtn.layer.borderWidth = 1.0
        scoreBtn.layer.cornerRadius = 10; // this value vary as per your desire
        
        userName.text = oldUsername
        password.text = oldPassword
        userName2.text = oldUsername2
        password2.text = oldPassword2
    }

    @IBAction func showScore(_ sender: UIButton) {
        let vc :ScoreViewController = self.storyboard?.instantiateViewController(withIdentifier: "Score") as! ScoreViewController
        vc.delegate = self
        vc.updateInfo(self.name)
        self.present(vc, animated: false, completion: nil)
    }
    
    func didFinishScore(_ controller: ScoreViewController) {
        controller.dismiss(animated: false, completion: nil)
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loginView.backgroundColor = UIColor(red: (CGFloat)(0xF5)/255.0, green: (CGFloat)(0xF5)/255.0, blue: (CGFloat)(0xDC)/255.0, alpha: 1)
        userName.layer.borderColor = UIColor.black.cgColor
        userName.layer.borderWidth = 1.0
        userName.layer.backgroundColor = UIColor.white.cgColor
        
        password.layer.borderColor = UIColor.black.cgColor
        password.layer.borderWidth = 1.0
        password.layer.backgroundColor = UIColor.white.cgColor
        
        userName2.layer.borderColor = UIColor.black.cgColor
        userName2.layer.borderWidth = 1.0
        userName2.layer.backgroundColor = UIColor.white.cgColor
        
        password2.layer.borderColor = UIColor.black.cgColor
        password2.layer.borderWidth = 1.0
        password2.layer.backgroundColor = UIColor.white.cgColor

        loginBtn.layer.borderColor = UIColor.gray.cgColor
        loginBtn.layer.borderWidth = 1.0
        loginBtn.layer.cornerRadius = 10; // this value vary as per your desire

        userSwitch.setOn(oldisUser2, animated: false)
        fontSwitch.setOn(oldisBigFont, animated: false)
        
        scoreBtn.becomeFirstResponder()
        
        /*
        if (oldisUser2) {
            userName2.becomeFirstResponder()
        } else {
            userName.becomeFirstResponder()
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: AnyObject) {
        delegate.didFinishLogin(self, username: userName.text!, password: password.text!, username2: userName2.text!, password2: password2.text!, isUser2: newisUser2, isBigFont: newisBigFont)
    }

    func updateInfo(_ username :String, password :String, username2 :String, password2 :String, isUser2 :Bool, isBigFont :Bool, name :String) {
        oldUsername = username
        oldPassword = password
        oldUsername2 = username2
        oldPassword2 = password2
        oldisUser2 = isUser2
        oldisBigFont = isBigFont
        newisUser2 = isUser2
        newisBigFont = isBigFont
        self.name = name
    }
    
    @IBAction func applyUser2(_ sender: UISwitch) {
        newisUser2 = sender.isOn
        if (newisUser2) {
            userName2.becomeFirstResponder()
        } else {
            userName.becomeFirstResponder()
        }
    }
    
    @IBAction func applyBigFont(_ sender: UISwitch) {
        newisBigFont = sender.isOn
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
