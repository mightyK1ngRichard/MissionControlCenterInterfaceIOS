//
//  PlanetView.swift
//  SpaceStation
//
//  Created by Dmitriy Permyakov on 28/10/2023.
//

import SwiftUI

struct PlanetView: View {
    var planet: PlanetModel
    var size: CGSize

    var body: some View {
        let cardSize = size.width * 0.8

        let maxCardsDisplaySize = size.width * 3

        GeometryReader {
            let _size = $0.size
            let offset = $0.frame(in: .named("SCROLL")).minY - (size.height - cardSize)
            let scale = offset <= 0 ? (offset / maxCardsDisplaySize) : 0
            let reducedScale = 1 + scale
            let currentSizeScale = offset / cardSize

            let imageSize = CGSize(edge: $0.size.width * 0.8)
            MKRImageView(
                configuration: .basic(
                    kind: .custom(
                        url: planet.imageURL,
                        mode: .fit,
                        imageSize: imageSize,
                        imageCornerRadius: imageSize.width / 2,
                        shimmerSize: CGSize(width: imageSize.width, height: imageSize.width * 0.5),
                        placeholderImageSize: 40
                    )
                )
            )
            .frame(width: _size.width, height: _size.height)
            .scaleEffect(
                reducedScale < 0
                ? 0.001
                : reducedScale, anchor: .init(
                    x: 0.5,
                    y: 1 - (currentSizeScale / 2.4)
                )
            )
            .scaleEffect(offset > 0 ? 1 + currentSizeScale : 1, anchor: .top)
            .offset(y: offset > 0 ? currentSizeScale * 200 : 0)
            .offset(y: currentSizeScale * -130)

        }
        .frame(height: cardSize)
    }
}

// MARK: - Preview

#Preview {
    PlanetView(planet: .mockPlanet, size: CGSize(edge: 600))
}

// MARK: - Mock Data

private extension PlanetModel {

    static var mockPlanet = PlanetModel(id: 0, name: "Планета 1", description: nil, discoveryDate: nil, imageURL: .saturn, radius: nil, mass: nil, coordinates: .init(x: -100, y: -250))
}
