/**
 * 旋轉迷宮遊戲 V11 - 最終整合版 (多關卡, 搖桿, 音效)
 * 核心功能：多關卡管理、高效單字節搖桿控制、穩定物理與碰撞。
 * 新增功能：主頁/遊戲中 雙音樂切換、最終勝利音效。
 * 優化：移除關卡過渡延遲，實現快速切關。
 * * 硬體要求：
 * 1. Arduino 必須運行 Serial.write(x/4) 的程式 (高效單字節輸出)。
 * 2. Processing 必須安裝 Minim 函式庫。
 * 3. data/ 資料夾中須放入 bgm_menu.mp3, bgm_game.mp3, win_jingle.mp3。
 */

import processing.serial.*; // 導入 Serial 函式庫
import ddf.minim.*;      // 導入 Minim 函式庫 (用於聲音處理)

// --- 聲音變數 ---
Minim minim;             // Minim 核心物件
AudioPlayer bgmMenu;     // 主頁背景音樂
AudioPlayer bgmGame;     // 遊戲中背景音樂
AudioPlayer winJingle;   // 勝利音效

// --- 搖桿與 Serial 控制變數 ---
Serial port;
// 搖桿中心點與死區設定 (基於 0-255 範圍)
final int CENTER_VALUE_BYTE = 127; 
final int DEAD_ZONE_BYTE = 15; 
final float MAX_ROTATION_SPEED_FROM_JOYSTICK = 0.08; // 旋轉靈敏度 (弧度/幀)


// --- 遊戲狀態 ---
int gameState = 0;   // 0=開始畫面, 1=關卡選擇, 2=遊戲中, 4=最終獲勝, 5=時間到, 6=炸彈爆炸 (已移除狀態 3)
int selectedLevel = 0;
int currentLevel = 0;
int totalLevels = 12;
int menuSelection = 0; // 0=選關, 1=連續挑戰

float mazeAngle = 0;
float targetAngle = 0;
float ballX, ballY;
float ballVX = 0, ballVY = 0;
float ballRadius = 15;
float gravity = 0.6;
float friction = 0.93;
float rotationSpeed = 0.15; // 鍵盤旋轉速度 (現已移除鍵盤控制)
float maxRotation = 4.5;

int mazeSize = 500;
int cellSize = 50;
int cols, rows;

float levelStartTime = 0;
float levelFinishTime = 0;
float[] levelTimeLimit = {15, 15, 15, 15, 15, 15, 25, 25, 30, 30, 35, 40};

// **已移除 transitionTimer 和 transitionDuration，實現快速切關**

int[][][] levels;
int[][][] bombPositions;
float[][] levelStarts;
float[][] levelEnds;

