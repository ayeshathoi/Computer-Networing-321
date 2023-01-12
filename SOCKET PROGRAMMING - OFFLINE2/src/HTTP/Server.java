package HTTP;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.net.*;

public class Server {

    static PrintWriter logFile;

    public static void main(String []args) throws Exception
    {
        ServerSocket serverSocket = new ServerSocket(5062);
        System.out.println("SERVER STARTED --- Listening on Port 5062");

        logFile = new PrintWriter( new FileOutputStream( "log.txt"));

        while(true)
            new Thread(new HTTPWORKER(serverSocket.accept())).start();//start of thread
    }
}
