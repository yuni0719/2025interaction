// 旋轉迷宮遊戲 + Arduino 搖桿

import processing.serial.*; // 導入 Serial 函式庫

// --- 遊戲狀態 ---
int gameState = 0;   // 0=開始畫面, 1=遊戲中, 2=獲勝

// --- 搖桿與旋轉控制變數 ---
Serial port;
float mazeAngle = 0;  // 迷宮旋轉角度
float targetAngle = 0;  // 目標角度(用於平滑控制)

// 搖桿中心點與死區設定 (基於 0-255 範圍)
// 由於 Arduino 傳輸 0-255，所以這裡的中心點和死區必須調整
final int CENTER_VALUE_BYTE = 127; 
final int DEAD_ZONE_BYTE = 15; // 相當於 0-1023 範圍的 +/- 60，更寬裕
final float MAX_ROTATION_SPEED_FROM_JOYSTICK = 0.08; // 旋轉靈敏度 (弧度/幀)


// --- 球體與物理變數 ---
float ballX, ballY;     // 球的位置
float ballVX = 0, ballVY = 0; // 球的速度
float ballRadius = 15;
float gravity = 0.3;  // 增加重力
float friction = 0.98;  // 更滑
float rotationSpeed = 0.08;  // 原始平滑旋轉速度 
float maxRotation = PI / 2;  // 最大旋轉角度限制 (90度)

int mazeSize = 500;
int cellSize = 50;
int cols, rows;

// 迷宮牆壁
int[][] maze = {
  {1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,1,0,0,0,0,1},
  {1,0,1,0,1,0,1,1,0,1},
  {1,0,1,0,0,0,1,0,0,1},
  {1,0,1,1,1,0,1,0,1,1},
  {1,0,0,0,0,0,0,0,0,1},
  {1,1,1,0,1,1,1,1,0,1},
  {1,0,0,0,0,0,0,1,0,1},
  {1,0,1,1,1,1,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1}
};

float startX = 75;
float startY = 75;
float endX = 425;
float endY = 425;

PFont font;

void setup() {
  size(800, 800);
  cols = maze[0].length;
  rows = maze.length;
  
  try {
    port = new Serial(this, "COM7", 9600); 
    println("嘗試連接 COM7 埠...");
  } catch (Exception e) {
    println("錯誤：無法連接到 COM7。請檢查 Arduino 是否連線。");
  }

  ballX = startX;
  ballY = startY;
  
  // 設定支援中文的字體
  font = createFont("Microsoft JhengHei", 32); 
  textFont(font);
}

void draw() {
  background(20);
  
  if (gameState == 0) {
    drawStartScreen();
  } else if (gameState == 1) {
    drawGame();
  } else if (gameState == 2) {
    drawWinScreen();
  }
}

// --- 遊戲核心迴圈 ---
void drawGame() {
  translate(width/2, height/2);
  
  // 將搖桿輸入整合到 targetAngle 的計算中
  handleSerialInput();
  
  // 平滑旋轉過渡 (使用搖桿設定的 targetAngle)
  mazeAngle = lerp(mazeAngle, targetAngle, 0.15);
  
  rotate(mazeAngle);
  
  drawMaze();
  updateBall();
  drawStartEnd();
  drawBall();
  checkWin();
  
  rotate(-mazeAngle); // 旋轉回來繪製 UI
  
  // 顯示控制資訊
  fill(255);
  textAlign(LEFT);
  textSize(16);
  text("搖桿 X: 傾斜迷宮", -380, -360);
  text("R: 重置", -380, -335);
  text("角度: " + nf(degrees(mazeAngle), 1, 1) + "°", -380, -310);
  
  // 提示文字
  textAlign(RIGHT);
  fill(0, 255, 0);
  text("綠色方塊 = 起點", 380, -360);
  fill(255, 0, 0);
  text("紅色方塊 = 終點", 380, -335);
}

