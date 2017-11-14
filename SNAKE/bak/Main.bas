!- CONSTANTS AND VARIABLES 
!- =======================

10 CS$ = CHR$(147)
20 KU$ = "w"
30 KD$ = "s"
40 KL$ = "a"
50 KR$ = "d"
60 DIM F%(1000) 
70 BL% = 0
80 SH% = 1
90 SB% = 2
100 FD% = 3 
!- Pressed keys are automatically repeated
110 POKE 650,128 
!- Most recent snake head location
120 RCNT% = 1524
!- Most recent moving direction
130 DRCTN$ = "" 
!- Change of location coordinates
140 ICR% = 0
!- Speed of the snake (30 is slowest, 0 is fastest)
150 VLCTY = 5
160 POKE 53281, 1
170 POKE 53280, 15
180 POKE 646, 5
!- Snake length
190 SL% = 0



!- MAIN GAME
!- =========

1000 PRINT CS$
1020 POKE RCNT%, 90
1030 FOR I=0 TO 1e17 
1040 GOSUB 3000
1050 NEXT I




!- UPDATE GAME FIELD
!- =================

2000 FOR X = 0 TO 1000 
2020 IF F%(X) = SH% THEN POKE X+1024,90 : GOTO 2050
2030 IF F%(X) = SB% THEN POKE X+1024,87 : GOTO 2050
2040 IF F%(X) = FD% THEN POKE X+1024,102 : GOTO 2050
2050 NEXT X




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
4010 IF (DRCTN$ = KU$ AND A$ = KD$) OR (DRCTN$ = KD$ AND A$ = KU$) OR (DRCTN$ = KL$ AND A$ = KR$) OR (DRCTN$ = KR$ AND A$ = KL$)GOTO 4060
!- If the snake hits the wall let it come out of to the opposite one
4020 IF ((RCNT%+ICR%-1023)-INT((RCNT%+ICR%-1023)/40)*40) = 0 THEN GOTO 9999 : GOTO 4030
4022 IF (RCNT%+ICR%)>2023 OR (RCNT%+ICR%) < 1024 THEN GOTO 9999
!- Update the recent position of the snake head
4025 RCNT%=RCNT%+ICR%
4030 IF A$ <>"" THEN DRCTN$ = A$ 
4040 IF RCNT%<>TMP% THEN POKE RCNT%,90 : POKE TMP%,96
4050 T = TI+VLCTY : FOR I=-1 TO 0 : I = TI<T : NEXT
4060 RETURN




9999 PRINT CS$
10000 PRINT "game over!"
