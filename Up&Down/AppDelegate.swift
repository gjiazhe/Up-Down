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
        statusItem = NSStatusBar.system.statusItem(withLength: 72)
        
        menu = NSMenu()
        autoLaunchMenu = NSMenuItem()
        autoLaunchMenu.title = NSLocalizedString("Start at login", comment: "") 
        autoLaunchMenu.state = NSControl.StateValue(rawValue: AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0)
        autoLaunchMenu.action = #selector(menuItemAutoLaunchClick)
        menu.addItem(autoLaunchMenu)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: NSLocalizedString("About", comment: ""), action: #selector(menuItemAboutClick), keyEquivalent: "")
        menu.addItem(withTitle: NSLocalizedString("Quit Up&Down", comment: ""), action: #selector(menuItemQuitClick), keyEquivalent: "q")
        
        statusItemView = StatusItemView(statusItem: statusItem, menu: menu)
        statusItem.view = statusItemView
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
         NetWorkMonitor(statusItemView: statusItemView).start()
    }
}

//action
extension AppDelegate {
    @objc func menuItemQuitClick() {
        NSApp.terminate(nil)
    }
    
    @objc func menuItemAboutClick() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("About Up&Down", comment:"")
        alert.addButton(withTitle: "Github")
        alert.addButton(withTitle: NSLocalizedString("Close", comment:""))
        alert.informativeText = NSLocalizedString("About content", comment: "")
        let result = alert.runModal()
        switch result {
        case NSApplication.ModalResponse.alertFirstButtonReturn:
            //open Github page
            NSWorkspace.shared.open(URL(string: "https://github.com/gjiazhe/Up-Down")!)
            break
        default:
            //close alert window
            break
        }
    }
    
    @objc func menuItemAutoLaunchClick() {
        AutoLaunchHelper.toggleLaunchWhenLogin()
        autoLaunchMenu.state = NSControl.StateValue(rawValue: AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0)
    }
}
