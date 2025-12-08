// 新增搖桿連接

import processing.serial.*;

Serial port;
float angle = 0;
// 核心修正：將 currentSpeed 變為全域變數，確保速度不會在無數據時被重置為 0。
float rotationDelta = 0.0; 
String buffer = "";
// 搖桿中心點數值 (0-1023 的中間點)
final int CENTER_VALUE = 512;
// 死區 (Dead Zone): 在 512 +/- 15 範圍內，視為速度 0。
final int DEAD_ZONE = 15; 
// 旋轉速率的極限值
final float MAX_ROTATION_SPEED = 4.0;

void setup() {
  size(600, 600);
  port = new Serial(this, "COM7", 9600); 
}

void draw() {
  background(255);
  
  // 預設速度現在是從 rotationDelta 變數取得 (rotationDelta 不會在每幀開始時被重設為 0)
  float currentSpeed = rotationDelta; 

  // 高速非阻塞：逐字讀取序列資料
  if (port != null) { // 確保埠已初始化
    while (port.available() > 0) {
      char c = port.readChar();
      if (c == '\n') {
        String data = buffer.trim();
        buffer = "";
        
        // 完全阻擋非數字的值
        if (data.length() > 0 && data.matches("\\d+")) {
          int x = int(data);
          
          // 1. 安全檢查：限制 x 必須在數值範圍內
          if (x >= 0 && x <= 1023) {
            
            // 2. 核心修正：死區檢查
            if (abs(x - CENTER_VALUE) > DEAD_ZONE) {
               // 數值在死區外：計算旋轉速度
               rotationDelta = map(x, 0, 1023, MAX_ROTATION_SPEED, -MAX_ROTATION_SPEED);
            } else {
               // 數值在死區內：將速度設為 0
               rotationDelta = 0.0;
            }
          }
        }
      } else {
        buffer += c;
      }
    }
    // 讀完所有數據後，currentSpeed 會使用最後更新的 rotationDelta
    currentSpeed = rotationDelta;
  }

  // 更新角度
  angle += currentSpeed;

  // 畫旋轉方形
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(angle));
  rectMode(CENTER);
  rect(0, 0, 200, 200);
  popMatrix();
}

