// week10_3_arduino_analogRead_A3
// 把 joystick 的 Y 線, 經由麵包版幫忙, 接到 MarkerUNO 另一邊的 A3
// (不能接其他的, 因為要接有~ 小蟲符號的, 代表 analog 訊號)
void setup() {
  pinMode(2, INPUT_PULLUP); 
  //pinMode(3, INPUT); // 有小蟲符號, 代表 analog 訊號
  pinMode(8, OUTPUT); // 發出聲音
}

void loop() {
  int now = analogRead(A3);
  if (now > 800) { // 變高
    tone(8, 523, 100); // 發出 523 的 Do
    delay(100);
    tone(8, 784, 100); // 發出 784 的 So
    delay(200);
  } else if (now < 200) { // 變低
    tone(8, 784, 100); // 發出 784 的 So
    delay(100);
    tone(8, 523, 100); // 發出 523 的 Do
    delay(200);
  }

}
