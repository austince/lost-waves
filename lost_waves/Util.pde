/*
Just helpful little functions that don't really have a home elsewhere

*/

color changeAlpha(color c, int alpha) {
  return (c & 0xffffff) | (alpha << 24);
}
