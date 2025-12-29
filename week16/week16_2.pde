/**
 * 旋轉迷宮遊戲 V11 - 最終整合 UI 修復版
 * 1. 修正：通關後按下 Enter 或 M 返回時，會立即停止勝利音效。
 * 2. 修正：通關、炸彈爆炸與時間到畫面的提示文字縮小，並拉大行間距，保持視覺一致。
 * 3. 核心：支援 360 度無限旋轉。
 * 4. 整合：12 個關卡數據 (維持原始單行格式)、炸彈音效、雙音樂切換。
 * 5. 點上面 Sketch -> Library -> Manage Libraries -> 搜尋 Minim -> install
 * 6. 需在 data 資料夾中放入 bgm_menu.mp3、bgm_game.mp3、win_jingle.mp3
 */

import processing.serial.*; 
import ddf.minim.*;      

// --- 聲音變數 ---
Minim minim;             
AudioPlayer bgmMenu, bgmGame, winJingle, bombSound;   

// --- 搖桿與 Serial 控制變數 ---
Serial port;
final int CENTER_VALUE_BYTE = 127; 
final int DEAD_ZONE_BYTE = 15; 
final float MAX_ROTATION_SPEED_FROM_JOYSTICK = 0.08; 
boolean canChangeSelection = true;

// --- 遊戲狀態 ---
int gameState = 0;   // 0=開始畫面, 1=關卡選擇, 2=遊戲中, 4=最終獲勝, 5=時間到, 6=炸彈爆炸
int selectedLevel = 0;
int currentLevel = 0;
int totalLevels = 12;
int menuSelection = 0; 

float mazeAngle = 0, targetAngle = 0;
float ballX, ballY, ballVX = 0, ballVY = 0;
float ballRadius = 15;
float gravity = 0.6, friction = 0.93;

int mazeSize = 500, cellSize = 50, cols, rows;
float levelStartTime = 0;
float[] levelTimeLimit = {15, 15, 15, 15, 15, 15, 25, 25, 30, 30, 35, 40};

int[][][] levels;
int[][][] bombPositions;
float[][] levelStarts, levelEnds;

