!- CONSTANTS AND VARIABLES
!- ///////////////////////

!- Clear screen constant
1 CS$=chr$(147)

!- Define Keyboard Input constants
2 KU$="w"
3 KD$="s"
4 KL$="a"
5 KR$="d"
6 KP$="p"
!- If PS = 1, then the game stops
7 PS%=0

!- Field symbol types (BL=Blank, SB=Snake Body, FD=Food)
8 BL%=96
9 SB%=81
10 FD%=83

!- Pointer to the first element of the linked list (HD - "Head") and to the last element (TD - "To Delete")
11 HD%=-1
12 TD%=-1

!- Current snake head location
13 RCNT%=1524
!- Change of location coordinates (e.g. if the snake goes left, ICR will be -1)
15 ICR%=0
!- Speed of the snake (100 is slowest, 0 is fastest)
16 VLCTY%=100

!- Color settings
!- Black background color
17 poke 53281,0
!- Black border color
18 poke 53280,1
!- Green text color
19 poke 646,5

!- Screen location offset (the screen RAM starts at 1024 and ends at 2023)
20 SO%=1024

!- SID memory location constant
21 SD = 54272

!- vic = base address of vic, mb = chosen memory block, mp = memory position (*64 since a sprite block is 64 Byte large)
22 vic=53248 : mb%=13 : mp=mb%*64
!- Read the snake's sprite data and poke it at the respective memory location
23 for SS=0 to 62 : read B% : poke MP+SS,B% : next
!- Switch the sprite on
24 poke vic+21,1
!- Set sprite pointer and configurations (multicolor, doubled size)
25 poke 2040,mb% : poke vic+28,1 : poke vic+29,1 : poke vic+23,1
!- Set sprite colors (green, red and light green)
26 poke vic+37,13 : poke vic+38,2 : poke vic+39,5
!- Set the sprites x and y coordinates
27 xp%=250 : yp%=145
!- And write them to the memory
28 poke vic,xp% : poke vic+1,yp%



!- INITIALIZE LINKED LIST
!- //////////////////////

!- MX denotes the maximum number of elements in the "linkedlist"
29 MX%=1000 
!- PX denotes an array of x coordinates, PY for y coordinates, NX for the next element in the list
30 dim PX%(MX%) : dim PY%(MX%) : dim NX%(MX%)
31 GOTO 300



!- PLAY A SOUND
!- ////////////

!- Clear SID 
35 FOR LL=SD TO SD+24 : POKE LL, 0 : NEXT
!- Set attack and delay
37 POKE SD+5, 98 : POKE SD+6,195
!- Set volume to max
38 POKE SD+24,15
!- Continuously read music data
39 READ HF,LF,DR
!- If it reads -1, stop
40 IF HF < 0 GOTO 46
!- Set the frequency, high and low byte
41 POKE SD+1, HF : POKE SD, LF
!- Set the waveform to saw
42 POKE SD+4, 33
!- Hold for the given duration
43 FOR TT=1 TO DR : NEXT
!- Reset the waveform
44 POKE SD+4, 32
!- Read next note
45 GOTO 39
!- Restore music data
46 RESTORE
!- Skip the sprite data (63 Bytes)
47 FOR PP=0 TO 62 : READ Q% : NEXT
48 RETURN


!- INSERT ELEMENT WITH COORDS. X AND Y
!- ///////////////////////////////////

50 C%=X%*40+Y%
!- Place a blank symbol at the last element's position
55 poke SO%+TD%,BL%
!- Place a snake body symbol at the new head's position
60 poke SO%+C%,SB%
!- Set the color of the snake element to green (to override the red of the food)
65 poke SD+C%+SO%,5
!- If the head pointer is initialized, the next element of the current head is at index C
70 if HD% <> -1 then NX%(HD%)=C%
!- Put X and Y values to the list at index C. Element at index C has no next element yet (-1).
75 PX%(C%)=X% : PY%(C%)=Y% : NX%(C%)= -1
!- Update the head pointer to the new head.
80 HD%=C%
85 return




!- GENERATE RANDOM FOOD
!- ////////////////////

!- Initialize randomizer.
150 RD=rnd(-TI)
!- Place a food symbol at a random place on screen if there is no snake yet.
160 NF%=SO%+int(rnd(1)*1000)
170 if peek(NF%)=SB% goto 160
!- Poke the food symbol and set the color of that character to red (poke to color RAM)
180 poke NF%,FD% : poke NF%+54272,10
190 return



!- MAIN GAME
!- /////////

!- Clear the screen
300 print CS$
!- Score is 0
305 SC%=0
!- Print the start screen
310 gosub 750
!- Wait for the user to press any button to continue
320 get BG$ : if BG$="" goto 320
!- Switch off the snake sprite and clear the screen
330 poke vic+21,0 : print CS$
!- The initial x value of the snake.
340 X%=12
!- The initial y value of the snake.
350 Y%=20
!- Add the first element to the linked list
360 gosub 50
!- Set the pointer to the last element to the head as it is the only element in the list so far.
370 TD%=C%
!- Place the first food element on the screen
380 gosub 150

!- Continuously read user input
!- Get keyboard press from user and save it into A.
400 get A$
!-  Wait a moment depending on the current velocity.
410 for I = 0 to VLCTY% : next

