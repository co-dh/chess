\d .r
Id:{x cut(x*x)#1b,x#0b}; Top:{x[0]#enlist x[1]#1b};  Bot:{x[0]#enlist x[1]#0b};
/composition
.q.I:{$[
      x~`t               ; .z.s[Top 2#count y;y]                
    ; x~`b               ; .z.s[Bot 2#count y;y]                 
    ; y~`t               ; .z.s[x            ;Top 2#count x 0]  
    ; y~`b               ; .z.s[x            ;Bot 2#count x 0]  
    ; y~`i               ; x
    ; x~`i               ; y
    ; y~`I               ; .z.s[x            ;not Id count x 0]
    ; count[x 0]<>count y; 'IncompatibleMatrix
    ; 1b                 ; [x:(|/)each y where each x; c:count each x; w: where 0=c; @[x;w;:;count[w]#enlist ((|/)c)#0b]]
    ]};
Shape:{count each (x; x 0)};

.q.In:{$[
      x~`i; .z.s[    Id count y; y]
    ; x~`I; .z.s[not Id count y; y]
    ; y~`i; .z.s[x;     Id count x]
    ; y~`I; .z.s[x; not Id count x]
    ; x~`t; .z.s[Top Shape y; y]
          ; (&/)(&/)x<=y]};
          
Rand: {x#`boolean$((*/)x)?2} /create a random boolean matrix of shape x
Dom:{x I`t}; Cod:{flip[x] I`t }; Upa:{x&not x I`I}; Mup:{x&x I`I}; UniZone:{Dom Upa x}; MulZone:{Dom Mup x};
Dual:{flip not x};
.q.LRes:{not flip[x] I not y}; .q.RRes:{not not[x]!flip y}; .q.Syq:{.q.LRes[x;y]&.q.LRes[not x; not y]};
UniVal:{(flip[x]I x) In `i}; Inj:{UniVal flip x};
Tot:{`t In x I `t}         ; Surj:{Tot flip x};
Mapping:{Tot[x]&UniVal x}  ; Bij:{Inj[x] & Surj x};
Vec:{x~x I `t}             ; Pnt:{ Vec[x]&Bij x};
Refl:{`i In x};            ; Irrefl:{x In `I};
SemiConnex: {`I In x|flip x}; Connex: {`t In  x|flip x};
Sym: {x~flip x}; Asym:{flip[x] In not x}; Antisym:{(x&flip[x]) In `i};

Tournament:{Asym[x]&SemiConnex x};
Trans:{(x I x) In x};

.q.And:{[f;g] {[f;g;x]f[x]&g x}[f;g]}
/Preorder:{Refl[x] & Trans x}; StrictOrder:{Trans[x] & Asym x}; Order:{StrictOrder[x]&Refl x};
Preorder:Refl And Trans; StrictOrder: Trans And Asym; Order: StrictOrder And Refl
Homo:{count[x]=count x 0};
Equi: Homo And Refl And Trans And Sym;
Difunct:{x~x I flip[x] I x};

/
\d .
show a: (0000000000001b;0100000100000b;0010001101010b;0110000100001b;0001001001101b);
show b: (000101110100b; 100100100100b;110011010001b; 110000101011b;000101110000b)
a Syq b

UniVal:{(&/)2>sum each x}  /another implementation

1b~UniVal (010b;001b)
1b~Vec (000b;111b;111b)
0b~Vec (000b;110b;111b)
0b~Pnt (000b;111b;111b)
1b~Pnt a:(000b;111b;000b)
1b~`i In (11b;01b)
1b~`I In (01b;11b)
0b~`I In (01b;01b)
0b~`i In (00b;01b)
1b~(00b;01b) In `i
1b ~ Refl {x LRes x} Rand 10 10
10b~(SemiConnex;Connex)@\: (0001b;1111b;1001b;0100b)
11b~(SemiConnex;Connex)@\: (1111b;0100b;1111b;0101b)
11b~(Asym; Antisym)@\: (0110b;0000b;0101b;0100b)
01b~(Asym; Antisym)@\: (0001b;1110b;0000b;0101b)
1b ~ Trans {x LRes x} Rand 10 10
1b~Difunct raze 3 2 2 2 #'enlist each (11000000000b;00111100000b;00000011100b;00000000000b)
