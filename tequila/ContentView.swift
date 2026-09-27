import SwiftUI
import AppKit
import UniformTypeIdentifiers
import PDFKit
@preconcurrency import WebKit

// =========================================================================
// 🌐 0. 语言管理系统（单语言 English 版）
// =========================================================================

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case en = "en"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .en: return "English"
        }
    }
}

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "SysAppLanguageV6")
            objectWillChange.send()
        }
    }
    
    private init() {
        self.currentLanguage = .en
    }
    
    // 📖 英文语言映射字典
    private let coreDictionary: [String: [AppLanguage: String]] = [
        // 导航菜单
        "nav_focus": [.en: "Focus"],
        "nav_timer": [.en: "Timer"],
        "nav_calendar": [.en: "Calendar"],
        "nav_mail": [.en: "Mail"],
        "nav_style": [.en: "Settings"],
        "nav_logs": [.en: "Logs"],
        
        // 控制台与任务
        "console_title": [.en: "Tasks"],
        "console_subtitle": [.en: "Pipeline"],
        "sys_mode": [.en: "Sandbox Mode"],
        "placeholder_task": [.en: "Task name..."],
        "empty_tip": [.en: "No active tasks."],
        
        // 设置与系统
        "geo_index": [.en: "Language"],
        "log_title": [.en: "Work Logs"],
        "log_subtitle": [.en: "Document Center"]
    ]
    
    /// 动态获取英文文本
    func localize(_ key: String) -> String {
        if let match = coreDictionary[key]?[currentLanguage] {
            return match
        }
        return key
    }
}

/// 全局快捷调用函数 (自动绑定单例状态)
func LS(_ key: String) -> String {
    return LanguageManager.shared.localize(key)
}

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import WebKit

// =========================================================================
// 🎨 1. 主题与本地资产管理中心
// =========================================================================

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var backgroundMode: Int { didSet { UserDefaults.standard.set(backgroundMode, forKey: "SysBgMode") } }
    @Published var solidColor: Color { didSet { saveColorToStorage() } }
    @Published var backgroundImage: NSImage? = nil { didSet { saveImageToStorage() } }
    
    @Published var textMode: Int { didSet { UserDefaults.standard.set(textMode, forKey: "SysTextMode") } }
    @Published var textColor: Color { didSet { saveTextColorToStorage() } }
    @Published var textImage: NSImage? = nil { didSet { saveTextImageToStorage() } }
    
    @Published var selectedFontName: String {
        didSet {
            UserDefaults.standard.set(selectedFontName, forKey: "SysFontNameV6")
        }
    }
    
    var availableFonts: [String] {
        return NSFontManager.shared.availableFontFamilies
    }
    
    init() {
        self.backgroundMode = UserDefaults.standard.integer(forKey: "SysBgMode")
        self.textMode = UserDefaults.standard.integer(forKey: "SysTextMode")
        self.selectedFontName = UserDefaults.standard.string(forKey: "SysFontNameV6") ?? "System"
        
        if let data = UserDefaults.standard.data(forKey: "SysBgColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            self.solidColor = Color(color)
        } else {
            self.solidColor = .black
        }
        
        if let imgData = UserDefaults.standard.data(forKey: "SysBgImage") {
            self.backgroundImage = NSImage(data: imgData)
        }
        
        if let data = UserDefaults.standard.data(forKey: "SysTextColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            self.textColor = Color(color)
        } else {
            self.textColor = .white
        }
        
        if let imgData = UserDefaults.standard.data(forKey: "SysTextImage") {
            self.textImage = NSImage(data: imgData)
        }
    }
    
    private func saveColorToStorage() {
        let nsColor = NSColor(solidColor)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: "SysBgColor")
        }
    }
    
    private func saveImageToStorage() {
        if let img = backgroundImage, let tiff = img.tiffRepresentation {
            UserDefaults.standard.set(tiff, forKey: "SysBgImage")
        } else {
            UserDefaults.standard.removeObject(forKey: "SysBgImage")
        }
    }
    
    private func saveTextColorToStorage() {
        let nsColor = NSColor(textColor)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: "SysTextColor")
        }
    }
    
    private func saveTextImageToStorage() {
        if let img = textImage, let tiff = img.tiffRepresentation {
            UserDefaults.standard.set(tiff, forKey: "SysTextImage")
        } else {
            UserDefaults.standard.removeObject(forKey: "SysTextImage")
        }
    }
    
    func triggerLocalFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        
        if panel.runModal() == .OK, let url = panel.url, let img = NSImage(contentsOf: url) {
            self.backgroundImage = img
            self.backgroundMode = 2
        }
    }
    
    func triggerTextFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        
        if panel.runModal() == .OK, let url = panel.url, let img = NSImage(contentsOf: url) {
            self.textImage = img
            self.textMode = 2
        }
    }
}

// =========================================================================
// 📦 2. 任务与计时器数据模型
// =========================================================================

struct TaskRecord: Identifiable, Codable {
    var id = UUID()
    var title: String
    var note: String = "" // 📝 批注文本框存储字段
    var isCompleted = false
    var creationDate: Date = Calendar.current.startOfDay(for: Date())
    var startTime: Date? = nil
    var endTime: Date? = nil
    var isRecurring: Bool = false
}

enum TimerMode: String, Codable {
    case stopwatch = "Count Up"
    case countdown = "Countdown"
}

struct TimerHistoryItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var mode: TimerMode
    var durationInSeconds: Int
    var timestamp: Date = Date()
    var category: String = "Inbox"
}

// =========================================================================
// 🕒 2.5 计时数据状态机管理器
// =========================================================================

class TimerSandboxManager: ObservableObject {
    static let shared = TimerSandboxManager()
    
    @Published var historyRecords: [TimerHistoryItem] = [] {
        didSet { saveHistoryToStorage() }
    }
    
    init() {
        loadHistoryFromStorage()
    }
    
    func addRecord(title: String, mode: TimerMode, seconds: Int, category: String = "Inbox") {
        let item = TimerHistoryItem(title: title.isEmpty ? "Untitled Activity Record" : title, mode: mode, durationInSeconds: seconds, category: category)
        historyRecords.insert(item, at: 0)
    }
    
    func deleteRecord(id: UUID) {
        historyRecords.removeAll(where: { $0.id == id })
    }
    
    func renameRecord(id: UUID, newTitle: String) {
        if let idx = historyRecords.firstIndex(where: { $0.id == id }) {
            historyRecords[idx].title = newTitle
        }
    }
    
    private func saveHistoryToStorage() {
        if let encoded = try? JSONEncoder().encode(historyRecords) {
            UserDefaults.standard.set(encoded, forKey: "SysTimerHistoryCacheStoreV1")
        }
    }
    
    private func loadHistoryFromStorage() {
        if let data = UserDefaults.standard.data(forKey: "SysTimerHistoryCacheStoreV1"),
           let decoded = try? JSONDecoder().decode([TimerHistoryItem].self, from: data) {
            self.historyRecords = decoded
        }
    }
}

// =========================================================================
// 📬 3. 邮箱账号管理与未读检测状态机
// =========================================================================

struct MailClientStaticNode: Identifiable {
    let id: UUID
    let name: String
    let iconText: String
    let webURL: String
    let description: String
}

class MailSandboxManager: ObservableObject {
    static let shared = MailSandboxManager()
    
    @Published var mailUnreadCounts: [String: Int] = [:]
    
    var totalUnreadCount: Int {
        mailUnreadCounts.values.reduce(0, +)
    }
    
    @Published var availableClients: [MailClientStaticNode] = [
        MailClientStaticNode(id: UUID(uuidString: "11111111-2222-3333-4444-555555555551")!, name: "Gmail", iconText: " G ", webURL: "https://mail.google.com", description: "Google Mail"),
        MailClientStaticNode(id: UUID(uuidString: "11111111-2222-3333-4444-555555555552")!, name: "Outlook", iconText: " O ", webURL: "https://outlook.live.com/mail/", description: "Microsoft Outlook"),
        MailClientStaticNode(id: UUID(uuidString: "11111111-2222-3333-4444-555555555553")!, name: "iCloud Mail", iconText: " I ", webURL: "https://www.icloud.com/mail", description: "Apple iCloud Mail"),
        MailClientStaticNode(id: UUID(uuidString: "11111111-2222-3333-4444-555555555556")!, name: "ProtonMail", iconText: " P ", webURL: "https://mail.proton.me", description: "Proton Encrypted Mail"),
        MailClientStaticNode(id: UUID(uuidString: "11111111-2222-3333-4444-555555555557")!, name: "Yahoo Mail", iconText: " Y ", webURL: "https://mail.yahoo.com", description: "Yahoo Mail Services"),
        MailClientStaticNode(id: UUID(uuidString: "11111111-2222-3333-4444-555555555554")!, name: "网易 163 邮箱", iconText: " 163 ", webURL: "https://mail.163.com", description: "NetEase 163 Mail"),
        MailClientStaticNode(id: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!, name: "QQ 邮箱", iconText: " QQ ", webURL: "https://mail.qq.com", description: "Tencent QQ Mail")
    ]
    
    @Published var selectedClientIndex: Int = 0
    
    var currentActiveClient: MailClientStaticNode {
        return availableClients[selectedClientIndex]
    }
}

// =========================================================================
// 📝 3.8 工作日志文件系统模型与核心沙盒管理器
// =========================================================================

enum LogNodeType: String, Codable {
    case folder
    case document
}

class LogNode: Identifiable, Codable, ObservableObject {
    var id = UUID()
    var name: String
    var type: LogNodeType
    var contentHTML: String = "<div><b>New Document</b> - Start typing your entry here...</div>"
    var children: [LogNode]?
    
    init(name: String, type: LogNodeType, children: [LogNode]? = nil) {
        self.name = name
        self.type = type
        self.children = children
    }
}

class LogSystemManager: ObservableObject {
    static let shared = LogSystemManager()
    
    @Published var rootNodes: [LogNode] = [] {
        didSet { saveTreeToStorage() }
    }
    
    init() {
        loadTreeFromStorage()
    }
    
    func createNode(name: String, type: LogNodeType, parentID: UUID? = nil) {
        let newNode = LogNode(name: name, type: type, children: type == .folder ? [] : nil)
        if let parentID = parentID {
            if let parent = findNode(by: parentID, in: rootNodes) {
                if parent.children == nil { parent.children = [] }
                parent.children?.append(newNode)
                objectWillChange.send()
                saveTreeToStorage()
            }
        } else {
            rootNodes.append(newNode)
        }
    }
    
    func deleteNode(id: UUID) {
        func remove(from nodes: inout [LogNode]) -> Bool {
            if let idx = nodes.firstIndex(where: { $0.id == id }) {
                nodes.remove(at: idx)
                return true
            }
            for i in 0..<nodes.count {
                if nodes[i].children != nil {
                    if remove(from: &nodes[i].children!) { return true }
                }
            }
            return false
        }
        _ = remove(from: &rootNodes)
        objectWillChange.send()
        saveTreeToStorage()
    }
    
    func updateContent(id: UUID, html: String) {
        if let node = findNode(by: id, in: rootNodes) {
            node.contentHTML = html
            saveTreeToStorage()
        }
    }
    
    func renameNode(id: UUID, newName: String) {
        if let node = findNode(by: id, in: rootNodes) {
            node.name = newName
            objectWillChange.send()
            saveTreeToStorage()
        }
    }
    
    private func findNode(by id: UUID, in nodes: [LogNode]) -> LogNode? {
        for node in nodes {
            if node.id == id { return node }
            if let children = node.children, let found = findNode(by: id, in: children) {
                return found
            }
        }
        return nil
    }
    
    private func saveTreeToStorage() {
        if let encoded = try? JSONEncoder().encode(rootNodes) {
            UserDefaults.standard.set(encoded, forKey: "CoreLogTreeDataStoreV1")
        }
    }
    
    private func loadTreeFromStorage() {
        if let data = UserDefaults.standard.data(forKey: "CoreLogTreeDataStoreV1"),
           let decoded = try? JSONDecoder().decode([LogNode].self, from: data) {
            self.rootNodes = decoded
        } else {
            self.rootNodes = [
                LogNode(name: "My Work Log", type: .folder, children: [
                    LogNode(name: "Quarterly Performance Report.doc", type: .document)
                ])
            ]
        }
    }
}

// =========================================================================
// 🚀 4. 监听版 WebKit 网页容器包装器
// =========================================================================

class WKScriptMessageHandlerWeakProxy: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let actualDelegate = delegate else { return }
        actualDelegate.userContentController(userContentController, didReceive: message)
    }
}

struct NSMailWebViewWrapper: NSViewRepresentable {
    let urlString: String
    var onUnreadCountChanged: (Int) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let weakProxy = WKScriptMessageHandlerWeakProxy(delegate: context.coordinator)
        configuration.userContentController.add(weakProxy, name: "unreadStateNotifier")
        
        let nativeDetectScript = """
        function checkUnreadMail() {
            var unreadNum = 0;
            var pageTitle = document.title;
            var match = pageTitle.match(/\\((\\d+)\\)/);
            if (match && match[1]) {
                unreadNum = parseInt(match[1], 10);
            } else {
                var selectors = [
                    '#readmail_unread', '#folder_1_unread', '.folder_unread',
                    '#folder_1 b', '.bsU', '.zW', '.unread-count'
                ];
                for (var i = 0; i < selectors.length; i++) {
                    var element = document.querySelector(selectors[i]);
                    if (element) {
                        var txt = element.innerText || element.textContent;
                        var num = parseInt(txt.replace(/[^0-9]/g, ''), 10);
                        if (!isNaN(num) && num > 0) { unreadNum = num; break; }
                    }
                }
            }
            window.webkit.messageHandlers.unreadStateNotifier.postMessage({
                "url": window.location.href,
                "count": unreadNum
            });
        }
        """
        
        let userScript = WKUserScript(source: nativeDetectScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    static func dismantleNSView(_ nsView: WKWebView, coordinator: Coordinator) {
        nsView.configuration.userContentController.removeScriptMessageHandler(forName: "unreadStateNotifier")
        nsView.configuration.userContentController.removeAllUserScripts()
        coordinator.stopTimer()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: NSMailWebViewWrapper
        private var detectionTimer: Timer?
        
        init(_ parent: NSMailWebViewWrapper) {
            self.parent = parent
        }
        
        func startDetectionTimer(for webView: WKWebView) {
            detectionTimer?.invalidate()
            detectionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak webView] _ in
                guard let webView = webView else { return }
                DispatchQueue.main.async {
                    webView.evaluateJavaScript("typeof checkUnreadMail === 'function' ? checkUnreadMail() : null;", completionHandler: nil)
                }
            }
        }
        
        func stopTimer() {
            detectionTimer?.invalidate()
            detectionTimer = nil
        }
        
        deinit {
            stopTimer()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "unreadStateNotifier",
                  let body = message.body as? [String: Any],
                  let count = body["count"] as? Int else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.onUnreadCountChanged(count)
            }
        }
    }
}

// =========================================================================
// 📝 4.2 富文本编辑器容器组件
// =========================================================================

struct EmbeddedWordEditorContainer: NSViewRepresentable {
    let initialHTML: String
    var onContentChanged: (String) -> Void
    
    private static let cachedFontOptionsHTML: String = {
        let allSystemFonts = NSFontManager.shared.availableFontFamilies.sorted()
        return allSystemFonts.map { font in
            "<option value=\"\(font)\">\(font)</option>"
        }.joined(separator: "\n")
    }()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        let weakProxy = WKScriptMessageHandlerWeakProxy(delegate: context.coordinator)
        contentController.add(weakProxy, name: "wordContentSyncBridge")
        contentController.add(weakProxy, name: "triggerNativeImagePicker")
                
        configuration.userContentController = contentController
                
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        let fontOptionsHTML = Self.cachedFontOptionsHTML
        
        let documentTemplate = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <style>
            body {
                background-color: #ffffff;
                color: #333333;
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                margin: 0;
                padding: 12px;
                font-size: 14px;
                line-height: 1.6;
            }
            .toolbar {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-bottom: none;
                padding: 8px;
                border-top-left-radius: 6px;
                border-top-right-radius: 6px;
                display: flex;
                gap: 12px;
                align-items: center;
            }
            .toolbar select, .toolbar button {
                padding: 4px 8px;
                border: 1px solid #cbd5e1;
                background: #ffffff;
                border-radius: 4px;
                cursor: pointer;
                font-size: 12px;
            }
            .toolbar button:hover { background: #f1f5f9; }
            #editor {
                outline: none;
                min-height: 400px;
                border: 1px solid #e2e8f0;
                border-bottom-left-radius: 6px;
                border-bottom-right-radius: 6px;
                padding: 16px;
                box-shadow: inset 0 1px 3px rgba(0,0,0,0.05);
            }
            #editor:focus { border-color: #3b82f6; }
        </style>
        <script>
            function executeCmd(command, value = null) {
                document.execCommand(command, false, value);
                dispatchContent();
            }
            
            function triggerImageUpload() {
                window.webkit.messageHandlers.triggerNativeImagePicker.postMessage("open");
            }
            
            function insertImageBase64(base64Str) {
                executeCmd('insertImage', base64Str);
            }
            
            function dispatchContent() {
                var html = document.getElementById('editor').innerHTML;
                window.webkit.messageHandlers.wordContentSyncBridge.postMessage(html);
            }
        </script>
        </head>
        <body>
            <div class="toolbar">
                <select onchange="executeCmd('fontName', this.value); this.selectedIndex=0;">
                    <option value="">Select Font (All System Fonts)...</option>
                    \(fontOptionsHTML)
                </select>
                
                <button onclick="triggerImageUpload()">🖼 insert picture</button>
            </div>

