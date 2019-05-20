/*
Squares video
 */
import processing.sound.*;

boolean renderVideo = true;
//boolean renderVideo = false;

//boolean debugJumpToEnd = true;
boolean debugJumpToEnd = false;

int debugOffsetMillis = 0;
//int debugOffsetMillis = 110000;
int _frameRate = 30;
int totalFrames;
int prerollMillis = renderVideo ? 5000 : 0;
int audioMillisPreroll = -500;

int notesPerLine = 32;
int rows = 32;
float colWidth, rowHeight;

int idx = 0;

/* Cool scheme but too t-shirt-y?
 A - Dark blue       013243
 B - Orange          eb9532
 C - Golden yellow   f5e51b
 D - Green           26a65b
 E - Light blue      59abe3
 F - Purple?         4d13d1
 G - Blue-green      03c9a9
 */

/* All blues
 A - Dark blue       002170 (082056)
 B - Saturated       0069D3
 C - Powder          BFE4FF
 D - Medium          588FAA
 E - Light blue      59abe3
 F - Kitchen island  276FBF
 G - Blue-green      03c9a9
 */

////////////////////// A           B        C           D           E        F           G
//color[] colorScheme = {#002170, 0, #0069D3, #BFE4FF, 0, #588FAA, 0, #59abe3, #276FBF, 0, #03c9a9, 0};
//color[] colorScheme = {#002170, 0, #0069D3, #BFE4FF, 0, #588FAA, 0, #59abe3, #276FBF, 0, #03c9a9, 0};
//color[] colorScheme = {#013243, 0, #eb9532, #f5e51b, 0, #26a65b, 0, #4d13d1, #4d13d1, 0, #03c9a9, 0};
color[] colorScheme = {#043FDA, 0, #263479, #2294AC, 0, #D4E4E4, 0, #F9CB5F, #263479, 0, #263479, 0};

//color[] colorScheme = {#043FDA, 0, #263479, #2294AC, 0, #D4E4E4, 0, #d48c24, #263479, 0, #263479, 0};


Song song;
SoundFile file;

void setup() {
  size(1025, 1025);
  pixelDensity(2);
  colorMode(HSB, 360, 100, 100, 100);
  frameRate(_frameRate);

  song = new Song("05.json");
  file = new SoundFile(this, "05.wav");


  float offsetSecs = (prerollMillis * 2 + audioMillisPreroll) / 1000;
  totalFrames = (int)((file.duration() + offsetSecs) * _frameRate);
  if (renderVideo) {
    println("Rendering", totalFrames, "frames.");
  }

  background(0);

  colWidth = width / notesPerLine;
  rowHeight = height / rows;

  noFill();
  stroke(0, 0, 100, 100);
  strokeWeight(1);

  for (int x = 0; x <= notesPerLine; x++) {
    line(x * colWidth, 0, x * colWidth, height);
  }

  for (int y = 0; y <= rows; y++) {
    line(0, y * rowHeight, width, y * rowHeight);
  }
}

void draw() {

  if (frameCount > totalFrames) {
    exit();
  }

  int millis = _millis();

  if (!renderVideo && millis > prerollMillis && file != null && file.isPlaying() == false) {
    //file.jump((debugOffsetMillis + audioMillisPreroll) / 1000.0);
    file.play();
  }

  // Read notes from JSON in memory
  ArrayList<Note> notes = song.readNotes(millis);

  // Jump to the end
  if (debugJumpToEnd) {
    notes = song.readNotes(int(file.duration() * 1000));
  }

  if (notes == null || notes.isEmpty()) {
    if (renderVideo) {
      saveFrame("output/#####.png");
      println("frame", frameCount, "/", totalFrames);
    }
    return;
  }

  color lastDownbeatColor = 0, lastBeatColor = 0;

  for (Note n : notes) {

    int col = idx % notesPerLine;
    int row = idx / notesPerLine;

    float x = col * colWidth;
    float y = row * rowHeight;

    color baseColor = colorScheme[(n.pitchClass + 3) % 12];

    if (baseColor == 0) {
      println(n.pitchClass);
    } 


    //float hue = map(n.pitchClass, 0, 12, 90, 270);
    //float sat = idx % 4 == 0 ? 80 : constrain(n.velocity * 100, 0, 75);
    //float bri = idx % 4 == 0 ? 65 : 70;
    //color baseColor = color(hue, sat, bri);

    // if this is a big downbeat
    if (col % 16 == 0) {
      lastDownbeatColor = baseColor;
    }
    // if this is any beat
    if (col % 4 == 0) {
      lastBeatColor = baseColor;
    }

    color c = lerpColor(baseColor, lastBeatColor, 0.15);
    c = lerpColor(baseColor, lastDownbeatColor, 0.05);

    fill(c);
    stroke(c, 1);
    //stroke(hue, sat, 100, 100);
    //noStroke();
    rect(x + 0.5, y + 0.5, colWidth - 1, rowHeight - 1);

    //text(noteNameFromNumber(n.pitch), x + colWidth / 2, y);

    idx++;
  }

  if (renderVideo) {
    saveFrame("output/#####.png");
    println("frame", frameCount, "/", totalFrames);
  }
}
