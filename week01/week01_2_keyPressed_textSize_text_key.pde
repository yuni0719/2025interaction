// File-New (Ctrl-N) 開新的專案
void setup() {
  size(500, 500);
}
void draw() {
  if(keyPressed){ //記得先關掉注音
    background(#FF0000); //紅色背景
    textSize(80); //很大的字型
    text(""+key, 100, 100);
  }
}
