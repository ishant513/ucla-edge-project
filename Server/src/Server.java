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
			//System.out.println("received " + bytearr[0] + bytearr[1] + bytearr[2] + bytearr[3] + bytearr[4] +
			//bytearr[5] + bytearr[6] + bytearr[7]);
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
			ByteBuffer sendbuffer = ByteBuffer.allocate(24);
			sendbuffer.putLong(0, seqno);
			sendbuffer.putLong(Long.BYTES, timesent);
			sendbuffer.putLong(2*Long.BYTES, userstringsz);
			byte[] sendpacket = new byte[sendbuffer.remaining() + (int)userstringsz];
			sendbuffer.get(sendpacket, 0, 24);
			System.arraycopy(bytearr, 24, sendpacket, 24, (int)userstringsz);
			//System.out.println("Sending: " + sendpacket);
			dout.write(sendpacket);
			dout.flush();
		}
		d.close();
		din.close();
		sock.close();
		serversock.close();
	}

	public static long convertByteArrayToInt(byte[] data, int startIndex) {
		return (((data[startIndex + 7] & 0xFF) << 56) |
						((data[startIndex + 6] & 0xFF) << 48) |
						((data[startIndex + 5] & 0xFF) << 40) |
						((data[startIndex + 4] & 0xFF) << 32) |
						((data[startIndex + 3] & 0xFF) << 24) |
						((data[startIndex + 2] & 0xFF) << 16) |
						((data[startIndex + 1] & 0xFF) << 8)  |
						((data[startIndex + 0] & 0xFF) << 0)
		);
	}
}
