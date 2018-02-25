
import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;

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

float minBlobArea, maxBlobArea;
float minBlobWidthHeightRatio;

float blobWaveStep = 20;
float numSteps = 4;

void setup() {
    size(1280,720);
    colorMode(HSB);
    // create an instance of the OpenCV library
    // we'll pass each frame of video to it later
    // for processing
    cv = new OpenCV(this, width, height);
    
    minBlobArea = (width * height) / 1000;
    maxBlobArea = (width * height) / 8;
    minBlobWidthHeightRatio = 0.3; // 0-1, square + circle have 1

    println("MinArea", minBlobArea);
    println("MaxArea", maxBlobArea);

    // start the webcam
    String[] inputs = Capture.list();
    if (inputs.length == 0) {
        println("Couldn't detect any webcams connected!");
        exit();
    }
    webcam = new Capture(this, inputs[0]);
    webcam.start();
    
    // text settings (for showing the # of blobs)
    textSize(20);
    textAlign(LEFT, BOTTOM);
}


void draw() {
    ArrayList<Contour> blobs;    // list of blob contours
    ArrayList<Contour> convexBlobs;    // list of blob contours

  // don't do anything until a new frame of video
  // is available
  if (webcam.available()) {
    
    // read the webcam and load the frame into OpenCV
    webcam.read();
    cv.loadImage(webcam);
    
    // pre-process the image (adjust the threshold
    // using the mouse) and display it onscreen
    int threshold = int( map(mouseY, 0,height, 0,255) );
    cv.threshold(threshold);
    //cv.invert();    // blobs should be white, so you might have to use this
    cv.dilate();
    cv.erode();

    image(cv.getOutput(), 0,0);
    
    // get the blobs and draw them
    blobs = cv.findContours();
    convexBlobs = new ArrayList();

    for (Contour blob: blobs) {
        Contour convexBlob = blob.getConvexHull();
        if (filterBlob(convexBlob)) {
            convexBlobs.add(convexBlob);
        }
    }

    noFill();
    stroke(255,150,100);
    strokeWeight(3);
    int numBlobs = 0;

    for (Contour blob : convexBlobs) {
        // Last minute filtering tyring to rid the world of blobs in blobs
        if (containsAnother(blob, convexBlobs)) {
            println("Contains another");
            continue;
        }

        numBlobs++;
        // println(blob.pointMat.size().height, blob.getBoundingBox().height);
        // blob.setPolygonApproximationFactor(blob.pointMat.size().height * 0.5);
        ArrayList<PVector> blobPoints = blob.getPolygonApproximation().getPoints();
        ArrayList<PVector> blobUnitVectors = new ArrayList<PVector>(blobPoints.size());

        PVector centroid = getCentroid(blobPoints);
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
                unitVec.x *= (blobWaveStep * i);
                unitVec.y *= (blobWaveStep * i);
                pt.add(unitVec);
                vertex(pt.x, pt.y);
            }
            endShape(CLOSE);
        }
    }
    
    // how many blobs did we find?
    fill(0,150,255);
    noStroke();
    text(threshold + " threshold", 20, height - 60);
    text(blobs.size() + " blobs before filter", 20, height - 40);
    text(numBlobs + " blobs", 20, height - 20);
  }
}

/**
* returns true if it passes the requirements
*/
boolean filterBlob(Contour blob) {
    // filter by size
    float area = blob.area();
    if (area > maxBlobArea || area < minBlobArea) {
        return false;
    } 

    Rectangle bounds = blob.getBoundingBox();
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

boolean containsAnother(Contour blob, ArrayList<Contour> blobs) {
    for (Contour otherBlob: blobs) {
        // don't check if it contains itself
        if (blob == otherBlob) {
            continue;
        }

        PVector otherCentroid = getCentroid(otherBlob);
        if (blob.containsPoint((int) otherCentroid.x, (int) otherCentroid.y)) {
            return true;
        }
    }

    return false;
}

PVector getCentroid(Contour blob) {
    return getCentroid(blob.getPolygonApproximation().getPoints());
}

/**
* A rough estimation of the center point of a blob
*/
PVector getCentroid(ArrayList<PVector> pts) {
    // values for calculating the centroid
    PVector center = new PVector(0, 0);
    for (PVector pt : pts) {
      vertex(pt.x, pt.y);
      center.x += pt.x;
      center.y += pt.y;
    }

    center.x /= pts.size();
    center.y /= pts.size();

    return center;
}