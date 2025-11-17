// week11_1_arduino_serial_joystick_to_processing_better
// 修改自 week10_7_arduino_serial_joystick_to_processing
void setup() {
  Serial.begin(9600);
  pinMode(2, INPUT_PULLUP);
  pinMode(8, OUTPUT);
}
int count = 0, totalX = 0, totalY = 0; // 要統計平均的值
int x0 = 512, y0 = 512;
void loop() {
  delay(30); // 要慢一點, 不然 Processing會接不了
  int x = analogRead(A2); //把搖桿的X接到A2
  int y = analogRead(A3); //把搖桿的Y接到A3
  if(count<20) { // 想收集 20 筆資料
    totalX += x; // 加總, 要看平均值
    totalY += y; //  加總, 要看平均值
    count++; // 又讀到一筆囉!
    x0 = totalX / count; // 算平均
    y0 = totalY / count; // 算平均
  }
  // Serial.write(x/4); // 把 0 ~ 1023 變 0 ~ 255
  // Serial.write(y/4);
  if (abs(x-x0) < 25) x = 128; // 數值變化太小, 直接放中間值128
  else x = (x-x0)/4.4 + 128; // 有大的數值, 就減掉中間值, 再除以4, 再加128
  if (abs(y-y0) < 25) y = 128; // 數值變化太小, 直接放中間值128
  else y = (y-y0)/4.4 + 128; // 有大的數值, 就減掉中間值, 再除以4, 再加128
  Serial.write(x); // 直接送出去
  Serial.write(y); // 直接送出去
  
  if (x > 900) tone(8, 784, 100);
  if (x < 100) tone(8, 523, 100); 
  if (y > 900) tone(8, 659, 100);
  if (y < 100) tone(8, 500, 100); // 亂寫數字
}