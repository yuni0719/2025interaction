//week06_4_arduino_slow_jogging
void setup() {
  // put your setup code here, to run once:
  pinMode(8, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  tone(8, 700, 60); //你自己決定聲音的 Hz pin8, 780 Hz, 60ms
  delay(300); //等0.333秒 換下個音
  tone(8, 320, 60);
  delay(300);
} //每秒會叫3聲, 60秒會叫180聲, 180 BPM (Beat Per Minute)
