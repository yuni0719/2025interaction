//week03_2_for_5_times
void setup() {
  // put your setup code here, to run once:
  pinMode(8, OUTPUT);
  for(int i=0; i<5; i++) {
    tone(8, 800, 200);
    delay(1000);
  }
}

void loop() {
  // put your main code here, to run repeatedly:

}
