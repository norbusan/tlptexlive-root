ヒラギノ従属欧文の利用
齋藤修三郎

【ライセンス】
修正 BSDとします．

ヒラギノの欧文部分を利用するためのTFMとVFです．β版とすら呼べない，α版です．
T1エンコーディングとOT1エンコーディングとTS1エンコーディングのTFM, VFがあります．
LY1エンコーディングもあります．T3エンコーディングも追加しました．

プリアンブルで
\usepackage{hiraprop}
とすることで，従属欧文が使えるようになります．

\hmrfamilyでヒラギノ明朝体の，\hsffamilyでヒラギノ角ゴシック体の，\hmgfamilyで
ヒラギノ丸ゴシック体の従属欧文が，それぞれ使えるようになります．

以下をdvipdfmxとudvipsのそれぞれのマップファイルのエントリに追加してください．
%for dvipdfmx
hiramin-w3-h Identity-H HiraMinPro-W3
hiramin-w6-h Identity-H HiraMinPro-W6
hirakaku-w3-h Identity-H HiraKakuPro-W3
hirakaku-w6-h Identity-H HiraKakuPro-W6
hiramaru-w4-h Identity-H HiraMaruPro-W4

%for udvips
hiramin-w3-h HiraMinPro-W3-Identity-H
hiramin-w6-h HiraMinPro-W6-Identity-H
hirakaku-w3-h HiraKakuPro-W3-Identity-H
hirakaku-w6-h HiraKakuPro-W6-Identity-H
hiramaru-w4-h HiraMaruPro-W4-Identity-H

【変更履歴】
2012/6/1
・修正BSDライセンスを適用しました．
2004/2/18
・VFにおけるTFMの割り当て先が変更されました．各種マップファイルの変更をお願いします．
