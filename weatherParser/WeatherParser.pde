ArrayList<Station> stations;
boolean printSuccesses = false;
boolean printFailures = false;

void setup() {
  size(800, 800);

  String[] lines;

  //load each line from the first file
  lines = loadStrings("Lawrence1978To2000Edited.csv");
  
  //just print out number of lines to show that something is happening
  println("Number of rows: " + lines.length);

  //load lines from the second file:
  String[] lines2 = loadStrings("Lawrence2000To2019Edited.csv");

  //join the two arrays together:
  lines = concat(lines, lines2);

  //print out one line as an example of what format to expect:
  println(lines[5]);

  //initialize stations and the quick(ish) method for adding new rows in:
  stations = new ArrayList<Station>();
  int tempstarter = 0;

  //add the first entry to the arraylist:
  stations.add(new Station( lines[0] ));

  //add the other entries:
  for (int i = 1; i < lines.length; i++) {
    //if the station isn't the same as the last one (if it is this line automatically adds it):
    if (!stations.get(tempstarter).addRow(lines[i])) {
      //keep track of whether or not the line actually gets added to an existing station's data:
      boolean success = false;
      //try adding the line to each station:
      for (int n = 0; n < stations.size(); n++) {
        if (stations.get(n).addRow(lines[i])) {
          //if one takes it:
          success = true;
          tempstarter = n;
          break;
        }
      }
      if (!success) {
        //if one doesn't take it create a new station:
        stations.add(new Station( lines[i] ));
      }
    }
  }

  //output the number of stations for debugging purposes:
  println("Number of stations: " + stations.size());

  //output some details about each station:
  for (int i = 0; i < stations.size(); i++) {
    Station cur = stations.get(i);
    println("station: " + cur.station + ", loc: " + cur.loc + ", size: " + cur.dates.size());
  }
  
  //////////print out the successes.csv file:
  if (printSuccesses) {
    //list of dates when KU cancelled school historically:
    String success = "\"1978-02-12\",\"1978-02-13\",\"1983-02-02\",\"1985-02-12\",\"1993-01-20\",\"1993-02-25\",\"1997-01-27\",\"2001-02-09\"" +
      ",\"2002-01-30\",\"2002-01-31\",\"2004-02-05\",\"2006-03-13\",\"2008-02-06\",\"2008-02-21\",\"2009-12-24\",\"2010-01-06\"" +
      ",\"2010-01-10\",\"2011-01-19\",\"2011-02-01\",\"2011-02-02\",\"2013-02-21\",\"2013-02-22\",\"2014-02-04\",\"2014-02-05\"" +
      ",\"2018-02-20\",\"2018-02-22\",\"2019-02-06\",\"2018-02-07\"";
  
    //split the list based off of commas
    String[] csvSuccess = split(success, ",");

    //ininitialize these as dates
    Date[] dates = new Date[csvSuccess.length];
    for (int i = 0; i < csvSuccess.length; i++) {
      dates[i] = new Date(csvSuccess[i]);
    }
    
    //instantiate the output file writer:
    PrintWriter out = createWriter("successes.csv");
    
    //output the average data for each day
    for (int i = 0; i < dates.length; i++) {
      out.println(printAveDate(dates[i]));
    }
    //clean up file writer
    out.flush();
    out.close();
  }
  
  /////////print out the failures.csv file:
  if (printFailures) {
    //have to create a list of fail dates (went with Jan 20th through March 5th 2014-2018)
    String fails = new String();
    for (int y = 2018; y > 2014; y--) {
      for (int m = 1; m < 4; m++) {
        for (int d = (m==1)?20:1; d < 32; d=(d>=5&&m==3)?33:(d>=28&&m==2)?33:d+1) {
          fails+="\"" + 2018 + "-";
          fails+="0"+m+"-";
          if (d > 9)
            fails+=d + "\",";
          else
            fails+="0"+d+"\",";
        }
      }
    }

    //initialize the dates similar to when we did the successes
    String[] csvFails = split(fails, ",");
    Date[] dates = new Date[csvFails.length-1];
    for (int i = 0; i < csvFails.length-1; i++) {
      dates[i] = new Date(csvFails[i]);
    }

    //create the file writer:
    PrintWriter out = createWriter("failures.csv");

    for (int i = 0; i < dates.length; i++) {
      out.println(printAveDate(dates[i]));
    }
    //clean up file writer:
    out.flush();
    out.close();
  }
  
  printDate(new Date(12, 3, 2006));
  
}

