verbatimtex
%&uplatex-utf8
\documentclass{ujarticle}
\begin{document}
etex;
beginfig(1);
u=40;
v=40;
r=30;
draw (u+r,v)..(u,v+r)..(u-r,v)..(u,v-r)..cycle withcolor red;
% set3対応フォント+dviware なら「𠮷」もUTF-8で直接書ける。
label(btex ◎①α髙吉。ｶﾅ｡ etex, (u,v));
u:=u+46;
draw (u+r,v)..(u,v+r)..(u-r,v)..(u,v-r)..cycle withcolor blue;
label(btex \tate ◎①α髙吉。 etex, (u,v));
u:=u-23;
v:=v+40;
draw (u+r,v)..(u,v+r)..(u-r,v)..(u,v-r)..cycle withcolor green;
label(btex 面積は $\pi r^2$ etex, (u,v));
endfig;
end.
