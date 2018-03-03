/*
Just helpful little functions that don't really have a home elsewhere

*/
import java.text.SimpleDateFormat;
import java.text.DateFormat;

DateFormat logStamp = new SimpleDateFormat("yyyy.MM.dd.HH:mm:ss");

void log(Object ...args) {
  if (debug) {
    Object toPrint[] = new Object[args.length + 1];
    toPrint[0] = logStamp.format(new Date());
    for (int i = 1; i <= args.length; i++) {
      toPrint[i] = args[i-1];
    }
    println(toPrint);
  }
}

void logDisplayInfo() {
  // let's get some info about the current display
  log("DISPLAY INFO:");

  // get the display's dimensions
  // Processing normally won't let us use variables in the size()
  // command, but we can pass it the dimensions of the display
  log("-", displayWidth, "x", displayHeight, "px");

  // get the display's pixel density
  // this will optimize the sketch's graphics for retina and other
  // high-density displays
  if (displayDensity() == 1) {
    log("- normal-density display (1x)");
  }
  else {
    log("- retina display (2x)");
  }
  pixelDensity(displayDensity());
}
