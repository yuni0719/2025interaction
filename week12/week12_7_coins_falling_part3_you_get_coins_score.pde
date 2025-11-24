// week12_7_coins_falling_part3_you_get_coins_score
// 修改自 week12_6_coins_falling_part2_for_array_recycle_random
// 接金幣 (5) 小人在下面接金幣 (6) 勝利!
PImage imgCoin; // 把圖檔, 拉進程式裡
void setup() {
  size(300, 500);
  imgCoin = loadImage("coin.png");
  for(int i=0; i<10; i++) {
    x[i] = random(300-100);
    y[i] = -100 - random(1000);
  }
}
float userX = 150, userY = 450; // 我們要控制小人
float [] x = new float[10];
float [] y = new float[10];
int score = 0; // 分數
void draw() {
  background(255);
  for(int i=0; i<10; i++) {
    rect(x[i]-1, y[i]-1, 72, 72); // 用框框, 了解座標
    image(imgCoin, x[i], y[i], 70, 70);
    y[i] += 3; // 往下掉
    if( dist(userX, userY, x[i]+35, y[i]+35) < 35) { // 夠近
      score += 100; // 加分!
      x[i] = random(300-70); // 金幣放到上面、重生
      y[i] = -70 - random(200);
    }
    if(y[i]>500) {
      x[i] = random(300-70);
      y[i] = -70 - random(200);
    }
  }
  fill(255, 0, 0); // 紅色的小人
  ellipse(userX, userY, 50, 10);
  if(keyPressed && keyCode==LEFT) userX--;
  if(keyPressed && keyCode==RIGHT) userX++;
  fill(0); // 黑色的分數
  text("Score: " + score, 200, 50);
}
