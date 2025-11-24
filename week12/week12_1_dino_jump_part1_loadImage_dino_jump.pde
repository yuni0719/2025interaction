// week12_1_dino_jump_part1_loadImage_dino_jump
// 恐龍跳跳跳 (1)圖檔 (2) 跳
PImage img;
void setup() {
  size(300, 500);
  img = loadImage("dinosaur.png");
}
float x = 175, y = 400, dx=0, dy=0;
void draw() {
  background(255);
  image(img, x, y, 150, 100);
  y += dy;
  if(y<400) dy += 0.98;
  else dy = 0;
}
void keyPressed() {
  if(keyCode==UP) dy = -15;
}
