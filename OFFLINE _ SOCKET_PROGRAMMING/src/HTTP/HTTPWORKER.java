package HTTP;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;


public class HTTPWORKER implements Runnable {

    Socket socket;
    String File404, imageFile, textFile, directoryFile;
    public static int chunk = 4*1024;

    public HTTPWORKER(Socket socket) throws IOException {
        this.socket        = socket;
        this.File404       = parseContent("404.html");
        this.imageFile     = parseContent("Text_Image_Viewer.html");
        this.textFile      = parseContent("Text_Image_Viewer.html");
        this.directoryFile = parseContent("folderViewer.html");
    }

    private String parseContent(String fileName) throws IOException
    {
        StringBuilder stringBuilder = new StringBuilder();
        BufferedReader br = new BufferedReader(new InputStreamReader
                (new FileInputStream((fileName)), StandardCharsets.UTF_8));
        while(true) {
            String line;
            if((line = br.readLine()) == null)
                break;
            stringBuilder.append( line + "\n" );
        }

        return stringBuilder.toString();
    }

    public static boolean testImage(File file) throws IOException {

        boolean testImage = false;
        String mimetype = Files.probeContentType(file.toPath());

        if (mimetype != null)
            if (mimetype.split("/")[0].equals("image")) // [1] ~ jpeg/png
                testImage = true;
        return testImage;
    }


    private byte[] getChunk(byte[] bytes,int startIndex,int length) {
        byte[] chunk = new byte[length];
        int i = 0;
        while(i < length)
        {
            chunk[i] = bytes[startIndex+i];
            i++;
        }
        return chunk;
    }


    private String statusCode (String type)
    {
        if(type.equals(File404))
            return "404 NOT Found";
        return "200 OK";
    }


