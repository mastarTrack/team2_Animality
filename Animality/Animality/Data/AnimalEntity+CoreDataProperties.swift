//
//  AnimalEntity+CoreDataProperties.swift
//  Animality
//
//  Created by Hanjuheon on 3/4/26.
//
//

public import Foundation
public import CoreData


public typealias AnimalEntityCoreDataPropertiesSet = NSSet

extension AnimalEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnimalEntity> {
        return NSFetchRequest<AnimalEntity>(entityName: "AnimalEntity")
    }

    @NSManaged public var category: String?
    @NSManaged public var flightCapability: String?
    @NSManaged public var id: UUID?
    @NSManaged public var userId: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var pricePerHour: Int32
    @NSManaged public var size: String?
    @NSManaged public var status: String?
    @NSManaged public var type: String?
    @NSManaged public var registDate: Date?

}

extension AnimalEntity : Identifiable {

}