void initData() {
  levels = new int[][][] {
    // 第 1 關 - 簡單直線
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,0,1,1,1,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 2 關 - 基礎迷宮
    {
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
    },
    // 第 3 關 - Z字形
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,1,1,1,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,1,1,1,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 4 關 - 螺旋
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,0,1,0,0,0,0,1,0,1},
      {1,0,1,0,1,1,0,1,0,1},
      {1,0,1,0,1,0,0,1,0,1},
      {1,0,1,0,0,0,1,1,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 5 關 - 狹窄通道
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,1,0,1,0,1,0,1,1},
      {1,0,1,0,1,0,1,0,0,1},
      {1,0,0,0,1,0,1,1,0,1},
      {1,1,0,1,1,0,0,0,0,1},
      {1,0,0,0,0,0,1,1,0,1},
      {1,0,1,1,0,1,1,0,0,1},
      {1,0,1,0,0,0,0,0,1,1},
      {1,0,0,0,1,1,1,0,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 6 關 - 挑戰
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,1,0,0,0,0,1},
      {1,0,1,0,1,0,1,1,0,1},
      {1,0,1,0,0,0,1,0,0,1},
      {1,0,1,1,1,1,1,0,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,0,1,1,1,0,1},
      {1,0,0,0,0,1,0,0,0,1},
      {1,0,1,1,0,0,0,1,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 7 關 - 十字路口
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,0,1,0,0,0,1},
      {1,0,1,1,0,1,0,1,0,1},
      {1,0,1,0,0,0,0,1,0,1},
      {1,0,0,0,0,1,0,0,0,1},
      {1,1,1,1,1,1,0,1,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,0,1,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 8 關 - 迷宮花園
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,0,1,1,0,1},
      {1,0,1,0,0,0,0,1,0,1},
      {1,0,1,0,1,1,0,1,0,1},
      {1,0,0,0,1,1,0,0,0,1},
      {1,1,1,0,0,0,0,1,1,1},
      {1,0,0,0,1,1,0,0,0,1},
      {1,0,1,1,0,0,0,1,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 9 關 - 雙路選擇
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,1,1,1,0,0,1},
      {1,0,1,0,0,0,1,0,1,1},
      {1,0,1,1,1,0,1,0,0,1},
      {1,0,0,0,1,0,0,0,1,1},
      {1,1,1,0,1,1,1,0,0,1},
      {1,0,0,0,0,0,1,1,0,1},
      {1,0,1,1,1,0,0,0,0,1},
      {1,0,0,0,0,0,1,1,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 10 關 - 窄巷挑戰
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,1,1,1,1,1,1,1,0,1},
      {1,0,0,0,1,0,0,0,0,1},
      {1,0,1,0,1,0,1,1,1,1},
      {1,0,1,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,0,0,0,0,0,0,1,0,1},
      {1,1,1,1,1,1,0,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 11 關 - 螺旋迷宮
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,0,1,0,0,0,0,1,0,1},
      {1,0,1,0,0,1,0,1,0,1},
      {1,0,1,0,1,0,0,1,0,1},
      {1,0,1,0,0,0,0,1,0,1},
      {1,0,1,1,0,1,1,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    },
    // 第 12 關 - 終極試煉
    {
      {1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,1,0,1,0,0,1},
      {1,0,1,0,1,0,1,0,1,1},
      {1,0,1,0,0,0,0,0,0,1},
      {1,0,1,1,1,0,1,1,0,1},
      {1,0,0,0,1,0,0,1,0,1},
      {1,1,1,0,1,1,0,1,0,1},
      {1,0,0,0,0,0,0,0,0,1},
      {1,0,1,1,1,1,1,1,0,1},
      {1,1,1,1,1,1,1,1,1,1}
    }
  };
  
  bombPositions = new int[][][] {
    {}, {}, {}, {}, {}, {},
    {{225, 225}},
    {{225, 175}, {225, 325}},
    {{325,375}},
    {{375,425}},
    {{275, 275}},
    {{175, 175}, {325, 325}}
  };
  
  levelStarts = new float[][] {
    {75, 75}, {75, 75}, {75, 75}, {75, 75}, {75, 75}, {75, 75},
    {75, 75}, {225, 75}, {75, 75}, {425, 75}, {75, 75}, {75, 75}
  };
  
  levelEnds = new float[][] {
    {425, 425}, {425, 425}, {425, 425}, {425, 425}, {425, 425}, {425, 425},
    {425, 425}, {225, 425}, {425, 425}, {75, 425}, {175, 275}, {425, 425}
  };
}

int[][] getMaze() { return levels[currentLevel]; }
float getStartX() { return levelStarts[currentLevel][0]; }
float getStartY() { return levelStarts[currentLevel][1]; }
float getEndX() { return levelEnds[currentLevel][0]; }
float getEndY() { return levelEnds[currentLevel][1]; }
int[][] getBombs() { return bombPositions[currentLevel]; }
float getTimeLimit() { return levelTimeLimit[currentLevel]; }

PFont font;

void setup() {
  size(800, 800);
  initData();
  cols = getMaze()[0].length;  
  rows = getMaze().length;
  ballX = getStartX();
  ballY = getStartY();
  
  // 初始化 Serial 連線
  try {
    // 核心修正：強制連線 COM7
    port = new Serial(this, "COM7", 9600); 
    println("嘗試連接 COM7 埠...");
  } catch (Exception e) {
    println("錯誤：無法連接到 COM7。請檢查 Arduino 是否連線。");
  }
  
  // Minim 聲音初始化
  minim = new Minim(this);
  try {
      bgmMenu = minim.loadFile("bgm_menu.mp3");
      bgmGame = minim.loadFile("bgm_game.mp3");
      winJingle = minim.loadFile("win_jingle.mp3");
      bgmMenu.loop();
      println("所有聲音檔案載入成功。");
  } catch (Exception e) {
      println("警告：找不到音效檔案，聲音功能將失效。");
  }
  
  font = createFont("Microsoft JhengHei", 32);
  textFont(font);
  levelStartTime = millis() / 1000.0;
}

