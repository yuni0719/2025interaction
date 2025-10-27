// week08_4_2048_part4_keyPressed_keyCode_RIGHT_only
// 修改自 week08_3_2048_part3_void_keyPressed_genTwo
// (1) 按方向鍵, 板子往那個方向走 (先只做「往右移動」)
color [] c = {#CEC2B9, #EFE5DA, #EDE1CA, #EFB37E, #EF7F63, #EF7F63}; // 色彩 2^1, 2^2, 2^3 , 2^4, 2^5
color [] c2 = {#776E66, #776E66, #776E66, #FDF8F5, #FDF8F5, #FDF8F5}; // 字色
int [] N = {0, 2, 4, 8, 16, 32}; // 對應的數字
int [][] B = {{0, 0, 0, 0}, {1, 2, 3, 4}, {5, 0, 0, 0}, {0, 0, 0, 0}};
void keyPressed() {
  if(keyCode==RIGHT) { // 按「右」
    for(int i=0; i<4; i++) { //正常的迴圈
      int now = 3;
      for(int j=3; j>=0; j--) { //從右往左, 慢慢找
        if(B[i][j]>0) { //找到有板子
          B[i][now] = B[i][j];
          now--; // 下一格在這裡
        }
      } // 到這裡結束, now的左邊, 將不要放東西, 都歸零
      for(int j=now; j>=0; j--) { // 剩下的, 都放0表空白
        B[i][j] = 0;
      }
    }
  }
  genTwo();
}
void genTwo() { //找出陣列0的地方, 挑1個變成空白
  int zero = 0; // 找一找, 有幾個 0
  for(int i=0; i<4; i++) {
    for(int j=0; j<4; j++) {
      if(B[i][j]==0) zero++; // 找到0的板子 
    }
  } // 用亂數, 決定「第幾個0要放2」
  int ans = int(random(zero)); //ex. 有10格, 找到0...9格
  for(int i=0; i<4; i++) {
    for(int j=0; j<4; j++) {
      if(B[i][j]==0) {
        if(ans==0) {
          B[i][j] = 1; //2的1次方, 是2
          return; // 結束
        } else ans--; //倒數用掉1個, 慢慢找到是哪一格
      }
    }
  }
}
void setup() {
  size(410, 410); //讓邊線漂亮一點
}
void draw() {
  background(188, 174, 162); //色彩用滴管, 吸範例的圖
  for(int i=0; i<4; i++) { //左手i (對應y座標)
    for(int j=0; j<4; j++) { //右手j (對應x座標)
      int id = B[i][j]; //對應的代碼
      fill( c[id] ); //fill(206, 194, 185); //色彩用滴管, 吸範例的圖
      noStroke(); // 不要有黑線外框
      rect(j*100+10, i*100+10, 90, 90, 5); //弧角是5
      fill( c2[id] );
      textAlign(CENTER, CENTER);
      textSize(60);
      text( N[id], j*100+55, i*100+55);
    }
  }
}
