//week01_7_void_mouseDragged
//動很快, 也不會漏掉, 因為用都準確的追蹤
void setup() {
  size(500, 500);
}
int x = 200, y = 250;
void draw() {
  background(#FFFFAA);
  rect(x, y, 100, 50);
}
void mouseDragged() {//似乎沒有比較好
  if(mousePressed && x<mouseX && mouseX<x+100 && y<mouseY && mouseY<y+50) {
    x += mouseX - pmouseX;
    y += mouseX - pmouseY;
  }
}
