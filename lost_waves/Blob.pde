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
  color bColor;
  ArrayList<PVector> unitVectorsToCentroid = null;

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

  void setColor(color c) {
    bColor = c;
  }

  void setFrameTimeout(int numFrames) {
    frameTimer = numFrames;
  }

  color getColor() {
    return bColor;
  }

  void become(Blob otherBlob) {
    updateContour(otherBlob.contour);
  }

  private void updateContour(Contour newContour) {
    contour = newContour;
    // quadtruple the approximation
    // contour.setPolygonApproximationFactor(contour.getPolygonApproximationFactor() * 4);

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
  }

  void update() {
    age++;
  }

  Ring spawnRing() {
    return new Ring(
      getContour().getPolygonApproximation().getPoints(),
      unitVectorsToCentroid,
      centroid
    );
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

  /**
  * If the blob contains another blob in a list of blobs
  * @param blobs - the list of all blobs
  */
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

  void display() {
    fill(bColor);
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
