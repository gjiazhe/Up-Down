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
        
        menu = NSMenu()
        autoLaunchMenu = NSMenuItem()
        autoLaunchMenu.title = NSLocalizedString("Start at login", comment: "") 
        autoLaunchMenu.state = AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0
        autoLaunchMenu.action = #selector(menuItemAutoLaunchClick)
        menu.addItem(autoLaunchMenu)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle(NSLocalizedString("About", comment: ""), action: #selector(menuItemAboutClick), keyEquivalent: "")
        menu.addItemWithTitle(NSLocalizedString("Quit Up&Down", comment: ""), action: #selector(menuItemQuitClick), keyEquivalent: "q")
        
        statusItemView = StatusItemView(statusItem: statusItem, menu: menu)
        statusItem.view = statusItemView
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NetWorkMonitor(statusItemView: statusItemView).start()
    }
}

//action
extension AppDelegate {
    func menuItemQuitClick() {
        NSApp.terminate(nil)
    }
    
    func menuItemAboutClick() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("About Up&Down", comment:"")
        alert.addButtonWithTitle("Github")
        alert.addButtonWithTitle(NSLocalizedString("Close", comment:""))
        alert.informativeText = NSLocalizedString("About content", comment: "")
        let result = alert.runModal()
        switch result {
        case NSAlertFirstButtonReturn:
            //open Github page
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/gjiazhe/Up-Down")!)
            break
        default:
            //close alert window
            break
        }
    }
    
    func menuItemAutoLaunchClick() {
        AutoLaunchHelper.toggleLaunchWhenLogin()
        autoLaunchMenu.state = AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0
    }
}