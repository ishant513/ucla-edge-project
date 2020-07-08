import Foundation

var myseqno: Int64 = 1

struct pktheader {
    var seqno: Int64 = 0
    var timesent: Int = 0
    var userbytes: Int = 0
    init(sequence: Int64, sendtime: Int, bytes: Int) {
        seqno = sequence
        timesent = sendtime
        userbytes = bytes
    }
}

func createpktstring(pkt: pktheader, userstring: String) -> String {
    var mypkt = pkt
    let mydata = Data(bytes: &mypkt, count: MemoryLayout<ContiguousBytes>.size)
    let string = String(data: mydata, encoding: .utf8) ?? "No Input"
    let stringtosend = string + userstring
    return stringtosend
}

var string2: String = "Hi"
var packet = pktheader(sequence: myseqno, sendtime: 0, bytes: string2.utf8.count)
let str = createpktstring(pkt: packet, userstring: string2)

