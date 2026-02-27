//
//  AnimalEntity+CoreDataProperties.swift
//  Animality
//
//  Created by 김주희 on 2/27/26.
//
//

public import Foundation
public import CoreData


public typealias AnimalEntityCoreDataPropertiesSet = NSSet

extension AnimalEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnimalEntity> {
        return NSFetchRequest<AnimalEntity>(entityName: "AnimalEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var type: String?
    @NSManaged public var latitude: Double // 위도
    @NSManaged public var longitude: Double // 경도
    @NSManaged public var size: String?
    @NSManaged public var pricePerHour: Int32
    @NSManaged public var status: String
}

extension AnimalEntity : Identifiable {

}
