//
//  Receipt+CoreDataClass.swift
//  Animality
//
//  Created by Hanjuheon on 3/4/26.
//
//

public import Foundation
public import CoreData

public typealias ReceiptCoreDataClassSet = NSSet

@objc(Receipt)
public class Receipt: NSManagedObject {
    public static let className = "Receipt"
    public enum keys {
        static let id = "id"
        static let userId = "userId"
        static let animalId = "animalId"
        static let amount = "amount"
        static let location = "location"
        static let rentPaymentTime = "rentPaymentTime"
        static let rentStartTime = "rentStartTime"
        static let rentEndTime = "rentEndTime"
        static let rentState = "rentState"
        static let payState = "payState"
    }
}
