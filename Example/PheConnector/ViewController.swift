//
//  ViewController.swift
//  PheConnector
//
//  Created by Afriyandi Setiawan on 08/01/2017.
//  Copyright (c) 2017 Afriyandi Setiawan. All rights reserved.
//

import UIKit
import PheConnector

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func post(_ sender: UIButton) {
        phe.routine(Users.login(uName: "Phe", pass: "secure_password123")) { (isSuccess, arg1) in
            switch isSuccess {
            case true:
                debugPrint(arg1.json)
            case false:
                debugPrint(arg1.error)
            }
        }
    }
    @IBAction func get(_ sender: UIButton) {
        phe.routine(Users.getUser(userName: "Phe")) { (isSuccess, arg1) in
            switch isSuccess {
            case true:
                debugPrint(arg1.json)
            case false:
                debugPrint(arg1.error)
            }
        }
    }
}

