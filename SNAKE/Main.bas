!- CONSTANTS AND VARIABLES 
!- =======================

10 CS$ = CHR$(147)
20 KU$ = "w"
30 KD$ = "s"
40 KL$ = "a"
50 KR$ = "d"
60 BL% = 96
70 SH% = 90
80 SB% = 87
90 FD% = 102 

100 HD% = -1
110 TD% = -1
115 SL% = 0

!- Most recent snake head location
120 RCNT% = 1524
!- Most recent moving direction
130 DRCTN$ = "" 
!- Change of location coordinates
140 ICR% = 0
!- Speed of the snake (30 is slowest, 0 is fastest)
150 VLCTY% = 30

!- Color settings
160 POKE 53281, 1
170 POKE 53280, 15
180 POKE 646, 5

!- Initialize snake (head)
200 MX=1000 : GOSUB 1000 : GOTO 2000



!- INITIALIZE LINKED LIST
!- ======================

1000 DIM PX%(MX):DIM PY%(MX):DIM NX%(MX)
1040 RETURN
 


!- INSERT ELEMENT WITH COORDS. X AND Y
!- ============================================================

1400 GOSUB 1800
1405 POKE 1024+TD%, BL%
1408 POKE 1024+C%, SB%
1410 IF HD% <> -1 THEN NX%(HD%) = C%
1420 PX%(C%) = X% : PY%(C%) = Y% : NX%(C%) = -1
1430 HD% = C%
1440 RETURN



!- DELETE LAST NODE
!- ===================

1500 PX%(TD%) = 0 : PY%(TD%) = 0 
1520 TD% = NX%(TD%)
1530 RETURN



!- CALCULATE COORDINATE LOCATION DEPENDING ON X AND Y
!- ==================================================

1800 C%=X%*40+Y%:RETURN
1810 X% = INT(C%/40)
1820 Y% = C%-(X%*40)
1830 RETURN



!- MAIN GAME
!- =========

2000 PRINT CS$
2006 X% = 12
2007 Y% = 20
2009 GOSUB 1400
2010 TD% = C%
2014 POKE 1400, 102
2015 POKE 1450, 102
2016 POKE 1451, 102
!- Continuously read user input
2030 GOSUB 3000
2040 GOTO 2030



!- READ USER INPUT
!- ===============

3000 CN%=0
3002 GET A$
3005 TMP% = RCNT%
3010 IF A$ = KU$ OR (A$ = "" AND DRCTN$ = KU$) THEN ICR%=-40 : GOSUB 4000 : GOTO 3050
3020 IF A$ = KD$ OR (A$ = "" AND DRCTN$ = KD$) THEN ICR%=40 : GOSUB 4000 : GOTO 3050
3030 IF A$ = KL$ OR (A$ = "" AND DRCTN$ = KL$) THEN ICR%=-1 : GOSUB 4000 : GOTO 3050
3040 IF A$ = KR$ OR (A$ = "" AND DRCTN$ = KR$) THEN ICR%=+1 : GOSUB 4000 : GOTO 3050
3050 RETURN




!- MOVE SNAKE
!- ==========

4000 IF DRCTN$ = "" GOTO 4020

!- Prevent the snake from going in the opposite direction it comes from
4010 IF (DRCTN$ = KU$ AND A$ = KD$) OR (DRCTN$ = KD$ AND A$ = KU$) OR (DRCTN$ = KL$ AND A$ = KR$) OR (DRCTN$ = KR$ AND A$ = KL$) THEN GOTO 4060

!- If the snake hits the wall the game is over
4020 IF ((RCNT%+ICR%-1023)-INT((RCNT%+ICR%-1023)/40)*40) = 0 THEN GOTO 9999 : GOTO 4023
4022 IF (RCNT%+ICR%)>2023 OR (RCNT%+ICR%) < 1024 THEN GOTO 9999

!- If the snake bites itself the game ist over
4023 IF PEEK(RCNT%+ICR%) = SB% THEN GOTO 9999

!- Update the position of the snake
4025 GOSUB 5000
4060 RETURN




!- MOVEMENT LOGIC
!- ==============

!- NL = new snake head location
5000 RCNT% = RCNT%+ICR% : C%=RCNT%-1024 

!- Get location of last snake-element
5010 OL% = TD%

!- Add new element at head of list
!-5020 Z%=NL% : GOSUB 6000 : X%=LX% : Y%=LY% : GOSUB 1400
5015 TP% = PEEK(C%+1024)
5020 GOSUB 1810 : GOSUB 1400
5030 IF TP% = FD% THEN GOTO 5050
5040 GOSUB 1500 GOTO 5060
5050 SC% = SC%+1
5060 REM Play sound

5160 IF A$ <> "" THEN DRCTN$ = A$ 
5170 T = TI+VLCTY% : FOR I=-1 TO 0 : I = TI<T : NEXT
5180 RETURN




9999 PRINT CS$
10000 PRINT "game over!"