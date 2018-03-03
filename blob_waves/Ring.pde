class Ring {
  ArrayList<PVector> points;
  ArrayList<PVector> unitVectorsToCentroid;
  PVector centroid;
  float growthScale = 2;
  float growthScaleY = 2;
  int id = -1;
  int age = 0;
  int growAge = 100;


  Ring(ArrayList<PVector> pts, ArrayList<PVector> unitVecs, PVector centroid) {
    this.points = pts;
    this.unitVectorsToCentroid = unitVecs;
    this.centroid = centroid;
  }

  void setId(int id) {
    this.id = id;
  }

  void shift(PVector amount) {
    for (PVector pt: points) {
      pt.add(amount);
    }
  }

  void grow() {
    log("Growing ring", id);
    growthScale += noise(30);
    growthScaleY += noise(30);

    for (int pointIndex = 0; pointIndex < points.size(); pointIndex++) {
        PVector unitVec = unitVectorsToCentroid.get(pointIndex).copy();
        PVector pt = points.get(pointIndex).copy();
        // float yscale = ((waveStep * i) + noise(30));
        unitVec.x *= growthScale;
        unitVec.y *= growthScaleY;

        pt.add(unitVec);
        vertex(pt.x, pt.y);
    }
  }

  void update() {
    age++;
    if (age % growAge == 0) {
      grow();
    }
  }

  void display() {
    fill(255, 0, 200, 100);
    beginShape();
    for (int pointIndex = 0; pointIndex < points.size(); pointIndex++) {
        PVector pt = points.get(pointIndex);
        vertex(pt.x, pt.y);
    }
    endShape(CLOSE);
  }
}