// 程式結束時停止聲音
void stop() {
  if (bgmMenu != null) bgmMenu.close();
  if (bgmGame != null) bgmGame.close();
  if (winJingle != null) winJingle.close();
  if (minim != null) minim.stop();
  super.stop();
}

// 聲音管理函式
void handleMusicState() {
  // 0: Start, 1: Select, 2: Playing, 4: Final Win, 5: Time Up, 6: Bomb Hit
  if (gameState == 0 || gameState == 1) { // 主頁或選關
      if (bgmGame != null && bgmGame.isPlaying()) bgmGame.pause();
      if (bgmMenu != null && !bgmMenu.isPlaying()) bgmMenu.loop();
  } else if (gameState == 2) { // 遊戲中
      if (bgmMenu != null && bgmMenu.isPlaying()) bgmMenu.pause();
      if (bgmGame != null && !bgmGame.isPlaying()) bgmGame.loop();
  } else if (gameState == 4 || gameState == 5 || gameState == 6) { // 最終獲勝或失敗畫面
      if (bgmMenu != null && bgmMenu.isPlaying()) bgmMenu.pause();
      if (bgmGame != null && bgmGame.isPlaying()) bgmGame.pause();
  }
}

void draw() {
  background(20);
  handleMusicState(); // 處理音樂狀態切換
  
  if (gameState == 0) drawStartScreen();
  else if (gameState == 1) drawLevelSelect();
  else if (gameState == 2) drawGame();
  else if (gameState == 4) drawWinScreen(); // **修正：移除對 drawLevelComplete() 的呼叫**
  else if (gameState == 5) drawTimeUpScreen();
  else if (gameState == 6) drawBombHitScreen();
}

// --- 搖桿輸入處理函式 (V11 新增/優化) ---
void handleSerialInput() {
  
  if (port != null) { 
    // 關鍵修正：只讀取最新的數據，丟棄舊數據
    while (port.available() > 1) { 
        port.read();
    }
    
    // 讀取最新的單個 Byte 數據 (0-255)
    if (port.available() > 0) {
        int xByte = port.read(); 
        
        if (xByte >= 0 && xByte <= 255) {
          
          if (abs(xByte - CENTER_VALUE_BYTE) > DEAD_ZONE_BYTE) {
             
             // 數值在死區外：計算旋轉速度 (已修正方向)
             float mappedSpeed = map(xByte, 0, 255, -MAX_ROTATION_SPEED_FROM_JOYSTICK, MAX_ROTATION_SPEED_FROM_JOYSTICK);
             
             // 更新 targetAngle
             targetAngle += mappedSpeed;
             
             // 限制最大旋轉角度
             targetAngle = constrain(targetAngle, -maxRotation, maxRotation);
          } 
        }
    }
  }
}

void drawStartScreen() {
  textAlign(CENTER, CENTER);
  fill(255, 200, 0);
  textSize(60);
  text("旋轉迷宮", width/2, 120);
  fill(255);
  textSize(24);
  text("遊戲規則", width/2, 200);
  textSize(30);
  fill(200);
  // **修正說明：使用搖桿**
  text("1. 使用搖桿 X 軸控制迷宮傾斜角度", width/2, 250);
  text("2. 讓黃色球從綠色起點滾到紅色終點", width/2, 300);
  text("3. 碰到紅色炸彈立即失敗", width/2, 350);
  text("4. 按 R 鍵可以隨時重置當前關卡", width/2, 400);
  fill(255);
  textSize(20);
  text("圖示說明", width/2, 470);
  fill(0, 255, 0);
  noStroke();
  rectMode(CENTER);
  rect(width/2 - 150, 540, 35, 35);
  fill(255);
  textSize(18);
  text("起點", width/2 - 150, 585);
  fill(255, 0, 0);
  rect(width/2, 540, 35, 35);
  fill(255);
  text("終點", width/2, 585);
  fill(50);
  stroke(255, 0, 0);
  strokeWeight(3);
  ellipse(width/2 + 150, 540, 25, 25);
  fill(255);
  noStroke();
  text("炸彈", width/2 + 150, 585);
  rectMode(CORNER);
  if (frameCount % 60 < 30) {
    fill(255, 255, 0);
    textSize(32);
    text("按 Enter 鍵進入關卡選擇", width/2, 680);
  }
}

