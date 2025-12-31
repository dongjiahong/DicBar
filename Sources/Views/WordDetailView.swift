import SwiftUI

struct WordDetailView: View {
    let word: Word
    let onBack: () -> Void
    
    @State private var selectedTab = 0
    @StateObject private var audioService = AudioService()
    
    var body: some View {
        VStack(spacing: 0) {
            // 头部
            header
            
            Divider()
            
            // 标签栏
            tabBar
            
            Divider()
            
            // 内容
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedTab {
                    case 0:
                        definitionsSection
                    case 1:
                        comparisonsSection
                    default:
                        EmptyView()
                    }
                }
                .padding(16)
            }
            .background(Color.white)
        }
        .background(Color.white)
    }
    
    // MARK: - 头部（重新设计）
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 第一行：返回按钮 + 单词
            HStack(spacing: 10) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
                Text(word.word)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // 词形变化按钮
                if let forms = word.forms, !forms.allForms.isEmpty {
                    Menu {
                        ForEach(formsItems, id: \.0) { label, value in
                            Text("\(label): \(value)")
                        }
                    } label: {
                        Image(systemName: "textformat.abc")
                            .font(.system(size: 14))
                            .foregroundColor(.accentColor)
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            
            // 第二行：音标 + 发音按钮
            HStack(spacing: 12) {
                if let pronunciation = word.pronunciation {
                    Text("/\(pronunciation)/")
                        .font(.system(size: 15))
                        .foregroundColor(Color(white: 0.5))
                }
                
                // 发音按钮
                HStack(spacing: 8) {
                    Button(action: {
                        audioService.playPronunciation(word: word.word, accent: .american)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 12))
                            Text("美音")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        audioService.playPronunciation(word: word.word, accent: .british)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 12))
                            Text("英音")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            
            // 第三行：简明释义
            if let definition = word.conciseDefinition {
                Text(definition)
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.35))
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
    }
    
    private var formsItems: [(String, String)] {
        guard let forms = word.forms else { return [] }
        var items: [(String, String)] = []
        
        if let v = forms.plural { items.append(("复数", v)) }
        if let v = forms.thirdPersonSingular { items.append(("第三人称单数", v)) }
        if let v = forms.pastTense { items.append(("过去式", v)) }
        if let v = forms.pastParticiple { items.append(("过去分词", v)) }
        if let v = forms.presentParticiple { items.append(("现在分词", v)) }
        if let v = forms.comparative { items.append(("比较级", v)) }
        if let v = forms.superlative { items.append(("最高级", v)) }
        
        return items
    }
    
    // MARK: - 标签栏
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            TabButton(title: "释义", count: word.definitions.count, isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "辨析", count: word.comparisons.count, isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    // MARK: - 释义部分
    
    private var definitionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(word.definitions.enumerated()), id: \.element.id) { index, definition in
                DefinitionCard(definition: definition, index: index + 1)
            }
        }
    }
    
    // MARK: - 辨析部分
    
    private var comparisonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if word.comparisons.isEmpty {
                Text("暂无近义词辨析")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                ForEach(word.comparisons, id: \.id) { comparison in
                    ComparisonCard(comparison: comparison)
                }
            }
        }
    }
}

// MARK: - 标签按钮

struct TabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isSelected ? .white : Color(white: 0.5))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.accentColor : Color(white: 0.85))
                        )
                }
            }
            .foregroundColor(isSelected ? .accentColor : Color(white: 0.3))
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 释义卡片

struct DefinitionCard: View {
    let definition: Definition
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 词性标签
            HStack(spacing: 8) {
                Text("\(index)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.accentColor))
                
                if let pos = definition.pos, !pos.isEmpty {
                    Text(pos)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.1))
                        )
                }
            }
            
            // 英文释义
            if let en = definition.explanationEn, !en.isEmpty {
                Text(en)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineSpacing(4)
            }
            
            // 中文释义
            if let cn = definition.explanationCn, !cn.isEmpty {
                Text(cn)
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.4))
                    .lineSpacing(4)
            }
            
            // 例句
            if let exampleEn = definition.exampleEn, !exampleEn.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 10))
                            .foregroundColor(.accentColor)
                        
                        Text(exampleEn)
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.2))
                            .italic()
                    }
                    
                    if let exampleCn = definition.exampleCn, !exampleCn.isEmpty {
                        Text(exampleCn)
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.5))
                            .padding(.leading, 16)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(white: 0.97))
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.98))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - 辨析卡片

struct ComparisonCard: View {
    let comparison: Comparison
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                
                if let word = comparison.wordToCompare {
                    Text(word)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            if let analysis = comparison.analysis, !analysis.isEmpty {
                Text(analysis)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineSpacing(5)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.08))
        )
    }
}

// MARK: - 预览

#Preview {
    let mockWord = Word(
        id: 1,
        word: "internationally",
        pronunciation: "in·ter·na·shn·uh·lee",
        conciseDefinition: "adv. 国际地, 在国际间, 国际性地",
        formsJson: nil
    )
    
    WordDetailView(word: mockWord, onBack: {})
        .frame(width: 420, height: 520)
}
