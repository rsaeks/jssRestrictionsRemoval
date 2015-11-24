//
//  ViewController.swift
//  JSS Restrictions Removal Tool
//
//  Created by Randy Saeks on 11/23/15.
//  Copyright © 2015 Randy Saeks. All rights reserved.
//

import Cocoa
import Just



class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // DEBUG: Console Output for loading the app
        print("View did Load")
    }
    // Create Connection to JSS URL from Text Box
    @IBOutlet weak var jssURL: NSTextField!
    
    //Initialize Connection to JSS Status indicator gems
    @IBOutlet weak var jssConnectYes: NSImageView!
    @IBOutlet weak var jssConnectNo: NSImageView!
    @IBOutlet weak var jssConnectTBD: NSImageView!
    
    @IBAction func checkJSSURL(sender: NSButton) {
        // Reset gems
        jssConnectTBD.hidden = false
        jssConnectYes.hidden = true
        jssConnectNo.hidden = true
        
        //DEBUG: Console output to button pressed
        print ("Button Pressed")
        
        //DEBUG: Console output of URL of JSS
        print (jssURL.stringValue)
        
        // Get URL of site from server
        let r = Just.get(jssURL.stringValue)
        
        //DEBUG: Print the data returned by server
        print(r.url)
        
        // As long as we get data back from server set status gem to green and hide red / grey
        if (r.url != nil ) {
            jssConnectTBD.hidden = true
            jssConnectYes.hidden = false
        }
            // If we get back nil set status gem to red and hide green and grey
        else {
            jssConnectTBD.hidden = true
            jssConnectNo.hidden = false
        }
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

