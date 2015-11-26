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
        // To Do:
        // Read jssURL.stringValue from User-based preference
        // Read exclusionGID.stringValue from User-based preference
        // Read jssUsername.stringValue from User-based preference
        
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
    @IBOutlet weak var invalidGIDorSN: NSTextField!
    @IBOutlet weak var otherError: NSTextField!
    @IBOutlet weak var unableToConnectJSS: NSTextField!
    @IBOutlet weak var invalidPassword: NSTextField!
    @IBOutlet weak var removeEnabled: NSButton!
    @IBOutlet weak var reapplyEnabled: NSButton!
    @IBAction func checkJSSURL(sender: NSButton) {
        // jssConnectTBD.hidden = false
        // jssConnectYes.hidden = true
        // jssConnectNo.hidden = true
        
        
        // Get URL of site from server
        let r = Just.get(jssURL.stringValue, timeout:5.0)
        
        // As long as we get data back from server set status gem to green and hide red / grey
        if (r.url != nil ) {
            resetStatus()
            jssConnectTBD.hidden = true
            jssConnectYes.hidden = false
            removeEnabled.enabled = true
            reapplyEnabled.enabled = true
        }
            // If we get back nil set status gem to red and hide green and grey
        else {
            resetStatus()
            jssConnectTBD.hidden = true
            jssConnectNo.hidden = false
            unableToConnectJSS.hidden = false
            removeEnabled.enabled = false
            reapplyEnabled.enabled = false
        }
        
    }
    
    @IBAction func removeRestrictions(sender: AnyObject) {
        resetStatus()
        jssConnectYes.hidden = false
        let builtURL = jssURL.stringValue + "/JSSResource/mobiledevicegroups/id/" + exclusionGID.stringValue
        let addCommand  = "<mobile_device_group><mobile_device_additions><mobile_device><serial_number>" + deviceSN.stringValue + "</serial_number></mobile_device></mobile_device_additions></mobile_device_group>"
        let addCommandXML = try! NSXMLDocument(XMLString: addCommand, options: 0)
        let addCommandXMLStatus = Just.put(builtURL, auth: (jssUsername.stringValue, jssPassword.stringValue), headers: ["Content-Type":"text/xml"], requestBody: addCommandXML.XMLData)
        print(addCommandXMLStatus.statusCode)
        if (addCommandXMLStatus.statusCode == 201)
        {
            resetStatus()
            jssConnectYes.hidden = false
            removeSuccess.hidden = false
        }
        else if (addCommandXMLStatus.statusCode == 401) {
            resetStatus()
            jssConnectYes.hidden = false
            removeFail.hidden = false
            invalidPassword.hidden = false

        }
        else if (addCommandXMLStatus.statusCode == 404) {
            resetStatus()
            jssConnectYes.hidden = false
            removeFail.hidden = false
            invalidGIDorSN.hidden = false
        }
        else {
            resetStatus()
            jssConnectYes.hidden = false
            removeFail.hidden = false
            otherError.hidden = false
        }
    

    }
    
    @IBAction func reapplyRestrictions(sender: AnyObject) {
        resetStatus()
        jssConnectYes.hidden = false
        let builtURL = jssURL.stringValue + "/JSSResource/mobiledevicegroups/id/" + exclusionGID.stringValue
        let removeCommand  = "<mobile_device_group><mobile_device_deletions><mobile_device><serial_number>" + deviceSN.stringValue + "</serial_number></mobile_device></mobile_device_deletions></mobile_device_group>"
        let removeCommandXML = try! NSXMLDocument(XMLString: removeCommand, options: 0)
        let removeCommandXMLStatus = Just.put(builtURL, auth: (jssUsername.stringValue, jssPassword.stringValue), headers: ["Content-Type":"text/xml"], requestBody: removeCommandXML.XMLData)
        print(removeCommandXMLStatus.statusCode)
        if (removeCommandXMLStatus.statusCode == 201)
        {
            resetStatus()
            jssConnectYes.hidden = false
            reapplySuccess.hidden = false
            
        }
        else if (removeCommandXMLStatus.statusCode == 401) {
            resetStatus()
            jssConnectYes.hidden = false
            reapplyFail.hidden = false
            invalidPassword.hidden = false
        }
        else if (removeCommandXMLStatus.statusCode == 404) {
            resetStatus()
            jssConnectYes.hidden = false
            reapplyFail.hidden = false
            reapplyUnknown.hidden = true
            invalidGIDorSN.hidden = false
        }
        else {
            resetStatus()
            jssConnectYes.hidden = false
            reapplyFail.hidden = false
            otherError.hidden = false
        }

    }

    @IBAction func saveSettings(sender: AnyObject) {
        // To Do:
        // Save jssURL.stringValue to User-based preference
        // Save exceptionGID.stringValue to User-based preference
        // Save jssUsername.stingValue to User-based preference
    }
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    func resetStatus() {
        jssConnectTBD.hidden = false
        jssConnectYes.hidden = true
        jssConnectNo.hidden = true
        removeSuccess.hidden = true
        removeFail.hidden = true
        removeUnknown.hidden = false
        reapplySuccess.hidden = true
        reapplyFail.hidden = true
        reapplyUnknown.hidden = false
        unableToConnectJSS.hidden = true
        invalidPassword.hidden = true
        invalidGIDorSN.hidden = true
        otherError.hidden = true
        
    }
    
}