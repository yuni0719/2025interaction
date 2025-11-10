// week10_6_processing_serial_joystick_coins
// 利用 USB Serial 傳 joystick 的量, 讓板子左右移動
import processing.serial.*;
Serial myPort;
void setup() {
  size(500, 500);
  myPort = new Serial(this, "COM6", 9600);
  rectMode(CENTER); // 四邊形的正中心, 當成座標
} // 預設是左上角當成座標。可改成正中心當座標
int x = 250, y = 400, now;
float dx = 0; //移動的速度
void draw() {
  background(#FFFFA0);
  rect(x, y, 100, 20);
  if(myPort.available() > 0) {
    now = myPort.read(); // 0 ~ 255
    dx = (now~127) / 10.0; // -128 ~ +127
    if(abs(dx)<0.21) dx = 0; // 因有殘值, 所以太小就設
  }
  x += dx;
}
    
