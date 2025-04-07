//
//  DailyTotal+CoreDataProperties.swift
//  FoodTrack
//
//  Created by Raphael Morel on 30/03/2025.
//
//

import Foundation
import CoreData


extension DailyTotal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyTotal> {
        return NSFetchRequest<DailyTotal>(entityName: "DailyTotal")
    }

    @NSManaged public var date: Date?
    @NSManaged public var calories: Double
    @NSManaged public var proteins: Double
    @NSManaged public var carbohydrates: Double
    @NSManaged public var lipids: Double

}

extension DailyTotal : Identifiable {

}
