float[] stringToFloat(String[] s) {
  float[] f = new float[s.length];
  for (int i = 0; i < s.length; i++)
    f[i] = float(s[i]);
  return f;
}

class Data {
  Table table;
  
  // rangeMin = start row, rangeMax = end row
  Data(int rangeMin, int rangeMax, boolean restrictCountries) {
    String path = "../gdppp_growth.csv";
    if (restrictCountries)
      path = "../gdppp_growth_10k_only.csv";
    table = loadTable(path, "header");
    // Removing columns outside of (rangeMin, rangeMax)
    filterColumns(rangeMin, rangeMax);
  }
  
  void filterColumns(int rangeMin, int rangeMax) {
    int j = 0;
    int dataLen = table.getRowCount();
    for (int i = 0; i < dataLen; i++) {
      if (i < rangeMin || i >= rangeMax) {
        table.removeRow(i-j);
        j++;
      }
    }
  }
  
  String[] countries() {
    return table.getStringColumn("Country Name");
  }
  
  float[] growth() {
    // WHY IS THERE NO getFloatColumn hhhhhh
    String[] dataStr = table.getStringColumn("Growth");
    return stringToFloat(dataStr);
  }
  
  float[] gdppp() {
    String[] dataStr = table.getStringColumn("GDP Per Capita");
    return stringToFloat(dataStr);
  }
}
