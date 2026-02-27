//
//  CoreDataManager.swift
//  Animality
//
//  Created by 김주희 on 2/27/26.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    
    // MARK: - Core Data stack
    // persistentContainer 설정
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // context로 데이터 추출
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    // MARK: - Core Data Saving support
    // 변경 사항이 있을 경우 데이터 저장
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
