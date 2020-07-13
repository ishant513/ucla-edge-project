import Foundation
import SwiftSocket

var myseqno: Int64 = 10

struct pktheader {
    var seqno: Int64 = 0
    var timesent: Int64 = 0
    var userbytes: Int64 = 0
    init(bytes: Int64) {
        seqno = myseqno
        myseqno += 1
        timesent = 5
        userbytes = bytes
        print(seqno, timesent, userbytes)
    }
}

func createpktstring(pkt: pktheader, userstring: String) -> [Byte] {
    var mypkt = pkt
    let userstrsize = userstring.count
    let intsz = MemoryLayout.size(ofValue: mypkt.seqno)
    print("intsz = ", intsz)
    let pkthdrsize = MemoryLayout.size(ofValue: mypkt)
    var buffer = [Byte](repeating: 0, count: pkthdrsize + userstrsize)
    memcpy(&buffer[0], &mypkt.seqno, intsz)
    memcpy(&buffer[intsz], &mypkt.timesent, intsz)
    memcpy(&buffer[2*intsz], &mypkt.userbytes, intsz)
    memcpy(&buffer[pkthdrsize], userstring, userstrsize)
    print(buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7], buffer[8])
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
                return pktheader(bytes: Int64(userstring.count))
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
