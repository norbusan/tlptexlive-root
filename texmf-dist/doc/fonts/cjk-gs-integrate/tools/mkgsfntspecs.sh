#!/bin/bash

# This program is licensed under the terms of the MIT License. 
#
# Copyright (c) 2014 Munehiro Yamamoto <munepixyz@gmail.com>
# Modified 05/04/2015 by Bruno Voisin <bvoisin@mac.com> for testing purposes
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

GSRESDIR=$(pwd)/Work/share/ghostscript/9.16/Resource

echo -n "Checking your Ghostscript's resource directory..."
[ -d ${GSRESDIR} ] || exit 1
echo ${GSRESDIR}

#
# settings for Hiragino fonts
#
FontList=(
    ## Morisawa NewCID
    Ryumin-Light,Japan
    GothicBBB-Medium,Japan
    FutoMinA101-Bold,Japan
    FutoGoB101-Bold,Japan
    Jun101-Light,Japan
    A-OTF-RyuminPro-Light,Japan
    A-OTF-GothicBBBPro-Medium,Japan
    A-OTF-FutoMinA101Pro-Bold,Japan
    A-OTF-FutoGoB101Pro-Bold,Japan
    A-OTF-Jun101Pro-Light,Japan
    ## Screen Hiragino bundled in OS X
    HiraKakuPro-W3,Japan
    HiraKakuPro-W6,Japan
    HiraKakuStd-W8,Japan
    HiraMaruPro-W4,Japan
    HiraMinPro-W3,Japan
    HiraMinPro-W6,Japan
    HiraKakuProN-W3,Japan
    HiraKakuProN-W6,Japan
    HiraKakuStdN-W8,Japan
    HiraMaruProN-W4,Japan
    HiraMinProN-W3,Japan
    HiraMinProN-W6,Japan
    HiraginoSansGB-W3,GB
    HiraginoSansGB-W6,GB
    # HiraginoSansCNS-W3,CNS
    # HiraginoSansCNS-W6,CNS
    ## Jiyukobo Yu bundled in OS X 
    YuGo-Bold,Japan
    YuGo-Medium,Japan
    YuMin-Demibold,Japan
    YuMin-Medium,Japan
    ## Japanese IPA fonts bundled in TeX Live 
    IPAexMincho,Japan
    IPAexGothic,Japan
    IPAMincho,Japan
    IPAGothic,Japan
    ## Chinese fonts bundled in OS X 
    STHeiti,GB
    STXihei,GB
    STHeitiSC-Light,GB
    STHeitiSC-Medium,GB
    STHeitiTC-Light,GB
    STHeitiTC-Medium,GB
    STSong,GB
    STSongti-SC-Light,GB
    STSongti-SC-Regular,GB
    STSongti-SC-Bold,GB
    STSongti-SC-Black,GB
    STSongti-TC-Light,GB
    STSongti-TC-Regular,GB
    STSongti-TC-Bold,GB
    STKaiti,GB
    STKaiti-SC-Regular,GB
    STKaiti-SC-Bold,GB
    STKaiti-SC-Black,GB
    STKaiTi-TC-Regular,GB
    STKaiTi-TC-Bold,GB
    STKaiti-Adobe-CNS1,CNS
    STKaiti-SC-Regular-Adobe-CNS1,CNS
    STKaiti-SC-Bold-Adobe-CNS1,CNS
    STKaiti-SC-Black-Adobe-CNS1,CNS
    STKaiTi-TC-Regular-Adobe-CNS1,CNS
    STKaiTi-TC-Bold-Adobe-CNS1,CNS
    STFangsong,GB
    LiHeiPro,CNS
    LiSongPro,CNS
)

