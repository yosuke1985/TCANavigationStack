//
//  ParkDetailView.swift
//  TCANavigationStack
//x
//  Created by Yosuke NAKAYAMA on 2022/07/16.
//

import SwiftUI
import ComposableArchitecture

struct ParkDetailState: Equatable {
    let park: Park
    var alert: AlertState<ParkDetailAction>?

    enum Route: Equatable, Hashable {
        case textView
    }
}

enum ParkDetailAction: Equatable {
    case showAlert
    case alertDismissed
    case goToTextView
    case goBack
}

struct ParkDetailEnvironment {}

let parkDetailReducer = Reducer<ParkDetailState, ParkDetailAction, ParkDetailEnvironment>
{ state, action, _ in
    switch action {
    case .showAlert:
        state.alert = .init(title: TextState("Alert"))
        return .none
    case .alertDismissed:
        state.alert = nil
        return .none
    default:
        return .none
    }
}

struct ParkDetailView: View {
    let store: Store<ParkDetailState, ParkDetailAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 10) {

                Button {
                    viewStore.send(.showAlert)
                } label: {
                    Text("Show Alert")
                }

                Button {
                    viewStore.send(.goToTextView)
                } label: {
                    Text("Go Text View")
                }

                Button {
                    viewStore.send(.goBack)
                } label: {
                    Text("Go Back")
                }


            }
            .navigationTitle(viewStore.park.name)
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
        }
    }
}
