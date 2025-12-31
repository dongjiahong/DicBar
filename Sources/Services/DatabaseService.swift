import Foundation
import GRDB

class DatabaseService: ObservableObject {
    private var dbQueue: DatabaseQueue?
    
    init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        // 从 Bundle 获取数据库路径
        guard let dbPath = Bundle.main.path(forResource: "dictionary", ofType: "db") else {
            print("Error: dictionary.db not found in bundle")
            return
        }
        
        do {
            // 以只读模式打开数据库
            var config = Configuration()
            config.readonly = true
            dbQueue = try DatabaseQueue(path: dbPath, configuration: config)
            print("Database loaded successfully: \(dbPath)")
        } catch {
            print("Database error: \(error)")
        }
    }
    
    // MARK: - 搜索功能
    
    /// 前缀搜索（用于实时输入）
    func searchByPrefix(_ prefix: String, limit: Int = 20) -> [Word] {
        guard let db = dbQueue, !prefix.isEmpty else { return [] }
        
        do {
            return try db.read { db in
                let pattern = "\(prefix.lowercased())%"
                let words = try Word
                    .filter(Column("word").like(pattern))
                    .order(Column("word"))
                    .limit(limit)
                    .fetchAll(db)
                return words
            }
        } catch {
            print("Search error: \(error)")
            return []
        }
    }
    
    /// 精确查找单词（获取完整信息）
    func findWord(_ word: String) -> Word? {
        guard let db = dbQueue else { return nil }
        
        do {
            return try db.read { db in
                guard var wordResult = try Word
                    .filter(Column("word") == word.lowercased())
                    .fetchOne(db) else { return nil }
                
                // 加载释义
                wordResult.definitions = try Definition
                    .filter(Column("word_id") == wordResult.id)
                    .fetchAll(db)
                
                // 加载对比
                wordResult.comparisons = try Comparison
                    .filter(Column("word_id") == wordResult.id)
                    .fetchAll(db)
                
                return wordResult
            }
        } catch {
            print("Find error: \(error)")
            return nil
        }
    }
    
    /// 全文搜索
    func fullTextSearch(_ query: String, limit: Int = 20) -> [Word] {
        guard let db = dbQueue, !query.isEmpty else { return [] }
        
        do {
            return try db.read { db in
                let ftsPattern = "\(query)*"
                let sql = """
                    SELECT words.* FROM words
                    JOIN words_fts ON words.id = words_fts.rowid
                    WHERE words_fts MATCH ?
                    LIMIT ?
                """
                return try Word.fetchAll(db, sql: sql, arguments: [ftsPattern, limit])
            }
        } catch {
            print("FTS error: \(error)")
            return []
        }
    }
    
    /// 获取单词总数
    func wordCount() -> Int {
        guard let db = dbQueue else { return 0 }
        
        do {
            return try db.read { db in
                try Word.fetchCount(db)
            }
        } catch {
            return 0
        }
    }
}
