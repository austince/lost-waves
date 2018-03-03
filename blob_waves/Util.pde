/*
Just helpful little functions that don't really have a home elsewhere

*/
import java.text.SimpleDateFormat;
import java.text.DateFormat;

DateFormat logStamp = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss -- ");

PrintWriter output;

void setupLogger() {
  output = createWriter("log.txt");
}

void logInProd(Object ...args) {
  if (production) log(args);
}

void log(Object ...args) {
  Object toPrint[] = new Object[args.length + 1];
  toPrint[0] = logStamp.format(new Date());
  for (int i = 1; i <= args.length; i++) {
    toPrint[i] = args[i-1];
  }

  if (production) {
    // write it to a file?
    String printStr = "";
    for (Object obj: toPrint) {
      printStr += obj.toString()  + " ";
    }
    output.println(printStr);
    output.flush();
  } else {
    // Show in console
    println(toPrint);
  }
}
