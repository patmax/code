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
200 MX=100 : GOSUB 1000:GOTO 2000



!- INITIALIZE LINKED LIST
!- ======================

1000 DIM SN$(MX):DIM NX%(MX)
1010 NX%(2)=0:FP = MX
1020 SN$(1)="SENTINEL":NX%(1)=0
1030 FOR I=3 TO MX:NX%(I)=I-1:NEXT
1040 RETURN



!- ALLOCATE FREE SPACE IN LINKED LIST
!- ==================================

1100 P = FP:IF P THEN FP = NX%(P)
1110 RETURN



!- RELEASE INDEX IN LINKED LIST
!- ============================

1200 IF P=1 THEN RETURN:REM DON'T FREE SENTINEL NODE
1210 SN$(P)="":NX%(P)=FP:FP=P:RETURN



!- INSERT NODE POINTED TO BY P
!- ===========================

1300 NX%(P)=NX%(1):NX%(1)=P:RETURN



!- INSERT ELEMENT E AT HEAD OF LINKED LIST
!- =======================================
1400 GOSUB 1100:SN$(P)=E$:GOTO 1300



!- DELETE NODE AT HEAD
!- ===================

1500 P = NX%(1):IF P=0 THEN RETURN
1510 NX%(1)=NX%(P):GOTO 1200



!- SEARCH LIST FOR E (P=Node Or 0, M=Previous Node)
!- ================================================
1600 M=1:P=NX%(1)
1610 IF P=0 THEN RETURN
1620 IF SN$(P)=E$ THEN RETURN
1630 M=P:P=NX%(M):GOTO 1610



!- REMOVE NODE CONTAINING E FROM LIST 
!- ==================================

1700 GOSUB 1600:IF P=0 THEN RETURN
1710 NX%(M)=NX%(P):GOTO 1200



!- MAIN GAME
!- =========

2000 PRINT CS$
2001 E$ = "test"
2002 GOSUB 1400 
2003 E$ = "hallo"
2004 GOSUB 1400
2005 E$ = "test"
2006 GOSUB 1600 
2009 PRINT "node"; SN$(P); SN$(M)
2010 POKE RCNT%, 90
2020 FOR I=0 TO 1e17 
2030 GOSUB 3000
2040 NEXT I



!- UPDATE GAME FIELD
!- =================

!-2000 FOR X = 0 TO 1000 
!-2020 IF F%(X) = SH% THEN POKE X+1024,90 : GOTO 2050
!-2030 IF F%(X) = SB% THEN POKE X+1024,87 : GOTO 2050
!-2040 IF F%(X) = FD% THEN POKE X+1024,102 : GOTO 2050
!-2050 NEXT X




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
