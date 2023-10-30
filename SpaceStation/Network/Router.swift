//
//  Router.swift
//  Vikings
//
//  Created by Дмитрий Пермяков on 18.09.2023.
//

import Foundation

// MARK: ROUTER

enum Router {
    case station
    case planets
    case linearSpeed
    case rotationSpeed
}

// MARK: METHODs

enum Method: String {
    case get  = "GET"
    case post = "POST"
}

// MARK: ENDPOINTS

extension Router {
    
    var endpoint: String {
        switch self {
        case .station: return .baseUrl + .station
        case .planets: return .baseUrl + .planets
        case .linearSpeed: return .baseUrl + .linearSpeed
        case .rotationSpeed: return .baseUrl + .rotationSpeed
        }
    }
}

// MARK: CONSTANTS

private extension String {
    
    static let baseUrl = String.serverHost + "/api"
    static let station = "/Station"
    static let planets = String.station + "/planets"
    static let linearSpeed = "/Station/linearSpeed"
    static let rotationSpeed = "/Station/rotationSpeed"
}

extension String {

    static let serverHost = "http://192.168.1.37:2023"
}
