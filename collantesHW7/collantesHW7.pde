/*
Xavier Collantes
12/9/2015
CPSC 211-01
Assignment #7
Stock Reader: Takes updated stock proces and projects a visual representation in the form of a graph. 
*/

Table table;
PFont font;
String [] dateArr;
float [] openArr;
float [] highArr;
float [] lowArr;
float [] closeArr;
int [] volArr;

int isInterval = 0;
float minCloseArrLine = 0;

int period = 30;
int rowNum = 0;
final String symbol = "TSLA";
color graphColor;

float [] closeArrLine = new float[period];  //To be used only in the drawLine(); data multiplied by a magnitude

PImage bg;
float intervalXAcc = 0;
float intervalX = 0;

/**
@discription Sets up screen size, black backbfound, fonts, gets stock prices, period to a default 30 days.  
*/
void setup()
{
  size(1980, 1080);
  background(0);
  font = createFont("./../data/Panton-LightCaps.otf", 12, true);
  strokeWeight(3);

  getQuotes();
  setPeriod(30);    //1 month (default)
  formatLine();
  drawLine();
  setColor();
  save("img.png");
  bg = loadImage("img.png");
  background(bg);
}

/**
Continously refreshes the background to contain the image of a line, then keeps track of the mouseX value 
to draw a horizontal line as a marker to show the price of stock of a certain day.  
*/
void draw()
{
  background(bg);
  if (mouseX % (width / period) >= -2 && mouseX % (width / period) <= 2)
  {
    stroke(200);
    strokeWeight(3);
    line(mouseX, 0, mouseX, height);
    priceText();
    dateText();
    priceChange();
  } 
  else
  {
    priceText();
    dateText();
    priceChange();
  }
}

/**
 Pre: 
 Post: 
 Creates a table object with downloaded historical stock quotes from Yahoo!
 Prices and dates are assigned to arrays for each column of data.  
 */
void getQuotes()
{
  //table = loadTable("http://ichart.yahoo.com/table.csv?s=" + symbol, "header, csv");
  table = loadTable("http://www.google.com/finance/historical?q=NASDAQ%3A" + symbol + "&ei=dkJhWYC7FoSfjAHx0p3ADg&output=csv", "header, csv");

  rowNum = table.getRowCount();
  println(table.getRowCount() + " rows in doc.");

  dateArr = new String[rowNum];
  openArr = new float[rowNum];
  highArr = new float[rowNum];
  lowArr = new float[rowNum];
  closeArr = new float[rowNum];
  volArr = new int[rowNum];

  int i = 0;
  for (TableRow row : table.rows())
  {
    dateArr[i] = row.getString("Date");
    openArr[i] = row.getFloat("Open");
    highArr[i] = row.getFloat("High");
    lowArr[i] = row.getFloat("Low");
    closeArr[i] = row.getFloat("Close");
    volArr[i] = row.getInt("Volume");

    //println(symbol + " closed at " + closeArr[i] + " on " + dateArr[i] + " (Row Number: " + i + ")");

    i++;
  }
}

/**
The period is set to a default 30 or one month but could be used to later include one year, 
six months, or all time stock line on the graph.  
*/
void setPeriod(int n)
{
  int i = 0;
  intervalX = width / n;

  while (i < n)
  {
    closeArrLine[i] = closeArr[i] * 20;
    println("(Row Number: " + i + ")");
    i++;
  }
  minCloseArrLine = min(closeArrLine);
  print("setPeriod");
  println(max(closeArrLine));
}

/**
Line drawn on the graph may be too big or out of the frame of the window.  The function adjusts the data set for the 
line on the graph to be in the window by taking the minimum value and moving it above the lower limit. Then the rest of the 
data set is also adjusted proportionally to keep the line from falling below the bottom of the window.  
*/
void formatLine()
{
  int h = 0;
  float minCloseArrLine = (float) min(closeArrLine);

  if (minCloseArrLine > 100)
  {
    while (h < closeArrLine.length)
    {
      closeArrLine[h] = closeArrLine[h] - abs(minCloseArrLine - 100);
      h++;
    }
  }

  if (minCloseArrLine < 100)
  {
    while (h < closeArrLine.length - 1)
    {
      closeArrLine[h] = closeArrLine[h] + abs(minCloseArrLine - 100);
      h++;
    }
  }
}

/**
Main component of the line drawn on the graph.  This is where the line 
is actually drawn by taking two points (target point and next point) to draw the line
based on the intervalX variable to determine interval along the X-Axis.  
*/
void drawLine()
{
  int m = 0;
  stroke(109);
  strokeWeight(3);
  while (m < closeArrLine.length - 1)
  {

    line(intervalXAcc, myY(closeArrLine[m]), intervalXAcc += intervalX, myY(closeArrLine[m + 1])); 
    m++;
  }
}

/**
If the a gain is made from the previous close a day ago then the color scheme of the graph 
turns green and red if a loss is incurred.  
*/
void setColor()
{
  if (gain())
  {
    graphColor = color(0, 255, 0);
  } else
  {
    graphColor = color(255, 0, 0);
  }
}


/**
Evaluates if there is a gain or loss is made from latest day in data set 
from the day before the latest day.  
*/
boolean gain()
{
  if (closeArr[0] >= closeArr[1]) 
  {
    return true;
  } else
  {
    return false;
  }
}

/**
Displays the price of the stock selected by the mouseX variable.  
*/
void priceText()
{
  textAlign(CENTER, CENTER);
  fill(graphColor);
  textFont(font, 40);
  text(symbol, width / 2, height / 12); 
  textFont(font, 75);
  text("$" + nf(closeArr[(int) map(mouseX, 0, width, 0, period)], 0, 2), width / 2, height / 6 + 50);
}

/**
Displays the change in price of the closing stock from the latest day and the day before in the data set
in terms of a positive or negative.  
*/
void priceChange()
{
  textFont(font, 50);
  textAlign(CENTER, CENTER);
  fill(graphColor);
  text(nfp(closeArr[0] - closeArr[1], 2, 2), width / 2, height / 6);
}

/**
Displays the date of the stock selected by the mouseX variable in format of YYYY-MM-DD.  
*/
void dateText()
{
  textFont(font, 30);
  textAlign(CENTER, CENTER);
  fill(graphColor);
  text(dateArr[(int) map(mouseX, 0, width, 0, period)], width / 2, height / 6 * 2);
}

/**
 @param num Takes a Y value and converts it to its invert as to create 
 a graph much resembling a Cartesian coordinate plane.  
 */
float myY(float num)
{
  return (height - num);
}