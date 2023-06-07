import Foundation
import Accelerate
import SwiftUI


func dotadd(_ x: [Double], _ y: [Double]) -> [Double] {
    var z: [Double] = []
    for i in 0..<x.count {
        z.append(x[i] + y[i])
    }
    return z
}

func mul(_ x: [Double], _ y: Double) -> [Double] {
    var z: [Double] = x
    for i in 0..<x.count {
        z[i] *= y
    }
    return z
}

struct PendulumHelper: Hashable {
    //    var parameters: [Double]
    var yglobal: [Double]
    var parameter = [1.5, 2.0, 3.0, 2.0] // L1, L2, m1, m2
    var colors: [Color]
    var id: Int
    var created: Date
    //    var param: Parameters
    
    init(_ p: Parameters) {
        //        param = p
        let conversion = Double.pi/180
        yglobal = [0.0, 0.0, p.angles[0]*conversion, p.angles[1]*conversion]
        //        yglobal = [0.0, 0.0, Double.pi/4, Double.pi/4]
        // do something...
        //        self.p = p
        colors = p.colors
        id = p.id
        created = Date()
    }
    
    mutating func update(t: Double, dt: Double) -> [Double] { // Updates the angles and returns the 4 dimensional vector
        self.yglobal = dotadd(yglobal, rk4(y: yglobal, t: t, dt: dt))
        //        print(yglobal)
        return yglobal
    }
    
    mutating func updateParam(_ p: Parameters) {
        yglobal = [0.0, 0.0, p.angles[0], p.angles[1]]
        
    }
    
    // derivative of vector [theta_dot, theta], where theta is the angle and theta_dot is the derivative (angular velocity)
    func slope(y: [Double], t: Double) -> [Double] {
        let t1d: Double = y[0], t2d: Double = y[1],
            t1: Double = y[2], t2: Double = y[3]
        
        // parameters like masses and the lengths of the rods connecting the spheres
        let L1: Double = parameter[0], L2: Double = parameter[1],
            m1: Double = parameter[2], m2: Double = parameter[3]
        let g: Double = 9.8
        
        // equations of motion for the Double pendulum
        let f1: Double = -m2 * L2 * t2d * t2d * sin(t1 - t2) - (m1 + m2) * g * sin(t1)
        let f2: Double = L1 * t1d * t1d * sin(t1 - t2) - g * sin(t2)
        let f: [Double] = [f1, f2]
        
        let m11: Double = (m1 + m2) * L1
        let m12: Double = m2 * L2 * cos(t1 - t2)
        let m21: Double = L1 * cos(t1 - t2)
        let m22: Double = L2
        //        let m: [Double] = [m11, m12, m21, m22]
        
        // INVERT THE MATRIX
        let m_inv = mul([m22, -m12, -m21, m11], 1/(m11 * m22 - m12 * m21))
        // F = ma -> a = F/m
        var tdd: [Double] = [0.0, 0.0]
        let a = Int32(2)
        let b = Int32(1)
        let c = Int32(2)
        vDSP_mmulD(
            m_inv, vDSP_Stride(1),
            f, vDSP_Stride(1),
            &tdd, vDSP_Stride(1),
            vDSP_Length(a),
            vDSP_Length(b),
            vDSP_Length(c)
        )
        return [tdd[0], tdd[1], t1d, t2d]
    }
    
    // performs a single step of the runge kutta method
    func rk4(y: [Double], t: Double, dt: Double) -> [Double] {
        
        // HAVE TO TYPE ANNOTATE EVERYTHING - OTHERWISE THE COMPILE TIME IS TOO LONG :(
        let k1: [Double] = slope(y: y, t: t)
        let k2: [Double] = slope(y: dotadd(y, mul(k1, 0.5 * dt)), t: t + 0.5 * dt)
        let k3: [Double] = slope(y: dotadd(y, mul(k2, 0.5 * dt)), t: t + 0.5 * dt)
        let k4: [Double] = slope(y: dotadd(y, mul(k3, dt)), t: t + dt)
        let answer: [Double] = dotadd(dotadd(k1, mul(k2, 2)), dotadd(mul(k3, 2), k4))
        
        return mul(answer, dt / 6)
    }
    
    func getPoints() -> [Data] {
        let offset: (Double, Double) = (0.0, 100.0)
        let scale = 100.0
        //        let conversion = Double.pi / 180
        let conversion = 1.0
        let x1: Double = parameter[0] * sin (yglobal[2] * conversion) * scale + offset.0
        let y1: Double = parameter[0] * cos (yglobal[2] * conversion) * scale + offset.1
        return [Data(x1, y1), Data(x1 + parameter[1] * sin (yglobal[3] * conversion) * scale, y1 + parameter[1] * cos (yglobal[3] * conversion) * scale)]
        //        return [Data(0, yglobal[2]), Data(0, yglobal[3])]
    }
    
    func getAngle() -> Double {
        return sin(yglobal[2])
    }
}

class HelperList: ObservableObject {
    @Published var list: [PendulumHelper]
    
    init() {
        list = []
    }
    
    init(_ p: [PendulumHelper]) {
        list = p
    }
}
