// week09_5_Arduino_C4_G3_A3_B3
#define NOTE_C4 262
#define NOTE_G3 196
#define NOTE_A3 220
#define NOTE_B3 247


void setup() {
  Serial.begin(9600); // 建立 Serial 連線
  pinMode(8, OUTPUT); //「發聲音」的8 
  tone(8, 262, 100); 
  delay(100);
  tone(8, 196, 100);
  delay(100);
}
void serialEvent() {
//void setrialEvent() {
  while (Serial.available()) {
    char now = Serial.read();
    if (now=='R') {
      tone(8, 262, 100);
      delay(100);
    } else if(now=='L') {
      tone(8, 196, 100);
      delay(100);
    } else if(now=='U') {
      tone(8, 220, 100);
      delay(100);
    } else if(now=='D') {
      tone(8, 247, 100);
      delay(100);
    }
  }
}
void loop() {
  
}
