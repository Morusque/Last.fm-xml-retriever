
// for some reason it has become difficult to export the entire listening history of a given last.fm user in a single file
// I didn't like the idea of relying on the last.fm web interface to consult my data and the possibility of losing access to it anytime so I wrote this processing sketch
// download processing and open this file with it, request a last.fm api key, then set the proper values for those two variables right there
// run the sketch, wait until it closes itself, the listening history will then be stored in a .xml file located in the root folder of the sketch

String your_user_name = "USER_NAME";// <---- replace this
String your_api_key = "API_KEY";// <---- replace this

void setup() {
  XML result = loadXML("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user="+your_user_name+"&api_key="+your_api_key+"&format=xml&limit=200");
  XML resultXml = parseXML("<base></base>");
  for (int requestNb=0; result.getChild("recenttracks").getChildren("track").length>0; requestNb++) {
    XML[] tracks = result.getChild("recenttracks").getChildren("track");
    int oldestTime = -1; 
    for (int i=0; i<tracks.length; i++) {
      try {
        String artist = tracks[i].getChild("artist").getContent();
        String artistId = tracks[i].getChild("artist").getString("mbid");
        String title = tracks[i].getChild("name").getContent();
        String album = tracks[i].getChild("album").getContent();
        String albumId = tracks[i].getChild("album").getString("mbid");
        int timeStamp = tracks[i].getChild("date").getInt("uts");
        String timeString = tracks[i].getChild("date").getContent();
        String url = tracks[i].getChild("url").getContent();
        XML[] images = tracks[i].getChildren("image");
        String image = "";
        for (int im=0; im<images.length; im++) if (images[im].getContent().length()>image.length()) image = images[im].getContent();
        boolean found = false;
        XML[] addedTracks = resultXml.getChildren("track");
        for (int j=0; j<addedTracks.length&&!found; j++) {
          if (addedTracks[j].getChild("artist").getContent().equals(artist)) {
            if (addedTracks[j].getChild("title").getContent().equals(title)) {
              found=true;
              XML newDate = new XML("date");
              newDate.setContent(timeString);
              newDate.setInt("uts", timeStamp);
              addedTracks[j].getChild("listens").addChild(newDate);
            }
          }
        }
        if (!found) {
          XML newTrack = new XML("track");
          XML newTrackArtist = new XML("artist");
          newTrackArtist.setContent(artist);
          newTrackArtist.setString("mbid", artistId);
          XML newTrackTitle = new XML("title");
          newTrackTitle.setContent(title);
          XML newTrackAlbum = new XML("album");
          newTrackAlbum.setContent(album);
          newTrackAlbum.setString("mbid", albumId);
          XML newTrackUrl = new XML("url");
          newTrackUrl.setContent(url);
          XML newTrackImage = new XML("image");
          newTrackImage.setContent(image);
          XML newTrackDate = new XML("date");
          newTrackDate.setContent(timeString);
          newTrackDate.setInt("uts", timeStamp);
          newTrack.addChild(newTrackTitle);
          newTrack.addChild(newTrackArtist);
          newTrack.addChild(newTrackAlbum);
          newTrack.addChild(newTrackUrl);
          newTrack.addChild(newTrackImage);
          newTrack.addChild(new XML("listens"));
          newTrack.getChild("listens").addChild(newTrackDate);
          resultXml.addChild(newTrack);
        }

        if (oldestTime==-1||oldestTime>timeStamp) oldestTime = timeStamp;
      }
      catch (Exception e) {
        println(e);
      }
    }
    result = loadXML("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user="+your_user_name+"&api_key="+your_api_key+"&format=xml&limit=200&to="+oldestTime);
    println("new time : "+oldestTime);
    println("----------------------------------------------------");
    saveXML(resultXml, "result.xml");
  }
  exit();
}