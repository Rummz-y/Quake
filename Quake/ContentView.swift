import SwiftUI
import Combine

// MARK: - Models
struct Character: Codable, Identifiable {
    var id = UUID()
    var name: String
    var turnRoll: Int
    var hp: Int
    var reactionUsed: Bool = false
    var monsterDetails: Monster?
}

struct SpecialAbility: Codable {
    let name: String?
    let desc: String?
    let attack_bonus: Int?
}

struct Action: Codable {
    let name: String?
    let desc: String?
    let attack_bonus: Int?
    let damage_dice: String?
    let damage_bonus: Int?
}

struct LegendaryAction: Codable {
    let name: String?
    let desc: String?
    let attack_bonus: Int?
}

struct Speed: Codable {
    let walk: Int?
    let swim: Int?
}

struct Monster: Codable, Identifiable {
    var id = UUID()

    let name: String?
    let size: String?
    let type: String?
    let subtype: String?
    let alignment: String?
    let armor_class: Int?
    let hit_points: Int?
    let hit_dice: String?
    let speed: String?
    let strength: Int?
    let dexterity: Int?
    let constitution: Int?
    let intelligence: Int?
    let wisdom: Int?
    let charisma: Int?
    let constitution_save: Int?
    let intelligence_save: Int?
    let wisdom_save: Int?
    let history: Int?
    let perception: Int?
    let damage_vulnerabilities: String?
    let damage_resistances: String?
    let damage_immunities: String?
    let condition_immunities: String?
    let senses: String?
    let languages: String?
    let challenge_rating: String?
    let special_abilities: [SpecialAbility]?
    let actions: [Action]?
    let legendary_desc: String?
    let legendary_actions: [LegendaryAction]?
    let speed_json: Speed?
    let armor_desc: String?

    private enum CodingKeys: String, CodingKey {
        case name, size, type, subtype, alignment, armor_class, hit_points, hit_dice, speed,
             strength, dexterity, constitution, intelligence, wisdom, charisma,
             constitution_save, intelligence_save, wisdom_save, history, perception,
             damage_vulnerabilities, damage_resistances, damage_immunities, condition_immunities,
             senses, languages, challenge_rating, special_abilities, actions, legendary_desc,
             legendary_actions, speed_json, armor_desc
    }
}

struct ContentView: View {

    @State private var characters: [Character] = []
    @State private var saveFiles: [URL] = []
    @State private var selectedFile: URL?
    @State private var saveStatus = ""
    @State private var currentIndex = 0
    @State private var newCharacterName = ""
    @State private var hpToSubtract: [UUID: Int] = [:]
    @State private var monsters: [Monster] = []
    @State private var showMonsterPicker = false


    var body: some View {
        TabView {
            fileManagementTab
                .tabItem {
                    Label("File Management", systemImage: "folder")
                }

            characterEditingTab
                .tabItem {
                    Label(selectedFile?.lastPathComponent ?? "Edit Characters", systemImage: "person.3")
                }

            monstersTab
                .tabItem {
                    Label("Monsters", systemImage: "flame")
                }
        }
        .onAppear {
            loadMonsters { loadedMonsters in
                self.monsters = loadedMonsters
            }
            listSaveFiles()
        }
    }


    var fileManagementTab: some View {
        VStack {
            Text("File Management")
                .font(.title)

            HStack {
                Button("List Saved Files") { listSaveFiles() }
                    .padding()

                Button("New File") { createNewFile() }
                    .padding()

                Button("Open Documents Folder") { openDocumentsFolder() }
                    .padding()
            }

            List(saveFiles, id: \.self) { file in
                Button(action: {
                    selectedFile = file
                    loadFileContent()
                }) {
                    Text(file.lastPathComponent)
                }
            }
            .frame(maxHeight: 200)

            Text(saveStatus)
                .padding()
                .foregroundColor(.green)
        }
        .padding()
    }

    var characterEditingTab: some View {
        VStack {
            if characters.isEmpty {
                Text("No characters loaded. Open a save file to edit characters.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Text(selectedFile?.lastPathComponent ?? "Edit Characters")
                    .font(.title)

                HStack {
                    Button("Sort by Name") { sortCharacters(by: .name) }
                        .padding()
                    Button("Sort by HP") { sortCharacters(by: .hp) }
                        .padding()
                    Button("Sort by Turn Roll") { sortCharacters(by: .turnRoll) }
                        .padding()
                    Button("Randomize Turn Rolls") { randomizeTurnRolls() }
                        .padding()
                }

                List {
                    ForEach(characters.indices, id: \.self) { index in
                        let character = characters[index]
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Name: \(character.name)")
                                    .font(.headline)
                                Spacer()
                                Button("Remove") {
                                    removeCharacter(at: index)
                                }
                                .foregroundColor(.red)
                            }

                            HStack {
                                Text("Turn Roll: \(character.turnRoll)")
                                Button("+") { modifyTurnRoll(for: character.id, by: 1) }
                                Button("-") { modifyTurnRoll(for: character.id, by: -1) }
                            }

                            HStack {
                                Text("HP: \(character.hp)")
                                TextField("HP to Subtract", value: Binding(
                                    get: { hpToSubtract[character.id] ?? 0 },
                                    set: { hpToSubtract[character.id] = $0 }
                                ), formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 100)
                                Button("Subtract HP") { subtractHP(from: character.id) }
                            }

                            HStack {
                                Toggle("Reaction", isOn: Binding(
                                    get: { character.reactionUsed },
                                    set: { characters[index].reactionUsed = $0 }
                                ))
                                .toggleStyle(CheckboxToggleStyle())
                            }

                            if let monster = character.monsterDetails {
                                DisclosureGroup("Monster Stats") {
                                    VStack(alignment: .leading) {
                                        Text("Type: \(monster.type ?? "Unknown")")
                                        Text("AC: \(monster.armor_class ?? 0)")
                                        Text("Speed: \(monster.speed ?? "Unknown")")
                                        Text("Alignment: \(monster.alignment ?? "Unknown")")
                                        Text("Strength: \(monster.strength ?? 0)")
                                        Text("Dexterity: \(monster.dexterity ?? 0)")
                                        Text("Constitution: \(monster.constitution ?? 0)")
                                        Text("Intelligence: \(monster.intelligence ?? 0)")
                                        Text("Wisdom: \(monster.wisdom ?? 0)")
                                        Text("Charisma: \(monster.charisma ?? 0)")
                                    }
                                }
                            }
                        }
                    }
                }

                HStack {
                    Button("End Turn") { endTurn() }
                        .padding()
                    Button("Add Monster") { showMonsterPicker = true }
                        .padding()
                    TextField("New Character Name", text: $newCharacterName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                    Button("Add New Character") { addNewCharacter() }
                        .padding()
                }
            }
        }
        .sheet(isPresented: $showMonsterPicker) {
            monsterPicker
        }
        .padding()
    }

