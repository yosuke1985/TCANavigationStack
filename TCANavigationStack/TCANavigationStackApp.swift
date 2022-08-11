//
//  TCANavigationStackApp.swift
//  TCANavigationStack
//
//  Created by Yosuke NAKAYAMA on 2022/07/20.
//

import SwiftUI

@main
struct TCANavigationStackApp: App {
    var body: some Scene {
        WindowGroup {
            ParkListView(store: .init(initialState: ParkListState(id: UUID()),
                                      reducer: parkListReducer,
                                      environment: ParkListEnvironment())
            )
        }
    }
}