//helper method (now for debug purposes only).  prints out data from each station about a specific date in time
void printDate(Date day) {
  println("printing data for: "+day.month+"/"+day.day+"/"+day.year); 
  int possessed = 0; 
  for (int n = 0; n < stations.size(); n++) {
    if (stations.get(n).printDate(day)) { 
      possessed++;
    }
  }
  if (possessed == 0) { 
    println("[No stations had this date]");
  }
}

//averages out all the station's data about a specific date (if there is none, it skips over it)
String printAveDate(Date day) {
  //println("printing averaged data for: "+day.month+"/"+day.day+"/"+day.year);

  double[] aveWEPAXN = new double[6]; //stores sum and eventually average for the values of awind, evap, percip, tavg, tmax, tmin
  int[] avenum = new int[6]; //stores numbers of entries added

  boolean foundone = false; 

  for (int i = 0; i < stations.size(); i++) {
    Station cur = stations.get(i); 
    int dind = cur.dayIndex(day); 
    if (dind != -1) {
      foundone = true; 
      if (cur.awind.get(dind) != Double.MIN_VALUE) {
        aveWEPAXN[0]+=cur.awind.get(dind); 
        avenum[0]++;
      }
      if (cur.evap.get(dind)!=Double.MIN_VALUE) {
        aveWEPAXN[1]+=cur.evap.get(dind); 
        avenum[1]++;
      }
      if (cur.percip.get(dind)!=Double.MIN_VALUE) {
        aveWEPAXN[2]+=cur.percip.get(dind); 
        avenum[2]++;
      }
      if (cur.tavg.get(dind)!=Integer.MIN_VALUE) {
        aveWEPAXN[3]+=cur.tavg.get(dind); 
        avenum[3]++;
      }
      if (cur.tmax.get(dind)!=Integer.MIN_VALUE) {
        aveWEPAXN[4]+=cur.tmax.get(dind); 
        avenum[4]++;
      }
      if (cur.tmin.get(dind)!=Integer.MIN_VALUE) {
        aveWEPAXN[5]+=cur.tmin.get(dind); 
        avenum[5]++;
      }
    }
  }
  if (foundone) {
    aveWEPAXN[0] /= avenum[0]; 
    aveWEPAXN[1] /= avenum[1]; 
    aveWEPAXN[2] /= avenum[2]; 
    aveWEPAXN[3] /= avenum[3]; 
    aveWEPAXN[4] /= avenum[4]; 
    aveWEPAXN[5] /= avenum[5]; 
    
    //return method if it's going to be printed to console:
    //return ("awind: "+aveWEPAXN[0]+", evap: "+aveWEPAXN[1]+", percip: "+aveWEPAXN[2]+", tavg: "+aveWEPAXN[3]+", tmax: "+aveWEPAXN[4]+", tmin: "+aveWEPAXN[5]);
    //return method if it's going to be outputted as a .csv file:
    return ("\""+aveWEPAXN[0]+"\",\""+aveWEPAXN[2]+"\",\""+aveWEPAXN[4]+"\",\""+aveWEPAXN[5]+"\"");
  }
  return "";
}

//stores data relating to each station:
class Station {
  String station; 
  String loc; 
  ArrayList<Date> dates; 
  ArrayList<Double> awind; 
  ArrayList<Double> evap; 
  ArrayList<Double> percip; 
  ArrayList<Integer> tavg, tmax, tmin; 
  ArrayList<String> WT01, WT03, WT04, WT05, WT06, WT08, WT09, WT11; 
  
  public Station(String row) {
    String[] comsep = split(row, ","); 
    station = comsep[0]; 
    loc = comsep[1] + comsep[2]; 

    dates = new ArrayList<Date>(); 
    awind = new ArrayList<Double>(); 
    evap = new ArrayList<Double>(); 
    percip = new ArrayList<Double>(); 
    tmax = new ArrayList<Integer>(); 
    tmin = new ArrayList<Integer>(); 
    tavg = new ArrayList<Integer>(); 
    WT01 = new ArrayList<String>(); 
    WT03 = new ArrayList<String>(); 
    WT04 = new ArrayList<String>(); 
    WT05 = new ArrayList<String>(); 
    WT06 = new ArrayList<String>(); 
    WT08 = new ArrayList<String>(); 
    WT09 = new ArrayList<String>(); 
    WT11 = new ArrayList<String>(); 

    addRow(row);
  }

