import SwiftUI

struct TripDetailView: View {
    @Binding var plan: VacationPlan
    @State private var showingAddActivitySheet = false
    @State private var selectedDay: Date?
    @State private var isOverviewExpanded = false
    @State private var selectedCategory: ActivityCategory?
    @State private var expandedDays: Set<Date> = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    private var daysInTrip: [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: plan.startTime)
        let endDate = calendar.startOfDay(for: plan.endTime)
        
        repeat {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        } while currentDate <= endDate
        
        return dates
    }
    
    private var minEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: plan.startTime) ?? plan.startTime
    }
    
    private var destinationImage: String {
        switch plan.destination {
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
            // Provide a default image URL if needed
            return "https://plus.unsplash.com/premium_photo-1661919210043-fd847a58522d?q=80&w=3020&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        }
    }
    
    private var destinationColor: Color {
        let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .red, .teal]
        let randomIndex = abs(plan.destination.hashValue) % colors.count
        return colors[randomIndex]
    }
    
    var body: some View {
        List {
            Section {
                AsyncImage(url: URL(string: destinationImage)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(.clear)
                            .listRowBackground(Color.clear)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    case .failure(_):
                        Rectangle()
                            .fill(destinationColor.opacity(0.3))
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .listSectionSeparator(.hidden)
            
            Section(header: Text("Trip Overview")) {
                DisclosureGroup(
                    isExpanded: $isOverviewExpanded,
                    content: {
                        DatePicker("Start Date",
                                  selection: $plan.startTime,
                                  displayedComponents: [.date])
                            .onChange(of: plan.startTime) { oldTime, newTime in
                                if plan.endTime <= plan.startTime {
                                    plan.endTime = minEndDate
                                }
                            }
                        
                        DatePicker("End Date",
                                  selection: $plan.endTime,
                                  in: minEndDate...,
                                  displayedComponents: [.date])
                            .onChange(of: plan.endTime) { oldTime, newTime in
                            }
                        
                        HStack {
                            Text("Duration:")
                            Spacer()
                            Text("\(daysInTrip.count) days")
                        }
                        
                        HStack {
                            Text("Budget:")
                            Spacer()
                            TextField("", value: $plan.budget, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.green)
                        }
                    },
                    label: {
                        HStack {
                            Text("\(daysInTrip.count) days")
                            Text("•")
                            Text(dateFormatter.string(from: plan.startTime))
                            Text("-")
                            Text(dateFormatter.string(from: plan.endTime))
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                )
            }
            
            ForEach(daysInTrip, id: \.self) { day in
                Section(header: DayHeaderView(date: day, formatter: dayFormatter)) {
                    if let agenda = plan.dayAgendas.first(where: { calendar.isDate($0.date, inSameDayAs: day) }),
                       let agendaIndex = plan.dayAgendas.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                        
                        if !agenda.activities.isEmpty {
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedDays.contains(day) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedDays.insert(day)
                                        } else {
                                            expandedDays.remove(day)
                                        }
                                    }
                                )
                            ) {
                                ForEach(agenda.sortedActivities.indices, id: \.self) { index in
                                    let activity = agenda.sortedActivities[index]
                                    let bindingIndex = agenda.activities.firstIndex(where: { $0.time == activity.time })!
                                    
                                    NavigationLink(
                                        destination: ActivityDetailView(
                                            activity: $plan.dayAgendas[agendaIndex].activities[bindingIndex],
                                            plan: $plan
                                        )
                                    ) {
                                        HStack(alignment: .top, spacing: 12) {
                                            VStack(spacing: 4) {
                                                if let category = activity.category {
                                                    Image(systemName: category.icon)
                                                        .foregroundColor(.blue)
                                                        .frame(width: 24, height: 24)
                                                } else {
                                                    Spacer()
                                                        .frame(width: 24, height: 24)
                                                }
                                                Text(timeFormatter.string(from: activity.time))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(activity.name)
                                                    .font(.headline)
                                                
                                                if !activity.description.isEmpty {
                                                    Text(activity.description)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                if let photoData = activity.photoData,
                                                   let uiImage = UIImage(data: photoData) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(height: 150)
                                                        .frame(maxWidth: .infinity)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                }
                                            }
                                        }
                                    }
                                }
                                .onDelete { indexSet in
                                    // Convert selected indices to the actual activity indices
                                    let activitiesToDelete = indexSet.map { agenda.sortedActivities[$0] }
                                    
                                    // Remove the activities
                                    plan.dayAgendas[agendaIndex].activities.removeAll { activity in
                                        activitiesToDelete.contains { $0.time == activity.time }
                                    }
                                    
                                    // If the agenda is now empty, remove it
                                    if plan.dayAgendas[agendaIndex].activities.isEmpty {
                                        plan.dayAgendas.remove(at: agendaIndex)
                                    }
                                }
                            } label: {
                                Text("\(agenda.activities.count) \(agenda.activities.count == 1 ? "Activity" : "Activities")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: {
                        selectedDay = day
                        showingAddActivitySheet = true
                    }) {
                        Label("Add Activity", systemImage: "plus.circle")
                    }
                }
            }
        }
        .navigationTitle(plan.destination)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            initializeExpandedDays()
        }
        .sheet(isPresented: $showingAddActivitySheet) {
            if let day = selectedDay {
                AddDayActivityView(
                    day: day,
                    plan: $plan,
                    expandedDays: $expandedDays
                )
            }
        }
    }
    
    private let calendar = Calendar.current
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func initializeExpandedDays() {
        expandedDays = Set(daysInTrip)
    }
}

