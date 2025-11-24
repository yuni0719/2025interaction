// week12_2_dino_jump_part2_board_if_dy
// 修改自 week12_1_dino_jump_part1_loadImage_dino_jump
// 恐龍跳跳跳 (3) 板子 (4) 卡在板子上
PImage img;
void setup() {
  size(300, 500);
  img = loadImage("dinosaur.png");
}
float boardX = 200, boardY = 400;
float x = 175, y = 400, dx=0, dy=0;
void draw() {
  background(255);
  rect(boardX, boardY, 100, 5);
  image(img, x, y, 150, 100);
  if(y+100 <= boardY && y+dy+100 >= boardY) {
    y = boardY-100;
    dy = 0;
  } else {
    y += dy;
    if(y<400) dy += 0.98;
    else dy = 0;
  }
  x += dx;
}
void keyPressed() {
  if(keyCode==UP) dy = -15;
}
