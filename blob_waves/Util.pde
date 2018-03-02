/*
Just helpful little functions that don't really have a home elsewhere

*/

void log(Object ...args) {
  if (debug) {
    Object toPrint[] = new Object[args.length + 1];
    toPrint[0] = new Date();
    for (int i = 1; i <= args.length; i++) {
      toPrint[i] = args[i-1];
    }
    println(toPrint);
  }
}
