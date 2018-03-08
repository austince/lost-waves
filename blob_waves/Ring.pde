import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Rect;
import org.opencv.core.Mat;
import org.opencv.core.MatOfInt;
import org.opencv.core.Point;

// TODO: Make the contour into a shape for quicker drawing / scaling
class Ring {
  ArrayList<PVector> points;
  ArrayList<PVector> unitVectorsToCentroid;

  // for checking inclusions
  MatOfPoint2f mat;

  PVector centroid;
  float growthScale = 2;
  float growthScaleY = 2;
  int id = -1;
  int age = 0;
  int maxAge = 1000; // temp
  int growAge = 50;
  float xNoiseOff = 0;
  float yNoiseOff = 0;
  color rColor;
  float mass = 10; // kg?


  Ring(ArrayList<PVector> pts, ArrayList<PVector> unitVecs, PVector centroid) {
    this.points = pts;
    this.unitVectorsToCentroid = unitVecs;
    this.centroid = centroid;

    Point matPoints[] = new Point[points.size()];
    for (int pointIndex = 0; pointIndex < points.size(); pointIndex++) {
        PVector pt = points.get(pointIndex);
        matPoints[pointIndex] = new Point(pt.x, pt.y);
    }
    mat = new MatOfPoint2f(matPoints);
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

  void setColor(color c) {
    this.rColor = c;
  }

  void shift(PVector amount) {
    for (PVector pt: points) {
      pt.add(amount);
    }
  }

  void grow() {
    Point matPoints[] = new Point[points.size()];
    for (int pointIndex = 0; pointIndex < points.size(); pointIndex++) {
        PVector unitVec = unitVectorsToCentroid.get(pointIndex).copy();
        PVector pt = points.get(pointIndex); // don't copy cause we're mod-ing!
        unitVec.mult(growthScale);
        pt.add(unitVec);
        matPoints[pointIndex] = new Point(pt.x, pt.y);
    }
    mat = new MatOfPoint2f(matPoints);

    // mass *= growthScale;
  }

  boolean containsPoint2D(PVector point) {
    Point p = new Point(point.x, point.y);
    return Imgproc.pointPolygonTest(mat, p, false) == 1;
  }

  /**
  * Gets force towards point
  */
  PVector getForce(PVector pos) {
    // only do 2D
    pos.z = 0;
    float distToCent = abs(PVector.dist(pos, centroid));
    float vel = distToCent / age;
    return PVector.sub(pos, centroid).normalize().mult(vel).div(mass); // rough
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
    fill(rColor);
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
