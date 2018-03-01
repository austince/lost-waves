
import processing.video.*;
import processing.sound.*;
import gab.opencv.*;
import java.awt.Rectangle;
import java.util.List;

/*
BLOB DETECTION: WEBCAM
Austin Cawley-Edwards, Jeff Thompson

An expanded version of the Blob Detection example
using the webcam as an input. Try using your phone's
flashlight in a darkened room, adjusting the threshold
until it's the only blob. The mouse's X position is
also used to set the minimum blob size – anything smaller
is ignored, which is useful for noisey environments.

Details on how the pre-processing and blob detection
work are skipped here, so see the previous example
if you want to understand what's happening there.
For more on getting webcam input, see the Image
Processing code examples.

*/

Capture webcam;              // webcam input
OpenCV cv;                   // instance of the OpenCV library
SoundFile oceanSound;        // ocean sound to play from each point
                             // Would one day love this to bspatiale positional

float minBlobArea, maxBlobArea;
float minBlobWidthHeightRatio;

List<Blob> blobs;    // list of blobs we know about

float blobWaveStep = 20;
float numSteps = 4;

float detail = 0.6;      // amount of detail in the noise (0-1)
float increment = 0.002;    // how quickly to move through noise (0-1)

boolean debug = true;

void setup() {
    size(1280,720);
    colorMode(HSB);
    // create an instance of the OpenCV library
    // we'll pass each frame of video to it later
    // for processing
    cv = new OpenCV(this, width, height);
    println("Loading file.");
    // oceanSound = new SoundFile(this, "ocean.mp3");

    noiseDetail(8, detail);

    minBlobArea = (width * height) / 1000;
    maxBlobArea = (width * height) / 8;
    minBlobWidthHeightRatio = 0.3; // 0-1, square + circle have 1

    // https://github.com/processing/processing/issues/4601
    println("MinArea", minBlobArea);
    println("MaxArea", maxBlobArea);

    // start the webcam
    String camId = getCameraIdBySpecsOrDefault(1280, 720, 30);
    if (camId == null) {
        println("Couldn't detect any webcams connected!");
        exit();
    }
    webcam = new Capture(this, camId);
    webcam.start();

    // oceanSound.loop();
    // text settings (for showing the # of blobs)
    textSize(20);
    textAlign(LEFT, BOTTOM);
}


void draw() {
  // don't do anything until a new frame of video
  // is available
  if (webcam.available()) {

    // read the webcam and load the frame into OpenCV
    webcam.read();
    cv.loadImage(webcam);

    // pre-process the image (adjust the threshold
    // using the mouse) and display it onscreen
    int threshold = int(map(mouseY, 0,height, 0, 255));
    cv.threshold(threshold);
    // cv.invert();    // blobs should be white, so you might have to use this
    cv.dilate();
    cv.erode();

    image(cv.getOutput(), 0,0);

    // get the blobs and draw them
    List<Contour> contours = cv.findContours();
    List<Blob> currentBlobs = new ArrayList(); // list of filtered blobs we've found

    // Do basic filtering and transform Contour => Blob
    for (Contour contour: contours) {
        Blob convexBlob = Blob.fromContour(contour.getConvexHull());
        if (filterBlob(convexBlob)) {
            currentBlobs.add(convexBlob);
        }
    }

    // Remove all blobs that contain another of the remaining
    for (int i=currentBlobs.size()-1; i>=0; i-=1) {
      Blob blob = currentBlobs.get(i);
      if (blob.containsAnother(currentBlobs)) {
        println("Contains another.");
        // currentBlobs.remove(i);
      }
    }

    noFill();
    stroke(255,150,100);
    strokeWeight(3);

    for (Blob blob : currentBlobs) {
        // Last minute filtering tyring to rid the world of blobs in blobs

        // println(blob.pointMat.size().height, blob.getBoundingBox().height);
        blob.getContour().setPolygonApproximationFactor(blob.getContour().getPolygonApproximationFactor() * 4);
        ArrayList<PVector> blobPoints = blob.getContour().getPolygonApproximation().getPoints();
        ArrayList<PVector> blobUnitVectors = new ArrayList<PVector>(blobPoints.size());

        PVector centroid = Blob.getCentroid(blobPoints);
        fill(255, 0, 200, 100);
        ellipse(centroid.x, centroid.y, 20, 20);

        for (PVector pt : blobPoints) {
            PVector unitVec = PVector.sub(pt, centroid);
            unitVec.normalize();
            blobUnitVectors.add(unitVec);
        }

        for (int i = 0; i < numSteps; i++) {

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
        }
    }

    // how many blobs did we find?
    if (debug) {
      fill(0,150,255);
      noStroke();
      text(threshold + " threshold", 20, height - 60);
      text(contours.size() + " blobs before filter", 20, height - 40);
      text(currentBlobs.size() + " blobs", 20, height - 20);
    }
  }
}

/**
* returns true if it passes the requirements
*/
boolean filterBlob(Blob blob) {
    // filter by size
    float area = blob.getContour().area();
    if (area > maxBlobArea || area < minBlobArea) {
        return false;
    }

    Rectangle bounds = blob.getContour().getBoundingBox();
    float whRatio;
    if (bounds.width > bounds.height) {
        whRatio = (float) bounds.height / (float) bounds.width;
    } else {
        whRatio = (float) bounds.width / (float) bounds.height;
    }

    if (whRatio < minBlobWidthHeightRatio) {
        return false;
    }

    return true;
}

void keyPressed() {
  if (key == 'd') {
    debug = !debug;
  }
}
