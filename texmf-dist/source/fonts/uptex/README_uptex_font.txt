jis font for upTeX/upLaTeX


The files in this directory are
based on "jis font TFM & VF set"
by ASCII Corporation (currently ASCII MEDIA WORKS Inc.)
and modified for upTeX/upLaTeX.
These are available under the license agreement in "README_ASCII_Corp.txt".

このディレクトリのファイルは、
株式会社アスキー(現 株式会社アスキー・メディアワークス)による
「jisフォントTFM&VFセット」をもとに
upTeX/upLaTeX向けに改変したものです。
"README_ASCII_Corp.txt" の内容にしたがってご利用ください。


Setting in addition to jis.tfm:
jis.tfm などから追加した設定:
Type1: U+FF5F U+3018 U+3016 U+301D 
Type2: U+FF60 U+3019 U+3017 U+301F 
Type5: JIS 0x213D -> U+2014 and U+2015

                  men-ku-ten
                   面-区-点
U+FF5F: JIS X 0213  1-02-54 始め二重バーレーン
U+3018: JIS X 0213  1-02-56 始め二重亀甲括弧
U+3016: JIS X 0213  1-02-58 始めすみ付き括弧(白)
U+301D: JIS X 0213  1-13-64 始めダブルミニュート
U+FF60: JIS X 0213  1-02-55 終わり二重バーレーン
U+3019: JIS X 0213  1-02-57 終わり二重亀甲括弧
U+3017: JIS X 0213  1-02-59 終わりすみ付き括弧(白)
U+301F: JIS X 0213  1-13-65 終わりダブルミニュート

U+2014: EM DASH
U+2015: HORIZONTAL BAR
        JIS X 0208    01-29 ダッシュ(全角) (0x213D)
        JIS X 0213  1-01-29 ダッシュ(全角)

JIS -> Unicode conversion is ambiguos and depends on tables.
0x213D -> U+2014 : JIS, Macintosh, nkf, JavaJRE1.4.0 or lator
0x213D -> U+2015 : Windows, gd, JavaJRE1.3.1, upTeX


#### ChangeLog

uptex-1.00 [2012/01/15] TTK
  * re-package for upTeX/upLaTeX Ver.1.00 distribution.
  * makepl.perl, upjisr-h{,-hk}.pl, upjisr-v.pl,
    upjis{r,g}-{h,v}.tfm, up{jpn,kor,sch,tch}{rm,gt}-{h,v}.tfm:
    add U+2014 as Type 5 in tfm files.
  * upjpn{rm,gt}-{h,v}.vf:
    add CJK Unified Ideographs Extension C,D.
  * Makefile:
    update.

v20110507a [2011/05/07] TTK
  * re-package for upTeX/upLaTeX based on uptex-0.30 distribution.
