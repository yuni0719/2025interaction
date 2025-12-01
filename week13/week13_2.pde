import processing.serial.*;
Serial port;

void setup() {
  size(400, 200);
  port = new Serial(this, "COM6", 9600); 
}

void draw() {
  if (port.available() > 0) {
    String data = trim(port.readString());
    if (data != null) {
      println("Receive: " + data);
    }
  }
}
