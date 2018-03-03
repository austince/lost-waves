class Ring {
  ArrayList<PVector> points;
  ArrayList<PVector> unitVectorsToCentroid;
  PVector centroid;
  float growthScale = 2;


  Ring(ArrayList<PVector> pts, ArrayList<PVector> unitVecs, PVector centroid) {
    this.points = pts;
    this.unitVectorsToCentroid = unitVecs;
    this.centroid = centroid;
  }

  void shift(PVector amount) {
    for (PVector pt: points) {
      pt.add(amount);
    }
  }

  void display() {
    fill(255, 0, 200, 100);
    beginShape();
    for (int pointIndex = 0; pointIndex < points.size(); pointIndex++) {
        PVector unitVec = unitVectorsToCentroid.get(pointIndex);
        PVector pt = points.get(pointIndex).copy();
        float scale = (growthScale + noise(30));
        // float yscale = ((waveStep * i) + noise(30));
        pt.add(PVector.mult(unitVec, scale));
        vertex(pt.x, pt.y);
    }
    endShape(CLOSE);
  }
}
