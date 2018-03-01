import gab.opencv.*;

static class Blob {
  Contour contour;
  Blob(Contour contour) {
    this.contour = contour;
  }

  static List<Blob> fromContourList(List<Contour> list) {
    ArrayList<Blob> blobs = new ArrayList(list.size());
    for (Contour contour: list) {
      blobs.add(new Blob(contour));
    }
    return blobs;
  }

  static Blob fromContour(Contour contour) {
    return new Blob(contour);
  }

  Contour getContour() {
    return contour;
  }

  PVector getCentroid() {
      return Blob.getCentroid(contour.getPolygonApproximation().getPoints());
  }

  /**
  * A rough estimation of the center point of a blob
  */
  static PVector getCentroid(ArrayList<PVector> pts) {
      // values for calculating the centroid
      PVector center = new PVector(0, 0);
      for (PVector pt : pts) {
        center.x += pt.x;
        center.y += pt.y;
      }

      center.x /= pts.size();
      center.y /= pts.size();

      return center;
  }

  boolean containsAnother(List<Blob> blobs) {
      for (Blob otherBlob: blobs) {
          // don't check if it contains itself
          if (this == otherBlob) {
              continue;
          }

          PVector otherCentroid = otherBlob.getCentroid();
          if (this.contour.containsPoint((int) otherCentroid.x, (int) otherCentroid.y)) {
              return true;
          }
      }

      return false;
  }
}
