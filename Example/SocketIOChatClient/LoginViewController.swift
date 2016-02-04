//
//  LoginViewController.swift
//  SocketIO
//
//  Created by Kenneth on 26/1/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: Init
    @IBOutlet weak var textField: UITextField!
    
    //MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = "蒼老師"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? ChatViewController else { return }
        vc.username = sender as? String
    }

    @IBAction func connectButtonTapped() {
        guard let username = textField.text else { return }
        if username.isEmpty { return }
        performSegueWithIdentifier("ChatViewControllerSegue", sender: username)
    }
}