private struct DayHeaderView: View {
    let date: Date
    let formatter: DateFormatter
    
    var body: some View {
        Text(formatter.string(from: date))
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .textCase(nil)
            .padding(.top, 8)
    }
}

struct AddDayActivityView: View {
    let day: Date
    @Binding var plan: VacationPlan
    @Binding var expandedDays: Set<Date>
    @Environment(\.dismiss) private var dismiss
    @State private var activityTime = Date()
    @State private var activityName = ""
    @State private var activityDescription = ""
    @State private var activityURL = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedCategory: ActivityCategory?
    @State private var activityAirline = ""
    @State private var activityFlightNumber = ""
    @State private var activityTerminal = ""
    @State private var activityCost: Double?
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Time", selection: $activityTime, displayedComponents: .hourAndMinute)
                
                Section(header: Text("Category")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ActivityCategory.allCases, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    VStack {
                                        Image(systemName: category.icon)
                                            .font(.title2)
                                            .frame(width: 44, height: 44)
                                            .background(selectedCategory == category ? Color.blue : Color.blue.opacity(0.1))
                                            .foregroundColor(selectedCategory == category ? .white : .blue)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Text(category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(selectedCategory == category ? .primary : .secondary)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Activity")) {
                    TextField("Title", text: $activityName)
                    
                    if selectedCategory == .flight {
                        TextField("Airport", text: $activityDescription)
                        TextField("Airline", text: $activityAirline)
                        TextField("Flight Number", text: $activityFlightNumber)
                            .textInputAutocapitalization(.characters)
                        TextField("Terminal", text: $activityTerminal)
                            .textInputAutocapitalization(.characters)
                    } else {
                        TextField("Description", text: $activityDescription, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                
                Section(header: Text("Details")) {
                    TextField("URL (optional)", text: $activityURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    if let image = selectedImage {
                        HStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                            
                            Button(role: .destructive) {
                                selectedImage = nil
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                    
                    Button {
                        showingImagePicker = true
                    } label: {
                        Label(selectedImage == nil ? "Add Photo" : "Change Photo", 
                              systemImage: "photo")
                    }
                }
                
                Section(header: Text("Budget")) {
                    TextField("Cost (optional)", value: $activityCost, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addActivity()
                        dismiss()
                    }
                    .disabled(activityName.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func addActivity() {
        let calendar = Calendar.current
        let activityDate = calendar.date(bySettingHour: calendar.component(.hour, from: activityTime),
                                       minute: calendar.component(.minute, from: activityTime),
                                       second: 0,
                                       of: day) ?? day
        
        let description: String
        if selectedCategory == .flight {
            description = [
                "Airport: \(activityDescription)",
                "Airline: \(activityAirline)",
                "Flight: \(activityFlightNumber)",
                "Terminal: \(activityTerminal)"
            ].joined(separator: "\n")
        } else {
            description = activityDescription
        }
        
        let activity = ScheduledActivity(
            time: activityDate,
            name: activityName,
            description: description,
            category: selectedCategory,
            url: activityURL.isEmpty ? nil : activityURL,
            photoData: selectedImage?.jpegData(compressionQuality: 0.8)
        )
        
        var updatedAgendas = plan.dayAgendas
        
        if let index = updatedAgendas.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
            updatedAgendas[index].activities.append(activity)
            updatedAgendas[index].activities.sort { $0.time < $1.time }
        } else {
            let newAgenda = DayAgenda(date: day, activities: [activity])
            updatedAgendas.append(newAgenda)
        }
        
        plan.dayAgendas = updatedAgendas
        expandedDays.insert(day)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, 
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

struct FlightDetails {
    var airport: String
    var airline: String
    var flightNumber: String
    var terminal: String
}

struct ActivityDetailView: View {
    @Binding var activity: ScheduledActivity
    @Binding var plan: VacationPlan
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    // Add temporary state for all editable fields
    @State private var tempTime: Date
    @State private var tempName: String
    @State private var tempDescription: String
    @State private var tempCategory: ActivityCategory?
    @State private var tempURL: String
    @State private var tempPhotoData: Data?
    @State private var hasChanges = false
    @State private var flightDetails: FlightDetails = FlightDetails(airport: "", airline: "", flightNumber: "", terminal: "")
    
    // Initialize temporary state with current values
    init(activity: Binding<ScheduledActivity>, plan: Binding<VacationPlan>) {
        self._activity = activity
        self._plan = plan
        self._tempTime = State(initialValue: activity.wrappedValue.time)
        self._tempName = State(initialValue: activity.wrappedValue.name)
        self._tempDescription = State(initialValue: activity.wrappedValue.description)
        self._tempCategory = State(initialValue: activity.wrappedValue.category)
        self._tempURL = State(initialValue: activity.wrappedValue.url ?? "")
        self._tempPhotoData = State(initialValue: activity.wrappedValue.photoData)
        
        // Parse flight details if category is flight
        if activity.wrappedValue.category == .flight {
            let details = Self.parseFlightDetails(activity.wrappedValue.description)
            self._flightDetails = State(initialValue: details)
        }
    }
    
    var body: some View {
        List {
            DatePicker("Time", selection: $tempTime, displayedComponents: .hourAndMinute)
                .onChange(of: tempTime) { checkForChanges() }
            
            Section(header: Text("Category")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ActivityCategory.allCases, id: \.self) { category in
                            Button {
                                tempCategory = category
                                checkForChanges()
                            } label: {
                                VStack {
                                    Image(systemName: category.icon)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(tempCategory == category ? Color.blue : Color.blue.opacity(0.1))
                                        .foregroundColor(tempCategory == category ? .white : .blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .foregroundColor(tempCategory == category ? .primary : .secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Activity")) {
                TextField("Title", text: $tempName)
                    .onChange(of: tempName) { _, _ in checkForChanges() }
                
                if tempCategory == .flight {
                    TextField("Airport", text: $flightDetails.airport)
                        .onChange(of: flightDetails.airport) { _, _ in updateFlightDescription() }
                    TextField("Airline", text: $flightDetails.airline)
                        .onChange(of: flightDetails.airline) { _, _ in updateFlightDescription() }
                    TextField("Flight Number", text: $flightDetails.flightNumber)
                        .textInputAutocapitalization(.characters)
                        .onChange(of: flightDetails.flightNumber) { _, _ in updateFlightDescription() }
                    TextField("Terminal", text: $flightDetails.terminal)
                        .textInputAutocapitalization(.characters)
                        .onChange(of: flightDetails.terminal) { _, _ in updateFlightDescription() }
                } else {
                    TextField("Description", text: $tempDescription, axis: .vertical)
                        .onChange(of: tempDescription) { _, _ in checkForChanges() }
                }
            }
            
            Section(header: Text("Details")) {
                TextField("URL (optional)", text: $tempURL)
                    .onChange(of: tempURL) { checkForChanges() }
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                if let photoData = tempPhotoData,
                   let uiImage = UIImage(data: photoData) {
                    HStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Button(role: .destructive) {
                            tempPhotoData = nil
                            checkForChanges()
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                
                Button {
                    showingImagePicker = true
                } label: {
                    Label(tempPhotoData == nil ? "Add Photo" : "Change Photo", 
                          systemImage: "photo")
                }
            }
        }
        .navigationTitle("Edit Activity")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if hasChanges {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
                .onChange(of: selectedImage) { _, newImage in
                    if let image = newImage {
                        tempPhotoData = image.jpegData(compressionQuality: 0.8)
                        checkForChanges()
                    }
                }
        }
    }
    
    private func checkForChanges() {
        // Always check if there are changes, regardless of previous edits
        if tempCategory == .flight {
            let currentFlightDetails = Self.parseFlightDetails(activity.description)
            hasChanges = tempTime != activity.time ||
                tempName != activity.name ||
                flightDetails.airport != currentFlightDetails.airport ||
                flightDetails.airline != currentFlightDetails.airline ||
                flightDetails.flightNumber != currentFlightDetails.flightNumber ||
                flightDetails.terminal != currentFlightDetails.terminal ||
                tempCategory != activity.category ||
                tempURL != (activity.url ?? "") ||
                tempPhotoData != activity.photoData
        } else {
            hasChanges = tempTime != activity.time ||
                tempName != activity.name ||
                tempDescription != activity.description ||
                tempCategory != activity.category ||
                tempURL != (activity.url ?? "") ||
                tempPhotoData != activity.photoData
        }
    }
    
    private func saveChanges() {
        // Store the old time before updating the activity
        let oldTime = activity.time
        let calendar = Calendar.current
        
        // Create a new activity instance with the updated values
        let updatedActivity = ScheduledActivity(
            time: tempTime,
            name: tempName,
            description: tempDescription,
            category: tempCategory,
            url: tempURL.isEmpty ? nil : tempURL,
            photoData: tempPhotoData
        )
        
        // Find the old and new day agendas
        let oldDay = calendar.startOfDay(for: oldTime)
        let newDay = calendar.startOfDay(for: tempTime)
        
        // Handle the update
        if calendar.isDate(oldDay, inSameDayAs: newDay) {
            // Same day - just update the activity
            if let agendaIndex = plan.dayAgendas.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: newDay) }),
               let activityIndex = plan.dayAgendas[agendaIndex].activities.firstIndex(where: { $0.time == oldTime }) {
                plan.dayAgendas[agendaIndex].activities[activityIndex] = updatedActivity
            }
        } else {
            // Different days - remove from old day, add to new day
            if let oldAgendaIndex = plan.dayAgendas.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: oldDay) }) {
                plan.dayAgendas[oldAgendaIndex].activities.removeAll { $0.time == oldTime }
                
                // Remove empty agenda
                if plan.dayAgendas[oldAgendaIndex].activities.isEmpty {
                    plan.dayAgendas.remove(at: oldAgendaIndex)
                }
            }
            
            // Add to new day
            if let newAgendaIndex = plan.dayAgendas.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: newDay) }) {
                plan.dayAgendas[newAgendaIndex].activities.append(updatedActivity)
            } else {
                // Create new agenda if needed
                let newAgenda = DayAgenda(date: newDay, activities: [updatedActivity])
                plan.dayAgendas.append(newAgenda)
            }
        }
        
        // Update the binding
        activity = updatedActivity
    }
    
    private static func parseFlightDetails(_ description: String) -> FlightDetails {
        var details = FlightDetails(airport: "", airline: "", flightNumber: "", terminal: "")
        
        let lines = description.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("Airport: ") {
                details.airport = String(line.dropFirst(9))
            } else if line.hasPrefix("Airline: ") {
                details.airline = String(line.dropFirst(9))
            } else if line.hasPrefix("Flight: ") {
                details.flightNumber = String(line.dropFirst(8))
            } else if line.hasPrefix("Terminal: ") {
                details.terminal = String(line.dropFirst(10))
            }
        }
        
        return details
    }
    
    private func updateFlightDescription() {
        tempDescription = [
            "Airport: \(flightDetails.airport)",
            "Airline: \(flightDetails.airline)",
            "Flight: \(flightDetails.flightNumber)",
            "Terminal: \(flightDetails.terminal)"
        ].joined(separator: "\n")
        checkForChanges()
    }
}

extension DayAgenda {
    var sortedActivities: [ScheduledActivity] {
        activities.sorted { $0.time < $1.time }
    }
}

