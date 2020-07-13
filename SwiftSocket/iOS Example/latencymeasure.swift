import Foundation
import SwiftSocket

var myseqno: Int = 999

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

func createpktstring(pkt: pktheader, userstring: String) -> [Byte] {
    var mypkt = pkt
    let pkthdrsize = MemoryLayout.size(ofValue: mypkt)
    let userstrsize = userstring.count
    print(userstrsize)
    var buffer = [Byte](repeating: 0, count: pkthdrsize + userstrsize)
    memcpy(&buffer[0], &mypkt, pkthdrsize)
    memcpy(&buffer[pkthdrsize + 1], userstring, userstrsize)
    return buffer
}

class timeloop {
    var flag: Int = 0
    var userstring: String = "Default"
    var remoteclient: TCPClient
    var controller: ViewController?
        
    init(frequency: TimeInterval, string2: String, client: TCPClient) {
        userstring = string2 + "\n"
        remoteclient = client
        let timer = frequency/1000
          _ = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(fire), userInfo: nil, repeats: false)
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
                return pktheader(bytes: userstring.count)
            }
        }
        let pkttosend = createpktstring(pkt: packet, userstring: userstring)
        if controller!.sendpacket(pkt2send: pkttosend, using: remoteclient) {
            controller!.appendToTextField(string: "Sent packet\n")
        } else {
            controller!.appendToTextField(string: "Failed tp Send packet\n")
        }
        
    }
}
