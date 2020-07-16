import Foundation
import SwiftSocket

var myseqno: Int64 = 999

struct pktheader {
    var seqno: Int64 = 0
    var timesent: Int64 = 0
    var userbytes: Int64 = 0
    init(bytes: Int64) {
        seqno = myseqno
        myseqno += 1
        timesent = getCurrentMillis()
        userbytes = bytes
        print(seqno, timesent, userbytes)
    }
}

func getCurrentMillis() -> Int64 {
    return Int64(Date().timeIntervalSince1970*1000)
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
        userstring = string2
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
            controller!.appendToTextField(string: "Failed to Send packet\n")
        }
        
    }
}

class pktread{
    var remoteclient: TCPClient
    var controller: ViewController?
    var userstring: String = "Default"
        
    init(frequency: TimeInterval, string2: String, client: TCPClient) {
        remoteclient = client
        userstring = string2
        //let timer = frequency/1000
        //  _ = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(recv), userInfo: nil, repeats: false)
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
            backgroundQueue.async {
                print("Run on background thread")
                self.recv()
        }
    }
    
    func setController(viewcon: ViewController){
        controller = viewcon
    }
    
    var bool: Bool = true
        
    //@objc
    func recv() {
        while(self.bool == true) {
            //var pktstr:[Byte] = remoteclient.read(24 + userstring.count)!
            print("Trying to Get packet")
            var seqno: Int64 = 0
            var seqno1: Int64 = 0
            var seqno2: Int64 = 0
            var timesent: Int64 = 0
            var userstringsz: Int64 = 0
            let intsz = MemoryLayout.size(ofValue: seqno)
            var pktstr:[Byte] = self.controller!.readResponse(client: self.remoteclient, len: intsz*3 + userstring.count)!
            print("Got Packet: ", pktstr[0], pktstr[1], pktstr[2], pktstr[3], pktstr[4], pktstr[5], pktstr[6], pktstr[7], pktstr[8])
            var data = Data(bytes: pktstr, count: 24)
            memcpy(&data[0], &seqno, intsz)
            memcpy(&pktstr[intsz], &timesent, intsz)
            memcpy(&pktstr[intsz*2], &userstringsz, intsz)
            seqno1 = seqno.littleEndian
            seqno2 = Int64(NSSwapBigLongLongToHost(UInt64(seqno)))
            print("Seqno: ", seqno, seqno1, seqno2)
            //userstringsz = userstringsz.littleEndian
            var pktbyte = [Byte](repeating: 0, count: userstring.count)
            memcpy(&pktbyte[0], &pktstr[24], userstring.count)
            let string1 = String(bytes: pktbyte, encoding: .utf8)
            //let start = String.Index(utf16Offset: 24, in: pktstr)
            //let end = String.Index(utf16Offset: 24 + userstring.count, in: pktstr)
            //let substring = String(pktstr[start..<end])
            //let string1 = String(bytes: pktstr, encoding: .utf8)
            DispatchQueue.main.async(execute: {
                //print("Got Packet Back: ", seqno, timesent, userstringsz)
                print(pktstr[0], pktstr[1], pktstr[2], pktstr[3], pktstr[4], pktstr[5], pktstr[6], pktstr[7], pktstr[8])
                print(seqno, seqno1, seqno2)
                let str2 = "Got Packet Back "
                self.controller?.appendToTextField(string: str2)
            })
        }
    }
}