            <div id="editor" contenteditable="true" oninput="dispatchContent()">
                \(initialHTML)
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(documentTemplate, baseURL: nil)
        context.coordinator.targetWebView = webView
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    static func dismantleNSView(_ nsView: WKWebView, coordinator: Coordinator) {
        nsView.configuration.userContentController.removeScriptMessageHandler(forName: "wordContentSyncBridge")
        nsView.configuration.userContentController.removeScriptMessageHandler(forName: "triggerNativeImagePicker")
        nsView.navigationDelegate = nil
        coordinator.targetWebView = nil
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: EmbeddedWordEditorContainer
        weak var targetWebView: WKWebView?
        
        init(_ parent: EmbeddedWordEditorContainer) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard targetWebView != nil else { return }
            
            if message.name == "wordContentSyncBridge", let htmlString = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.onContentChanged(htmlString)
                }
            }
            else if message.name == "triggerNativeImagePicker" {
                DispatchQueue.main.async {
                    self.openNativeImagePanel()
                }
            }
        }
        
        private func openNativeImagePanel() {
            let panel = NSOpenPanel()
            panel.title = "Select Image to Insert"
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.allowedContentTypes = [.image, .jpeg, .png, .webP]
            
            panel.begin { [weak self] response in
                guard let self = self, response == .OK, let url = panel.url else { return }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if let imgData = try? Data(contentsOf: url) {
                        let mimeType = url.pathExtension.lowercased() == "png" ? "image/png" : "image/jpeg"
                        let base64String = imgData.base64EncodedString()
                        let dataURL = "data:\(mimeType);base64,\(base64String)"
                        
                        let jsCode = "insertImageBase64('\(dataURL)');"
                        DispatchQueue.main.async {
                            self.targetWebView?.evaluateJavaScript(jsCode, completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
}

// =========================================================================
// 🌎 4.5 常驻状态挂件：实时地区时钟组件
// =========================================================================

struct GlobalGeographicClockWidget: View {
    @ObservedObject var theme = ThemeManager.shared
    @State private var currentTimeString: String = ""
    @State private var regionIdentifier: String = ""
    
    @AppStorage("WidgetDragOffsetX_V6") private var dragOffsetX: Double = 0.0
    @AppStorage("WidgetDragOffsetY_V6") private var dragOffsetY: Double = 0.0
    
    @GestureState private var gestureOffset: CGSize = .zero
    
    let tickerTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "globe.asia.australia.fill")
                .font(.system(size: 10))
                .UniversalTextColorModifier()
            
            Text("\(regionIdentifier)  \(currentTimeString)")
                .font(.UniversalFont(size: 11, weight: .medium, design: .monospaced))
                .UniversalTextColorModifier()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.4))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .offset(x: dragOffsetX + gestureOffset.width, y: dragOffsetY + gestureOffset.height)
        .gesture(
            DragGesture()
                .updating($gestureOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    dragOffsetX += value.translation.width
                    dragOffsetY += value.translation.height
                }
        )
        .animation(.interactiveSpring(), value: gestureOffset)
        .onHover { isInside in
            if isInside { NSCursor.openHand.set() } else { NSCursor.arrow.set() }
        }
        .onAppear { updateClockData() }
        .onReceive(tickerTimer) { _ in updateClockData() }
    }
    
    private func updateClockData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        self.currentTimeString = formatter.string(from: Date())
        
        let timeZone = TimeZone.autoupdatingCurrent
        
        if let city = timeZone.identifier.split(separator: "/").last {
            let cityName = String(city).replacingOccurrences(of: "_", with: " ")
            self.regionIdentifier = cityName
        } else {
            self.regionIdentifier = timeZone.localizedName(for: .generic, locale: .current) ?? timeZone.identifier
        }
    }
}

import SwiftUI
import UniformTypeIdentifiers
import AppKit

// =========================================================================
// 🖥 5. 主控制效能视图 & PDF 导出核心
// =========================================================================

final class TaskPDFExportDocument: ReferenceFileDocument {
    typealias Snapshot = Data

    static var readableContentTypes: [UTType] { [.pdf] }
    var tasks: [TaskRecord]
    var exportDate: Date

    init(tasks: [TaskRecord], exportDate: Date = Date()) {
        self.tasks = tasks
        self.exportDate = exportDate
    }

    init(configuration: ReadConfiguration) throws {
        self.tasks = []
        self.exportDate = Date()
    }

    func snapshot(contentType: UTType) throws -> Data {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let dateString = formatter.string(from: exportDate)
        
        let titleFont = NSFont.boldSystemFont(ofSize: 22)
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: NSColor.black]
        let mainStr = NSMutableAttributedString(string: "Tasks Daily Report (\(dateString))\nExported on: \(formatter.string(from: Date()))\n\n", attributes: titleAttributes)
        
        let itemFont = NSFont.systemFont(ofSize: 13)
        let noteFont = NSFontManager.shared.convert(NSFont.systemFont(ofSize: 11), toHaveTrait: .italicFontMask)
        
        for task in tasks {
            let prefix = task.isCompleted ? "[✓]  " : "[ ]  "
            var timeRangeStr = ""
            if let start = task.startTime, let end = task.endTime {
                timeRangeStr = " [\(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))]"
            }
            let recurringStr = task.isRecurring ? " (fixed tasks)" : ""
            let itemAttributes: [NSAttributedString.Key: Any] = [
                .font: itemFont,
                .foregroundColor: task.isCompleted ? NSColor.lightGray : NSColor.black
            ]
            mainStr.append(NSAttributedString(string: "\(prefix)\(task.title)\(timeRangeStr)\(recurringStr)", attributes: itemAttributes))
            
            if !task.note.trimmingCharacters(in: .whitespaces).isEmpty {
                let noteAttributes: [NSAttributedString.Key: Any] = [
                    .font: noteFont,
                    .foregroundColor: NSColor.darkGray
                ]
                mainStr.append(NSAttributedString(string: "  (Note: \(task.note))", attributes: noteAttributes))
            }
            mainStr.append(NSAttributedString(string: "\n", attributes: itemAttributes))
        }
        
        let printView = NSTextField(frame: NSRect(x: 0, y: 0, width: 595, height: 842))
        printView.isEditable = false
        printView.isBordered = false
        printView.drawsBackground = true
        printView.backgroundColor = .white
        printView.attributedStringValue = mainStr
        
        return printView.dataWithPDF(inside: NSRect(x: 0, y: 0, width: 595, height: 842))
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: snapshot)
    }
}

struct ContentView: View {
    @State private var currentNavTab: String = "tasks"
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject var langManager = LanguageManager.shared
    @ObservedObject var sandboxManager = MailSandboxManager.shared
    
    @State private var taskTitle = ""
    @State private var enableTimeRange = false
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    
    @State var savedTasks: [TaskRecord] = [] { didSet { saveTasksToPersistentStore() } }
    @State private var selectedCalendarDate = Date()
    @State private var selectedTaskDate = Date()
    
    @State private var isShowingExporter = false
    @State private var exportDocument: TaskPDFExportDocument? = nil
    @State private var defaultExportName = "Tasks_Report.pdf"
    
    @State private var draggedTask: TaskRecord?
    
    // 精英微光脉冲与触觉控制变量
    @State private var pulseTaskId: UUID? = nil
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.0
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var selectedDayTasksFiltered: [TaskRecord] {
        savedTasks
            .filter { $0.isRecurring || Calendar.current.isDate($0.creationDate, inSameDayAs: selectedTaskDate) }
    }
    
    var body: some View {
        GlobalThemeWrapper(currentTab: currentNavTab) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 0) {
                    leftSidebarPanel
                    Rectangle().frame(width: 1).foregroundColor(Color.white.opacity(0.06))
                    rightContentPresenter
                }
                
                GlobalGeographicClockWidget()
                    .padding(.top, 20)
                    .padding(.trailing, 24)
                    .zIndex(99)
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
        .fileExporter(
            isPresented: $isShowingExporter,
            document: exportDocument,
            contentType: .pdf,
            defaultFilename: defaultExportName
        ) { result in
            switch result {
            case .success(let url): print("Successfully exported to custom location: \(url)")
            case .failure(let error): print("Export aborted: \(error)")
            }
        }
        .onAppear {
            loadTasksFromPersistentStore()
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ResetToFocusTab"), object: nil, queue: .main) { _ in
                self.currentNavTab = "tasks"
            }
        }
    }
    
    private var leftSidebarPanel: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: "CORE")
                    .font(.UniversalFont(size: 11, weight: .bold, design: .monospaced))
                    .UniversalTextColorModifier()
                Text(verbatim: LS("sys_mode"))
                    .font(.UniversalFont(size: 8, weight: .light, design: .default))
                    .UniversalTextColorModifier(opacity: 0.6)
            }
            .padding(.top, 32)
            .padding(.bottom, 20)
            
            VStack(spacing: 24) {
                SidebarLinkButton(tab: "tasks", code: "01", title: LS("nav_focus"), currentNavTab: $currentNavTab, theme: theme)
                SidebarLinkButton(tab: "timer", code: "02", title: LS("nav_timer"), currentNavTab: $currentNavTab, theme: theme)
                SidebarLinkButton(tab: "calendar", code: "03", title: LS("nav_calendar"), currentNavTab: $currentNavTab, theme: theme)
                SidebarLinkButton(tab: "mail", code: "04", title: LS("nav_mail"), currentNavTab: $currentNavTab, theme: theme, badgeCount: 0)
                SidebarLinkButton(tab: "themeSettings", code: "05", title: LS("nav_style"), currentNavTab: $currentNavTab, theme: theme)
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                Rectangle().frame(height: 0.5).foregroundColor(Color.white.opacity(0.08))
                    .padding(.bottom, 16)
                Button(action: {
                    DispatchQueue.main.async {
                        self.currentNavTab = "logs"
                    }
                }) {
                    SidebarLinkButton(tab: "logs", code: "06", title: LS("nav_logs"), currentNavTab: $currentNavTab, theme: theme)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
        }
        .frame(width: 100)
        .background(Color.black.opacity(0.1))
    }
    
    @ViewBuilder
    private var rightContentPresenter: some View {
        ZStack {
            if currentNavTab == "tasks" {
                tasksTabView.padding(32)
            }
            else if currentNavTab == "timer" {
                GlobalTimerSandboxView().padding(32)
            }
            else if currentNavTab == "calendar" {
                IndependentCalendarGridView(
                    savedTasks: $savedTasks,
                    selectedDate: $selectedCalendarDate,
                    onDailyExportRequested: { targetDate in
                        self.exportTasksToPDF(for: targetDate)
                    },
                    onMonthlyExportRequested: { monthDate, lineStates, notesMap in
                        print("Exporting monthly report: \(monthDate)")
                    }
                )
                .padding(32)
            }
            else if currentNavTab == "mail" {
                GlobalMailSandboxContainerView()
            }
            else if currentNavTab == "themeSettings" {
                GlobalThemeSettingView().padding(32)
            }
            else if currentNavTab == "logs" {
                GlobalWorkLogSandboxView().padding(32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var tasksTabView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: LS("console_title"))
                        .font(.UniversalFont(size: 18, weight: .regular))
                        .UniversalTextColorModifier()
                    Text(verbatim: LS("console_subtitle"))
                        .font(.UniversalFont(size: 10, design: .default))
                        .UniversalTextColorModifier(opacity: 0.5)
                }
                Spacer()
                
                Button(action: { exportCurrentPageTasksToPDF() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export PDF")
                    }
                    .font(.UniversalFont(size: 11, weight: .medium, design: .monospaced))
                    .UniversalTextColorModifier()
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                
                DatePicker("", selection: $selectedTaskDate, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(.field)
                    .frame(width: 110)
                    .padding(.trailing, 140)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .leading) {
                    if taskTitle.isEmpty {
                        Text(verbatim: LS("placeholder_task"))
                            .font(.UniversalFont(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    TextField("", text: $taskTitle, onCommit: executeQuickTaskCreation)
                        .textFieldStyle(.plain)
                        .font(.UniversalFont(size: 13, weight: .light))
                        .foregroundColor(.white)
                        .frame(height: 36)
                }
                
                HStack(spacing: 12) {
                    Toggle(isOn: $enableTimeRange) {
                        Text("Set Time Slot")
                            .font(.UniversalFont(size: 11, weight: .light))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .toggleStyle(.checkbox)
                    
                    if enableTimeRange {
                        DatePicker("", selection: $startTime, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.field)
                            .frame(width: 65)
                        
                        Text("to")
                            .font(.UniversalFont(size: 11, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                        
                        DatePicker("", selection: $endTime, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.field)
                            .frame(width: 65)
                    }
                    
                    Spacer()
                    
                    Button(action: executeQuickTaskCreation) {
                        Text("Add Task")
                            .font(.UniversalFont(size: 11, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(4)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                
                Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(taskTitle.isEmpty ? 0.08 : 0.25))
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    if selectedDayTasksFiltered.isEmpty {
                        HStack {
                            Text(verbatim: LS("empty_tip"))
                                .font(.UniversalFont(size: 11, weight: .light))
                                .UniversalTextColorModifier(opacity: 0.5)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    } else {
                        ForEach(selectedDayTasksFiltered, id: \.id) { task in
                            HStack(spacing: 14) {
                                // 拖拽抓手：AppKit 原生 onHover 手型
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.25))
                                    .onHover { inside in
                                        if inside {
                                            NSCursor.openHand.set()
                                        } else {
                                            NSCursor.arrow.set()
                                        }
                                    }
                                
                                // 💼 极简冷静的高级商业勾选组件
                                Button(action: {
                                    triggerExecutiveToggle(for: task)
                                }) {
                                    ZStack {
                                        // 触发完成时的无缝扩张微光晕 (Soft Pulse Glow)
                                        if pulseTaskId == task.id {
                                            Circle()
                                                .fill(theme.textColor.opacity(0.35))
                                                .frame(width: 15, height: 15)
                                                .scaleEffect(pulseScale)
                                                .opacity(pulseOpacity)
                                        }
                                        
                                        // 标准状态勾选图标
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(task.isCompleted ? theme.textColor : .white.opacity(0.3))
                                            .scaleEffect(pulseTaskId == task.id ? 0.94 : 1.0)
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                Text(task.title)
                                    .font(.UniversalFont(size: 13))
                                    .foregroundColor(task.isCompleted ? .white.opacity(0.3) : .white)
                                    .strikethrough(task.isCompleted, color: .white.opacity(0.3))
                                    .UniversalTextColorModifier(forceIgnoreIfImageMode: task.isCompleted)
                                    .animation(.easeInOut(duration: 0.25), value: task.isCompleted)
                                
                                if let start = task.startTime, let end = task.endTime {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 10))
                                        Text("\(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))")
                                            .font(.UniversalFont(size: 11, weight: .medium, design: .monospaced))
                                    }
                                    .foregroundColor(task.isCompleted ? .white.opacity(0.2) : .white.opacity(0.6))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(4)
                                }
                                
                                Button(action: {
                                    if let idx = savedTasks.firstIndex(where: { $0.id == task.id }) {
                                        savedTasks[idx].isRecurring.toggle()
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: task.isRecurring ? "pin.fill" : "pin")
                                            .font(.system(size: 11))
                                        Text(task.isRecurring ? "固定任务" : "Pin")
                                            .font(.UniversalFont(size: 11, weight: .light))
                                    }
                                    .foregroundColor(task.isRecurring ? .yellow : .white.opacity(0.4))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(task.isRecurring ? Color.yellow.opacity(0.15) : Color.white.opacity(0.05))
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                                
                                // 📝 批注文本框
                                TextField("Annotate...", text: Binding(
                                    get: { task.note },
                                    set: { newNote in
                                        if let idx = savedTasks.firstIndex(where: { $0.id == task.id }) {
                                            savedTasks[idx].note = newNote
                                        }
                                    }
                                ))
                                .textFieldStyle(.plain)
                                .font(.UniversalFont(size: 11, weight: .light))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                                .frame(maxWidth: 400)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let idx = savedTasks.firstIndex(where: { $0.id == task.id }) {
                                        savedTasks.remove(at: idx)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.15))
                                }.buttonStyle(.plain)
                            }
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .overlay(VStack{ Spacer(); Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.04)) })
                            .onDrag {
                                self.draggedTask = task
                                return NSItemProvider(object: task.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: TaskDropDelegate(item: task, tasks: $savedTasks, draggedItem: $draggedTask))
                        }
                    }
                }
            }
        }
    }
    
    // 💼 高度自控且高质感的精英切换逻辑
    private func triggerExecutiveToggle(for task: TaskRecord) {
        guard let idx = savedTasks.firstIndex(where: { $0.id == task.id }) else { return }
        let willComplete = !savedTasks[idx].isCompleted
        
        // 1. 商务沉稳音效
        if willComplete {
            NSSound(named: "Tink")?.play()
        } else {
            NSSound(named: "Pop")?.play()
        }
        
        // 2. 状态变更 & 精确缩放弹簧曲线
        self.pulseTaskId = task.id
        self.pulseScale = 1.0
        self.pulseOpacity = willComplete ? 0.8 : 0.0
        
        withAnimation(.interpolatingSpring(stiffness: 380, damping: 28)) {
            savedTasks[idx].isCompleted.toggle()
        }
        
        // 3. 微光平滑漫射并隐去 (Soft Glow Decay)
        if willComplete {
            withAnimation(.easeOut(duration: 0.22)) {
                self.pulseScale = 1.85
                self.pulseOpacity = 0.0
            }
        }
        
        // 4. 重置微光动画 ID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if self.pulseTaskId == task.id {
                self.pulseTaskId = nil
            }
        }
    }
    
    private func executeQuickTaskCreation() {
        guard !taskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var newTask = TaskRecord(title: taskTitle)
        newTask.creationDate = selectedTaskDate
        if enableTimeRange {
            newTask.startTime = startTime
            newTask.endTime = endTime
        }
        savedTasks.append(newTask)
        taskTitle = ""
    }
    
    private func exportCurrentPageTasksToPDF() {
        exportTasksToPDF(for: selectedTaskDate)
    }
    
    func exportTasksToPDF(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        let dateKey = formatter.string(from: date)
        
        let filtered = savedTasks.filter { $0.isRecurring || Calendar.current.isDate($0.creationDate, inSameDayAs: date) }
        
        self.defaultExportName = "Tasks_Report_\(dateKey).pdf"
        self.exportDocument = TaskPDFExportDocument(tasks: filtered, exportDate: date)
        
        DispatchQueue.main.async {
            self.isShowingExporter = true
        }
    }
    
    private func saveTasksToPersistentStore() { if let encoded = try? JSONEncoder().encode(savedTasks) { UserDefaults.standard.set(encoded, forKey: "CoreSavedTaskDataStoreV2") } }
    private func loadTasksFromPersistentStore() { if let data = UserDefaults.standard.data(forKey: "CoreSavedTaskDataStoreV2"), let decoded = try? JSONDecoder().decode([TaskRecord].self, from: data) { self.savedTasks = decoded } }
}

// =========================================================================
// 🔀 拖拽排序 DropDelegate 代理支持（含音效触发）
// =========================================================================

struct TaskDropDelegate: DropDelegate {
    let item: TaskRecord
    @Binding var tasks: [TaskRecord]
    @Binding var draggedItem: TaskRecord?

    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem.id != item.id,
              let fromIndex = tasks.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = tasks.firstIndex(where: { $0.id == item.id }) else { return }

        // 🎵 鼠标拖拽任务划过列表项时触发低调的 Pop 提示音
        NSSound(named: "Pop")?.play()

        withAnimation(.default) {
            tasks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        return true
    }
}
// =========================================================================
// 🕒 5.5 精密时间流控制台与工业级多分类归档系统
// =========================================================================

struct LocalTimerDisplayItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    let modeRaw: String
    let durationInSeconds: Int
    var category: String
}

