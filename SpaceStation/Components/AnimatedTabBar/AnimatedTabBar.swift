//
//  AnimatedTabBar.swift
//  Vikings
//
//  Created by Dmitriy Permyakov on 26/10/2023.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case planets = "globe.asia.australia.fill"
    case controller = "gamecontroller"
    case house = "house"

    var title: String {
        switch self {
        case .planets:
            return "Планеты"
        case .controller:
            return "Пульт"
        case .house:
            return "Станция"
        }
    }
}

struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tab
    var isAnimating: Bool?
}

extension View {

    @ViewBuilder
    func setUpTab(_ tab: Tab) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tag(tab)
            .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    ContentView()
}
