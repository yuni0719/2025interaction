//week03_7_processing.mouse_serial_write
import processing.serial.*; //使用 Serial外掛
Serial myPort;
void setup(){
  size(400, 400);
  myPort = new Serial(this, "COM5", 9600);
} //COM3 COM4 COM5 還是 COM6 要查你的電腦
void mousePressed(){
  myPort.write('b'); //用 USB 傳字母'b'
}
void draw(){
  if(mousePressed) background(#FF0000);
  else background(#00FF00);
}
