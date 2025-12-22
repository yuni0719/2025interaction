/**
 * Arduino 搖桿程式 - 高效單字節模式
 * 1. 傳送 X 軸 (0-255) 給 Processing
 * 2. 偵測左右撥動，並在 Pin 8 觸發蜂鳴器音效
 */

const int joyXPin = A0; 
const int buzzerPin = 8; // 蜂鳴器接腳

// 用於紀錄是否已經叫過，防止連續發聲
boolean hasBeeped = false; 

void setup() {
  Serial.begin(9600); 
  pinMode(buzzerPin, OUTPUT); 
}

void loop() {
  // 1. 讀取與傳送數據
  int xRaw = analogRead(joyXPin);
  int xMapped = xRaw / 4; // 轉換為 0-255
  Serial.write(xMapped);

  // 2. 撥動音效邏輯 (左右選關卡時會叫)
  // 當搖桿推到底 (小於 50 或 大於 200) 且之前沒叫過時發聲
  if ((xMapped < 50 || xMapped > 200) && !hasBeeped) {
    tone(buzzerPin, 880, 50); // 發出短促高音 (880Hz, 0.05秒)
    hasBeeped = true;         // 標記已發聲
  } 
  
  // 當搖桿回到中心點附近，重置標記，下次撥動才會再叫
  if (xMapped > 100 && xMapped < 150) {
    hasBeeped = false; 
  }

  delay(10); 
}