//weel03_6_auto_for_up_for_down
void setup() {
  for(int i=3; i<=13; i++) {
    pinMode(i, OUTPUT); //都可發亮
  }
}

void loop() {
  for(int i=3; i<=13; i++) { //小到大的迴圈
    for(int k=3; k<=13; k++) digitalWrite(k, LOW);
    digitalWrite(i, HIGH); //輪到的pin會發亮
    delay(200);
  }

  for(int i=13; i>=3; i--) { //大到小的迴圈
    for(int k=3; k<=13; k++) digitalWrite(k, LOW);
    digitalWrite(i, HIGH); //輪到的pin會發亮
    delay(200);
  }
}
