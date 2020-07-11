import Foundation

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