!- If p is pressed, toggle pause mode
420 if A$=KP$ and PS%=0 then poke 53281,1 : PS%=1 : goto 400
430 if A$=KP$ and PS%=1 then poke 53281,0 : PS%=0 : goto 400
440 if PS%=1 goto 400

!- ICR is described in line 15.
!- Translate user input to ICR and prevent the snake from going in the opposite direction
450 if (A$=KU$ and ICR% <> 40)  then ICR%=-40
460 if (A$=KD$ and ICR% <> -40) then ICR%=40
470 if (A$=KL$ and ICR% <> 1)  then ICR%=-1
480 if (A$=KR$ and ICR% <> -1)  then ICR%=1
490 IF ICR% = 0 GOTO 400


!- MOVE SNAKE
!- //////////

520 C%=(RCNT%+ICR%)-SO%
530 X%=int(C%/40) : Y%=C%-(X%*40)
!- If the snake hits the wall, the game is over
!- TOP: X<0, BOTTOM: X=25, RIGHT: Y=0 AND DRCTN=KR, LEFT: Y=39 AND DRCTN=KL
550 if (X%<0) or (X%=25) or (Y%=0 and ICR%=1) or (Y%=39 and ICR%=-1) goto 800
555 RCNT%=RCNT%+ICR% : TP% = peek(RCNT%)
!- If the snake bites itself the game is over (if there is a snake element at new location)
560 if TP%=SB% goto 800


!- MOVEMENT LOGIC
!- //////////////

!- C = new snake head location
600 C%=RCNT%-SO%
630 X%=int(C%/40) : Y%=C%-(X%*40) 
!- Insert new snake element at head of list
635 gosub 50

!- If there is food at the new location, and skip deletion of the last element
640 if TP%=FD% goto 660

!- Deinitialize the x and y values for the element the TD-pointer points at.
650 PX%(TD%)=-1 : PY%(TD%)=-1
!- Move the TD pointer to the second last element in list.
651 TD%=NX%(TD%) 
655 goto 400

!- Increment the score!
660 SC%=SC%+1
!- Increase the speed of the snake.
670 if VLCTY% >= 20 then VLCTY%=VLCTY%-20
!- Play sound
675 gosub 35
!- Place new food element
680 gosub 150
710 goto 400



!- PRINT START-SCREEN
!- //////////////////

750 print"        {green}QQQ"
751 print"       Q   Q"
752 print"       Q     {light green}Q   Q  QQ  Q  Q QQQQ"
753 print"        {green}QQQ  {light green}QQ  Q Q  Q Q Q  Q"
754 print"           {green}Q {light green}Q Q Q Q  Q QQ   QQQ"
755 print"       {green}Q   Q {light green}Q  QQ QQQQ Q Q  Q"
756 print"        {green}QQQ  {light green}Q   Q Q  Q Q  Q QQQQ"
757 print""
758 print""
759 print"    {pink}press {cyan}p {pink}to pause"
760 print""
761 print"    press {cyan}w {pink}to move up"
762 print"    press {cyan}s {pink}to move down"
763 print"    press {cyan}d {pink}to move right"
764 print"    press {cyan}a {pink}to move left"
765 print""
766 print"    press {cyan}any key {pink}to start"
767 print""
769 print"    {white}eat food to score!"
770 print"    don't touch the border!"
771 print""
772 print""
773 print"                  {yellow}(c) by patrick ahrens"
774 return



!- PRINT GAME OVER-SCREEN
!- //////////////////////

775 print""
776 print""
777 print"         {red}QQQQ    Q   Q   Q QQQQQ"
778 print"        Q    Q  Q Q  QQ QQ Q"
779 print"        Q      Q   Q QQQQQ Q"
780 print"        Q QQQ  Q   Q Q Q Q QQQQ"
781 print"        Q    Q QQQQQ Q   Q Q"
782 print"        Q    Q Q   Q Q   Q Q"
783 print"         QQQQ  Q   Q Q   Q QQQQQ"
784 print""
785 print""
786 print"         QQQQ  Q   Q QQQQQ QQQQ"
787 print"        Q    Q Q   Q Q     Q   Q"
788 print"        Q    Q Q   Q Q     Q   Q"
789 print"        Q    Q Q   Q Q     Q   Q"
790 print"        Q    Q Q   Q QQQQ  QQQQ"
791 print"        Q    Q Q   Q Q     Q Q"
792 print"        Q    Q  Q Q  Q     Q  Q"
793 print"         QQQQ    Q   QQQQQ Q   Q"
794 print""
795 print""
796 print"{white}your score is: ";SC%
797 return



!- GAME OVER HANDLER
!- /////////////////

800 print CS$
!- Print game over screen
810 gosub 775
820 end



!- SNAKE SPRITE DATA
!- /////////////////

1000 data 0,170,128
1001 data 2,85,96
1002 data 9,85,88
1003 data 37,85,86
1004 data 37,21,22
1005 data 36,132,134
1006 data 36,132,134
1007 data 36,132,134
1008 data 37,21,22
1009 data 37,85,86
1010 data 9,85,88
1011 data 9,85,88
1012 data 2,85,96
1013 data 2,93,96
1014 data 0,157,128
1015 data 0,12,0
1016 data 0,12,0
1017 data 0,63,0
1018 data 0,51,0
1019 data 0,192,192
1020 data 0,192,192



!- MUSIC DATA
!- //////////


1125 DATA 21,154,63,24,63,63
1130 DATA 25,177,250,24,63,125
1135 DATA 19,63,250,-1,-1,-1

