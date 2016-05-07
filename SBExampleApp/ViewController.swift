//
//  ViewController.swift
//  SBExampleApp
//
//  Created by Gregory Hutchinson on 5/6/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func crashMe(sender: UIButton) {
        let array = NSArray()
        let _ = array.objectAtIndex(99)
    }
}