// --- 搖桿輸入處理函式 ---
void handleSerialInput() {
  
  if (port != null) { // 確保埠已連接
    // 關鍵修正：只讀取最新的數據，丟棄舊數據
    while (port.available() > 1) { // 如果數據多於 1 Byte (即舊數據)，先讀掉它
        port.read();
    }
    
    // 讀取最新的單個 Byte 數據 (0-255)
    if (port.available() > 0) {
        int xByte = port.read(); 
        
        // 檢查讀值是否有效 (單字節範圍)
        if (xByte >= 0 && xByte <= 255) {
          
          // 核心修正：死區檢查 (使用 0-255 的中心點)
          if (abs(xByte - CENTER_VALUE_BYTE) > DEAD_ZONE_BYTE) {
             
             // 數值在死區外：計算旋轉速度
             // 將 0-255 範圍映射到 MAX ~ -MAX
             float mappedSpeed = map(xByte, 0, 255, -MAX_ROTATION_SPEED_FROM_JOYSTICK, MAX_ROTATION_SPEED_FROM_JOYSTICK);
             
             // 更新 targetAngle：將映射的速度持續加到目標角度上
             targetAngle += mappedSpeed;
             
             // 限制最大旋轉角度
             targetAngle = constrain(targetAngle, -maxRotation, maxRotation);
          } 
          // 搖桿在死區內時，targetAngle 維持不變，實現靜止
        }
    }
  }
}


// --- 物理更新 ---
void updateBall() {
  // 重力方向：相對於迷宮傾斜。這裏的邏輯是正確的。
  float gravX = sin(mazeAngle) * gravity;
  float gravY = cos(mazeAngle) * gravity;
  
  ballVX += gravX;
  ballVY += gravY;
  ballVX *= friction;
  ballVY *= friction;
  
  float oldX = ballX;
  float oldY = ballY;
  
  ballX += ballVX;
  ballY += ballVY;
  
  if (checkCollision(ballX, ballY)) {
    // 碰撞處理: 退回舊位置並反彈
    ballX = oldX;
    ballY = oldY;
    ballVX *= -0.5; // 減速反彈
    ballVY *= -0.5;
    
    // 避免微小抖動
    if (abs(ballVX) < 0.2) ballVX = 0;
    if (abs(ballVY) < 0.2) ballVY = 0;
  }
  
  // 限制球在迷宮邊界內 (防止跑出 mazeSize)
  ballX = constrain(ballX, ballRadius, mazeSize - ballRadius);
  ballY = constrain(ballY, ballRadius, mazeSize - ballRadius);
}


// --- 遊戲介面與狀態函式 ---

void drawStartScreen() {
  textAlign(CENTER, CENTER);
  
  // 標題
  fill(255, 200, 0);
  textSize(60);
  text("旋轉迷宮", width/2, 120);
  
  // 遊戲規則
  fill(255);
  textSize(24);
  text("遊戲規則", width/2, 200);
  
  textSize(18);
  fill(200);
  text("1. 使用搖桿 X 軸控制迷宮傾斜角度", width/2, 250); // 已修改說明
  text("2. 讓黃色球從綠色起點滾到紅色終點", width/2, 285);
  text("3. 小心不要碰到灰色牆壁", width/2, 320);
  text("4. 按 R 鍵可以隨時重置", width/2, 355);
  
  // 圖示說明
  fill(255);
  textSize(20);
  text("圖示說明", width/2, 420);
  
  // 綠色方塊 - 起點
  fill(0, 255, 0);
  noStroke();
  rectMode(CENTER);
  rect(width/2 - 100, 490, 35, 35);
  fill(255);
  textSize(18);
  text("起點", width/2 - 100, 535);
  
  // 紅色方塊 - 終點
  fill(255, 0, 0);
  rect(width/2 + 100, 490, 35, 35);
  fill(255);
  text("終點", width/2 + 100, 535);
  rectMode(CORNER);
  
  // 黃色球
  fill(255, 200, 0);
  noStroke();
  ellipse(width/2, 600, 30, 30);
  fill(255);
  textSize(18);
  text("你的球", width/2, 645);
  
  // 開始提示 - 閃爍效果
  if (frameCount % 60 < 30) {
    fill(255, 255, 0);
    textSize(32);
    text("按 Enter鍵 開始遊戲", width/2, 720);
  } else {
    fill(255, 255, 0, 150);
    textSize(28);
    text("按 Enter 鍵 開始遊戲", width/2, 720);
  }
}

