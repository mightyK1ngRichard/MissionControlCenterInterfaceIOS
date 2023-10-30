//
//  DynamicRectangle.swift
//  Vikings
//
//  Created by Dmitriy Permyakov on 28/10/2023.
//

import SwiftUI

struct DynamicRectangle: View {
    @EnvironmentObject var mainObserver: MainObserver
    @State private var rotatino: CGFloat = .zero
    let title: String!

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous)
                .frame(width: .rectWidth, height: .rectHeight)
                .foregroundStyle(Color.strokeColor)
                .rotationEffect(.degrees(rotatino))
                .mask {
                    RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous)
                        .stroke(lineWidth: .lineWidth)
                        .frame(width: .maskWidth, height: .maskHeight)
                }
            
            Text(title)
                .font(.title)
                .foregroundStyle(Color.strokeColor)
                .bold()
        }
        .task {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                rotatino = .rotation
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DynamicRectangle(title: "Начать\nуправление")
        .environmentObject(MainObserver())
}

#Preview {
    ContentView()
        .environmentObject(MainObserver())
}

// MARK: - Constants

private extension Color {

    static let backgroundColor: Self = .clear
    static let strokeColor: LinearGradient = .init(
        colors: [Color.mint, .blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

private extension CGFloat {

    static let cornerRadius: CGFloat = 20
    static let rotation: CGFloat = 360
    static let lineWidth: CGFloat = 7

    static let rectWidth: CGFloat = 130
    static let maskWidth: CGFloat = 286
    static let rectHeight: CGFloat = 360
    static let maskHeight: CGFloat = 210
}
