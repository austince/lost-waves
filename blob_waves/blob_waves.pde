
import processing.video.*;
import processing.sound.*;
import gab.opencv.*;
import java.awt.Rectangle;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

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

List<Blob> blobs = new ArrayList();    // list of blobs we know about
AtomicInteger blobId = new AtomicInteger(0); // how we give blobs ids

float blobWaveStep = 20;
float numSteps = 4;

float detail = 0.6;      // amount of detail in the noise (0-1)
float increment = 0.002;    // how quickly to move through noise (0-1)

int threshold;

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

void prepareImage() {
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
}


void draw() {
  // don't do anything until a new frame of video
  // is available
  if (webcam.available()) {
    prepareImage();

    image(cv.getOutput(), 0,0);

    // get the blobs and draw them
    List<Contour> contours = cv.findContours();
    List<Blob> foundBlobs = new ArrayList(); // list of filtered blobs we've found

    // Do basic filtering and transform Contour => Blob
    for (Contour contour: contours) {
        Blob convexBlob = blobFromContour(contour.getConvexHull());
        if (filterBlob(convexBlob)) {
            foundBlobs.add(convexBlob);
        }
    }

    // Persistance!
    if (blobs.isEmpty() && foundBlobs.size() > 0) {
      // All foundBlobs are new!
      println("New blobs!");
      for (Blob b: foundBlobs) {
        b.setId(blobId.getAndIncrement());
        blobs.add(b);
        println("Found new blob:", b.id);
      }
    } else if (blobs.size() <= foundBlobs.size()) {
      // println("Matching blobs");
      // Same blobs detected, let's match!
      // match by closest distance
      for (Blob blob: blobs) {
        // find min distance index
        // set the id
        Blob matchedBlob = null;
        float minDistance = width * height; // will never be greater than this
        for (Blob foundBlob: foundBlobs) {
          float dist = PVector.dist(blob.getCentroid(), foundBlob.getCentroid());
          if (dist < minDistance && !foundBlob.matched) {
            matchedBlob = foundBlob;
            minDistance = dist;
          }
        }
        // println("Blob matched:", matchedBlob);
        matchedBlob.matched = true;
        blob.become(matchedBlob);
        println("Matched blob:", blob.id);
      }

      // Now add all unmatched blobs
      for (Blob b: foundBlobs) {
        if (!b.matched) {
          b.setId(blobId.getAndIncrement());
          blobs.add(b);
          println("Found new blob:", b.id);
        }
      }
    } else if (blobs.size() > foundBlobs.size()) {
      // Need to remove all that aren't there anymore
      // quickly initialize all current blobs as not matched
      for (Blob b: blobs) {
        b.matched = false;
      }

      // Reverse the loop
      for (Blob foundBlob: foundBlobs) {
        // find min distance index
        // set the id
        Blob matchedBlob = null;
        float minDistance = width * height; // will never be greater than this
        for (Blob blob: blobs) {
          float dist = PVector.dist(blob.getCentroid(), foundBlob.getCentroid());
          if (dist < minDistance && !foundBlob.matched) {
            matchedBlob = foundBlob;
            minDistance = dist;
          }
        }
        // if it
        if (matchedBlob != null) {
          // Matched in this case is a blob we already know about
          matchedBlob.matched = true;
          matchedBlob.become(foundBlob);
        }
      }

      // Now add all unmatched blobs
      for (int i = blobs.size() - 1; i >= 0; i--) {
        Blob blob = blobs.get(i);
        if (!blob.matched) {
          blobs.remove(i);
          println("Goodbye blob:", blob.id);
        }
      }
    }



    // Draw the blobs

    noFill();
    stroke(255,150,100);
    strokeWeight(3);

    for (Blob blob : blobs) {
        // println("Blob:", blob.id);
        // Last minute filtering tyring to rid the world of blobs in blobs

        // println(blob.pointMat.size().height, blob.getBoundingBox().height);
        blob.display();
    }

    // how many blobs did we find?
    if (debug) {
      fill(0,150,255);
      noStroke();
      text(threshold + " threshold", 20, height - 60);
      text(contours.size() + " blobs before filter", 20, height - 40);
      text(foundBlobs.size() + " blobs", 20, height - 20);
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