EncodeList_Japan=(
    78-EUC-H
    78-EUC-V
    78-H
    78-RKSJ-H
    78-RKSJ-V
    78-V
    78ms-RKSJ-H
    78ms-RKSJ-V
    83pv-RKSJ-H
    90ms-RKSJ-H
    90ms-RKSJ-V
    90msp-RKSJ-H
    90msp-RKSJ-V
    90pv-RKSJ-H
    90pv-RKSJ-V
    Add-H
    Add-RKSJ-H
    Add-RKSJ-V
    Add-V
    Adobe-Japan1-0
    Adobe-Japan1-1
    Adobe-Japan1-2
    Adobe-Japan1-3
    Adobe-Japan1-4
    Adobe-Japan1-5
    Adobe-Japan1-6
    EUC-H
    EUC-V
    Ext-H
    Ext-RKSJ-H
    Ext-RKSJ-V
    Ext-V
    H
    Hankaku
    Hiragana
    Identity-H
    Identity-V
    Katakana
    NWP-H
    NWP-V
    RKSJ-H
    RKSJ-V
    Roman
    UniJIS-UCS2-H
    UniJIS-UCS2-HW-H
    UniJIS-UCS2-HW-V
    UniJIS-UCS2-V
    UniJIS-UTF16-H
    UniJIS-UTF16-V
    UniJIS-UTF32-H
    UniJIS-UTF32-V
    UniJIS-UTF8-H
    UniJIS-UTF8-V
    UniJIS2004-UTF16-H
    UniJIS2004-UTF16-V
    UniJIS2004-UTF32-H
    UniJIS2004-UTF32-V
    UniJIS2004-UTF8-H
    UniJIS2004-UTF8-V
    UniJISPro-UCS2-HW-V
    UniJISPro-UCS2-V
    UniJISPro-UTF8-V
    UniJISX0213-UTF32-H
    UniJISX0213-UTF32-V
    UniJISX02132004-UTF32-H
    UniJISX02132004-UTF32-V
    V
    WP-Symbol
)

EncodeList_GB=(
    Adobe-GB1-0
    Adobe-GB1-1
    Adobe-GB1-2
    Adobe-GB1-3
    Adobe-GB1-4
    Adobe-GB1-5
    GB-EUC-H
    GB-EUC-V
    GB-H
    GB-RKSJ-H
    GB-V
    GBK-EUC-H
    GBK-EUC-V
    GBK2K-H
    GBK2K-V
    GBKp-EUC-H
    GBKp-EUC-V
    GBT-EUC-H
    GBT-EUC-V
    GBT-H
    GBT-RKSJ-H
    GBT-V
    GBTpc-EUC-H
    GBTpc-EUC-V
    GBpc-EUC-H
    GBpc-EUC-V
    Identity-H
    Identity-V
    UniGB-UCS2-H
    UniGB-UCS2-V
    UniGB-UTF16-H
    UniGB-UTF16-V
    UniGB-UTF32-H
    UniGB-UTF32-V
    UniGB-UTF8-H
    UniGB-UTF8-V
)

EncodeList_CNS=(
    Adobe-CNS1-0
    Adobe-CNS1-1
    Adobe-CNS1-2
    Adobe-CNS1-3
    Adobe-CNS1-4
    Adobe-CNS1-5
    Adobe-CNS1-6
    B5-H
    B5-V
    B5pc-H
    B5pc-V
    CNS-EUC-H
    CNS-EUC-V
    CNS1-H
    CNS1-V
    CNS2-H
    CNS2-V
    ETHK-B5-H
    ETHK-B5-V
    ETen-B5-H
    ETen-B5-V
    ETenms-B5-H
    ETenms-B5-V
    HKdla-B5-H
    HKdla-B5-V
    HKdlb-B5-H
    HKdlb-B5-V
    HKgccs-B5-H
    HKgccs-B5-V
    HKm314-B5-H
    HKm314-B5-V
    HKm471-B5-H
    HKm471-B5-V
    HKscs-B5-H
    HKscs-B5-V
    Identity-H
    Identity-V
    UniCNS-UCS2-H
    UniCNS-UCS2-V
    UniCNS-UTF16-H
    UniCNS-UTF16-V
    UniCNS-UTF32-H
    UniCNS-UTF32-V
    UniCNS-UTF8-H
    UniCNS-UTF8-V
)

EncodeList_Korea=(
    Adobe-Korea1-0
    Adobe-Korea1-1
    Adobe-Korea1-2
    Identity-H
    Identity-V
    KSC-EUC-H
    KSC-EUC-V
    KSC-H
    KSC-Johab-H
    KSC-Johab-V
    KSC-RKSJ-H
    KSC-V
    KSCms-UHC-H
    KSCms-UHC-HW-H
    KSCms-UHC-HW-V
    KSCms-UHC-V
    KSCpc-EUC-H
    KSCpc-EUC-V
    UniKS-UCS2-H
    UniKS-UCS2-V
    UniKS-UTF16-H
    UniKS-UTF16-V
    UniKS-UTF32-H
    UniKS-UTF32-V
    UniKS-UTF8-H
    UniKS-UTF8-V
)

## mkgsfontspec [fontname] [encode] > [fontspec]
mkgsfontspec(){
    local fontname=$1
    local encode=$2
	cat <<EOT
%%!PS-Adobe-3.0 Resource-Font
%%%%DocumentNeededResources: ${encode} (CMap)
%%%%IncludeResource: ${encode} (CMap)
%%%%BeginResource: Font (${fontname}-${encode})
(${fontname}-${encode})
(${encode}) /CMap findresource
[(${fontname}) /CIDFont findresource]
composefont
pop
%%%%EndResource
%%%%EOF
EOT
}

