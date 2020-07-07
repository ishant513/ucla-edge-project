import Foundation

struct pktheader {
    var seqno: Int64 = 0
    var timesent: Int64 = 0
    var userbytes: Int64 = 0
}

func createpktstring(pkt: pktheader, userstring: String) -> String {
    var mypkt = pkt
    let mydata = Data(bytes: &mypkt, count: MemoryLayout<ContiguousBytes>.size)
    let string = String(data: mydata, encoding: .utf8) ?? "No Input"
    let stringtosend = string + userstring
    return stringtosend
}
