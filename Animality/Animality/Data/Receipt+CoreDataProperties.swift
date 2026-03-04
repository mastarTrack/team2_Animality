//
//  Receipt+CoreDataProperties.swift
//  Animality
//
//  Created by Hanjuheon on 3/4/26.
//
//

import Foundation
import CoreData


public typealias ReceiptCoreDataPropertiesSet = NSSet

extension Receipt {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Receipt> {
        return NSFetchRequest<Receipt>(entityName: "Receipt")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var userId: UUID?
    @NSManaged public var animalId: UUID?
    @NSManaged public var amount: Int64
    @NSManaged public var location: String?
    @NSManaged public var rentPaymentTime: Date?
    @NSManaged public var rentStartTime: Date?
    @NSManaged public var rentEndTime: Date?
    @NSManaged public var rentState: String?
    @NSManaged public var payState: String?

}

extension Receipt : Identifiable {

}
