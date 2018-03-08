class Ship {
  static final String objFilename = "sailboat.obj";
  PShape shipShape; // he he
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector resistenceAcc;
  color frameColor;
  color fillColor;
  float ry;
  int dir = 1;
  int age = 0;
  float maxWave = 1000;
  float maxTilt = radians(10); // in radians
  float mass = 100; // kg?

  Ship(float x, float y, float z) {
    this(new PVector(x, y, z));
  }

  Ship(PVector pos) {
    position = pos.copy();
    shipShape = loadShape(objFilename);
    frameColor = color(0);
    fillColor = color(0, 0, 0, 0);
    velocity = new PVector(0, 0, 0);
    acceleration = new PVector(0, 0, 0);
  }

  void setMass(float m) {
    mass = m;
  }

  PShape getShape() {
    return shipShape;
  }

  PVector getPosition() {
    return position;
  }

  void applyForce(PVector force) {
    force.div(mass);
    acceleration.add(force);
  }

  void update() {
    if (ry > maxTilt || ry < -maxTilt) {
      dir *= -1;
    }

    // A little easing
    float dRy;
    if (dir < 0) {
      dRy = maxTilt - ry;
    } else {
      dRy = ry - maxTilt;
    }

    float change = dir * constrain(abs(dRy) * 0.01, 0.005, 5);
    // log("Boat ry change", change);
    ry += change;

    age++;
    // position.z += maxWave * 1 / defaultPeriod * sin(age);
    // drag for water
    float c = 0.1;
    float speed = velocity.mag();
    float dragMagnitude = c * speed * speed;
    PVector drag = velocity.copy();
    drag.mult(-1);
    drag.normalize();
    drag.mult(dragMagnitude);
    applyForce(drag);

    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    PVector dir = velocity.copy().normalize();

    shipShape.setStroke(true);
    shipShape.setStroke(frameColor);
    shipShape.setStrokeWeight(.5);
    shipShape.setFill(fillColor);

    pushMatrix();
    translate(position.x, position.y, position.z);
    rotateY(ry); // first rotate the "tilt"
    rotateX(PI / 2); // now flip it to be level with ground
    shape(shipShape);

    popMatrix();
  }
}
