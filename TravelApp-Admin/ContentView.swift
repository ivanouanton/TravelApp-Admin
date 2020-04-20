//
//  ContentView.swift
//  TravelApp-Admin
//
//  Created by Антон Иванов on 4/16/20.
//  Copyright © 2020 companyName. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var showDetails = false
    var body: some View {
        VStack {
            Button(action: {
                self.showDetails.toggle()
//                PlaceManager.shared.getDPImages(with: UIHostingController(rootView: self))
//                PlaceManager.shared.parseExel()
            }) {
                Text("Show details")
            }

            if showDetails {
                Text("You should follow me on Twitter: @twostraw")
                    .font(.largeTitle)
                    .lineLimit(nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
    }
}