    var monstersTab: some View {
        VStack {
            Text("Monsters")
                .font(.title)
                .padding()

            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 150), spacing: 15)]

                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(monsters, id: \.id) { monster in
                        VStack {
                            Text(monster.name ?? "Unknown")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 4)
                            Text("AC: \(monster.armor_class ?? 0)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("Type: \(monster.type ?? "Unknown")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("HP: \(monster.hit_points ?? 100)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("CR: \(monster.challenge_rating ?? "0")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Button("Add to Characters") {
                                addMonsterToCharacters(monster)
                            }
                            .padding(5)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(5)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 3)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }

    var monsterPicker: some View {
        NavigationView {
            ScrollView {
            }
            .navigationTitle("Choose a Monster")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showMonsterPicker = false
                    }
                }
            }
        }
    }

    // Beginning of Helper Functions
    func removeCharacter(at index: Int) {
        characters.remove(at: index)
        saveFile()
    }

    func loadMonsters(completion: @escaping ([Monster]) -> Void) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("monsters.json")

        DispatchQueue.global(qos: .background).async {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decodedMonsters = try JSONDecoder().decode([Monster].self, from: data)
                    DispatchQueue.main.async {
                        completion(decodedMonsters)
                    }
                } catch {
                    print("Failed to parse \(fileURL.path): \(error)")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } else {
                print("Monsters file not found at \(fileURL.path).")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    func addMonsterToCharacters(_ monster: Monster) {
        let newMonster = Character(
            name: monster.name ?? "monster",
            turnRoll: Int.random(in: 1...20),
            hp: monster.hit_points ?? 100,
            monsterDetails: monster
        )
        characters.append(newMonster)
        saveFile()
    }

    func saveFile() {
        guard let selectedFile = selectedFile else {
            saveStatus = "No file selected to save."
            return
        }

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(characters) {
            do {
                try data.write(to: selectedFile, options: .atomic)
                saveStatus = "File saved successfully!"
            } catch {
                print("Error writing file:", error)
                saveStatus = "Failed to save file. Please check file permissions or location."
            }
        }
    }

    func listSaveFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            saveFiles = files.filter { $0.pathExtension == "json" }
        } catch {
            print("Error listing files:", error)
            saveFiles = []
        }
    }

    func loadFileContent() {
        guard let selectedFile = selectedFile else { return }
        do {
            let data = try Data(contentsOf: selectedFile)
            characters = try JSONDecoder().decode([Character].self, from: data)
            saveStatus = "File loaded successfully!"
        } catch {
            print("Error loading file: \(error)")
            saveStatus = "Failed to load file."
        }
    }

    func createNewFile() {
        let newFileName = "NewCampaignFile-\(UUID().uuidString).json"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(newFileName)

        characters = [Character(name: "New Character", turnRoll: 10, hp: 100)]
        selectedFile = fileURL
        saveFile()
        listSaveFiles()
    }

    func openDocumentsFolder() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        NSWorkspace.shared.open(documentsURL)
    }

    func modifyTurnRoll(for id: UUID, by amount: Int) {
        if let index = characters.firstIndex(where: { $0.id == id }) {
            characters[index].turnRoll += amount
            saveFile()
        }
    }

    func subtractHP(from id: UUID) {
        if let index = characters.firstIndex(where: { $0.id == id }) {
            let amount = hpToSubtract[id] ?? 0
            if amount > 0 {
                characters[index].hp = max(0, characters[index].hp - amount)
                hpToSubtract[id] = 0
                saveFile()
            }
        }
    }

    func endTurn() {
        guard !characters.isEmpty else { return }
        currentIndex = (currentIndex + 1) % characters.count
    }

    func addNewCharacter() {
        guard !newCharacterName.isEmpty else { return }
        let newCharacter = Character(name: newCharacterName, turnRoll: 10, hp: Int.random(in: 1...20))
        characters.append(newCharacter)
        saveFile()
        newCharacterName = ""
    }

    func sortCharacters(by type: SortType) {
        switch type {
        case .name:
            characters.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .hp:
            characters.sort { $0.hp > $1.hp }
        case .turnRoll:
            characters.sort { $0.turnRoll > $1.turnRoll }
        }
    }

    func randomizeTurnRolls() {
        for i in characters.indices {
            characters[i].turnRoll = Int.random(in: 1...20)
        }
        sortCharacters(by: .turnRoll)
    }
}

enum SortType {
    case name, hp, turnRoll
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
