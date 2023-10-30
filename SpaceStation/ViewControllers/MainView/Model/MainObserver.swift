//
//  MainObserver.swift
//  SpaceStation
//
//  Created by Dmitriy Permyakov on 29/10/2023.
//

import Foundation

class MainObserver: ObservableObject {
    @Published var showTabBar: Bool = true
    @Published var planets: [PlanetModel] = []
}