struct GlobalTimerSandboxView: View {
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject var timerManager = TimerSandboxManager.shared
    
    @State private var currentMode: TimerMode = .stopwatch
    @State private var currentTimerTitle: String = ""
    
    @State private var categories: [String] = ["Inbox", "Work", "Design", "Life"]
    @State private var selectedCategoryFilter: String = "All"
    @State private var currentSelectedCategory: String = "Inbox"
    @State private var newCategoryName: String = ""
    @State private var showAddCategoryPopover = false
    
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var secondsElapsed = 0
    @State private var countdownDuration = 1500
    @State private var initialCountdownTotal = 1500
    
    @State private var isFullScreenExpanded: Bool = false
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 25
    @State private var selectedSeconds: Int = 0
    
    private var totalSelectedSeconds: Int {
        let total = (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds
        return total > 0 ? total : 1500
    }
    
    @State private var editingRecordID: UUID? = nil
    @State private var editingTitleText: String = ""
    
    @State private var showHourPopover = false
    @State private var showMinutePopover = false
    @State private var showSecondPopover = false
    
    let coreEnginePublisher = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var timeFormattedString: String {
        let total = currentMode == .stopwatch ? secondsElapsed : countdownDuration
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    
    private var isStopwatch: Bool { currentMode == .stopwatch }
    private var isCountdown: Bool { currentMode == .countdown }
    private var hasStarted: Bool {
        secondsElapsed > 0 || (currentMode == .countdown && countdownDuration != initialCountdownTotal)
    }
    
    private var safeRecords: [LocalTimerDisplayItem] {
        return timerManager.historyRecords.map { item in
            return LocalTimerDisplayItem(
                id: item.id,
                title: item.title,
                modeRaw: item.mode.rawValue,
                durationInSeconds: item.durationInSeconds,
                category: item.category
            )
        }
    }
    
    private var filteredRecords: [LocalTimerDisplayItem] {
        if selectedCategoryFilter == "All" {
            return safeRecords
        }
        return safeRecords.filter { $0.category == selectedCategoryFilter }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 28) {
            leftFolderManagerPanel
                .frame(width: 160)
            
            VStack(spacing: 20) {
                modeSelectorSegment
                
                if currentMode == .countdown && !isRunning && !isPaused {
                    timeAdjusterPanel
                } else {
                    currentActiveConfigLabel
                }
                
                taskTitleInputField
                giantDisplayZone
                advancedControlMatrix
            }
            .frame(width: 320)
            
            Spacer(minLength: 12)
            
            rightHistorySection
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .overlay(fullScreenImmersiveOverlay)
        .onReceive(coreEnginePublisher) { _ in
            guard isRunning && !isPaused else { return }
            if currentMode == .stopwatch {
                secondsElapsed += 1
            } else {
                if countdownDuration > 0 {
                    countdownDuration -= 1
                } else {
                    isRunning = false
                    commitAndArchiveSession()
                }
            }
        }
    }
    
    private var leftFolderManagerPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CHRONO CORE")
                    .font(.UniversalFont(size: 11, weight: .bold, design: .monospaced))
                    .UniversalTextColorModifier()
                    .tracking(1.2)
                Text("Advanced Timebase Pipeline")
                    .font(.UniversalFont(size: 9, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
            }
            Rectangle().frame(height: 0.5).foregroundColor(.white.opacity(0.08))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Archive Folders (View Targets)")
                    .font(.UniversalFont(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(0.5)
                    .padding(.bottom, 2)
                
                Button(action: { selectedCategoryFilter = "All" }) {
                    HStack {
                        Image(systemName: "tray.2.fill")
                        Text("Archive History")
                        Spacer()
                        Text("\(safeRecords.count)").font(.UniversalFont(size: 9, design: .monospaced))
                    }
                    .font(.UniversalFont(size: 11, weight: selectedCategoryFilter == "All" ? .medium : .regular))
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(selectedCategoryFilter == "All" ? Color.white.opacity(0.06) : Color.clear)
                    .foregroundColor(selectedCategoryFilter == "All" ? .white : .white.opacity(0.5))
                    .UniversalTextColorModifier(forceIgnoreIfImageMode: selectedCategoryFilter != "All")
                    .cornerRadius(4)
                }.buttonStyle(.plain)
                
                ForEach(categories, id: \.self) { folder in
                    let count = safeRecords.filter { $0.category == folder }.count
                    Button(action: { selectedCategoryFilter = folder }) {
                        HStack {
                            Image(systemName: "folder.fill" )
                            Text(folder)
                            Spacer()
                            if count > 0 {
                                Text("\(count)").font(.UniversalFont(size: 9, design: .monospaced))
                            }
                        }
                        .font(.UniversalFont(size: 11, weight: selectedCategoryFilter == folder ? .medium : .regular))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(selectedCategoryFilter == folder ? Color.white.opacity(0.06) : Color.clear)
                        .foregroundColor(selectedCategoryFilter == folder ? .white : .white.opacity(0.5))
                        .UniversalTextColorModifier(forceIgnoreIfImageMode: selectedCategoryFilter != folder)
                        .cornerRadius(4)
                    }.buttonStyle(.plain)
                }
                
                Button(action: { showAddCategoryPopover.toggle() }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create New Folder...")
                    }
                    .font(.UniversalFont(size: 10, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showAddCategoryPopover, arrowEdge: .trailing) {
                    VStack(spacing: 8) {
                        TextField("Folder Name", text: $newCategoryName)
                            .textFieldStyle(.plain)
                            .font(.UniversalFont(size: 11))
                            .padding(6)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(4)
                        Button("Confirm Creation") {
                            let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && !categories.contains(trimmed) {
                                categories.append(trimmed)
                            }
                            newCategoryName = ""
                            showAddCategoryPopover = false
                        }
                        .buttonStyle(.borderless)
                        .font(.UniversalFont(size: 11, weight: .medium))
                    }
                    .padding(10)
                    .frame(width: 120)
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Target Folder")
                    .font(.UniversalFont(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
                Picker("", selection: $currentSelectedCategory) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .font(.UniversalFont(size: 10))
            }
            .padding(8)
            .background(Color.white.opacity(0.03))
            .cornerRadius(4)
        }
    }
    
    private var modeSelectorSegment: some View {
        HStack(spacing: 2) {
            Button(action: { changeMode(.stopwatch) }) {
                Text("CHRONO Count Up")
                    .font(.UniversalFont(size: 10, weight: isStopwatch ? .semibold : .regular, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(isStopwatch ? Color.white.opacity(0.15) : Color.white.opacity(0.04))
                    .foregroundColor(.white)
                    .UniversalTextColorModifier(forceIgnoreIfImageMode: !isStopwatch)
            }.buttonStyle(.plain)
            
            Button(action: { changeMode(.countdown) }) {
                Text("COUNT Countdown")
                    .font(.UniversalFont(size: 10, weight: isCountdown ? .semibold : .regular, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(isCountdown ? Color.white.opacity(0.15) : Color.white.opacity(0.04))
                    .foregroundColor(.white)
                    .UniversalTextColorModifier(forceIgnoreIfImageMode: !isCountdown)
            }.buttonStyle(.plain)
        }
        .cornerRadius(4)
    }
    
    private var timeAdjusterPanel: some View {
        HStack(spacing: 8) {
            Button(action: { showHourPopover.toggle() }) {
                Text(String(format: "%02dH", selectedHours))
                    .font(.UniversalFont(size: 11, weight: .medium, design: .monospaced))
                    .UniversalTextColorModifier()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(3)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showHourPopover, arrowEdge: .bottom) {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(0..<24, id: \.self) { h in
                            Button("\(h) hour") {
                                selectedHours = h
                                syncAdjustedCountdownDuration()
                                showHourPopover = false
                            }
                            .buttonStyle(.borderless)
                            .font(.UniversalFont(size: 11))
                        }
                    }.padding(6)
                }.frame(height: 150)
            }
            
            Text(":")
                .font(.UniversalFont(size: 11))
                .foregroundColor(.white.opacity(0.3))
            
            Button(action: { showMinutePopover.toggle() }) {
                Text(String(format: "%02dM", selectedMinutes))
                    .font(.UniversalFont(size: 11, weight: .medium, design: .monospaced))
                    .UniversalTextColorModifier()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(3)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showMinutePopover, arrowEdge: .bottom) {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(0..<60, id: \.self) { m in
                            Button("\(m) minute") {
                                selectedMinutes = m
                                syncAdjustedCountdownDuration()
                                showMinutePopover = false
                            }
                            .buttonStyle(.borderless)
                            .font(.UniversalFont(size: 11))
                        }
                    }.padding(6)
                }.frame(height: 150)
            }
            
            Text(":")
                .font(.UniversalFont(size: 11))
                .foregroundColor(.white.opacity(0.3))
            
            Button(action: { showSecondPopover.toggle() }) {
                Text(String(format: "%02dS", selectedSeconds))
                    .font(.UniversalFont(size: 11, weight: .medium, design: .monospaced))
                    .UniversalTextColorModifier()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(3)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showSecondPopover, arrowEdge: .bottom) {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(0..<60, id: \.self) { s in
                            Button("\(s) second") {
                                selectedSeconds = s
                                syncAdjustedCountdownDuration()
                                showSecondPopover = false
                            }
                            .buttonStyle(.borderless)
                            .font(.UniversalFont(size: 11))
                        }
                    }.padding(6)
                }.frame(height: 150)
            }
        }
    }
    
    private var currentActiveConfigLabel: some View {
        Text(currentMode == .stopwatch ? "Timebase Engine [Destination➔ \(currentSelectedCategory)]" : "Countdown Quota Engine [Destination➔ \(currentSelectedCategory)]")
            .font(.UniversalFont(size: 10, weight: .medium, design: .monospaced))
            .UniversalTextColorModifier(opacity: 0.5)
            .frame(height: 21)
    }
    
    private var taskTitleInputField: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "tag.fill")
                    .font(.system(size: 9))
                    .UniversalTextColorModifier()
                TextField("Enter event tag...", text: $currentTimerTitle)
                    .textFieldStyle(.plain)
                    .font(.UniversalFont(size: 11))
                    .foregroundColor(.white)
            }
            .padding(8)
            .background(Color.white.opacity(0.04))
            .cornerRadius(4)
        }
    }
    
