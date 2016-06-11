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
        autoLaunchMenu.title = "Start at login"
        autoLaunchMenu.state = AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0
        autoLaunchMenu.action = #selector(menuItemAutoLaunchClick)
        menu.addItem(autoLaunchMenu)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("About", action: #selector(menuItemAboutClick), keyEquivalent: "")
        menu.addItemWithTitle("Quit Up&Down", action: #selector(menuItemQuitClick), keyEquivalent: "q")
        
        statusItemView = StatusItemView.init(statusItem: statusItem, menu: menu)
        statusItem.view = statusItemView
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        MonitorTask.init(statusItemView: statusItemView).start()
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
        alert.addButtonWithTitle("Close")
        alert.informativeText = "Up&Down is an open-source Mac OS X app to monitor upload and download speeds."
        let result = alert.runModal()
        switch result {
        case NSAlertFirstButtonReturn:
            Swift.print("About Me")
            NSWorkspace.sharedWorkspace().openURL(NSURL.init(string: "https://github.com/gjiazhe/Up-Down")!)
            break
        default:
            Swift.print("Close")
            break
        }
    }
    
    func menuItemAutoLaunchClick() {
        AutoLaunchHelper.toggleLaunchWhenLogin()
        autoLaunchMenu.state = AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0
    }
}