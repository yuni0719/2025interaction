// week03_3_void_loop_tone_delay
void setup() {
  // put your setup code here, to run once:
  pinMode(8, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  tone(8, 800, 200);
  delay(1000); // 1000ms = 1秒
}
