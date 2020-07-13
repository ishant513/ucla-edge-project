import java.net.*;
import java.io.*;
import java.nio.*;
public class Server {  
	
	public static void main(String args[]) throws Exception{  
		ServerSocket serversock = new ServerSocket(9000);
		
		System.out.println("Waiting for connection :|");
		Socket sock = serversock.accept();
		System.out.println("Connected :)");
		DataInputStream din = new DataInputStream(sock.getInputStream());
		BufferedReader d = new BufferedReader(new InputStreamReader(din));
		DataOutputStream dout = new DataOutputStream(sock.getOutputStream());
		//BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		boolean sent = true;
		while(sent){
			System.out.println("in loop");
			byte[] bytearr = new byte[1024];
			din.read(bytearr,0,24);
			System.out.println("received " + bytearr[0] + bytearr[1] + bytearr[2] + bytearr[3] + bytearr[4] +
					bytearr[5] + bytearr[6] + bytearr[7]);
			//int seqno = ByteBuffer.wrap(bytearr, 0, 4).getInt();
			long seqno = convertByteArrayToInt(bytearr, 0);
			System.out.println("received seqno " + seqno);
			long timesent = convertByteArrayToInt(bytearr, 8);
			System.out.println("received time " + timesent);
			long userstringsz = convertByteArrayToInt(bytearr, 16);
			System.out.println("received userstrsize " + userstringsz);
			din.read(bytearr, 24, (int)userstringsz);
			String str = new String(bytearr, 24, (int)userstringsz);
			System.out.println("received string " + str);

			// Sent the Packet Back
			dout.write(bytearr, 0, (int) (24 + userstringsz));
			dout.flush();
		}
		d.close();
		din.close();
		sock.close();
		serversock.close();
	}

	public static int convertByteArrayToInt(byte[] data, int startIndex) {
		return (
				data[startIndex + 7] << 56)
				| (data[startIndex + 6] << 48)
				| (data[startIndex + 5] << 40)
				| (data[startIndex + 4] << 32)
				| (data[startIndex + 3] << 24)
				| (data[startIndex + 2] << 16)
				| (data[startIndex + 1] << 8)
				| data[startIndex];
	}
}