  //returns true if it was able to add the row, false if otherwise
  public boolean addRow(String row) {
    String[] comsep = split(row, ","); 
    if (!comsep[0].equals(station)) {
      return false;
    }

    dates.add(new Date(comsep[3])); 
    if (comsep[4].length() > 0) { 
      awind.add(Double.valueOf(comsep[4].substring(1, comsep[4].length()-1)));
    } else {
      awind.add(Double.MIN_VALUE);
    }
    if (comsep[5].length() > 0) { 
      evap.add(Double.valueOf(comsep[5].substring(1, comsep[5].length()-1)));
    } else {
      evap.add(Double.MIN_VALUE);
    }
    if (comsep[6].length() > 0) { 
      percip.add(Double.valueOf(comsep[6].substring(1, comsep[6].length()-1)));
    } else {
      percip.add(Double.MIN_VALUE);
    }
    if (comsep[7].length() > 0) { 
      tavg.add(Integer.valueOf(comsep[7].substring(1, comsep[7].length()-1)));
    } else {
      tavg.add(Integer.MIN_VALUE);
    }
    if (comsep[8].length() > 0) { 
      tmax.add(Integer.valueOf(comsep[8].substring(1, comsep[8].length()-1)));
    } else {
      tmax.add(Integer.MIN_VALUE);
    }
    if (comsep[9].length() > 0) { 
      tmin.add(Integer.valueOf(comsep[9].substring(1, comsep[9].length()-1)));
    } else {
      tmin.add(Integer.MIN_VALUE);
    }
    WT01.add(comsep[10]); 
    WT03.add(comsep[11]); 
    WT04.add(comsep[12]); 
    WT05.add(comsep[13]); 
    WT06.add(comsep[14]); 
    WT08.add(comsep[15]); 
    WT09.add(comsep[16]); 
    WT11.add(comsep[17]); 

    return true;
  }
  
  //prints the station's data about a day to the terminal
  public boolean printDate(Date day) {
    for (int i = 0; i < dates.size(); i++) {
      if (dates.get(i).equals(day)) {
        print("Station: " + station + ", awind: "); 
        if (awind.get(i) != Double.MIN_VALUE) {
          print(awind.get(i));
        } else { 
          print("[N/A]");
        }
        print(", evap: "); 
        if (evap.get(i) != Double.MIN_VALUE) {
          print(evap.get(i));
        } else { 
          print("[N/A]");
        }
        print(", percip "); 
        if (percip.get(i) != Double.MIN_VALUE) {
          print(percip.get(i));
        } else { 
          print("[N/A]");
        }
        print(", tavg: "); 
        if (tavg.get(i) != Integer.MIN_VALUE) {
          print(tavg.get(i));
        } else { 
          print("[N/A]");
        }
        print(", tmax: "); 
        if (tmax.get(i) != Integer.MIN_VALUE) {
          print(tmax.get(i));
        } else { 
          print("[N/A]");
        }
        print(", tmin: "); 
        if (tmin.get(i) != Integer.MIN_VALUE) {
          println(tmin.get(i));
        } else { 
          println("[N/A]");
        }
        return true;
      }
    }
    return false;
  }
  
  //returns the index of the entry that matches the specified day (not clean at all, but it works)
  public int dayIndex(Date day) {
    for (int i = 0; i < dates.size(); i++) {
      if (dates.get(i).equals(day)) {
        return i;
      }
    }
    return -1;
  }
}

//helper data structure for storing and manipulating a date
class Date {
  int day, month, year; 
  public Date(String date) {
    String[] dashSep = split(date, "-"); 
    dashSep[0] = dashSep[0].substring(1); 
    dashSep[2] = dashSep[2].substring(0, 2); 
    year = int(dashSep[0]); 
    month = int(dashSep[1]); 
    day = int(dashSep[2]);
  }

  public Date(int day, int month, int year) {
    this.day = day; 
    this.month = month; 
    this.year = year;
  }

  public boolean equals(Date other) {
    return (other.year == year && other.month == month && other.day == day);
  }
}

//probably not necessary
void draw() {
  clear();
}
