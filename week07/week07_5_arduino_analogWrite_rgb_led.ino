//week07_5_arduino_analogWrite_rgb_led
void setup() {
  pinMode(3, OUTPUT); //換最左邊的紅色
  // RGB LED 最長的那根, 是接地GMD
  pinMode(6, OUTPUT); //藍色(GMD的旁邊那個)
  pinMode(5, OUTPUT); // 綠色(最外面)
  //(有PWM功能, 可0-255輸出), 要輸出
} // 這些特別的腳, 分別是 第3、5、6、9、10、11, 共6個腳, 都可控制它的亮暗程度

void loop() {
  analogWrite(6, 0); // 藍色關掉
  analogWrite(3, 255); // 最亮的紅色
  delay(500); // 每0.5秒
  analogWrite(3, 0); // 紅色關掉
  analogWrite(5, 255); // 最亮的綠色
  delay(500); // 每0.5秒
  analogWrite(3, 0); // 綠色關掉
  analogWrite(5, 255) // 最亮的藍色
  delay(500); // 每0.5秒
}