void initData() {
  levels = new int[][][] {
    // 第 1 - 12 關 (維持您提供的原始格式)
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,1,0,1,1,1,1,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,1,0,0,0,0,1},{1,0,1,0,1,0,1,1,0,1},{1,0,1,0,0,0,1,0,0,1},{1,0,1,1,1,0,1,0,1,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,0,1,1,1,1,0,1},{1,0,0,0,0,0,0,1,0,1},{1,0,1,1,1,1,0,0,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,1,1,1,1,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,1,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,1,1,1,1,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,0,1},{1,0,1,0,0,0,0,1,0,1},{1,0,1,0,1,1,0,1,0,1},{1,0,1,0,1,0,0,1,0,1},{1,0,1,0,0,0,1,1,0,1},{1,0,1,1,1,1,1,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,1,0,1,0,1,0,1,1},{1,0,1,0,1,0,1,0,0,1},{1,0,0,0,1,0,1,1,0,1},{1,1,0,1,1,0,0,0,0,1},{1,0,0,0,0,0,1,1,0,1},{1,0,1,1,0,1,1,0,0,1},{1,0,1,0,0,0,0,0,1,1},{1,0,0,0,1,1,1,0,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,1,0,0,0,0,1},{1,0,1,0,1,0,1,1,0,1},{1,0,1,0,0,0,1,0,0,1},{1,0,1,1,1,1,1,0,1,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,1,0,1,1,1,0,1},{1,0,0,0,0,1,0,0,0,1},{1,0,1,1,0,0,0,1,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,0,1,0,0,0,1},{1,0,1,1,0,1,0,1,0,1},{1,0,1,0,0,0,0,1,0,1},{1,0,0,0,0,1,0,0,0,1},{1,1,1,1,1,1,0,1,1,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,0,1,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,0,1,1,0,1},{1,0,1,0,0,0,0,1,0,1},{1,0,1,0,1,1,0,1,0,1},{1,0,0,0,1,1,0,0,0,1},{1,1,1,0,0,0,0,1,1,1},{1,0,0,0,1,1,0,0,0,1},{1,0,1,1,0,0,0,1,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,1,1,1,0,0,1},{1,0,1,0,0,0,1,0,1,1},{1,0,1,1,1,0,1,0,0,1},{1,0,0,0,1,0,0,0,1,1},{1,1,1,0,1,1,1,0,0,1},{1,0,0,0,0,0,1,1,0,1},{1,0,1,1,1,0,0,0,0,1},{1,0,0,0,0,0,1,1,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,0,1},{1,0,0,0,1,0,0,0,0,1},{1,0,1,0,1,0,1,1,1,1},{1,0,1,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,0,1},{1,0,0,0,0,0,0,1,0,1},{1,1,1,1,1,1,0,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,0,1},{1,0,1,0,0,0,0,1,0,1},{1,0,1,0,0,1,0,1,0,1},{1,0,1,0,1,0,0,1,0,1},{1,0,1,0,0,0,0,1,0,1},{1,0,1,1,0,1,1,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,1,1,1,1,1,1,1,1,1}},
    {{1,1,1,1,1,1,1,1,1,1},{1,0,0,0,1,0,1,0,0,1},{1,0,1,0,1,0,1,0,1,1},{1,0,1,0,0,0,0,0,0,1},{1,0,1,1,1,0,1,1,0,1},{1,0,0,0,1,0,0,1,0,1},{1,1,1,0,1,1,0,1,0,1},{1,0,0,0,0,0,0,0,0,1},{1,0,1,1,1,1,1,1,0,1},{1,1,1,1,1,1,1,1,1,1}}
  };
  bombPositions = new int[][][] { {}, {}, {}, {}, {}, {}, {{225, 225}}, {{225, 175}, {225, 325}}, {{325,375}}, {{375,425}}, {{275, 275}}, {{175, 175}, {325, 325}} };
  levelStarts = new float[][] { {75, 75}, {75, 75}, {75, 75}, {75, 75}, {75, 75}, {75, 75}, {75, 75}, {225, 75}, {75, 75}, {425, 75}, {75, 75}, {75, 75} };
  levelEnds = new float[][] { {425, 425}, {425, 425}, {425, 425}, {425, 425}, {425, 425}, {425, 425}, {425, 425}, {225, 425}, {425, 425}, {75, 425}, {175, 275}, {425, 425} };
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
  cols = getMaze()[0].length; rows = getMaze().length;
  ballX = getStartX(); ballY = getStartY();
  try {
    port = new Serial(this, "COM3", 9600); 
  } catch (Exception e) {
    println("Serial 連線錯誤。");
  }
  minim = new Minim(this);
  try {
      bgmMenu = minim.loadFile("bgm_menu.mp3"); bgmGame = minim.loadFile("bgm_game.mp3");
      winJingle = minim.loadFile("win_jingle.mp3"); bombSound = minim.loadFile("bomb.mp3");
      bgmMenu.loop();
  } catch (Exception e) { println("音效載入失敗。"); }
  font = createFont("Microsoft JhengHei", 32); textFont(font);
  levelStartTime = millis() / 1000.0;
}

void stop() {
  if (bgmMenu != null) bgmMenu.close(); if (bgmGame != null) bgmGame.close();
  if (winJingle != null) winJingle.close(); if (bombSound != null) bombSound.close();
  if (minim != null) minim.stop(); super.stop();
}

void handleMusicState() {
  if (gameState == 0 || gameState == 1) { 
      if (bgmGame != null && bgmGame.isPlaying()) bgmGame.pause();
      if (bgmMenu != null && !bgmMenu.isPlaying()) bgmMenu.loop();
  } else if (gameState == 2) { 
      if (bgmMenu != null && bgmMenu.isPlaying()) bgmMenu.pause();
      if (bgmGame != null && !bgmGame.isPlaying()) bgmGame.loop();
  } else { 
      if (bgmMenu != null && bgmMenu.isPlaying()) bgmMenu.pause();
      if (bgmGame != null && bgmGame.isPlaying()) bgmGame.pause();
  }
}

void draw() {
  background(20); handleMusicState(); 
  if (gameState == 0) drawStartScreen();
  else if (gameState == 1) drawLevelSelect();
  else if (gameState == 2) drawGame();
  else if (gameState == 4) drawWinScreen(); 
  else if (gameState == 5) drawTimeUpScreen();
  else if (gameState == 6) drawBombHitScreen();
}

