#! /bin/sh


do_gb() {
# simplified chinese uses STSong-Light
platex "\def\dviware{dvipdfmx}\input adobe-GB1-012.tex" && \
    dvipdfmx -o adobe-GB1-012.dvipdfmx.pdf adobe-GB1-012.dvi
platex "\def\dviware{dvips}\input adobe-GB1-012.tex" && \
    dvips adobe-GB1-012.dvi
platex "\def\dviware{dvipdfmx}\input adobe-GB1-345.tex" && \
    dvipdfmx -o adobe-GB1-345.dvipdfmx.pdf adobe-GB1-345.dvi
platex "\def\dviware{dvips}\input adobe-GB1-345.tex" && \
    dvips adobe-GB1-345.dvi

for i in `perl ../cjk-gs-integrate.pl --list-aliases --machine-readable -q | grep ^STSong-Light: | awk -F: '{print$3}'`; do
	perl ../cjk-gs-integrate.pl --only-aliases --alias STSong-Light=$i
	echo ps2pdf adobe-GB1-012.ps -o "adobe-GB1-012-$i.pdf"
	if ps2pdf adobe-GB1-012.ps "adobe-GB1-012-$i.pdf" > "adobe-GB1-012-$i.ps2pdf.log" 2>&1 ; then
		echo "success GB1-012 $i" >> status
	else
		echo "failure GB1-012 $i" >> status
	fi
	echo ps2pdf adobe-GB1-345.ps -o "adobe-GB1-345-$i.pdf"
	if ps2pdf adobe-GB1-345.ps "adobe-GB1-345-$i.pdf" > "adobe-GB1-345-$i.ps2pdf.log" 2>&1 ; then
		echo "success GB1-345 $i" >> status
	else
		echo "failure GB1-345 $i" >> status
	fi
done
}


do_cns() {
# traditional chinese uses MSung-Light
platex "\def\dviware{dvipdfmx}\input adobe-CNS1.tex" && \
    dvipdfmx -o adobe-CNS1.dvipdfmx.pdf adobe-CNS1.dvi
platex "\def\dviware{dvips}\input adobe-CNS1.tex" && \
    dvips adobe-CNS1.dvi
for i in `perl ../cjk-gs-integrate.pl --list-aliases --machine-readable -q | grep ^MSung-Light: | awk -F: '{print$3}'`; do
	perl ../cjk-gs-integrate.pl --only-aliases --alias MSung-Light=$i
	echo ps2pdf adobe-CNS1.ps -o "adobe-CNS1-$i.pdf"
	if ps2pdf adobe-CNS1.ps "adobe-CNS1-$i.pdf" > "adobe-CNS1-$i.ps2pdf.log" 2>&1 ; then
		echo "success CNS1 $i" >> status
	else
		echo "failure CNS1 $i" >> status
	fi
done
}

do_korea() {
# korean uses HYSMyeongJo-Medium
platex "\def\dviware{dvipdfmx}\input adobe-Korea1.tex" && \
    dvipdfmx -o adobe-Korea1.dvipdfmx.pdf adobe-Korea1.dvi
platex "\def\dviware{dvips}\input adobe-Korea1.tex" && \
    dvips adobe-Korea1.dvi
for i in `perl ../cjk-gs-integrate.pl --list-aliases --machine-readable -q | grep ^HYSMyeongJo-Medium: | awk -F: '{print$3}'`; do
	perl ../cjk-gs-integrate.pl --only-aliases --alias HYSMyeongJo-Medium=$i
	echo ps2pdf adobe-Korea1.ps -o "adobe-Korea1-$i.pdf"
	if ps2pdf adobe-Korea1.ps "adobe-Korea1-$i.pdf" > "adobe-Korea1-$i.ps2pdf.log" 2>&1 ; then
		echo "success Korea1 $i" >> status
	else
		echo "failure Korea1 $i" >> status
	fi
done
}

do_japan() {
# japanese uses Ryumin-Light
platex "\def\dviware{dvipdfmx}\input adobe-Japan1.tex" && \
    dvipdfmx -o adobe-Japan1.dvipdfmx.pdf adobe-Japan1.dvi
platex "\def\dviware{dvips}\input adobe-Japan1.tex" && \
    dvips adobe-Japan1.dvi
for i in `perl ../cjk-gs-integrate.pl --list-aliases --machine-readable -q | grep ^Ryumin-Light: | awk -F: '{print$3}'`; do
	perl ../cjk-gs-integrate.pl --only-aliases --alias Ryumin-Light=$i
	echo ps2pdf adobe-Japan1.ps -o "adobe-Japan1-$i.pdf"
	if ps2pdf adobe-Japan1.ps "adobe-Japan1-$i.pdf" > "adobe-Japan1-$i.ps2pdf.log" 2>&1 ; then
		echo "success Japan1 $i" >> status
	else
		echo "failure Japan1 $i" >> status
	fi
done
}

if [ "$1" = "gb" -o "$1" = "all" ] ; then 
  do_gb
fi
if [ "$1" = "cns" -o "$1" = "all" ] ; then 
  do_cns
fi
if [ "$1" = "korea" -o "$1" = "all" ] ; then 
  do_korea
fi
if [ "$1" = "japan" -o "$1" = "all" ] ; then 
  do_japan
fi

