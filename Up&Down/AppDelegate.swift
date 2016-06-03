//
//  AppDelegate.swift
//  Up&Down
//
//  Created by 郭佳哲 on 5/15/16.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem:NSStatusItem
    let statusItemView:StatusItemView
    let menu:NSMenu
    let autoLaunchMenu:NSMenuItem
    
    override init() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(72)
        
        menu = NSMenu.init()
        autoLaunchMenu = NSMenuItem.init()
        autoLaunchMenu.title = "Launch when login"
        autoLaunchMenu.state = AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0
        autoLaunchMenu.action = #selector(menuItemAutoLaunchClick)
        menu.addItem(autoLaunchMenu)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("About", action: #selector(menuItemAboutClick), keyEquivalent: "")
        menu.addItemWithTitle("Quit", action: #selector(menuItemQuitClick), keyEquivalent: "q")
        
        statusItemView = StatusItemView.init(statusItem: statusItem, menu: menu)
        statusItem.view = statusItemView
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSThread.init(target: self, selector: #selector(startUpdateTimer), object: nil).start()
    }
    
    func startUpdateTimer() {
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(updateRateData), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().run()
    }
    
    func updateRateData() {
        let task = NSTask.init()
        task.launchPath = "/usr/bin/sar"
        task.arguments = ["-n", "DEV", "1"]
        
        let pipe = NSPipe.init()
        task.standardOutput = pipe
        
        task.launch()
        task.waitUntilExit()
        
        let status = task.terminationStatus
        if status == 0 {
//            print("Task succeeded.")
            let fileHandle = pipe.fileHandleForReading
            let data = fileHandle.readDataToEndOfFile()
            
            var string = String.init(data: data, encoding: NSUTF8StringEncoding)
            string = string?.substringFromIndex((string?.rangeOfString("Aver")?.startIndex)!)
            handleData(string!)
        } else {
            print("Task failed.")
        }
    }
    
    /*
     23:18:25    IFACE    Ipkts/s      Ibytes/s     Opkts/s      Obytes/s
     
     
     23:18:26    lo0            0             0           0             0
     23:18:26    gif0           0             0           0             0
     23:18:26    stf0           0             0           0             0
     23:18:26    en0            0             0           0             0
     23:18:26    en1            0             0           0             0
     23:18:26    en2            0             0           0             0
     23:18:26    p2p0           0             0           0             0
     23:18:26    awdl0          0             0           0             0
     23:18:26    bridge0        0             0           0             0
     23:18:26    en4            0             0           0             0
     Average:   lo0            0             0           0             0
     Average:   gif0           0             0           0             0
     Average:   stf0           0             0           0             0
     Average:   en0            0             0           0             0
     Average:   en1            0             0           0             0
     Average:   en2            0             0           0             0
     Average:   p2p0           0             0           0             0
     Average:   awdl0          0             0           0             0
     Average:   bridge0        0             0           0             0
     Average:   en4            0             0           0             0
     */
    func handleData(string: String) {
        //        print(string)
        let pattern = "en\\w+\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            let results = regex.matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count))
            var upRate: Float = 0
            var downRate: Float = 0
            for result in results {
                downRate += Float.init((string as NSString).substringWithRange(result.rangeAtIndex(2)))!
                upRate += Float.init((string as NSString).substringWithRange(result.rangeAtIndex(4)))!
            }
            statusItemView.setRateData(up: upRate, down: downRate)
            //test data
            //statusItemView.setRateData(up: Float(arc4random())%StatusItemView.KB, down: Float(arc4random())%StatusItemView.MB)
        }
        catch {}
    }
}

//action
extension AppDelegate {
    func menuItemQuitClick() {
        NSApp.terminate(nil)
    }
    
    func menuItemAboutClick() {
        let alert = NSAlert.init()
        alert.messageText = "About Up&Down"
        alert.addButtonWithTitle("About Me")
        alert.addButtonWithTitle("Cancle")
        alert.informativeText = "An open-source Mac OSX app to monitor upload and download speed."
        let result = alert.runModal()
        switch result {
        case NSAlertFirstButtonReturn:
            Swift.print("About Me")
            NSWorkspace.sharedWorkspace().openURL(NSURL.init(string: "https://github.com/gjiazhe/Up-Down")!)
            break
        default:
            Swift.print("Cancel")
            break
        }
    }
    
    func menuItemAutoLaunchClick() {
        AutoLaunchHelper.toggleLaunchWhenLogin()
        autoLaunchMenu.state = AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0
    }
}