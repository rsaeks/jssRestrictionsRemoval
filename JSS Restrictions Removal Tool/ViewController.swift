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
        
    }
    
    @IBOutlet weak var jssURL: NSTextField!
    @IBOutlet weak var exclusionGID: NSTextField!
    @IBOutlet weak var jssUsername: NSTextField!
    @IBOutlet weak var jssPassword: NSSecureTextField!
    @IBOutlet weak var deviceSN: NSTextField!
    @IBOutlet weak var removeSuccess: NSImageView!
    @IBOutlet weak var removeUnknown: NSImageView!
    @IBOutlet weak var removeFail: NSImageView!
    @IBOutlet weak var reapplySuccess: NSImageView!
    @IBOutlet weak var reapplyUnknown: NSImageView!
    @IBOutlet weak var reapplyFail: NSImageView!
    @IBOutlet weak var jssConnectYes: NSImageView!
    @IBOutlet weak var jssConnectNo: NSImageView!
    @IBOutlet weak var jssConnectTBD: NSImageView!
    
    @IBAction func checkJSSURL(sender: NSButton) {
        jssConnectTBD.hidden = false
        jssConnectYes.hidden = true
        jssConnectNo.hidden = true
        
        // Get URL of site from server
        let r = Just.get(jssURL.stringValue, timeout:5.0)
        
        // As long as we get data back from server set status gem to green and hide red / grey
        if (r.url != nil ) {
            jssConnectTBD.hidden = true
            jssConnectYes.hidden = false
            removeSuccess.hidden = true
            removeFail.hidden = true
            removeUnknown.hidden = false
            reapplySuccess.hidden = true
            reapplyFail.hidden = true
            reapplyUnknown.hidden = false
        }
            // If we get back nil set status gem to red and hide green and grey
        else {
            jssConnectTBD.hidden = true
            jssConnectNo.hidden = false
            removeSuccess.hidden = true
            removeFail.hidden = true
            removeUnknown.hidden = false
            reapplySuccess.hidden = true
            reapplyFail.hidden = true
            reapplyUnknown.hidden = false
        }
        
    }
    
    @IBAction func removeRestrictions(sender: AnyObject) {
        removeSuccess.hidden = true
        removeFail.hidden = true
        removeUnknown.hidden = false
        let builtURL = jssURL.stringValue + "/JSSResource/mobiledevicegroups/id/" + exclusionGID.stringValue
        let addCommand  = "<mobile_device_group><mobile_device_additions><mobile_device><serial_number>" + deviceSN.stringValue + "</serial_number></mobile_device></mobile_device_additions></mobile_device_group>"
        let addCommandXML = try! NSXMLDocument(XMLString: addCommand, options: 0)
        let addCommandXMLStatus = Just.put(builtURL, auth: (jssUsername.stringValue, jssPassword.stringValue), headers: ["Content-Type":"text/xml"], requestBody: addCommandXML.XMLData)
        print(addCommandXMLStatus.statusCode)
        if (addCommandXMLStatus.statusCode == 201)
        {
            removeUnknown.hidden = true
            removeSuccess.hidden = false
            reapplyFail.hidden = true
            reapplySuccess.hidden = true
            reapplyUnknown.hidden = false
            
        }
        else {
            removeUnknown.hidden = true
            removeFail.hidden = false
            reapplyFail.hidden = true
            reapplySuccess.hidden = true
            reapplyUnknown.hidden = false
        }
    

    }
    
    @IBAction func reapplyRestrictions(sender: AnyObject) {
        reapplySuccess.hidden = true
        reapplyFail.hidden = true
        reapplyUnknown.hidden = false
        let builtURL = jssURL.stringValue + "/JSSResource/mobiledevicegroups/id/" + exclusionGID.stringValue
        let removeCommand  = "<mobile_device_group><mobile_device_deletions><mobile_device><serial_number>" + deviceSN.stringValue + "</serial_number></mobile_device></mobile_device_deletions></mobile_device_group>"
        let removeCommandXML = try! NSXMLDocument(XMLString: removeCommand, options: 0)
        let removeCommandXMLStatus = Just.put(builtURL, auth: (jssUsername.stringValue, jssPassword.stringValue), headers: ["Content-Type":"text/xml"], requestBody: removeCommandXML.XMLData)
        print(removeCommandXMLStatus.statusCode)
        if (removeCommandXMLStatus.statusCode == 201)
        {
            reapplyUnknown.hidden = true
            reapplySuccess.hidden = false
            removeUnknown.hidden = false
            removeSuccess.hidden = true
            removeFail.hidden = true
            
        }
        else {
            reapplyUnknown.hidden = true
            reapplyFail.hidden = false
            removeUnknown.hidden = false
            removeSuccess.hidden = true
            removeFail.hidden = true
        }

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}