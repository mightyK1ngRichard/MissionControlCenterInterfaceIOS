//
//  Test.swift
//  SpaceStation
//
//  Created by Dmitriy Permyakov on 28/10/2023.
//

import SwiftUI

struct Test: View {
    @State private var currentAmmount: CGFloat = .zero

    var body: some View {
        VStack(spacing: 0) {

        }
        .onAppear(perform: FetchData)
    }
}

private extension Test {

    func FetchData() {
        NetworkService.shared.request(
            router: .station,
            method: .get,
            type: StationStateEntity.self,
            parameters: nil
        ) { result in
            switch result {
            case .success(let info):
                print(info)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    Test()
}
