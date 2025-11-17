// week11_4_pacman_part3_move_change_direction
// 修改自 week11_3_pacman_part2_move_x_y_void_keyPressed
// 小精靈 張嘴 (在動) 而且嘴巴的方向 dir 會轉動
void setup() {
  size(500, 500);
}
int x = 250, y = 250, dx = 0, dy = 0, dir = 0; // diff of x y
float m = 0, dm = 0.05; // 嘴巴大小 mouth, 嘴巴改變量 diff of m
void draw() {
  background(0);
  fill(255, 255, 0); // 黃色的
  float m0 = dir * PI/2; // 幾個 「半PI」 有幾個90度
  arc(x, y, 30, 30, m0 + m, m0 + PI*2-m); // 弧度
  x += dx; // 改變座標
  y += dy; // 改變座標
  if(m>=1 || m<0) dm = -dm; // 正負倒過來
  m += dm;
}
void keyPressed() {
  if(keyCode == LEFT)  { dx = -1; dy = 0; dir = 2; } // dir:2 向左 PI
  if(keyCode == RIGHT) { dx = +1; dy = 0; dir = 0; } // dir:0 向右 0度
  if(keyCode == UP)    { dx = 0; dy = -1; dir = 3; } // dir:3 向上 PI*1.5
  if(keyCode == DOWN)  { dx = 0; dy = +1; dir = 1; } // dor:1 向下 PI/2
}
