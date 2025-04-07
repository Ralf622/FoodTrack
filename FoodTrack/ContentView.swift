import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            FoodEntryView()
                .tabItem {
                    Label("Saisie", systemImage: "square.and.pencil")
                }

            // Page "Daily"
            DailyView()
                .tabItem {
                    Label("Récap Journalier", systemImage: "star")
                }
        }
    }
}

struct FoodEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)],
        animation: .default)
    private var foodEntries: FetchedResults<FoodEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)],
        animation: .default)
    private var foodItems: FetchedResults<FoodItem>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyTotal.date, ascending: true)],
        animation: .default)
    private var dailyTotals: FetchedResults<DailyTotal>
    
    @State private var amount: Double? = nil
    @State private var selectedFood = "Pâtes"
    
    @State private var addFoodName: String = ""
    @State private var addFoodWeight: Double? = nil
    @State private var addFoodCalories: Double? = nil
    @State private var addFoodCarbohydrates: Double? = nil
    @State private var addFoodLipids: Double? = nil
    @State private var addFoodProteins: Double? = nil
    
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("Amount", value: $amount, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .focused($isFocused)

                        Text("g")
                    }
                    Picker("Food", selection: $selectedFood) {
                        ForEach(foodItems.map(\.name!), id: \.self) { food in
                            Text(food)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Button("Add") {
                        addFoodEntry()
                        isFocused = false
                    }
                }

                Section("Ajouter un aliment à la liste") {
                    TextField("Name", text :$addFoodName)
                        .focused($isFocused)
                    HStack{
                        TextField("Weight", value :$addFoodWeight, format : .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                        Text("g")
                    }
                    HStack{
                        TextField("calories", value :$addFoodCalories, format : .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                        Text("kcals")
                    }
                    HStack{
                        TextField("carbohydrates", value :$addFoodCarbohydrates, format : .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                        Text("g")
                    }
                    HStack{
                        TextField("lipids", value :$addFoodLipids, format : .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                        Text("g")
                    }
                    HStack{
                        TextField("proteins", value :$addFoodProteins, format : .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                        Text("g")
                    }
                    Button("Add") {
                        addFoodItem()
                    }
                }
                Section {
                    NavigationLink(destination: ManageFoodListView()){
                        Text("Appuyer ici pour gérer la liste des aliments")
                    }
                }
            }
            .navigationTitle("Saisie des aliments")
            .alert(isPresented: $showAlert) {
                            Alert(title: Text("Erreur"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isFocused = false
                        }
                    }
                }
            
        }
    }
    
    private func addFoodItem() {
        // Vérifie si tous les champs sont remplis
        guard !addFoodName.isEmpty,
              let weight = addFoodWeight,
              let calories = addFoodCalories,
              let carbohydrates = addFoodCarbohydrates,
              let lipids = addFoodLipids,
              let proteins = addFoodProteins else {
            alertMessage = "Tous les champs doivent être remplis."
                        showAlert = true
            return
        }

        // Normalisation des valeurs à 100g
        let weightFactor = 100.0 / weight

        let newItem = FoodItem(context: viewContext)
        newItem.name = addFoodName
        newItem.calories = calories * weightFactor
        newItem.carbohydrates = carbohydrates * weightFactor
        newItem.lipids = lipids * weightFactor
        newItem.proteins = proteins * weightFactor

        do {
            try viewContext.save()
            addFoodName = "" // Réinitialise le champ après l'ajout
            addFoodWeight = nil
            addFoodCalories = nil
            addFoodCarbohydrates = nil
            addFoodLipids = nil
            addFoodProteins = nil
        } catch {
            print("Erreur lors de la sauvegarde : \(error.localizedDescription)")
        }
    }


    
    /// Ajoute une nouvelle entrée alimentaire dans Core Data
    private func addFoodEntry() {
        guard let amount = amount, amount > 0 else {
            alertMessage = "Veuillez entrer une quantité valide"
            showAlert = true
            return
        }
        
        let newEntry = FoodEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.name = selectedFood
        newEntry.amount = amount
        newEntry.date = Date()
        
        
        

        var calories: Double = 0
        var proteins: Double = 0
        var carbohydrates: Double = 0
        var lipids: Double = 0
        
        // Récupérer les valeurs nutritionnelles de l'aliment sélectionné
        if let foodItem = foodItems.first(where: { $0.name == selectedFood }) {
            let factor = amount / 100.0
            calories = foodItem.calories * factor
            proteins = foodItem.proteins * factor
            carbohydrates = foodItem.carbohydrates * factor
            lipids = foodItem.lipids * factor
            print (foodItem)
            print (calories, proteins, carbohydrates, lipids)
        }

        
        let today = Calendar.current.startOfDay(for: Date()) // Normaliser la date à minuit

        // Rechercher s'il y a déjà un `DailyTotal` pour aujourd'hui
        let request: NSFetchRequest<DailyTotal> = DailyTotal.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)

        do {
            let results = try viewContext.fetch(request)
            let dailyTotal: DailyTotal

            if let existingTotal = results.first {
                // Mise à jour des valeurs existantes
                dailyTotal = existingTotal
            } else {
                // Création d'un nouveau total journalier
                dailyTotal = DailyTotal(context: viewContext)
                dailyTotal.date = today
                dailyTotal.calories = 0
                dailyTotal.proteins = 0
                dailyTotal.carbohydrates = 0
                dailyTotal.lipids = 0
            }

            // Ajouter les valeurs de la nouvelle entrée
            dailyTotal.calories += calories
            dailyTotal.proteins += proteins
            dailyTotal.carbohydrates += carbohydrates
            dailyTotal.lipids += lipids

            try viewContext.save()

        } catch {
            print("Erreur lors de la mise à jour du total journalier : \(error.localizedDescription)")
        }
        
        
        do {
            try viewContext.save()
        } catch {
            print("Erreur lors de la sauvegarde : \(error.localizedDescription)")
        }
    }
}

struct ManageFoodListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)],
        animation: .default
    )
    private var foodItems: FetchedResults<FoodItem>

    @State private var selectedFoodItem: FoodItem?

    var body: some View {
        NavigationStack {
            List {
                ForEach(foodItems, id: \.self) { foodItem in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(foodItem.name ?? "Sans nom")
                                .font(.headline)
                            Spacer()
                            Button("Modifier") {
                                selectedFoodItem = foodItem
                            }
                            .buttonStyle(.bordered)
                        }
                        Text("Calories: \(foodItem.calories, specifier: "%.0f") kcal")
                        Text("Protéines: \(foodItem.proteins, specifier: "%.1f") g")
                        Text("Glucides: \(foodItem.carbohydrates, specifier: "%.1f") g")
                        Text("Lipides: \(foodItem.lipids, specifier: "%.1f") g")
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Aliments")
            .toolbar {
                EditButton()
            }
            .sheet(item: $selectedFoodItem) { item in
                EditFoodItemView(foodItem: item)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = foodItems[index]
            viewContext.delete(item)
        }
        try? viewContext.save()
    }
}


struct EditFoodItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var foodItem: FoodItem

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nom")) {
                    TextField("Nom", text: Binding(
                        get: { foodItem.name ?? "" },
                        set: { foodItem.name = $0 }
                    ))
                }

                Section(header: Text("Valeurs nutritionnelles (pour 100g)")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("kcal", value: $foodItem.calories, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Protéines")
                        Spacer()
                        TextField("g", value: $foodItem.proteins, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Glucides")
                        Spacer()
                        TextField("g", value: $foodItem.carbohydrates, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Lipides")
                        Spacer()
                        TextField("g", value: $foodItem.lipids, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Modifier l’aliment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            print("Erreur de sauvegarde : \(error.localizedDescription)")
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}



struct DailyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: DailyTotal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyTotal.date, ascending: true)]
    ) private var dailyTotals: FetchedResults<DailyTotal>
    
    @State private var selectedDate: Date = Date() // Ajout de l'état pour la date sélectionnée
    
    var filteredDailyTotal: DailyTotal? {
        let targetDate = Calendar.current.startOfDay(for: selectedDate)
        return dailyTotals.first { Calendar.current.startOfDay(for: $0.date ?? Date()) == targetDate }
    }
    var body: some View {
        
        // Bandeau de date en haut
        NavigationStack{
            Form{
                HStack {
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    Spacer()
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.bordered)
                
                // Affichage des valeurs du jour sélectionné
                if let dailyTotal = filteredDailyTotal {
                    Section {
                        Text("Calories: \(dailyTotal.calories, specifier: "%.0f") kcal")
                        Text("Protéines: \(dailyTotal.proteins, specifier: "%.1f") g")
                        Text("Glucides: \(dailyTotal.carbohydrates, specifier: "%.1f") g")
                        Text("Lipides: \(dailyTotal.lipids, specifier: "%.1f") g")
                    }
                } else {
                    Text("Aucune donnée disponible pour cette date")
                        .foregroundColor(.gray)
                        .padding()
                }
                Section {
                    NavigationLink(destination: DailyFoodListView(selectedDate: selectedDate)) {
                        HStack {
                            Text("Voir les aliments consommés")
                        }
                    }
                }
            }
            .navigationTitle("Récap journalier")
        }
        
    }
}

