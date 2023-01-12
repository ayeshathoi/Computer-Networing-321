package HTTP;

import java.io.*;
import java.net.*;
import java.nio.file.*;

public class ClientWorker implements Runnable {

    String file;

    public ClientWorker(String fileName)
    {
        this.file =fileName;
    }

    @Override
    public void run() {
        try {

            Socket socket = new Socket("localhost", 5062);
            File FileForUPLOAD = new File(Paths.get(Paths.get("").toAbsolutePath().toString(), file).toString());

            this.file = FileForUPLOAD.getName();

            //Command for HTTPSERVER
            OutputStreamWriter out = new OutputStreamWriter(socket.getOutputStream());
            BufferedWriter bufferedWriter=new BufferedWriter(out);

            String uploadReq = "UPLOAD" + file;
            boolean error = false;

            boolean ok = FileForUPLOAD.exists();
            boolean isImageFile = HTTPWORKER.testImage(FileForUPLOAD);
            boolean testTextFile = file.endsWith(".txt") || file.endsWith(".mp4");

            // file Nonexistent
            if (!ok)
            {
                uploadReq = "NONEXISTENT FILE " + file;
                error = true;
            }


            // invalid Format
            else if (!isImageFile && !testTextFile)
            {
                uploadReq = "UNSUPPORTED FILE " + file;
                error =  true;
            }

            bufferedWriter.write(uploadReq + "\n");
            bufferedWriter.flush();

            if(error)
                System.out.println("Invalid Upload Request : "+ file);

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

                    System.out.println("UPLOAD COMPLETED : "+ file);
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