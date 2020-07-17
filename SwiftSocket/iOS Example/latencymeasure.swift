import Foundation
import SwiftSocket

var myseqno: Int64 = 999

struct pktheader {
    var seqno: Int64 = 0
    var timesent: UInt64 = 0
    var userbytes: Int64 = 0
    init(bytes: Int64) {
        seqno = myseqno
        timesent = getCurrentMillis()
        userbytes = bytes
     }
}

func getCurrentMillis() -> UInt64 {
    let mstill2020: UInt64 = (2020-1970)*365*24*60*60*1000
    let currmssince1970: UInt64 = UInt64(Date().timeIntervalSince1970*1000)
    var millisince2020: UInt64 = currmssince1970 - mstill2020
    
    // Just send 32bits, we can ignore the high order bits since the same time will
    // be sent back to us and we will use the same function to find the current time
    millisince2020 = millisince2020 & 0xFFFFFFFF
    return millisince2020
}

func createpktstring(pkt: pktheader, userstring: String) -> [Byte] {
    var mypkt = pkt
    let userstrsize = userstring.count
    let intsz = MemoryLayout.size(ofValue: mypkt.seqno)
    let uintsz = MemoryLayout.size(ofValue: mypkt.timesent)
    let pkthdrsize = MemoryLayout.size(ofValue: mypkt)
    var buffer = [Byte](repeating: 0, count: pkthdrsize + userstrsize)
    memcpy(&buffer[0], &mypkt.seqno, intsz)
    memcpy(&buffer[intsz], &mypkt.timesent, uintsz)
    memcpy(&buffer[2*intsz], &mypkt.userbytes, intsz)
    memcpy(&buffer[pkthdrsize], userstring, userstrsize)
    // print(buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7], buffer[8])
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
        
    @objc func fire() {

        let packet:pktheader = pktheader(bytes: Int64(userstring.count))

        let pkttosend = createpktstring(pkt: packet, userstring: userstring)
        if controller!.sendpacket(pkt2send: pkttosend, using: remoteclient) {
            //controller!.appendToTextField(string: "Sent packet\n")
            myseqno += 1
            print("Sent packet seqno, timesent: ", packet.seqno, packet.timesent)
        } else {
            controller!.appendToTextField(string: "Failed to Send packet\n")
        }
        
    }
}

class pktread {
    var remoteclient: TCPClient
    var controller: ViewController?
    var userstring: String = "Default"
        
    init(frequency: TimeInterval, string2: String, client: TCPClient) {
        remoteclient = client
        userstring = string2

        // Need to run the packet recv in a background threads dispatchqueue so main thread is
        // free to schedule timer for sending packet and interact with the user on UI
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
            backgroundQueue.async {
                print("Run Packet Receive on background thread")
                self.recv()
        }
    }
    
    func setController(viewcon: ViewController){
        controller = viewcon
    }
    
    var bool: Bool = true
        
    func recv() {
        while(self.bool == true) {
            var seqno: Int64 = 0
            var timesent: UInt64 = 0
            var rtt: UInt64 = 0
            var userstringsz: Int64 = 0
            let intsz = MemoryLayout.size(ofValue: seqno)
            
            guard
                let pktstr:[Byte] = (self.controller?.readResponse(client: self.remoteclient, len: intsz*3 + userstring.count))!
            else {
                bool = false
                return
            }
            //print("Got Packet: ", pktstr[0], pktstr[1], pktstr[2], pktstr[3], pktstr[4], pktstr[5], pktstr[6], pktstr[7], pktstr[8])
            
            
            seqno = convertbytestoint(arr: pktstr, startIndex: 0, len: intsz)
            timesent = UInt64(convertbytestoint(arr: pktstr, startIndex: intsz, len: intsz))
            let currtime: UInt64 = getCurrentMillis()
            rtt = currtime - timesent
            userstringsz = convertbytestoint(arr: pktstr, startIndex: 2*intsz, len: intsz)
            //seqno1 - seqno.littleEndian
            //seqno2 = Int64(NSSwapBigLongLongToHost(UInt64(seqno)))
            print("Received Packet Seqno, timesent, rtt: ", seqno, timesent, rtt)
            let string1 = convertbytestostring(arr: pktstr, startIndex: 3*intsz, len: Int(userstringsz))
            
            // Not allowed to print to UI from background thread dispatchqueue so we have to
            // schedule this action on the main thread dispatchqueue
            DispatchQueue.main.async(execute: {
                self.controller!.PrintRecvPacketInfo(seqno: seqno, rtt: rtt, userstr: string1)
            })
        }
    }
}

func convertbytestoint(arr: [Byte], startIndex: Int, len: Int) -> Int64 {
    var buffer = [Byte](repeating: 0, count: len)
    for i in 0...len - 1 {
        buffer[i] = arr[startIndex + i]
    }
    var value: Int64 = 0

    for byte in buffer {
        value <<= 8
        value |= Int64(byte)
    }

    return value
}

func convertbytestostring(arr: [Byte], startIndex: Int, len: Int) -> String {
    var buffer = [Byte](repeating: 0, count: len)
    for i in 0...len - 1 {
        buffer[i] = arr[startIndex + i]
    }
    let str = String(bytes: buffer, encoding: .utf8) ?? "Couldn't Read Custom String"
    return str
}
