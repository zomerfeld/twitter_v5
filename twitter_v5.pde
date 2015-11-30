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
String user;
//List<Status> tweets;
List<Status> tweets = new ArrayList<Status>();
String fileStore;
String timeString;
String wordsTable;
String tsvOutput;
Table nameTable;
Table dataTable;
int currentRow = -1;
PrintWriter writer;
int rowCount = 0;
int DataRowCount;
String[] users;
String[] maxes;
long lastID = 1;

Twitter twitter;

void setup() {
  size(800, 600);
  timeString = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second(); //GET TIME
  println(timeString); // PRINT TIME
  //fileStore = user + "_"+timeString + ".txt"; // Auto-generete per-use tweets filename Where to save the RAW tweets
  fileStore = "tweets";
  tsvOutput = fileStore + ".tsv";
  println(tsvOutput); // Prints the raw tweet location
  wordsTable = user + "_"+timeString + "weighted.txt"; //Where to save the weighted Tweets
  //writer = createWriter(tsvOutput);
  nameTable = loadTable("names.tsv", "tsv");
  dataTable = loadTable(tsvOutput,"tsv");
  tConfigure(); // Configures Twitter Authentication, in a separate file.
  rowCount = nameTable.getRowCount();
  println("rowcount of name table is: " + rowCount);
  maxID();

  
}

void draw() {
  fill(0, 40);
  rect(0, 0, width, height);


  if (currentTweet < tweets.size()) {
    Status status = tweets.get(currentTweet);
    println("current tweet: " + currentTweet);
    String str = status.getText();
    if (str.charAt(0) != '@') { //IGNORES replies and tweets that starts with metions
      String getTextSani = status.getText().replaceAll("(\\r|\\n)", "  "); //removes break lines from status - how wonderful
      appendTextToFile(fileStore, getTextSani); //Put tweet into text file. CHANGE
      appendTextToFile(tsvOutput, (user + "\t" + status.getId() + "\t" + status.getCreatedAt() + "\t" + getTextSani));
      fill(200);
      text(getTextSani, random(width-300), random(height-150), 300, 200); //prints tweet on screen
      delay(2);
    }
    currentTweet = currentTweet + 1; //Moves to the next tweet
  } else {
    println("clearing and moving row");
    tweets.clear();
    currentRow++;
    pageno = 1;
    currentTweet = 0;
    println("current row: " + currentRow);
    println("currentTweet: " + currentTweet);
    println("tweets.size: " + tweets.size());

    if (currentRow < rowCount) {
      user = nameTable.getString(currentRow, 1); 
      DataRowCount = dataTable.getRowCount();


      println("now retrieving: " + user);
      getNewTweets(user, 1); //Gets tweets to memory (1 is fake number, real number retrieval for sinceID is done in the actual function
      //processTweets();
    }
  }

  if (currentRow > rowCount) {
    maxID();
    noLoop();
    println("***DONEZO***");
  }
}