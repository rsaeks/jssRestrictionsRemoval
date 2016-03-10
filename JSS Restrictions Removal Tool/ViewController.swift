//
//  ViewController.swift
//  JSS Restrictions Removal Tool
//
//  Created by Randy Saeks on 11/23/15.
//  Copyright © 2015 Randy Saeks. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check for saved preferences and read them
        let kJSSURLCheck = NSUserDefaults.standardUserDefaults().objectForKey("kJSSURL")
        if (kJSSURLCheck != nil) {
            jssURL.stringValue = NSUserDefaults.standardUserDefaults().objectForKey("kJSSURL") as! String
        }

        let kexclusionGIDCheck = NSUserDefaults.standardUserDefaults().objectForKey("kJSSURL")
        if (kexclusionGIDCheck != nil) {
            exclusionGID.stringValue = NSUserDefaults.standardUserDefaults().objectForKey("kexclusionGID") as! String
        }
        
        let kJSSUsernameCheck = NSUserDefaults.standardUserDefaults().objectForKey("kJSSUsername")
        if (kJSSUsernameCheck != nil) {
            jssUsername.stringValue = NSUserDefaults.standardUserDefaults().objectForKey("kJSSUsername") as! String
        }
        
    }
    // Connections to our Main.storyboard are defined below
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
    @IBOutlet weak var CheckURLButton: NSButton!
    @IBOutlet weak var deleteSuccess: NSImageView!
    @IBOutlet weak var deleteFailed: NSImageView!
    @IBOutlet weak var deleteDeviceButton: NSButton!
    @IBOutlet weak var userNameToCheck: NSTextField!
    @IBOutlet weak var deviceSNLabel: NSTextField!
    @IBOutlet weak var deviceNameLabel: NSTextField!
    @IBOutlet weak var deviceMACLabel: NSTextField!
    @IBOutlet weak var deviceIPLabel: NSTextField!
    @IBOutlet weak var deviceINVLabel: NSTextField!
    @IBOutlet weak var userCheckButton: NSButton!

    // Globals for API Paths
    let devAPIPath = "/JSSResource/mobiledevicegroups/id/"
    let devAPIMatchPath = "/JSSResource/mobiledevices/match/"
    let devAPISNPatch = "/JSSResource/mobiledevices/serialnumber/"
    
    // Run this function when clicking "Check" for JSS URL
    @IBAction func checkJSSURL(sender: NSButton) {
        
        // If there is a trailing slash in the JSS URL, remove.
        if (jssURL.stringValue.characters.last == "/") {
            jssURL.stringValue = jssURL.stringValue.substringToIndex(jssURL.stringValue.endIndex.predecessor())
        }
        
        // Test connection to JSS
        let testConn = Just.get(jssURL.stringValue, timeout:5.0)
       
        if (testConn.statusCode != nil) {
            resetStatus()
            jssConnectTBD.hidden = true
            jssConnectYes.hidden = false
            removeEnabled.enabled = true
            reapplyEnabled.enabled = true
            userCheckButton.enabled = true
        }

        else {
            resetStatus()
            jssConnectTBD.hidden = true
            jssConnectNo.hidden = false
            unableToConnectJSS.hidden = false
            removeEnabled.enabled = false
            reapplyEnabled.enabled = false
            CheckURLButton.hidden = false
        }
        
    }
    @IBAction func openJSSURLInBrowser(sender: AnyObject) {
        let baseURL = NSURL(string: jssURL.stringValue)
        NSWorkspace.sharedWorkspace().openURL(baseURL!)
    }
    
    // Run this function when clicking "Remove Settings"
    @IBAction func removeRestrictions(sender: AnyObject) {
        resetStatus()
        jssConnectYes.hidden = false
        let builtURL = jssURL.stringValue + devAPIPath + exclusionGID.stringValue
        let addCommand  = "<mobile_device_group><mobile_device_additions><mobile_device><serial_number>" + deviceSN.stringValue + "</serial_number></mobile_device></mobile_device_additions></mobile_device_group>"
        let addCommandXML = try! NSXMLDocument(XMLString: addCommand, options: 0)
        let addCommandXMLStatus = Just.put(builtURL, auth: (jssUsername.stringValue, jssPassword.stringValue), headers: ["Content-Type":"text/xml"], requestBody: addCommandXML.XMLData)
       
        // Successful PUT
        if (addCommandXMLStatus.statusCode == 201) {
            resetStatus()
            jssConnectYes.hidden = false
            removeSuccess.hidden = false
            deleteDeviceButton.enabled = true
            
        }
        // Unauthorized PUT result
        else if (addCommandXMLStatus.statusCode == 401) {
            resetStatus()
            jssConnectYes.hidden = false
            removeFail.hidden = false
            invalidPassword.hidden = false

        }
        // Not found PUT result
        else if (addCommandXMLStatus.statusCode == 404 || addCommandXMLStatus.statusCode == 409) {
            resetStatus()
            jssConnectYes.hidden = false
            removeFail.hidden = false
            invalidGIDorSN.hidden = false
        }
        // Other PUT errors
        else {
            resetStatus()
            jssConnectYes.hidden = false
            removeFail.hidden = false
            otherError.hidden = false
        }
    }
    
    // Run this funtion when clicking "Reapply Settings"
    @IBAction func reapplyRestrictions(sender: AnyObject) {
        resetStatus()
        jssConnectYes.hidden = false
        let builtURL = jssURL.stringValue + devAPIPath + exclusionGID.stringValue
        let removeCommand  = "<mobile_device_group><mobile_device_deletions><mobile_device><serial_number>" + deviceSN.stringValue + "</serial_number></mobile_device></mobile_device_deletions></mobile_device_group>"
        let removeCommandXML = try! NSXMLDocument(XMLString: removeCommand, options: 0)
        let removeCommandXMLStatus = Just.put(builtURL, auth: (jssUsername.stringValue, jssPassword.stringValue), headers: ["Content-Type":"text/xml"], requestBody: removeCommandXML.XMLData)

        // Successful PUT
        if (removeCommandXMLStatus.statusCode == 201) {
            resetStatus()
            jssConnectYes.hidden = false
            reapplySuccess.hidden = false
            
        }
        // Unauthorized PUT result
        else if (removeCommandXMLStatus.statusCode == 401) {
            resetStatus()
            jssConnectYes.hidden = false
            reapplyFail.hidden = false
            invalidPassword.hidden = false
        }
        // Not found PUT result
        else if (removeCommandXMLStatus.statusCode == 404 || removeCommandXMLStatus.statusCode == 409) {
            resetStatus()
            jssConnectYes.hidden = false
            reapplyFail.hidden = false
            invalidGIDorSN.hidden = false
        }
        // Other PUT errors
        else {
            resetStatus()
            jssConnectYes.hidden = false
            reapplyFail.hidden = false
            otherError.hidden = false
        }

    }

    // Run this when clicking delete device button
    @IBAction func deleteDevice(sender: AnyObject) {
        resetStatus()
        let removeURL=jssURL.stringValue + devAPIMatchPath + deviceSN.stringValue
        let deviceData = Just.get(removeURL, auth: (jssUsername.stringValue, jssPassword.stringValue)).text! as String
        // Check for an authentication error.
        if (deviceData.rangeOfString("authentication") != nil) {
            invalidPassword.hidden = false
            deleteFailed.hidden = false
        }
        // Check for returned number of items being equal to 1 device.
        else if (deviceData.rangeOfString("<size>1") != nil) {
            var subStr = deviceData[deviceData.startIndex.advancedBy(83)...deviceData.startIndex.advancedBy(100)]
            subStr = subStr.stringByReplacingOccurrencesOfString("<id>", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let IDNumber = subStr.componentsSeparatedByString("<")[0]
            let deleteDevice = Just.delete(jssURL.stringValue + devAPIPath + IDNumber, auth: (jssUsername.stringValue, jssPassword.stringValue))
            print (deleteDevice.statusCode)
            // Check the response code of the delete command.
            if (deleteDevice.ok) {
                deleteSuccess.hidden = false
                deleteDeviceButton.enabled = false
            }
            
            else {
                deleteFailed.hidden = false
                otherError.hidden = false
            }
    }
        //Catch all other errors getting device data.
        else {
            invalidGIDorSN.hidden = false
            deleteFailed.hidden = false
        }
    }
    
    @IBAction func FindUserInfo(sender: AnyObject) {
        resetStatus()
        let userData = Just.get(jssURL.stringValue + devAPIMatchPath + userNameToCheck.stringValue, auth: (jssUsername.stringValue, jssPassword.stringValue)).text! as String
        if (userData.rangeOfString("authentication") != nil) {
            invalidPassword.hidden = false
        }
        else {
            
        var checkDevice = userData.componentsSeparatedByString("<size>")[1]
        checkDevice = checkDevice.componentsSeparatedByString("</size")[0]
        if (checkDevice == "0") {
            resetStatus()
            invalidGIDorSN.hidden = false
        }
       
        else {
            // Pull out Value between ITEM: eg <ITEM>Value</ITEM>
            var tempDeviceSN = userData.componentsSeparatedByString("<serial_number>")[1]
            tempDeviceSN = tempDeviceSN.componentsSeparatedByString("</serial_number>")[0]
            var deviceName = userData.componentsSeparatedByString("<name>")[1]
            deviceName = deviceName.componentsSeparatedByString("</name")[0]
            var macAddress = userData.componentsSeparatedByString("<wifi_mac_address>")[1]
            macAddress = macAddress.componentsSeparatedByString("</wifi_mac_address>")[0]
        
            let IPData = Just.get(jssURL.stringValue + devAPISNPatch + tempDeviceSN, auth: (jssUsername.stringValue, jssPassword.stringValue)).text! as String
            var deviceIP = IPData.componentsSeparatedByString("<ip_address>")[1]
            deviceIP = deviceIP.componentsSeparatedByString("</ip_address>")[0]

            if ((IPData.rangeOfString("<last_inventory_update_epoch>0")) != nil) {
                deviceSNLabel.stringValue = tempDeviceSN
                deviceSN.stringValue = tempDeviceSN
                deviceNameLabel.stringValue = deviceName
                deviceMACLabel.stringValue = macAddress
                deviceIPLabel.stringValue = deviceIP
                deviceINVLabel.stringValue = "Not Found"
            }
            else {
                var deviceInvDate = IPData.componentsSeparatedByString("<last_inventory_update>")[1]
                deviceInvDate = deviceInvDate.componentsSeparatedByString("</last_inventory_update>")[0]
                deviceSNLabel.stringValue = tempDeviceSN
                deviceSN.stringValue = tempDeviceSN
                deviceNameLabel.stringValue = deviceName
                deviceMACLabel.stringValue = macAddress
                deviceIPLabel.stringValue = deviceIP
                deviceINVLabel.stringValue = deviceInvDate
                }
            }
        }
        
    }
    // Run this function when clicking "Save Settings"
    @IBAction func saveSettings(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(jssURL.stringValue, forKey: "kJSSURL")
        NSUserDefaults.standardUserDefaults().setObject(exclusionGID.stringValue, forKey: "kexclusionGID")
        NSUserDefaults.standardUserDefaults().setObject(jssUsername.stringValue, forKey: "kJSSUsername")
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
        CheckURLButton.hidden = true
        deleteFailed.hidden = true
        deleteSuccess.hidden = true
        
    }
    
}