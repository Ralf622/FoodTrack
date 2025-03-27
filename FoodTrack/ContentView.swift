//
//  ContentView.swift
//  FoodTrack
//
//  Created by Raphael Morel on 27/03/2025.
//

import SwiftUI

struct ContentView: View {
    @State var food = ["Pates", "Salade", "Poulet"]
    let caloriesPerGram: [String: Double] = [
        "Pates": 12.5,
        "Salade": 18.3,
        "Poulet": 12.99
    ]
    @State var amount = 0.0
    @State private var selectedFood = "Pâtes" // Valeur initiale
    @State var totalCaloriesOfDay: Double = 0.0
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    HStack{
                        TextField("Amount", value: $amount, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                        Text("g")
                    }
                    Picker("Food", selection: $selectedFood){
                        ForEach(food, id: \.self){
                            Text($0)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    Button("Add"){
                        totalCaloriesOfDay+=(caloriesPerGram[selectedFood] ?? 0) * amount

                    }

                }
                Section("Total Calories"){
                    Text(totalCaloriesOfDay,format: .number.precision(.fractionLength(0)))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
