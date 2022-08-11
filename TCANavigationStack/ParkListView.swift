//
//  ParkListView.swift
//  TCANavigationStack
//
//  Created by Yosuke NAKAYAMA on 2022/07/16.
//

import SwiftUI
import ComposableArchitecture

struct Park: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
}
struct ParkListState: Equatable, Identifiable {
    var id: UUID
    @BindableState var path = NavigationPath()
    var parkList: IdentifiedArrayOf<Park> = [.init(name: "Yoyogi Park"),
                                             .init(name: "Merican Park"),
                                             .init(name: "Rikyu Park")]
    var parkDetailState: ParkDetailState?
    enum Route: Equatable, Hashable {
        case parkDetailView(Park.ID)
        case parkDetailRoute(ParkDetailState.Route)
    }
}

enum ParkListAction: BindableAction, Equatable {
    case binding(BindingAction<ParkListState>)
    case goToParkDetailView(Park.ID)
    case parkDetailAction(ParkDetailAction)
}

struct ParkListEnvironment {}

let parkListReducer = Reducer<ParkListState, ParkListAction, ParkListEnvironment>
    { state, action, environment in
        switch action {
        case .goToParkDetailView(let id):
            guard let park = state.parkList[id: id] else { return .none }
            state.parkDetailState = .init(park: park)
            state.path.append(ParkListState.Route.parkDetailView(park.id))
            return .none
        case .binding(\.$path):
            if state.path.isEmpty {
                state.parkDetailState = nil
            }
            return .none
        case .parkDetailAction(.goToTextView):
            state.path.append(ParkListState.Route.parkDetailRoute(.textView))
            return .none
        case .parkDetailAction(.goBack):
            state.path.removeLast()
            return .none
        default:
            return .none
        }
    }.binding()
    .combined(with:
                parkDetailReducer
        .optional()
        .pullback(state: \.parkDetailState,
                  action: /ParkListAction.parkDetailAction,
                  environment: { _ in .init() })
    )

struct ParkListView: View {
    let store: Store<ParkListState, ParkListAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationStack(path: viewStore.binding(\.$path)) {
                VStack(spacing: 10) {
                    ForEach(viewStore.parkList) { park in
                        Button {
                            viewStore.send(.goToParkDetailView(park.id))
                        } label: {
                            Text(park.name)
                        }
                    }
                }
                .navigationTitle("Park List View")
                .navigationDestination(for: ParkListState.Route.self) { route in
                    switch route {
                    case .parkDetailView:
                        IfLetStore(
                            store.scope(
                                state: \.parkDetailState,
                                action: ParkListAction.parkDetailAction
                            ),
                            then: ParkDetailView.init(store:)
                        )
                    case .parkDetailRoute(.textView):
                        Text("Hello World!")
                    }
                }
            }
        }
    }
}
