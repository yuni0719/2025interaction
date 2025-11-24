// week12_5_coins_falling_part1_Pimage_image_y
// 接金幣 (1) 有金幣 (2) 掉下來
PImage imgCoin; // 把圖檔, 拉進程式裡
void setup() {
  size(300, 500);
  imgCoin = loadImage("coin.png");
}
float x = 0, y = 0;
void draw() {
  background(255);
  image(imgCoin, x, y, 70, 70);
  y += 3; // 往下掉
}
