// Reddit: u/d_mystery

// Variables below can be customized
String title = "GDP Per Capita Growth (2000-2020)";
String subtitle = "Each country's current GDP Per Capita is shown in parentheses";
// String subtitle = "*This chart only includes countries with a GDP Per Capita of 10,000 USD or more. Each country's current GDP Per Capita is shown in parentheses."; 
float scale = 0.8;  // Controls the size of the bar graph, default (scale=1) is 1600 pixels wide for 20 bars
boolean saveFile = true; // Save the image as png. This make take a few seconds for very high resolutions
boolean restrictCountries = false; // Only allow countries with gdppp of 10k or more to appear

// Controls the top rank and bottom rank shown (respectively, starting from 0)
int sliceMin = 0;
int sliceMax = 20;

// All of these control the size/position of the square that
// Contains all of the bars
int numBars = sliceMax - sliceMin;
float yMin = 100 * scale;
float yMax = (775 * scale * numBars / 20) + yMin;
float xMin = 150 * scale;
float xMax = (1300 * scale * sqrt(numBars / 20)) + xMin;

float padding = 10 * scale; // Space between bars (vertical)
float flagPadding = 4 * scale; // Space between the flag and the outside of the bar (horizontal & vertical)
float textPaddingLeft = 10 * scale; // Space between the country name text and the bar (horizontal)
float textPaddingRight = 5 * scale; // Space between the number of users text and the bar (horizontal)

int backgroundColor = 255;

// Don't touch these
float highestGrowth;
float[] growth;
float[] gdppp;
String[] countries;
PImage[] flags;
color[] flagColors;
boolean includesSubtitle;
Data data;

void settings() {
  int w = round(xMax + xMin);
  int h = round(yMax + yMin / 2);
  size(w, h);
}

void setup() {
  data = new Data(sliceMin, sliceMax, restrictCountries);
  countries = data.countries();
  growth = data.growth();
  gdppp = data.gdppp();
  
  flags = new PImage[numBars];
  flagColors = new color[numBars];
  for (int i = 0; i < numBars; i++) {
    String country = countries[i];
    flags[i] = getFlag(country);
    flagColors[i] = averagePixelColor(flags[i]);
  }
  highestGrowth = data.table.getFloat(0, "Growth");
  
  includesSubtitle = !subtitle.equals("");
  if (includesSubtitle)
    yMin += 50;
}

void draw() {
  background(backgroundColor);
  noStroke();
  
  float totalSpace = yMax - yMin;
  float maxWidth = xMax - xMin;
  float paddingSpace =  padding * (numBars - 1); // Total space that is empty (between the bars)
  float barSpace = totalSpace - paddingSpace; // Total space that isn't empty
  float barHeightTotal = totalSpace / numBars; // Height of bar including padding
  float barHeight = barSpace / numBars; // Height of bar excluding padding
  
  for (int i = 0; i < numBars; i++) {
    String country = countries[i];
    PImage flag = flags[i];
    color flagColor = flagColors[i];
    float change = growth[i];
    float startY = barHeightTotal * i;
    float barWidth = maxWidth * change / highestGrowth;
    
    if (country.equals("Russian Federation")) {
      country = "Russia";
    } else if (country.equals("Czech Republic")) {
      country = "Czechia";
    } else if (country.equals("Slovak Republic")) {
      country = "Slovakia";
    } else if (country.equals("Korea, Rep.")) {
      country = "South Korea";
    }
    
    // Bar rectangle
    fill(flagColor);
    rect(xMin, startY + yMin, barWidth, barHeight);
    
    // Set the flag height such that it fits within the rectangle
    float flagHeight = barHeight - flagPadding * 2;
    // Adjust the flag width so that it keeps the same aspect ratio
    float flagWidth = (flagHeight / flag.height) * flag.width;
    
    float flagX = xMin + barWidth - flagWidth - flagPadding;
    float flagY = startY + yMin + flagPadding;
    
    fill(0);
    // Set a border around the flag with a thickness of `scale`
    rect(flagX-scale, flagY-scale, flagWidth+2*scale, flagHeight+2*scale);
    image(flag, flagX, flagY, flagWidth, flagHeight);
    
    // So flags don't overflow past the edge
    fill(backgroundColor);
    rect(0, yMin + startY, xMin, barHeightTotal);
    
    // Country name (on the left of the bar)
    fill(flagColor);
    textAlign(RIGHT, CENTER);
    textSize(18 * scale);
    text(country, xMin - textPaddingLeft, startY + yMin + barHeight / 2 - 3 * scale);
    
    // GDPPP growth + current GDPPP (on the right of the bar)
    textAlign(LEFT, CENTER);
    textSize(12 * scale);
    // Format it like 12087.3 -> 12,100 USD
    int gdpEstimateInt = round(gdppp[i] / 100) * 100;
    String gdpEstimate = addComma(str(gdpEstimateInt));
    String description = "+" + round(growth[i]) + "% (" + gdpEstimate + " USD)";
    text(description, xMin + barWidth + textPaddingRight, startY + yMin + barHeight / 2 - 3 * scale);
  }
  
  // Title
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(32 * scale);
  float yPos = yMin/2;
  if (includesSubtitle)
    yPos = yMin/3;
  text(title, width / 2, yPos);
  
  if (includesSubtitle) {
    textSize(16 * scale);
    fill(128);
    // 33% for title, 67% for subtitle
    text(subtitle, width / 2, yPos * 2);
  }
  
  if (saveFile) {
    saveFrame(title + ".png");
    // Only save once
    saveFile = false;
  }
}

PImage getFlag(String country) {
  String path = "../flags/flag-of-" + capitalize(country) + ".png";
  return loadImage(path);
}

String addComma(String num) {
  if (num.length() < 4)
    return num;
  return num.substring(0, num.length()-3) + "," + num.substring(num.length()-3, num.length());
}

color averagePixelColor(PImage image) {
  image.loadPixels();
  int numPixels = image.pixels.length;
  float[] reds = new float[numPixels];
  float[] greens = new float[numPixels];
  float[] blues = new float[numPixels];
  for (int loc = 0; loc < numPixels; loc++) {
    reds[loc] = red(image.pixels[loc]);
    greens[loc] = green(image.pixels[loc]);
    blues[loc] = blue(image.pixels[loc]);
  }
  return color(mean(reds), mean(greens), mean(blues));
}

String capitalize(String s){
  // Blantantly stolen from carykh
  return s.substring(0,1).toUpperCase()+s.substring(1,s.length());
}

String[] slice(String[] s, int sliceMin, int sliceMax) {
  int sliceLen = sliceMax - sliceMin;
  String[] res = new String[sliceLen];
  int counter = 0;
  for (int i = sliceMin; i < sliceMax; i++) {
    res[counter] = s[i];
    counter += 1;
  }
  return res;
}

float mean(float[] nums) {
  float sum = 0;
  for (int i = 0; i < nums.length; i++) {
    sum += nums[i];
  }
  return sum / nums.length;
}