    private var giantDisplayZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.textColor.opacity(0.2), lineWidth: 1)
                )
            
            VStack(spacing: 6) {
                Text(timeFormattedString)
                    .font(.UniversalFont(size: 46, weight: .bold, design: .monospaced))
                    .UniversalTextColorModifier()
                    .tracking(0.5)
                
                HStack(spacing: 4) {
                    Circle()
                        .frame(width: 5, height: 5)
                        .foregroundColor(isRunning ? (isPaused ? .yellow : Color(red: 0.2, green: 0.9, blue: 0.4)) : .red)
                    Text(isRunning ? (isPaused ? "PAUSED" : "RUNNING") : "STANDBY")
                        .font(.UniversalFont(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(.vertical, 24)
        }
    }
    
    private var advancedControlMatrix: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                if !isRunning {
                    Button(action: startTimerEngine) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        .font(.UniversalFont(size: 11, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .UniversalTextColorModifier()
                        .cornerRadius(4)
                    }.buttonStyle(.plain)
                } else {
                    Button(action: togglePauseEngine) {
                        HStack {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            Text(isPaused ? "Resume" : "Safe Pause")
                        }
                        .font(.UniversalFont(size: 11, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isPaused ? Color.green : Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(4)
                    }.buttonStyle(.plain)
                    
                    Button(action: resetTimerEngine) {
                        HStack {
                            Image(systemName: "gobackward")
                            Text("Abort & Reset")
                        }
                        .font(.UniversalFont(size: 11, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    }.buttonStyle(.plain)
                }
                
                Button(action: { isFullScreenExpanded = true }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 11))
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }.buttonStyle(.plain)
            }
            
            if isRunning {
                Button(action: {
                    self.isPaused = true
                    self.commitAndArchiveSession()
                }) {
                    HStack {
                        Image(systemName: "archivebox.fill")
                        Text("Pause and Archive to[\(currentSelectedCategory)]")
                    }
                    .font(.UniversalFont(size: 10, weight: .semibold, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .UniversalTextColorModifier()
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var rightHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CHRONO STREAM")
                        .font(.UniversalFont(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Active Filter: \(selectedCategoryFilter)")
                        .font(.UniversalFont(size: 8, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
            }
            
            ScrollView {
                VStack(spacing: 8) {
                    if filteredRecords.isEmpty {
                        Text("No Archived Logs")
                            .font(.UniversalFont(size: 10, weight: .light))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.top, 40)
                    } else {
                        ForEach(filteredRecords, id: \.id) { record in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    if editingRecordID == record.id {
                                        TextField("", text: $editingTitleText, onCommit: {
                                            timerManager.renameRecord(id: record.id, newTitle: editingTitleText)
                                            editingRecordID = nil
                                        })
                                        .textFieldStyle(.plain)
                                        .font(.UniversalFont(size: 12))
                                        .foregroundColor(.white)
                                    } else {
                                        Text(record.title)
                                            .font(.UniversalFont(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.85))
                                            .UniversalTextColorModifier()
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Text(record.modeRaw)
                                            .font(.UniversalFont(size: 8, weight: .bold))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(record.modeRaw == "Count Up" ? Color.blue.opacity(0.3) : Color.purple.opacity(0.3))
                                            .foregroundColor(.white)
                                            .cornerRadius(2)
                                        
                                        Text("📂 \(record.category)")
                                            .font(.UniversalFont(size: 8, weight: .medium, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.7))
                                            .UniversalTextColorModifier()
                                        
                                        Text("Duration: \(record.durationInSeconds)second")
                                            .font(.UniversalFont(size: 9, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                }
                                Spacer()
                                
                                Button(action: {
                                    if editingRecordID == record.id {
                                        timerManager.renameRecord(id: record.id, newTitle: editingTitleText)
                                        editingRecordID = nil
                                    } else {
                                        editingRecordID = record.id
                                        editingTitleText = record.title
                                    }
                                }) {
                                    Image(systemName: editingRecordID == record.id ? "checkmark" : "pencil")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.3))
                                }.buttonStyle(.plain)
                                
                                Button(action: { timerManager.deleteRecord(id: record.id) }) {
                                    Image(systemName: "xmark.circle")
                                        .font(.system(size: 11))
                                        .foregroundColor(.red.opacity(0.4))
                                }.buttonStyle(.plain)
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.04), lineWidth: 0.5)
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var fullScreenImmersiveOverlay: some View {
        ZStack {
            if isFullScreenExpanded {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    HStack {
                        Spacer()
                        Button(action: { isFullScreenExpanded = false }) {
                            Image(systemName: "arrow.down.right.and.arrow.down.right")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }.buttonStyle(.plain)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        if !currentTimerTitle.isEmpty {
                            Text(currentTimerTitle)
                                .font(.UniversalFont(size: 24, weight: .light))
                                .foregroundColor(.white.opacity(0.6))
                                .UniversalTextColorModifier()
                                .tracking(2)
                        }
                        
                        Text(timeFormattedString)
                            .font(.UniversalFont(size: 120, weight: .bold, design: .monospaced))
                            .UniversalTextColorModifier()
                    }
                    
                    HStack(spacing: 24) {
                        Button(action: togglePauseEngine) {
                            Text("PAUSE")
                                .font(.UniversalFont(size: 14, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(isPaused ? Color.green : Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .UniversalTextColorModifier()
                                .cornerRadius(6)
                        }.buttonStyle(.plain)
                        
                        Button(action: {
                            self.isPaused = true
                            self.commitAndArchiveSession()
                            self.isFullScreenExpanded = false
                        }) {
                            Text("Archive & Exit")
                                .font(.UniversalFont(size: 14, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .UniversalTextColorModifier()
                                .cornerRadius(6)
                        }.buttonStyle(.plain)
                        
                        Button(action: resetTimerEngine) {
                            Text("RESET")
                                .font(.UniversalFont(size: 14, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }.buttonStyle(.plain)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func changeMode(_ mode: TimerMode) {
        guard !isRunning else { return }
        currentMode = mode
        resetTimerEngine()
    }
    
    private func syncAdjustedCountdownDuration() {
        countdownDuration = totalSelectedSeconds
        initialCountdownTotal = totalSelectedSeconds
    }
    
    private func startTimerEngine() {
        if currentMode == .countdown {
            countdownDuration = totalSelectedSeconds
            initialCountdownTotal = totalSelectedSeconds
        } else {
            secondsElapsed = 0
        }
        isRunning = true
        isPaused = false
    }
    
    private func togglePauseEngine() {
        isPaused.toggle()
    }
    
    private func resetTimerEngine() {
        isRunning = false
        isPaused = false
        secondsElapsed = 0
        countdownDuration = totalSelectedSeconds
        initialCountdownTotal = totalSelectedSeconds
    }
    
    private func commitAndArchiveSession() {
        let finalDuration = currentMode == .stopwatch ? secondsElapsed : (initialCountdownTotal - countdownDuration)
        timerManager.addRecord(title: currentTimerTitle, mode: currentMode, seconds: finalDuration, category: currentSelectedCategory)
        currentTimerTitle = ""
        resetTimerEngine()
    }
}

// =========================================================================
// 📅 独立日历布局矩阵（空间画画廊版 - Apple 日历长条拖拽交互 + 时间段与 Circle 交互支持）
// =========================================================================
import SwiftUI
import AppKit

// 💾 独立的可结构化持久化批注数据模型
struct CalendarNote: Identifiable, Codable {
    var id = UUID()
    var text: String
    var fontName: String
    var fontSize: CGFloat
    
    var isBold: Bool
    var isItalic: Bool
    var isUnderline: Bool
    
    var colorComponents: [CGFloat]
    
    var xOffset: CGFloat
    var yOffset: CGFloat
    
    var textColor: Color {
        guard colorComponents.count == 4 else { return .white }
        return Color(red: Double(colorComponents[0]), green: Double(colorComponents[1]), blue: Double(colorComponents[2])).opacity(Double(colorComponents[3]))
    }
    
    init(text: String, fontName: String = "System", fontSize: CGFloat = 12, isBold: Bool = false, isItalic: Bool = false, isUnderline: Bool = false, textColor: Color = .white, xOffset: CGFloat, yOffset: CGFloat) {
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderline = isUnderline
        self.xOffset = xOffset
        self.yOffset = yOffset
        
        let nsColor = NSColor(textColor)
        if let rgbColor = nsColor.usingColorSpace(.deviceRGB) {
            self.colorComponents = [rgbColor.redComponent, rgbColor.greenComponent, rgbColor.blueComponent, rgbColor.alphaComponent]
        } else {
            self.colorComponents = [1, 1, 1, 1]
        }
    }
}

// 🎨 单个日期的荧光笔着色模型
struct DateHighlightColor: Codable {
    var colorComponents: [CGFloat]
    
    var color: Color {
        guard colorComponents.count == 4 else { return .yellow }
        return Color(red: Double(colorComponents[0]), green: Double(colorComponents[1]), blue: Double(colorComponents[2])).opacity(Double(colorComponents[3]))
    }
    
    init(color: Color) {
        let nsColor = NSColor(color)
        if let rgbColor = nsColor.usingColorSpace(.deviceRGB) {
            self.colorComponents = [rgbColor.redComponent, rgbColor.greenComponent, rgbColor.blueComponent, rgbColor.alphaComponent]
        } else {
            self.colorComponents = [1, 0.9, 0.2, 0.4]
        }
    }
}

// 📅 系统月历内嵌日程事件数据模型（升级：支持时间段 Duration 以及 不确定时间横线）
struct CalendarEvent: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date       // 开始日期
    var endDate: Date?   // 结束日期
    var colorComponents: [CGFloat]
    var isReminder: Bool = false
    var fontName: String = "System"
    
    // 时间段（Duration）开关与具体的开始/结束时间
    var hasSpecificTime: Bool = false
    var startTime: Date = Date()
    var endTime: Date = Date().addingTimeInterval(3600) // 默认 1 小时时长
    
    // 新增：开始/结束时间是否不确定（不确定则显示横线 '-'）
    var isStartTimeUnknown: Bool = false
    var isEndTimeUnknown: Bool = false
    
    var color: Color {
        guard colorComponents.count == 4 else { return .blue }
        return Color(red: Double(colorComponents[0]), green: Double(colorComponents[1]), blue: Double(colorComponents[2])).opacity(Double(colorComponents[3]))
    }
    
    var actualEndDate: Date {
        endDate ?? date
    }
    
    // 带有时间段与不确定横线的格式化显示文本
    var displayTitle: String {
        if hasSpecificTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            let startStr = isStartTimeUnknown ? "-" : formatter.string(from: startTime)
            let endStr = isEndTimeUnknown ? "-" : formatter.string(from: endTime)
            
            return "\(startStr)-\(endStr) \(title)"
        }
        return title
    }
    
    init(title: String, date: Date, endDate: Date? = nil, color: Color = Color.blue.opacity(0.3), isReminder: Bool = false, fontName: String = "System", hasSpecificTime: Bool = false, startTime: Date = Date(), endTime: Date = Date().addingTimeInterval(3600), isStartTimeUnknown: Bool = false, isEndTimeUnknown: Bool = false) {
        self.date = Calendar.current.startOfDay(for: date)
        self.endDate = endDate != nil ? Calendar.current.startOfDay(for: endDate!) : Calendar.current.startOfDay(for: date)
        self.title = title
        self.isReminder = isReminder
        self.fontName = fontName
        self.hasSpecificTime = hasSpecificTime
        self.startTime = startTime
        self.endTime = endTime
        self.isStartTimeUnknown = isStartTimeUnknown
        self.isEndTimeUnknown = isEndTimeUnknown
        
        let nsColor = NSColor(color)
        if let rgbColor = nsColor.usingColorSpace(.deviceRGB) {
            self.colorComponents = [rgbColor.redComponent, rgbColor.greenComponent, rgbColor.blueComponent, rgbColor.alphaComponent]
        } else {
            self.colorComponents = [0.2, 0.5, 0.9, 0.5]
        }
    }
}

// ⭐ 星星标记的状态枚举
enum CustomStarState: String, Codable, CaseIterable {
    case none = "none"
    case yellow = "yellow"
    case red = "red"
    case black = "black"
    case white = "white"
    case purple = "purple"
    case green = "green"
}

struct CalendarColorItem: Identifiable, Equatable {
    var id = UUID()
    var color: Color
    
    static func == (lhs: CalendarColorItem, rhs: CalendarColorItem) -> Bool {
        let nsL = NSColor(lhs.color).usingColorSpace(.deviceRGB)
        let nsR = NSColor(rhs.color).usingColorSpace(.deviceRGB)
        guard let l = nsL, let r = nsR else { return false }
        return abs(l.redComponent - r.redComponent) < 0.05 &&
               abs(l.greenComponent - r.greenComponent) < 0.05 &&
               abs(l.blueComponent - r.blueComponent) < 0.05
    }
}

struct IndependentCalendarGridView: View {
    @Binding var savedTasks: [TaskRecord]
    @Binding var selectedDate: Date
    var onDailyExportRequested: (Date) -> Void
    var onMonthlyExportRequested: (Date, [Date: Color], [String: String]) -> Void
    
    @ObservedObject var theme = ThemeManager.shared
    
    @State private var showBaseGuide: Bool = !UserDefaults.standard.bool(forKey: "HasDismissedCalendarBaseGuideV2")
    @State private var showNoteGuide: Bool = !UserDefaults.standard.bool(forKey: "HasDismissedCalendarNoteGuideV2")
    
    @State private var singleDateHighlights: [Date: DateHighlightColor] = [:] {
        didSet { saveCalendarStatesToDisk() }
    }
    @State private var dateStarMarkers: [Date: CustomStarState] = [:] {
        didSet { saveCalendarStatesToDisk() }
    }
    @State private var activeLineColor: Color = Color.yellow.opacity(0.4) {
        didSet { saveCalendarStatesToDisk() }
    }
    @State private var dateNotes: [Date: [CalendarNote]] = [:] {
        didSet { saveCalendarStatesToDisk() }
    }
    
    @State private var calendarEvents: [CalendarEvent] = [] {
        didSet { saveCalendarStatesToDisk() }
    }
    
    @State private var popoverTargetDate: Date? = nil
    @State private var showMoreEventsDate: Date? = nil
    @State private var quickEventTitle: String = ""
    @State private var quickEventColor: Color = Color(red: 0.22, green: 0.67, blue: 0.93)
    @State private var quickEventIsReminder: Bool = false
    
    // 快速创建弹窗的时间段状态
    @State private var quickEventHasTime: Bool = false
    @State private var quickEventStartTime: Date = Date()
    @State private var quickEventEndTime: Date = Date().addingTimeInterval(3600)
    @State private var quickEventIsStartUnknown: Bool = false
    @State private var quickEventIsEndUnknown: Bool = false
    
    @State private var activeEditingEventId: UUID? = nil
    @State private var editingEventTitle: String = ""
    @State private var editingEventColor: Color = Color(red: 0.22, green: 0.67, blue: 0.93)
    @State private var editingEventFontName: String = "System"
    @State private var editingEventHasTime: Bool = false
    @State private var editingEventStartTime: Date = Date()
    @State private var editingEventEndTime: Date = Date().addingTimeInterval(3600)
    @State private var editingEventIsStartUnknown: Bool = false
    @State private var editingEventIsEndUnknown: Bool = false
    @State private var popoverMenuLocation: CGPoint = .zero
    
    @State private var activeEditingNoteId: UUID? = nil
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var currentDraggingId: UUID? = nil
    @State private var dragTranslation: CGSize = .zero
    
    @State private var isInternalLoading: Bool = false
    
    // Apple 风格全局捕捉拖拽变量
    @State private var dragTrackStartIndex: Int? = nil
    @State private var dragTrackCurrentIndex: Int? = nil
    
    // 单元格与画板参数
    private let cellHeight: CGFloat = 130
    private let gridSpacing: CGFloat = 10
    private let maxVisibleSlotsPerCell: Int = 3
    
    private var allSystemFonts: [String] {
        ["System"] + NSFontManager.shared.availableFontFamilies.sorted()
    }
    
    private var currentMonthKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: selectedDate)
    }
    
    private var calendarGridDates: [Date?] {
        guard let range = Calendar.current.range(of: .day, in: .month, for: selectedDate),
              let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedDate)) else { return [] }
        
        let weekday = Calendar.current.component(.weekday, from: startOfMonth)
        var days: [Date?] = Array(repeating: nil, count: weekday - 1)
        for day in range {
            if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    private var activeDisplayColors: [CalendarColorItem] {
        var uniquelyFound: [CalendarColorItem] = []
        let sortedDates = calendarGridDates.compactMap { $0 }.sorted()
        for date in sortedDates {
            let targetDateStart = Calendar.current.startOfDay(for: date)
            if let highlight = singleDateHighlights[targetDateStart] {
                let currentGridColor = CalendarColorItem(color: highlight.color)
                if !uniquelyFound.contains(where: { $0 == currentGridColor }) {
                    uniquelyFound.append(currentGridColor)
                }
            }
        }
        return uniquelyFound
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if showBaseGuide || showNoteGuide {
                VStack(spacing: 8) {
                    if showBaseGuide { baseUsageGuideBanner }
                    if showNoteGuide { noteUsageGuideBanner }
                }
            }
            
            topControlBar
            
            renderCompleteCalendarView()
            
            bottomActionBar
        }
        .padding(.trailing, 4)
        .onAppear {
            loadCalendarStatesFromDisk()
        }
        .onChange(of: currentMonthKey) { oldMonth, newMonth in
            loadCalendarStatesFromDisk()
        }
    }
    
    // 🖼️ 完整日历主体视图
    @ViewBuilder
    private func renderCompleteCalendarView(forExport: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            weekdayHeaderView
            
            GeometryReader { gridGeo in
                let totalWidth = gridGeo.size.width
                let cellWidth = (totalWidth - (6 * gridSpacing)) / 7
                
                ZStack(alignment: .topLeading) {
                    calendarGridView(cellWidth: cellWidth)
                    
                    // 数学精准几何坐标绘制跨天日程条
                    renderMathematicalCrossDayEventBars(cellWidth: cellWidth)
                    
                    // 实时 Apple 风格划选渲染
                    if let startIdx = dragTrackStartIndex, let currIdx = dragTrackCurrentIndex {
                        renderAppleStyleDragSelection(startIdx: startIdx, currentIdx: currIdx, cellWidth: cellWidth)
                    }
                    
                    if !forExport {
                        Color.clear
                            .frame(width: 1, height: 1)
                            .offset(x: popoverMenuLocation.x, y: popoverMenuLocation.y)
                            .popover(isPresented: Binding(
                                get: { activeEditingEventId != nil },
                                set: { show in if !show { activeEditingEventId = nil } }
                            ), arrowEdge: .bottom) {
                                eventDetailConfigureSettingsPanel()
                            }
                        
                        ForEach(dateNotes.keys.sorted(), id: \.self) { date in
                            if currentMonthKey == getYearMonthString(for: date), let notes = dateNotes[date] {
                                ForEach(notes) { note in
                                    renderFloatingNote(note, originDate: date)
                                }
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gestureValue in
                            let point = gestureValue.location
                            let col = max(0, min(6, Int(point.x / (cellWidth + gridSpacing))))
                            let row = max(0, Int(point.y / (cellHeight + gridSpacing)))
                            let index = row * 7 + col
                            
                            if index >= 0 && index < calendarGridDates.count && calendarGridDates[index] != nil {
                                if dragTrackStartIndex == nil {
                                    dragTrackStartIndex = index
                                }
                                dragTrackCurrentIndex = index
                            }
                        }
                        .onEnded { gestureValue in
                            if let sIdx = dragTrackStartIndex, let cIdx = dragTrackCurrentIndex, sIdx != cIdx {
                                createAppleStyleEventFromDrag(startIndex: sIdx, endIndex: cIdx)
                            } else if let sIdx = dragTrackStartIndex, let targetDate = calendarGridDates[sIdx] {
                                self.selectedDate = targetDate
                                self.popoverTargetDate = targetDate
                            }
                            dragTrackStartIndex = nil
                            dragTrackCurrentIndex = nil
                        }
                )
            }
            .frame(height: CGFloat(ceil(Double(calendarGridDates.count) / 7.0)) * (cellHeight + gridSpacing))
        }
    }
    
    private func getYearMonthString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    private var baseUsageGuideBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("🎨").font(.system(size: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text("Basic Markup Guide").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                Text("• Click date number: Highlight background.\n• Click empty space: Quick add event.\n• Drag selection: Create multi-day events, just like Apple Calendar.").font(.system(size: 11)).foregroundColor(.white.opacity(0.8)).lineSpacing(3)
            }
            Spacer()
            Button(action: {
                showBaseGuide = false
                UserDefaults.standard.set(true, forKey: "HasDismissedCalendarBaseGuideV2")
            }) {
                Text("Dismiss").font(.system(size: 10, weight: .medium)).foregroundColor(.yellow).padding(.horizontal, 8).padding(.vertical, 3).background(Color.yellow.opacity(0.12)).cornerRadius(4)
            }.buttonStyle(.plain)
        }
        .padding(10).background(Color.blue.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue.opacity(0.2), lineWidth: 1)).cornerRadius(8)
    }
    
    private var noteUsageGuideBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("✍️").font(.system(size: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text("Pro Tips").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                Text("• Double-click below date: Add floating note. Drag to reposition anytime.").font(.system(size: 11)).foregroundColor(.white.opacity(0.8)).lineSpacing(3)
            }
            Spacer()
            Button(action: {
                showNoteGuide = false
                UserDefaults.standard.set(true, forKey: "HasDismissedCalendarNoteGuideV2")
            }) {
                Text("Dismiss").font(.system(size: 10, weight: .medium)).foregroundColor(.yellow).padding(.horizontal, 8).padding(.vertical, 3).background(Color.yellow.opacity(0.12)).cornerRadius(4)
            }.buttonStyle(.plain)
        }
        .padding(10).background(Color.purple.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.purple.opacity(0.2), lineWidth: 1)).cornerRadius(8)
    }
    
    private var topControlBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Button(action: { moveMonth(by: -1) }) {
                        Image(systemName: "chevron.left").font(.system(size: 14, weight: .bold)).UniversalTextColorModifier()
                    }.buttonStyle(.plain)
                    
                    Text(selectedDate, style: .date)
                        .font(.UniversalFont(size: 18, weight: .bold, design: .monospaced))
                        .UniversalTextColorModifier()
                        .frame(minWidth: 140, alignment: .leading)
                    
                    Button(action: { moveMonth(by: 1) }) {
                        Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).UniversalTextColorModifier()
                    }.buttonStyle(.plain)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    if !activeDisplayColors.isEmpty {
                        HStack(spacing: 6) {
                            Text("Active Highlighters:").font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
                            ForEach(activeDisplayColors) { colorItem in
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 4).fill(colorItem.color).frame(width: 22, height: 22).overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.3), lineWidth: 1))
                                        .onTapGesture { handleQuickPaletteTap(colorItem.color) }
                                    
                                    Button(action: { purgeColorFromCurrentMonth(colorItem.color) }) {
                                        ZStack {
                                            Circle().fill(Color.black.opacity(0.85)).frame(width: 10, height: 10)
                                            Image(systemName: "xmark").font(.system(size: 6, weight: .bold)).foregroundColor(.white)
                                        }
                                    }.buttonStyle(.plain).offset(x: -4, y: -4)
                                }.frame(width: 24, height: 24)
                            }
                        }
                    }
                    
                    Text("Brush Color:").font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
                    ColorPicker("", selection: $activeLineColor).labelsHidden().frame(width: 24, height: 24)
                    
                    if !singleDateHighlights.isEmpty || !dateStarMarkers.isEmpty || !calendarEvents.isEmpty {
                        Button("Clear All Events & Marks") {
                            singleDateHighlights.removeAll()
                            dateStarMarkers.removeAll()
                            calendarEvents.removeAll()
                            dateNotes.removeAll()
                        }
                        .font(.system(size: 11, weight: .bold)).foregroundColor(.red.opacity(0.8)).buttonStyle(.plain).padding(.horizontal, 8).padding(.vertical, 3).background(Color.red.opacity(0.1)).cornerRadius(4)
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.04)).cornerRadius(8)
            }
        }
    }
    
    private var weekdayHeaderView: some View {
        let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        return HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day).font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundColor(.white.opacity(0.4)).frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func calendarGridView(cellWidth: CGFloat) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: 7)
        
        return LazyVGrid(columns: columns, spacing: gridSpacing) {
            ForEach(0..<calendarGridDates.count, id: \.self) { index in
                let dateOpt = calendarGridDates[index]
                
                ZStack(alignment: .topLeading) {
                    calendarCell(for: dateOpt, gridIndex: index, cellWidth: cellWidth)
                }
                .frame(maxWidth: .infinity)
                .frame(height: cellHeight, alignment: .topLeading)
                .background(
                    Group {
                        if dateOpt != nil {
                            if Calendar.current.isDateInToday(dateOpt!) {
                                LinearGradient(colors: [Color.white.opacity(0.14), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            } else {
                                Color.white.opacity(0.02)
                            }
                        } else {
                            Color.clear
                        }
                    }
                )
                .cornerRadius(8)
                .overlay(
                    Group {
                        if let d = dateOpt {
                            if Calendar.current.isDate(selectedDate, inSameDayAs: d) {
                                RoundedRectangle(cornerRadius: 8).stroke(Color.blue.opacity(0.8), lineWidth: 2)
                            } else {
                                RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.04), lineWidth: 1)
                            }
                        }
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func calendarCell(for dateOpt: Date?, gridIndex: Int, cellWidth: CGFloat) -> some View {
        if let date = dateOpt {
            let dayNumber = Calendar.current.component(.day, from: date)
            let targetDateStart = Calendar.current.startOfDay(for: date)
            
            let hasHighlightColor = singleDateHighlights[targetDateStart]
            let starState = dateStarMarkers[targetDateStart] ?? .none
            
            // 计算该日期的所有事件及溢出情况
            let (visibleReminders, overflowCount) = getEventsAndOverflowCount(for: targetDateStart)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .center, spacing: 0) {
                    Text("\(dayNumber)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.leading, 6)
                    
                    Spacer()
                    
                    Button(action: { cycleStarMarker(for: targetDateStart) }) {
                        Group {
                            switch starState {
                            case .none:
                                Image(systemName: "star").font(.system(size: 10)).foregroundColor(.white.opacity(0.15))
                            case .yellow:
                                Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.yellow)
                            case .red:
                                Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.red)
                            case .black:
                                Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.gray)
                            case .white:
                                Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.white)
                            case .purple:
                                Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.purple)
                            case .green:
                                Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.green)
                            }
                        }
                        .padding(.trailing, 6)
                        .frame(width: 20, height: 20, alignment: .center)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 24)
                .background(
                    Group {
                        if let hColor = hasHighlightColor { Rectangle().fill(hColor.color) } else { Color.white.opacity(0.04) }
                    }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    handleSingleDateHighlight(targetDateStart)
                }
                
                // 圆圈提醒日程区 (支持点击调起属性编辑/删除面板)
                VStack(spacing: 2) {
                    ForEach(visibleReminders, id: \.id) { event in
                        HStack(spacing: 4) {
                            Circle().stroke(event.color, lineWidth: 1.5).frame(width: 8, height: 8)
                            Text(event.displayTitle)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                                .textSelection(.enabled)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 4).frame(height: 14)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let col = CGFloat(gridIndex % 7)
                            let row = CGFloat(gridIndex / 7)
                            let originX = col * (cellWidth + gridSpacing) + 10
                            let originY = row * (cellHeight + gridSpacing) + 60
                            
                            self.editingEventTitle = event.title
                            self.editingEventColor = event.color
                            self.editingEventFontName = event.fontName
                            self.editingEventHasTime = event.hasSpecificTime
                            self.editingEventStartTime = event.startTime
                            self.editingEventEndTime = event.endTime
                            self.editingEventIsStartUnknown = event.isStartTimeUnknown
                            self.editingEventIsEndUnknown = event.isEndTimeUnknown
                            self.popoverMenuLocation = CGPoint(x: originX, y: originY)
                            self.activeEditingEventId = event.id
                        }
                    }
                }
                .padding(.top, CGFloat(maxVisibleSlotsPerCell) * 20 + 6)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Spacer(minLength: 0)
                
                // ⭐ 方格超载提示：右下角显示 +N 按钮
                if overflowCount > 0 {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showMoreEventsDate = targetDateStart
                        }) {
                            Text("+\(overflowCount)")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(4)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 4)
                        .padding(.bottom, 4)
                        .popover(isPresented: Binding(
                            get: { showMoreEventsDate == targetDateStart },
                            set: { show in if !show { showMoreEventsDate = nil } }
                        ), arrowEdge: .bottom) {
                            allEventsDetailPopoverView(for: targetDateStart)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.black.opacity(0.0001))
            .onTapGesture(count: 2) {
                let newNote = CalendarNote(
                    text: "New Note", fontName: "System", fontSize: 12,
                    isBold: false, isItalic: false, isUnderline: false,
                    textColor: .white, xOffset: 10, yOffset: 30
                )
                if var notes = dateNotes[date] {
                    notes.append(newNote)
                    dateNotes[date] = notes
                } else {
                    dateNotes[date] = [newNote]
                }
                activeEditingNoteId = newNote.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isTextFieldFocused = true
                    NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                }
            }
            .popover(isPresented: Binding(
                get: { popoverTargetDate == targetDateStart },
                set: { show in if !show { popoverTargetDate = nil } }
            ), arrowEdge: .bottom) {
                quickEventCreationFormView(for: targetDateStart)
            }
        } else {
            Color.clear
        }
    }
    
    // 渲染 Apple 官方风格的划选交互条（一拖即有一长条）
    @ViewBuilder
    private func renderAppleStyleDragSelection(startIdx: Int, currentIdx: Int, cellWidth: CGFloat) -> some View {
        let minIdx = min(startIdx, currentIdx)
        let maxIdx = max(startIdx, currentIdx)
        
        let groupedByRow = Dictionary(grouping: Array(minIdx...maxIdx)) { $0 / 7 }
        
        ZStack(alignment: .topLeading) {
            ForEach(groupedByRow.keys.sorted(), id: \.self) { rowIndex in
                if let rowIndices = groupedByRow[rowIndex],
                   let firstIdx = rowIndices.min(),
                   let lastIdx = rowIndices.max() {
                    
                    let startCol = CGFloat(firstIdx % 7)
                    let endCol = CGFloat(lastIdx % 7)
                    let spanCols = endCol - startCol + 1
                    
                    let originX = startCol * (cellWidth + gridSpacing)
                    let barWidth = (spanCols * cellWidth) + ((spanCols - 1) * gridSpacing)
                    let originY = CGFloat(rowIndex) * (cellHeight + gridSpacing) + 28
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                        Text("New Event")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .frame(width: max(barWidth, 10), height: 20)
                    .background(Capsule().fill(Color(red: 0.22, green: 0.67, blue: 0.93)))
                    .offset(x: originX, y: originY)
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .allowsHitTesting(false)
                }
            }
        }
    }
    
    private func createAppleStyleEventFromDrag(startIndex: Int, endIndex: Int) {
        let minIdx = min(startIndex, endIndex)
        let maxIdx = max(startIndex, endIndex)
        
        guard minIdx < calendarGridDates.count, maxIdx < calendarGridDates.count,
              let startDate = calendarGridDates[minIdx],
              let endDate = calendarGridDates[maxIdx] else { return }
        
        let newEvent = CalendarEvent(
            title: "New Event",
            date: startDate,
            endDate: endDate,
            color: Color(red: 0.22, green: 0.67, blue: 0.93),
            isReminder: false,
            fontName: "System"
        )
        
        calendarEvents.append(newEvent)
    }
    
    // 计算方格内隐藏的日程条与提醒，返回 (+N) 数量
    private func getEventsAndOverflowCount(for targetDate: Date) -> (visibleReminders: [CalendarEvent], overflowCount: Int) {
        let validGridDates = calendarGridDates.compactMap { $0 }.map { Calendar.current.startOfDay(for: $0) }
        let normalEvents = calendarEvents.filter { !$0.isReminder }
        let filteredEvents = normalEvents.filter { ev in
            let start = Calendar.current.startOfDay(for: ev.date)
            let end = Calendar.current.startOfDay(for: ev.actualEndDate)
            return validGridDates.contains { $0 >= start && $0 <= end }
        }.sorted { (ev1, ev2) -> Bool in
            if ev1.date != ev2.date { return ev1.date < ev2.date }
            return ev1.actualEndDate.timeIntervalSince(ev1.date) > ev2.actualEndDate.timeIntervalSince(ev2.date)
        }
        
        let allocatedSlots = calculateAllocatedSlots(filteredEvents: filteredEvents, visibleDates: validGridDates)
        
        var overflowCount = 0
        for ev in filteredEvents {
            let start = Calendar.current.startOfDay(for: ev.date)
            let end = Calendar.current.startOfDay(for: ev.actualEndDate)
            if targetDate >= start && targetDate <= end {
                if let slot = allocatedSlots[ev.id], slot >= maxVisibleSlotsPerCell {
                    overflowCount += 1
                }
            }
        }
        
        // 提醒类型处理
        let rawReminders = calendarEvents.filter {
            $0.isReminder && Calendar.current.isDate($0.date, inSameDayAs: targetDate)
        }
        let mergedReminders = sutureCalendarEvents(rawReminders)
        
        let visibleRemindersCount = max(0, maxVisibleSlotsPerCell - 1)
        let visibleReminders = Array(mergedReminders.prefix(visibleRemindersCount))
        if mergedReminders.count > visibleRemindersCount {
            overflowCount += (mergedReminders.count - visibleRemindersCount)
        }
        
        return (visibleReminders, overflowCount)
    }
    
    // 弹窗：显示该日期超量隐藏的所有完整日程列表
    @ViewBuilder
    private func allEventsDetailPopoverView(for targetDate: Date) -> some View {
        let allDayEvents = calendarEvents.filter { ev in
            let start = Calendar.current.startOfDay(for: ev.date)
            let end = Calendar.current.startOfDay(for: ev.actualEndDate)
            return targetDate >= start && targetDate <= end
        }
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("📅 All Events (\(allDayEvents.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.yellow)
                Spacer()
            }
            
            Divider().background(Color.white.opacity(0.15))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(allDayEvents) { event in
                        HStack(spacing: 8) {
                            if event.isReminder {
                                Circle().stroke(event.color, lineWidth: 1.5).frame(width: 8, height: 8)
                            } else {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(event.color)
                                    .frame(width: 4, height: 16)
                            }
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(event.displayTitle)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                if event.date != event.actualEndDate {
                                    Text("\(formattedShortDate(event.date)) - \(formattedShortDate(event.actualEndDate))")
                                        .font(.system(size: 9))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                calendarEvents.removeAll(where: { $0.id == event.id })
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 10))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(4)
                    }
                }
            }
            .frame(maxHeight: 180)
        }
        .padding(10)
        .frame(width: 220)
    }
    
    private func formattedShortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"
        return f.string(from: date)
    }
    
    @ViewBuilder
    private func quickEventCreationFormView(for targetDate: Date) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("➕ Add Event").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
            
            TextField("Event Title", text: $quickEventTitle)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
            
            Toggle("Set Time Duration", isOn: $quickEventHasTime)
                .font(.system(size: 11))
                .foregroundColor(.white)
            
            if quickEventHasTime {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        DatePicker("Start:", selection: $quickEventStartTime, displayedComponents: .hourAndMinute)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .disabled(quickEventIsStartUnknown)
                        
                        Toggle("Unknown (-)", isOn: $quickEventIsStartUnknown)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.8))
                            .toggleStyle(.checkbox)
                    }
                    
                    HStack {
                        DatePicker("End:", selection: $quickEventEndTime, displayedComponents: .hourAndMinute)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .disabled(quickEventIsEndUnknown)
                        
                        Toggle("Unknown (-)", isOn: $quickEventIsEndUnknown)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.8))
                            .toggleStyle(.checkbox)
                    }
                }
            }
            
            Picker("", selection: $quickEventIsReminder) {
                Text("Bar").tag(false)
                Text("Circle").tag(true)
            }.pickerStyle(.segmented).scaleEffect(0.9)
            
            HStack {
                ColorPicker("Color:", selection: $quickEventColor).font(.system(size: 10))
                Spacer()
                Button(action: {
                    let trimmed = quickEventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        let newEv = CalendarEvent(
                            title: trimmed,
                            date: targetDate,
                            endDate: targetDate,
                            color: quickEventColor,
                            isReminder: quickEventIsReminder,
                            hasSpecificTime: quickEventHasTime,
                            startTime: quickEventStartTime,
                            endTime: quickEventEndTime,
                            isStartTimeUnknown: quickEventIsStartUnknown,
                            isEndTimeUnknown: quickEventIsEndUnknown
                        )
                        calendarEvents.append(newEv)
                        quickEventTitle = ""
                        popoverTargetDate = nil
                    }
                }) {
                    Text("Add").font(.system(size: 10, weight: .bold)).foregroundColor(.black)
                        .padding(.horizontal, 10).padding(.vertical, 3).background(Color.yellow).cornerRadius(4)
                }.buttonStyle(.plain)
            }
        }
        .padding(10).frame(width: 240)
    }
    
    private func calculateAllocatedSlots(filteredEvents: [CalendarEvent], visibleDates: [Date]) -> [UUID: Int] {
        var allocatedSlots: [UUID: Int] = [:]
        var dateSlotsOccupation: [Date: Set<Int>] = [:]
        
        for ev in filteredEvents {
            let start = Calendar.current.startOfDay(for: ev.date)
            let end = Calendar.current.startOfDay(for: ev.actualEndDate)
            let crossedDates = visibleDates.filter { $0 >= start && $0 <= end }
            
            var targetSlot = 0
            while true {
                var isSlotAvailable = true
                for d in crossedDates {
                    if let occupied = dateSlotsOccupation[d], occupied.contains(targetSlot) {
                        isSlotAvailable = false
                        break
                    }
                }
                if isSlotAvailable { break }
                targetSlot += 1
            }
            
            allocatedSlots[ev.id] = targetSlot
            for d in crossedDates {
                if dateSlotsOccupation[d] == nil { dateSlotsOccupation[d] = [] }
                dateSlotsOccupation[d]?.insert(targetSlot)
            }
        }
        return allocatedSlots
    }
    
    // 纯数学绝对几何坐标绘制跨天日程条（呈现 Apple 原生端角 Capsule 样式）
    @ViewBuilder
    private func renderMathematicalCrossDayEventBars(cellWidth: CGFloat) -> some View {
        let normalEvents = calendarEvents.filter { !$0.isReminder }
        let validGridDates = calendarGridDates.compactMap { $0 }.map { Calendar.current.startOfDay(for: $0) }
        
        if !validGridDates.isEmpty {
            let filteredEvents = normalEvents.filter { ev in
                let start = Calendar.current.startOfDay(for: ev.date)
                let end = Calendar.current.startOfDay(for: ev.actualEndDate)
                return validGridDates.contains { $0 >= start && $0 <= end }
            }.sorted { (ev1, ev2) -> Bool in
                if ev1.date != ev2.date { return ev1.date < ev2.date }
                return ev1.actualEndDate.timeIntervalSince(ev1.date) > ev2.actualEndDate.timeIntervalSince(ev2.date)
            }
            
            let allocatedSlots = calculateAllocatedSlots(filteredEvents: filteredEvents, visibleDates: validGridDates)
            
            ZStack(alignment: .topLeading) {
                ForEach(filteredEvents) { event in
                    if let assignedSlot = allocatedSlots[event.id], assignedSlot < maxVisibleSlotsPerCell {
                        let start = Calendar.current.startOfDay(for: event.date)
                        let end = Calendar.current.startOfDay(for: event.actualEndDate)
                        
                        let activeIndices = calendarGridDates.indices.filter { idx in
                            if let d = calendarGridDates[idx] {
                                let sd = Calendar.current.startOfDay(for: d)
                                return sd >= start && sd <= end
                            }
                            return false
                        }
                        
                        if !activeIndices.isEmpty {
                            let groupedByRow = Dictionary(grouping: activeIndices) { $0 / 7 }
                            
                            ForEach(groupedByRow.keys.sorted(), id: \.self) { rowIndex in
                                if let rowIndices = groupedByRow[rowIndex],
                                   let firstIdx = rowIndices.min(),
                                   let lastIdx = rowIndices.max() {
                                    
                                    let startCol = CGFloat(firstIdx % 7)
                                    let endCol = CGFloat(lastIdx % 7)
                                    let spanCols = endCol - startCol + 1
                                    
                                    let originX = startCol * (cellWidth + gridSpacing)
                                    let barWidth = (spanCols * cellWidth) + ((spanCols - 1) * gridSpacing)
                                    let originY = CGFloat(rowIndex) * (cellHeight + gridSpacing) + 28 + (CGFloat(assignedSlot) * 22)
                                    
                                    HStack(spacing: 5) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white)
                                        Text(event.displayTitle)
                                            .font(event.fontName == "System" ? .system(size: 10, weight: .bold) : .custom(event.fontName, size: 10).weight(.bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .frame(width: max(barWidth, 10), height: 19)
                                    .background(Capsule().fill(event.color))
                                    .offset(x: originX, y: originY)
                                    .onTapGesture {
                                        self.editingEventTitle = event.title
                                        self.editingEventColor = event.color
                                        self.editingEventFontName = event.fontName
                                        self.editingEventHasTime = event.hasSpecificTime
                                        self.editingEventStartTime = event.startTime
                                        self.editingEventEndTime = event.endTime
                                        self.editingEventIsStartUnknown = event.isStartTimeUnknown
                                        self.editingEventIsEndUnknown = event.isEndTimeUnknown
                                        self.popoverMenuLocation = CGPoint(x: originX + barWidth / 2, y: originY)
                                        self.activeEditingEventId = event.id
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func eventDetailConfigureSettingsPanel() -> some View {
        if let targetId = activeEditingEventId {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("🛠️ Configure Event Property").font(.system(size: 11, weight: .bold)).foregroundColor(.yellow)
                    Spacer()
                }
                
                TextField("Title", text: $editingEventTitle)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                    .frame(width: 220)
                    .onChange(of: editingEventTitle) { oldValue, newValue in
                        updateEventPropertyDirectly(id: targetId) { $0.title = newValue }
                    }
                
                Toggle("Enable Duration", isOn: $editingEventHasTime)
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .onChange(of: editingEventHasTime) { oldValue, newValue in
                        updateEventPropertyDirectly(id: targetId) { $0.hasSpecificTime = newValue }
                    }
                
                if editingEventHasTime {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            DatePicker("Start Time:", selection: $editingEventStartTime, displayedComponents: .hourAndMinute)
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                                .disabled(editingEventIsStartUnknown)
                                .onChange(of: editingEventStartTime) { oldValue, newValue in
                                    updateEventPropertyDirectly(id: targetId) { $0.startTime = newValue }
                                }
                            
                            Toggle("Unknown (-)", isOn: $editingEventIsStartUnknown)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.8))
                                .toggleStyle(.checkbox)
                                .onChange(of: editingEventIsStartUnknown) { oldValue, newValue in
                                    updateEventPropertyDirectly(id: targetId) { $0.isStartTimeUnknown = newValue }
                                }
                        }
                        
                        HStack {
                            DatePicker("End Time:", selection: $editingEventEndTime, displayedComponents: .hourAndMinute)
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                                .disabled(editingEventIsEndUnknown)
                                .onChange(of: editingEventEndTime) { oldValue, newValue in
                                    updateEventPropertyDirectly(id: targetId) { $0.endTime = newValue }
                                }
                            
                            Toggle("Unknown (-)", isOn: $editingEventIsEndUnknown)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.8))
                                .toggleStyle(.checkbox)
                                .onChange(of: editingEventIsEndUnknown) { oldValue, newValue in
                                    updateEventPropertyDirectly(id: targetId) { $0.isEndTimeUnknown = newValue }
                                }
                        }
                    }
                }
                
                Divider().background(Color.white.opacity(0.12))
                
                HStack {
                    Text("🎨 Color:").font(.system(size: 11, weight: .medium)).foregroundColor(.white.opacity(0.8))
                    Spacer()
                    ColorPicker("", selection: $editingEventColor)
                        .labelsHidden()
                        .onChange(of: editingEventColor) { oldValue, newColor in
                            updateEventPropertyDirectly(id: targetId) { ev in
                                let ns = NSColor(newColor)
                                if let rgb = ns.usingColorSpace(.deviceRGB) {
                                    ev.colorComponents = [rgb.redComponent, rgb.greenComponent, rgb.blueComponent, rgb.alphaComponent]
                                }
                            }
                        }
                }
                
                Divider().background(Color.white.opacity(0.12))
                
                Text("🔤 Font Family:").font(.system(size: 10, weight: .medium)).foregroundColor(.white.opacity(0.6))
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 3) {
                        ForEach(allSystemFonts, id: \.self) { fName in
                            Button(action: {
                                self.editingEventFontName = fName
                                updateEventPropertyDirectly(id: targetId) { $0.fontName = fName }
                            }) {
                                HStack {
                                    Text(fName)
                                        .font(fName == "System" ? .system(size: 10) : .custom(fName, size: 10))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Spacer()
                                    if editingEventFontName == fName {
                                        Image(systemName: "checkmark").foregroundColor(.yellow).font(.system(size: 9, weight: .bold))
                                    }
                                }
                                .padding(.horizontal, 6).padding(.vertical, 4)
                                .background(editingEventFontName == fName ? Color.white.opacity(0.12) : Color.clear)
                                .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 90)
                
                Divider().background(Color.white.opacity(0.12))
                
                Button(action: {
                    calendarEvents.removeAll(where: { $0.id == targetId })
                    activeEditingEventId = nil
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete Event")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .frame(width: 250)
        }
    }
    
    private func updateEventPropertyDirectly(id: UUID, block: (inout CalendarEvent) -> Void) {
        if let idx = calendarEvents.firstIndex(where: { $0.id == id }) {
            block(&calendarEvents[idx])
            saveCalendarStatesToDisk()
        }
    }
    
    private func sutureCalendarEvents(_ events: [CalendarEvent]) -> [CalendarEvent] {
        var merged: [CalendarEvent] = []
        for ev in events {
            let isDuplicate = merged.contains(where: {
                $0.title.trimmingCharacters(in: .whitespacesAndNewlines) == ev.title.trimmingCharacters(in: .whitespacesAndNewlines) &&
                $0.isReminder == ev.isReminder &&
                isColorEqual($0.color, ev.color) &&
                Calendar.current.isDate($0.date, inSameDayAs: ev.date) &&
                Calendar.current.isDate($0.actualEndDate, inSameDayAs: ev.actualEndDate)
            })
            if isDuplicate { continue } else { merged.append(ev) }
        }
        return merged
    }
    
    private func isColorEqual(_ c1: Color, _ c2: Color) -> Bool {
        let ns1 = NSColor(c1).usingColorSpace(.deviceRGB)
        let ns2 = NSColor(c2).usingColorSpace(.deviceRGB)
        guard let l = ns1, let r = ns2 else { return false }
        return abs(l.redComponent - r.redComponent) < 0.05 &&
               abs(l.greenComponent - r.greenComponent) < 0.05 &&
               abs(l.blueComponent - r.blueComponent) < 0.05
    }
    
    private func getSwiftUIFont(from note: CalendarNote) -> Font {
        var baseFont: Font = .system(size: note.fontSize)
        if note.fontName != "System" { baseFont = .custom(note.fontName, size: note.fontSize) }
        if note.isBold { baseFont = baseFont.bold() }
        return baseFont
    }
    
    @ViewBuilder
    private func renderFloatingNote(_ note: CalendarNote, originDate: Date) -> some View {
        ZStack {
            if activeEditingNoteId == note.id {
                TextField("", text: Binding(
                    get: { note.text },
                    set: { newValue in updateNoteText(for: originDate, id: note.id, text: newValue) }
                ), onCommit: {
                    if note.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        removeNote(for: originDate, id: note.id)
                    }
                    activeEditingNoteId = nil
                })
                .textFieldStyle(.plain)
                .font(getSwiftUIFont(from: note))
                .focused($isTextFieldFocused)
                .padding(.horizontal, 6).padding(.vertical, 3).background(Color.blue.opacity(0.5)).cornerRadius(4)
                .frame(minWidth: 100)
                .modifier(AdvancedTextStyleModifier(isItalic: note.isItalic, isUnderline: note.isUnderline, color: note.textColor, fontSize: note.fontSize))
                .popover(isPresented: Binding(
                    get: { activeEditingNoteId == note.id },
                    set: { show in if !show { activeEditingNoteId = nil } }
                ), arrowEdge: .bottom) {
                    annotationPropertyModifierPanel(for: originDate, noteId: note.id)
                }
            } else {
                Text(note.text.isEmpty ? " " : note.text)
                    .font(getSwiftUIFont(from: note))
                    .foregroundColor(note.textColor)
                    .lineLimit(1).padding(.horizontal, 6).padding(.vertical, 3).background(note.textColor.opacity(0.25)).cornerRadius(4)
                    .textSelection(.enabled)
                    .modifier(AdvancedTextStyleModifier(isItalic: note.isItalic, isUnderline: note.isUnderline, color: note.textColor, fontSize: note.fontSize))
                    .onTapGesture(count: 2) {
                        activeEditingNoteId = note.id
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.isTextFieldFocused = true
                            NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                        }
                    }
            }
        }
        .offset(
            x: note.xOffset + (currentDraggingId == note.id ? dragTranslation.width : 0),
            y: note.yOffset + (currentDraggingId == note.id ? dragTranslation.height : 0)
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentDraggingId = note.id
                    dragTranslation = value.translation
                }
                .onEnded { value in
                    updateNoteFinalPosition(for: originDate, id: note.id, finalTranslation: value.translation)
                    currentDraggingId = nil
                    dragTranslation = .zero
                }
        )
    }
    
    @ViewBuilder
    private func annotationPropertyModifierPanel(for targetDate: Date, noteId: UUID) -> some View {
        if let notes = dateNotes[targetDate], let note = notes.first(where: { $0.id == noteId }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🎨 Color:").font(.system(size: 11, weight: .bold)).foregroundColor(.white.opacity(0.9))
                    Spacer()
                    ColorPicker("", selection: Binding(
                        get: { note.textColor },
                        set: { newColor in
                            updateNoteProperty(for: targetDate, id: noteId) { targetNote in
                                let ns = NSColor(newColor)
                                if let rgb = ns.usingColorSpace(.deviceRGB) {
                                    targetNote.colorComponents = [rgb.redComponent, rgb.greenComponent, rgb.blueComponent, rgb.alphaComponent]
                                }
                            }
                        }
                    )).labelsHidden()
                }
                
                Divider().background(Color.white.opacity(0.12))
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("🔠 Font Size:").font(.system(size: 11, weight: .bold)).foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Text("\(Int(note.fontSize)) pt").font(.system(size: 10, design: .monospaced)).foregroundColor(.yellow)
                        Stepper("", value: Binding(
                            get: { note.fontSize },
                            set: { newSize in updateNoteProperty(for: targetDate, id: noteId) { $0.fontSize = min(max(newSize, 8), 48) } }
                        ), in: 8...48).labelsHidden()
                    }
                    Slider(value: Binding(
                        get: { note.fontSize },
                        set: { newSize in updateNoteProperty(for: targetDate, id: noteId) { $0.fontSize = CGFloat(newSize) } }
                    ), in: 8...48).accentColor(.yellow)
                }
                
                Divider().background(Color.white.opacity(0.12))
                
                HStack(spacing: 10) {
                    Toggle(isOn: Binding(get: { note.isBold }, set: { b in updateNoteProperty(for: targetDate, id: noteId) { $0.isBold = b } })) {
                        Text("B").font(.system(size: 12, weight: .bold))
                    }.toggleStyle(.button)
                    Toggle(isOn: Binding(get: { note.isItalic }, set: { i in updateNoteProperty(for: targetDate, id: noteId) { $0.isItalic = i } })) {
                        Text("I").font(.system(size: 12, weight: .medium).italic())
                    }.toggleStyle(.button)
                    Toggle(isOn: Binding(get: { note.isUnderline }, set: { u in updateNoteProperty(for: targetDate, id: noteId) { $0.isUnderline = u } })) {
                        Text("U").font(.system(size: 12)).underline()
                    }.toggleStyle(.button)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Divider().background(Color.white.opacity(0.12))
                
                Text("🔤 Font Family:").font(.system(size: 10, weight: .bold)).foregroundColor(.white.opacity(0.6))
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(allSystemFonts, id: \.self) { fName in
                            Button(action: { updateNoteProperty(for: targetDate, id: noteId) { $0.fontName = fName } }) {
                                NavyFontRowView(fName: fName, isSelected: note.fontName == fName)
                            }.buttonStyle(.plain)
                        }
                    }
                }.frame(height: 85)
                
                Divider().background(Color.white.opacity(0.12))
                
                Button(action: {
                    removeNote(for: targetDate, id: noteId)
                    activeEditingNoteId = nil
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Remove Note")
                    }
                    .font(.system(size: 11, weight: .medium)).foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)
                    .background(Color.red.opacity(0.1)).cornerRadius(4)
                }.buttonStyle(.plain)
            }
            .padding(12).frame(width: 235)
        }
    }
    
    private var bottomActionBar: some View {
        HStack {
            Button(action: { executeDirectCopyExportPDF() }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Monthly Calendar (PDF)")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white).padding(.vertical, 7).padding(.horizontal, 16)
                .background(Color.blue.opacity(0.8)).cornerRadius(6)
            }.buttonStyle(.plain)
            Spacer()
        }
    }
    
    // 🖨️ 纯英文矢量 PDF 导出
    @MainActor
    private func executeDirectCopyExportPDF() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let monthStr = formatter.string(from: selectedDate)
        let enFormatter = DateFormatter()
        enFormatter.dateFormat = "MMMM yyyy"
        enFormatter.locale = Locale(identifier: "en_US")
        let monthEnStr = enFormatter.string(from: selectedDate).uppercased()
        
        savePanel.nameFieldStringValue = "\(monthStr)_Calendar.pdf"
        
        savePanel.begin { response in
            guard response == .OK, let targetURL = savePanel.url else { return }
            
            let rowCount = CGFloat(ceil(Double(calendarGridDates.count) / 7.0))
            let dynamicCanvasHeight: CGFloat = 110 + (rowCount * (cellHeight + gridSpacing)) + 50
            
            let exportLandscapeSnapshotView = VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("EXECUTIVE MONTHLY SCHEDULE")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color.blue.opacity(0.85))
                            .tracking(2.5)
                        
                        Text(monthEnStr)
                            .font(.system(size: 26, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Exported: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.45))
                }
                .padding(.horizontal, 4)
                
                renderCompleteCalendarView(forExport: true)
                
                HStack {
                    Spacer()
                    Text("Created by Tequila")
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.55))
                        .italic()
                }
                .padding(.top, 2)
                .padding(.horizontal, 4)
            }
            .padding(24)
            .frame(width: 1120, height: dynamicCanvasHeight)
            .background(Color(red: 0.08, green: 0.09, blue: 0.12))
            
            let renderer = ImageRenderer(content: exportLandscapeSnapshotView)
            renderer.scale = 2.0
            
            renderer.render { size, context in
                var mediaBox = CGRect(origin: .zero, size: size)
                guard let consumer = CGDataConsumer(url: targetURL as CFURL),
                      let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
                    return
                }
                
                pdfContext.beginPDFPage(nil)
                context(pdfContext)
                pdfContext.endPDFPage()
                pdfContext.closePDF()
                
                self.onMonthlyExportRequested(selectedDate, [:], ["Status": "Success"])
            }
        }
    }
    
    private func cycleStarMarker(for targetDate: Date) {
        let current = dateStarMarkers[targetDate] ?? .none
        switch current {
        case .none: dateStarMarkers[targetDate] = .yellow
        case .yellow: dateStarMarkers[targetDate] = .red
        case .red: dateStarMarkers[targetDate] = .black
        case .black: dateStarMarkers[targetDate] = .white
        case .white: dateStarMarkers[targetDate] = .purple
        case .green: dateStarMarkers[targetDate] = .none
        case .purple: dateStarMarkers[targetDate] = .green
        }
    }
    
    private func handleSingleDateHighlight(_ targetDate: Date) {
        self.selectedDate = targetDate
        if let existing = singleDateHighlights[targetDate] {
            let nsEx = NSColor(existing.color).usingColorSpace(.deviceRGB)
            let nsAct = NSColor(activeLineColor).usingColorSpace(.deviceRGB)
            if let ne = nsEx, let na = nsAct,
               abs(ne.redComponent - na.redComponent) < 0.01 && abs(ne.greenComponent - na.greenComponent) < 0.01 && abs(ne.blueComponent - na.blueComponent) < 0.01 {
                singleDateHighlights.removeValue(forKey: targetDate)
            } else {
                let blended = blendColors(colorA: existing.color, colorB: activeLineColor)
                singleDateHighlights[targetDate] = DateHighlightColor(color: blended)
            }
        } else {
            singleDateHighlights[targetDate] = DateHighlightColor(color: activeLineColor)
        }
    }
    
    private func handleQuickPaletteTap(_ selectedPaletteColor: Color) {
        let targetDateStart = Calendar.current.startOfDay(for: selectedDate)
        if let existing = singleDateHighlights[targetDateStart] {
            let nsEx = NSColor(existing.color).usingColorSpace(.deviceRGB)
            let nsPal = NSColor(selectedPaletteColor).usingColorSpace(.deviceRGB)
            if let ne = nsEx, let np = nsPal,
               abs(ne.redComponent - np.redComponent) < 0.01 && abs(ne.greenComponent - np.greenComponent) < 0.01 && abs(ne.blueComponent - np.blueComponent) < 0.01 {
                singleDateHighlights.removeValue(forKey: targetDateStart)
            } else {
                singleDateHighlights[targetDateStart] = DateHighlightColor(color: selectedPaletteColor)
            }
        } else {
            singleDateHighlights[targetDateStart] = DateHighlightColor(color: selectedPaletteColor)
        }
    }
    
    private func purgeColorFromCurrentMonth(_ targetColor: Color) {
        let nsTarget = NSColor(targetColor).usingColorSpace(.deviceRGB)
        guard let target = nsTarget else { return }
        for case let date? in calendarGridDates {
            let targetDateStart = Calendar.current.startOfDay(for: date)
            if let currentHighlight = singleDateHighlights[targetDateStart] {
                if let nsCur = NSColor(currentHighlight.color).usingColorSpace(.deviceRGB) {
                    if abs(target.redComponent - nsCur.redComponent) < 0.01 &&
                       abs(target.greenComponent - nsCur.greenComponent) < 0.01 &&
                       abs(target.blueComponent - nsCur.blueComponent) < 0.01 {
                        singleDateHighlights.removeValue(forKey: targetDateStart)
                    }
                }
            }
        }
    }
    
    private func updateNoteFinalPosition(for date: Date, id: UUID, finalTranslation: CGSize) {
        guard var notes = dateNotes[date], let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[idx].xOffset += finalTranslation.width
        notes[idx].yOffset += finalTranslation.height
        dateNotes[date] = notes
    }
    
    private func updateNoteText(for date: Date, id: UUID, text: String) {
        guard var notes = dateNotes[date], let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[idx].text = text
        dateNotes[date] = notes
    }
    
    private func removeNote(for date: Date, id: UUID) {
        guard var notes = dateNotes[date] else { return }
        notes.removeAll(where: { $0.id == id })
        if notes.isEmpty { dateNotes.removeValue(forKey: date) } else { dateNotes[date] = notes }
    }
    
    private func updateNoteProperty(for date: Date, id: UUID, block: (inout CalendarNote) -> Void) {
        guard var notes = dateNotes[date], let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        block(&notes[idx])
        dateNotes[date] = notes
    }
    
    private func blendColors(colorA: Color, colorB: Color) -> Color {
        let nsColorA = NSColor(colorA).usingColorSpace(.deviceRGB) ?? NSColor(red: 1, green: 1, blue: 1, alpha: 1)
        let nsColorB = NSColor(colorB).usingColorSpace(.deviceRGB) ?? NSColor(red: 1, green: 1, blue: 1, alpha: 1)
        let r = (nsColorA.redComponent + nsColorB.redComponent) / 2.0
        let g = (nsColorA.greenComponent + nsColorB.greenComponent) / 2.0
        let b = (nsColorA.blueComponent + nsColorB.blueComponent) / 2.0
        let a = (nsColorA.alphaComponent + nsColorB.alphaComponent) / 2.0
        return Color(red: Double(r), green: Double(g), blue: Double(b)).opacity(Double(a))
    }
    
    private func moveMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            self.selectedDate = newMonth
        }
    }
    
    private func saveCalendarStatesToDisk() {
        guard !isInternalLoading else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let prefix = "CoreCalendar_M\(currentMonthKey)_"
        
        var stringKeyedNotes: [String: [CalendarNote]] = [:]
        for (date, notes) in dateNotes { stringKeyedNotes[formatter.string(from: date)] = notes }
        if let encodedNotes = try? JSONEncoder().encode(stringKeyedNotes) {
            UserDefaults.standard.set(encodedNotes, forKey: "\(prefix)NotesV45")
        }
        
        var stringKeyedHighlights: [String: DateHighlightColor] = [:]
        for (date, hl) in singleDateHighlights { stringKeyedHighlights[formatter.string(from: date)] = hl }
        if let encodedHl = try? JSONEncoder().encode(stringKeyedHighlights) {
            UserDefaults.standard.set(encodedHl, forKey: "\(prefix)HighlightsV45")
        }
        
        var stringKeyedStars: [String: String] = [:]
        for (date, starred) in dateStarMarkers { stringKeyedStars[formatter.string(from: date)] = starred.rawValue }
        if let encodedStars = try? JSONEncoder().encode(stringKeyedStars) {
            UserDefaults.standard.set(encodedStars, forKey: "\(prefix)StarsV45")
        }
        
        if let encodedEvents = try? JSONEncoder().encode(calendarEvents) {
            UserDefaults.standard.set(encodedEvents, forKey: "\(prefix)EventsEmbeddedV45")
        }
    }
    
    private func loadCalendarStatesFromDisk() {
        isInternalLoading = true
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let prefix = "CoreCalendar_M\(currentMonthKey)_"
        
        if let notesData = UserDefaults.standard.data(forKey: "\(prefix)NotesV45"),
           let decodedStringNotes = try? JSONDecoder().decode([String: [CalendarNote]].self, from: notesData) {
            var restoredNotes: [Date: [CalendarNote]] = [:]
            for (stringDate, notes) in decodedStringNotes {
                if let parsedDate = formatter.date(from: stringDate) { restoredNotes[parsedDate] = notes }
            }
            self.dateNotes = restoredNotes
        } else {
            self.dateNotes = [:]
        }
        
        if let hlData = UserDefaults.standard.data(forKey: "\(prefix)HighlightsV45"),
           let decodedHl = try? JSONDecoder().decode([String: DateHighlightColor].self, from: hlData) {
            var restoredHl: [Date: DateHighlightColor] = [:]
            for (stringDate, hl) in decodedHl {
                if let parsedDate = formatter.date(from: stringDate) { restoredHl[parsedDate] = hl }
            }
            self.singleDateHighlights = restoredHl
        } else {
            self.singleDateHighlights = [:]
        }
        
        if let starsData = UserDefaults.standard.data(forKey: "\(prefix)StarsV45"),
           let decodedStars = try? JSONDecoder().decode([String: String].self, from: starsData) {
            var restoredStars: [Date: CustomStarState] = [:]
            for (stringDate, rawStr) in decodedStars {
                if let parsedDate = formatter.date(from: stringDate), let enumState = CustomStarState(rawValue: rawStr) {
                    restoredStars[parsedDate] = enumState
                }
            }
            self.dateStarMarkers = restoredStars
        } else {
            self.dateStarMarkers = [:]
        }
        
        if let evData = UserDefaults.standard.data(forKey: "\(prefix)EventsEmbeddedV45"),
           let decodedEvs = try? JSONDecoder().decode([CalendarEvent].self, from: evData) {
            self.calendarEvents = decodedEvs
        } else {
            self.calendarEvents = []
        }
        isInternalLoading = false
    }
}

