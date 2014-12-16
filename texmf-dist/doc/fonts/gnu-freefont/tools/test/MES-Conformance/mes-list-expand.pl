#!/usr/bin/perl
# $Id: mes-list-expand.pl,v 1.1 2009-12-27 16:25:15 Stevan_White Exp $
#
# Expand MES ranges, as available in CEN documents, into simple list
# of character codes.

# Unicode table
$tblfile = "/usr/local/share/unicode/UnicodeData-Latest.txt";
# Array size
$#table = 65535;

# Read in complete Unicode table for the named entities
open(TABLE, "<$tblfile") || die "Cannot find $tblfile\n";
while (<TABLE>) {
    ($code,$name) = split(/[;\n]/, $_, 9999);
    $table[hex($code)] = $name;
}
close(TABLE);

if ($#ARGV >= 0) {
    open(RANGE, $ARGV[0]);
} else {
    open(RANGE, "<stdin");
}
while (<RANGE>) {
    if (/^\#.*/) {
        next;
    } else {
	($page,$codes) = split(/[\t]/, $_, 9999);
	chomp $codes;
	@range = split(/ /, $codes, 9999);
	for ($i = 0; $i <= $#range; $i++) {
	    if (length($range[$i]) == 2) {
		$code = 256*hex($page) + hex($range[$i]);
		printf("%04X:%s\n", $code, $table[$code]);
	    } else {
		($lower,$upper) = split(/-/, $range[$i], 9999);
		for ($j = hex($lower); $j <= hex($upper); $j++) {
		    $code = 256*hex($page) + $j;
		    printf("%04X:%s\n", $code, $table[$code]);
		}
	    }
	}
    }
}
