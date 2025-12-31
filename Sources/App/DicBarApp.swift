import SwiftUI

@main
struct DicBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 状态栏应用，不需要窗口场景
        Settings {
            EmptyView()
        }
    }
}
