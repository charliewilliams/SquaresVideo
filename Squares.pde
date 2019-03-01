/*
Squares video
 */
import processing.sound.*;

boolean renderVideo = true;

int debugOffsetMillis = 0;
//int debugOffsetMillis = 110000;
int _frameRate = 30;
int totalFrames;
int prerollMillis = renderVideo ? 10000 : 0;
int audioMillisPreroll = 0;

int notesPerLine = 32;
int rows = 32;
float colWidth, rowHeight;

int idx = 0;

Song song;
SoundFile file;

void setup() {
  size(1024, 1024);
  pixelDensity(2);
  colorMode(HSB, 360, 100, 100, 100);
  frameRate(_frameRate);

  song = new Song("05.json");
  file = new SoundFile(this, "05.wav");

  if (renderVideo) {
    float offsetSecs = (prerollMillis * 2 + audioMillisPreroll) / 1000;
    totalFrames = (int)((file.duration() + offsetSecs) * _frameRate);
    println("Rendering", totalFrames, "frames.");
  }

  background(0);

  colWidth = width / notesPerLine;
  rowHeight = height / rows;

  noFill();
  stroke(0, 0, 100, 100);
  strokeWeight(1);

  for (int x = 0; x < notesPerLine; x++) {
    line(x * colWidth, 0, x * colWidth, height);
  }

  for (int y = 0; y < rows; y++) {
    line(0, y * rowHeight, width, y * rowHeight);
  }
}

void draw() {

  if (frameCount > totalFrames) {
    exit();
  }

  int millis = _millis();

  if (millis > prerollMillis && file != null && file.isPlaying() == false) {
    //file.jump((debugOffsetMillis + audioMillisPreroll) / 1000.0);
    file.play();
  }

  // Read notes from JSON in memory
  ArrayList<Note> notes = song.readNotes(millis);

  if (notes == null || notes.isEmpty()) {
    saveFrame("output/#####.png");
    return;
  }

  for (Note n : notes) {

    int col = idx % notesPerLine;
    int row = idx / notesPerLine;

    float x = col * colWidth;
    float y = row * rowHeight;

    float hue = map(n.pitchClass, 0, 12, 0, 360);
    float sat = idx % 4 == 0 ? 100 : n.velocity * 100;
    float bri = idx % 4 == 0 ? 80 : 100;
    color c = color(hue, sat, bri, 100);
    fill(c);
    stroke(hue, sat, 100, 100);
    //noStroke();
    rect(x, y, colWidth, rowHeight);

    //text(noteNameFromNumber(n.pitch), x + colWidth / 2, y);

    idx++;
  }

  saveFrame("output/#####.png");
}
