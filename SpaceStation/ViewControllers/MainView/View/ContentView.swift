//
//  ContentView.swift
//  SpaceStation
//
//  Created by Dmitriy Permyakov on 28/10/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: Tab = .planets
    @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { AnimatedTab(tab: $0) }
    @StateObject var mainObserver = MainObserver()
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                NavigationStack {
                    PlanetsView()
                }
                .setUpTab(.planets)

                NavigationStack {
                    VStack {
                        NavigationLink {
                            MapView()
                                .toolbar(.hidden, for: .tabBar)
                                .task {
                                    mainObserver.showTabBar = false
                                }
                        } label: {
                            DynamicRectangle(title: "Начать\nуправление")
                        }

                        LottieView(lottieFile: "spaceGirl")
                            .frame(width: 300, height: 300)
                    }
                }
                .setUpTab(.controller)

                NavigationStack {
                    VStack {
                        StationView()
                    }
                    .navigationTitle(Tab.house.title)
                }
                .setUpTab(.house)
            }

            if mainObserver.showTabBar {
                CustomTabBar()
            }
        }
        .onAppear(perform: FetchData)
        .environmentObject(mainObserver)
    }
}

// MARK: - Network

private extension ContentView {
    
    func FetchData() {
        NetworkService.shared.request(
            router: .planets,
            method: .get,
            type: [PlanetEntity].self,
            parameters: ["scanRadius": -1]
        ) { result in
            switch result {
            case .success(let planets):
                mainObserver.planets = planets.map { $0.mapper }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(MainObserver())
}

// MARK: - Custom Bar

private extension ContentView {

    @ViewBuilder
    func CustomTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach($allTabs) { $animatedTab in
                let tab = animatedTab.tab
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .font(.title2)
                        .symbolEffect(.bounce.down.byLayer, value: animatedTab.isAnimating)

                    Text(tab.title)
                        .font(.caption2)
                        .textScale(.secondary)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(activeTab == tab ? Color.primary : Color.gray.opacity(0.8))
                .padding(.top, 5)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.bouncy, completionCriteria: .logicallyComplete) {
                        activeTab = tab
                        animatedTab.isAnimating = true
                    } completion: {
                        var trasnaction = Transaction()
                        trasnaction.disablesAnimations = true
                        withTransaction(trasnaction) {
                            animatedTab.isAnimating = nil
                        }
                    }
                }
            }
        }
        .background(.bar)
    }
}

private extension CGFloat {

    static let rotation: CGFloat = 360
}