## mkfontspec [fontspec dir]
mkfontspec(){
    local FONTSPECDIR=$1

    mkdir -p $FONTSPECDIR

    for i in ${FontList[@]}; do
        fnt=$(echo $i | cut -f1 -d",")
        enc=$(echo $i | cut -f2 -d",")

        case $enc in
    	    Japan)	enclist="${EncodeList_Japan[@]}";;
	    GB)	enclist="${EncodeList_GB[@]}";;
	    CNS)	enclist="${EncodeList_CNS[@]}";;
	    Korea)	enclist="${EncodeList_Korea[@]}";;
	    *)	exit 1;;
        esac

        for j in $enclist; do
    	    mkgsfontspec ${fnt} ${j} > ${FONTSPECDIR}/${fnt}-${j}
        done
    done

    return 0
}

## mkcidfonts [cidfonts dir]
mkcidfonts(){
    local CIDFONTSDIR=$1

    mkdir -p $CIDFONTSDIR
    (cd $CIDFONTSDIR
        rm -f HiraMinPro{,N}-W{3,6}
        rm -f HiraMaruPro{,N}-W4
        rm -f HiraKakuPro{,N}-W{3,6}
        rm -f HiraKakuStd{,N}-W8
        rm -f HiraginoSansGB-W{3,6}

        ln -s "/Library/Fonts/ヒラギノ明朝 Pro W3.otf" HiraMinPro-W3
        ln -s "/Library/Fonts/ヒラギノ明朝 Pro W6.otf" HiraMinPro-W6
        ln -s "/Library/Fonts/ヒラギノ丸ゴ Pro W4.otf" HiraMaruPro-W4
        ln -s "/Library/Fonts/ヒラギノ角ゴ Pro W3.otf" HiraKakuPro-W3
        ln -s "/Library/Fonts/ヒラギノ角ゴ Pro W6.otf" HiraKakuPro-W6
        ln -s "/Library/Fonts/ヒラギノ角ゴ Std W8.otf" HiraKakuStd-W8
        ln -s "/System/Library/Fonts/ヒラギノ明朝 ProN W3.otf" HiraMinProN-W3
        ln -s "/System/Library/Fonts/ヒラギノ明朝 ProN W6.otf" HiraMinProN-W6
        ln -s "/Library/Fonts/ヒラギノ丸ゴ ProN W4.otf" HiraMaruProN-W4
        ln -s "/System/Library/Fonts/ヒラギノ角ゴ ProN W3.otf" HiraKakuProN-W3
        ln -s "/System/Library/Fonts/ヒラギノ角ゴ ProN W6.otf" HiraKakuProN-W6
        ln -s "/Library/Fonts/ヒラギノ角ゴ StdN W8.otf" HiraKakuStdN-W8
        ln -s "/Library/Fonts/Hiragino Sans GB W3.otf" HiraginoSansGB-W3
        ln -s "/Library/Fonts/Hiragino Sans GB W6.otf" HiraginoSansGB-W6
	
        rm -f YuMin-{Medium,Demibold}
        rm -f YuGo-{Medium,Bold}

        ln -s "/Library/Fonts/Yu Mincho Medium.otf" YuMin-Medium
        ln -s "/Library/Fonts/Yu Mincho Demibold.otf" YuMin-Demibold
        ln -s "/Library/Fonts/Yu Gothic Medium.otf" YuGo-Medium
        ln -s "/Library/Fonts/Yu Gothic Bold.otf" YuGo-Bold

        rm -f STHeiti.ttf
        rm -f STXihei.ttf
        rm -f STFangsong.ttf
        rm -f LiHeiPro.ttf
        rm -f LiSongPro.ttf

        ln -s /Library/Fonts/华文黑体.ttf STHeiti.ttf
        ln -s /Library/Fonts/华文细黑.ttf STXihei.ttf
        ln -s /Library/Fonts/华文仿宋.ttf STFangsong.ttf
        ln -s "/Library/Fonts/儷黑 Pro.ttf" LiHeiPro.ttf
        ln -s "/Library/Fonts/儷宋 Pro.ttf" LiSongPro.ttf
    )
    
    return 0
}


# generate the Ghostscript FontSpec files for the Hiragino fonts 
# bundled on Mac OS X
mkfontspec ${GSRESDIR}/Font
mkcidfonts ${GSRESDIR}/CIDFont

echo $(basename $0): done

# end of file
