#!/usr/bin/perl
# $Id: CheckConformance.pl,v 1.1 2009-12-27 16:25:15 Stevan_White Exp $
#
# Check conformance of font file with given character sets.

# Get the characters in the font file
# Regexp for ENCODING line matches BDF and PfaEdit's SFD formats
if ($#ARGV >= 0) {
    open(FONTFILE, $ARGV[0]);
} else {
    open(FONTFILE, "<stdin");
}
while (<FONTFILE>) {
    if (/^E[Nn][Cc][Oo][Dd][Ii][Nn][Gg]:? ([\d]+)/) {
	$char{$1} = 1;
    }
}
close (FONTFILE);

$tbldir = "./";
@tables = ("MES-1.lst", "MES-2.lst", "MES-3B.lst");

foreach $table (0 .. $#tables) {

    $tblfile = $tbldir.$tables[$table];

    # Read in the table with the named entities
    open(TABLE, "<$tblfile") || die "Cannot find $tblfile\n";
    delete @table{keys %table};
    while (<TABLE>) {
	if (/^\#.*/) {
	    next;
	} else {
	    chomp;
	    ($code,$name) = split(/:/, $_, 9999);
	    $table{hex($code)} = $name;
	}
    }
    close(TABLE);
    
    # Get the list of missing chars, sorted numerically by their code
    foreach $key (sort {$a <=> $b} keys %table) {
	if ($char{$key} != 1) {
	    push @missing, $key;
	}
    }
    
    # Print the list of missing chars, code and ISO 10646 name
    if ($#missing >= 0) {
	print "\n$#missing characters are found missing for conformance with ";
	print "$tblfile:\n";
	for ($i = 0; $i <= $#missing; $i++) {
	    printf("%04X  %s\n", $missing[$i], $table{$missing[$i]});
	}
    } else {
	print "\nCongratulations!\n";
	print "No characters are found missing for conformance with ";
	print "$tblfile.\n";
    }
}