    @Override
    public void run() {
        try {

            //http req stored input --- All req starts with GET
            String input = (new BufferedReader(new InputStreamReader
                    (this.socket.getInputStream()))).readLine();


            if(input == null)
                return;


            //type of file
            String type = File404; //default NOTFOUND
            PrintWriter pr = new PrintWriter(this.socket.getOutputStream());
            OutputStream out=socket.getOutputStream();

            String DirectoryName = "<li><a href=\"{href}\"><b><i>{name}</i></b><a></li>";
            String fileName      ="<li><a href=\"{href}\">{name}<a></li>";


            if (input.length() > 0) {
                if (input.startsWith("GET")) {
                    {
                        //http route ~ after " " ~ GET / tiger.bmp
                        String route = input.split(" ")[1];

                        String path = Paths.get(Paths.get("").toAbsolutePath()
                                .toString(), route).toString();//Directory folder choose

                        File requestedFile = new File(path);

                        //check if the file exists
                        boolean ok = requestedFile.exists();

                        //if the file exists
                        if (ok) {

                            //check if it's a directory
                            boolean dir = requestedFile.isDirectory();
                            if(!dir){
                                // if it's a text file
                                if (requestedFile.getName().endsWith(".txt")) {
                                    //changing title in TextFile with Filename
                                    String textOpen = this.textFile.replace("{title}", requestedFile.getName());
                                    type = textOpen.replace("<img src=\"{src}\">", parseContent(path));
                                }

                                //if it's a imageFile
                                else if (testImage(requestedFile)) {
                                    byte[] imagebytearray = new byte[(int) requestedFile.length()];
                                    //read the imagebits
                                    new FileInputStream(requestedFile).read(imagebytearray);
                                    //base64 to embed image data in html files
                                    String replaceTitle = this.imageFile.replace("{title}",
                                            requestedFile.getName());
                                    String replaceSrc = "data:" + Files.probeContentType(requestedFile.toPath())
                                            + ";base64, " + Base64.getEncoder().encodeToString(imagebytearray);

                                    type = replaceTitle.replace("{src}", replaceSrc);

                                }
                                // in other cases ------ DOWNLOADING
                                else {
                                    out.write("HTTP/1.1 200 OK\r\n".getBytes());
                                    out.write("Accept-Ranges: bytes\r\n".getBytes());
                                    out.write(("Content-Length: " + requestedFile.length() + "\r\n").getBytes());
                                    out.write("Content-Type: application/octet-stream\r\n".getBytes());
                                    out.write(("Content-Disposition: attachment; filename=\"" + requestedFile.getName() + "\"\r\n").getBytes());
                                    out.write("\r\n".getBytes());

                                    byte[] bytes = new FileInputStream(requestedFile).readAllBytes();
                                    try {
                                        int i = 0;
                                        int total = chunk;
                                        while(total <= bytes.length)
                                        {
                                            out.write(getChunk(bytes, i * chunk, chunk));
                                            i++;
                                            total += i*chunk;
                                        }

                                        int left = bytes.length%chunk;
                                        int startIndex = (bytes.length / chunk )*chunk;

                                        out.write(getChunk(bytes, startIndex, left));
                                    }
                                    catch (IOException e)
                                    {
                                        System.out.println("CLIENT ABORTED DOWNLOADING");
                                    }

                                }
                            }
                            else {
                                String ListItems = "";
                                String SubRoute, portion;

                                if (requestedFile.listFiles() != null) {
                                    for (File file : requestedFile.listFiles()) {
                                        //if it's a directory
                                        SubRoute = (route + "/" + file.getName());
                                        String FileType;
                                        // file or directory 1 slash
                                        SubRoute = SubRoute.replaceAll("//", "/");
                                        boolean ChildDir = file.isDirectory();
                                        if (ChildDir)
                                            FileType = DirectoryName;
                                        else
                                            FileType = fileName;

                                        // rename {name} to filename in link
                                        portion = FileType.replace("{name}", file.getName());

                                        // rename href in link to a valid route
                                        portion = portion.replace("{href}", SubRoute);

                                        ListItems = ListItems + portion + "\n";
                                    }

                                    //changing title in directoryFile.html with Filename
                                    String replaceTitleWithName = this.directoryFile.replace
                                            ("{title}", requestedFile.getName());
                                    //change the items in list with item
                                    type = replaceTitleWithName.replace("{items}", ListItems);
                                }
                            }
                        }

                        if (type != null) {
                            String request = input+"\nServer: Java HTTP Server: 1.1\r\n" + "Date: " + new Date() +
                                    "\rContent-Type: text/html\r\nContent-Length: " + type.length() + "\r\n\r\n";

                            Server.logFile.println("REQUEST\n" + request);

                            String MimeTypeResponse = "HTTP/1.1 " + statusCode(type) + "\r\n" +
                                    "Server: Java HTTP Server: 1.1\r\nDate: " + new Date() + "\r\n" +
                                    "Content-Type: text/html" + "\r\nContent-Length: " + type.length() +
                                    "\r\n\r\n";
                            Server.logFile.println("RESPONSE\n" + MimeTypeResponse);
                            Server.logFile.flush();
                            MimeTypeResponse += type;
                            pr.write(MimeTypeResponse);
                        }

                        pr.flush();
                        pr.close();

                        out.flush();
                        out.close();
                    }
                }


                else{

                if(input.startsWith("UPLOADING")) {

                    DataInputStream dataInputStream = new DataInputStream(socket.getInputStream());
                    OutputStreamWriter outputStreamWriter = new OutputStreamWriter(socket.getOutputStream());
                    BufferedWriter bufferedWriter = new BufferedWriter(outputStreamWriter);
                    bufferedWriter.write("FILE_READY_TO_UPLOAD" + "\n");
                    bufferedWriter.flush();

                    String FILENAME = input.substring("UPLOADING".length());
                    System.out.println(FILENAME);

                    while (dataInputStream.available() > 0)
                        dataInputStream.read();

                    FileOutputStream fileOutputStream = new FileOutputStream(Paths.get(Paths.get("")
                                    .toAbsolutePath().toString(), "uploaded", FILENAME).toString());


                    long size = dataInputStream.readLong();
                    int bytes;
                    byte[] buffer = new byte[chunk];

                    while ((bytes = dataInputStream.read(buffer, 0, (int) Math.min(buffer.length, size))) != -1)
                        {
                            fileOutputStream.write(buffer, 0, bytes);
                            size -= bytes;
                            if(size <0)
                                break;
                        }

                    fileOutputStream.close();
                    }
                else if (input.startsWith("NONEXISTENT") || input.startsWith("UNSUPPORTED"))
                    System.out.println("INVALID UPLOAD REQUEST : " + input);
                }
            }

            //closing the socket
            this.socket.close();
        }

        catch (IOException exception)
        {
            exception.printStackTrace();
        }
    }
}