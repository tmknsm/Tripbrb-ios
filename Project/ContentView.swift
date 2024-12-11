import SwiftUI

struct VacationPlan: Identifiable {
    let id = UUID()
    var destination: String
    var startTime: Date  // This will now store the full date
    var endTime: Date    // This will now store the full date
    var activities: [String]
    var budget: Double
    var dayAgendas: [DayAgenda] = []
    
    var totalActivities: Int {
        dayAgendas.reduce(0) { sum, agenda in
            sum + agenda.activities.count
        }
    }
    
    var destinationImageURL: String {
        switch destination {
        case "Paris":
            return "https://plus.unsplash.com/premium_photo-1661919210043-fd847a58522d?q=80&w=3020&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        case "Bali":
            return "https://images.unsplash.com/photo-1554481923-a6918bd997bc?q=80&w=3465&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        case "Tokyo":
            return "https://images.unsplash.com/photo-1551641506-ee5bf4cb45f1?q=80&w=3568&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        case "Santorini":
            return "https://images.unsplash.com/photo-1731684019094-673232b34cf6?q=80&w=3474&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        case "New York City":
            return "https://images.unsplash.com/photo-1539630179772-93574399faf7?q=80&w=3542&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        default:
            return "https://images.unsplash.com/photo-1484589065579-248aad0d8b13?q=80&w=3459&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        }
    }
}

struct ContentView: View {
    @State private var vacationPlans: [VacationPlan] = []
    @State private var showingAddSheet = false
    @State private var newDestination = ""
    @State private var newStartTime = Date()
    @State private var newEndTime = Date()
    @State private var budget: Double = 0.0
    @State private var editMode: EditMode = .inactive
    @State private var isDestinationPickerShowing = false
    @State private var selectedDestination: Destination?
    @State private var editingPlan: VacationPlan?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var sortedVacationPlans: [VacationPlan] {
        vacationPlans.sorted { $0.startTime < $1.startTime }
    }
    
