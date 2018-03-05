// TODO: Make the contour into a shape for quicker drawing / scaling
class Ring {
  ArrayList<PVector> points;
  ArrayList<PVector> unitVectorsToCentroid;
  PVector centroid;
  float growthScale = 2;
  float growthScaleY = 2;
  int id = -1;
  int age = 0;
  int maxAge = 1000; // temp
  int growAge = 50;
  float xNoiseOff = 0;
  float yNoiseOff = 0;


  Ring(ArrayList<PVector> pts, ArrayList<PVector> unitVecs, PVector centroid) {
    this.points = pts;
    this.unitVectorsToCentroid = unitVecs;
    this.centroid = centroid;
  }

  void setId(int id) {
    this.id = id;
  }

  void setMaxAge(int age) {
    maxAge = age;
  }

  void setGrowAge(int age) {
    growAge = age;
  }

  void setGrowthScale(float scale) {
    growthScale = scale;
  }

  void shift(PVector amount) {
    for (PVector pt: points) {
      pt.add(amount);
    }
  }

  void grow() {
    for (int pointIndex = 0; pointIndex < points.size(); pointIndex++) {
        PVector unitVec = unitVectorsToCentroid.get(pointIndex).copy();
        PVector pt = points.get(pointIndex); // don't copy cause we're mod-ing!
        unitVec.mult(growthScale);
        pt.add(unitVec);
    }
  }

  void update() {
    age++;
    if (age % growAge == 0) {
      grow();
    }
  }

  void display() {
    colorMode(HSB, 360, 100, 100);
    float maxShift = width * height / 92160; // 10px on 1280 x 720
    float alpha = map(age, 0, maxAge, 100, 0);
    color c = color(360, 0, 70, alpha);
    fill(c);
    noStroke();
    beginShape();
    for (int pointIndex = 0; pointIndex < points.size(); pointIndex++) {
        PVector pt = points.get(pointIndex);
        // float xNoise = map(noise(xNoiseOff, yNoiseOff), 0, 1, 0, maxShift);
        // float yNoise = map(noise(yNoiseOff, xNoiseOff), 0, 1, 0, maxShift);
        // vertex(pt.x + xNoise, pt.y + yNoise);
        vertex(pt.x, pt.y);
        xNoiseOff = (xNoiseOff + 0.05);
        yNoiseOff = (yNoiseOff + 0.01);
    }
    endShape(CLOSE);
  }
}
