import SwiftUI

@main
struct MyApp: App {
    @StateObject var paramlist = ParametersList([Parameters(id: 1, colors: [.black, .black, .black], angles: [0.0, 0.0])])
    var body: some Scene {
        WindowGroup {
            ContentView(paramlist)
        }
    }
}