void drawLevelSelect() {
  textAlign(CENTER, CENTER);
  fill(255, 200, 0);
  textSize(60);
  text("選擇關卡", width/2, 80);
  int c = 4;
  int r = 3;
  float buttonSize = 80;
  float spacing = 100;
  float startX = width/2 - (c * spacing) / 2 + spacing/2;
  float startY = 180;
  for (int i = 0; i < totalLevels; i++) {
    int col = i % c;
    int row = i / c;
    float x = startX + col * spacing;
    float y = startY + row * spacing;
    boolean isSelected = (i == selectedLevel && menuSelection == 0);
    if (isSelected) {
      fill(255, 200, 0);
      stroke(255, 255, 0);
      strokeWeight(4);
    } else {
      fill(80);
      stroke(150);
      strokeWeight(2);
    }
    rectMode(CENTER);
    rect(x, y, buttonSize, buttonSize, 10);
    fill(255);
    textSize(32);
    text(i + 1, x, y - 5);
    if (bombPositions[i].length > 0) {
      fill(255, 100, 100);
      textSize(14);
      text("💣×" + bombPositions[i].length, x, y + 25);
    }
  }
  rectMode(CORNER);
  if (menuSelection == 1) {
    fill(255, 200, 0);
    stroke(255, 255, 0);
    strokeWeight(4);
  } else {
    fill(80);
    stroke(150);
    strokeWeight(2);
  }
  rectMode(CENTER);
  rect(width/2, 530, 350, 60, 10);
  fill(255);
  textSize(24);
  text("從第 1 關開始連續挑戰", width/2, 530);
  rectMode(CORNER);
  fill(200);
  textSize(20);
  // **修正說明：使用搖桿取代方向鍵**
  text("搖桿/M 鍵選擇 | Enter 確認", width/2, 630);
  fill(150);
  textSize(18);
  text("按 ESC 返回主選單", width/2, 680);
}

void drawGame() {
  translate(width/2, height/2);
  
  // ** V11 核心改動：搖桿控制旋轉 **
  handleSerialInput(); 
  
  mazeAngle = lerp(mazeAngle, targetAngle, 0.15);
  rotate(mazeAngle);
  drawMaze();  
  drawBombs();
  updateBall();
  drawStartEnd();
  drawBall();
  checkWin();
  checkTimeUp();
  checkBombHit();
  rotate(-mazeAngle);
  
  fill(255);
  textAlign(LEFT);
  textSize(20);
  text("第 " + (currentLevel + 1) + " / " + totalLevels + " 關", -380, -360);
  float timeLeft = getTimeLimit() - (millis() / 1000.0 - levelStartTime);
  if (timeLeft < 5) fill(255, 0, 0);
  else if (timeLeft < 10) fill(255, 200, 0);
  else fill(100, 255, 100);
  textSize(24);
  text("剩餘: " + nf(max(0, timeLeft), 1, 1) + " 秒", -380, -330);
  fill(200);
  textSize(16);
  // **修正說明：移除方向鍵提示**
  text("搖桿 X: 傾斜", -380, -295); 
  text("R: 重置", -380, -275);
  textAlign(RIGHT);
  fill(0, 255, 0);
  textSize(16);
  text("綠色 = 起點", 380, -360);
  fill(255, 0, 0);
  text("紅色 = 終點", 380, -335);
  if (getBombs().length > 0) {
    fill(255, 100, 100);
    text("避開炸彈！", 380, -310);
  }
}

