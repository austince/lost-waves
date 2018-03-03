
void logCameras() {
  for (String camId: Capture.list()) {
    log("Available cam:", camId);
  }
}


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
  String cam = null;

  String specStr = "size=" + w + "x" + h + ",fps=" + fps;
  for (String camId : Capture.list()) {
    if (camId.indexOf(specStr) >= 0) {
      cam = camId;
      break;
    }
  }
  return cam;
}
