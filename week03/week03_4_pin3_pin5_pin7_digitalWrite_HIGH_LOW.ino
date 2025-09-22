// week03_4_pin3_pin5_pin7_digitalWrite_HIGH_LOW
void setup() {
  // put your setup code here, to run once:
  pinMode(3, OUTPUT); // Do
  pinMode(5, OUTPUT); // Mi
  pinMode(7, OUTPUT); // So
  pinMode(8, OUTPUT); // 8~8~8~ 叭叭叭
}

void loop() {
  digitalWrite(3, HIGH);
  tone(8, 523, 200);
  delay(1000);
  digitalWrite(3, LOW);

  digitalWrite(5, HIGH);
  tone(8, 659, 200);
  delay(1000);
  digitalWrite(5, LOW);  

  digitalWrite(7, HIGH);
  tone(8, 784, 200);
  delay(1000);
  digitalWrite(7, LOW);   
}
