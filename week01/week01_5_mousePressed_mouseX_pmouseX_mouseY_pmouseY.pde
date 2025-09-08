//week01_5_mousePressed_mouseX_pmouseX_mouseY_pmouseY
//結合 mouse 和 keyboard
void setup() {
  size(500, 500);
}
int x = 200, y = 250;
void draw() {
  background(#FFFFAA);
  if(mousePressed) { //不管有沒有壓到rect四邊形, 都移動它
    x += mouseX - pmouseX;
    y += mouseX - pmouseY;
  }
  rect(x, y, 100, 50);
}
