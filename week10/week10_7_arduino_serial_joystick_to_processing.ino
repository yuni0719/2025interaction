// week10_7_arduino_serial_joystick_to_processing
// 修改自 week10_5_arduino_serial_joystick_to_processing
void setup() {
  Serial.begin(9600);
  pinMode(2, INPUT_PULLUP);
  pinMode(8, OUTPUT);
}

void loop() {
  delay(30); // 要慢一點, 不然 Processing會接不了
  int x = analogRead(A2); //把搖桿的X接到A2
  int y = analogRead(A3); //把搖桿的Y接到A3
  Serial.write(x/4); // 把 0 ~ 1023 變 0 ~ 255
  Serial.write(y/4);
  if (x > 900) tone(8, 784, 100);
  if (x < 100) tone(8, 523, 100); 
  if (y > 900) tone(8, 659, 100);
  if (y < 100) tone(8, 500, 100);
}
