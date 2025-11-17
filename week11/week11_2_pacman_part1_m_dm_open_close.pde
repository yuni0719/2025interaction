// week11_2_pacman_part1_m_dm_open_close
// 小精靈 張嘴 (在動)
void setup() {
  size(500, 500);
}
int x = 250, y = 250;
float m = 0, dm = 0.05; // 嘴巴大小 mouth, 嘴巴改變量 diff of m
void draw() {
  background(0);
  fill(255, 255, 0); // 黃色的
  arc(x, y, 30, 30, +m, PI*2-m); // 弧度
  if(m>=1 || m<0) dm = -dm; // 正負倒過來
  m += dm;
}
