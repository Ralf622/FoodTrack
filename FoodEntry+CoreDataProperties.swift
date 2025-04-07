//
//  FoodEntry+CoreDataProperties.swift
//  FoodTrack
//
//  Created by Raphael Morel on 28/03/2025.
//
//

import Foundation
import CoreData


extension FoodEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodEntry> {
        return NSFetchRequest<FoodEntry>(entityName: "FoodEntry")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?

}

extension FoodEntry : Identifiable {

}
