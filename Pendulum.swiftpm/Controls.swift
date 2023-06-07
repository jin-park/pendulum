import SwiftUI

struct Parameters: Identifiable {
    var id: Int
    var colors: [Color] // 3 colors: background, mass 1, mass 2
    var angles: [Double] // Angles 1 and 2

}

class ParametersList: ObservableObject {
    @Published var paramList: [Parameters]
    init(_ p: [Parameters]) {
        paramList = p
    }
}

extension ParametersList: Equatable {
    static func == (left: ParametersList, right: ParametersList) -> Bool {
        return left.paramList == right.paramList
    }
}

extension Parameters: Equatable {
    static func == (left: Parameters, right: Parameters) -> Bool {
        return left.id == right.id && left.colors == right.colors && left.angles == right.angles
    }
}

struct Controls: View {
    @State private var selected = Color.blue
    @State private var sliderValue = 10.0
    @State private var numPendulums: Int = 1
    @State private var mode = "Show trail"
    @Binding var started: Bool
    
    @ObservedObject var parameters: ParametersList
    @Binding var changed: Bool
    var something: Bool = false
    
    @State private var pendulums: [Int] = [1]
    @State private var selectedPendulum = 1
    
    var body: some View {
        VStack {
            
            HStack {
                Stepper(value: $numPendulums, in: 1...5, label: {
                    Text("Number of pendulums: \(numPendulums)")
                }, onEditingChanged: { _ in
                    if (numPendulums > pendulums.count) {
                        
                        pendulums.append(numPendulums)
                        parameters.paramList.append(Parameters(id: numPendulums, colors: [.black, .black, .black], angles: [0.0, 0.0]))
                        var newList: [Parameters] = []
                        for param in parameters.paramList {
                            newList.append(param)
                            
                        }
                        print(parameters.paramList)
                        //                        params = ParametersList(newList)
                    } else if (numPendulums < pendulums.count) {
                        //                        let temp = selectedPendulum
                        if (selectedPendulum != pendulums.count) {
                            pendulums.remove(at: selectedPendulum)
                        } else {
                            selectedPendulum -= 1
                            pendulums.remove(at: pendulums.count-1)
                        }
                        parameters.paramList.remove(at: selectedPendulum-1)
                        
                    }
                })
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5.0)
                        .foregroundColor(Color.white)
                )
                
                Picker("Pendulum #\(selectedPendulum)", selection: $selectedPendulum) {
                    ForEach(pendulums, id: \.self) {
                        Text("#\($0)")
                    }
                }
                .tint(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5.0)
                        .foregroundColor(Color.white)
                )
            }
            .disabled(started)
            .opacity(started ? 0.5 : 1.0)
            
            
            
            Group {
                HStack {
                    
                    ColorPicker(selection: $parameters.paramList[selectedPendulum-1].colors[0]) {
                        Text("Mass #1")
                    }
                    .onChange(of: parameters.paramList[selectedPendulum-1].colors[0], perform: { _ in

                        changed.toggle()
                    })
                    
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10.0)
                            .foregroundColor(.white)
                    )
                    
                    ColorPicker(selection: $parameters.paramList[selectedPendulum-1].colors[1]) {
                        Text("Mass #2")
                    }
                    .onChange(of: parameters.paramList[selectedPendulum-1].colors[1], perform: { _ in

                        changed.toggle()
                    })
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10.0)
                            .foregroundColor(.white)
                    )
                    
                    ColorPicker(selection: $parameters.paramList[selectedPendulum-1].colors[2]) {
                        Text("Rods")
                    }
                    .onChange(of: parameters.paramList[selectedPendulum-1].colors[2], perform: { _ in

                        changed.toggle()
                    })
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10.0)
                            .foregroundColor(.white)
                    )
                    
                }
                
                HStack {
                    HStack {
                        Text("Angle #1: \(Int(parameters.paramList[selectedPendulum-1].angles[0]))º")
                        
                        Slider(value: $parameters.paramList[selectedPendulum-1].angles[0], in: 0...180)
                            .onChange(of: parameters.paramList[selectedPendulum-1].angles[0], perform: { _ in

                                changed.toggle()
                            })
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 5.0)
                            .foregroundColor(Color.white)
                    )
                    
                    HStack {
                        Text("Angle #2: \(Int(parameters.paramList[selectedPendulum-1].angles[1]))º")
                        Slider(value: $parameters.paramList[selectedPendulum-1].angles[1], in: 0...180)
                            .onChange(of: parameters.paramList[selectedPendulum-1].angles[1], perform: { _ in

                                changed.toggle()
                            })
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 5.0)
                            .foregroundColor(Color.white)
                    )
                }
            }
            .disabled(started)
            .opacity(started ? 0.5 : 1.0)
            
            
            
            Group {
                HStack {
                    
                    Button(action: {
                        started.toggle()
                    }, label: {
                        ZStack {
                            Text("\(started ? "Stop" : "Start")")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(Color.white)
                                    
                                )
                        }
                    })
                    
//                    Button(action: {
//                        print("Hello, world!")
//                    }, label: {
//                        Text("Learn More!")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .foregroundColor(.black)
//                            .background(
//                                RoundedRectangle(cornerRadius: 10.0)
//                                    .fill(Color.white)
//                            )
//                    })
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10.0)
                .padding()
                .foregroundColor(.gray)
        )
        .onChange(of: parameters, perform: { _ in
            print("HELLO?")
        })
    }
    
    
}
