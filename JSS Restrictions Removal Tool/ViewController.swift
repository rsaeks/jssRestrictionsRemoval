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
        let kJSSURLCheck = UserDefaults.standard.object(forKey: "kJSSURL")
        if (kJSSURLCheck != nil) {
            jssURL.stringValue = UserDefaults.standard.object(forKey: "kJSSURL") as! String
        }

        let kexclusionGIDCheck = UserDefaults.standard.object(forKey: "kJSSURL")
        if (kexclusionGIDCheck != nil) {
            exclusionGID.stringValue = UserDefaults.standard.object(forKey: "kexclusionGID") as! String
        }
        
        let kJSSUsernameCheck = UserDefaults.standard.object(forKey: "kJSSUsername")
        if (kJSSUsernameCheck != nil) {
            jssUsername.stringValue = UserDefaults.standard.object(forKey: "kJSSUsername") as! String
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
    @IBOutlet weak var UpdateInventoryButton: NSButton!


    // Globals for API Paths
    let devAPIPath = "/JSSResource/mobiledevicegroups/id/"
    let devAPIMatchPath = "/JSSResource/mobiledevices/match/"
    let devAPISNPatch = "/JSSResource/mobiledevices/serialnumber/"
    let devAPIUpdateInventoryPath = "/JSSResource/mobiledevicecommands/command/UpdateInventory/id/"
    
    // Run this function when clicking "Check" for JSS URL
    @IBAction func checkJSSURL(_ sender: NSButton) {
        
        // If there is a trailing slash in the JSS URL, remove.
        if (jssURL.stringValue.characters.last == "/") {
            jssURL.stringValue = jssURL.stringValue.substring(to: jssURL.stringValue.characters.index(before: jssURL.stringValue.endIndex))
        }
        
        // Test connection to JSS
        let testConn = Just.get(jssURL.stringValue, timeout:5.0)
       
        if (testConn.statusCode != nil) {
            resetStatus()
            jssConnectTBD.isHidden = true
            jssConnectYes.isHidden = false
            removeEnabled.isEnabled = true
            reapplyEnabled.isEnabled = true
            userCheckButton.isEnabled = true
            UpdateInventoryButton.isEnabled = true
        }

        else {
            resetStatus()
            jssConnectTBD.isHidden = true
            jssConnectNo.isHidden = false
            unableToConnectJSS.isHidden = false
            removeEnabled.isEnabled = false
            reapplyEnabled.isEnabled = false
            CheckURLButton.isHidden = false
        }
        
    }
    @IBAction func openJSSURLInBrowser(_ sender: AnyObject) {
        let baseURL = URL(string: jssURL.stringValue)
        NSWorkspace.shared().open(baseURL!)
    }
    
    // Run this function when clicking "Remove Settings"
    @IBAction func removeRestrictions(_ sender: AnyObject) {
        resetStatus()
        jssConnectYes.isHidden = false
        let builtURL = jssURL.stringValue + devAPIPath + exclusionGID.stringValue
        let addCommand  = "<mobile_device_group><mobile_device_additions><mobile_device><serial_number>" + deviceSN.stringValue + "</serial_number></mobile_device></mobile_device_additions></mobile_device_group>"
        let addCommandXML = try! XMLDocument(xmlString: addCommand, options: 0)
        let addCommandXMLStatus = Just.put(builtURL, headers: ["Content-Type":"text/xml"], auth: (jssUsername.stringValue, jssPassword.stringValue), requestBody: addCommandXML.xmlData)
       
        // Successful PUT
        if (addCommandXMLStatus.statusCode == 201) {
            resetStatus()
            jssConnectYes.isHidden = false
            removeSuccess.isHidden = false
            deleteDeviceButton.isEnabled = true
            
        }
        // Unauthorized PUT result
        else if (addCommandXMLStatus.statusCode == 401) {
            resetStatus()
            jssConnectYes.isHidden = false
            removeFail.isHidden = false
            invalidPassword.isHidden = false

        }
        // Not found PUT result
        else if (addCommandXMLStatus.statusCode == 404 || addCommandXMLStatus.statusCode == 409) {
            resetStatus()
            jssConnectYes.isHidden = false
            removeFail.isHidden = false
            invalidGIDorSN.isHidden = false
        }
        // Other PUT errors
        else {
            resetStatus()
            jssConnectYes.isHidden = false
            removeFail.isHidden = false
            otherError.isHidden = false
        }
    }
    
    // Run this funtion when clicking "Reapply Settings"
    @IBAction func reapplyRestrictions(_ sender: AnyObject) {
        resetStatus()
        jssConnectYes.isHidden = false
        let builtURL = jssURL.stringValue + devAPIPath + exclusionGID.stringValue
        let removeCommand  = "<mobile_device_group><mobile_device_deletions><mobile_device><serial_number>" + deviceSN.stringValue + "</serial_number></mobile_device></mobile_device_deletions></mobile_device_group>"
        let removeCommandXML = try! XMLDocument(xmlString: removeCommand, options: 0)
        let removeCommandXMLStatus = Just.put(builtURL, headers: ["Content-Type":"text/xml"], auth: (jssUsername.stringValue, jssPassword.stringValue), requestBody: removeCommandXML.xmlData)

        // Successful PUT
        if (removeCommandXMLStatus.statusCode == 201) {
            resetStatus()
            jssConnectYes.isHidden = false
            reapplySuccess.isHidden = false
            
        }
        // Unauthorized PUT result
        else if (removeCommandXMLStatus.statusCode == 401) {
            resetStatus()
            jssConnectYes.isHidden = false
            reapplyFail.isHidden = false
            invalidPassword.isHidden = false
        }
        // Not found PUT result
        else if (removeCommandXMLStatus.statusCode == 404 || removeCommandXMLStatus.statusCode == 409) {
            resetStatus()
            jssConnectYes.isHidden = false
            reapplyFail.isHidden = false
            invalidGIDorSN.isHidden = false
        }
        // Other PUT errors
        else {
            resetStatus()
            jssConnectYes.isHidden = false
            reapplyFail.isHidden = false
            otherError.isHidden = false
        }

    }

    // Run this function when clicking Update Inventory
    @IBAction func updateInventoryButtonPushed(_ sender: Any) {
        let removeURL=jssURL.stringValue + devAPIMatchPath + deviceSN.stringValue
        let deviceData = Just.get(removeURL, auth: (jssUsername.stringValue, jssPassword.stringValue)).text! as String
        // Check for an authentication error.
        if (deviceData.range(of: "authentication") != nil) {
            invalidPassword.isHidden = false
            deleteFailed.isHidden = false
        }
            // Check for returned number of items being equal to 1 device.
        else if (deviceData.range(of: "<size>1") != nil) {
            var subStr = deviceData[deviceData.characters.index(deviceData.startIndex, offsetBy: 83)...deviceData.characters.index(deviceData.startIndex, offsetBy: 100)]
            subStr = subStr.replacingOccurrences(of: "<id>", with: "", options: NSString.CompareOptions.literal, range: nil)
            let IDNumber = subStr.components(separatedBy: "<")[0]
            let UpdateInventoryCommandURL = jssURL.stringValue + devAPIUpdateInventoryPath + IDNumber
            print(UpdateInventoryCommandURL)
            // JSSResource/mobiledevicecommands/command/UpdateInventory/id/13 -X POST
            let UpdateInventory = Just.post(UpdateInventoryCommandURL, auth: (jssUsername.stringValue, jssPassword.stringValue))
            print (UpdateInventory.statusCode ?? 9999)
        }
        
        
    }

    
    
    
    
    
    
    
    
    
    
    // Run this when clicking delete device button
    @IBAction func deleteDevice(_ sender: AnyObject) {
        resetStatus()
        let removeURL=jssURL.stringValue + devAPIMatchPath + deviceSN.stringValue
        let deviceData = Just.get(removeURL, auth: (jssUsername.stringValue, jssPassword.stringValue)).text! as String
        // Check for an authentication error.
        if (deviceData.range(of: "authentication") != nil) {
            invalidPassword.isHidden = false
            deleteFailed.isHidden = false
        }
        // Check for returned number of items being equal to 1 device.
        else if (deviceData.range(of: "<size>1") != nil) {
            var subStr = deviceData[deviceData.characters.index(deviceData.startIndex, offsetBy: 83)...deviceData.characters.index(deviceData.startIndex, offsetBy: 100)]
            subStr = subStr.replacingOccurrences(of: "<id>", with: "", options: NSString.CompareOptions.literal, range: nil)
            let IDNumber = subStr.components(separatedBy: "<")[0]
            let deleteDevice = Just.delete(jssURL.stringValue + devAPIPath + IDNumber, auth: (jssUsername.stringValue, jssPassword.stringValue))
            print (deleteDevice.statusCode!)
            // Check the response code of the delete command.
            if (deleteDevice.ok) {
                deleteSuccess.isHidden = false
                deleteDeviceButton.isEnabled = false
            }
            
            else {
                deleteFailed.isHidden = false
                otherError.isHidden = false
            }
    }
        //Catch all other errors getting device data.
        else {
            invalidGIDorSN.isHidden = false
            deleteFailed.isHidden = false
        }
    }
    
    @IBAction func FindUserInfo(_ sender: AnyObject) {
        resetStatus()
        let userData = Just.get(jssURL.stringValue + devAPIMatchPath + userNameToCheck.stringValue, auth: (jssUsername.stringValue, jssPassword.stringValue)).text! as String
        if (userData.range(of: "authentication") != nil) {
            invalidPassword.isHidden = false
        }
        else {
            
        var checkDevice = userData.components(separatedBy: "<size>")[1]
        checkDevice = checkDevice.components(separatedBy: "</size")[0]
        if (checkDevice == "0") {
            resetStatus()
            invalidGIDorSN.isHidden = false
        }
       
        else {
            // Pull out Value between ITEM: eg <ITEM>Value</ITEM>
            var tempDeviceSN = userData.components(separatedBy: "<serial_number>")[1]
            tempDeviceSN = tempDeviceSN.components(separatedBy: "</serial_number>")[0]
            var deviceName = userData.components(separatedBy: "<name>")[1]
            deviceName = deviceName.components(separatedBy: "</name")[0]
            var macAddress = userData.components(separatedBy: "<wifi_mac_address>")[1]
            macAddress = macAddress.components(separatedBy: "</wifi_mac_address>")[0]
        
            let IPData = Just.get(jssURL.stringValue + devAPISNPatch + tempDeviceSN, auth: (jssUsername.stringValue, jssPassword.stringValue)).text! as String
            var deviceIP = IPData.components(separatedBy: "<ip_address>")[1]
            deviceIP = deviceIP.components(separatedBy: "</ip_address>")[0]

            if ((IPData.range(of: "<last_inventory_update_epoch>0")) != nil) {
                deviceSNLabel.stringValue = tempDeviceSN
                deviceSN.stringValue = tempDeviceSN
                deviceNameLabel.stringValue = deviceName
                deviceMACLabel.stringValue = macAddress
                deviceIPLabel.stringValue = deviceIP
                deviceINVLabel.stringValue = "Not Found"
            }
            else {
                var deviceInvDate = IPData.components(separatedBy: "<last_inventory_update>")[1]
                deviceInvDate = deviceInvDate.components(separatedBy: "</last_inventory_update>")[0]
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
    @IBAction func saveSettings(_ sender: AnyObject) {
        UserDefaults.standard.set(jssURL.stringValue, forKey: "kJSSURL")
        UserDefaults.standard.set(exclusionGID.stringValue, forKey: "kexclusionGID")
        UserDefaults.standard.set(jssUsername.stringValue, forKey: "kJSSUsername")
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    func resetStatus() {
        jssConnectTBD.isHidden = false
        jssConnectYes.isHidden = true
        jssConnectNo.isHidden = true
        removeSuccess.isHidden = true
        removeFail.isHidden = true
        removeUnknown.isHidden = false
        reapplySuccess.isHidden = true
        reapplyFail.isHidden = true
        reapplyUnknown.isHidden = false
        unableToConnectJSS.isHidden = true
        invalidPassword.isHidden = true
        invalidGIDorSN.isHidden = true
        otherError.isHidden = true
        CheckURLButton.isHidden = true
        deleteFailed.isHidden = true
        deleteSuccess.isHidden = true
        
    }
    
}
