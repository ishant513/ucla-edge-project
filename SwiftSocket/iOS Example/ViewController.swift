import UIKit
import SwiftSocket

class ViewController: UIViewController {
  
    @IBOutlet weak var textView: UITextView!
    
    var host:String = "localhost"
    let port = 9000
    var client: TCPClient?
    var runtimer: looper?
    var runtest: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    
        client = TCPClient(address: host, port: Int32(port))
    }
    
    @IBOutlet weak var frequency: UITextField!
    
    var inputtedtime: TimeInterval = 0.0
    
    @IBAction func getTimeInt(){
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
  
    private func sendRequest(stringtossend: String, using client: TCPClient) -> String? {
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
  
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
    
        return String(bytes: response, encoding: .utf8)
    }

    func appendToTextField(string: String) {
        print(string)
        textView.text = textView.text.appending("\n\(string)")
    }
    
    @IBAction func TestStart(_ sender: Any) {
        appendToTextField(string: "Got it again\n")
        runtest = true
        runtimer = looper.self()
    }
    
    @IBAction func stopButtonClick(sender: UIButton){
        
    }

    class looper {
        var flag: Int = 0
        
        init() {
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
        }
        
        func printer() {
            print("Got it again\n")
        }
        
        @objc func fire() {
            print("in loop\n")
            // appendToTextField(string: "Got it again\n")
        }
//            var string3: String = string2 + "\n"
//            var packet:pktheader {
//                get{
//                    return pktheader(bytes: string3.utf16.count)
//                }
//            }
//            var uinput: String{
//                get{
//                createpktstring(pkt: packet, userstring: string3)
//            }
//            }
//            if let response = sendRequest(stringtossend: uinput, using: client) {
//                appendToTextField(string: "Got it\n")
//                appendToTextField(string: "Response: \(response)")
//            }
//            if let response1 = sendRequest(stringtossend: "\n", using: client) {
//                appendToTextField(string: "Got it again\n")
//                appendToTextField(string: "Response: \(response1)")
//            }
        
    }
}
