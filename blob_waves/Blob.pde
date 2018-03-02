import gab.opencv.*;
import java.util.Date;

class Blob {
  Contour contour;
  int id = -1;
  int age = 0;
  float ageScale = 0;
  float agePerRing = 60 * 100;
  int waveStep = 50;
  int currentTimer;
  int frameTimer = 25; // how many frames this can be gone for and not be removed
  PVector centroid = null;
  boolean matched = false;
  PVector velocity = new PVector(0, 0);
  ArrayList<PVector> unitVectorsToCentroid = null;
  // Each ring needs a set of points
  ArrayList<Ring> rings = new ArrayList();

  Blob(Contour contour) {
    updateContour(contour);
    resetTimer();
  }

  void setId(int id) {
    this.id = id;
  }

  Contour getContour() {
    return contour;
  }

  PVector getCentroid() {
    return centroid;
  }

  void become(Blob otherBlob) {
    updateContour(otherBlob.contour);
  }

  void updateContour(Contour newContour) {
    contour = newContour;
    // quadtruple the approximation
    contour.setPolygonApproximationFactor(contour.getPolygonApproximationFactor() * 4);

    // update the unit vectors and centroid
    ArrayList<PVector> blobPoints = getContour().getPolygonApproximation().getPoints();

    PVector oldCentroid = centroid;
    centroid = getCentroidFromPoints(contour.getPolygonApproximation().getPoints());

    PVector centroidChange;
    if (oldCentroid == null) {
      centroidChange = new PVector(0, 0);
    } else {
      centroidChange = PVector.sub(centroid, oldCentroid);
    }

    unitVectorsToCentroid = new ArrayList<PVector>(blobPoints.size());
    for (PVector pt : blobPoints) {
        PVector unitVec = PVector.sub(pt, centroid);
        unitVec.normalize();
        unitVectorsToCentroid.add(unitVec);
    }

    if (rings.size() == 0) {
      // no rings already
      rings.add(new Ring(blobPoints));
    } else {
      // Must update all rings towards new point?
      for (Ring ring: rings) {
        ring.shift(centroidChange);
      }
    }
  }

  void update() {
    age++;
  }

  // Time lifespacn
  void decrementTimer() {
    currentTimer--;
  }

  void resetTimer() {
    currentTimer = frameTimer;
  }

  boolean timedout() {
    return currentTimer < 0;
  }

  void display() {
    for (int i = 0; i < rings.size(); i++) {
      Ring ring = rings.get(i);
      fill(255, 0, 200, 100);
      beginShape();
      for (int pointIndex = 0; pointIndex < ring.points.size(); pointIndex++) {
          PVector unitVec = unitVectorsToCentroid.get(pointIndex);
          PVector pt = ring.points.get(pointIndex).copy();
          float scale = ((waveStep * i) + noise(30));
          // float yscale = ((waveStep * i) + noise(30));
          pt.add(PVector.mult(unitVec, scale));
          vertex(pt.x, pt.y);
      }
      endShape(CLOSE);
    }

    if (debug) {
      fill(255, 0, 200, 100);
      ellipse(centroid.x, centroid.y, 20, 20);

      textMode(CENTER);
      textSize(20);
      fill(0);
      text(id + "", centroid.x, centroid.y);
      textSize(16);
      fill(255, 0, 0, 200);
      text(currentTimer + " till dead.", centroid.x, centroid.y - 20);
      text(age + " frames old.", centroid.x, centroid.y - 40);
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

class Ring {
  ArrayList<PVector> points;
  ArrayList<PVector> unitVectorsToCentroid;
  PVector centroid;


  Ring(ArrayList<PVector> pts, PVector centroid) {
    points = pts;
  }

  void shift(PVector amount) {
    for (PVector pt: points) {
      pt.add(amount);
    }
  }
}

// "Static" Helper methods

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
* A rough estimation of the centroid point of a blob
*/
PVector getCentroidFromPoints(ArrayList<PVector> pts) {
    // values for calculating the centroid
    PVector centroid = new PVector(0, 0);
    for (PVector pt : pts) {
      centroid.x += pt.x;
      centroid.y += pt.y;
    }

    centroid.x /= pts.size();
    centroid.y /= pts.size();

    return centroid;
}
