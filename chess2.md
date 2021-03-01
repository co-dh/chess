
q)\l chess2.q
~~~q
q)
\l rel.q
map: (raze string 1+til 8)!(1+til 8)#\:" " ; / number 1 to 8 represent spaces.
map["/"]: "\n"                             ; / / to separate each row.
pieces: "rnbqkpRNBQKP "
map[pieces]: pieces;
unicode: pieces!("♜";"♞";"♝";"♛";"♚";"♟";"♖";"♘";"♗";"♕";"♔";"♙";enlist" "); / count of 1 unicode char is not 1.
board: { "\n"vs raze map x}                       ; /given a FEN, return the board as 8X8 byte arrays of pieces

attack:()!()    ; / dictionary from piece to attack relation.

Pos2Row: raze 8#'enlist each(neg til 8)rotate\:10000000b; / The relation from position to row
Pos2Col: raze 8# enlist     (neg til 8)rotate\:10000000b; /   and to column.
pos2Row: raze (first where)@' Pos2Row;                  ; / Position to row number 
pos2Col: raze (first where)@' Pos2Col;                  ; / Position to column number 
SameRow: Same Pos2Row                                   ; / Positions of the same row
SameCol: Same Pos2Col                                   ; /   and same rank.
attack[`R]:attack[`r]: SameRow | SameCol                ; / Rook can attack by row and rank. (Ignore block for now)

diff :{x-/:\:x} /diff table of an array to itself
/ King can attack any positions that have row/column absolute difference < 2 
attack[`k]:attack[`K]: (and). 2>abs each diff each (pos2Row;pos2Col); 
attack[`P]:( 1=diff pos2Row)&(1=abs diff pos2Col) /`white Pawn at g1 attacks f2 and h2. 
attack[`p]:(-1=diff pos2Row)&(1=abs diff pos2Col) /`black pawn at a8 attacks b7

diagonal    : -7+til 15             ; / Diagonal are numbered from -7 to 7 for symetry.
pos2Down : pos2Col-pos2Row       ; / Each position have a right down diagonal,
pos2Up   : -7+pos2Col+pos2Row    ; /   and a right up diagonal. 
Pos2Up   : pos2Up  =\:diagonal   ;
Pos2Down : pos2Down=\:diagonal   ;
attack[`B]: attack[`b]: Same[Pos2Up] | Same Pos2Down;

/anything below \ will be ignored by q

\
~~~
# Chess Puzzle Solver in Relational Mathematics.


## Forsyth-Edwards(FEN) chess notation display

There are 6 kind of pieces: King,Queen, Bishop,kNight,Rook,Pawn.
The Forsyth-Edwards Notation use lower case letter for black pieces, and upper case for white pieces.

~~~q
fen: "5b2/p3n2r/3R2pp/k1p1Bp2/2B1p3/1P6/P1P2PPP/2K5" ; / an example
q)-1@bd: board fen;
     b  
p   n  r
   R  pp
k p Bp  
  B p   
 P      
P P  PPP
  K     
~~~


It would be nice to show above output as a mMarkdown table.

### Show Chess Board as Markdown Table
~~~q
mdRow: {"|",("|" sv x),"|"} ; / render a row as Markdown table row.
q)print: {-1@x;} /print string with line return
q)print first chessHeader: mdRow each enlist@'' ("ABCDEFGH"; 8#"-") /chess table header in Markdown
|A|B|C|D|E|F|G|H|
q)chessRow: {mdRow raze unicode enlist each x } ; / display row as Markdown
q)-1@chessRow bd[2];
| | | |♖| | |♟|♟|
q)/ generate Markdown table for a chess board. x: str[]
q)mdBoard: {-1@"\n"; -1@chessHeader,chessRow each x; -1@"\n";} ;
~~~


Some css for chess board. It's not working on github, but works in Chrome plugin.
<style type="text/css" rel="stylesheet">
.markdown-body table td { 
    font-size: 2.5em; 
    width:60px; height:60px; 
    padding: 0px 0px; 
    text-align:center;
    vertical-align: middle;
    } 

