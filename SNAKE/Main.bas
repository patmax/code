!- CONSTANTS AND VARIABLES 
!- =======================

10 CS$ = CHR$(147)
20 KU$ = "w"
30 KD$ = "s"
40 KL$ = "a"
50 KR$ = "d"
60 DIM F%(1000) 
70 BL% = 96
80 SH% = 90
90 SB% = 87
100 FD% = 102 
!- Most recent snake head location
120 RCNT% = 1524
!- Most recent moving direction
130 DRCTN$ = "" 
!- Change of location coordinates
140 ICR% = 0
!- Speed of the snake (30 is slowest, 0 is fastest)
150 VLCTY% = 0
160 POKE 53281, 1
170 POKE 53280, 15
180 POKE 646, 5
!- Snake length
190 SL% = 1


!- Initialize snake (head)
200 MX=100 : GOSUB 1000 : GOTO 2000



!- INITIALIZE LINKED LIST
!- ======================

!- PX = x coordinate, PY = y coordinate
1000 DIM PX%(MX):DIM PY%(MX):DIM NX%(MX)
1010 NX%(2)=0:FP = MX
1020 PX%(1)=0:PY%(1)=0:NX%(1)=0
1030 FOR I=3 TO MX:NX%(I)=I-1:NEXT
1040 RETURN



!- ALLOCATE FREE SPACE
!- ==================================

1100 P = FP:IF P THEN FP = NX%(P): PRINT "p: ";P;" fp: ";FP
1110 RETURN



!- RELEASE INDEX IN LINKED LIST
!- ============================

1200 IF P=1 THEN RETURN:REM DON'T FREE SENTINEL NODE
1210 PX%(P)=-1:PY%(P)=-1:NX%(P)=FP:FP=P:RETURN



!- INSERT NODE POINTED TO BY P
!- ===========================

1300 NX%(P)=NX%(1):NX%(1)=P:RETURN



!- INSERT ELEMENT AT HEAD OF LINKED LIST WITH COORDS. X AND Y
!- ============================================================

1400 GOSUB 1100:PX%(P)=X%:PY%(P)=Y%:GOSUB 1300



!- DELETE NODE AT HEAD
!- ===================

1500 P = NX%(1):IF P=0 THEN RETURN
1510 NX%(1)=NX%(P):GOTO 1200



!- SEARCH LIST FOR (X,Y) (P=Node Or 0, M=Previous Node)
!- ================================================
1600 M=1:P=NX%(1)
1610 IF P=0 THEN RETURN
1620 IF PX%(P)=X% AND PY%(P)=Y% THEN RETURN
1630 M=P:P=NX%(M):GOTO 1610



!- REMOVE NODE CONTAINING (X,Y) FROM LIST 
!- ==================================

1700 GOSUB 1600:IF P=0 THEN RETURN
1710 NX%(M)=NX%(P):GOTO 1200



!- MAIN GAME
!- =========

2000 PRINT CS$
2006 X% = 12
2007 Y% = 20
2008 GOSUB 1400
2010 PRINT "p: ";P;" x: "; X%;", y: ";Y%
2011 MM%=1400
2014 POKE MM%, 102
2020 POKE RCNT%, 90
!- Continuously read user input
2030 GOSUB 3000
2040 GOTO 2030




!- READ USER INPUT
!- ===============

3000 CN%=0
3002 GET A$
3005 TMP% = RCNT%
3008 IF A$ = "l" THEN PRINT "add": X%=SX%(P):Y%=SY%(P):GOSUB 1400:GOSUB 1600:GOTO 3050
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
4020 IF ((RCNT%+ICR%-1023)-INT((RCNT%+ICR%-1023)/40)*40) = 0 THEN GOTO 9999 : GOTO 4025
4022 IF (RCNT%+ICR%)>2023 OR (RCNT%+ICR%) < 1024 THEN GOTO 9999

!- Update the position of the snake
4025 GOSUB 5000
4060 RETURN




!- MOVEMENT LOGIC
!- ==============

!- Place Snake Symbol at new position
5000 TMP% = RCNT%
5010 RCNT% = RCNT%+ICR% : Z%=RCNT% : GOSUB 6000

!- If the snake's length is 1
5030 IF SL% <> 1 THEN GOTO 5060
5040 PX%(P)=LX%:PY%(P)=LY%
5050 POKE TMP%, BL%
5055 IF PEEK(Z%) = FD% THEN GOTO 5090
5058 GOTO 5150

!- If the snake's length is greater than 1
5060 IF PEEK(Z%) <> FD% THEN GOTO 5090
5070 X%=LX%:Y%=LY%:GOSUB 1400
5080 SL% = SL%+1:GOSUB 6030:GOTO 5140

!- Food eaten
5090 X%=PX%(P):Y%=PY%(P)
5095 PRINT "p: ";P;" x: "; X%;", y: ";Y%
5100 GOSUB 1400
5110 PRINT "p: ";P;" x: "; X%;", y: ";Y%
5120 LX%=X%:LY%=Y%
5130 GOSUB 6030


5140 POKE Z%,BL%
5150 POKE Z%, SH%
 
5160 IF A$ <> "" THEN DRCTN$ = A$ 
5170 T = TI+VLCTY% : FOR I=-1 TO 0 : I = TI<T : NEXT
5180 RETURN



!- TRANSLATE LOCATION CODE TO X AND Y COORDINATE AND VICE VERSA
!- ============================================================

6000 LX% = INT((Z%-1024)/40)
6010 LY% = Z%-(1024+LX%*40)
6020 RETURN
6030 Z% = LX%*40+1024+LY%
6040 RETURN



9999 PRINT CS$
10000 PRINT "game over!"
