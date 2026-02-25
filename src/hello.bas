10 rem c64 vibe hello demo
20 poke53280,6:poke53281,0:poke646,1
30 print chr$(147);
40 print chr$(5);chr$(18);"   c64 vibe coding lab   ";chr$(146)
50 print
60 print chr$(30);"      hello, world!"
70 print chr$(31);"   from vscode + vice"
80 print
90 print chr$(18);chr$(81);chr$(81);chr$(81);"   8-bit magic   ";chr$(81);chr$(81);chr$(81);chr$(146)
100 print
110 for c=2 to 7
120 poke646,c
130 print chr$(29);chr$(29);chr$(29);"* * * petscii party * * *"
140 for d=1 to 120:next d
150 next c
160 poke646,1
170 print
180 print chr$(28);"      press run/stop"
190 end
