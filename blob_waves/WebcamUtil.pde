
void logCameras() {
  for (String camId: Capture.list()) {
    log("Available cam:", camId);
  }
}

String getCameraIdBySpecsOrDefault(String name, int w, int h, int fps) {
  String camId = getCameraIdBySpecs(name, width, height, 30);
  if (camId == null) {
      // Just get first camera so it doesn't break
      camId = getFirstCameraId();
  }
  return camId;
}

String getCameraIdBySpecsOrDefault(int w, int h, int fps) {
    return getCameraIdBySpecsOrDefault("", w, h, fps);
}

String getFirstCameraId() {
  String[] cameras = Capture.list();
  return cameras.length > 0 ? cameras[0] : null;
}

String getCameraIdBySpecs(String name, int w, int h, int fps) {
  String specStr = name + "," + "size=" + w + "x" + h + ",fps=" + fps;
  return getCameraBySearch(specStr);
}

String getCameraIdBySpecs(int w, int h, int fps) {
  String specStr = "size=" + w + "x" + h + ",fps=" + fps;
  return getCameraBySearch(specStr);
}

String getCameraBySearch(String search) {
  String cam = null;
  for (String camId : Capture.list()) {
    if (camId.indexOf(search) >= 0) {
      cam = camId;
      break;
    }
  }
  return cam;
}
