List<int> myArray = List.filled(7, 0);

double? lng = 0;
double? lat = 0;

int? days;
int? act;
var testo;
int rad = 10000;
int price = 2;
late String jsonData;

String? finalAnswer;

String baseUrl = "https://flaskerrami-e55686bb66fb.herokuapp.com/your_endpoint";

Map<String, dynamic>? data;

class BuilderClass {
  get() {
    int val = myArray[0];
    return val;
  }

  getVal() {
    for (int i = 6; i >= 1; i--) {
      if (myArray[i] == 1) {
        return 1;
      }
    }
    return 0;
  }

///////////////////////
  void setFinal(data) {
    jsonData = data;
  }

  getFinalTest() {
    return jsonData;
  }

  getLng() {
    return lng;
  }

  getLat() {
    return lat;
  }

///////////////////////////
  void setFinalo(data) {
    testo = data;
  }

  getFinalTesto() {
    return testo;
  }
///////////////////////////
  // Setter methods for setting parameters

  void setArr(int index, bool value) {
    if (value == true) {
      myArray[index] = 1; // Use assignment operator '=' instead of '=='
    } else {
      myArray[index] = 0; // Use assignment operator '=' instead of '=='
    }
  }

  void setLng(double? value) {
    lng = value;
  }

  gettttFinal() {
    return data;
  }

  void setLat(double value) {
    lat = value;
  }

  void setDays(int? value) {
    days = value;
  }

  void setAct(int? value) {
    act = value;
  }

  void setRad(int value) {
    rad = value;
  }

  void setPrice(double? value) {
    if (value == 0) {
      price = 1;
    } else if (value == 1.5) {
      price = 2;
    } else if (value == 3) {
      price = 3;
    }
  }

  // Method to construct the final URL
  String buildUrl() {
    String queryString =
        ' lat=$lat&lng=$lng&day=$days&act=$act&rad=$rad&price=$price';

    for (int i = 6; i >= 0; i--) {
      int x = myArray[i];
      queryString += '&your_array=$x';
    }

    return '$baseUrl?${queryString.substring(1)}';
  }

  void test() {
    String finalUrl = buildUrl();
  }
}

void main() {
  BuilderClass myBuilder = BuilderClass();

  // Set parameters using setter functions

  // Set array elements

  // Construct the final URL
  String finalUrl = myBuilder.buildUrl();
}