struct DailyFoodListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var selectedDate: Date
    
    @FetchRequest(
        entity: FoodEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: true)]
    ) private var foodEntries: FetchedResults<FoodEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)],
        animation: .default)
    private var foodItems: FetchedResults<FoodItem>
    
    var filteredFoodEntries: [FoodEntry] {
        let targetDate = Calendar.current.startOfDay(for: selectedDate)
        return foodEntries
            .filter { Calendar.current.startOfDay(for: $0.date ?? Date()) == targetDate}
            .sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    @State private var expandedEntryID: NSManagedObjectID? = nil
    
    var body: some View {
        List {
            ForEach(filteredFoodEntries) { foodEntry in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(foodEntry.name ?? "")
                        Text("\(foodEntry.amount, format: .number.precision(.fractionLength(0))) g")
                        Spacer()
                        Text(foodEntry.date!, format: .dateTime.hour().minute())
                    }
                    .padding(.vertical, 5)
                    .onTapGesture {
                        withAnimation {
                            if expandedEntryID == foodEntry.objectID {
                                expandedEntryID = nil
                            }
                            else {
                                expandedEntryID = foodEntry.objectID
                            }
                        }
                    }
                    
                    if expandedEntryID == foodEntry.objectID {
                        HStack {
                            Text("P: \(foodEntry.amount, specifier: "%.0f") g")
                            Spacer()
                            Text("G: 75 g")
                            Spacer()
                            Text("L: 90 g")
                        }
                    }
                }
            }
            .onDelete(perform: deleteFoodEntries)
        }
    }
    
    /// Supprime une entrée alimentaire
    private func deleteFoodEntries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let entry = foodEntries[index] // Entrée supprimée
                let entryDate = Calendar.current.startOfDay(for: entry.date ?? Date())

                // Rechercher le DailyTotal correspondant
                let request: NSFetchRequest<DailyTotal> = DailyTotal.fetchRequest()
                request.predicate = NSPredicate(format: "date == %@", entryDate as NSDate)

                do {
                    let results = try viewContext.fetch(request)
                    if let dailyTotal = results.first {
                        
                        var calories: Double = 0
                        var proteins: Double = 0
                        var carbohydrates: Double = 0
                        var lipids: Double = 0
                        
                        // Récupérer les valeurs nutritionnelles de l'aliment sélectionné
                        if let foodItem = foodItems.first(where: { $0.name == entry.name }) {
                            let factor = entry.amount / 100.0
                            calories = foodItem.calories * factor
                            proteins = foodItem.proteins * factor
                            carbohydrates = foodItem.carbohydrates * factor
                            lipids = foodItem.lipids * factor
                        }

                        // Soustraction des valeurs nutritionnelles
                        dailyTotal.calories -= calories
                        dailyTotal.proteins -= proteins
                        dailyTotal.carbohydrates -= carbohydrates
                        dailyTotal.lipids -= lipids

                        // S'assurer que les valeurs ne deviennent pas négatives
                        dailyTotal.calories = max(dailyTotal.calories, 0)
                        dailyTotal.proteins = max(dailyTotal.proteins, 0)
                        dailyTotal.carbohydrates = max(dailyTotal.carbohydrates, 0)
                        dailyTotal.lipids = max(dailyTotal.lipids, 0)
                    }

                    // Supprimer l'entrée
                    viewContext.delete(entry)
                } catch {
                    print("Erreur lors de la mise à jour du total journalier : \(error.localizedDescription)")
                }
            }

            // Sauvegarder les changements
            do {
                try viewContext.save()
            } catch {
                print("Erreur lors de la suppression : \(error.localizedDescription)")
            }
        }
    }
    
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
