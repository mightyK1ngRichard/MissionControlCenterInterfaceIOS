//
//  LottieView.swift
//  SpaceStation
//
//  Created by Dmitriy Permyakov on 29/10/2023.
//

import SwiftUI
import Lottie

struct LottieViewScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            LottieView(lottieFile: "space")
                .frame(width: 300, height: 300)
        }
    }
}

#Preview {
    LottieViewScreen()
}

struct LottieView: UIViewRepresentable {
    let lottieFile: String

    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)

        animationView.animation = LottieAnimation.named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        view.addSubview(animationView)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}