    private var minEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: newStartTime) ?? newStartTime
    }
    
    var body: some View {
        NavigationView {
            Group {
                if vacationPlans.isEmpty {
                    VStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                                .padding(20)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .padding(.bottom, 8)
                            
                            Text("Plan your first trip")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("Tap + to start planning your next adventure!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        Spacer()
                    }
                    .offset(y: -44)
                } else {
                    List {
                        ForEach(sortedVacationPlans) { plan in
                            Section {
                                NavigationLink(destination: TripDetailView(plan: binding(for: plan))) {
                                    HStack(spacing: 12) {
                                        let imageURL = URL(string: plan.destinationImageURL)
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case .empty:
                                                Color.gray.opacity(0.3)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            case .failure:
                                                Color.gray.opacity(0.3)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(plan.destination)
                                                .font(.headline)
                                            let startDate = dateFormatter.string(from: plan.startTime)
                                            let endDate = dateFormatter.string(from: plan.endTime)
                                            Text("\(startDate) - \(endDate)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            if plan.totalActivities > 0 {
                                                Text("\(plan.totalActivities) \(plan.totalActivities == 1 ? "Activity" : "Activities")")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Text("Budget: \(plan.budget, format: .currency(code: "USD"))")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .listSectionSpacing(.compact)
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    if let index = vacationPlans.firstIndex(where: { $0.id == plan.id }) {
                                        vacationPlans.remove(at: index)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                
                                Button {
                                    editingPlan = plan
                                    showingAddSheet = true
                                    // Pre-populate the form with existing trip data
                                    newDestination = plan.destination
                                    newStartTime = plan.startTime
                                    newEndTime = plan.endTime
                                    budget = plan.budget
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.gray)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .listRowSpacing(8)
                }
            }
            .navigationTitle("Tripsss")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("Where to?")) {
                            Button(action: {
                                isDestinationPickerShowing = true
                            }) {
                                HStack {
                                    Text(newDestination.isEmpty ? "Select destination" : newDestination)
                                        .foregroundColor(newDestination.isEmpty ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                            }
                            .sheet(isPresented: $isDestinationPickerShowing) {
                                NavigationView {
                                    List {
                                        Section(header: Text("Custom Destination")) {
                                            TextField("Enter custom destination", text: $newDestination)
                                                .textInputAutocapitalization(.words)
                                            if !newDestination.isEmpty {
                                                Button(action: {
                                                    isDestinationPickerShowing = false
                                                }) {
                                                    Text("Use \"\(newDestination)\"")
                                                }
                                            }
                                        }
                                        
                                        Section(header: Text("Popular Destinations")) {
                                            ForEach(Destination.popular) { destination in
                                                Button(action: {
                                                    newDestination = destination.name
                                                    selectedDestination = destination
                                                    isDestinationPickerShowing = false
                                                }) {
                                                    HStack(spacing: 15) {
                                                        Image(systemName: destination.imageName)
                                                            .font(.title2)
                                                            .frame(width: 40, height: 40)
                                                            .background(Color.blue.opacity(0.1))
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            HStack {
                                                                Text(destination.name)
                                                                    .font(.headline)
                                                                Text(destination.country)
                                                                    .font(.subheadline)
                                                                    .foregroundColor(.gray)
                                                            }
                                                            
                                                            Text(destination.description)
                                                                .font(.caption)
                                                                .foregroundColor(.gray)
                                                                .lineLimit(2)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        Text("\(destination.popularityScore)%")
                                                            .font(.caption)
                                                            .foregroundColor(.green)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.green.opacity(0.1))
                                                            .clipShape(Capsule())
                                                    }
                                                }
                                                .foregroundColor(.primary)
                                            }
                                        }
                                    }
                                    .navigationTitle("Choose Destination")
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button("Cancel") {
                                                isDestinationPickerShowing = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Dates")) {
                            DatePicker("Start Date",
                                      selection: $newStartTime,
                                      displayedComponents: [.date])
                                .onChange(of: newStartTime) { oldTime, newTime in
                                    if newEndTime <= newStartTime {
                                        newEndTime = minEndDate
                                    }
                                }
                            
                            DatePicker("End Date",
                                      selection: $newEndTime,
                                      in: minEndDate...,
                                      displayedComponents: [.date])
                        }
                        
                        Section(header: Text("Budget")) {
                            TextField("Enter budget", value: $budget, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                        }
                    }
                    .navigationTitle(editingPlan != nil ? "Edit Trip" : "New Trip")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingAddSheet = false
                                resetForm()
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                _ = savePlan()
                                showingAddSheet = false
                                resetForm()
                            }
                            .disabled(newDestination.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func savePlan() -> VacationPlan {
        let plan = VacationPlan(
            destination: newDestination,
            startTime: newStartTime,
            endTime: newEndTime,
            activities: editingPlan?.activities ?? [],
            budget: budget,
            dayAgendas: editingPlan?.dayAgendas ?? []
        )
        
        if let editingPlan = editingPlan {
            if let index = vacationPlans.firstIndex(where: { $0.id == editingPlan.id }) {
                vacationPlans[index] = plan
            }
        } else {
            vacationPlans.append(plan)
        }
        
        editingPlan = nil
        return plan
    }
    
    private func deletePlan(at offsets: IndexSet) {
        vacationPlans.remove(atOffsets: offsets)
    }
    
    private func resetForm() {
        newDestination = ""
        newStartTime = Date()
        newEndTime = Date()
        budget = 0.0
        selectedDestination = nil
        editingPlan = nil
    }
    
    private func binding(for plan: VacationPlan) -> Binding<VacationPlan> {
        Binding(
            get: { plan },
            set: { newValue in
                if let index = vacationPlans.firstIndex(where: { $0.id == plan.id }) {
                    vacationPlans[index] = newValue
                }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
