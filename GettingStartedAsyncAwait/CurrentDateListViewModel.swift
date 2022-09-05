//
//  CurrentDateListViewModel.swift
//  GettingStartedAsyncAwait
//
//  Created by 山本響 on 2022/09/05.
//

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
