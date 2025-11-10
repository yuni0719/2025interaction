// week10_5_processing_serial_joystick
import processing.serial.*;
Serial myPort;
void setup() {
  size(512, 200);
  myPort = new Serial(this, "COM6", 9600);
}
int now = 255;
void draw() {
  background(now); // 色彩 0-128-255
  ellipse(now, 100, 8, 8); // 小白球, 顯示位置
  if(myPort.available() > 0) {
    now = myPort.read();
  }
}
    
