//
//  ContentView.swift
//  teslaMote
//
//  Created by Tobias Lüscher on 07.06.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        Text("Hello World")
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
