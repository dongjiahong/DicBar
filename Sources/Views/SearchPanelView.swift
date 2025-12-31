import SwiftUI
import AppKit

// MARK: - 搜索面板

struct SearchPanelView: View {
    @EnvironmentObject var databaseService: DatabaseService
    
    @State private var searchText = ""
    @State private var searchResults: [Word] = []
    @State private var selectedWord: Word?
    @State private var isLoading = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            searchBar
            
            Divider()
            
            // 内容区域
            if let word = selectedWord {
                // 显示单词详情
                WordDetailView(word: word, onBack: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedWord = nil
                    }
                })
            } else {
                // 显示搜索结果
                searchResultsList
            }
        }
        .background(Color.white)
        .frame(width: 420, height: 520)
        .onReceive(NotificationCenter.default.publisher(for: .focusSearchField)) { _ in
            isSearchFocused = true
        }
    }
    
    // MARK: - 搜索栏
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.accentColor)
                .font(.system(size: 16, weight: .medium))
            
            TextField("输入单词...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.black)
                .focused($isSearchFocused)
                .onChange(of: searchText) { newValue in
                    performSearch(newValue)
                }
                .onSubmit {
                    if let first = searchResults.first {
                        selectWord(first)
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    searchResults = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.gray)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
    }
    
    // MARK: - 搜索结果列表
    
    private var searchResultsList: some View {
        Group {
            if searchText.isEmpty {
                // 空状态
                VStack(spacing: 16) {
                    Image(systemName: "character.book.closed")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor.opacity(0.6))
                    
                    Text("输入单词开始查询")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            } else if searchResults.isEmpty {
                // 无结果
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(Color.gray)
                    
                    Text("未找到 \"\(searchText)\"")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            } else {
                // 结果列表
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchResults, id: \.id) { word in
                            SearchResultRow(word: word)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectWord(word)
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .background(Color.white)
            }
        }
    }
    
    // MARK: - 操作
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        // 使用前缀搜索
        searchResults = databaseService.searchByPrefix(query, limit: 30)
    }
    
    private func selectWord(_ word: Word) {
        // 获取完整信息
        if let fullWord = databaseService.findWord(word.word) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedWord = fullWord
            }
        }
    }
}

// MARK: - 搜索结果行

struct SearchResultRow: View {
    let word: Word
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                if let definition = word.conciseDefinition {
                    Text(definition)
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.4))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let pronunciation = word.pronunciation {
                Text(pronunciation)
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.gray.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isHovered ? Color.accentColor.opacity(0.08) : Color.white)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - 预览

#Preview {
    SearchPanelView()
        .environmentObject(DatabaseService())
}
