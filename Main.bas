!- CONSTANTS AND VARIABLES 
!- ///////////////////////

!- Clear screen constant
1 CS$ = CHR$(147) 

!- Define Keyboard Input constants
2 KU$ = "w"
3 KD$ = "s"
4 KL$ = "a"
5 KR$ = "d"
6 KP$ = "p"
7 PS% = 0 : REM If PS = 1, then the game stops

!- Field symbol types (BL=Blank, SB=Snake Body, FD=Food)
8 BL% = 96
9 SB% = 81
10 FD% = 42 

!- Pointer to the first element of the linked list (HD - "Head") and to the last element (TD - "To Delete")
11 HD% = -1
12 TD% = -1

!- Current snake head location 
13 RCNT% = 1524
!- Most recent moving direction (e.g. up or down)
14 DRCTN$ = "" 
!- Change of location coordinates (e.g. if the snake goes left, ICR will be -1)
15 ICR% = 0
!- Speed of the snake (25 is slowest, 0 is fastest)
16 VLCTY% = 25

!- Color settings
17 POKE 53281, 0 : REM Black background color
18 POKE 53280, 1 : REM Black border color
19 POKE 646, 5 : REM Green text color

20 SO% = 1024 : REM Screen location offset (the screen RAM starts at 1024 and ends at 2023)

        
!- vic = base address of vic, mb = chosen memory block, mp = memory position (*64 since a sprite block is 64 Byte large)
21 vic = 53248 : mb%=13 : mp=mb%*64

22 FOR SS = 0 TO 62 
23 READ B%
24 POKE MP+SS,B% : NEXT
25 POKE vic+21,1
26 POKE 2040,mb% : POKE 53276, 1 :  POKE 53277,1 : POKE 53271,1 : POKE 53285, 13 : POKE 53286, 2 : POKE 53287, 5
27 xp% = 250 : yp% = 145
28 poke vic, xp% : poke vic+1, yp%



!- Initialize snake
!- MX denotes the maximum number of elements in the "linked list"
29 MX%=1000 : GOSUB 30 : GOTO 300



!- INITIALIZE LINKED LIST
!- //////////////////////

!- PX denotes an array of x coordinates, PY for y coordinates, NX for the next element in the list
30 DIM PX%(MX%):DIM PY%(MX%):DIM NX%(MX%)
31 RETURN
 


!- PLAY A SOUND 
!- ////////////

40 S = 54272: W = 17: ON INT(RND(TI)*4)+1 GOTO 410,420,430,440
41 W = 33: GOTO 440
42 W = 65: GOTO 440
43 W = 129
44 POKE S+24,15: POKE S+5,97: POKE S+6,200: POKE S+4,W
45 FOR X = 0 TO 255 STEP (RND(TI)*15)+1
46 POKE S,X :POKE S+1,255-X
47 FOR Y = 0 TO 33: NEXT Y,X10000 REM 
48 FOR X = 0 TO 200: NEXT: POKE S+24,0
49 FOR X = 0 TO 100: NEXT : RETURN



!- INSERT ELEMENT WITH COORDS. X AND Y
!- ///////////////////////////////////

50 GOSUB 200
55 POKE SO%+TD%, BL%  : REM Place a blank symbol at the last element's position
60 POKE SO%+C%, SB%   : REM Place a snake body symbol at the new head's position
65 POKE 54272+C%+SO%, 5 : REM Set the color of the snake element to green (to override the red of the food)
70 IF HD% <> -1 THEN NX%(HD%) = C% : REM If the head pointer is initialized, the next element of the current head is at index C
75 PX%(C%) = X% : PY%(C%) = Y% : NX%(C%) = -1 : REM Put X and Y values to the list at index C. Element at index C has no next element yet (-1).
80 HD% = C% : REM Update the head pointer to the new head.
85 RETURN



!- DELETE LAST NODE
!- ////////////////

100 PX%(TD%) = 0 : PY%(TD%) = 0 : REM Deinitialize the x and y values for the element the TD-pointer points at.
110 TD% = NX%(TD%) : REM Move the TD pointer to the second last element in list.
120 RETURN



