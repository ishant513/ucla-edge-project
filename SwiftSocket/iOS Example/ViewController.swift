import UIKit
import SwiftSocket

class ViewController: UIViewController {
  
    @IBOutlet weak var textView: UITextView!
    
    var host:String = "localhost"
    let port = 9000
    var client: TCPClient?
    var runtimer: timeloop?
    var connected: Bool = false
    var runtest: Bool = false
    var packetread:pktread?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        client = TCPClient(address: host, port: Int32(port))
    }
    
    @IBOutlet weak var frequency: UITextField!
    
    var inputtedtime: TimeInterval = 500
    
    @IBAction func getTimeInt() {
        inputtedtime = (frequency.text! as NSString).doubleValue
        if (inputtedtime < 100) {
            inputtedtime = 100
        }
        if (inputtedtime > 1000) {
            inputtedtime = 1000
        }
    }
    
    // var time:TimeInterval
    
    // init(time: TimeInterval, since date: Date) {
    //    self.time = inputtedtime
    //    super.init(nibName: nil, bundle: nil)
    //}
    
    @IBOutlet weak var ipAddress:UITextField!
    
    @IBAction func getIP(){
        host = ipAddress.text ?? "localhost"
    }
    
    lazy var string2: String = "Custom String"
 
    //our label to display input
    @IBOutlet weak var labelName: UILabel!
    
    //this is the text field we created
    @IBOutlet weak var textFieldName: UITextField!
    
    @IBAction func buttonClick(sender: UIButton) {
        //getting input from Text Field
        string2 = textFieldName.text!
        
        //Displaying input text into label
        labelName.text = string2
    }
    
    @IBAction func connectButtonAction() {
        guard let client = client else { return }
        switch client.connect(timeout: 10) {
        case .success:
            connected = true
            appendToTextField(string: "Connected to host \(client.address)")
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
    }
  
    
    
    func sendpacket(pkt2send: [Byte], using client: TCPClient) -> Bool {
        //appendToTextField(string: "Sending data ... ")
        switch client.send(data: pkt2send) {
        case .success:
            return true
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return false
        }
    }
  
    func readResponse(client: TCPClient, len: Int) -> [Byte]? {
        guard let response = client.read(len) else { return nil }
        return response
    }

    func appendToTextField(string: String) {
        textView.text = textView.text.appending("\n\(string)")
    }
    
    func PrintRecvPacketInfo(seqno: Int64, rtt: UInt64, userstr: String) {
        let str1 = String(seqno)
        let str2 = String(rtt)
        let str3 = "Seq# " + str1 + ", RTT: " + str2 + ", Custom String: " + userstr
        textView.text = textView.text.appending("\n\(str3)")
    }
    
    @IBAction func TestStart(_ sender: Any) {
        if (connected != true) {
            appendToTextField(string: "You need to connect first")
        } else {
            runtest = true
            runtimer = timeloop.self(frequency: inputtedtime, string2: string2, client: client!)
            runtimer?.setController(viewcon: self)
            packetread = pktread.self(frequency: 1000, string2: string2, client: client!)
            packetread?.setController(viewcon: self)
        }
    }
    
    @IBAction func stopButtonClick(sender: UIButton){
        
    }

}