void drawMaze() {
  stroke(200);
  strokeWeight(2);
  fill(80);
  
  // 繪製迷宮牆壁
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (maze[i][j] == 1) {
        float x = j * cellSize - mazeSize/2;
        float y = i * cellSize - mazeSize/2;
        rect(x, y, cellSize, cellSize);
      }
    }
  }
  
  // 繪製外框
  noFill();
  stroke(255);
  strokeWeight(4);
  rect(-mazeSize/2, -mazeSize/2, mazeSize, mazeSize);
}

void drawStartEnd() {
  // 起點 - 綠色方塊
  fill(0, 255, 0);
  stroke(255);
  strokeWeight(2);
  rectMode(CENTER);
  rect(startX - mazeSize/2, startY - mazeSize/2, 35, 35);
  
  // 終點 - 紅色方塊
  fill(255, 0, 0);
  rect(endX - mazeSize/2, endY - mazeSize/2, 35, 35);
  rectMode(CORNER);
}

void drawBall() {
  fill(255, 200, 0);
  stroke(255, 150, 0);
  strokeWeight(2);
  ellipse(ballX - mazeSize/2, ballY - mazeSize/2, ballRadius * 2, ballRadius * 2);
}

boolean checkCollision(float x, float y) {
  int checkPoints = 8;
  for (int i = 0; i < checkPoints; i++) {
    float angle = TWO_PI * i / checkPoints;
    float checkX = x + cos(angle) * ballRadius;
    float checkY = y + sin(angle) * ballRadius;
    
    int col = int(checkX / cellSize);
    int row = int(checkY / cellSize);
    
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      if (maze[row][col] == 1) {
        return true;
      }
    }
  }
  return false;
}

void checkWin() {
  float d = dist(ballX, ballY, endX, endY);
  if (d < 25) {
    gameState = 2;
  }
}

void drawWinScreen() {
  textAlign(CENTER, CENTER);
  
  // 勝利標題
  fill(255, 215, 0);
  textSize(80);
  text("恭喜過關!", width/2, 200);
  
  // 星星效果
  for (int i = 0; i < 50; i++) {
    float x = random(width);
    float y = random(height);
    float size = random(2, 8);
    fill(255, 255, 0, random(100, 255));
    noStroke();
    star(x, y, size);
  }
  
  // 重新開始提示
  fill(255);
  textSize(32);
    text("按 Enter 再玩一次", width/2, 500);
    text("按 ESC 回到主選單", width/2, 550);
  
  if (frameCount % 40 < 20) {
    fill(255, 255, 0);
    textSize(36);
    text("你贏了!", width/2, 350);
  }
}

void star(float x, float y, float size) {
  beginShape();
  for (int i = 0; i < 5; i++) {
    float angle = TWO_PI * i / 5 - PI/2;
    float sx = x + cos(angle) * size;
    float sy = y + sin(angle) * size;
    vertex(sx, sy);
    angle += PI / 5;
    sx = x + cos(angle) * size/2;
    sy = y + sin(angle) * size/2;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void resetGame() {
  ballX = startX;
  ballY = startY;
  ballVX = 0;
  ballVY = 0;
  mazeAngle = 0;
  targetAngle = 0;
}

void keyPressed() {
  println("按鍵偵測: key=" + key + " keyCode=" + keyCode + " gameState=" + gameState);
  
  // 開始畫面 - 按Enter開始
  if (gameState == 0) {
    if (key == ' ' || keyCode == 32 || key == ENTER || keyCode == ENTER) {
      gameState = 1;
      resetGame();
      println(">>> 遊戲開始!");
    }
  }
  
  // 遊戲中的控制
  else if (gameState == 1) {
    // 移除所有鍵盤傾斜控制，僅保留重置功能
    
    if (key == 'r' || key == 'R') {
      resetGame();
    }
  }
  
  // 勝利畫面
  else if (gameState == 2) {
    if (key == ENTER) {
      gameState = 1;
      resetGame();
    }
    if (keyCode == ESC) {
      key = 0;  // 防止關閉視窗
      gameState = 0;
    }
  }
}
