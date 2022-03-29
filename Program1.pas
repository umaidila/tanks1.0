uses graphabc;
type direction = (up,down,left,right,none); //   направление пушки танка
adress = record     //адрес кирпичей в центре
         x:integer;
         y:integer;
         end;
bricks = array [1..50] of adress; // массив таких адресов
var
a: bricks;
direct1,wasdirect1,direct2,wasdirect2,bdirect1,bdirect2: direction;
x1,y1,x2,y2,bx1,by1,bx2,by2,hp1,hp2: integer; // координаты, цифра указывает на номер танка bx/y - коорд-ты снаряда, hp1,hp2 - жизни каждого танка
shoot1,shoot2: integer; // состояние стрельбы из танка - 0: танк не стреляет, 1 - стрельнул, 2- снаряд летит, и нельзя запустить новый
flag:boolean;
//
procedure borders(a:bricks); // границы карты
var i:integer;
begin
setbrushcolor(rgb(135,81,28));
for i:=0 to 31 do
begin
rectangle(i*40,81,(i+1)*40,121); // верхняя линия кирпичей
rectangle(i*40,761,(i+1)*40,800); // нижняя
end;
for i:= 1 to 17 do
begin
rectangle(0,81+(i*40),39,81+((i+1)*40)); // левая граница
rectangle(1240,80+(i*40),1280,80+((i+1)*40)); // правая
end;
for i:=1 to 50 do
rectangle(a[i].x,a[i].y,a[i].x+40,a[i].y+40); // кирпичи внутри
end;
//
function ifstop(x,y:integer;direct:direction;a:bricks): boolean; // ф-ия, проверяющая, есть ли рядом кирпичи, через которые нельзя проехать
var i: integer;
begin
ifstop:=true; // изначально
if (x = 40) and (direct = left) then ifstop:= false; // если танк движется у к левой границе - x=44, т.к. все коориднаты кратны 4м
if (x = 1200) and (direct = right) then ifstop:= false; // к правой (x-40, т.к это левая координата танка)
if (y = 120) and (direct = up) then ifstop:= false;
if (y = 720) and (direct = down) then ifstop := false;
for i:= 1 to 50 do
begin
if (direct = up) and (a[i].y+40 = y) and (((a[i].x < x+40) and (a[i].x+40 > x+40)) or ((a[i].x<x) and(a[i].x+40>x)) or (a[i].x = x)) then ifstop := false; // проверка на движение вверх с кирпичами внутри
if (direct = down) and (a[i].y = y+40) and (((a[i].x < x+40) and (a[i].x+40 >x+40)) or ((a[i].x<x) and(a[i].x+40>x)) or (a[i].x = x)) then ifstop := false; // вниз
if (direct = left) and (a[i].x+40 = x) and (((a[i].y < y+40) and (a[i].y+40 > y+40)) or ((a[i].y<y) and(a[i].y+40>y)) or (a[i].y=y)) then ifstop := false;
if (direct = right) and (a[i].x = x+40) and (((a[i].y < y+40) and (a[i].y+40 > y+40)) or ((a[i].y<y) and(a[i].y+40>y)) or (a[i].y=y)) then ifstop := false;
end;
end;
//
function Bifstop(x,y:integer;direct:direction;a:bricks;tx,ty:integer): integer; // ф-ия, для снаряда - 0-встреча с кирпичом, 1- можно ехать, 2 - попадание в танк (tx,ty:координаты вражеского танка)
var i:integer;
begin
bifstop:= 1; // изначально (если снаряд не встретит ничего, то продолжит двжение
if (x <= 40) and (direct = left) then bifstop:= 0; // если снаряд движется к левой границе 
if (x >=1240) and (direct = right) then bifstop:= 0; // к правой 
if (y <= 120) and (direct = up) then bifstop:= 0;
if (y >760) and (direct = down) then bifstop := 0;
for i:=1 to 50 do
if (x>=a[i].x) and (x<=a[i].x+40) and (y>=a[i].y) and (y<=a[i].y+40) then Bifstop:=0; // если снаряд встречает кирпич, то меняется статус выстрела на 0
if (x>tx) and (x<tx+40) and (y>ty) and (y<ty+40) then Bifstop:=2; // при встрече снаряда с танком
end;
//
procedure beginning(x1,y1:integer; direct1,direct2:direction; var wasdirect1,wasdirect2:direction;a:bricks;bx1,by1,bx2,by2,shoot1,shoot2:integer;var hp1,hp2: integer); // wasdirect1 - запоминает, каким было направление танка до этого, чтоы пушка не пропадала
var p1,p2:string;
begin
if (direct1 = up) or (direct1 = down ) or (direct1 = left) or (direct1 = right) then wasdirect1:= direct1; // принцип работы wasdirect(если direct = none, wasdirect запоминает, что было)
if (direct2 = up) or (direct2 = down ) or (direct2 = left) or (direct2 = right) then wasdirect2:= direct2;  // для 2го танка
setbrushcolor(rgb(236,236,236)); //
fillrectangle(0,0,1280,80);      // серое поле с информацией
setbrushcolor(rgb(160,249,216)); //
fillrect(0,80,1280,800);         // зелёное поле боя
setpencolor(clblack);
line(0,80,1280,80);
setbrushcolor(rgb(255,0,60));  // цвет первого танка - красный
roundrect(x1,y1,x1+40,y1+40,20,20); // появление 1го танка
setbrushcolor(clblue); // цвет второго танка - голубой
roundrect(x2,y2,x2+40,y2+40,20,20); // рисование 2го танка
setpenwidth(2); // толщина пушки
if wasdirect1 = up then line(x1+20,y1,x1+20,y1-10);       //рисование пушки 1 танка
if wasdirect1 = down then line(x1+20,y1+40,x1+20,y1+50);
if wasdirect1 = left then line(x1,y1+20,x1-10,y1+20);
if wasdirect1 = right then line(x1+40,y1+20,x1+50,y1+20);
if wasdirect2 = up then line(x2+20,y2,x2+20,y2-10);       //рисование пушки 2 танка
if wasdirect2 = down then line(x2+20,y2+40,x2+20,y2+50);
if wasdirect2 = left then line(x2,y2+20,x2-10,y2+20);
if wasdirect2 = right then line(x2+40,y2+20,x2+50,y2+20);
if shoot1 <> 0 then // если есть снаряд, то рисует его 
begin
setbrushcolor(rgb(255,0,60));
circle(bx1,by1,6);
end;
if shoot2 <> 0 then // то же теперь для 2го танка
begin
setbrushcolor(clblue);
circle(bx2,by2,6);
end;
borders(a); // нарисование границ
setfontsize(20);
setbrushcolor(rgb(236,236,236));
p1:= 'Player1';
p2:= 'Player2';
textout(145,10,p1);
textout(1020,10,p2);
setbrushcolor(rgb(255,0,60));
if hp1>=1 then circle(160,60,8);
if hp1>=2 then circle(190,60,8);
if hp1=3 then circle(220,60,8);
setbrushcolor(clblue);
if hp2>=1 then circle(1035,60,8);
if hp2>=2 then circle(1065,60,8);
if hp2= 3 then circle(1095,60,8);
end;
//
procedure start(x,y,mousebutton:integer);
begin
if (x>=500) and (x<=650) and (y>=430) and (y<=490) and (mousebutton =1) then flag := true;
end;
//
procedure direc(key:integer); // по нажатию кнопки меняет направление танка
begin
if key = vk_w then direct1:= up;
if key = vk_s then direct1:= down;
if key = vk_a then direct1:= left;
if key = vk_d then direct1:= right;
if key = vk_up then direct2:= up;
if key = vk_down then direct2:= down;
if key = vk_left then direct2:= left;
if key = vk_right then direct2:= right;
if key = vk_space then begin if shoot1= 0 then shoot1:= 1 end; // если снаряд не был запущен, то запускает его
if key = vk_enter then begin if shoot2 = 0 then shoot2:= 1 end ;
end;
//
procedure stop(key:integer); // при отпускании кнопки останавливает танк
begin
if key = vk_w then direct1:= none;
if key = vk_s then direct1:= none;
if key = vk_a then direct1:= none;
if key = vk_d then direct1:= none;
if key = vk_up then direct2:= none;
if key = vk_down then direct2:= none;
if key = vk_left then direct2:= none;
if key = vk_right then direct2:= none;
onkeydown:=direc;
end;
//
procedure move(var x1,y1:integer; var direct1,direct2:direction; var wasdirect1,wasdirect2:direction;a:bricks; var bx1,by1,bx2,by2: integer; var shoot1,shoot2: integer; var bdirect1,bdirect2: direction;var hp1,hp2: integer); // процедура измнения положений снарядов и танков
begin
if ifstop(x1,y1,direct1,a) = true then // если танк не упирается в верхние границы, можно двигаться
begin
if direct1 = up then y1:= y1-4;
if direct1 = down then y1:= y1+4;
if direct1 = left then x1:= x1-4;
if direct1 = right then x1:= x1+4;
end;
if ifstop(x2,y2,direct2,a) = true then // если танк не упирается в верхние границы, можно двигаться
begin
if direct2 = up then y2:= y2-4;
if direct2 = down then y2:= y2+4;
if direct2 = left then x2:= x2-4;
if direct2 = right then x2:= x2+4;
end;
if shoot1 = 1 then // если была нажата клавиша стрельбы, то обработка события
begin
shoot1:= 2;
bdirect1:=wasdirect1;
if bdirect1 = up then begin bx1:= x1+20; by1:= y1-25 end;
if bdirect1 = down then begin bx1:= x1+20; by1:= y1+ 65 end;
if bdirect1 = left then begin bx1:= x1-25; by1:= y1+20 end;
if bdirect1 = right then begin bx1:= x1+ 65; by1:= y1+20 end;
end;
if shoot1 = 2 then begin
if Bifstop(bx1,by1,bdirect1,a,x2,y2) = 0 then shoot1 := 0; // если снаряд встречает кирпич, то он останавливается
if Bifstop(bx1,by1,bdirect1,a,x2,y2) = 1 then // если нет, то в зависимости от направления он меняет координаты
begin
if bdirect1 = up then by1:= by1-12;
if bdirect1 = down then by1:= by1+12;
if bdirect1 = left then bx1:= bx1 - 12;
if bdirect1 = right then bx1:= bx1 + 12;
end;
if Bifstop(bx1,by1,bdirect1,a,x2,y2) = 2 then // если снаряд попадает в танк
begin
hp2:=hp2-1;
shoot1:=0;
end;
end;
if shoot2 = 1 then // то же самое, но для 2го танка
begin
shoot2:= 2;
bdirect2:=wasdirect2;
if bdirect2 = up then begin bx2:= x2+20; by2:= y2-25 end;
if bdirect2 = down then begin bx2:= x2+20; by2:= y2+ 65 end;
if bdirect2 = left then begin bx2:= x2-25; by2:= y2+20 end;
if bdirect2 = right then begin bx2:= x2+ 65; by2:= y2+20 end;
end;
if shoot2 = 2 then begin
if Bifstop(bx2,by2,bdirect2,a,x1,y1) = 0 then shoot2 := 0; // если снаряд встречает кирпич, то он останавливается
if Bifstop(bx2,by2,bdirect2,a,x1,y1) = 1 then // если нет, то в зависимости от направления он меняет координаты
begin
if bdirect2 = up then by2:= by2-12;
if bdirect2 = down then by2:= by2+12;
if bdirect2 = left then bx2:= bx2 - 12;
if bdirect2 = right then bx2:= bx2 + 12;
end;
if Bifstop(bx2,by2,bdirect2,a,x1,y1) = 2 then // если снаряд попадает в танк
begin
hp1:=hp1-1;
shoot2:=0;
end;
end;
lockDrawing;
beginning(x1,y1,direct1,direct2,wasdirect1,wasdirect2,a,bx1,by1,bx2,by2,shoot1,shoot2,hp1,hp2); // рисование нового изображения с новыми положениями танков
redraw;
end;
//
begin           
a[1].x:=400; // наполение БД о кирпичах внутри
a[2].x:=400;
a[3].x:=400;
a[4].x:=400;
a[5].x:=400;
a[6].x:=360;
a[7].x:=320;
a[8].x:=280;
a[9].x:=160;
a[10].x:=200;
a[11].x:=160;
a[12].x:=200;
a[13].x:=360;
a[14].x:=360;
a[15].x:=360;
a[16].x:=400;
a[17].x:=560;
a[18].x:=600;
a[19].x:=640;
a[20].x:=680;
a[21].x:=720;
a[22].x:=760;
a[23].x:=600;
a[24].x:=600;
a[25].x:=560;
a[26].x:=560;
a[27].x:=560;
a[28].x:=560;
a[29].x:=520;
a[30].x:=720;
a[31].x:=720;
a[32].x:=1080;
a[33].x:=1080;
a[34].x:=880;
a[35].x:=840;
a[36].x:=840;
a[37].x:=840;
a[38].x:=840;
a[39].x:=880;
a[40].x:=960;
a[41].x:=960;
a[42].x:=1000;
a[43].x:=1040;
a[44].x:=1080;
a[45].x:=1080;
a[46].x:=1080;
a[47].x:=960;
a[48].x:=1000;
a[49].x:=1040;
a[50].x:=1080;
a[1].y:=120;
a[2].y:=160;
a[3].y:=200;
a[4].y:=240;
a[5].y:=280;
a[6].y:=280;
a[7].y:=280;
a[8].y:=280;
a[9].y:=520;
a[10].y:=520;
a[11].y:=560;
a[12].y:=560;
a[13].y:=560;
a[14].y:=600;
a[15].y:=640;
a[16].y:=640;
a[17].y:=200;
a[18].y:=200;
a[19].y:=200;
a[20].y:=200;
a[21].y:=200;
a[22].y:=200;
a[23].y:=360;
a[24].y:=400;
a[25].y:=400;
a[26].y:=440;
a[27].y:=480;
a[28].y:=520;
a[29].y:=520;
a[30].y:=600;
a[31].y:=640;
a[32].y:=200;
a[33].y:=240;
a[34].y:=360;
a[35].y:=360;
a[36].y:=400;
a[37].y:=440;
a[38].y:=480;
a[39].y:=480;
a[40].y:=640;
a[41].y:=680;
a[42].y:=680;
a[43].y:=680;
a[44].y:=680;
a[45].y:=640;
a[46].y:=600;
a[47].y:=720;
a[48].y:=720;
a[49].y:=720;
a[50].y:=720;
setwindowsize(1280,800);
centerwindow;
wasdirect1:= up; // изначальное положение 1й пушки
wasdirect2:= up;
flag:=false;
clearwindow(clwhite);
setfontsize(40);
textout(200,200,'Player1');
textout(840,200,'Player2');
setfontsize(15);
textout(200,300,'"w,a,s,d" - движение');
textout(200,330,'"space" - огонь');
textout(840,300,'стрелки- движение');
textout(840,330,'"enter" - огонь');
setfontsize(25);
textout(520,440,'Начать');
drawrectangle(500,430,650,490);
repeat
onmousedown:=start;
until flag = true;
hp1:=3;
hp2:=3;
shoot1:= 0;
shoot2:= 0;
x1:= 80;  //
y1:= 160; // первые координаты 1го танка
direct1:=none;
x2:=1120;
y2:=440;
direct2:=none;
setbrushcolor(rgb(236,236,236)); //
fillrectangle(0,0,1280,80);      // серое поле с информацией
setbrushcolor(rgb(160,249,216));//
fillrect(0,80,1280,800);        // зелёное поле боя
setpencolor(clblack);
line(0,80,1280,80);
borders(a);
setbrushcolor(rgb(255,0,60));  // цвет первого танка - красный
roundrect(x1,y1,x1+40,y1+40,20,20); // появление 1го танка
setpenwidth(2); // толщина пушки
line(x1+20,y1,x1+20,y1-10); //рисование пушки изначально вверх
setbrushcolor(clblue); // цвет второго танка - голубой
roundrect(x2,y2,x2+40,y2+40,20,20); // рисование 2го танка
line(x1+20,y1,x1+20,y1-10); // пушка 2го танка
//
while (hp1>0) and (hp2>0) do
begin
onkeydown:=direc; // 
move(x1,y1,direct1,direct2,wasdirect1,wasdirect2,a,bx1,by1,bx2,by2,shoot1,shoot2,bdirect1,bdirect2,hp1,hp2);
//sleep(1);
onkeyup:= stop;
end;
closewindow;// когда здоровье одного из танков становится 0, закрывает игру
clearwindow;
setbrushcolor(clwhite);
setfontsize(30);
textout(500,300,'Победил');
end.