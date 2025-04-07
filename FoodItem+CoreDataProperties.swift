//
//  FoodItem+CoreDataProperties.swift
//  FoodTrack
//
//  Created by Raphael Morel on 28/03/2025.
//
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }

    @NSManaged public var calories: Double
    @NSManaged public var carbohydrates: Double
    @NSManaged public var lipids: Double
    @NSManaged public var name: String?
    @NSManaged public var proteins: Double

}

extension FoodItem : Identifiable {

}
