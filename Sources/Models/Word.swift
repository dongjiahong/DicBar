import Foundation
import GRDB

// MARK: - Word Model

struct Word: Codable, FetchableRecord, TableRecord {
    static let databaseTableName = "words"
    
    let id: Int64
    let word: String
    let pronunciation: String?
    let conciseDefinition: String?
    let formsJson: String?
    
    // 关联的释义和对比
    var definitions: [Definition] = []
    var comparisons: [Comparison] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case word
        case pronunciation
        case conciseDefinition = "concise_definition"
        case formsJson = "forms_json"
    }
    
    // 解析词形变化 JSON
    var forms: WordForms? {
        guard let json = formsJson, let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(WordForms.self, from: data)
    }
}

// MARK: - WordForms

struct WordForms: Codable {
    let plural: String?
    let thirdPersonSingular: String?
    let pastTense: String?
    let pastParticiple: String?
    let presentParticiple: String?
    let comparative: String?
    let superlative: String?
    
    enum CodingKeys: String, CodingKey {
        case plural
        case thirdPersonSingular = "third_person_singular"
        case pastTense = "past_tense"
        case pastParticiple = "past_participle"
        case presentParticiple = "present_participle"
        case comparative
        case superlative
    }
    
    var allForms: [String] {
        [plural, thirdPersonSingular, pastTense, pastParticiple, presentParticiple, comparative, superlative]
            .compactMap { $0 }
    }
}

// MARK: - Definition Model

struct Definition: Codable, FetchableRecord, TableRecord {
    static let databaseTableName = "definitions"
    
    let id: Int64
    let wordId: Int64
    let pos: String?
    let explanationEn: String?
    let explanationCn: String?
    let exampleEn: String?
    let exampleCn: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case wordId = "word_id"
        case pos
        case explanationEn = "explanation_en"
        case explanationCn = "explanation_cn"
        case exampleEn = "example_en"
        case exampleCn = "example_cn"
    }
}

// MARK: - Comparison Model

struct Comparison: Codable, FetchableRecord, TableRecord {
    static let databaseTableName = "comparisons"
    
    let id: Int64
    let wordId: Int64
    let wordToCompare: String?
    let analysis: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case wordId = "word_id"
        case wordToCompare = "word_to_compare"
        case analysis
    }
}
