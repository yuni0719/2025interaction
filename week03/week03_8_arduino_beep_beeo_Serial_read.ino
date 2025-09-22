//week03_8_arduino_beep_beeo_Serial_read
void setup() {
  Serial.begin(9600);
  pinMode(8, OUTPUT);
}
int beep = 1; //一開始, 會 beep 嗶嗶叫
void serialEvent() {
  while (Serial.available()) {
    char now = Serial.read();
    if(now==' ') beep = 0; //空白字母, 不叫
    if(now=='b') beep = 1; //字母'b' 要叫
  }
}
void loop() {
  if(beep==1) { //一開始, 會倒數計時
    tone(8, 800, 200);
    delay(1000);
  }
 
}