void handleSerialInput() {
  if (port != null) { 
    while (port.available() > 1) port.read(); 
    if (port.available() > 0) {
        int xByte = port.read(); 
        if (xByte >= 0 && xByte <= 255) {
          if (gameState == 2) {
            if (abs(xByte - CENTER_VALUE_BYTE) > DEAD_ZONE_BYTE) {
               float mappedSpeed = map(xByte, 0, 255, -MAX_ROTATION_SPEED_FROM_JOYSTICK, MAX_ROTATION_SPEED_FROM_JOYSTICK);
               // --- 360 度無限旋轉 ---
               targetAngle += mappedSpeed; 
            } 
          }
          else if (gameState == 1) {
             if (canChangeSelection) {
                if (xByte < 60) { selectedLevel = (selectedLevel - 1 + totalLevels) % totalLevels; canChangeSelection = false; }
                else if (xByte > 190) { selectedLevel = (selectedLevel + 1) % totalLevels; canChangeSelection = false; }
             } else {
                if (abs(xByte - CENTER_VALUE_BYTE) < 20) canChangeSelection = true;
             }
          }
        }
    }
  }
}

void drawStartScreen() {
  textAlign(CENTER, CENTER);
  fill(255, 200, 0); textSize(60); text("旋轉迷宮", width/2, 120);
  fill(255); textSize(24); text("遊戲規則", width/2, 200);
  textSize(30); fill(200);
  text("1. 使用搖桿 X 軸控制迷宮旋轉角度", width/2, 250);
  text("2. 讓黃色球從綠色起點滾到紅色終點", width/2, 300);
  text("3. 碰到紅色炸彈立即失敗", width/2, 350);
  text("4. 按 R 鍵可以隨時重置當前關卡", width/2, 400);
  fill(255); textSize(20); text("圖示說明", width/2, 470);
  fill(0, 255, 0); noStroke(); rectMode(CENTER);
  rect(width/2 - 150, 540, 35, 35);
  fill(255); textSize(18); text("起點", width/2 - 150, 585);
  fill(255, 0, 0); rect(width/2, 540, 35, 35);
  fill(255); text("終點", width/2, 585);
  fill(50); stroke(255, 0, 0); strokeWeight(3); ellipse(width/2 + 150, 540, 25, 25);
  fill(255); noStroke(); text("炸彈", width/2 + 150, 585);
  rectMode(CORNER);
  if (frameCount % 60 < 30) { fill(255, 255, 0); textSize(32); text("按 Enter 鍵進入選單", width/2, 680); }
}

void drawLevelSelect() {
  handleSerialInput(); textAlign(CENTER, CENTER);
  fill(255, 200, 0); textSize(60); text("選擇關卡", width/2, 80);
  int c = 4; float buttonSize = 80; float spacing = 100;
  float startX = width/2 - (c * spacing) / 2 + spacing/2;
  float startY = 180;
  for (int i = 0; i < totalLevels; i++) {
    float x = startX + (i % c) * spacing; float y = startY + (i / c) * spacing;
    if (i == selectedLevel && menuSelection == 0) { fill(255, 200, 0); stroke(255); strokeWeight(4); }
    else { fill(80); stroke(150); strokeWeight(2); }
    rectMode(CENTER); rect(x, y, buttonSize, buttonSize, 10);
    fill(255); textSize(32); text(i + 1, x, y - 5);
    if (bombPositions[i].length > 0) { fill(255, 100, 100); textSize(14); text("💣×" + bombPositions[i].length, x, y + 25); }
  }
  rectMode(CORNER);
  if (menuSelection == 1) { fill(255, 200, 0); stroke(255, 255, 0); strokeWeight(4); } else { fill(80); stroke(150); strokeWeight(2); }
  rectMode(CENTER); rect(width/2, 530, 350, 60, 10);
  fill(255); textSize(24); text("從第 1 關開始連續挑戰", width/2, 530);
  rectMode(CORNER);
  fill(200); textSize(20); text("搖桿左右選擇 | Enter 確認", width/2, 630);
  fill(150); textSize(18); text("按 ESC 返回主選單", width/2, 680);
}

