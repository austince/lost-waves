/**
All logging utilities
Would be nice to make a logger class / library for all of Processing to use
Needs of Processing users (?):
- simple outputs in development
- filterable
- accessible outputs when installed
*/

import java.text.SimpleDateFormat;
import java.text.DateFormat;

DateFormat logStamp = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss -- ");

PrintWriter output;

void logDisplayInfo() {
  // let's get some info about the current display

  // get the display's dimensions
  // Processing normally won't let us use variables in the size()
  // command, but we can pass it the dimensions of the display
  log("DISPLAY:", "-", displayWidth, "x", displayHeight, "px");

  // get the display's pixel density
  // this will optimize the sketch's graphics for retina and other
  // high-density displays
  if (displayDensity() == 1) {
    log("DISPLAY:", "- normal-density display (1x)");
  }
  else {
    log("DISPLAY:", "- retina display (2x)");
  }
}

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
