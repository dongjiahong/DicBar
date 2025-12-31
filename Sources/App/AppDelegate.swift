import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    
    let databaseService = DatabaseService()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏 Dock 图标
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏
        setupStatusBar()
        
        // 创建弹出面板
        setupPopover()
        
        // 监听点击外部关闭
        setupEventMonitor()
    }
    
    // MARK: - 状态栏设置
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "book.fill", accessibilityDescription: "DicBar")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    // MARK: - 弹出面板设置
    
    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 520)
        popover.behavior = .transient
        popover.animates = true
        
        let contentView = SearchPanelView()
            .environmentObject(databaseService)
        
        popover.contentViewController = NSHostingController(rootView: contentView)
    }
    
    // MARK: - 事件监听
    
    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.closePopover()
            }
        }
    }
    
    // MARK: - 面板操作
    
    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    private func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
            
            // 聚焦到搜索框
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .focusSearchField, object: nil)
            }
        }
    }
    
    private func closePopover() {
        popover.performClose(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

// MARK: - 通知名称

extension Notification.Name {
    static let focusSearchField = Notification.Name("focusSearchField")
}
