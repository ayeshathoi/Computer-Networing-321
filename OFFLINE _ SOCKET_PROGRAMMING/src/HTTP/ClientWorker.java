package HTTP;

import java.io.*;
import java.net.*;
import java.nio.file.*;

public class ClientWorker implements Runnable {

    String fileName;

    public ClientWorker(String fileName)
    {
        this.fileName=fileName;
    }

    @Override
    public void run() {
        try {

            Socket socket = new Socket("localhost", 5062);
            File FileForUPLOAD = new File(Paths.get(Paths.get("").toAbsolutePath().toString(), fileName).toString());

            this.fileName = FileForUPLOAD.getName();

            //Command for HTTPSERVER
            OutputStreamWriter out = new OutputStreamWriter(socket.getOutputStream());
            BufferedWriter bufferedWriter=new BufferedWriter(out);

            String uploadReq = "UPLOADING" + fileName;
            boolean error = false;

            boolean ok = FileForUPLOAD.exists();
            boolean isImageFile = HTTPWORKER.testImage(FileForUPLOAD);
            boolean testTextFile = fileName.endsWith(".txt");

            if (!ok)
            {
                uploadReq = "NONEXISTENT FILE " + fileName;
                error = true;
            }

            else if (!isImageFile && !testTextFile)
            {
                uploadReq = "UNSUPPORTED FILE " + fileName;
                error =  true;
            }

            bufferedWriter.write(uploadReq + "\n");
            bufferedWriter.flush();

            if(error)
                System.out.println("Invalid Upload Request : "+fileName);

            else {

                String input = new BufferedReader(new InputStreamReader(socket.getInputStream())).readLine();
                //FILE_READY_TO_UPLOAD ----- INPUT CONTENT

                if(input!=null && input.startsWith("FILE"))
                {
                    DataOutputStream dataOutputStream = new DataOutputStream(socket.getOutputStream());
                    FileInputStream fileInputStream = new FileInputStream(FileForUPLOAD);

                    dataOutputStream.writeLong(FileForUPLOAD.length());

                    int chunk_bytes ;
                    byte[] buffer = new byte[HTTPWORKER.chunk];

                    while ((chunk_bytes = fileInputStream.read(buffer)) != -1) {
                        dataOutputStream.write(buffer, 0, chunk_bytes);
                        dataOutputStream.flush();
                    }

                    System.out.println("UPLOAD COMPLETED : "+fileName );
                    fileInputStream.close();
                }
            }

            System.out.println("ENTER FILENAMES TO UPLOAD / EXIT ");
            socket.close();

        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}