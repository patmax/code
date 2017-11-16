!- CONSTANTS AND VARIABLES 
!- ///////////////////////

!- Clear screen constant
10 CS$ = CHR$(147) 

!- Define Keyboard Input constants
20 KU$ = "w"
30 KD$ = "s"
40 KL$ = "a"
50 KR$ = "d"

!- Field symbol types (BL=Blank, SB=Snake Body, FD=Food)
60 BL% = 96
70 SB% = 81
80 FD% = 42 

!- Pointer to the first element of the linked list (HD - "Head") and to the last element (TD - "To Delete")
90 HD% = -1
100 TD% = -1

!- Current snake head location 
120 RCNT% = 1524
!- Most recent moving direction (e.g. up or down)
130 DRCTN$ = "" 
!- Change of location coordinates (e.g. if the snake goes left, ICR will be -1)
140 ICR% = 0
!- Speed of the snake (30 is slowest, 0 is fastest)
150 VLCTY% = 30

!- Color settings
160 POKE 53281, 0 : REM Black border color
170 POKE 53280, 11 : REM Dark gray background color
180 POKE 646, 5 : REM Green text color

!- Initialize snake
!- MX is the maximum number of elements in the "linked list"
190 MX=1000 : GOSUB 300 : GOTO 900



!- INITIALIZE LINKED LIST
!- //////////////////////

!- PX denotes an array of X coordinates, PY for y coordinates, NX for the next element in the list
300 DIM PX%(MX):DIM PY%(MX):DIM NX%(MX)
310 RETURN
 


!- PLAY A SOUND 
!- ////////////

400 S = 54272: W = 17: ON INT(RND(TI)*4)+1 GOTO 410,420,430,440
410 W = 33: GOTO 440
420 W = 65: GOTO 440
430 W = 129
440 POKE S+24,15: POKE S+5,97: POKE S+6,200: POKE S+4,W
450 FOR X = 0 TO 255 STEP (RND(TI)*15)+1
460 POKE S,X :POKE S+1,255-X
470 FOR Y = 0 TO 33: NEXT Y,X
480 FOR X = 0 TO 200: NEXT: POKE S+24,0
490 FOR X = 0 TO 100: NEXT
495 RETURN



!- INSERT ELEMENT WITH COORDS. X AND Y
!- ///////////////////////////////////

500 GOSUB 800
510 POKE 1024+TD%, BL%  : REM Place a blank symbol at the last element's position
520 POKE 1024+C%, SB%   : REM Place a snake body symbol at the new head's position
530 IF HD% <> -1 THEN NX%(HD%) = C% : REM If the head pointer is initialized, the next element of the current head is at index C
540 PX%(C%) = X% : PY%(C%) = Y% : NX%(C%) = -1 : REM Put X and Y values to the list at index C. Element at index C has no next element yet (-1).
550 HD% = C% : REM Update the head pointer to the new head.
560 RETURN



!- DELETE LAST NODE
!- ////////////////

600 PX%(TD%) = 0 : PY%(TD%) = 0 : REM Deinitialize the x and y values for the element the TD-pointer points at.
610 TD% = NX%(TD%) : REM Move the TD pointer to the second last element in list.
620 RETURN



!- GENERATE RANDOM FOOD
!- ////////////////////
700 RD=RND(-TI) : REM Initialize randomizer.
!- Place a food symbol at a random place on screen if there is no snake yet. 
710 NF% = 1024+INT(RND(1)*1000)  
720 IF PEEK(NF%) = SB% GOTO 710     
730 POKE NF%,FD% 
740 RETURN



!- CALCULATE COORDINATE LOCATION DEPENDING ON X AND Y (800) AND VICE VERSA (810)
!- /////////////////////////////////////////////////////////////////////////////

800 C%=X%*40+Y%:RETURN : REM Get location variable by translating the x and y coordinates into a screen position.
810 X% = INT(C%/40) : REM Get x and y coordinates by manipulating a screen position C.
820 Y% = C%-(X%*40)
830 RETURN



!- MAIN GAME
!- /////////

900 PRINT CS$ 
910 X% = 12 : REM The initial X value of the snake.
920 Y% = 20 : REM The initial Y value of the snake.
930 GOSUB 500 
940 TD% = C% : REM Set the pointer to the last element to the head as it is the only element in the list so far.
950 GOSUB 700
!- Continuously read user input
960 GOSUB 1000
970 GOTO 960



!- READ USER INPUT
!- ///////////////

1000 CN%=0
1010 GET A$ : REM Get keyboard press from user and save it into A.
!- DRCTN denotes the most recently pressed key. ICR is described in line 140.
1020 IF A$ = KU$ OR (A$ = "" AND DRCTN$ = KU$) THEN ICR%=-40 : GOSUB 1100 : GOTO 1060
1030 IF A$ = KD$ OR (A$ = "" AND DRCTN$ = KD$) THEN ICR%=40 : GOSUB 1100 : GOTO 1060
1040 IF A$ = KL$ OR (A$ = "" AND DRCTN$ = KL$) THEN ICR%=-1 : GOSUB 1100 : GOTO 1060
1050 IF A$ = KR$ OR (A$ = "" AND DRCTN$ = KR$) THEN ICR%=+1 : GOSUB 1100 : GOTO 1060
1060 RETURN




!- MOVE SNAKE
!- //////////

1100 IF DRCTN$ = "" GOTO 1120

!- Prevent the snake from going in the opposite direction it comes from
1110 IF (DRCTN$ = KU$ AND A$ = KD$) OR (DRCTN$ = KD$ AND A$ = KU$) OR (DRCTN$ = KL$ AND A$ = KR$) OR (DRCTN$ = KR$ AND A$ = KL$) THEN GOTO 1170

!- If the snake hits the wall the game is over
1120 C%=(RCNT%+ICR%)-1024
1130 GOSUB 810
1135 REM TOP: X<0, BOTTOM: X=25, RIGHT: Y=0 AND DRCTN=KR, LEFT: Y=39 AND DRCTN=KL
1140 IF (X%<0) OR (X%=25) OR (Y%=0 AND DRCTN$=KR$) OR (Y%=39 AND DRCTN$=KL$)  THEN GOTO 1400 : GOTO 1140

!- If the snake bites itself the game ist over
1150 IF PEEK(RCNT%+ICR%) = SB% THEN GOTO 1400

!- Update the position of the snake and perform movement logic
1160 GOSUB 1200
1170 RETURN




!- MOVEMENT LOGIC
!- //////////////

!- C = new snake head location
1200 RCNT% = RCNT%+ICR% : C%=RCNT%-1024 

!- Get location of the last snake element (pointed at by TD)
1210 OL% = TD%

1220 TP% = PEEK(C%+1024)
1230 GOSUB 810 : GOSUB 500
1240 IF TP% = FD% THEN GOTO 1260 : REM If there is food at the new location, goto 1260
1250 GOSUB 600 : GOTO 1300
1260 SC% = SC%+1 : REM Increment the score! 
1270 IF VLCTY%>=5 THEN VLCTY% = VLCTY%-5 : REM Increase the speed of the snake.
!- PLAY SOUND !!!1280 GOSUB 400
1290 GOSUB 700

1300 IF A$ <> "" THEN DRCTN$ = A$ : REM If the user had pressed a key (A is not empty), update DRCTN
1310 T = TI+VLCTY% : FOR I=-1 TO 0 : I = TI<T : NEXT : REM Wait a moment depending on the current velocity.
1320 RETURN




1400 PRINT CS$
1410 PRINT "game over!"