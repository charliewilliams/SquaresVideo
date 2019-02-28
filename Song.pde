import java.util.Arrays;
import java.lang.Object;
// Convert from npm midi output json to a more useful in-memory format

class Song {

  int lengthMillis;
  HashMap<Float, Note> notes;
  Float[] timestamps;
  int noteCount;

  int currentTimestampIndex = 0;

  Song(String filename) {

    notes = loadJSONFile(filename);
    noteCount = notes.size();

    // put the timestamps in order
    int count = notes.size();
    timestamps = new Float[count];

    int i = 0;
    for (Float noteTime : notes.keySet()) {
      timestamps[i] = noteTime;
      i++;
    }

    Arrays.sort(timestamps);
  }

  private HashMap<Float, Note> loadJSONFile(String name) {

    HashMap<Float, Note> notes = new HashMap<Float, Note>();

    JSONObject json = loadJSONObject(name);
    JSONArray tracks = json.getJSONArray("tracks");

    for (int i = 0; i < tracks.size(); i++) {

      JSONObject track = tracks.getJSONObject(i);

      Integer channel;

      if (track.get("id") == null && track.get("name") != null && track.getString("name").length() > 0) {
        channel = Integer.parseInt(track.getString("name"));
      } else if (track.get("id") != null) {
        channel = track.getInt("id");
      } else {
        channel = 1;
      }

      if (channel == 16) {
        continue;
      }

      JSONArray notesJSON = track.getJSONArray("notes");

      //println(notesJSON.size(), "notes in track", i, "(channel", channel, ")");

      // Pull each note's JSON, create a Note object, and add it to the "notes" hashmap
      for (int j = 0; j < notesJSON.size(); j++) {

        JSONObject noteJSON = notesJSON.getJSONObject(j);

        Integer noteNumber = noteJSON.getInt("midi");
        Float velocity = noteJSON.getFloat("velocity");
        Float timestamp = noteJSON.getFloat("time");

        Note note = new Note(noteNumber, velocity, channel);
        notes.put(timestamp, note);
      }
    }

    return notes;
  }

  // Check to see if anything in the hashmap has a smaller key than millis(), 
  // if so, trigger those events & remove from the hashmap
  ArrayList<Note> readNotes(int millis) {

    ArrayList<Note> toReturn = new ArrayList<Note>();

    for (; currentTimestampIndex < timestamps.length; currentTimestampIndex++) {

      Float timestamp = timestamps[currentTimestampIndex];

      // Don't read beyond the present instant
      if (millis < timestamp * 1000) {
        //println(millis(), "Waiting for", (int)(timestamp * 1000));
        break; // doesn't increment currentTimestampIndex
      }

      toReturn.add(notes.get(timestamp));
    }
    
    return toReturn;
  }
}
