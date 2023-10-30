//
//  PlanetsView.swift
//  Vikings
//
//  Created by Dmitriy Permyakov on 28/10/2023.
//

import SwiftUI

struct PlanetsView: View {
    @EnvironmentObject var mainObserver: MainObserver
    @State private var offsetY: CGFloat = .zero
    @State private var currentIndex: CGFloat = .zero

    var body: some View {
        GeometryReader {
            let size = $0.size
            let cardSize = size.width * 0.8

            LinearGradient(
                colors: [
                .clear,
                .brown.opacity(0.2),
                .brown.opacity(0.45),
                .brown
            ], 
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()

            HeaderView()

            VStack(spacing: 0) {
                ForEach(mainObserver.planets) { planet in
                    PlanetView(planet: planet, size: size)
                }
            }
            .frame(width: size.width)
            .padding(.top, size.height - cardSize)
            .offset(y: offsetY)
            .offset(y: -currentIndex * cardSize)
        }
        .coordinateSpace(name: "SCROLL")
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged({ value in
                    offsetY = value.translation.height * 0.4
                })
                .onEnded({ value in
                    let translation = value.translation.height
                    withAnimation(.easeInOut) {
                        if translation > 0 {
                            if currentIndex > 0 && translation > 250 {
                                currentIndex -= 1
                            }
                        } else {
                            if currentIndex < CGFloat(mainObserver.planets.count - 1) && -translation > 250 {
                                currentIndex += 1
                            }
                        }

                        offsetY = .zero
                    }
                })
        )
    }

    func HeaderView() -> some View {
        VStack {
            HStack {
                Spacer()
                Button{

                } label: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.foreground)
                }
            }

            GeometryReader {
                let size = $0.size

                HStack(spacing: 0) {
                    ForEach(mainObserver.planets) { planet in
                        VStack(spacing: 15) {
                            Text(planet.name ?? .planetEmptyName)
                                .font(.title.bold())
                                .multilineTextAlignment(.center)
                            Text(planet.radius?.toString ?? .squareEmptyName)
                        }
                        .frame(width: size.width)
                    }
                }
                .offset(x: currentIndex * -size.width)
                .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8), value: currentIndex)
            }
            .padding(.top, -5)
        }
        .padding(15)
    }
}

// MARK: - Preview

#Preview {
    PlanetsView()
        .environmentObject(MainObserver.mock)
}

// MARK: - Constants

private extension String {

    static let planetEmptyName = "Название не задано"
    static let squareEmptyName = "Радиус не известен"

}

// MARK: - Mock data

private extension [PlanetModel] {

    static let planets: [PlanetModel] = [
        .init(id: 0, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -100, y: -250)),
        .init(id: 1, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -100, y: -250)),
        .init(id: 2, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 350, y: 0)),
        .init(id: 3, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 100, y: 100)),
        .init(id: 4, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 100, y: 500)),
        .init(id: 5, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: 100, y: 0)),
    ]
}

private extension MainObserver {

    static var mock: MainObserver {
        let mock = MainObserver()
        mock.planets = .planets
        return mock
    }
}
