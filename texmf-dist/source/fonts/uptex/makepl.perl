#!/usr/bin/perl -n -s

use utf8;

$hankana=$hk; # option -hk

if (/CHARWD|FONTAT|MOVERIGHT|QUAD|GLUE/) {
    s/0\.96221\d/1.000000/g; # 
    s/0\.72166\d/0.750000/g; # 
    s/0\.48110\d/0.500000/g; # 
    s/0\.24055\d/0.250000/g; # 
} elsif (/CHAR(HT|DP)|XHEIGHT|\(STRETCH|EXTRASPACE|EXTRASTRE|EXTRASHRINK/) {
    s/0\.09164\d/0.100000/; # 0.100000 STRETCH
    s/0\.91644\d/1.000000/; # 1.000000 XHEIGHT
    s/0\.22910\d/0.250000/; # 0.250000 EXTRASPACE
    s/0\.18328\d/0.200000/; # 0.200000 EXTRASTRETCH
    s/0\.11455\d/0.125000/; # 0.125000 EXTRASHRINK
    s/0\.77758\d/0.880000/; # 0.880000 CHARHT
    s/0\.13885\d/0.120000/; # 0.120000 CHARDP
    s/0\.45822\d/0.500000/; # 0.500000 CHARHT, CHARDP (vertical)
} elsif (/FAMILY/) {
    s/ JIS / UPJIS /;
} elsif (/CHARSINTYPE\s+\S+\s+(\d+)/) {
    $charsintype=$1;
} elsif (/LABEL\s+\S+\s+(\d+)/) {
    $label=$1;
} elsif (/TYPE\s+\S+\s+(\d+)/) {
    $type=$1;
}

if ($charsintype==1 && /\)/) {
    print <<END;
   UFF5F U3018 U3016 U301D 
END
    $charsintype=undef;
}
if ($charsintype==2 && /\)/) {
    print <<END;
   UFF60 U3019 U3017 U301F 
END
    $charsintype=undef;
}
if ($charsintype==5) {
    s/\x{2014}|\x{2015}/\x{2014} \x{2015}/g;
}

if ($hankana) {

if ($label==2 && /STOP\)/) {
    print <<END;
   (GLUE O 6 R 0.500000 R 0.0 R 0.500000)
END
}
if ($label==3 && /STOP\)/) {
    print <<END;
   (GLUE O 6 R 0.250000 R 0.0 R 0.250000)
END
}
if ($label==4 && /STOP\)/) {
    print <<END;
   (GLUE O 6 R 0.500000 R 0.0 R 0.0)
END
}
if ($type==2 && /^      \)/) {
    print <<END;
      (GLUE O 6 R 0.500000 R 0.0 R 0.500000)
END
}
if ($type==3 && /^      \)/) {
    print <<END;
      (GLUE O 6 R 0.250000 R 0.0 R 0.250000)
END
}
if ($type==4 && /^      \)/) {
    print <<END;
      (GLUE O 6 R 0.500000 R 0.0 R 0.0)
END
}

} # if $hankana

print;

next unless ($hankana);

if ($charsintype==5 && /\)/) {
    print <<END;
(CHARSINTYPE O 6
   UFF61 UFF62 UFF63 UFF64 UFF65 UFF66 UFF67
   UFF68 UFF69 UFF6A UFF6B UFF6C UFF6D UFF6E UFF6F
   UFF70 UFF71 UFF72 UFF73 UFF74 UFF75 UFF76 UFF77
   UFF78 UFF79 UFF7A UFF7B UFF7C UFF7D UFF7E UFF7F
   UFF80 UFF81 UFF82 UFF83 UFF84 UFF85 UFF86 UFF87
   UFF88 UFF89 UFF8A UFF8B UFF8C UFF8D UFF8E UFF8F
   UFF90 UFF91 UFF92 UFF93 UFF94 UFF95 UFF96 UFF97
   UFF98 UFF99 UFF9A UFF9B UFF9C UFF9D UFF9E UFF9F
   )
END
    $charsintype=undef;
}
if ($label==5 && /STOP\)/) {
    print <<END;
   (LABEL O 6)
   (GLUE O 1 R 0.500000 R 0.0 R 0.500000)
   (GLUE O 3 R 0.250000 R 0.0 R 0.250000)
   (STOP)
END
    $label=undef;
}
if ($type==5 && /^   \)/) {
    print <<END;
(TYPE O 6
   (CHARWD R 0.500000)
   (CHARHT R 0.880000)
   (CHARDP R 0.120000)
   (COMMENT
      (GLUE O 1 R 0.500000 R 0.0 R 0.500000)
      (GLUE O 3 R 0.250000 R 0.0 R 0.250000)
      )
   )
END
    $type=undef;
}