void drawMaze() {
  stroke(200);
  strokeWeight(2);
  fill(80);
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (getMaze()[i][j] == 1) {
        float x = j * cellSize - mazeSize/2;
        float y = i * cellSize - mazeSize/2;
        rect(x, y, cellSize, cellSize);
      }
    }
  }
  noFill();
  stroke(255);
  strokeWeight(4);
  rect(-mazeSize/2, -mazeSize/2, mazeSize, mazeSize);
}

void drawBombs() {
  int[][] bombs = getBombs();
  for (int i = 0; i < bombs.length; i++) {
    float bx = bombs[i][0] - mazeSize/2;
    float by = bombs[i][1] - mazeSize/2;
    fill(50);
    stroke(255, 0, 0);
    strokeWeight(3);
    ellipse(bx, by, 25, 25);
    stroke(255, 0, 0);
    strokeWeight(2);
    line(bx - 8, by - 8, bx + 8, by + 8);
    line(bx + 8, by - 8, bx - 8, by + 8);
  }
}

void drawStartEnd() {
  fill(0, 255, 0);
  stroke(255);
  strokeWeight(2);
  rectMode(CENTER);
  rect(getStartX() - mazeSize/2, getStartY() - mazeSize/2, 35, 35);
  fill(255, 0, 0);
  rect(getEndX() - mazeSize/2, getEndY() - mazeSize/2, 35, 35);
  rectMode(CORNER);
}

void drawBall() {
  fill(255, 200, 0);
  stroke(255, 150, 0);
  strokeWeight(2);
  ellipse(ballX - mazeSize/2, ballY - mazeSize/2, ballRadius * 2, ballRadius * 2);
}

void updateBall() {
  float gravX = sin(mazeAngle) * gravity;
  float gravY = cos(mazeAngle) * gravity;
  ballVX += gravX;
  ballVY += gravY;
  ballVX *= friction;
  ballVY *= friction;
  float oldX = ballX;
  float oldY = ballY;
  ballX += ballVX;
  if (checkCollision(ballX, ballY)) {
    ballX = oldX;
    ballVX *= -0.2;
  }
  ballY += ballVY;
  if (checkCollision(ballX, ballY)) {
    ballY = oldY;
    ballVY *= -0.2;
  }
  ballX = constrain(ballX, ballRadius, mazeSize - ballRadius);
  ballY = constrain(ballY, ballRadius, mazeSize - ballRadius);
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
      if (getMaze()[row][col] == 1) return true;
    }
  }
  return false;
}

boolean checkBombCollision(float x, float y) {
  // 檢查球是否碰到炸彈 (這段邏輯在 checkBombHit 中處理)
  return false;
}

void checkWin() {
  if (dist(ballX, ballY, getEndX(), getEndY()) < 25) {
    levelFinishTime = millis() / 1000.0 - levelStartTime;
    
    // 檢查是否為最終關卡過關
    if (currentLevel + 1 >= totalLevels) {
      // 最終關卡過關 (進入 Win Final 畫面)
      gameState = 4;
      if (bgmGame != null && bgmGame.isPlaying()) bgmGame.pause();
      if (winJingle != null) {
          winJingle.rewind(); 
          winJingle.play();
      }
    } else {
      // ** 快速切換到下一關 **
      currentLevel++;
      gameState = 2; // 保持在遊戲中狀態
      resetGame();
    }
  }
}

void checkTimeUp() {
  if (getTimeLimit() - (millis() / 1000.0 - levelStartTime) <= 0) gameState = 5;
}

void checkBombHit() {
  int[][] bombs = getBombs();
  for (int i = 0; i < bombs.length; i++) {
    float bx = bombs[i][0];
    float by = bombs[i][1];
    if (dist(ballX, ballY, bx, by) < ballRadius + 12) {
      gameState = 6;
      if (bgmGame != null && bgmGame.isPlaying()) bgmGame.pause();
      // 可在此處添加爆炸音效
    }
  }
}

// 移除 drawLevelComplete() 函式