void drawGame() {
  translate(width/2, height/2); handleSerialInput(); 
  mazeAngle = lerp(mazeAngle, targetAngle, 0.15); rotate(mazeAngle);
  drawMaze(); drawBombs(); updateBall(); drawStartEnd(); drawBall();
  checkWin(); checkTimeUp(); checkBombHit(); rotate(-mazeAngle);
  fill(255); textAlign(LEFT); textSize(20); text("第 " + (currentLevel + 1) + " / " + totalLevels + " 關", -380, -360);
  float timeLeft = getTimeLimit() - (millis() / 1000.0 - levelStartTime);
  if (timeLeft < 5) fill(255, 0, 0); else if (timeLeft < 10) fill(255, 200, 0); else fill(100, 255, 100);
  textSize(24); text("剩餘: " + nf(max(0, timeLeft), 1, 1) + " 秒", -380, -330);
  float displayAngle = (degrees(mazeAngle) % 360 + 360) % 360;
  fill(200); textSize(16); text("角度: " + nf(displayAngle, 1, 1) + "°", -380, -300); text("R: 重置", -380, -275);
  
  textAlign(RIGHT); 
  textSize(22); 
  fill(0, 255, 0); text("綠色 = 起點", 380, -360);
  fill(255, 0, 0); text("紅色 = 終點", 380, -330); 
  if (getBombs().length > 0) { 
    fill(255, 100, 100); text("炸彈 (避開！)", 380, -300); 
  }
}

void drawMaze() {
  stroke(200); strokeWeight(2); fill(80);
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) { if (getMaze()[i][j] == 1) rect(j * cellSize - mazeSize/2, i * cellSize - mazeSize/2, cellSize, cellSize); }
  }
  noFill(); stroke(255); strokeWeight(4); rect(-mazeSize/2, -mazeSize/2, mazeSize, mazeSize);
}

void drawBombs() {
  int[][] bombs = getBombs();
  for (int[] b : bombs) {
    float bx = b[0] - mazeSize/2; float by = b[1] - mazeSize/2;
    fill(50); stroke(255, 0, 0); strokeWeight(3); ellipse(bx, by, 25, 25);
    stroke(255, 0, 0); strokeWeight(2); line(bx-8, by-8, bx+8, by+8); line(bx+8, by-8, bx-8, by+8);
  }
}

void drawStartEnd() {
  fill(0, 255, 0); stroke(255); strokeWeight(2); rectMode(CENTER);
  rect(getStartX() - mazeSize/2, getStartY() - mazeSize/2, 35, 35);
  fill(255, 0, 0); rect(getEndX() - mazeSize/2, getEndY() - mazeSize/2, 35, 35); rectMode(CORNER);
}

void drawBall() {
  fill(255, 200, 0); stroke(255, 150, 0); strokeWeight(2);
  ellipse(ballX - mazeSize/2, ballY - mazeSize/2, ballRadius * 2, ballRadius * 2);
}

void updateBall() {
  float gravX = sin(mazeAngle) * gravity; float gravY = cos(mazeAngle) * gravity;
  ballVX += gravX; ballVY += gravY; ballVX *= friction; ballVY *= friction;
  float oldX = ballX; float oldY = ballY;
  ballX += ballVX; if (checkCollision(ballX, ballY)) { ballX = oldX; ballVX *= -0.2; }
  ballY += ballVY; if (checkCollision(ballX, ballY)) { ballY = oldY; ballVY *= -0.2; }
  ballX = constrain(ballX, ballRadius, mazeSize - ballRadius); ballY = constrain(ballY, ballRadius, mazeSize - ballRadius);
}

boolean checkCollision(float x, float y) {
  for (int i = 0; i < 8; i++) {
    float angle = TWO_PI * i / 8; // 計算偵測點角度
    float checkX = x + cos(angle) * ballRadius; 
    float checkY = y + sin(angle) * ballRadius;
    int col = int(checkX / cellSize); int row = int(checkY / cellSize);
    if (row >= 0 && row < rows && col >= 0 && col < cols && getMaze()[row][col] == 1) return true;
  }
  return false;
}

void checkWin() {
  if (dist(ballX, ballY, getEndX(), getEndY()) < 25) {
    if (currentLevel + 1 >= totalLevels) {
      gameState = 4; if (bgmGame != null && bgmGame.isPlaying()) bgmGame.pause();
      if (winJingle != null) { winJingle.rewind(); winJingle.play(); }
    } else { currentLevel++; gameState = 2; resetGame(); }
  }
}

void checkTimeUp() { if (getTimeLimit() - (millis() / 1000.0 - levelStartTime) <= 0) gameState = 5; }

