MAKEJVF =  makejvf
TFTOPL  = uptftopl -kanji=utf8
PLTOTF  = uppltotf -kanji=uptex
MAKEJVFG3 = $(MAKEJVF) -i -u gb -3
MAKEJVFC3 = $(MAKEJVF) -i -u cns -3
MAKEJVFJ3 = $(MAKEJVF) -i -u jis -3
MAKEJVFK  = $(MAKEJVF) -i -u ks
MAKEJVFJ  = $(MAKEJVF) -i -u jis
MAKEJVFJQ = $(MAKEJVF) -i -u jisq

all: tfm vf pstfm

pl:
	$(TFTOPL) `kpsewhich jis.tfm` jis.pl
	perl -s -n -C makepl.perl jis.pl > upjisr-h.pl
	perl -s -n -C makepl.perl -hk jis.pl > upjisr-h-hk.pl
	$(TFTOPL) `kpsewhich jis-v.tfm` jis-v.pl
	perl -s -n -C makepl.perl jis-v.pl > upjisr-v.pl

tfm:
	for fnt in upjisr upjisg upjpnrm upjpngt ; do \
		$(PLTOTF) upjisr-h-hk.pl $$fnt-h.tfm ; \
	done ; \
	for fnt in upjisr upjisg upjpnrm upjpngt ; do \
		$(PLTOTF) upjisr-v.pl $$fnt-v.tfm ; \
	done ; \
	for hv in h v ; do \
	for fnt in upkorrm upkorgt upschrm upschgt uptchrm uptchgt ; do \
		$(PLTOTF) upjisr-$$hv.pl $$fnt-$$hv.tfm ; \
	done ; \
	done
	for fnt in upjisr-hq upjisg-hq ; do \
		$(PLTOTF) upjisr-h.pl $$fnt.tfm ; \
	done

pstfm:
	for fnt in uprml upgbm ; do \
		$(PLTOTF) uprml-h-hk.pl $$fnt-h.tfm ; \
	done
	for fnt in uphysmjm uphygt upstsl upstht upmsl upmhm ; do \
		$(PLTOTF) uprml-h.pl $$fnt-h.tfm ; \
	done
	for fnt in uprml upgbm ; do \
		$(PLTOTF) uprml-h.pl $$fnt-hq.tfm ; \
	done

vf:
	$(MAKEJVFJ) -H -U upjisr-hq upjisr-h.tfm uprml-h
	$(MAKEJVFJ) -H -U upjisg-hq upjisg-h.tfm upgbm-h
	$(MAKEJVFJ) upjisr-v.tfm uprml-v
	$(MAKEJVFJ) upjisg-v.tfm upgbm-v
	$(MAKEJVFJQ) upjisr-hq.tfm uprml-hq
	$(MAKEJVFJQ) upjisg-hq.tfm upgbm-hq
	$(MAKEJVFJ3) -H -U upjisr-hq upjpnrm-h.tfm uprml-h
	$(MAKEJVFJ3) -H -U upjisg-hq upjpngt-h.tfm upgbm-h
	$(MAKEJVFJ3) upjpnrm-v.tfm uprml-v
	$(MAKEJVFJ3) upjpngt-v.tfm upgbm-v
	$(MAKEJVFK) upkorrm-h.tfm uphysmjm-h
	$(MAKEJVFK) upkorgt-h.tfm uphygt-h
	$(MAKEJVFK) upkorrm-v.tfm uphysmjm-v
	$(MAKEJVFK) upkorgt-v.tfm uphygt-v
	$(MAKEJVFG3) upschrm-h.tfm upstsl-h
	$(MAKEJVFG3) upschgt-h.tfm upstht-h
	$(MAKEJVFG3) upschrm-v.tfm upstsl-v
	$(MAKEJVFG3) upschgt-v.tfm upstht-v
	$(MAKEJVFC3) uptchrm-h.tfm upmsl-h
	$(MAKEJVFC3) uptchgt-h.tfm upmhm-h
	$(MAKEJVFC3) uptchrm-v.tfm upmsl-v
	$(MAKEJVFC3) uptchgt-v.tfm upmhm-v

move:
	mkdir -pv ../../../tfm/uptex/jis ../../../vf/uptex/jis
	mv -i *.tfm ../../../tfm/uptex/jis
	mv -i *.vf ../../../vf/uptex/jis
