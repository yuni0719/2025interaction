//week01_6_if_mousePressed_mouseX_mouseY
//結合 mouse 和 keyboard
void setup() {
  size(500, 500);
}
int x = 200, y = 250;
void draw() {
  background(#FFFFAA);
  //if(mousePressed && x<mouseX && y<mouseY) mouse在(x,y)的右下角, 條件還不夠
  if(mousePressed && x<mouseX && mouseX<x+100 && y<mouseY && mouseY<y+50) {
    x += mouseX - pmouseX;
    y += mouseX - pmouseY;
  }
  rect(x, y, 100, 50);
}