!- GENERATE RANDOM FOOD
!- ////////////////////

150 RD=RND(-TI) : REM Initialize randomizer.
!- Place a food symbol at a random place on screen if there is no snake yet. 
160 NF% = SO%+INT(RND(1)*1000)  
170 IF PEEK(NF%) = SB% GOTO 710     
180 POKE NF%,FD% : POKE NF%+54272,2 : REM Poke the food symbol and set the color of that character to red (poke to color RAM)
190 RETURN 




!- CALCULATE COORDINATE LOCATION DEPENDING ON X AND Y (800) AND VICE VERSA (810)
!- /////////////////////////////////////////////////////////////////////////////

200 C%=X%*40+Y%:RETURN : REM Get location variable by translating the x and y coordinates into a screen position.
210 X% = INT(C%/40) : REM Get x and y coordinates by manipulating a screen position C.
220 Y% = C%-(X%*40)
230 RETURN



!- MAIN GAME
!- /////////

300 PRINT CS$ 
310 GOSUB 750
320 GET BG$ : IF BG$ = "" GOTO 320
330 POKE vic+21,0 : PRINT CS$ 
340 X% = 12 : REM The initial X value of the snake.
350 Y% = 20 : REM The initial Y value of the snake.
360 GOSUB 50 
370 TD% = C% : REM Set the pointer to the last element to the head as it is the only element in the list so far.
380 GOSUB 150
!- Continuously read user input
390 GOSUB 400 : GOTO 390



!- READ USER INPUT
!- ///////////////

400 CN%=0
410 GET A$ : REM Get keyboard press from user and save it into A.
!- DRCTN denotes the most recently pressed key. ICR is described in line 140.
420 IF A$ = KP$ AND PS% = 0 THEN  POKE 53281, 1 : PS% = 1 : GOTO 490
430 IF A$ = KP$ AND PS% = 1 THEN POKE 53281, 0 : PS% = 0 : GOTO 490 
440 IF PS% = 1 THEN GOTO 490 : REM Pause game
450 IF A$ = KU$ OR (A$ = "" AND DRCTN$ = KU$) THEN ICR%=-40 : GOSUB 500 : GOTO 490
460 IF A$ = KD$ OR (A$ = "" AND DRCTN$ = KD$) THEN ICR%=40 : GOSUB 500 : GOTO 490
470 IF A$ = KL$ OR (A$ = "" AND DRCTN$ = KL$) THEN ICR%=-1 : GOSUB 500 : GOTO 490
480 IF A$ = KR$ OR (A$ = "" AND DRCTN$ = KR$) THEN ICR%=+1 : GOSUB 500 : GOTO 490
490 RETURN




!- MOVE SNAKE
!- //////////

500 IF DRCTN$ = "" GOTO 520

!- Prevent the snake from going in the opposite direction it comes from
510 IF (DRCTN$ = KU$ AND A$ = KD$) OR (DRCTN$ = KD$ AND A$ = KU$) OR (DRCTN$ = KL$ AND A$ = KR$) OR (DRCTN$ = KR$ AND A$ = KL$) THEN GOTO 580

!- If the snake hits the wall the game is over
520 C%=(RCNT%+ICR%)-SO%
530 GOSUB 210
540 REM TOP: X<0, BOTTOM: X=25, RIGHT: Y=0 AND DRCTN=KR, LEFT: Y=39 AND DRCTN=KL
550 IF (X%<0) OR (X%=25) OR (Y%=0 AND DRCTN$=KR$) OR (Y%=39 AND DRCTN$=KL$)  THEN GOTO 800

!- If the snake bites itself the game ist over
560 IF PEEK(RCNT%+ICR%) = SB% THEN GOTO 800

!- Update the position of the snake and perform movement logic
570 GOSUB 600
580 RETURN




!- MOVEMENT LOGIC
!- //////////////

!- C = new snake head location
600 RCNT% = RCNT%+ICR% : C%=RCNT%-SO% 

!- Get location of the last snake element (pointed at by TD)
610 OL% = TD%

