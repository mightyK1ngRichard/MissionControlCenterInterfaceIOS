//
//  MapView.swift
//  SpaceStation
//
//  Created by Dmitriy Permyakov on 28/10/2023.
//

import SwiftUI

struct MapView: View {
    @EnvironmentObject var mainObserver: MainObserver
    @State private var station: StationStateModel!
    @State private var ConstPlanets: [PlanetModel]!
    @State private var rocketOffset: CGPoint = .zero
    @State private var proxy: ScrollViewProxy? = nil
    @State private var timer: Timer?
    @State private var showButtons = true
    @State private var showView = false
    @State private var errorMessage = "error message"

    var body: some View {
        VStack{
            if showView && station != nil && ConstPlanets != nil {
                MapScreen()
                    .overlay(alignment: .bottom) {
                        ControllerView
                    }
            } else {
                VStack(spacing: 10) {
                    ProgressView()
                    Image("not_found")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                    Text(errorMessage)
                        .font(.footnote)
                }
            }
        }
        .onDisappear {
            mainObserver.showTabBar = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    proxy?.scrollTo(String.rocketProxyName, anchor: .center)
                }) {
                    Image(systemName: "location.fill.viewfinder")
                }
            }
        }
        .onAppear {
            FetchPlanets()
            timer = Timer(timeInterval: 0.1, repeats: true) { _ in
                FetchRocket()
            }
            RunLoop.main.add(timer!, forMode: .common)
        }
        .navigationTitle("Управление")
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Views

private extension MapView {

    func MapScreen() -> some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ScrollViewReader { proxy in
                ZStack {
                    ForEach(mainObserver.planets) { planet in
                        let xOffset = planet.coordinates.x
                        let yOffset = planet.coordinates.y

                        AsyncImage(url: planet.imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(edge: (planet.radius ?? 0) / 30)
                                .offset(x: xOffset, y: yOffset)
                                .id(planet.id)

                        } placeholder: {
                            ShimmeringView()
                                .frame(edge: 130)
                                .clipShape(Circle())
                                .offset(x: xOffset, y: yOffset)
                        }

                    }

                    Image("ship")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: .shipSize)
                        .focusable()
                        .offset(x: rocketOffset.x, y: rocketOffset.y)
                        .id(String.rocketProxyName)
                        .rotationEffect(
                            .degrees((station.transform.directionAngleDegrees ?? 0) + 90)
                        )
                }
                .frame(width: .screenScrollWidth, height: .screenScrollHeigth)
                .onAppear {
                    proxy.scrollTo(String.rocketProxyName, anchor: .center)
                    self.proxy = proxy
                }
            }
        }
    }

    @ViewBuilder
    func ControlButton(_ imageName: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 1.5)) {
                showButtons = false
                ButtonControlAction(imageName)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 2)) {
                    showButtons = true
                }
            }
        } label: {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: .buttonSize)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .offset(y: showButtons ? 0 : 200)
    }

    var ControllerView: some View {
        VStack {
            HStack {
                ForEach([String].buttonsControl, id: \.self) {
                    ControlButton($0)
                }
            }
        }
    }
}

// MARK: - Functions

private extension MapView {

    func FetchRocket() {
        NetworkService.shared.request(
            router: .station,
            method: .get,
            type: StationStateEntity.self,
            parameters: nil
        ) { result in
            switch result {
            case .success(let info):
                station = info.mapper
                guard let pl = ConstPlanets else {
                    errorMessage = "Планеты не найдены"
                    showView = false
                    return
                }
                mainObserver.planets = pl.newCoordinates(
                    x: station.transform.x,
                    y: station.transform.y
                )
            case .failure(let error):
                errorMessage = error.localizedDescription
                showView = false
            }
        }
    }

    func FetchPlanets() {
        NetworkService.shared.request(
            router: .station,
            method: .get,
            type: StationStateEntity.self,
            parameters: nil
        ) { result in
            switch result {
            case .success(let info):
                station = info.mapper
                NetworkService.shared.request(
                    router: .planets,
                    method: .get,
                    type: [PlanetEntity].self,
                    parameters: ["scanRadius": 1500]
                ) { result in
                    switch result {
                    case .success(let planets):
                        self.ConstPlanets = planets.map { $0.mapper }
                        mainObserver.planets = ConstPlanets.newCoordinates(
                            x: station.transform.x,
                            y: station.transform.y
                        )
                        showView = true
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showView = false
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showView = false
            }
        }
    }

    func ButtonControlAction(_ imageName: String) {
        switch imageName {
        case "stop.circle":
            print("stop")
            ChangeSpeed((station.transform.linearSpeed ?? 0) - 10)

        case "chevron.left.circle":
            print("left")
            ChangeDirection(-10)

        case "flame.circle":
            print("Fire")
            ChangeSpeed((station.transform.linearSpeed ?? 0) + 10)

        default:
            print("right")
            ChangeDirection(10)
        }
    }
}

// MARK: - POST

private extension MapView {

    func ChangeSpeed(_ speed: Double) {
        NetworkService.shared.emptyRequest(
            router: .linearSpeed,
            parameters: ["requiredLinearSpeed": speed]
        ) { result in
            switch result {
            case .success(let str):
                print(str)
                return
            case .failure(let error):
                errorMessage = error.localizedDescription
                showView = false
            }
        }
    }

    func ChangeDirection(_ rotation: Double) {
        NetworkService.shared.emptyRequest(
            router: .rotationSpeed,
            parameters: ["requiredRotationSpeedClockwiseDegrees": rotation]
        ) { result in
            switch result {
            case .success(let str):
                print(str)
            case .failure(let error):
                errorMessage = error.localizedDescription
                showView = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(MainObserver())
}

#Preview {
    MapView()
        .environmentObject(MainObserver())
}

// MARK: - Constants

private extension CGFloat {

    static let buttonSize: CGFloat = 40
    static let planetSize: CGFloat = 150
    static let shipSize: CGFloat = 60
    static let screenScrollWidth: CGFloat = 700
    static let screenScrollHeigth: CGFloat = 2000
}

private extension String {

    static let rocketProxyName = "Rocket"
}

private extension [String] {

    static let buttonsControl: Self = [
        "chevron.left.circle",
        "flame.circle",
        "stop.circle",
        "chevron.right.circle"
    ]
}

// MARK: - Mock Data

private extension [PlanetModel] {

    static let planets: [PlanetModel] = [
        .init(id: 0, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -100, y: -250)),
        .init(id: 1, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -100, y: -250)),
        .init(id: 2, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 350, y: 0)),
        .init(id: 3, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 100, y: 100)),
        .init(id: 4, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 100, y: 500)),
        .init(id: 5, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 100, y: 0)),
    ]

    static let planets2: [PlanetModel] = [
        .init(id: 0, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -1000, y: 30)),
        .init(id: 1, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -700, y: -950)),
        .init(id: 2, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 450, y: 20)),
        .init(id: 3, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 500, y: 300)),
        .init(id: 4, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 500, y: 300)),
        .init(id: 5, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -100, y: 300)),
        .init(id: 6, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 20, y: 20))
    ]

    static let planets3: [PlanetModel] = [
        .init(id: 0, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -10, y: 10)),
        .init(id: 1, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -500, y: -950)),
        .init(id: 2, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 0, y: 450)),
        .init(id: 3, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 48, y: 800)),
        .init(id: 4, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 0, y: 100)),
        .init(id: 5, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 800, y: 0))
    ]
}