struct NavyFontRowView: View {
    let fName: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(fName)
                .font(fName == "System" ? .system(size: 10) : .custom(fName, size: 10))
                .lineLimit(1)
                .foregroundColor(.white)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark").foregroundColor(.yellow).font(.system(size: 9, weight: .bold))
            }
        }
        .padding(.horizontal, 6).padding(.vertical, 4).background(isSelected ? Color.white.opacity(0.12) : Color.clear).cornerRadius(4).contentShape(Rectangle())
    }
}

struct AdvancedTextStyleModifier: ViewModifier {
    var isItalic: Bool
    var isUnderline: Bool
    var color: Color
    var fontSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .transformEffect(isItalic ? CGAffineTransform(a: 1, b: 0, c: 0.22, d: 1, tx: 0, ty: 0) : .identity)
            .overlay(
                Group {
                    if isUnderline {
                        VStack {
                            Spacer()
                            Rectangle().fill(color).frame(height: max(1, fontSize * 0.07))
                        }
                        .padding(.bottom, -2)
                    }
                }
            )
    }
}

import SwiftUI
import WebKit
import AppKit

// =========================================================================
// 🌐 7. 全局沙盒化网络及本地设置中心视图桥接
// =========================================================================

struct GlobalMailSandboxContainerView: View {
    @ObservedObject var sandboxManager = MailSandboxManager.shared
    @ObservedObject var theme = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("MAIL CLIENTS")
                    .font(.UniversalFont(size: 11, weight: .bold, design: .monospaced))
                    .UniversalTextColorModifier()
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(0..<sandboxManager.availableClients.count, id: \.self) { idx in
                            let node = sandboxManager.availableClients[idx]
                            let isSelected = sandboxManager.selectedClientIndex == idx
                            
                            Button(action: { sandboxManager.selectedClientIndex = idx }) {
                                HStack(spacing: 10) {
                                    Text(node.iconText)
                                        .font(.UniversalFont(size: 10, weight: .bold, design: .monospaced))
                                        .frame(width: 32, height: 24)
                                        .background(isSelected ? (theme.textMode == 2 ? Color.white : theme.textColor) : Color.white.opacity(0.08))
                                        .foregroundColor(isSelected ? .black : .white)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(node.name)
                                            .font(.UniversalFont(size: 11, weight: .medium))
                                            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                                            .UniversalTextColorModifier(forceIgnoreIfImageMode: isSelected)
                                        Text(node.description)
                                            .font(.UniversalFont(size: 8))
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(isSelected ? Color.white.opacity(0.06) : Color.clear)
                                .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .frame(width: 180)
            .background(Color.black.opacity(0.1))
            
            Rectangle().frame(width: 1).foregroundColor(Color.white.opacity(0.06))
            
            ZStack {
                NSMailWebViewWrapper(
                    urlString: sandboxManager.currentActiveClient.webURL,
                    onUnreadCountChanged: { count in
                        let activeURL = sandboxManager.currentActiveClient.webURL
                        sandboxManager.mailUnreadCounts[activeURL] = count
                    }
                )
                .id(sandboxManager.currentActiveClient.webURL)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct GlobalThemeSettingView: View {
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject var langManager = LanguageManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SYSTEM PREFERENCES")
                    .font(.UniversalFont(size: 16, weight: .regular, design: .monospaced))
                    .UniversalTextColorModifier()
                Text("Customize Workspace Environment")
                    .font(.UniversalFont(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .UniversalTextColorModifier()
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("Language Settings")
                        .font(.UniversalFont(size: 12, weight: .medium))
                        .foregroundColor(.white)
                    Text("(Default Language)")
                        .font(.UniversalFont(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Picker("", selection: $langManager.currentLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 450)
                
                Spacer()
            }
            .padding(12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Background Settings")
                    .font(.UniversalFont(size: 12, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ThemeModeCardButton(title: "Pure Dark", isActive: theme.backgroundMode == 0) { theme.backgroundMode = 0 }
                    ThemeModeCardButton(title: "Solid Color (Picker)", isActive: theme.backgroundMode == 1) { theme.backgroundMode = 1 }
                    ThemeModeCardButton(title: "Local Image...", isActive: theme.backgroundMode == 2) { theme.triggerLocalFilePicker() }
                }
                
                if theme.backgroundMode == 1 {
                    HStack(spacing: 8) {
                        ColorPicker("Canvas Color", selection: $theme.solidColor)
                            .labelsHidden()
                        Text("Click color picker to change solid background")
                            .font(.UniversalFont(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 4)
                }
                
                if theme.backgroundMode == 2, let img = theme.backgroundImage {
                    HStack(spacing: 10) {
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .cornerRadius(4)
                            .clipped()
                        Text("Loaded Background Image")
                            .font(.UniversalFont(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 4)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.02))
            .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Typography")
                    .font(.UniversalFont(size: 12, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ThemeModeCardButton(title: "Default White", isActive: theme.textMode == 0) {
                        theme.textMode = 0
                        theme.textColor = .white
                    }
                    ThemeModeCardButton(title: "Custom Color (Picker)", isActive: theme.textMode == 1) { theme.textMode = 1 }
                    ThemeModeCardButton(title: "Local Texture...", isActive: theme.textMode == 2) { theme.triggerTextFilePicker() }
                }
                
                if theme.textMode == 1 {
                    HStack(spacing: 8) {
                        ColorPicker("Text Color", selection: $theme.textColor)
                            .labelsHidden()
                        Text("Click color picker to change text color")
                            .font(.UniversalFont(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 4)
                }
                
                if theme.textMode == 2, let img = theme.textImage {
                    HStack(spacing: 10) {
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .cornerRadius(4)
                            .clipped()
                        Text("Active Text Mask Image")
                            .font(.UniversalFont(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 4)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.02))
            .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Font Settings")
                    .font(.UniversalFont(size: 12, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    Menu {
                        Button(action: { theme.selectedFontName = "System" }) {
                            HStack {
                                Text("System Default Font")
                                if theme.selectedFontName == "System" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Divider()
                        
                        ForEach(theme.availableFonts, id: \.self) { fontName in
                            Button(action: { theme.selectedFontName = fontName }) {
                                HStack {
                                    Text(fontName)
                                    if theme.selectedFontName == fontName {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Custom Global Font:")
                                .font(.UniversalFont(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text(theme.selectedFontName == "System" ? "Standard System Font" : theme.selectedFontName)
                                .font(.UniversalFont(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 320)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.02))
            .cornerRadius(6)
        }
    }
}

import SwiftUI
import WebKit
import AppKit
import UniformTypeIdentifiers

// =========================================================================
// 📝 工作日志排版中心（支持图片缩放与表格编辑）
// =========================================================================

struct GlobalWorkLogSandboxView: View {
    @ObservedObject var logManager = LogSystemManager.shared
    @ObservedObject var theme = ThemeManager.shared
    
    @State private var selectedNode: LogNode? = nil
    @State private var editingNodeID: UUID? = nil
    @State private var renameText: String = ""
    
    // 📁 新建控制流
    @State private var showRootCreatePopover = false
    @State private var showChildCreatePopover = false
    @State private var newNodeName = ""
    @State private var selectedParentFolderID: UUID? = nil
    
    // 🔤 核心字体弹窗控制状态
    @State private var showFontPopover = false
    
    // 🔒 内存安全桥梁：持有当前激活状态下的 WebView 指针
    @State private var currentWebViewStorage: WKWebView? = nil
    
    private static let cachedSystemFonts: [String] = [
        "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei",
        "SimSun", "Helvetica Neue", "Arial", "Times New Roman", "Courier New"
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧：文件树形目录控制架
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: LS("log_title"))
                        .font(.UniversalFont(size: 14, weight: .bold))
                        .UniversalTextColorModifier()
                    Text(verbatim: LS("log_subtitle"))
                        .font(.UniversalFont(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.bottom, 16)
                
                HStack {
                    Button(action: {
                        selectedParentFolderID = nil
                        newNodeName = ""
                        showRootCreatePopover = true
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Add Root Item")
                                .font(.UniversalFont(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color(nsColor: .controlAccentColor))
                        .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showRootCreatePopover, arrowEdge: .bottom) {
                        creationPopoverContent()
                    }
                    Spacer()
                }
                .padding(.bottom, 12)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        LogTreeRenderRecursiveView(
                            nodes: logManager.rootNodes,
                            selectedNode: $selectedNode,
                            editingNodeID: $editingNodeID,
                            renameText: $renameText,
                            showChildCreatePopover: $showChildCreatePopover,
                            selectedParentFolderID: $selectedParentFolderID,
                            newNodeName: $newNodeName
                        )
                    }
                }
                .onDeleteCommand {
                    if let activeSelected = selectedNode {
                        LogSystemManager.shared.deleteNode(id: activeSelected.id)
                        selectedNode = nil
                    }
                }
            }
            .frame(width: 260)
            .padding(.trailing, 20)
            
            Rectangle().frame(width: 0.5).foregroundColor(Color.white.opacity(0.1))
                .padding(.vertical, -10)
            
            // 右侧：文档排版中心
            VStack(spacing: 0) {
                if let activeNode = selectedNode, activeNode.type == .document {
                    HStack(spacing: 16) {
                        Text(activeNode.name)
                            .font(.UniversalFont(size: 14, weight: .semibold))
                            .UniversalTextColorModifier()
                        
                        Spacer()

                        Group {
                            // 🔤 字体选择器
                            Button(action: { showFontPopover = true }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "f.cursive")
                                        .font(.system(size: 14, weight: .bold))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8, weight: .bold))
                                }
                                .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                            .popover(isPresented: $showFontPopover, arrowEdge: .bottom) {
                                VStack(spacing: 0) {
                                    Text("Select Popular Font")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(.vertical, 6)
                                    
                                    Divider().background(Color.white.opacity(0.2))
                                    
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 0) {
                                            ForEach(Self.cachedSystemFonts, id: \.self) { fontName in
                                                Button(action: {
                                                    fireEditorAction("font_\(fontName)")
                                                    showFontPopover = false
                                                }) {
                                                    HStack {
                                                        Text(fontName)
                                                            .font(.custom(fontName, size: 12))
                                                            .foregroundColor(.white)
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .contentShape(Rectangle())
                                                }
                                                .buttonStyle(.plain)
                                                .background(Color.white.opacity(0.01))
                                            }
                                        }
                                    }
                                }
                                .frame(width: 220, height: 260)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            }
                            
                            // 🎨 色彩球
                            Button(action: { invokeMacNativeColorWheel() }) {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(.white)
                            }
                            
                            Rectangle().frame(width: 1, height: 14).foregroundColor(.white.opacity(0.2))
                            
                            // 基础排版三件套
                            Button(action: { fireEditorAction("bold") }) {
                                Image(systemName: "bold").foregroundColor(.white)
                            }
                            Button(action: { fireEditorAction("italic") }) {
                                Image(systemName: "italic").foregroundColor(.white)
                            }
                            Button(action: { fireEditorAction("underline") }) {
                                Image(systemName: "underline").foregroundColor(.white)
                            }
                            
                            Rectangle().frame(width: 1, height: 14).foregroundColor(.white.opacity(0.2))
                            
                            // 🖼️ 插入图片按钮（严格限制仅允许选择图片格式）
                            Button(action: { selectAndInsertImage() }) {
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.white)
                            }

                            // 📊 插入表格按钮（添加到工具栏最右侧）
                            Button(action: { fireEditorAction("insertCustomTable_3_3") }) {
                                Image(systemName: "tablecells")
                                    .foregroundColor(.white)
                            }
                        }
                        .font(.system(size: 13))
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.04))
                    
                    LogModuleStandaloneHtmlWrapper(initialHTML: activeNode.contentHTML, linkWebView: $currentWebViewStorage) { newHTML in
                        logManager.updateContent(id: activeNode.id, html: newHTML)
                    }
                    .id(activeNode.id)
                    .cornerRadius(6)
                    .padding(.top, 10)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.15))
                        Text("Select or create a .doc journal file from the sidebar to start editing")
                            .font(.UniversalFont(size: 11))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, 20)
        }
    }
    
    @ViewBuilder
    private func creationPopoverContent() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Enter folder name...", text: $newNodeName)
                .textFieldStyle(.plain)
                .padding(6)
                .background(Color.white.opacity(0.08))
                .cornerRadius(4)
            
            HStack {
                Button("Cancel") {
                    showRootCreatePopover = false
                    newNodeName = ""
                }
                .buttonStyle(.borderless)
                Spacer()
                Button("Confirm") {
                    let finalName = newNodeName.isEmpty ? "Untitled Folder" : newNodeName
                    logManager.createNode(name: finalName, type: .folder, parentID: nil)
                    newNodeName = ""
                    showRootCreatePopover = false
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(14)
        .frame(width: 220)
    }
    
    private func fireEditorAction(_ command: String, payload: String? = nil) {
        guard let webView = currentWebViewStorage else { return }
        
        let safeCmd = command.replacingOccurrences(of: "'", with: "\\'")
        let safePayload = (payload ?? "").replacingOccurrences(of: "'", with: "\\'").replacingOccurrences(of: "\n", with: "")
        
        let js = "executeWebEditorCommand('\(safeCmd)', '\(safePayload)');"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    private func selectAndInsertImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .png, .jpeg, .gif, .webP, .bmp]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            if let imageData = try? Data(contentsOf: url) {
                let ext = url.pathExtension.lowercased()
                let mimeType: String
                switch ext {
                case "png": mimeType = "image/png"
                case "jpg", "jpeg": mimeType = "image/jpeg"
                case "gif": mimeType = "image/gif"
                case "webp": mimeType = "image/webp"
                case "bmp": mimeType = "image/bmp"
                default: mimeType = "image/jpeg"
                }
                let base64 = imageData.base64EncodedString()
                let dataUri = "data:\(mimeType);base64,\(base64)"
                fireEditorAction("insertImage", payload: dataUri)
            }
        }
    }
    
    private func invokeMacNativeColorWheel() {
        NotificationCenter.default.removeObserver(self, name: NSColorPanel.colorDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(forName: NSColorPanel.colorDidChangeNotification, object: nil, queue: .main) { _ in
            let sysColor = NSColorPanel.shared.color
            if let rgb = sysColor.usingColorSpace(.deviceRGB) {
                let r = Int(rgb.redComponent * 255)
                let g = Int(rgb.greenComponent * 255)
                let b = Int(rgb.blueComponent * 255)
                let hex = String(format: "#%02X%02X%02X", r, g, b)
                self.fireEditorAction("textColor", payload: hex)
            }
        }
        NSColorPanel.shared.orderFrontRegardless()
    }
}

// =========================================================================
// 🚀 富文本引擎（支持全英文表格操控与图片缩放）
// =========================================================================

struct LogModuleStandaloneHtmlWrapper: NSViewRepresentable {
    var initialHTML: String
    @Binding var linkWebView: WKWebView?
    var onContentChange: (String) -> Void
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeNSView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "standaloneWrapperBridge")
        
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        
        var cleanHTML = initialHTML
        let targetText = "New Document – Start typing your entry here..."
        if cleanHTML.contains(targetText) {
            cleanHTML = cleanHTML.replacingOccurrences(of: targetText, with: "")
        }
        
        let trimmed = cleanHTML.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed == "<p></p>" || trimmed == "<p><br></p>" {
            cleanHTML = "<p>&nbsp;</p>"
        }
        
        let htmlEngineTemplate = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <style>
            body {
                background-color: #ffffff;
                color: #000000;
                font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                font-size: 15px;
                margin: 20px;
                outline: none;
            }
            [contenteditable="true"] {
                min-height: 500px;
                outline: none;
            }
            
            /* 表格渲染样式 */
            table.word-render-table {
                width: 100%;
                border-collapse: collapse;
                margin: 12px 0;
                font-size: 14px;
                position: relative;
            }
            table.word-render-table th, table.word-render-table td {
                border: 1px solid #cccccc;
                padding: 8px 12px;
                min-width: 50px;
                text-align: left;
                position: relative;
            }
            table.word-render-table th {
                background-color: #f5f5f7;
                font-weight: 600;
            }

            /* 表格浮动快捷控制面板（全英文） */
            .table-action-panel {
                position: absolute;
                display: none;
                background: #1e1e1e;
                border: 1px solid #444;
                border-radius: 6px;
                padding: 4px;
                z-index: 9999;
                box-shadow: 0 4px 12px rgba(0,0,0,0.4);
            }
            .table-action-panel button {
                background: transparent;
                border: none;
                color: white;
                padding: 4px 8px;
                cursor: pointer;
                font-size: 12px;
                border-radius: 4px;
            }
            .table-action-panel button:hover {
                background: #007aff;
            }

            /* 可缩放图片样式容器 */
            .editor-resizable-img-wrapper {
                display: inline-block;
                position: relative;
                max-width: 100%;
                margin: 6px 0;
                vertical-align: middle;
            }
            .editor-resizable-img-wrapper img {
                display: block;
                width: 100%;
                height: auto;
                border-radius: 4px;
                user-select: none;
            }
            .editor-resizable-img-wrapper.active-focus {
                outline: 2px solid #007aff;
            }
            .editor-resizable-img-wrapper .resize-handle {
                display: none;
                position: absolute;
                width: 10px;
                height: 10px;
                background: #007aff;
                border: 1px solid #fff;
                border-radius: 2px;
                right: -5px;
                bottom: -5px;
                cursor: se-resize;
                z-index: 10;
            }
            .editor-resizable-img-wrapper.active-focus .resize-handle {
                display: block;
            }
            
            .img-action-panel {
                position: absolute;
                display: none;
                background: #1e1e1e;
                border: 1px solid #444;
                border-radius: 6px;
                padding: 4px;
                z-index: 9999;
                box-shadow: 0 4px 12px rgba(0,0,0,0.4);
            }
            .img-action-panel button {
                background: transparent;
                border: none;
                color: white;
                padding: 4px 8px;
                cursor: pointer;
                font-size: 13px;
                border-radius: 4px;
            }
            .img-action-panel button:hover {
                background: #007aff;
            }
        </style>
        </head>
        <body contenteditable="true">
            \(cleanHTML)

            <!-- 表格浮动面板（全英文） -->
            <div id="tableGlobalPanel" class="table-action-panel" contenteditable="false">
                <button onclick="doTableModify('add_row')">+ Row</button>
                <button onclick="doTableModify('add_col')">+ Column</button>
                <button onclick="doTableModify('del_row')">− Row</button>
                <button onclick="doTableModify('del_col')">− Column</button>
            </div>

            <!-- 图片浮动面板 -->
            <div id="imgGlobalPanel" class="img-action-panel" contenteditable="false">
                <button onclick="resizeActiveImage(0.75)">Zoom Out</button>
                <button onclick="resizeActiveImage(1.25)">Zoom In</button>
                <button onclick="resizeActiveImage('100%')">Full Width</button>
                <button onclick="deleteActiveImage()">Delete</button>
            </div>

            <script>
                var currentTargetCell = null;
                var currentTargetImgWrapper = null;
                var isResizingImg = false;
                var resizeStartX, resizeStartWidth;

                function cleanResidualText() {
                    var badString = "New Document – Start typing your entry here...";
                    if (document.body.innerHTML.indexOf(badString) !== -1) {
                        document.body.innerHTML = document.body.innerHTML.replace(badString, "");
                        pushChangeToSwift();
                    }
                }
                setTimeout(cleanResidualText, 30);

                document.addEventListener('click', function(e) {
                    var cell = e.target.closest('td, th');
                    var tablePanel = document.getElementById('tableGlobalPanel');
                    var imgWrapper = e.target.closest('.editor-resizable-img-wrapper');
                    var imgPanel = document.getElementById('imgGlobalPanel');

                    // 表格选中与控制面板处理
                    if (cell) {
                        currentTargetCell = cell;
                        var rect = cell.getBoundingClientRect();
                        tablePanel.style.top = (window.scrollY + rect.top - 38) + 'px';
                        tablePanel.style.left = (window.scrollX + rect.left) + 'px';
                        tablePanel.style.display = 'block';
                    } else {
                        if (!e.target.closest('#tableGlobalPanel')) {
                            tablePanel.style.display = 'none';
                        }
                    }

                    // 图片控制
                    if (imgWrapper) {
                        document.querySelectorAll('.editor-resizable-img-wrapper').forEach(w => w.classList.remove('active-focus'));
                        currentTargetImgWrapper = imgWrapper;
                        imgWrapper.classList.add('active-focus');

                        var rect = imgWrapper.getBoundingClientRect();
                        imgPanel.style.top = (window.scrollY + rect.top - 38) + 'px';
                        imgPanel.style.left = (window.scrollX + rect.left) + 'px';
                        imgPanel.style.display = 'block';
                    } else {
                        if (!e.target.closest('#imgGlobalPanel')) {
                            imgPanel.style.display = 'none';
                            document.querySelectorAll('.editor-resizable-img-wrapper').forEach(w => w.classList.remove('active-focus'));
                            currentTargetImgWrapper = null;
                        }
                    }
                });

                // 表格增删行列逻辑
                function doTableModify(action) {
                    if (!currentTargetCell) return;
                    var row = currentTargetCell.parentElement;
                    var table = row.closest('table');
                    var cellIndex = currentTargetCell.cellIndex;
                    var rowIndex = row.rowIndex;

                    if (action === 'add_row') {
                        var newRow = table.insertRow(rowIndex + 1);
                        for (var i = 0; i < row.cells.length; i++) { 
                            var newCell = newRow.insertCell(i);
                            newCell.innerHTML = "&nbsp;";
                        }
                    } else if (action === 'add_col') {
                        for (var i = 0; i < table.rows.length; i++) {
                            var r = table.rows[i];
                            var newCell = (i === 0) ? document.createElement('th') : r.insertCell(cellIndex + 1);
                            newCell.innerHTML = "&nbsp;";
                            if (i === 0) { r.insertBefore(newCell, r.cells[cellIndex + 1]); }
                        }
                    } else if (action === 'del_row') {
                        if (table.rows.length > 1) { table.deleteRow(rowIndex); } else { table.remove(); }
                        document.getElementById('tableGlobalPanel').style.display = 'none';
                    } else if (action === 'del_col') {
                        if (row.cells.length > 1) {
                            for (var i = 0; i < table.rows.length; i++) { table.rows[i].deleteCell(cellIndex); }
                        } else { table.remove(); }
                        document.getElementById('tableGlobalPanel').style.display = 'none';
                    }
                    pushChangeToSwift();
                }

                // 图片拖拽角调整大小逻辑
                document.addEventListener('mousedown', function(e) {
                    if (e.target.classList.contains('resize-handle')) {
                        isResizingImg = true;
                        currentTargetImgWrapper = e.target.closest('.editor-resizable-img-wrapper');
                        resizeStartX = e.clientX;
                        resizeStartWidth = currentTargetImgWrapper.offsetWidth;
                        e.preventDefault();
                    }
                });

                document.addEventListener('mousemove', function(e) {
                    if (isResizingImg && currentTargetImgWrapper) {
                        var newWidth = Math.max(50, resizeStartWidth + (e.clientX - resizeStartX));
                        currentTargetImgWrapper.style.width = newWidth + 'px';
                        
                        var imgPanel = document.getElementById('imgGlobalPanel');
                        var rect = currentTargetImgWrapper.getBoundingClientRect();
                        imgPanel.style.top = (window.scrollY + rect.top - 38) + 'px';
                        imgPanel.style.left = (window.scrollX + rect.left) + 'px';
                    }
                });

                document.addEventListener('mouseup', function(e) {
                    if (isResizingImg) {
                        isResizingImg = false;
                        pushChangeToSwift();
                    }
                });

                function resizeActiveImage(factor) {
                    if (!currentTargetImgWrapper) return;
                    if (factor === '100%') {
                        currentTargetImgWrapper.style.width = '100%';
                    } else {
                        var curW = currentTargetImgWrapper.offsetWidth || 300;
                        currentTargetImgWrapper.style.width = Math.max(50, curW * factor) + 'px';
                    }
                    var imgPanel = document.getElementById('imgGlobalPanel');
                    var rect = currentTargetImgWrapper.getBoundingClientRect();
                    imgPanel.style.top = (window.scrollY + rect.top - 38) + 'px';
                    imgPanel.style.left = (window.scrollX + rect.left) + 'px';
                    pushChangeToSwift();
                }

                function deleteActiveImage() {
                    if (!currentTargetImgWrapper) return;
                    currentTargetImgWrapper.remove();
                    document.getElementById('imgGlobalPanel').style.display = 'none';
                    currentTargetImgWrapper = null;
                    pushChangeToSwift();
                }

                function executeWebEditorCommand(command, payload) {
                    if (command === 'textColor') {
                        document.execCommand('textColor', false, payload);
                    } 
                    else if (command.startsWith('font_')) {
                        var fontName = command.substring(5);
                        document.execCommand('fontName', false, fontName);
                    }
                    else if (command.startsWith('insertCustomTable_')) {
                        var parts = command.split('_');
                        var rows = parseInt(parts[1]) || 3, cols = parseInt(parts[2]) || 3;
                        var tableHtml = '<table class="word-render-table"><tbody>';
                        for (var i = 0; i < rows; i++) {
                            tableHtml += '<tr>';
                            for (var j = 0; j < cols; j++) { tableHtml += (i === 0) ? '<th>&nbsp;</th>' : '<td>&nbsp;</td>'; }
                            tableHtml += '</tr>';
                        }
                        tableHtml += '</tbody></table><p>&nbsp;</p>';
                        document.execCommand('insertHTML', false, tableHtml);
                    }
                    else if (command === 'insertImage') {
                        var imgTag = '<span class="editor-resizable-img-wrapper" contenteditable="false" style="width: 320px;"><img src="' + payload + '" /><span class="resize-handle"></span></span><p>&nbsp;</p>';
                        document.execCommand('insertHTML', false, imgTag);
                    }
                    else {
                        document.execCommand(command, false, null);
                    }
                    pushChangeToSwift();
                }
                
                function pushChangeToSwift() {
                    window.webkit.messageHandlers.standaloneWrapperBridge.postMessage(document.body.innerHTML);
                }
                document.addEventListener('input', pushChangeToSwift);
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlEngineTemplate, baseURL: nil)
        DispatchQueue.main.async { self.linkWebView = webView }
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: LogModuleStandaloneHtmlWrapper
        init(_ parent: LogModuleStandaloneHtmlWrapper) { self.parent = parent }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "standaloneWrapperBridge", let htmlString = message.body as? String {
                parent.onContentChange(htmlString)
            }
        }
    }
}
// =========================================================================
// 🌳 带有【打开】按键的树形结构递归组件
// =========================================================================

struct LogTreeRenderRecursiveView: View {
    let nodes: [LogNode]
    @Binding var selectedNode: LogNode?
    @Binding var editingNodeID: UUID?
    @Binding var renameText: String
    
    @Binding var showChildCreatePopover: Bool
    @Binding var selectedParentFolderID: UUID?
    @Binding var newNodeName: String
    
    var body: some View {
        ForEach(nodes) { node in
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: node.type == .folder ? "folder.fill" : "doc.text.fill")
                        .font(.system(size: 11))
                        .foregroundColor(node.type == .folder ? .yellow.opacity(0.8) : .blue.opacity(0.8))
                    
                    if editingNodeID == node.id {
                        TextField("", text: $renameText, onCommit: {
                            LogSystemManager.shared.renameNode(id: node.id, newName: renameText)
                            editingNodeID = nil
                        })
                        .textFieldStyle(.plain)
                        .font(.UniversalFont(size: 12))
                        .foregroundColor(.white)
                    } else {
                        Text(node.name)
                            .font(.UniversalFont(size: 12, weight: selectedNode?.id == node.id ? .semibold : .regular))
                            .foregroundColor(selectedNode?.id == node.id ? .white : .white.opacity(0.7))
                            .onTapGesture {
                                if node.type == .document { self.selectedNode = node }
                            }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        if node.type == .folder {
                            Button(action: {
                                selectedParentFolderID = node.id
                                newNodeName = ""
                                showChildCreatePopover = true
                            }) {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.plain)
                            .popover(isPresented: Binding(
                                get: { showChildCreatePopover && selectedParentFolderID == node.id },
                                set: { if !$0 { showChildCreatePopover = false } }
                            ), arrowEdge: .trailing) {
                                VStack(alignment: .leading, spacing: 12) {
                                    TextField("Enter file name...", text: $newNodeName)
                                        .textFieldStyle(.plain)
                                        .padding(6)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(4)
                                    HStack {
                                        Button("Cancel") { showChildCreatePopover = false; newNodeName = "" }
                                            .buttonStyle(.borderless)
                                        Spacer()
                                        Button("Confirm") {
                                            let finalName = newNodeName.isEmpty ? "Untitled Journal.doc" : newNodeName
                                            LogSystemManager.shared.createNode(name: finalName, type: .document, parentID: node.id)
                                            newNodeName = ""
                                            showChildCreatePopover = false
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                                .padding(14)
                                .frame(width: 220)
                            }
                        } else {
                            // ⭐️ 核心增加：文档旁边的“打开”蓝色加框按钮
                            Button(action: {
                                self.selectedNode = node
                            }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "arrow.up.forward.app")
                                    Text("open")
                                }
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(selectedNode?.id == node.id ? .white : .blue)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(selectedNode?.id == node.id ? Color.blue : Color.blue.opacity(0.2))
                                .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // 重命名按钮
                        Button(action: {
                            if editingNodeID == node.id {
                                LogSystemManager.shared.renameNode(id: node.id, newName: renameText)
                                editingNodeID = nil
                            } else {
                                editingNodeID = node.id
                                renameText = node.name
                            }
                        }) { Image(systemName: editingNodeID == node.id ? "checkmark" : "pencil") }.buttonStyle(.plain)
                        
                        // 删除按钮
                        Button(action: {
                            LogSystemManager.shared.deleteNode(id: node.id)
                            if selectedNode?.id == node.id {
                                selectedNode = nil
                            }
                        }) { Image(systemName: "trash") }.buttonStyle(.plain)
                    }
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.3))
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .background(selectedNode?.id == node.id ? Color.white.opacity(0.08) : Color.clear)
                .cornerRadius(4)
                
                if let children = node.children, !children.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        LogTreeRenderRecursiveView(
                            nodes: children,
                            selectedNode: $selectedNode,
                            editingNodeID: $editingNodeID,
                            renameText: $renameText,
                            showChildCreatePopover: $showChildCreatePopover,
                            selectedParentFolderID: $selectedParentFolderID,
                            newNodeName: $newNodeName
                        )
                    }
                    .padding(.leading, 14)
                }
            }
        }
    }
}

struct UniversalTextColor: ViewModifier {
    @ObservedObject var theme = ThemeManager.shared
    var opacity: Double = 1.0
    var forceIgnoreIfImageMode: Bool = false
    func body(content: Content) -> some View {
        if theme.textMode == 2 && !forceIgnoreIfImageMode { content } else { content.foregroundColor(theme.textColor.opacity(opacity)) }
    }
}

extension View {
    func UniversalTextColorModifier(opacity: Double = 1.0, forceIgnoreIfImageMode: Bool = false) -> some View {
        self.modifier(UniversalTextColor(opacity: opacity, forceIgnoreIfImageMode: forceIgnoreIfImageMode))
    }
}

extension Font {
    static func UniversalFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        let saved = ThemeManager.shared.selectedFontName
        return saved == "System" ? Font.system(size: size, weight: weight, design: design) : Font.custom(saved, size: size)
    }
}

struct GlobalThemeWrapper<Content: View>: View {
    let currentTab: String
    let content: Content
    @ObservedObject var theme = ThemeManager.shared
    
    init(currentTab: String, @ViewBuilder content: () -> Content) {
        self.currentTab = currentTab
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if theme.backgroundMode == 0 {
                Color.black.edgesIgnoringSafeArea(.all)
            } else if theme.backgroundMode == 1 {
                theme.solidColor.edgesIgnoringSafeArea(.all)
            } else if theme.backgroundMode == 2, let img = theme.backgroundImage {
                Image(nsImage: img).resizable().aspectRatio(contentMode: .fill).edgesIgnoringSafeArea(.all)
                Color.black.opacity(0.5)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            if theme.textMode == 2, let textImg = theme.textImage {
                content.overlay(Image(nsImage: textImg).resizable().aspectRatio(contentMode: .fill).mask(content).allowsHitTesting(false))
            } else {
                content
            }
        }
    }
}

struct SidebarLinkButton: View {
    let tab: String
    let code: String
    let title: String
    @Binding var currentNavTab: String
    @ObservedObject var theme: ThemeManager
    var badgeCount: Int = 0
    var isSelected: Bool { currentNavTab == tab }
    
    var body: some View {
        Button(action: { DispatchQueue.main.async { self.currentNavTab = self.tab } }) {
            VStack(spacing: 5) {
                ZStack {
                    Text(code).font(.UniversalFont(size: 14, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(isSelected ? theme.textColor : .white.opacity(0.2))
                    if badgeCount > 0 {
                        Text("\(badgeCount)").font(.system(size: 9, weight: .bold)).padding(.horizontal, 4).padding(.vertical, 1)
                            .background(Color.red).foregroundColor(.white).clipShape(Capsule()).offset(x: 10, y: -6)
                    }
                }
                Text(title).font(.UniversalFont(size: 10, weight: .light)).foregroundColor(isSelected ? .white : .white.opacity(0.4))
                    .UniversalTextColorModifier(forceIgnoreIfImageMode: !isSelected)
            }
            .frame(width: 72).contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}

struct ThemeModeCardButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title).font(.UniversalFont(size: 11, weight: .medium))
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isActive ? Color.white.opacity(0.15) : Color.white.opacity(0.04))
                .foregroundColor(isActive ? .white : .white.opacity(0.5)).cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(isActive ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1))
        }.buttonStyle(.plain)
    }
}