.markdown-body table tr:nth-child(odd) td:nth-child(even){
    background: #eed;
}
.markdown-body table tr:nth-child(even) td:nth-child(odd){
    background: #eed;
}

.markdown-body table tr:nth-child(odd) td:nth-child(odd){
    background: #ffe;
}
.markdown-body table tr:nth-child(even) td:nth-child(even){
    background: #ffe;
}

</style>

mdBoard board fen


|A|B|C|D|E|F|G|H|
|-|-|-|-|-|-|-|-|
| | | | | |♝| | |
|♟| | | |♞| | |♜|
| | | |♖| | |♟|♟|
|♚| |♟| |♗|♟| | |
| | |♗| |♟| | | |
| |♙| | | | | | |
|♙| |♙| | |♙|♙|♙|
| | |♔| | | | | |


q)
## What Positions will be attacked by a chess piece?

### Rook attacks in row and column.

There are 64 poistions in a chessboard. Positions are listed from 0(a8) to 63(h1).
However, it's more natural to mark a8 as row 0, column 0 when print to screen. 
So instead of use chess ranks and files, we use row and column. 

Pos2Row is a boolean matrix from 64 positions to row 0, 1,..7, and position 0 is related to row 0,
and row 0 is the first bit of 100000000b. This form is used so we can use the `Same` function to
find out positions that are on the same row/column.


~~~q
sh: {show 8 cut x;}; Show: show;
q)sh Pos2Row          / The relation from position to row. The first position map to first row(100000000b)
10000000b 10000000b 10000000b 10000000b 10000000b 10000000b 10000000b 10000000b
01000000b 01000000b 01000000b 01000000b 01000000b 01000000b 01000000b 01000000b
00100000b 00100000b 00100000b 00100000b 00100000b 00100000b 00100000b 00100000b
00010000b 00010000b 00010000b 00010000b 00010000b 00010000b 00010000b 00010000b
00001000b 00001000b 00001000b 00001000b 00001000b 00001000b 00001000b 00001000b
00000100b 00000100b 00000100b 00000100b 00000100b 00000100b 00000100b 00000100b
00000010b 00000010b 00000010b 00000010b 00000010b 00000010b 00000010b 00000010b
00000001b 00000001b 00000001b 00000001b 00000001b 00000001b 00000001b 00000001b
q)sh Pos2Col          /   and to column.
10000000b 01000000b 00100000b 00010000b 00001000b 00000100b 00000010b 00000001b
10000000b 01000000b 00100000b 00010000b 00001000b 00000100b 00000010b 00000001b
10000000b 01000000b 00100000b 00010000b 00001000b 00000100b 00000010b 00000001b
10000000b 01000000b 00100000b 00010000b 00001000b 00000100b 00000010b 00000001b
10000000b 01000000b 00100000b 00010000b 00001000b 00000100b 00000010b 00000001b
10000000b 01000000b 00100000b 00010000b 00001000b 00000100b 00000010b 00000001b
10000000b 01000000b 00100000b 00010000b 00001000b 00000100b 00000010b 00000001b
10000000b 01000000b 00100000b 00010000b 00001000b 00000100b 00000010b 00000001b
q)sh first SameRow    / Positions of the same row as position 0
11111111b
00000000b
00000000b
00000000b
00000000b
00000000b
00000000b
00000000b
q)sh first SameCol    /   and same rank.
10000000b
10000000b
10000000b
10000000b
10000000b
10000000b
10000000b
10000000b
q)sh first attack[`R] /` rook at position 0 can attack all positions of same row or column.
11111111b
10000000b
10000000b
10000000b
10000000b
10000000b
10000000b
10000000b
~~~


It's also convenitent to know which row/colunm(the index) of each position. 

### King attack 1 step away.

King can move/attack 1 step in any direction, except those are occupied by it's own piece, or 
attacked by the opposite.

So we need a mapping from position to row number, and column number

~~~q
sh pos2Row          / Position to row number.
0 0 0 0 0 0 0 0
1 1 1 1 1 1 1 1
2 2 2 2 2 2 2 2
3 3 3 3 3 3 3 3
4 4 4 4 4 4 4 4
5 5 5 5 5 5 5 5
6 6 6 6 6 6 6 6
7 7 7 7 7 7 7 7
q)sh pos2Col          / Position to column number
0 1 2 3 4 5 6 7
0 1 2 3 4 5 6 7
0 1 2 3 4 5 6 7
0 1 2 3 4 5 6 7
0 1 2 3 4 5 6 7
0 1 2 3 4 5 6 7
0 1 2 3 4 5 6 7
0 1 2 3 4 5 6 7
~~~


