# GettingStartedAsyncAwait

<img width="300" src="https://user-images.githubusercontent.com/47273077/188433846-5a987b99-64ec-4786-8ef9-213518255acd.gif">

```swift
import SwiftUI

struct CurrentDate: Decodable, Identifiable {
    let id = UUID()
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case date = "date"
    }
}

struct ContentView: View {
    
    @State private var currentDates: [CurrentDate] = []
    
    private func getDate() async throws -> CurrentDate? {
        
        guard let url = URL(string: "https://ember-sparkly-rule.glitch.me/current-date") else {
            fatalError("Url is incorrect!")
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try? JSONDecoder().decode(CurrentDate.self, from: data)
    }
    
    private func populateDates() async {
        
        do {
            guard let currentDate = try await getDate() else {
                return
            }
            
            self.currentDates.append(currentDate)
            
        } catch {
            print(error)
        }
    }

    var body: some View {
        NavigationView {
            List(currentDates) { currentDate in
                Text("\(currentDate.date)")
            }.listStyle(.plain)
            
            .navigationTitle("Dates")
            .navigationBarItems(trailing: Button(action: {
                // button action
                Task.init {
                    await populateDates()
                }
            }, label: {
                Image(systemName: "arrow.clockwise.circle")
            }))
            .task {
                await populateDates()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

```

-----

## MVVM
```swift
import SwiftUI

struct CurrentDate: Decodable, Identifiable {
    let id = UUID()
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case date = "date"
    }
}

struct ContentView: View {
    
    @StateObject private var currentDateListVM = CurrentDateListViewModel()

    var body: some View {
        NavigationView {
            List(currentDateListVM.currentDates, id: \.id) { currentDate in
                Text("\(currentDate.date)")
            }.listStyle(.plain)
            
            .navigationTitle("Dates")
            .navigationBarItems(trailing: Button(action: {
                // button action
                Task.init {
                    await currentDateListVM.populateDates()
                }
            }, label: {
                Image(systemName: "arrow.clockwise.circle")
            }))
            .task {
                await currentDateListVM.populateDates()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```


```swift

import Foundation

class Webservice {
    
    func getDate() async throws -> CurrentDate? {
        
        guard let url = URL(string: "https://ember-sparkly-rule.glitch.me/current-date") else {
            fatalError("Url is incorrect!")
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try? JSONDecoder().decode(CurrentDate.self, from: data)
    }
}
```

```swift
import Foundation

@MainActor // remove DispatchQueue.main.async
class CurrentDateListViewModel: ObservableObject {
    
    @Published var currentDates: [CurrentDateViewModel] = []
    
    func populateDates() async {
        do {
            let currentDate = try await Webservice().getDate()
            if let currentDate = currentDate {
                let currentDateViewModel = CurrentDateViewModel(currentDate: currentDate)
//                DispatchQueue.main.async {
                    self.currentDates.append(currentDateViewModel)
//                }
            }
        } catch {
            print(error)
        }
    }
}

struct CurrentDateViewModel {
    let currentDate: CurrentDate
    
    var id: UUID {
        currentDate.id
    }
    
    var date: String {
        currentDate.date
    }
}

```
