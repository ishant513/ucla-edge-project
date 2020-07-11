import Foundation
import SwiftSocket

var myseqno: Int = 99

struct pktheader {
    var seqno: Int = 0
    var timesent: Int = 0
    var userbytes: Int = 0
    init(bytes: Int) {
        seqno = myseqno
        myseqno += 1
        timesent = 1111
        userbytes = bytes
    }
}

func createpktstring(pkt: pktheader, userstring: String) -> String {
    var mypkt = pkt
    let mydata = Data(bytes: &mypkt, count: MemoryLayout<ContiguousBytes>.size)
    let string = String(data: mydata, encoding: .utf16) ?? "No Input"
    let stringtosend = string + userstring
    return stringtosend
}

class timeloop {
    var flag: Int = 0
    var userstring: String = "Default"
    var remoteclient: TCPClient
    var controller: ViewController
        
    init(frequency: TimeInterval, string2: String, client: TCPClient) {
        userstring = string2 + "\n"
        remoteclient = client
        let timer = frequency/1000
        _ = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    func setController(viewcon: ViewController){
        controller = viewcon
    }

        
    func printer() {
        print("Got it again\n")
    }
        
    @objc func fire() {
        print("in loop\n")

        var packet:pktheader {
            get {
                return pktheader(bytes: userstring.utf16.count)
            }
        }
        var uinput: String{
            get {
                createpktstring(pkt: packet, userstring: userstring)
            }
        }
        if let response = controller.sendRequest(stringtossend: uinput, using: remoteclient) {
            controller.appendToTextField(string: "Got it\n")
            controller.appendToTextField(string: "Response: \(response)")
        }
        if let response1 = controller.sendRequest(stringtossend: "\n", using: remoteclient) {
            controller.appendToTextField(string: "Got it again\n")
            controller.appendToTextField(string: "Response: \(response1)")
        }
        
    }
}