diff function create a table t of count[x] by count[x], with t[i;j]: x[i] - x[j]

~~~q
diff
{x-/:\:x}
q)diff 1 2 3 4
0 -1 -2 -3
1 0  -1 -2
2 1  0  -1
3 2  1  0 
~~~


`diff pos2Row` gives us a 64X64 table t, with t[i;j] stores the row difference of position i, and j

~~~q
sh first diff pos2Row       / row difference between position 0 and others.
0  0  0  0  0  0  0  0 
-1 -1 -1 -1 -1 -1 -1 -1
-2 -2 -2 -2 -2 -2 -2 -2
-3 -3 -3 -3 -3 -3 -3 -3
-4 -4 -4 -4 -4 -4 -4 -4
-5 -5 -5 -5 -5 -5 -5 -5
-6 -6 -6 -6 -6 -6 -6 -6
-7 -7 -7 -7 -7 -7 -7 -7
~~~


and we take it's absolute value and compare with 2
~~~q
sh first 2>abs diff pos2Row / positions with row difference to position 0 < 2
11111111b
11111111b
00000000b
00000000b
00000000b
00000000b
00000000b
00000000b
~~~


and we do the same thing for column, and get King's attack positions at each positions.
King can attack any positions that have row/column absolute difference < 2. 

~~~q
sh first attack[`k] /`
11000000b
11000000b
00000000b
00000000b
00000000b
00000000b
00000000b
00000000b
~~~


for example, at position 0(A8), king can only move/attack to 3 positions A7, B8,B7 like above, plus position 0.

### Pawn attack: white pawn(P) attack up left and up right, so row-1, column+-1

~~~q
sh last 1=diff pos2Row   / all positions in rank 2 are 1 row less than h1.
00000000b
00000000b
00000000b
00000000b
00000000b
00000000b
11111111b
00000000b
q)sh last 1=abs diff pos2Col   / file 7 is 1 column less than h1.
00000010b
00000010b
00000010b
00000010b
00000010b
00000010b
00000010b
00000010b
q)sh first -2 # attack[`P] /`white pawn g1 attacks f2 and h2.
00000000b
00000000b
00000000b
00000000b
00000000b
00000000b
00000101b
00000000b
q)sh first      attack[`p] /`black pawn a8 attacks b7
00000000b
01000000b
00000000b
00000000b
00000000b
00000000b
00000000b
00000000b
~~~


### Bishops and Queen move and attack in diagonals

There are each 15 diagonals at goes down and up( read from left to right), we use -7 .. 7 to represent each. 
a8 is at up diagonal 7, a7->b8 6

~~~q
diagonal    : -7+til 15             ; / Diagonal are numbered from -7 to 7 for symetry.
q)sh pos2Down / Each position have a right down diagonal,
0  1  2  3  4  5  6  7
-1 0  1  2  3  4  5  6
-2 -1 0  1  2  3  4  5
-3 -2 -1 0  1  2  3  4
-4 -3 -2 -1 0  1  2  3
-5 -4 -3 -2 -1 0  1  2
-6 -5 -4 -3 -2 -1 0  1
-7 -6 -5 -4 -3 -2 -1 0
q)sh pos2Up   /   and a right up diagonal.
-7 -6 -5 -4 -3 -2 -1 0
-6 -5 -4 -3 -2 -1 0  1
-5 -4 -3 -2 -1 0  1  2
-4 -3 -2 -1 0  1  2  3
-3 -2 -1 0  1  2  3  4
-2 -1 0  1  2  3  4  5
-1 0  1  2  3  4  5  6
0  1  2  3  4  5  6  7
q)diagonal where Pos2Up[48]  /A2 is at up diagonal -1
,-1
q)diagonal where Pos2Down[8] /A7 is at down diagonal -1
,-1
q)sh attack[`B]35 / `Bishop d4 attacks these positions.
00000001b
10000010b
01000100b
00101000b
00010000b
00101000b
01000100b
10000010b
~~~


### Knight move by (1,2) leap.(TODO)

## King mobility analysis.
Given board like this:

mdBoard board fen


|A|B|C|D|E|F|G|H|
|-|-|-|-|-|-|-|-|
| | | | | |♝| | |
|♟| | | |♞| | |♜|
| | | |♖| | |♟|♟|
|♚| |♟| |♗|♟| | |
| | |♗| |♟| | | |
| |♙| | | | | | |
|♙| |♙| | |♙|♙|♙|
| | |♔| | | | | |


q)
~~~q

