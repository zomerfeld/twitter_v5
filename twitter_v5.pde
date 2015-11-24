import java.util.*;
import twitter4j.*;
import twitter4j.conf.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import wordcram.*;
import java.io.*; //Serializable is somewhere inside - find it and reduce this later


int size = 0;
int pageno = 1;
int currentTweet;
String user = "uber";
//List<Status> tweets;
List<Status> tweets = new ArrayList<Status>();
String fileStore;
String timeString;
String wordsTable;
String tsvOutput;
Table nameTable;
int currentRow = -1;
PrintWriter writer;

Twitter twitter;

void setup() {
  size(800, 600);
  timeString = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second(); //GET TIME
  println(timeString); // PRINT TIME
  fileStore = user + "_"+timeString + ".txt"; // Where to save the RAW tweets
  wordsTable = user + "_"+timeString + "weighted.txt"; //Where to save the weighted Tweets
  println(fileStore); // Prints the raw tweet location
  tsvOutput = "data/" + fileStore + ".tsv";
   writer = createWriter(tsvOutput);


  tConfigure(); // Configures Twitter Authentication, in a separate file. 
  getNewTweets(); //Gets tweets to memory
}


void draw() {
  fill(0, 40);
  rect(0, 0, width, height);

  Status status = tweets.get(currentTweet); 
  println("current tweet: " + currentTweet);
  String str = status.getText();
  if (str.charAt(0) != '@') { //IGNORES replies and tweets that starts with metions
    String getTextSani = status.getText().replace(/\r?\n/g, "  ");
    appendTextToFile(fileStore, getTextSani); //Put tweet into text file. CHANGE
    writer.println(user + "\t" + status.getId() + "\t" + status.getCreatedAt() + "\t" + getTextSani);
    fill(200);
    text(getTextSani, random(width-300), random(height-150), 300, 200); //prints tweet on screen
    delay(20);
  }

  currentTweet = currentTweet + 1; //Moves to the next tweet


  if (currentTweet >= tweets.size()-1) { //Ends the sketch when the tweet list is over
    //currentTweet = 0;
    makeWordTable();
    println("Words Weighted and Saved");
    textAlign(CENTER);
    textSize(40);
    text("Weighted & done", width/2, height/2);
    noLoop();
  }
}

// GET NEW TWEETS ////////////////////////////////////////////

void getNewTweets() {
  while (true) {

    try {
      size = tweets.size(); 
      Paging page = new Paging(pageno, 100);
      tweets.addAll(twitter.getUserTimeline(user, page));
      println("GET - getting new tweets, page number " + pageno);
      pageno++;
      if (tweets.size() == size || pageno == 5) //limit to 5 to save on API limit - TEST, comment out this line and uncomment the next
        //if (tweets.size() == size) // Unlimited - max amount of tweets (3200) //uncomment for PROD
        break;
    }
    catch(TwitterException te) {
      System.out.println("Failed to search tweets: " + te.getMessage());
      System.exit(-1);
      te.printStackTrace();
    }
  }

  System.out.println("Total: "+tweets.size());
}


// CREATE AND APPEND TO TEXT FILE ////////////////////////////////////////////


void appendTextToFile(String filename, String text) {
  File f = new File(dataPath(filename));
  if (!f.exists()) {
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
void createFile(File f) {
  File parentDir = f.getParentFile();
  try {
    parentDir.mkdirs(); 
    f.createNewFile();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
} 

// REFRESH THE DISPLAY ////////////////////////////////////////////

void keyPressed( ) {
  if ((key == 'Z') || (key == 'z')) {
    currentTweet = 0;
    loop();
  }
}

// WORDCRAM - MAKE WORD TABLE ////////////////////////////////////////////


void makeWordTable() {
  String[] stopWords = loadStrings("StopWords.txt"); //Loads Stop Words File
  //println(stopWords);
  String[] data = loadStrings(fileStore);
  StringBuilder strBuilder = new StringBuilder();
  for (int i=0; i<data.length; i++) {
    //  data[i] = data[i].toLowerCase().replaceAll("\\W", " ").replaceAll(" +", " ");
    data[i] = data[i].toLowerCase();

    strBuilder.append( data[i] );
    //println(data[i]);
  }


  String dataOne = strBuilder.toString();
  String[] names = dataOne.replaceAll("\\W", " ").replaceAll(" +", " ").split(" ");
  Map map = new HashMap();

  for (int i = 0; i < names.length; i++)
    if (Arrays.asList(stopWords).contains(names[i])) {
      //println ("ignored");
    } else {
      {
        String key = names[i];
        NameAndNumber nan = (NameAndNumber) map.get(key);
        if (nan == null)
        {
          // New entry
          map.put(key, new NameAndNumber(key, 1));
        } else
        {
          map.put(key, new NameAndNumber(key, nan.m_number + 1));
        }
      }
    }

  // Sort the collection
  ArrayList keys = new ArrayList(map.keySet());
  Collections.sort(keys, new NameAndNumberComparator(map));

  // List the top ten
  int MAX = 10; 
  int count = 0;
  Iterator it = keys.iterator();
  while (it.hasNext() && count < MAX)
  {
    String key = (String) it.next();
    NameAndNumber nan = (NameAndNumber) map.get(key);
    println(key + " -> " + nan.m_number);
    count++;
  }

  exit();
}