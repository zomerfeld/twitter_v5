import java.util.*;
import twitter4j.*;
import twitter4j.conf.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import wordcram.*; // I don't think I need this anymore
import java.io.*; 


int size = 0;
int pageno = 1;
int currentTweet;
String user;
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
long lastID = 1;

Twitter twitter;

void setup() {
  size(800, 600);
  timeString = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second(); //GET TIME
  println(timeString); // PRINT TIME
  //fileStore = user + "_"+timeString + ".txt"; // Auto-generete per-use tweets filename Where to save the RAW tweets
  fileStore = "tweets"; //plain text file
  tsvOutput = fileStore + ".tsv"; //tweets.tsv file (currently taking the name from the plain text version
  println("plain text file: " + tsvOutput); // Prints the raw text tweet file location
  wordsTable = user + "_"+timeString + "weighted.txt"; //Where to save the weighted Tweets
  nameTable = loadTable("names.tsv", "tsv"); //the tables where the usernames and last IDs is saved
  dataTable = loadTable(tsvOutput,"tsv"); //The table where the tweets will be saved
  tConfigure(); // Configures Twitter Authentication. The configure function is in a separate file that doesn't go on github.
  
  rowCount = nameTable.getRowCount();
  println("rowcount of name table is: " + rowCount);
  
  maxID(); //Goes over the tweets tsv file, and stores the last ID per each user in names.tsv

  
}

void draw() {
  fill(0, 40);
  rect(0, 0, width, height); //fades the tweets from the screen by printing a semi-opaque black square on top of them


  if (currentTweet < tweets.size()) { //combs over all the tweets in the memory from the get new tweets function
    Status status = tweets.get(currentTweet);
    println("current tweet: " + currentTweet);
    String str = status.getText();
    if (str.charAt(0) != '@') { //IGNORES replies and tweets that starts with mentions
      String getTextSani = status.getText().replaceAll("(\\r|\\n)", "  "); //removes break lines from tweets - how wonderful
      appendTextToFile(fileStore, getTextSani); //Put tweet into the plain text file. 
      appendTextToFile(tsvOutput, (user + "\t" + status.getId() + "\t" + status.getCreatedAt() + "\t" + getTextSani)); //puts tweets (and user, tweet ID and date+time) into the TSV file
      fill(200);
      text(getTextSani, random(width-300), random(height-150), 300, 200); //prints tweet on screen
      delay(2);
    }
    currentTweet = currentTweet + 1; //Moves to the next tweet
  } else { //if all tweets in memory are processed or there are no tweets in memory
    println("clearing and moving row");
    tweets.clear(); //remove all tweets from memory (if it's not already empty)
    currentRow++; // moves one row in the names.tsv (nameTable)
    pageno = 1; //sets the page to be 1 again, to start retrieving tweets from another user
    currentTweet = 0; // resets the tweet count to 0
    println("current row in name table: " + currentRow);
    println("currentTweet in memory: " + currentTweet);
    println("tweets.size (total tweets in mem): " + tweets.size());

    if (currentRow < rowCount) { //if there are more users to look up in name table
      user = nameTable.getString(currentRow, 1); //gets the username from the name table
      DataRowCount = dataTable.getRowCount(); //counts the rows in the tweets table


      println("now retrieving: " + user);
      getNewTweets(user, 1); //Gets tweets to memory (1 is fake number, real number retrieval for sinceID is done in the actual maxID() function
      //processTweets(); //doesn't do anything, empty function. Keeping it here just in the meantime
    }
  }

  if (currentRow > rowCount) { //When there are no new tweets anymore
    maxID(); // updates names.tsv with the last ids in tweets.tsv
    noLoop(); //stops the loop
    println("***DONEZO***");
  }
}