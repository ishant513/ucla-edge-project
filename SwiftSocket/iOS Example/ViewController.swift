import UIKit
import SwiftSocket

class ViewController: UIViewController {
  
    @IBOutlet weak var textView: UITextView!
    
    var host:String = "localhost"
    let port = 9000
    var client: TCPClient?
    var runtimer: timeloop?
    var runtest: Bool = false

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
    
    lazy var string2: String = "Hi"
 
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
        appendToTextField(string: "Connected to host \(client.address)")
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
    }
  
    func sendRequest(stringtossend: String, using client: TCPClient) -> String? {
        appendToTextField(string: "Sending data ... ")
        appendToTextField(string: stringtossend)
        switch client.send(string: stringtossend) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return nil
        }
    }
    
    func sendpacket(pkt2send: [Byte], using client: TCPClient) -> Bool {
        appendToTextField(string: "Sending data ... ")
        switch client.send(data: pkt2send) {
        case .success:
            return true
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return false
        }
    }
  
    func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
    
        return String(bytes: response, encoding: .utf16)
    }

    func appendToTextField(string: String) {
        print(string)
        textView.text = textView.text.appending("\n\(string)")
    }
    
    @IBAction func TestStart(_ sender: Any) {
        appendToTextField(string: "Got it again\n")
        runtest = true
        runtimer = timeloop.self(frequency: inputtedtime, string2: string2, client: client!)
        runtimer?.setController(viewcon: self)
    }
    
    @IBAction func stopButtonClick(sender: UIButton){
        
    }

}
