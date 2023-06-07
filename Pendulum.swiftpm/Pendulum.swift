import SwiftUI
import Combine
import Charts

struct Data: Identifiable, Hashable {
    var id: UUID
    var x, y: Double
    init(_ x: Double, _ y: Double) {
        id = UUID()
        self.x = x
        self.y = y
    }
}

extension Data: Equatable {
    static func == (l: Data, r: Data) -> Bool {
        return l.x == r.x && l.y == r.y
    }
}

struct Pendulum: View {
    @State private var offset = CGSize.zero
    @State private var direction = true
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var cancellable: AnyCancellable? = nil
    //    @EnvironmentObject var parameters: ParametersList
    @ObservedObject var parameters: ParametersList
    
    //    @State var helpers: [PendulumHelper] = [PendulumHelper(Parameters(id: 1, colors: [.red, .black, .black], angles: [0.0, 0.0]))]
    @State var helpers: HelperList = HelperList()
    @State var counter: Double = 0.0
    @State var isRunning: Bool = false
    @Binding var changed: Bool
    var height, width: Double
    @Binding var started: Bool
    @State var newCoords: [[Data]] = []
    
    
    //    @Binding var changeValue: Int
    var body: some View {
        Chart {
            
            ForEach(helpers.list, id: \.self) { helper in
                let coords = newCoords[helper.id-1]
                LineMark(x: .value("X", 0), y: .value("HEllo", 100))
                    .foregroundStyle(helper.colors[2])
                LineMark(x: .value("X1", coords[0].x), y: .value("Y1", 100-coords[0].y))
                    .foregroundStyle(helper.colors[2])
                LineMark(x: .value("X2", coords[1].x), y: .value("Y2", 100-coords[1].y))
                    .foregroundStyle(helper.colors[2])
                LineMark(x: .value("X1", coords[0].x), y: .value("Y1", 100-coords[0].y))
                    .foregroundStyle(helper.colors[2])
                LineMark(x: .value("X", 0.0), y: .value("HEllo", 100.0))
                    .foregroundStyle(helper.colors[2])
            }
            ForEach(helpers.list, id: \.self) { helper in
                let coords = newCoords[helper.id-1]
                PointMark(x: .value("X", coords[0].x), y: .value("HEllo", 100-coords[0].y))
                    .foregroundStyle(helper.colors[0])
                    .symbolSize(400.0)
                PointMark(x: .value("X", coords[1].x), y: .value("HEllo", 100-coords[1].y))
                    .foregroundStyle(helper.colors[1])
                    .symbolSize(400.0)
                PointMark(x: .value("X", 0), y: .value("HEllo", 100))
                    .foregroundStyle(Color.black)
                //                    .foregroundStyle(helper.colors[1])
                
            }
            //
            //            ForEach(helpers.list, id: \.self) { helper in
            //                PointMark(x: .value("X", counter), y: .value("Y", helper.getAngle()))
            //            }
            
            
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        //        .frame(height: width)
        .chartYScale(domain: -500...500)
        //        .chartYScale(domain: -1...1)
        .chartXScale(domain: -300...300)
        // x: -200 ~ 200 y: -300...300
        .onChange(of: parameters, perform: { _ in
            var newHelperList: [PendulumHelper] = []
            for par in parameters.paramList {
                newHelperList.append(PendulumHelper(par))
            }
            helpers.list = newHelperList
        })
        .onChange(of: started, perform: { _ in
            if (started) {
                start()

            } else {
                stop()
            }

        })
        .onChange(of: changed, perform: { _ in
            var newHelperList: [PendulumHelper] = []
            for par in parameters.paramList {
                newHelperList.append(PendulumHelper(par))
            }
            helpers.list = newHelperList
            
            var newc: [[Data]] = []
            for helper in helpers.list {
                newc.append(helper.getPoints())
            }
            newCoords = newc
            
            //            print(helpers.list)
            //            print(parameters.paramList)
        })
        .onReceive(timer) { time in
            if (isRunning) {
                //                let k = helpers.list[0].update(t: counter, dt: 0.01)
                for i in 0..<helpers.list.count {
                    let _ = helpers.list[i].update(t: counter, dt: 0.01)
                }
                var newc: [[Data]] = []
                for helper in helpers.list {
                    newc.append(helper.getPoints())
                }
                newCoords = newc
                //                print(k)
                counter += 0.01
            }
            
        }
        //        .chartXScale(domain: 0...400)
        
    }
    
    func update(_ p: [Parameters]) {
        parameters.paramList = p
        var newHelperList: [PendulumHelper] = []
        for par in parameters.paramList {
            newHelperList.append(PendulumHelper(par))
        }
        
        
        helpers.list = newHelperList
        var newc: [[Data]] = []
        for helper in helpers.list {
            newc.append(helper.getPoints())
        }
        newCoords = newc
    }
    
    func start() {
        isRunning = true

        
        var newHelperList: [PendulumHelper] = []
        for par in parameters.paramList {
            newHelperList.append(PendulumHelper(par))
        }
        helpers.list = newHelperList
        counter = 0.0
        
        var newc: [[Data]] = []
        for helper in helpers.list {
            newc.append(helper.getPoints())
        }
        newCoords = newc
        self.isRunning = true
    }
    
    func stop() {
        self.isRunning = false

    }
}
