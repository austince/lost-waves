import gab.opencv.*;
import java.util.Date;

class Blob {
  Contour contour;
  int id = -1;
  int numSteps = 3;
  Date lastSeen;
  PVector center = null;
  boolean matched = false;

  Blob(Contour contour) {
    this.contour = contour;
    // quadtruple the approximation
    contour.setPolygonApproximationFactor(contour.getPolygonApproximationFactor() * 4);
    lastSeen = new Date();
  }

  void setId(int id) {
    this.id = id;
  }

  void become(Blob otherBlob) {
    contour = otherBlob.contour;
  }

  Contour getContour() {
    return contour;
  }

  PVector getCentroid() {
    if (center == null) {
      center = getCentroidFromPoints(contour.getPolygonApproximation().getPoints());
    }
    return center;
  }

  void display() {
    ArrayList<PVector> blobPoints = getContour().getPolygonApproximation().getPoints();
    ArrayList<PVector> blobUnitVectors = new ArrayList<PVector>(blobPoints.size());

    PVector centroid = getCentroidFromPoints(blobPoints);
    fill(255, 0, 200, 100);
    ellipse(centroid.x, centroid.y, 20, 20);

    for (PVector pt : blobPoints) {
        PVector unitVec = PVector.sub(pt, centroid);
        unitVec.normalize();
        blobUnitVectors.add(unitVec);
    }

    for (int i = 0; i < numSteps; i++) {
        fill(255, 0, 200, 100);
        beginShape();
        for (int pointIndex = 0; pointIndex < blobPoints.size(); pointIndex++) {
            PVector unitVec = blobUnitVectors.get(pointIndex).copy();
            PVector pt = blobPoints.get(pointIndex).copy();
            unitVec.x *= ((blobWaveStep * i) + noise(30));
            unitVec.y *= ((blobWaveStep * i) + noise(30));
            pt.add(unitVec);
            vertex(pt.x, pt.y);
        }
        endShape(CLOSE);
        fill(0);
        text(id + "", centroid.x, centroid.y);
    }
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

List<Blob> blobsFromContourList(List<Contour> list) {
  ArrayList<Blob> blobs = new ArrayList(list.size());
  for (Contour contour: list) {
    blobs.add(new Blob(contour));
  }
  return blobs;
}

List<Blob> convexBlobsFromContourList(List<Contour> list) {
  ArrayList<Blob> blobs = new ArrayList(list.size());
  for (Contour contour: list) {
    blobs.add(new Blob(contour.getConvexHull()));
  }
  return blobs;
}

Blob blobFromContour(Contour contour) {
  return new Blob(contour);
}

/**
* A rough estimation of the center point of a blob
*/
PVector getCentroidFromPoints(ArrayList<PVector> pts) {
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
