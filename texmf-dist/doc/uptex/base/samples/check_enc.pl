#!/usr/bin/perl

# This software is public domain.

#
# Perl 5.8.x + Encode.pm or Perl5.6.x + Jcode.pm is required.
if ($] >= 5.008) {
    eval('use Encode::Guess qw/euc-jp shiftjis 7bit-jis utf8/;');
    $@ and &error_exit;
    %perl_encname =
	qw/euc euc-jp jis 7bit-jis sjis shiftjis utf8 utf8 uptex utf8
           e euc-jp j 7bit-jis s shiftjis u utf8/;
    $Encodepm = 1;
} elsif ($] >= 5.006) {
    eval('use Jcode;');
    $@ and &error_exit;
    %perl_encname =
	qw/euc euc jis jis sjis sjis utf8 utf8 uptex utf8
           e euc j jis s sjis u utf8/;
    $Encodepm = 0;
} else {
    &error_exit;
}

$enc=shift @ARGV;
@files=@ARGV;

foreach $file (@files) {
    my $data;

    $data = undef;
    open(IN,$file) or die "check_enc:: Cannot open file $file\n";
    $data .= $_ while (<IN>);
    if ($Encodepm) {
	my $genc = eval('guess_encoding($data);');
	ref($genc) or die "check_enc:: Cannot guess: $genc, file:$file ($perl_encname{$enc})\n";
	$perl_guess = $genc->name;
    } else {
	$perl_guess = eval('getcode($data);');
    }
    if ($perl_guess ne $perl_encname{$enc}) {
	die "check_enc:: file:$file ($perl_guess) does not seem encoded by $perl_encname{$enc}\n";
    }
    print "check_enc:: OK! file:$file seems encoded by $perl_guess\n";

}

sub error_exit {
    print "check_enc:: Perl5.6.x + Jcode.pm or Perl5.8.x + Encode.pm is required. Cannot guess file encoding\n";
    sleep 1;
    exit(0);
}
