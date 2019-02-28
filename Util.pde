
int _millis() {

  if (renderVideo) {
    // Don't base this off millis at all, you'll drop frames.
    return frameCount * 1000 / _frameRate + debugOffsetMillis - prerollMillis;
  } else {
    return millis() + debugOffsetMillis - prerollMillis;
  }
}

float interpolate(float a, float b, float blend) {
  float theta = blend * PI;
  float f = (1 - cos(theta)) * 0.5;
  return a * (1 - f) + b * f;
}

void polygon(PGraphics pg, float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  pg.beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    pg.vertex(sx, sy);
  }
  pg.endShape(CLOSE);
}
