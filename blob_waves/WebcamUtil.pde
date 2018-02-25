
String getCameraIdBySpecsOrDefault(int w, int h, int fps) {
    String camId = getCameraIdBySpecs(width, height, 30);
    if (camId == null) {
        // Just get first camera so it doesn't break
        camId = getFirstCameraId();
    }
    return camId;
}

String getFirstCameraId() {
  String[] cameras = Capture.list();
  return cameras.length > 0 ? cameras[0] : null;
}

String getCameraIdBySpecs(int w, int h, int fps) {
  String camFound = null;

  String[] cameras = Capture.list();
  for (String camId : cameras) {
    if (camId.indexOf("size=" + w + "x" + h + ",fps=" + fps) >= 0) {
      camFound = camId;
      break;
    }
  }
  return camFound;
}