q)/ Given a chess board, return the positions attacked by all pieces of the same kind
q)/ piece: sym. A single character symbol that represent a piece. e.g. R for white rook
q)/ board: sym. A 64 character sym that describe a chess board with piece on it.
q)/             A8 at board[0].
q)/ return: All positions attacked all pieces designated by piece.
q)Attack:{[piece; board]; any attack[piece] where board=piece}
q)
q)bd: `$/:raze bd; /turn chess board into 64 syms
q)show bd
``````b```p````n```r````R```p`p`k``p``B`p`````B``p`````P```````P``P```P`P`P``..
q)sh Attack[`R; bd]; /White rook attacks following pieces.(Blocking ignored)
00010000b
00010000b
11111111b
00010000b
00010000b
00010000b
00010000b
00010000b
q)sh Attack[`B; bd]; /B attack
01000011b
00100110b
10011100b
01011000b
00110100b
01110010b
11001001b
10000100b
q)sh Attack[`P; bd]; /White pawns attack these positions
00000000b
00000000b
00000000b
00000000b
10100000b
01011111b
00000000b
00000000b
q)sh attacked: any `R`B`P Attack\:bd  /These positions attacked by all white pieces.
01010011b
00110110b
11111111b
01011000b
10110100b
01111111b
11011001b
10010100b
q)sh Attack[`k; bd]; /where black king can move to.
00000000b
00000000b
11000000b
11000000b
11000000b
00000000b
00000000b
00000000b
q)sh k:Attack[`k; bd] & not attacked; /`k cannot move to attacked positions.
00000000b
00000000b
00000000b
10000000b
01000000b
00000000b
00000000b
00000000b
~~~


To solve the puzzle, we need to find a piece that can attack ememy's king and all of it's legal positions.

~~~q
move: attack ; / most pieces move and attack the same way, except pawns.
q)show B:where bd = `B /`B's positions are at e5(28), c4(34)
28 34
q)ma: move[`B] I attack[`B] /White Bishop can attack these positions in 2 steps.
q)sh first ma[B] /Be5 can attack these positions in 2 steps
01010101b
10101010b
01010101b
10101010b
01010101b
10101010b
01010101b
10101010b
q)all each k <=/: ma[B]  /and it covers all kings legal positions.
10b
q)where all each k<=/:ma[B] /first white bishop(e5) can attack all k's position in 2 steps.
,0
q)/ we ignored that when bishop e5 moves, it's need to be removed from the orinal attacked position.
~~~