void drawTimeUpScreen() {
  textAlign(CENTER, CENTER);
  fill(255, 50, 50);
  textSize(70);
  text("時間到！", width/2, 250);
  fill(255);
  textSize(32);
  text("第 " + (currentLevel + 1) + " 關挑戰失敗", width/2, 350);
  fill(200);
  textSize(24);
  text("按 Enter 返回關卡選擇", width/2, 500);
  text("按 R 重新挑戰本關", width/2, 550);
}

void drawBombHitScreen() {
  textAlign(CENTER, CENTER);
  fill(255, 0, 0);
  textSize(70);
  text("炸彈爆炸！", width/2, 250);
  fill(255);
  textSize(32);
  text("第 " + (currentLevel + 1) + " 關挑戰失敗", width/2, 350);
  fill(200);
  textSize(24);
  text("按 Enter 返回關卡選擇", width/2, 500);
  text("按 R 重新挑戰本關", width/2, 550);
}

void drawWinScreen() {
  textAlign(CENTER, CENTER);
  fill(255, 215, 0);
  textSize(80);
  text("全部通關！", width/2, 200);
  fill(255);
  textSize(40);
  text("恭喜完成 " + totalLevels + " 個關卡！", width/2, 280);
  for (int i = 0; i < 50; i++) {
    star(random(width), random(height), random(2, 8));
  }
  fill(255);
  textSize(32);
  text("按 Enter 返回關卡選擇", width/2, 500);
  // **修正按鍵為 M**
  text("按 M 回到主選單", width/2, 550);
  if (frameCount % 40 < 20) {
    fill(255, 255, 0);
    textSize(36);
    text("你是迷宮大師！", width/2, 380);
  }
}

void star(float x, float y, float size) {
  fill(255, 255, 0, random(100, 255));
  noStroke();
  beginShape();
  for (int i = 0; i < 5; i++) {
    float a = TWO_PI * i / 5 - PI/2;
    vertex(x + cos(a) * size, y + sin(a) * size);
    a += PI / 5;
    vertex(x + cos(a) * size/2, y + sin(a) * size/2);
  }
  endShape(CLOSE);
}

void resetGame() {
  ballX = getStartX();
  ballY = getStartY();
  ballVX = 0;
  ballVY = 0;
  mazeAngle = 0;
  targetAngle = 0;
  levelStartTime = millis() / 1000.0;
}

void fullReset() {
  currentLevel = 0;
  resetGame();
}

void keyPressed() {
  if (gameState == 0) {
    if (key == ENTER) gameState = 1;
  }
  else if (gameState == 1) { // 關卡選擇畫面
    if (keyCode == LEFT) {
      if (menuSelection == 0) {
        selectedLevel--;
        if (selectedLevel < 0) selectedLevel = totalLevels - 1;
      }
    }
    if (keyCode == RIGHT) {
      if (menuSelection == 0) {
        selectedLevel++;
        if (selectedLevel >= totalLevels) selectedLevel = 0;
      }
    }
    if (keyCode == UP) menuSelection = 0;
    if (keyCode == DOWN) menuSelection = 1;
    if (key == ENTER) {
      gameState = 2;
      if (menuSelection == 1) fullReset();
      else {
        currentLevel = selectedLevel;
        resetGame();
      }
    }
    if (keyCode == ESC) {
      // **修正 ESC 鍵行為**
      key = 0; 
      gameState = 0;
    }
  }
  else if (gameState == 2) { // 遊戲中
    // **移除鍵盤傾斜控制** (僅保留重置)
    
    if (key == 'r' || key == 'R') resetGame();
  }
  else if (gameState == 4) { // 最終獲勝畫面
    if (key == ENTER) {
      gameState = 1;
      menuSelection = 0;
    }
    // **修正按鍵為 M**
    if (key == 'm' || key == 'M') {
      gameState = 0;
      fullReset();
    }
  }
  else if (gameState == 5 || gameState == 6) { // 失敗畫面 (時間到 / 炸彈爆炸)
    if (key == ENTER) {
      gameState = 1;
      menuSelection = 0;
      selectedLevel = 0;
    }
    if (key == 'r' || key == 'R') {
      gameState = 2;
      resetGame();
    }
  }
}
