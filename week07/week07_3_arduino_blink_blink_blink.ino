// week07_3_arduino_blink_blink_blink
// 修改自 week07_1_arduino_blink 只是再多插兩支 LED
// 使用麵包板, 每5洞是一版, 所以用 GED 接之後
// 小心, 有一隻腳要接地GND, 另一支接13
// 小心, 有一隻腳要接地GND, 另一支接12
// 小心, 有一隻腳要接地GND, 另一支接13
// 小心, 有一隻腳要接地GND, 另一支接10
void setup() {
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(12, OUTPUT); //把第12支腳, 能送出資料 OUTPUT
  pinMode(13, OUTPUT); //把第13支腳, 能送出資料 OUTPUT

}

void loop() {
  for(int i=10; i<=13; i++) {
    digitalWrite(13, LOW); // 暗掉
    digitalWrite(i-1, LOW); // 暗掉
    digitalWrite(i, HIGH); // 發亮
    delay(500);
  }
}