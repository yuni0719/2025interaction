// week07_2_arduino_blink_blink
// 修改自 week07_1_arduino_blink 只是再多插一支 LED
// 小心, 有一隻腳要接地GND, 另一支接13
// 小心, 有一隻腳要接地GND, 另一支接12
void setup() {
  pinMode(12, OUTPUT); //把第12支腳, 能送出資料 OUTPUT
  pinMode(13, OUTPUT); //把第13支腳, 能送出資料 OUTPUT

}

void loop() {
  digitalWrite(12, LOW); // 暗掉
  digitalWrite(13, HIGH); // 發亮
  delay(500);
  digitalWrite(13, LOW); // 暗掉
  digitalWrite(12, HIGH); // 發亮
  delay(500);

}
