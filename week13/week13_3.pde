float angle = 0;

void setup() {
  size(600, 600);
}

void draw() {
  background(255);

  // 測試旋轉
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(angle));
  rectMode(CENTER);
  rect(0, 0, 200, 200);
  popMatrix();

  // 用鍵盤測試
  if (keyPressed) {
    if (key == 'a') angle -= 2;
    if (key == 'd') angle += 2;
  }
}
