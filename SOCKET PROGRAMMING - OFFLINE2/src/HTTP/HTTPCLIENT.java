package HTTP;

import java.util.Scanner;

public class HTTPCLIENT {
    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);
        System.out.println("ENTER FILENAMES TO UPLOAD / EXIT ");

        while (true) {
            String input = sc.nextLine();

            if (!input.equals("EXIT")) {
                // parallel upload
                String[] filesForUpload =input.split(" ");
                for (String fileName : filesForUpload) {
                    try {
                        new Thread(new ClientWorker(fileName)).start();
                    } catch (RuntimeException e) {
                        System.out.println(e.getMessage());
                    }
                }
            }
            else
                break;
            System.out.println();
        }
    }
}
