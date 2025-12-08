// Arduino 程式碼：專為 Processing 高效遊戲設計的單字節傳輸模式。
// 使用 Serial.write(x/4) 傳輸 0-255 的單字節數據。

const int joyXPin = A0; // 搖桿 X 軸訊號接在 A0

void setup() {
  // 確保波特率與 Processing 匹配
  Serial.begin(9600); 
}

void loop() {
  // 1. 讀取 X 軸原始數值 (0-1023)
  int xRaw = analogRead(joyXPin);

  // 2. 縮放為 0-255 範圍
  int xMapped = xRaw / 4;

  // 3. 使用 Serial.write 輸出單字節數據 (高速)
  Serial.write(xMapped);

  // 傳輸延遲 (保持低延遲，讓 Processing 能快速讀取)
  delay(10); 
}