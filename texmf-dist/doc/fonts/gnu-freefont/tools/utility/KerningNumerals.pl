#!/usr/bin/perl
=pod

=head1 KerningNumerals.pl

Move kerning information from ASCII numerals (U+0030...) to characters in
the Adobe corporate use area (U+F6xx).

By: Primož Peterlin, 2003

$Id: KerningNumerals.pl,v 1.2 2003-05-15 12:04:41 peterlin Exp $

=cut

sub numerically { $a <=> $b; }

if ($#ARGV != 0) {
    print $#ARGV;
    die "Usage: $0 file.sfd\n";
}

open(INFILE, $ARGV[0]) || die "Failed to open file: $ARGV[0]\n";

while (<INFILE>) {
    if (/^Kerns:/) {
	# Old-style kerning information
	chomp;
	# Cut off the first seven characters ("Kerns: ")
	substr($_,0,7) = "";
	@values = split;
	# Construct the hash $kern{$code}
	for ($i = 0; $i <= $#values; $i += 2) {
	    $code = $values[$i];
	    # Recode ASCII numerals to Adobe corporate use values
	    if ($code == 48) {
		$code = 63033;
	    } elsif ($code == 49) {
		$code = 63196;
	    } elsif ($code == 50) {
		$code = 63034;
	    } elsif ($code == 51) {
		$code = 63035;
	    } elsif ($code == 52) {
		$code = 63036;
	    } elsif ($code == 53) {
		$code = 63037;
	    } elsif ($code == 54) {
		$code = 63038;
	    } elsif ($code == 55) {
		$code = 63039;
	    } elsif ($code == 56) {
		$code = 63040;
	    } elsif ($code == 57) {
		$code = 63041;
	    }
	    $kern{$code} = $values[$i+1];
	}
	print "Kerns:";
	foreach $code (sort numerically keys(%kern)) {
	    print " ",$code," ",$kern{$code};
	}
	print "\n";
	# Clean-up
	foreach $code (keys(%kern)) {
	    delete $kern{$code};
	}
    } elsif (/^KernsSLIF:/) {
	# New-style kerning information
	chomp;
	# Cut off the first eleven characters ("KernsSLIF: ")
	substr($_,0,11) = "";
	@values = split;
	# Construct the hash $kern{$code}
	for ($i = 0; $i <= $#values; $i += 4) {
	    $code = $values[$i];
	    # Recode ASCII numerals to Adobe corporate use values
	    if ($code == 48) {
		$code = 63033;
	    } elsif ($code == 49) {
		$code = 63196;
	    } elsif ($code == 50) {
		$code = 63034;
	    } elsif ($code == 51) {
		$code = 63035;
	    } elsif ($code == 52) {
		$code = 63036;
	    } elsif ($code == 53) {
		$code = 63037;
	    } elsif ($code == 54) {
		$code = 63038;
	    } elsif ($code == 55) {
		$code = 63039;
	    } elsif ($code == 56) {
		$code = 63040;
	    } elsif ($code == 57) {
		$code = 63041;
	    }
	    $kern{$code} = $values[$i+1];
	    $unx{$code}  = $values[$i+2];
	    $uny{$code}  = $values[$i+3];
	}
	print "KernsSLIF:";
	foreach $code (sort numerically keys(%kern)) {
	    print " ",$code," ",$kern{$code}," ",$unx{$code}," ",$uny{$code};
	}
	print "\n";
	# Clean-up
	foreach $code (keys(%kern)) {
	    delete $kern{$code};
	}
    } else {
	# All other lines
	print;
    }
}

close(INFILE);