620 TP% = PEEK(C%+SO%)
630 GOSUB 210 : GOSUB 50
640 IF TP% = FD% THEN GOTO 660 : REM If there is food at the new location, goto 660
650 GOSUB 100 : GOTO 690
660 SC% = SC%+1 : REM Increment the score! 
670 IF VLCTY%>=5 THEN VLCTY% = VLCTY%-5 : REM Increase the speed of the snake.
!- PLAY SOUND !!!1280 GOSUB 400
680 GOSUB 150

690 IF A$ <> "" THEN DRCTN$ = A$ : REM If the user had pressed a key (A is not empty), update DRCTN
700 T = TI+VLCTY% : FOR I=-1 TO 0 : I = TI<T : NEXT : REM Wait a moment depending on the current velocity.
710 RETURN



!- PRINT START SCREEN
!- //////////////////

750 PRINT "        {green}QQQ"
751 PRINT "       Q   Q"
752 PRINT "       Q     {light green}Q   Q  QQ  Q  Q QQQQ"
753 PRINT "        {green}QQQ  {light green}QQ  Q Q  Q Q Q  Q"
754 PRINT "           {green}Q {light green}Q Q Q Q  Q QQ   QQQ"
755 PRINT "       {green}Q   Q {light green}Q  QQ QQQQ Q Q  Q"
756 PRINT "        {green}QQQ  {light green}Q   Q Q  Q Q  Q QQQQ"
757 PRINT ""
758 PRINT ""
759 PRINT "    {pink}press {cyan}p {pink}to pause"
760 PRINT ""
761 PRINT "    press {cyan}w {pink}to move up"
762 PRINT "    press {cyan}s {pink}to move down"
763 PRINT "    press {cyan}d {pink}to move right"
764 PRINT "    press {cyan}a {pink}to move left"
765 PRINT ""
766 PRINT "    press {cyan}any key {pink}to start"
767 PRINT ""
769 PRINT "    {white}eat food to score!"
770 PRINT "    don't touch the border!"
771 PRINT ""
772 PRINT ""
773 PRINT "                  {yellow}(c) by patrick ahrens"      
774 RETURN

775 PRINT ""
776 PRINT ""
777 PRINT "         {red}QQQQ    Q   Q   Q QQQQQ"
778 PRINT "        Q    Q  Q Q  QQ QQ Q"
779 PRINT "        Q      Q   Q QQQQQ Q"
780 PRINT "        Q QQQ  Q   Q Q Q Q QQQQ"
781 PRINT "        Q    Q QQQQQ Q   Q Q"
782 PRINT "        Q    Q Q   Q Q   Q Q"
783 PRINT "         QQQQ  Q   Q Q   Q QQQQQ"
784 PRINT ""
785 PRINT ""
786 PRINT "         QQQQ  Q   Q QQQQQ QQQQ"
787 PRINT "        Q    Q Q   Q Q     Q   Q"
788 PRINT "        Q    Q Q   Q Q     Q   Q"
789 PRINT "        Q    Q Q   Q Q     Q   Q"
790 PRINT "        Q    Q Q   Q QQQQ  QQQQ"
791 PRINT "        Q    Q Q   Q Q     Q Q"
792 PRINT "        Q    Q  Q Q  Q     Q  Q"
793 PRINT "         QQQQ    Q   QQQQQ Q   Q"
794 RETURN



!- GAME OVER HANDLER
!- /////////////////

800 PRINT CS$
810 GOSUB 775
820 END



10000 REM SNAKE SPRITE DATA
10010 DATA 0,170,128
10020 DATA 2,85,96
10030 DATA 9,85,88
10040 DATA 37,85,86
10050 DATA 37,21,22
10060 DATA 36,132,134
10070 DATA 36,132,134
10080 DATA 36,132,134
10090 DATA 37,21,22
10100 DATA 37,85,86
10110 DATA 9,85,88
10120 DATA 9,85,88
10130 DATA 2,85,96
10140 DATA 2,93,96
10150 DATA 0,157,128
10160 DATA 0,12,0
10170 DATA 0,12,0
10180 DATA 0,63,0
10190 DATA 0,51,0
10200 DATA 0,192,192
10210 DATA 0,192,192
