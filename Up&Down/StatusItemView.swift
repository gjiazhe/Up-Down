//
//  StatusItemView.swift
//  Up&Down
//
//  Created by 郭佳哲 on 5/16/16.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import AppKit
import Foundation

open class StatusItemView: NSControl {
    static let KB:Double = 1024
    static let MB:Double = KB*1024
    static let GB:Double = MB*1024
    static let TB:Double = GB*1024
    
    var fontSize:CGFloat = 9
    var fontColor = NSColor.black
    var darkMode = false
    var mouseDown = false
    var statusItem:NSStatusItem
    
    var upRate = "- - KB/s"
    var downRate = "- - KB/s"
    
    init(statusItem aStatusItem: NSStatusItem, menu aMenu: NSMenu) {
        statusItem = aStatusItem
        super.init(frame: NSMakeRect(0, 0, statusItem.length, 30))
        menu = aMenu
        menu?.delegate = self
        
        darkMode = SystemThemeChangeHelper.isCurrentDark()
        
        SystemThemeChangeHelper.addRespond(target: self, selector: #selector(changeMode))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        statusItem.drawStatusBarBackground(in: dirtyRect, withHighlight: mouseDown)
        
        fontColor = (darkMode||mouseDown) ? NSColor.white : NSColor.black
        let fontAttributes = [NSFontAttributeName: NSFont.systemFont(ofSize: fontSize), NSForegroundColorAttributeName: fontColor] as [String : Any]
        
        let upRateString = NSAttributedString(string: upRate+" ↑", attributes: fontAttributes)
        let upRateRect = upRateString.boundingRect(with: NSSize(width: 100, height: 100), options: .usesLineFragmentOrigin)
        upRateString.draw(at: NSMakePoint(bounds.width - upRateRect.width - 5, 10))
        
        let downRateString = NSAttributedString(string: downRate+" ↓", attributes: fontAttributes)
        let downRateRect = downRateString.boundingRect(with: NSSize(width: 100, height: 100), options: .usesLineFragmentOrigin)
        downRateString.draw(at: NSMakePoint(bounds.width - downRateRect.width - 5, 0))
    }
    
    open func setRateData(up:Double, down: Double) {
        upRate = formatRateData(up)
        downRate = formatRateData(down)
        setNeedsDisplay()
    }
    
    func formatRateData(_ data:Double) -> String {
        var result:Double
        var unit: String
        
        if data < StatusItemView.KB/100 {
            result = 0
            return "0 KB/s"
        }
            
        else if data < StatusItemView.MB{
            result = data/StatusItemView.KB
            unit = " KB/s"
        }
            
        else if data < StatusItemView.GB {
            result = data/StatusItemView.MB
            unit = " MB/s"
        }
            
        else if data < StatusItemView.TB {
            result = data/StatusItemView.GB
            unit = " GB/s"
        }
            
        else {
            result = 1023
            unit = " GB/s"
        }
        
        if result < 100 {
            return String(format: "%0.2f", result) + unit
        }
        else if result < 999 {
            return String(format: "%0.1f", result) + unit
        }
        else {
            return String(format: "%0.0f", result) + unit
        }
    }
    
    func changeMode() {
        darkMode = SystemThemeChangeHelper.isCurrentDark()
        setNeedsDisplay()
    }
}

//action
extension StatusItemView: NSMenuDelegate{
    open override func mouseDown(with theEvent: NSEvent) {
        statusItem.popUpMenu(menu!)
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        mouseDown = true
        setNeedsDisplay()
    }
    
    public func menuDidClose(_ menu: NSMenu) {
        mouseDown = false
        setNeedsDisplay()
    }
}
