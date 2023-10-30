//
//  Planet.swift
//  SpaceStation
//
//  Created by Dmitriy Permyakov on 28/10/2023.
//

import Foundation

// MARK: - Entity

struct PlanetEntity: Decodable {
    let id: Int
    let name: String?
    let description: String?
    let discoveryDate: String?
    let imageUrl: String?
    let radius: Double?
    let mass: Double?
    let position: PlanetCoorinateEntity
}

struct PlanetCoorinateEntity: Decodable {
    let x: Double
    let y: Double
}

// MARK: - View Model

struct PlanetModel: Identifiable {
    let id: Int
    let name: String?
    let description: String?
    let discoveryDate: String?
    let imageURL: URL?
    let radius: Double?
    let mass: Double?
    let coordinates: PlanetCoorinateModel
}

struct PlanetCoorinateModel {
    let x: Double
    let y: Double
}

// MARK: - Mapper

private extension PlanetCoorinateEntity {
    var mapper: PlanetCoorinateModel {
        PlanetCoorinateModel(x: x, y: y)
    }
}

extension PlanetEntity {

    var mapper: PlanetModel {
        PlanetModel(
            id: id,
            name: name,
            description: description,
            discoveryDate: discoveryDate,
            imageURL: (.serverHost + "/api/StaticData/\(imageUrl ?? "")").toURL,
            radius: radius,
            mass: mass,
            coordinates: position.mapper
        )
    }
}

// MARK: - New coordinates

extension [PlanetModel] {

    func newCoordinates(x RocketX: Double, y RocketY: Double) -> Self {
        self.map {
            PlanetModel(
                id: $0.id,
                name: $0.name,
                description: $0.description,
                discoveryDate: $0.discoveryDate,
                imageURL: $0.imageURL,
                radius: $0.radius,
                mass: $0.mass,
                coordinates: PlanetCoorinateModel(
                    x: $0.coordinates.x - RocketX,
                    y: $0.coordinates.y - RocketY
                )
            )
        }
    }
}