void checkBombHit() {
  int[][] bombs = getBombs();
  for (int[] b : bombs) {
    if (dist(ballX, ballY, b[0], b[1]) < ballRadius + 12) {
      if (bombSound != null) { bombSound.rewind(); bombSound.play(); }
      gameState = 6; if (bgmGame != null && bgmGame.isPlaying()) bgmGame.pause();
    }
  }
}

void drawTimeUpScreen() { 
  textAlign(CENTER, CENTER); 
  fill(255, 50, 50); textSize(70); text("時間到！", width/2, 250); 
  fill(255); textSize(32); text("第 " + (currentLevel + 1) + " 關挑戰失敗", width/2, 350); 
  fill(200); 
  textSize(20); // 字體縮小
  text("按 Enter 返回選單", width/2, 520); // Y座標拉開
  text("按 R 重新挑戰", width/2, 580);    // Y座標拉開
  text("按 M 回到主選單", width/2, 640);  // Y座標拉開
}

void drawBombHitScreen() { 
  textAlign(CENTER, CENTER); 
  fill(255, 0, 0); textSize(70); text("炸彈爆炸！", width/2, 250); 
  fill(255); textSize(32); text("第 " + (currentLevel + 1) + " 關挑戰失敗", width/2, 350); 
  fill(200); 
  textSize(20); // 字體縮小
  text("按 Enter 返回選單", width/2, 520); // Y座標拉開
  text("按 R 重新挑戰", width/2, 580);    // Y座標拉開
  text("按 M 回到主選單", width/2, 640);  // Y座標拉開
}

// --- 通關畫面 UI 優化 ---
void drawWinScreen() { 
  textAlign(CENTER, CENTER); 
  fill(255, 215, 0); textSize(80); text("全部通關！", width/2, 200); 
  fill(255); textSize(40); text("恭喜完成 " + totalLevels + " 個關卡！", width/2, 300); 
  for (int i = 0; i < 50; i++) star(random(width), random(height), random(2, 8));
  
  fill(200); 
  textSize(20); // 字體縮小
  text("按 Enter 再玩一次", width/2, 520); // Y座標拉開
  text("按 M 回到主選單", width/2, 580);    // Y座標拉開
  
  if (frameCount % 40 < 20) { fill(255, 255, 0); textSize(36); text("你是迷宮大師！", width/2, 400); }
}

void star(float x, float y, float size) {
  fill(255, 255, 0, random(100, 255)); noStroke(); beginShape();
  for (int i = 0; i < 5; i++) {
    float a = TWO_PI * i / 5 - PI/2;
    vertex(x + cos(a) * size, y + sin(a) * size);
    a += PI / 5;
    vertex(x + cos(a) * size/2, y + sin(a) * size/2);
  }
  endShape(CLOSE);
}

void resetGame() {
  ballX = getStartX(); ballY = getStartY(); ballVX = 0; ballVY = 0; mazeAngle = 0; targetAngle = 0; levelStartTime = millis() / 1000.0;
}

void fullReset() { currentLevel = 0; resetGame(); }

void keyPressed() {
  if (gameState == 0) { if (key == ENTER) gameState = 1; }
  else if (gameState == 1) { 
    if (keyCode == UP) menuSelection = 0; if (keyCode == DOWN) menuSelection = 1;
    if (key == ENTER) { gameState = 2; if (menuSelection == 1) fullReset(); else { currentLevel = selectedLevel; resetGame(); } }
    if (keyCode == ESC) { key = 0; gameState = 0; }
    if (keyCode == LEFT) selectedLevel = (selectedLevel - 1 + totalLevels) % totalLevels;
    if (keyCode == RIGHT) selectedLevel = (selectedLevel + 1) % totalLevels;
  }
  else if (gameState == 2) { if (key == 'r' || key == 'R') resetGame(); }
  else if (gameState == 4 || gameState == 5 || gameState == 6) {
    if (key == ENTER) { 
      //核心優化：返回時關掉勝利音樂
      if (winJingle != null && winJingle.isPlaying()) winJingle.pause();
      gameState = 1; menuSelection = 0; 
    }
    if (key == 'm' || key == 'M') { 
      //核心優化：返回時關掉勝利音樂
      if (winJingle != null && winJingle.isPlaying()) winJingle.pause();
      gameState = 0; fullReset(); 
    }
    if (key == 'r' || key == 'R') { if (gameState != 4) { gameState = 2; resetGame(); } }
  }
}
