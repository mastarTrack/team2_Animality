//
//  AnimalEntity+CoreDataClass.swift
//  Animality
//
//  Created by 김주희 on 2/27/26.
//
//

public import Foundation
public import CoreData

public typealias AnimalEntityCoreDataClassSet = NSSet

@objc(AnimalEntity)
public class AnimalEntity: NSManagedObject {
    public static let className = "AnimalEntity"
    public enum keys {
        static let id = "id"
        static let name = "name"
        static let category = "category"
        static let type = "type"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let size = "size"
        static let pricePerHour  = "pricePerHour"
        static let status = "status"
        static let flightCapability = "flightCapability"
        
        
        
    }
}
