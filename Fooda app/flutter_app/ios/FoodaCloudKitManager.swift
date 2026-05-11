import Foundation
import CloudKit

class FoodaCloudKitManager {
    
    // Singleton instance (optional, but good for management)
    static let shared = FoodaCloudKitManager()
    
    private let container: CKContainer
    private let database: CKDatabase
    private let recordType = "Backup"
    
    init() {
        // 使用指定的 Container ID
        self.container = CKContainer(identifier: "iCloud.com.gomiigo.FoodaApp")
        // 使用 Private Database (用戶私有數據)
        self.database = self.container.privateCloudDatabase
    }
    
    /// 上傳備份 (覆蓋舊的)
    /// - Parameters:
    ///   - json: 備份數據 JSON 字串
    ///   - userId: 用戶 ID (用於查詢)
    ///   - completion: 完成回調 (Result<Void, Error>)
    func uploadBackup(json: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // 1. 先查詢是否已存在該用戶的備份
        let predicate = NSPredicate(format: "userId == %@", userId)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { [weak self] (records, error) in
            guard let self = self else { return }
            
            if let error = error {
                // 查詢失敗
                completion(.failure(error))
                return
            }
            
            let recordToSave: CKRecord
            
            if let records = records, let firstRecord = records.first {
                // 2a. 若存在 -> 更新該筆
                recordToSave = firstRecord
            } else {
                // 2b. 若不存在 -> 新增一筆
                recordToSave = CKRecord(recordType: self.recordType)
                recordToSave["userId"] = userId as CKRecordValue
            }
            
            // 3. 設定數據
            recordToSave["json"] = json as CKRecordValue
            recordToSave["updatedAt"] = Date() as CKRecordValue
            
            // 4. 儲存
            let modifyOp = CKModifyRecordsOperation(recordsToSave: [recordToSave], recordIDsToDelete: nil)
            modifyOp.savePolicy = .changedKeys
            
            modifyOp.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
            
            self.database.add(modifyOp)
        }
    }
    
    /// 下載備份
    /// - Parameters:
    ///   - userId: 用戶 ID
    ///   - completion: 完成回調 (Result<String?, Error>) -> String? 為 JSON 字串，若無備份則為 nil
    func fetchBackup(userId: String, completion: @escaping (Result<String?, Error>) -> Void) {
        
        // 1. 查詢該用戶的備份
        let predicate = NSPredicate(format: "userId == %@", userId)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        // 按時間倒序 (雖然理論上只有一筆，但保險起見取最新的)
        query.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let records = records, let firstRecord = records.first else {
                // 找不到記錄 -> 回傳 nil
                completion(.success(nil))
                return
            }
            
            // 2. 取出 JSON
            if let jsonString = firstRecord["json"] as? String {
                completion(.success(jsonString))
            } else {
                // 欄位格式錯誤或為空
                completion(.success(nil))
            }
        }
    }
}
