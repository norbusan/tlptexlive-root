#
# Makefile to test pagebox=artbox etc. in platex with dvipdfmx
#
# files pagebox-dx.tex, pagebox-pd.tex, image1.tex, image2.tex
# are written by Y. Terada.
#

all: pagebox-dx.pdf pagebox-pd.pdf

pagebox-dx.pdf: pagebox-dx.tex image1.pdf image2.pdf
	platex pagebox-dx.tex
	dvipdfmx pagebox-dx.dvi

pagebox-pd.pdf: pagebox-pd.tex image1.pdf image2.pdf
	pdflatex pagebox-pd.tex

image1.pdf: image1.tex
	pdflatex $<

image2.pdf: image2.tex
	pdflatex $<

clean::
	rm -f *~ *.log *.aux *.dvi pagebox-dx.pdf pagebox-pd.pdf
