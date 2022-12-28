package HTTP;

import java.util.Scanner;

public class HTTPCLIENT {
    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);
        System.out.println("ENTER FILENAMES TO UPLOAD / EXIT ");

        while (true) {
            String input = sc.nextLine();

            if (input.equals("EXIT"))
                break;
            else {
                try
                {
                    //call to ClientWorker
                    new Thread(new ClientWorker(input)).start();
                }
                catch (RuntimeException e) {
                    System.out.println(e.getMessage());
                }
            }
            System.out.println();
        }
    }
}
