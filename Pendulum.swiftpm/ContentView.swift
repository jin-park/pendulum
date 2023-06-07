import SwiftUI

class Change: ObservableObject {
    @Published var x: Bool = false
    func toggle() {
        x.toggle()
    }
}

extension Change: Equatable {
    
    static func == (left: Change, right: Change) -> Bool {
        return left.x == right.x
    }
}

struct ContentView: View {
    //    @State private var started: Bool = false
    //    @State private var show: Bool = true
    @ObservedObject var parameters: ParametersList
    //    @State var changeVal: Int
    //    @State var x: Pendulum
    
    //    @StateObject var changed: Change = Change()
    @State var changed: Bool = false
    @State var started: Bool = false
    var body: some View {
        GeometryReader { geo in
            
            HStack {
                Pendulum(parameters: parameters, changed: $changed, height: geo.size.height, width: geo.size.width/2, started: $started)
                    .frame(width: geo.size.width/2)
                    .background(Color.white)
                    .onAppear {


                        changed.toggle()

                    }
                
                
                Controls(started: $started, parameters: parameters, changed: $changed)
                    .onChange(of: changed, perform: { _ in
                        //              
                        
                        
                    })
                    .onChange(of: started, perform: { _ in
                        //                            print("Hello, world!")
                        //                            x.update()
                        //                            changeVal += 1
                        if (started) {
                            //                                x.start()
                            //                                show.toggle()
                            //                                print(type(of: (0,0)))
                        } else {
                            //                                print("IS THIS EVEN WORKING")
                            //                                x.stop()
                        }
                    })
                
                
                
            }
            
            .background(Color.gray)
        }
        
    }
    
    init (_ p: ParametersList) {
        //        changeVal = 1
        //        x = Pendulum($changeVal)
        //        parameters = ParametersList([Parameters(id: 1, colors: [.red, .blue, .yellow], angles: [0.0, 0.0])])
        //        x = Pendulum(parameters: p)
        parameters = p
    }
}
