
class Note {

  int pitch;
  float normPitch;
  int pitchClass; // 0-11
  int octave;
  int channel;
  private String name;
  private Float velocity; // normalized 0-1

  Note(Integer num, Float vel, Integer chan) {

    pitch = num;
    normPitch = num / 127.0f; // 0-1
    pitchClass = num % 12;
    octave = num / 12;
    velocity = vel;
    channel = chan;
  }

  boolean isAccidental() {
    // json midi conversion calls all black keys sharps afaik
    // for our purposes (D home key) we call an "accidental" any black key except F# and C#.
    return name.charAt(1) == 'b' || (name.charAt(1) == '#' && name.charAt(0) != 'F' && name.charAt(0) != 'D');
  }
}

static String noteNameFromNumber(int num) {
  int  nNote = num % 12;
  return noteNames[nNote];
}

private static String[] noteNames = {"C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"};
