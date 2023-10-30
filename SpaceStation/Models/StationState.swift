//
//  StationState.swift
//  SpaceStation
//
//  Created by Dmitriy Permyakov on 28/10/2023.
//

import Foundation

// MARK: - Entity

struct StationStateEntity: Decodable {
    let name: String?
    let battery: BatteryEntity?
    let linearSpeedAcceleration: Double?
    let rotationSpeedDegreesAcceleration: Double?
    let transform: StationTransformEntity
}

struct StationTransformEntity: Decodable {
    let x: Double
    let y: Double
    let requiredLinearSpeed: Double?
    let linearSpeed: Double?
    let requiredRotationSpeedClockwiseDegrees: Double?
    let rotationSpeedClockwiseDegrees: Double?
    let directionAngleDegrees: Double?
}

struct BatteryEntity: Decodable {
    let level: Double?
    let passiveDegradationRate: Double?
    let loadDegrationRate: Double?
}

// MARK: - Model

struct StationStateModel: Decodable {
    let name: String?
    let battery: BatteryModel?
    let linearSpeedAcceleration: Double?
    let rotationSpeedDegreesAcceleration: Double?
    let transform: StationTransformModel
}

struct StationTransformModel: Decodable {
    let x: Double
    let y: Double
    let requiredLinearSpeed: Double?
    let linearSpeed: Double?
    let requiredRotationSpeedClockwiseDegrees: Double?
    let directionAngleDegrees: Double?
}

struct BatteryModel: Decodable {
    let level: Double?
    let passiveDegradationRate: Double?
    let loadDegrationRate: Double?
}

// MARK: - Mapper

extension StationStateEntity {

    var mapper: StationStateModel {
        StationStateModel(
            name: name,
            battery: battery?.mapper,
            linearSpeedAcceleration: linearSpeedAcceleration,
            rotationSpeedDegreesAcceleration: rotationSpeedDegreesAcceleration,
            transform: transform.mapper
        )
    }
}

extension StationTransformEntity {

    var mapper: StationTransformModel {
        StationTransformModel(
            x: x,
            y: y,
            requiredLinearSpeed: requiredLinearSpeed,
            linearSpeed: linearSpeed,
            requiredRotationSpeedClockwiseDegrees: requiredRotationSpeedClockwiseDegrees,
            directionAngleDegrees: directionAngleDegrees
        )
    }
}

extension BatteryEntity {

    var mapper: BatteryModel {
        BatteryModel(
            level: level,
            passiveDegradationRate: passiveDegradationRate,
            loadDegrationRate: loadDegrationRate
        )
    }

}
