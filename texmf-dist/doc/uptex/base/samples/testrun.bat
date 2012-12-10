del *.dvi *.aux *.log *.ps *.pdf *.1 *.mpx

rem misc
for %%f in (misc set3) ^
do ( ^
uplatex %%f-check-utf8 && ^
uplatex "\def\withhyperref{dvipdfmx}\input" %%f-check-utf8.tex && ^
uplatex "\def\withhyperref{dvipdfmx}\input" %%f-check-utf8.tex && ^
updvitype -kanji=uptex %%f-check-utf8.dvi > %%f-check-utf8.pdvitype && ^
updvipdfmx %%f-check-utf8 && ^
uplatex "\def\withhyperref{dvips}\input" %%f-check-utf8.tex && ^
updvips %%f-check-utf8 && ^
uplatex %%f-check-utf8 )
for %%f in (misc) ^
do ( ^
uplatex %%f-check-v-utf8 && ^
uplatex "\def\withhyperref{dvipdfmx}\input" %%f-check-v-utf8.tex && ^
uplatex "\def\withhyperref{dvipdfmx}\input" %%f-check-v-utf8.tex && ^
updvitype -kanji=uptex %%f-check-v-utf8.dvi > %%f-check-v-utf8.pdvitype && ^
updvipdfmx -l %%f-check-v-utf8 && ^
uplatex "\def\withhyperref{dvips}\input" %%f-check-v-utf8.tex && ^
updvips -t landscape %%f-check-v-utf8 && ^
uplatex %%f-check-v-utf8 )

rem kinsoku
uplatex kinsoku-chk-utf8
dvipdfmx kinsoku-chk-utf8
updvips kinsoku-chk-utf8

rem widow
platex widow
move widow.dvi widow-platex.dvi
dvipdfmx widow-platex.dvi
uplatex widow
move widow.dvi widow-u-uptex.dvi
dvipdfmx widow-u-uptex.dvi

rem uptex
uptex sangoku-uptex
dvipdfmx sangoku-uptex
updvips sangoku-uptex

rem uplatex
uplatex sangoku-uplatex
dvipdfmx sangoku-uplatex
updvips sangoku-uplatex

rem aozora
for %%c in (ujarticle ujreport ujbook utarticle utreport utbook) ^
do ( ^
uplatex aozora-%%c-utf8 && ^
dvipdfmx aozora-%%c-utf8 && ^
updvips aozora-%%c-utf8 )

rem adobe
for %%c in (jp kr gb cns) ^
do ( ^
uptex adobe-%%c-utf8 && ^
updvipdfmx adobe-%%c-utf8 && ^
updvips adobe-%%c-utf8 )

rem jbib
uplatex jbib2-utf8.tex
upjbibtex -kanji=uptex --kanji-internal=uptex jbib2-utf8
uplatex jbib2-utf8.tex
uplatex jbib2-utf8.tex

rem jmpost
for %%f in (area jstr) ^
do ( ^
upjmpost -kanji=uptex -tex=uplatex %%f-uptex.mp && ^
uplatex %%f-uptex-incl.tex && ^
updvips %%f-uptex-incl.dvi && ^
updvipdfmx %%f-uptex-incl.dvi )

rem updvi2tty
platex -kanji=jis simple-jis.tex
move simple-jis.dvi simple-jis-platex.dvi
for %%f in (j e s u) ^
do ( ^
updvi2tty -w 62 -o simple-jis-platex-%%f.dvi2tty -E %%f simple-jis-platex.dvi )
uplatex simple-u-jis.tex
move simple-u-jis.dvi simple-u-jis-uptex.dvi
for %%f in (j e s u) ^
do ( ^
updvi2tty -w 62 -o simple-u-jis-uptex-%%f.dvi2tty -E %%f simple-u-jis-uptex.dvi )


rem
rem following samples require the utf package
rem 

rem utf
uplatex utfsmpl-uplatex
updvipdfmx utfsmpl-uplatex
updvips utfsmpl-uplatex

rem
rem following samples require the otf package
rem 

rem otf
uplatex otfsmpl-uplatex
updvipdfmx otfsmpl-uplatex
updvips otfsmpl-uplatex

rem adobe
for %%c in (jp kr gb cns) ^
do ( ^
uplatex "\def\adobe{%%c}\input" adobe-cid && ^
move adobe-cid.dvi adobe-%%c-mc-cid.dvi && ^
updvipdfmx adobe-%%c-mc-cid && ^
updvips adobe-%%c-mc-cid )
for %%c in (jp kr cns) ^
do ( ^
uplatex "\def\adobe{%%c}\def\family{gt}\input" adobe-cid && ^
move adobe-cid.dvi adobe-%%c-gt-cid.dvi && ^
updvipdfmx adobe-%%c-gt-cid && ^
updvips adobe-%%c-gt-cid )

rem uotftest
for %%o in (default deluxe expert bold noreplace) ^
do ( ^
uplatex "\def\option{%%o}\def\class{ujarticle}\input" uotftest-utf8.tex && ^
move uotftest-utf8.dvi uotftest-%%o-h-uplatex.dvi && ^
updvipdfmx uotftest-%%o-h-uplatex.dvi && ^
uplatex "\def\option{%%o}\def\class{utarticle}\input" uotftest-utf8.tex && ^
move uotftest-utf8.dvi uotftest-%%o-v-uplatex.dvi && ^
updvipdfmx uotftest-%%o-v-uplatex.dvi && ^
platex "\def\option{%%o}\def\class{jarticle}\input" uotftest.tex && ^
move uotftest.dvi uotftest-%%o-h-platex.dvi && ^
dvipdfmx uotftest-%%o-h-platex.dvi && ^
platex "\def\option{%%o}\def\class{tarticle}\input" uotftest.tex && ^
move uotftest.dvi uotftest-%%o-v-platex.dvi && ^
dvipdfmx uotftest-%%o-v-platex.dvi )
