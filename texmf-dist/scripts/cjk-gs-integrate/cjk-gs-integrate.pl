#!/usr/bin/env perl
#
# cjk-gs-integrate - setup ghostscript for CID/TTF CJK fonts
#
# Copyright 2015 by Norbert Preining
#
# Based on research and work by Yusuke Kuroki, Bruno Voisin, Munehiro Yamamoto
# and the TeX Q&A wiki page
#
# This file is licensed under GPL version 3 or any later version.
# For copyright statements see end of file.
#
# For development see
#  https://github.com/norbusan/cjk-gs-support
#
# TODO:
# - how to deal with MacTeX pre-shipped configuration files?
# - interoperability with updmap-config-kanji
# - input from CK about font priorities
#

$^W = 1;
use Getopt::Long qw(:config no_autoabbrev ignore_case_always);
use File::Basename;
use File::Path qw(make_path);
use strict;

(my $prg = basename($0)) =~ s/\.pl$//;
my $version = '20151002.0';

if (win32()) {
  print_error("Sorry, currently not supported on Windows!\n");
  exit(1);
}

my %encode_list = (
  Japan => [ qw/
    2004-H
    2004-V
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
    WP-Symbol/ ],
  GB => [ qw/
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
    UniGB-UTF8-V/ ],
  CNS => [ qw/
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
    UniCNS-UTF8-V/ ],
  Korea => [ qw/
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
    UniKS-UTF8-V/ ] );

my $dry_run = 0;
my $opt_help = 0;
my $opt_quiet = 0;
my $opt_debug = 0;
my $opt_listaliases = 0;
my $opt_listallaliases = 0;
my $opt_listfonts = 0;
my $opt_remove = 0;
my $opt_info = 0;
my $opt_fontdef;
my $opt_output;
my @opt_aliases;
my $opt_only_aliases = 0;
my $opt_machine = 0;
my $opt_filelist;
my $opt_force = 0;
my $opt_texmflink;
my $opt_markdown = 0;

if (! GetOptions(
        "n|dry-run"   => \$dry_run,
        "info"        => \$opt_info,
        "list-aliases" => \$opt_listaliases,
        "list-all-aliases" => \$opt_listallaliases,
        "list-fonts"  => \$opt_listfonts,
        "link-texmf:s" => \$opt_texmflink,
        "remove"       => \$opt_remove,
        "only-aliases" => \$opt_only_aliases,
        "machine-readable" => \$opt_machine,
        "force"       => \$opt_force,
        "filelist=s"  => \$opt_filelist,
        "markdown"    => \$opt_markdown,
        "o|output=s"  => \$opt_output,
        "h|help"      => \$opt_help,
        "q|quiet"     => \$opt_quiet,
        "d|debug+"    => \$opt_debug,
        "f|fontdef=s" => \$opt_fontdef,
        "a|alias=s"   => \@opt_aliases,
        "v|version"   => sub { print &version(); exit(0); }, ) ) {
  die "Try \"$0 --help\" for more information.\n";
}

sub win32 { return ($^O=~/^MSWin(32|64)$/i); }
my $nul = (win32() ? 'nul' : '/dev/null') ;
my $sep = (win32() ? ';' : ':');
my %fontdb;
my %aliases;
my %user_aliases;

if ($opt_help) {
  Usage();
  exit 0;
}

if ($opt_debug) {
  require Data::Dumper;
  $Data::Dumper::Indent = 1;
}

if (defined($opt_texmflink)) {
  my $foo;
  if ($opt_texmflink eq '') {
    # option was passed but didn't receive a value
    #  -> use TEXMFLOCAL
    chomp( $foo = `kpsewhich -var-value=TEXMFLOCAL`);
  } else {
    # option was passed with an argument
    #  -> use it
    $foo = $opt_texmflink;
  }
  $opt_texmflink = $foo;
}


main(@ARGV);

#
# only sub definitions from here on
#
sub main {
  print_info("reading font database ...\n");
  read_font_database();
  determine_ttf_link_target(); # see comments there
  if (!$opt_listallaliases) {
    print_info("checking for files ...\n");
    check_for_files();
  } else {
    make_all_available();
  }
  compute_aliases();
  if ($opt_info) {
    $opt_listfonts = 1;
    $opt_listaliases = 1;
  }
  if ($opt_listfonts) {
    info_found_fonts();
  }
  if ($opt_listaliases || $opt_listallaliases) {
    print "List of ", ($opt_listaliases ? "all" : "available"), " aliases and their options (in decreasing priority):\n" unless $opt_machine;
    my (@jal, @kal, @tal, @sal);
    for my $al (sort keys %aliases) {
      my $cl;
      my @ks = sort { $a <=> $b} keys(%{$aliases{$al}});
      my $foo = '';
      $foo = "$al:\n" unless $opt_machine;
      for my $p (@ks) {
        my $t = $aliases{$al}{$p};
        my $fn = ($opt_listallaliases ? "-" : $fontdb{$t}{'target'} );
        # should always be the same ;-)
        $cl = $fontdb{$t}{'class'};
        if (!$opt_listallaliases && $fontdb{$t}{'type'} eq 'TTF' && $fontdb{$t}{'subfont'} > 0) {
          $fn .= "($fontdb{$t}{'subfont'})";
        }
        if ($opt_machine) {
          $foo .= "$al:$p:$aliases{$al}{$p}:$fn\n";
        } else {
          $foo .= "\t($p) $aliases{$al}{$p} ($fn)\n";
        }
      }
      if ($cl eq 'Japan') {
        push @jal, $foo;
      } elsif ($cl eq 'Korea') {
        push @kal, $foo;
      } elsif ($cl eq 'GB') {
        push @sal, $foo;
      } elsif ($cl eq 'CNS') {
        push @tal, $foo;
      } else {
        print STDERR "unknown class $cl for $al\n";
      }
    }
    if ($opt_machine) {
      print @jal if @jal;
      print @kal if @kal;
      print @tal if @tal;
      print @sal if @sal;
    } else {
      print "Aliases for Japanese fonts:\n", @jal, "\n" if @jal;
      print "Aliases for Korean fonts:\n", @kal, "\n" if @kal;
      print "Aliases for Traditional Chinese fonts:\n", @tal, "\n" if @tal;
      print "Aliases for Simplified Chinese fonts:\n", @sal, "\n" if @sal;
    }
  }
  exit(0) if ($opt_listfonts || $opt_listaliases || $opt_listallaliases);

  if (! $opt_output) {
    print_info("searching for GhostScript resource\n");
    my $gsres = find_gs_resource();
    if (!$gsres) {
      print_error("Cannot find GhostScript, terminating!\n");
      exit(1);
    } else {
      $opt_output = $gsres;
    }
  }
  if (! -d $opt_output) {
    $dry_run || mkdir($opt_output) || 
      die ("Cannot create directory $opt_output: $!");
  }
  print_info("output is going to $opt_output\n");
  if (!$opt_only_aliases) {
    print_info(($opt_remove ? "removing" : "generating") . " font snippets and link CID fonts ...\n");
    do_otf_fonts();
    print_info(($opt_remove ? "removing" : "generating") . " font snippets, links, and cidfmap.local for TTF fonts ...\n");
    do_ttf_fonts();
  }
  print_info(($opt_remove ? "removing" : "generating") . " font aliases ...\n");
  do_aliases();
  print_info("finished\n");
}

sub update_master_cidfmap {
  my $add = shift;
  my $cidfmap_master = "$opt_output/Init/cidfmap";
  print_info(sprintf("%s $add %s cidfmap file ...\n", 
    ($opt_remove ? "removing" : "adding"), ($opt_remove ? "from" : "to")));
  if (-r $cidfmap_master) {
    open(FOO, "<", $cidfmap_master) ||
      die ("Cannot open $cidfmap_master for reading: $!");
    my $found = 0;
    my $newmaster = "";
    # in add mode: just search for the entry and set $found
    # in remove mode: collect all lines that do not match
    while(<FOO>) {
      if (m/^\s*\(\Q$add\E\)\s\s*\.runlibfile\s*$/) {
        $found = 1;
      } else {
        $newmaster .= $_;
      }
    }
    close(FOO);
    if ($found) {
      if ($opt_remove) {
        open(FOO, ">", $cidfmap_master) ||
          die ("Cannot clean up $cidfmap_master: $!");
        print FOO $newmaster;
        close FOO;
      } else {
        print_info("$add already loaded in $cidfmap_master, no changes\n");
      }
    } else {
      return if $dry_run;
      return if $opt_remove;
      open(FOO, ">>", $cidfmap_master) ||
        die ("Cannot open $cidfmap_master for appending: $!");
      print FOO "($add) .runlibfile\n";
      close(FOO);
    }
  } else {
    return if $dry_run;
    return if $opt_remove;
    open(FOO, ">", $cidfmap_master) ||
      die ("Cannot open $cidfmap_master for writing: $!");
    print FOO "($add) .runlibfile\n";
    close(FOO);
  }
}

sub make_dir {
  my ($d, $w) = @_;
  if (-r $d) {
    if (! -d $d) {
      print_error("$d is not a directory, $w\n");
      exit 1;
    }
  } else {
    $dry_run || make_path($d);
  }
}

sub do_otf_fonts {
  my $fontdest = "$opt_output/Font";
  my $ciddest  = "$opt_output/CIDFont";
  make_dir($fontdest, "cannot create CID snippets there!");
  make_dir($ciddest,  "cannot link CID fonts there!");
  make_dir("$opt_texmflink/fonts/opentype/cjk-gs-integrate",
           "cannot link fonts to it!")
    if $opt_texmflink;
  for my $k (keys %fontdb) {
    if ($fontdb{$k}{'available'} && $fontdb{$k}{'type'} eq 'CID') {
      generate_font_snippet($fontdest,
        $k, $fontdb{$k}{'class'}, $fontdb{$k}{'target'});
      link_font($fontdb{$k}{'target'}, $ciddest, $k);
      link_font($fontdb{$k}{'target'}, "$opt_texmflink/fonts/opentype/cjk-gs-integrate")
        if $opt_texmflink;
    }
  }
}

sub generate_font_snippet {
  my ($fd, $n, $c, $f) = @_;
  return if $dry_run;
  for my $enc (@{$encode_list{$c}}) {
    if ($opt_remove) {
      unlink "$fd/$n-$enc" if (-f "$fd/$n-$enc");
      next;
    }
    open(FOO, ">$fd/$n-$enc") || 
      die("cannot open $fd/$n-$enc for writing: $!");
    print FOO "%%!PS-Adobe-3.0 Resource-Font
%%%%DocumentNeededResources: $enc (CMap)
%%%%IncludeResource: $enc (CMap)
%%%%BeginResource: Font ($n-$enc)
($n-$enc)
($enc) /CMap findresource
[($n) /CIDFont findresource]
composefont
pop
%%%%EndResource
%%%%EOF
";
    close(FOO);
  }
}

sub link_font {
  my ($f, $cd, $n) = @_;
  return if $dry_run;
  if (!$n) {
    $n = basename($f);
  }
  my $target = "$cd/$n";
  if ($opt_force && -e $target) {
    print_info("Removing $target prior to recreation due to --force\n");
    unlink($target) || die "Cannot unlink $target prior to recreation under --force: $!";
    return if $opt_remove;
  }
  if (-l $target) {
    my $linkt = readlink($target);
    if ($linkt && -r $linkt) {
      if ($linkt eq $f) {
        unlink($target) if $opt_remove;
        # do nothing, it is the same link
      } else {
        print_error("link $target already existing, but different target then $target, exiting!\n");
        exit(1);
      }
    } else {
      print_warning("removing dangling symlink $target to $linkt\n");
      unlink($target);
    }
  } else {
    if (-e $target) {
      print_error("$target already existing, but not a link, exiting!\n");
      exit(1);
    } else {
      if ($opt_remove) {
        unlink($target);
      } else {
        symlink($f, $target) || die("Cannot link font $f to $target: $!");
      }
    }
  }
}

sub do_ttf_fonts {
  my $fontdest = "$opt_output/Font";
  my $cidfsubst = "$opt_output/CIDFSubst";
  my $outp = '';
  make_dir($fontdest, "cannot create CID snippets there!");
  make_dir($cidfsubst,  "cannot link TTF fonts there!");
  make_dir("$opt_texmflink/fonts/truetype/cjk-gs-integrate",
           "cannot link fonts to it!")
    if $opt_texmflink;
  for my $k (keys %fontdb) {
    if ($fontdb{$k}{'available'} && $fontdb{$k}{'type'} eq 'TTF') {
      generate_font_snippet($fontdest,
        $k, $fontdb{$k}{'class'}, $fontdb{$k}{'target'});
      $outp .= generate_cidfmap_entry($k, $fontdb{$k}{'class'}, $fontdb{$k}{'ttfname'}, $fontdb{$k}{'subfont'});
      link_font($fontdb{$k}{'target'}, $cidfsubst, $fontdb{$k}{'ttfname'});
      link_font($fontdb{$k}{'target'}, "$opt_texmflink/fonts/truetype/cjk-gs-integrate", $fontdb{$k}{'ttfname'})
        if $opt_texmflink;
    }
  }
  return if $dry_run;
  if ($outp) {
    if (! -d "$opt_output/Init") {
      mkdir("$opt_output/Init") ||
        die("Cannot create directory $opt_output/Init: $!");
    }
    open(FOO, ">$opt_output/Init/cidfmap.local") || 
      die "Cannot open $opt_output/cidfmap.local: $!";
    print FOO $outp;
    close(FOO);
  }
  update_master_cidfmap('cidfmap.local');
}

sub do_aliases {
  my $fontdest = "$opt_output/Font";
  my $cidfsubst = "$opt_output/CIDFSubst";
  my $outp = '';
  #
  # alias handling
  # we use two levels of aliases, one is for the default names that
  # are not actual fonts:
  # Ryumin-Light, GothicBBB-Medium, FutoMinA101-Bold, FutoGoB101-Bold, 
  # Jun101-Light which are the original Morisawa names.
  #
  # the second level of aliases is for Morisawa OTF font names:
  # RyuminPro-Light, GothicBBBPro-Medium,
  # FutoMinA101Pro-Bold, FutoGoB101Pro-Bold
  # Jun101Pro-Light
  #
  # the order of fonts selected is
  # Morisawa Pr6, Morisawa, Hiragino ProN, Hiragino, 
  # Yu OSX, Yu Win, Kozuka ProN, Kozuka, IPAex, IPA
  # but is defined in the Provides(Priority): Name in the font definiton
  #
  $outp .= "\n\n% Aliases\n";
  #
  my (@jal, @kal, @tal, @sal);
  #
  for my $al (sort keys %aliases) {
    my $target;
    my $class;
    if ($user_aliases{$al}) {
      $target = $user_aliases{$al};
      # determine class
      if ($fontdb{$target}{'available'}) {
        $class = $fontdb{$target}{'class'};
      } else {
        # must be an aliases, we checked this when initializing %user_aliases
        # reset the $al value
        # and since $class is still undefined we will use the next code below
        $al = $target;
      }
    }
    if (!$class) {
      # search lowest number
      my @ks = keys(%{$aliases{$al}});
      my $first = (sort { $a <=> $b} @ks)[0];
      $target = $aliases{$al}{$first};
      $class  = $fontdb{$target}{'class'};
    }
    # we also need to create font snippets in Font for the aliases!
    generate_font_snippet($fontdest, $al, $class, $target);
    if ($class eq 'Japan') {
      push @jal, "/$al /$target ;";
    } elsif ($class eq 'Korea') {
      push @kal, "/$al /$target ;";
    } elsif ($class eq 'GB') {
      push @sal, "/$al /$target ;";
    } elsif ($class eq 'CNS') {
      push @tal, "/$al /$target ;";
    } else {
      print STDERR "unknown class $class for $al\n";
    }
  }
  $outp .= "\n% Japanese fonts\n" . join("\n", @jal) . "\n" if @jal;
  $outp .= "\n% Korean fonts\n" . join("\n", @kal) . "\n" if @kal;
  $outp .= "\n% Traditional Chinese fonts\n" . join("\n", @tal) . "\n" if @tal;
  $outp .= "\n% Simplified Chinese fonts\n" . join("\n", @sal) . "\n" if @sal;
  #
  return if $dry_run;
  if ($outp && !$opt_remove) {
    if (! -d "$opt_output/Init") {
      mkdir("$opt_output/Init") ||
        die("Cannot create directory $opt_output/Init: $!");
    }
    open(FOO, ">$opt_output/Init/cidfmap.aliases") || 
      die "Cannot open $opt_output/cidfmap.aliases: $!";
    print FOO $outp;
    close(FOO);
  }
  update_master_cidfmap('cidfmap.aliases');
}

sub generate_cidfmap_entry {
  my ($n, $c, $f, $sf) = @_;
  return "" if $opt_remove;
  # $f is already the link target name 'ttfname'
  # as determined by minimal priority number
  # extract subfont
  my $s = "/$n << /FileType /TrueType 
  /Path pssystemparams /GenericResourceDir get 
  (CIDFSubst/$f) concatstrings
  /SubfontID $sf
  /CSI [($c";
  if ($c eq "Japan") {
    $s .= "1) 6]";
  } elsif ($c eq "GB") {
    $s .= "1) 5]";
  } elsif ($c eq "CNS") {
    $s .= "1) 5]";
  } elsif ($c eq "Korea") {
    $s .= "1) 2]";
  } else {
    print_warning("unknown class $c for $n, skipping.\n");
    return '';
  }
  $s .= " >> ;\n";
  return $s;
}

#
# dump found files
sub info_found_fonts {
  print "List of found fonts:\n\n";
  for my $k (keys %fontdb) {
    my @foundfiles;
    if ($fontdb{$k}{'available'}) {
      print "Font:  $k\n";
      print "Type:  $fontdb{$k}{'type'}\n";
      print "Class: $fontdb{$k}{'class'}\n";
      my $fn = $fontdb{$k}{'target'};
      if ($fontdb{$k}{'type'} eq 'TTF' && $fontdb{$k}{'subfont'} > 0) {
        $fn .= "($fontdb{$k}{'subfont'})";
      }
      print "File:  $fn\n";
      if ($fontdb{$k}{'type'} eq 'TTF') {
        print "Link:  $fontdb{$k}{'ttfname'}\n";
      }
      print "\n";
    }
  }
}


#
# make all fonts available for listing all aliases
sub make_all_available {
  for my $k (keys %fontdb) {
    $fontdb{$k}{'available'} = 1;
    delete $fontdb{$k}{'files'};
  }
}

#
# checks all file names listed in %fontdb
# and sets
sub check_for_files {
  my @foundfiles;
  if ($opt_filelist) {
    open(FOO, "<", $opt_filelist) || die "Cannot open $opt_filelist: $!";
    @foundfiles = <FOO>;
    close(FOO) || warn "Cannot close $opt_filelist: $!";
  } else {
    # first collect all files:
    my @fn;
    for my $k (keys %fontdb) {
      for my $f (keys %{$fontdb{$k}{'files'}}) {
        # check for subfont extension 
        if ($f =~ m/^(.*)\(\d*\)$/) {
          push @fn, $1;
        } else {
          push @fn, $f;
        }
      }
    }
    #
    # collect extra directories for search
    my @extradirs;
    if (win32()) {
      push @extradirs, "c:/windows/fonts//";
    } else {
      # other dirs to check, for normal unix?
      for my $d (qw!/Library/Fonts /System/Library/Fonts /Library/Fonts/Microsoft/ /Network/Library/Fonts!) {
        push @extradirs, $d if (-d $d);
      }
      my $home = $ENV{'HOME'};
      push @extradirs, "$home/Library/Fonts" if (-d "$home/Library/Fonts");
    }
    #
    if (@extradirs) {
      # final dummy directory
      push @extradirs, "/this/does/not/really/exists/unless/you/are/stupid";
      # push current value of OSFONTDIR
      push @extradirs, $ENV{'OSFONTDIR'} if $ENV{'OSFONTDIR'};
      # compose OSFONTDIR
      my $osfontdir = join ':', @extradirs;
      $ENV{'OSFONTDIR'} = $osfontdir;
    }
    if ($ENV{'OSFONTDIR'}) {
      print_debug("final setting of OSFONTDIR: $ENV{'OSFONTDIR'}\n");
    }
    # prepare for kpsewhich call, we need to do quoting
    my $cmdl = 'kpsewhich ';
    for my $f (@fn) {
      $cmdl .= " \"$f\" ";
    }
    # shoot up kpsewhich
    print_ddebug("checking for $cmdl\n");
    @foundfiles = `$cmdl`;
  }
  chomp(@foundfiles);
  print_ddebug("Found files @foundfiles\n");
  # map basenames to filenames
  my %bntofn;
  for my $f (@foundfiles) {
    my $bn = basename($f);
    $bntofn{$bn} = $f;
  }
  if ($opt_debug > 0) {
    print_debug("dumping font database before file check:\n");
    print_debug(Data::Dumper::Dumper(\%fontdb));
  }
  if ($opt_debug > 1) {
    print_ddebug("dumping basename to filename list:\n");
    print_ddebug(Data::Dumper::Dumper(\%bntofn));
  }

  # update the %fontdb with the found files
  for my $k (keys %fontdb) {
    $fontdb{$k}{'available'} = 0;
    for my $f (keys %{$fontdb{$k}{'files'}}) {
      # check for subfont extension 
      my $realfile = $f;
      $realfile =~ s/^(.*)\(\d*\)$/$1/;
      if ($bntofn{$realfile}) {
        # we found a representative, make it available
        $fontdb{$k}{'files'}{$f}{'target'} = $bntofn{$realfile};
        $fontdb{$k}{'available'} = 1;
      } else {
        # delete the entry for convenience
        delete $fontdb{$k}{'files'}{$f};
      }
    }
  }
  # second round to determine the winner in case of more targets
  for my $k (keys %fontdb) {
    if ($fontdb{$k}{'available'}) {
      my $mp = 1000000; my $mf; my $mt;
      for my $f (keys %{$fontdb{$k}{'files'}}) {
        if ($fontdb{$k}{'files'}{$f}{'priority'} < $mp) {
          $mp = $fontdb{$k}{'files'}{$f}{'priority'};
          $mf = $f;
          $mt = $fontdb{$k}{'files'}{$f}{'type'};
        }
      }
      # extract subfont if necessary
      my $sf = 0;
      if ($mf =~ m/^(.*)\((\d*)\)$/) { $sf = $2; }
      $fontdb{$k}{'target'} = $fontdb{$k}{'files'}{$mf}{'target'};
      $fontdb{$k}{'type'} = $fontdb{$k}{'files'}{$mf}{'type'};
      $fontdb{$k}{'subfont'} = $sf if ($fontdb{$k}{'type'} eq 'TTF');
    }
    # not needed anymore
    delete $fontdb{$k}{'files'};
  }
  if ($opt_debug > 0) {
    print_debug("dumping font database:\n");
    print_debug(Data::Dumper::Dumper(\%fontdb));
  }
}

sub compute_aliases {
  # go through fontdb to check for provides
  # accumulate all provided fonts in @provides
  for my $k (keys %fontdb) {
    if ($fontdb{$k}{'available'}) {
      for my $p (keys %{$fontdb{$k}{'provides'}}) {
        # do not check alias if the real font is available
        next if $fontdb{$p}{'available'};
        # use the priority as key
        # if priorities are double, this will pick one at chance
        if ($aliases{$p}{$fontdb{$k}{'provides'}{$p}}) {
          print_warning("duplicate provide levels:\n");
          print_warning("  current $p $fontdb{$k}{'provides'}{$p} $aliases{$p}{$fontdb{$k}{'provides'}{$p}}\n");
          print_warning("  ignored $p $fontdb{$k}{'provides'}{$p} $k\n");
        } else {
          $aliases{$p}{$fontdb{$k}{'provides'}{$p}} = $k;
        }
      }
    }
  }
  # check for user supplied aliases
  for my $a (@opt_aliases) {
    if ($a =~ m/^(.*)=(.*)$/) {
      my $ll = $1;
      my $rr = $2;
      # check for consistency of user provided aliases:
      # - ll must not be available
      # - rr needs to be available as font or alias
      # check whether $rr is available, either as real font or as alias
      if ($fontdb{$ll}{'available'}) {
        print_error("left side of alias spec is provided by a real font: $a\n");
        print_error("stopping here\n");
        exit(1);
      }
      if (!($fontdb{$rr}{'available'} || $aliases{$rr})) {
        print_error("right side of alias spec is not available as real font or alias: $a\n");
        print_error("stopping here\n");
        exit(1);
      }
      $user_aliases{$ll} = $rr;
    }
  }
  if ($opt_debug > 0) {
    print_debug("dumping aliases:\n");
    print_debug(Data::Dumper::Dumper(\%aliases));
  }
}

# While the OTF link target is determined by the filename itself
# for TTF we can have ttc with several fonts.
# The following routine determines the link target by selecting
# the file name of the ttf candidates with the lowest priority
# as the link target name for TTF
sub determine_ttf_link_target {
  for my $k (keys %fontdb) {
    my $ttfname;
    my $mp = 10000000;
    for my $f (keys %{$fontdb{$k}{'files'}}) {
      if ($fontdb{$k}{'files'}{$f}{'type'} eq 'TTF') {
        my $p = $fontdb{$k}{'files'}{$f}{'priority'};
        if ($p < $mp) {
          $ttfname = $f;
          $ttfname =~ s/^(.*)\(\d*\)$/$1/;
          $mp = $p;
        }
      }
    }
    if ($ttfname) {
      $fontdb{$k}{'ttfname'} = $ttfname;
    }
  }
}

sub read_font_database {
  my @dbl;
  if ($opt_fontdef) {
    open (FDB, "<$opt_fontdef") ||
      die "Cannot find $opt_fontdef: $!";
    @dbl = <FDB>;
    close(FDB);
  } else {
    @dbl = <DATA>;
  }
  chomp(@dbl);
  # add a "final empty line" to easy parsing
  push @dbl, "";
  my $fontname = "";
  my $fontclass = "";
  my %fontprovides = ();
  my %fontfiles;
  my $psname = "";
  my $lineno = 0;
  for my $l (@dbl) {
    $lineno++;

    next if ($l =~ m/^\s*#/);
    if ($l =~ m/^\s*$/) {
      if ($fontname || $fontclass || keys(%fontfiles)) {
        if ($fontname && $fontclass && keys(%fontfiles)) {
          my $realfontname = ($psname ? $psname : $fontname);
          $fontdb{$realfontname}{'class'} = $fontclass;
          $fontdb{$realfontname}{'files'} = { %fontfiles };
          $fontdb{$realfontname}{'provides'} = { %fontprovides };
          if ($opt_debug > 1) {
            print_ddebug("Dumping fontfiles for $realfontname: " . Data::Dumper::Dumper(\%fontfiles));
          }
          # reset to start
          $fontname = $fontclass = $psname = "";
          %fontfiles = ();
          %fontprovides = ();
        } else {
          print_warning("incomplete entry above line $lineno for $fontname/$fontclass, skipping!\n");
          # reset to start
          $fontname = $fontclass = $psname = "";
          %fontfiles = ();
          %fontprovides = ();
        }
      } else {
        # no term is set, so nothing to warn about
      }
      next;
    }
    if ($l =~ m/^Name:\s*(.*)$/) { $fontname = $1; next; }
    if ($l =~ m/^PSName:\s*(.*)$/) { $psname = $1; next; }
    if ($l =~ m/^Class:\s*(.*)$/) { $fontclass = $1 ; next ; }
    if ($l =~ m/^Filename(\((\d+)\))?:\s*(.*)$/) { 
      my $fn = $3;
      $fontfiles{$fn}{'priority'} = ($2 ? $2 : 10);
      print_ddebug("filename: $fn\n");
      if ($fn =~ m/\.ot[fc]$/i) {
        print_ddebug("type: cid\n");
        $fontfiles{$fn}{'type'} = 'CID';
      } elsif ($fn =~ m/\.tt[fc](\(\d+\))?$/i) {
        print_ddebug("type: ttf\n");
        $fontfiles{$fn}{'type'} = 'TTF';
      } else{
        print_warning("cannot determine font type of $fn at line $lineno, skipping!\n");
        delete $fontfiles{$fn};
      }
      next;
    }
    if ($l =~ m/^Provides\((\d+)\):\s*(.*)$/) { $fontprovides{$2} = $1; next; }
    # we are still here??
    print_error("Cannot parse this file at line $lineno, exiting. Strange line: >>>$l<<<\n");
    exit (1);
  }
}

sub find_gs_resource {
  # we assume that gs is in the path
  # on Windows we probably have to try something else
  my @ret = `gs --help 2>$nul`;
  my $foundres = '';
  if ($?) {
    print_error("Cannot find gs ...\n");
  } else {
    # try to find resource line
    for (@ret) {
      if (m!Resource/Font!) {
        $foundres = $_;
        $foundres =~ s/^\s*//;
        $foundres =~ s/\s*:\s*$//;
        $foundres =~ s!/Font!!;
        last;
      }
    }
    if (!$foundres) {
      print_error("Found gs but no resource???\n");
    }
  }
  return $foundres;
}

sub version {
  my $ret = sprintf "%s version %s\n", $prg, $version;
  return $ret;
}

sub Usage {
  my $headline = "Configuring GhostScript for CJK CID/TTF fonts";
  my $usage = "[perl] $prg\[.pl\] [OPTIONS]";
  my $options = "
-n, --dry-run         do not actually output anything
--remove              try to remove instead of create
-f, --fontdef FILE    specify alternate set of font definitions, if not
                      given, the built-in set is used
-o, --output DIR      specifies the base output dir, if not provided,
                      the Resource directory of an installed GhostScript
                      is searched and used.
-a, --alias LL=RR     defines an alias, or overrides a given alias;
                      illegal if LL is provided by a real font, or
                      RR is neither available as real font or alias;
                      can be given multiple times
--filelist FILE       read list of available font files from FILE
                      instead of searching with kpathsea
--link-texmf [DIR]    link fonts into
                         DIR/fonts/opentype/cjk-gs-integrate
                      and
                         DIR/fonts/truetype/cjk-gs-integrate
                      where DIR defaults to TEXMFLOCAL
--machine-readable    output of --list-aliases is machine readable
--force               do not bail out if linked fonts already exist
-q, --quiet           be less verbose
-d, --debug           output debug information, can be given multiple times
-v, --version         outputs only the version information
-h, --help            this help
";

  my $commandoptions = "
--only-aliases        do only regenerate the cidfmap.alias file instead of all
--list-aliases        lists the available aliases and their options, with the
                      selected option on top
--list-all-aliases    list all possible aliases without searching for actually
                      present files
--list-fonts          lists the fonts found on the system
--info                combines the above two information
";

  my $shortdesc = "
This script searches a list of directories for CJK fonts, and makes
them available to an installed GhostScript. In the simplest case with
sufficient privileges, a run without arguments should effect in a
complete setup of GhostScript.
";

my $operation = "
For each found TrueType (TTF) font it creates a cidfmap entry in

    <Resource>/Init/cidfmap.local

and links the font to

    <Resource>/CIDFSubst/

For each CID font it creates a snippet in

    <Resource>/Font/

and links the font to

    <Resource>/CIDFont/

The `<Resource>` dir is either given by `-o`/`--output`, or otherwise searched
from an installed GhostScript (binary name is assumed to be 'gs').

Aliases are added to 

    <Resource>/Init/cidfmap.aliases

Finally, it tries to add runlib calls to

    <Resource>/Init/cidfmap

to load the cidfmap.local and cidfmap.aliases.
";

  my $dirsearch = '
Search is done using the kpathsea library, in particular using kpsewhich
program. By default the following directories are searched:
  - all TEXMF trees
  - `/Library/Fonts`, `/Library/Fonts/Microsoft`, `/System/Library/Fonts`, 
    `/Network/Library/Fonts`, and `~/Library/Fonts` (all if available)
  - `c:/windows/fonts` (on Windows)
  - the directories in `OSFONTDIR` environment variable

In case you want to add some directories to the search path, adapt the
`OSFONTDIR` environment variable accordingly: Example:

`````
    OSFONTDIR="/usr/local/share/fonts/truetype//:/usr/local/share/fonts/opentype//" $prg
`````

will result in fonts found in the above two given directories to be
searched in addition.
';

  my $outputfile = "
If no output option is given, the program searches for a GhostScript
interpreter 'gs' and determines its Resource directory. This might
fail, in which case one need to pass the output directory manually.

Since the program adds files and link to this directory, sufficient
permissions are necessary.
";

  my $aliases = "
Aliases are managed via the Provides values in the font database.
At the moment entries for the basic font names for CJK fonts
are added:

Japanese:

    Ryumin-Light GothicBBB-Medium FutoMinA101-Bold FutoGoB101-Bold Jun101-Light

Korean:

    HYGoThic-Medium HYSMyeongJo-Medium

Simplified Chinese:

    STSong-Light STHeiti-Regular STHeiti-Light STKaiti-Regular

Traditional Chinese:

    MSung-Light MHei-Medium MKai-Medium

In addition, we also include provide entries for the OTF Morisawa names:
    RyuminPro-Light GothicBBBPro-Medium FutoMinA101Pro-Bold
    FutoGoB101Pro-Bold Jun101Pro-Light

The order is determined by the Provides setting in the font database,
and for the Japanese fonts it is currently:
    Morisawa Pr6, Morisawa, Hiragino ProN, Hiragino, 
    Yu OSX, Yu Win, Kozuka ProN, Kozuka, IPAex, IPA

That is, the first font found in this order will be used to provide the
alias if necessary.

#### Overriding aliases ####

Using the command line option `--alias LL=RR` one can add arbitrary aliases,
or override ones selected by the program. For this to work the following
requirements of `LL` and `RR` must be fulfilled:
  * `LL` is not provided by a real font
  * `RR` is available either as real font, or as alias (indirect alias)
";

  my $authors = "
The script and its documentation was written by Norbert Preining, based
on research and work by Yusuke Kuroki, Bruno Voisin, Munehiro Yamamoto
and the TeX Q&A wiki page.

The script is licensed under GNU General Public License Version 3 or later.
The contained font data is not copyrightable.
";


  if ($opt_markdown) {
    print "$headline\n";
    print ("=" x length($headline));
    print "\n$shortdesc\nUsage\n-----\n\n`````\n$usage\n`````\n\n";
    print "#### Options ####\n\n`````";
    print_for_out($options, "  ");
    print "`````\n\n#### Command like options ####\n\n`````";
    print_for_out($commandoptions, "  ");
    print "`````\n\nOperation\n---------\n$operation\n";
    print "How and which directories are searched\n";
    print "--------------------------------------\n$dirsearch\n";
    print "Output files\n";
    print "------------\n$outputfile\n";
    print "Aliases\n";
    print "-------\n$aliases\n";
    print "Authors, Contributors, and Copyright\n";
    print "------------------------------------\n$authors\n";
  } else {
    print "\nUsage: $usage\n\n$headline\n$shortdesc";
    print "\nOptions:\n";
    print_for_out($options, "  ");
    print "\nCommand like options:\n";
    print_for_out($commandoptions, "  ");
    print "\nOperation:\n";
    print_for_out($operation, "  ");
    print "\nHow and which directories are searched:\n";
    print_for_out($dirsearch, "  ");
    print "\nOutput files:\n";
    print_for_out($outputfile, "  ");
    print "\nAliases:\n";
    print_for_out($aliases, "  ");
    print "\nAuthors, Contributors, and Copyright:\n";
    print_for_out($authors, "  ");
    print "\n";
  }
  exit 0;
}

sub print_for_out {
  my ($what, $indent) = @_;
  for (split /\n/, $what) { 
    next if m/`````/;
    s/\s*####\s*//g;
    if ($_ eq '') {
      print "\n";
    } else {
      print "$indent$_\n";
    }
  }
}

# info/warning can be suppressed
# verbose/error cannot be suppressed
sub print_info {
  print STDOUT "$prg: ", @_ if (!$opt_quiet);
}
sub print_verbose {
  print STDOUT "$prg: ", @_;
}
sub print_warning {
  print STDERR "$prg [WARNING]: ", @_ if (!$opt_quiet) 
}
sub print_error {
  print STDERR "$prg [ERROR]: ", @_;
}
sub print_debug {
  print STDERR "$prg [DEBUG]: ", @_ if ($opt_debug >= 1);
}
sub print_ddebug {
  print STDERR "$prg [DEBUG]: ", @_ if ($opt_debug >= 2);
}


__DATA__
#
# CJK FONT DEFINITIONS
#

# JAPAN

# Morisawa

Name: A-OTF-FutoGoB101Pr6N-Bold
PSName: FutoGoB101Pr6N-Bold
Class: Japan
Provides(10): FutoGoB101-Bold
Provides(10): FutoGoB101Pro-Bold
Filename: A-OTF-FutoGoB101Pr6N-Bold.otf

Name: A-OTF-FutoGoB101Pro-Bold
PSName: FutoGoB101Pro-Bold
Class: Japan
Provides(20): FutoGoB101-Bold
Filename: A-OTF-FutoGoB101Pro-Bold.otf

Name: A-OTF-FutoMinA101Pr6N-Bold
PSName: FutoMinA101Pr6N-Bold
Class: Japan
Provides(10): FutoMinA101-Bold
Provides(10): FutoMinA101Pro-Bold
Filename: A-OTF-FutoMinA101Pr6N-Bold.otf

Name: A-OTF-FutoMinA101Pro-Bold
PSName: FutoMinA101Pro-Bold
Class: Japan
Provides(20): FutoMinA101-Bold
Filename: A-OTF-FutoMinA101Pro-Bold.otf

Name: A-OTF-GothicBBBPr6N-Medium
PSName: GothicBBBPr6N-Medium
Class: Japan
Provides(10): GothicBBB-Medium
Provides(10): GothicBBBPro-Medium
Filename: A-OTF-GothicBBBPr6N-Medium.otf

Name: A-OTF-GothicBBBPro-Medium
PSName: GothicBBBPro-Medium
Class: Japan
Provides(20): GothicBBB-Medium
Filename: A-OTF-GothicBBBPro-Medium.otf

Name: A-OTF-Jun101Pro-Light
PSName: Jun101Pro-Light
Class: Japan
Provides(20): Jun101-Light
Filename: A-OTF-Jun101Pro-Light.otf

Name: A-OTF-MidashiGoPr6N-MB31
PSName: MidashiGoPr6N-MB31
Class: Japan
Provides(10): MidashiGo-MB31
Provides(10): MidashiGoPro-MB31
Filename: A-OTF-MidashiGoPr6N-MB31.otf

Name: A-OTF-MidashiGoPro-MB31
PSName: MidashiGoPro-MB31
Class: Japan
Provides(20): MidashiGo-MB31
Filename: A-OTF-MidashiGoPro-MB31.otf

Name: A-OTF-RyuminPr6N-Light
PSName: RyuminPr6N-Light
Class: Japan
Provides(10): Ryumin-Light
Provides(10): RyuminPro-Light
Filename: A-OTF-RyuminPr6N-Light.otf

Name: A-OTF-RyuminPro-Light
PSName: RyuminPro-Light
Class: Japan
Provides(20): Ryumin-Light
Filename: A-OTF-RyuminPro-Light.otf

Name: A-OTF-ShinMGoPr6N-Light
PSName: ShinMGoPr6N-Light
Class: Japan
Provides(10): Jun101-Light
Provides(10): Jun101Pro-Light
Filename: A-OTF-ShinMGoPr6N-Light.otf


# Hiragino

Name: HiraKakuPro-W3
Class: Japan
Provides(40): GothicBBB-Medium
Provides(40): GothicBBBPro-Medium
# the following two are *not* the same
# one is in decomposed form (for Mac), one is in composed form (for the rest)
Filename(20): ヒラギノ角ゴ Pro W3.otf
Filename(19): ヒラギノ角ゴ Pro W3.otf
Filename(10): HiraKakuPro-W3.otf
Filename(30): ヒラギノ角ゴシック W3.ttc(3)
Filename(29): ヒラギノ角ゴシック W3.ttc(3)
Filename(28): HiraginoSans-W3.ttc(3)

Name: HiraKakuPro-W6
Class: Japan
Provides(40): FutoGoB101-Bold
Provides(40): FutoGoB101Pro-Bold
Filename(20): ヒラギノ角ゴ Pro W6.otf
Filename(19): ヒラギノ角ゴ Pro W6.otf
Filename(10): HiraKakuPro-W6.otf
Filename(30): ヒラギノ角ゴシック W6.ttc(3)
Filename(29): ヒラギノ角ゴシック W6.ttc(3)
Filename(28): HiraginoSans-W6.ttc(3)

Name: HiraKakuProN-W3
Class: Japan
Provides(30): GothicBBB-Medium
Provides(30): GothicBBBPro-Medium
Filename(20): ヒラギノ角ゴ ProN W3.otf
Filename(19): ヒラギノ角ゴ ProN W3.otf
Filename(10): HiraKakuProN-W3.otf
Filename(30): ヒラギノ角ゴシック W3.ttc(2)
Filename(29): ヒラギノ角ゴシック W3.ttc(2)
Filename(28): HiraginoSans-W3.ttc(2)

Name: HiraKakuProN-W6
Class: Japan
Provides(30): FutoGoB101-Bold
Provides(30): FutoGoB101Pro-Bold
Filename(20): ヒラギノ角ゴ ProN W6.otf
Filename(19): ヒラギノ角ゴ ProN W6.otf
Filename(10): HiraKakuProN-W6.otf
Filename(30): ヒラギノ角ゴシック W6.ttc(2)
Filename(29): ヒラギノ角ゴシック W6.ttc(2)
Filename(28): HiraginoSans-W6.ttc(2)

Name: HiraKakuStd-W8
Class: Japan
Provides(40): MidashiGo-MB31
Provides(40): MidashiGoPro-MB31
Filename(20): ヒラギノ角ゴ Std W8.otf
Filename(19): ヒラギノ角ゴ Std W8.otf
Filename(10): HiraKakuStd-W8.otf
Filename(30): ヒラギノ角ゴシック W8.ttc(2)
Filename(29): ヒラギノ角ゴシック W8.ttc(2)
Filename(28): HiraginoSans-W8.ttc(2)

Name: HiraKakuStdN-W8
Class: Japan
Provides(30): MidashiGo-MB31
Provides(30): MidashiGoPro-MB31
Filename(20): ヒラギノ角ゴ StdN W8.otf
Filename(19): ヒラギノ角ゴ StdN W8.otf
Filename(10): HiraKakuStdN-W8.otf
Filename(30): ヒラギノ角ゴシック W8.ttc(3)
Filename(29): ヒラギノ角ゴシック W8.ttc(3)
Filename(28): HiraginoSans-W8.ttc(3)

Name: HiraginoSans-W0
Class: Japan
Provides(30): HiraginoSans-W0
Filename(30): ヒラギノ角ゴシック W0.ttc(0)
Filename(29): ヒラギノ角ゴシック W0.ttc(0)
Filename(28): HiraginoSans-W0.ttc(0)

Name: HiraginoSans-W1
Class: Japan
Provides(30): HiraginoSans-W1
Filename(30): ヒラギノ角ゴシック W1.ttc(0)
Filename(29): ヒラギノ角ゴシック W1.ttc(0)
Filename(28): HiraginoSans-W1.ttc(0)

Name: HiraginoSans-W2
Class: Japan
Provides(30): HiraginoSans-W2
Filename(30): ヒラギノ角ゴシック W2.ttc(0)
Filename(29): ヒラギノ角ゴシック W2.ttc(0)
Filename(28): HiraginoSans-W2.ttc(0)

Name: HiraginoSans-W3
Class: Japan
Provides(30): HiraginoSans-W3
Filename(30): ヒラギノ角ゴシック W3.ttc(0)
Filename(29): ヒラギノ角ゴシック W3.ttc(0)
Filename(28): HiraginoSans-W3.ttc(0)

Name: HiraginoSans-W4
Class: Japan
Provides(30): HiraginoSans-W4
Filename(30): ヒラギノ角ゴシック W4.ttc(0)
Filename(29): ヒラギノ角ゴシック W4.ttc(0)
Filename(28): HiraginoSans-W4.ttc(0)

Name: HiraginoSans-W5
Class: Japan
Provides(30): HiraginoSans-W5
Filename(30): ヒラギノ角ゴシック W5.ttc(0)
Filename(29): ヒラギノ角ゴシック W5.ttc(0)
Filename(28): HiraginoSans-W5.ttc(0)

Name: HiraginoSans-W6
Class: Japan
Provides(30): HiraginoSans-W6
Filename(30): ヒラギノ角ゴシック W6.ttc(0)
Filename(29): ヒラギノ角ゴシック W6.ttc(0)
Filename(28): HiraginoSans-W6.ttc(0)

Name: HiraginoSans-W7
Class: Japan
Provides(30): HiraginoSans-W7
Filename(30): ヒラギノ角ゴシック W7.ttc(0)
Filename(29): ヒラギノ角ゴシック W7.ttc(0)
Filename(28): HiraginoSans-W7.ttc(0)

Name: HiraginoSans-W8
Class: Japan
Provides(30): HiraginoSans-W8
Filename(30): ヒラギノ角ゴシック W8.ttc(0)
Filename(29): ヒラギノ角ゴシック W8.ttc(0)
Filename(28): HiraginoSans-W8.ttc(0)

Name: HiraginoSans-W9
Class: Japan
Provides(30): HiraginoSans-W9
Filename(30): ヒラギノ角ゴシック W9.ttc(0)
Filename(29): ヒラギノ角ゴシック W9.ttc(0)
Filename(28): HiraginoSans-W9.ttc(0)

Name: HiraMaruPro-W4
Class: Japan
Provides(40): Jun101-Light
Provides(40): Jun101Pro-Light
Filename(20): ヒラギノ丸ゴ Pro W4.otf
Filename(19): ヒラギノ丸ゴ Pro W4.otf
Filename(10): HiraMaruPro-W4.otf
Filename(30): ヒラギノ丸ゴ ProN W4.ttc(0)
Filename(29): ヒラギノ丸ゴ ProN W4.ttc(0)
Filename(28): HiraginoSansR-W4.ttc(0)

Name: HiraMaruProN-W4
Class: Japan
Provides(30): Jun101-Light
Provides(30): Jun101Pro-Light
Filename(20): ヒラギノ丸ゴ ProN W4.otf
Filename(19): ヒラギノ丸ゴ ProN W4.otf
Filename(10): HiraMaruProN-W4.otf
Filename(30): ヒラギノ丸ゴ ProN W4.ttc(1)
Filename(29): ヒラギノ丸ゴ ProN W4.ttc(1)
Filename(28): HiraginoSansR-W4.ttc(1)

Name: HiraMinPro-W3
Class: Japan
Provides(40): Ryumin-Light
Provides(40): RyuminPro-Light
Filename(20): ヒラギノ明朝 Pro W3.otf
Filename(19): ヒラギノ明朝 Pro W3.otf
Filename(10): HiraMinPro-W3.otf
Filename(30): ヒラギノ明朝 ProN W3.ttc(1)
Filename(29): ヒラギノ明朝 ProN W3.ttc(1)
Filename(28): HiraginoSerif-W3.ttc(1)

Name: HiraMinPro-W6
Class: Japan
Provides(40): FutoMinA101-Bold
Provides(40): FutoMinA101Pro-Bold
Filename(20): ヒラギノ明朝 Pro W6.otf
Filename(19): ヒラギノ明朝 Pro W6.otf
Filename(10): HiraMinPro-W6.otf
Filename(30): ヒラギノ明朝 ProN W6.ttc(1)
Filename(29): ヒラギノ明朝 ProN W6.ttc(1)
Filename(28): HiraginoSerif-W6.ttc(1)

Name: HiraMinProN-W3
Class: Japan
Provides(30): Ryumin-Light
Provides(30): RyuminPro-Light
Filename(20): ヒラギノ明朝 ProN W3.otf
Filename(19): ヒラギノ明朝 ProN W3.otf
Filename(10): HiraMinProN-W3.otf
Filename(30): ヒラギノ明朝 ProN W3.ttc(0)
Filename(29): ヒラギノ明朝 ProN W3.ttc(0)
Filename(28): HiraginoSerif-W3.ttc(0)


Name: HiraMinProN-W6
Class: Japan
Provides(30): FutoMinA101-Bold
Provides(30): FutoMinA101Pro-Bold
Filename(20): ヒラギノ明朝 ProN W6.otf
Filename(19): ヒラギノ明朝 ProN W6.otf
Filename(10): HiraMinProN-W6.otf
Filename(30): ヒラギノ明朝 ProN W6.ttc(0)
Filename(29): ヒラギノ明朝 ProN W6.ttc(0)
Filename(28): HiraginoSerif-W6.ttc(0)


Name: HiraginoSansGB-W3
Class: GB
Filename(20): Hiragino Sans GB W3.otf
Filename(10): HiraginoSansGB-W3.otf
Filename(30): Hiragino Sans GB W3.ttc(0)

Name: HiraginoSansGB-W6
Class: GB
Filename(20): Hiragino Sans GB W6.otf
Filename(10): HiraginoSansGB-W6.otf
Filename(30): Hiragino Sans GB W6.ttc(0)


# Yu-fonts MacOS version

Name: YuGo-Medium
Class: Japan
Provides(50): GothicBBB-Medium
Provides(50): GothicBBBPro-Medium
Filename(20): Yu Gothic Medium.otf
Filename(10): YuGo-Medium.otf

Name: YuGo-Bold
Class: Japan
Provides(50): FutoGoB101-Bold
Provides(50): FutoGoB101Pro-Bold
Provides(50): Jun101-Light
Provides(50): Jun101Pro-Light
Provides(50): MidashiGo-MB31
Provides(50): MidashiGoPro-MB31
Filename(20): Yu Gothic Bold.otf
Filename(10): YuGo-Bold.otf

Name: YuMin-Medium
Class: Japan
Provides(50): Ryumin-Light
Provides(50): RyuminPro-Light
Filename(20): Yu Mincho Medium.otf
Filename(10): YuMin-Medium.otf
Filename(30): YuMincho.ttc(0)

Name: YuMin-Demibold
Class: Japan
Provides(50): FutoMinA101-Bold
Provides(50): FutoMinA101Pro-Bold
Filename(20): Yu Mincho Demibold.otf
Filename(10): YuMin-Demibold.otf
Filename(30): YuMincho.ttc(1)

Name: YuMin_36pKn-Medium
Class: Japan
Filename(30): YuMincho.ttc(2)

Name: YuMin_36pKn-Demibold
Class: Japan
Filename(30): YuMincho.ttc(3)

# Yu-fonts Windows version

Name: YuMincho-Regular
Class: Japan
Provides(60): Ryumin-Light
Provides(60): RyuminPro-Light
Filename(20): yumin.ttf
Filename(10): YuMincho-Regular.ttf

Name: YuMincho-Light
Class: Japan
Filename(20): yuminl.ttf
Filename(10): YuMincho-Light.ttf

Name: YuMincho-DemiBold
Class: Japan
Provides(60): FutoMinA101-Bold
Provides(60): FutoMinA101Pro-Bold
Filename(20): yumindb.ttf
Filename(10): YuMincho-DemiBold.ttf

Name: YuGothic-Regular
Class: Japan
Provides(60): GothicBBB-Medium
Provides(60): GothicBBBPro-Medium
Filename(20): yugothic.ttf
Filename(10): YuGothic-Regular.ttf

Name: YuGothic-Light
Class: Japan
Filename(20): yugothil.ttf
Filename(10): YuGothic-Light.ttf

Name: YuGothic-Bold
Class: Japan
Provides(60): FutoGoB101-Bold
Provides(60): FutoGoB101Pro-Bold
Provides(60): Jun101-Light
Provides(60): Jun101Pro-Light
Provides(60): MidashiGo-MB31
Provides(60): MidashiGoPro-MB31
Filename(20): yugothib.ttf
Filename(10): YuGothic-Bold.ttf

# IPA fonts

Name: IPAMincho
Class: Japan
Provides(110): Ryumin-Light
Provides(110): RyuminPro-Light
Provides(110): FutoMinA101-Bold
Provides(110): FutoMinA101Pro-Bold
Filename(20): ipam.ttf
Filename(10): IPAMincho.ttf

Name: IPAGothic
Class: Japan
Provides(110): GothicBBB-Medium
Provides(110): GothicBBBPro-Medium
Provides(110): FutoGoB101-Bold
Provides(110): FutoGoB101Pro-Bold
Provides(110): Jun101-Light
Provides(110): Jun101Pro-Light
Provides(110): MidashiGo-MB31
Provides(110): MidashiGoPro-MB31
Filename(20): ipag.ttf
Filename(10): IPAGothic.ttf

Name: IPAexMincho
Class: Japan
Provides(100): Ryumin-Light
Provides(100): RyuminPro-Light
Provides(100): FutoMinA101-Bold
Provides(100): FutoMinA101Pro-Bold
Filename(20): ipaexm.ttf
Filename(10): IPAexMincho.ttf

Name: IPAexGothic
Class: Japan
Provides(100): GothicBBB-Medium
Provides(100): GothicBBBPro-Medium
Provides(100): FutoGoB101-Bold
Provides(100): FutoGoB101Pro-Bold
Provides(100): Jun101-Light
Provides(100): Jun101Pro-Light
Provides(100): MidashiGo-MB31
Provides(100): MidashiGoPro-MB31
Filename(20): ipaexg.ttf
Filename(10): IPAexGothic.ttf

# Kozuka fonts

Name: KozGoPr6N-Bold
Class: Japan
Provides(70): FutoGoB101-Bold
Provides(70): FutoGoB101Pro-Bold
Filename: KozGoPr6N-Bold.otf

Name: KozGoPr6N-Heavy
Class: Japan
Provides(70): Jun101-Light
Provides(70): Jun101Pro-Light
Provides(70): MidashiGo-MB31
Provides(70): MidashiGoPro-MB31
Filename: KozGoPr6N-Heavy.otf

Name: KozGoPr6N-Medium
Class: Japan
Provides(70): GothicBBB-Medium
Provides(70): GothicBBBPro-Medium
Filename: KozGoPr6N-Medium.otf

Name: KozGoPr6N-Regular
Class: Japan
Filename: KozGoPr6N-Regular.otf

Name: KozGoPr6N-ExtraLight
Class: Japan
Filename: KozGoPr6N-ExtraLight.otf

Name: KozGoPr6N-Light
Class: Japan
Filename: KozGoPr6N-Light.otf

Name: KozGoPro-ExtraLight
Class: Japan
Filename: KozGoPro-ExtraLight.otf

Name: KozGoPro-Light
Class: Japan
Filename: KozGoPro-Light.otf


Name: KozGoPro-Bold
Class: Japan
Provides(90): FutoGoB101-Bold
Provides(90): FutoGoB101Pro-Bold
Filename: KozGoPro-Bold.otf

Name: KozGoPro-Heavy
Class: Japan
Provides(90): Jun101-Light
Provides(90): Jun101Pro-Light
Provides(90): MidashiGo-MB31
Provides(90): MidashiGoPro-MB31
Filename: KozGoPro-Heavy.otf

Name: KozGoPro-Medium
Class: Japan
Provides(90): GothicBBB-Medium
Provides(90): GothicBBBPro-Medium
Filename: KozGoPro-Medium.otf

Name: KozGoPro-Regular
Class: Japan
Filename: KozGoPro-Regular.otf

Name: KozGoProVI-Bold
Class: Japan
Provides(80): FutoGoB101-Bold
Provides(80): FutoGoB101Pro-Bold
Filename: KozGoProVI-Bold.otf

Name: KozGoProVI-Heavy
Class: Japan
Provides(80): Jun101-Light
Provides(80): Jun101Pro-Light
Provides(80): MidashiGo-MB31
Provides(80): MidashiGoPro-MB31
Filename: KozGoProVI-Heavy.otf

Name: KozGoProVI-Medium
Class: Japan
Provides(80): GothicBBB-Medium
Provides(80): GothicBBBPro-Medium
Filename: KozGoProVI-Medium.otf

Name: KozGoProVI-Regular
Class: Japan
Filename: KozGoProVI-Regular.otf

Name: KozMinPr6N-Bold
Class: Japan
Provides(70): FutoMinA101-Bold
Provides(70): FutoMinA101Pro-Bold
Filename: KozMinPr6N-Bold.otf

Name: KozMinPr6N-Light
Class: Japan
Filename: KozMinPr6N-Light.otf

Name: KozMinPr6N-Regular
Class: Japan
Provides(70): Ryumin-Light
Provides(70): RyuminPro-Light
Filename: KozMinPr6N-Regular.otf

Name: KozMinPro-Bold
Class: Japan
Provides(90): FutoMinA101-Bold
Provides(90): FutoMinA101Pro-Bold
Filename: KozMinPro-Bold.otf

Name: KozMinPro-Light
Class: Japan
Filename: KozMinPro-Light.otf

Name: KozMinPro-Regular
Class: Japan
Provides(90): Ryumin-Light
Provides(90): RyuminPro-Light
Filename: KozMinPro-Regular.otf

Name: KozMinProVI-Bold
Class: Japan
Provides(80): FutoMinA101-Bold
Provides(80): FutoMinA101Pro-Bold
Filename: KozMinProVI-Bold.otf

Name: KozMinProVI-Light
Class: Japan
Filename: KozMinProVI-Light.otf

Name: KozMinProVI-Regular
Class: Japan
Provides(80): Ryumin-Light
Provides(80): RyuminPro-Light
Filename: KozMinProVI-Regular.otf

Name: KozMinPr6N-ExtraLight
Class: Japan
Filename: KozMinPr6N-ExtraLight.otf

Name: KozMinPr6N-Medium
Class: Japan
Filename: KozMinPr6N-Medium.otf

Name: KozMinPr6N-Heavy
Class: Japan
Filename: KozMinPr6N-Heavy.otf

Name: KozMinPro-ExtraLight
Class: Japan
Filename: KozMinPro-ExtraLight.otf

Name: KozMinPro-Medium
Class: Japan
Filename: KozMinPro-Medium.otf

Name: KozMinPro-Heavy
Class: Japan
Filename: KozMinPro-Heavy.otf

#
# other OSX 11 fonts

# TODO TODO should they provide Maru Gothic ???
Name: TsukuARdGothic-Regular
Class: Japan
Filename: TsukushiAMaruGothic.ttc(0)

Name: TsukuARdGothic-Bold
Class: Japan
Filename: TsukushiAMaruGothic.ttc(1)

Name: TsukuBRdGothic-Regular
Class: Japan
Filename: TsukushiBMaruGothic.ttc(0)

Name: TsukuBRdGothic-Bold
Class: Japan
Filename: TsukushiBMaruGothic.ttc(1)

Name: Klee-Medium
Class: Japan
Filename: Klee.ttc(1)

Name: Klee-Demibold
Class: Japan
Filename: Klee.ttc(0)

#
# CHINESE FONTS
#

Name: LiHeiPro
Class: CNS
Provides(50): MHei-Medium
Filename(20): 儷黑 Pro.ttf
Filename(10): LiHeiPro.ttf

Name: LiSongPro
Class: CNS
Provides(50): MSung-Medium
Provides(50): MSung-Light
Filename(20): 儷宋 Pro.ttf
Filename(10): LiSongPro.ttf

Name: STXihei
Class: GB
Provides(20): STHeiti-Light
Filename(20): 华文细黑.ttf
Filename(10): STXihei.ttf

Name: STHeiti
Class: GB
Provides(50): STHeiti-Regular
Filename(20): 华文黑体.ttf
Filename(10): STHeiti.ttf

Name: STHeitiSC-Light
Class: GB
Provides(10): STHeiti-Light
Filename(10): STHeiti Light.ttc(1)
Filename(20): STHeitiSC-Light.ttf

Name: STHeitiSC-Medium
Class: GB
Provides(40): STHeiti-Regular
Filename(10): STHeiti Medium.ttc(1)
Filename(20): STHeitiSC-Medium.ttf

Name: STHeitiTC-Light
Class: CNS
Filename(10): STHeiti Light.ttc(0)
Filename(20): STHeitiTC-Light.ttf

Name: STHeitiTC-Medium
Class: CNS
Provides(40): MHei-Medium
Filename(10): STHeiti Medium.ttc(0)
Filename(20): STHeitiTC-Medium.ttf

Name: STFangsong
Class: GB
Provides(40): STFangsong-Light
Provides(40): STFangsong-Regular
Filename(20): 华文仿宋.ttf
Filename(10): STFangsong.ttf

Name: STSong
Class: GB
Provides(50): STSong-Light
Filename(10): Songti.ttc(4)
Filename(20): 宋体.ttc(3)
Filename(30): 华文宋体.ttf
Filename(40): STSong.ttf

Name: STSongti-SC-Light
Class: GB
Provides(40): STSong-Light
Filename(10): Songti.ttc(3)
Filename(20): 宋体.ttc(2)
Filename(30): STSongti-SC-Light.ttf

Name: STSongti-SC-Regular
Class: GB
Filename(10): Songti.ttc(6)
Filename(20): 宋体.ttc(4)
Filename(30): STSongti-SC-Regular.ttf

Name: STSongti-SC-Bold
Class: GB
Filename(10): Songti.ttc(1)
Filename(20): 宋体.ttc(1)
Filename(30): STSongti-SC-Bold.ttf

Name: STSongti-SC-Black
Class: GB
Filename(10): Songti.ttc(0)
Filename(20): 宋体.ttc(0)
Filename(30): STSongti-SC-Black.ttf

Name: STSongti-TC-Light
Class: CNS
Provides(40): MSung-Light
Filename(10): Songti.ttc(5)
Filename(20): STSongti-TC-Light.ttf

Name: STSongti-TC-Regular
Class: CNS
Provides(40): MSung-Medium
Filename(10): Songti.ttc(7)
Filename(20): STSongti-TC-Regular.ttf

Name: STSongti-TC-Bold
Class: CNS
Filename(10): Songti.ttc(2)
Filename(20): STSongti-TC-Bold.ttf

Name: STKaiti
Class: GB
Provides(50): STKaiti-Regular
Filename(10): Kaiti.ttc(4)
Filename(20): 楷体.ttc(3)
Filename(30): 华文楷体.ttf
Filename(40): STKaiti.ttf

Name: STKaiti-SC-Regular
Class: GB
Provides(40): STKaiti-Regular
Filename(10): Kaiti.ttc(3)
Filename(20): 楷体.ttc(2)
Filename(30): STKaiti-SC-Regular.ttf

Name: STKaiti-SC-Bold
Class: GB
Filename(10): Kaiti.ttc(1)
Filename(20): 楷体.ttc(1)
Filename(30): STKaiti-SC-Bold.ttf

Name: STKaiti-SC-Black
Class: GB
Filename(10): Kaiti.ttc(0)
Filename(20): 楷体.ttc(0)
Filename(30): STKaiti-SC-Black.ttf

Name: STKaiTi-TC-Regular
Class: CNS
Provides(40): MKai-Medium
Filename(10): Kaiti.ttc(5)
Filename(20): STKaiTi-TC-Regular.ttf

Name: STKaiTi-TC-Bold
Class: CNS
Filename(10): Kaiti.ttc(2)
Filename(20): STKaiTi-TC-Bold.ttf

Name: STKaiti-Adobe-CNS1
Class: CNS
Provides(50): MKai-Medium
Filename(10): Kaiti.ttc(4)
Filename(20): 楷体.ttc(3)
Filename(30): 华文楷体.ttf
Filename(40): STKaiti.ttf

# Adobe fonts

# simplified chinese

Name: AdobeSongStd-Light
Class: GB
Provides(30): STSong-Light
Filename(10): AdobeSongStd-Light.otf

Name: AdobeHeitiStd-Regular
Class: GB
Provides(30): STHeiti-Regular
Provides(30): STHeiti-Light
Filename(20): AdobeHeitiStd-Regular.otf

Name: AdobeKaitiStd-Regular
Class: GB
Provides(30): STKaiti-Regular
Filename(20): AdobeKaitiStd-Regular.otf

Name: AdobeFangsongStd-Regular
Class: GB
Provides(30): STFangsong-Light
Provides(30): STFangsong-Regular
Filename(20): AdobeFangsongStd-Regular.otf

# traditional chinese

Name: AdobeMingStd-Light
Class: CNS
Provides(30): MSung-Light
Provides(30): MSung-Medium
Filename(20): AdobeMingStd-Light.otf

Name: AdobeFanHeitiStd-Bold
Class: CNS
Provides(30): MHei-Medium
Provides(30): MKai-Medium
Filename(20): AdobeFanHeitiStd-Bold.otf

# korean

Name: AdobeMyungjoStd-Medium
Class: Korea
Provides(20): HYSMyeongJo-Medium
Filename: AdobeMyungjoStd-Medium.otf

Name: AdobeGothicStd-Bold
Class: Korea
Provides(20): HYGoThic-Medium
Provides(50): HYRGoThic-Medium
Filename: AdobeGothicStd-Bold.otf

#
# KOREAN FONTS
#

# apple fonts

Name: AppleMyungjo
Class: Korea
Provides(50): HYSMyeongJo-Medium
Filename: AppleMyungjo.ttf

Name: AppleGothic
Class: Korea
Provides(50): HYGoThic-Medium
Provides(80): HYRGoThic-Medium
Filename: AppleGothic.ttf

Name: NanumMyeongjo
Class: Korea
Provides(30): HYSMyeongJo-Medium
Filename: NanumMyeongjo.ttc(0)

Name: NanumMyeongjoBold
Class: Korea
Filename: NanumMyeongjo.ttc(1)

Name: NanumMyeongjoExtraBold
Class: Korea
Filename: NanumMyeongjo.ttc(2)

Name: NanumGothic
Class: Korea
Provides(30): HYGoThic-Medium
Provides(60): HYRGoThic-Medium
Filename: NanumGothic.ttc(0)

Name: NanumGothicBold
Class: Korea
Filename: NanumGothic.ttc(1)

Name: NanumGothicExtraBold
Class: Korea
Filename: NanumGothic.ttc(2)

Name: NanumBrush
Class: Korea
Filename: NanumScript.ttc(0)

Name: NanumPen
Class: Korea
Filename: NanumScript.ttc(1)

Name: AppleSDGothicNeo-Thin
Class: Korea
Filename: AppleSDGothicNeo-Thin.otf

Name: AppleSDGothicNeo-UltraLight
Class: Korea
Filename: AppleSDGothicNeo-UltraLight.otf

Name: AppleSDGothicNeo-Light
Class: Korea
Filename: AppleSDGothicNeo-Light.otf

Name: AppleSDGothicNeo-Regular
Class: Korea
Filename: AppleSDGothicNeo-Regular.otf

Name: AppleSDGothicNeo-Medium
Class: Korea
Filename: AppleSDGothicNeo-Medium.otf

Name: AppleSDGothicNeo-SemiBold
Class: Korea
Filename: AppleSDGothicNeo-SemiBold.otf

Name: AppleSDGothicNeo-Bold
Class: Korea
Filename: AppleSDGothicNeo-Bold.otf

Name: AppleSDGothicNeo-ExtraBold
Class: Korea
Filename: AppleSDGothicNeo-ExtraBold.otf

Name: AppleSDGothicNeo-Heavy
Class: Korea
Filename: AppleSDGothicNeo-Heavy.otf

#
# Microsoft Mac Office fonts
#

# Korea

Name: Gulim
Class: Korea
Provides(70): HYRGoThic-Medium
Provides(70): HYGoThic-Medium
Filename(30): Gulim.ttf
Filename(50): gulim.ttc

Name: Dotum
Class: Korea
Provides(40): HYGoThic-Medium
Filename(50): Dotum.ttf

Name: Batang
Class: Korea
Provides(40): HYSMyeongJo-Medium
Filename(50): Batang.ttf

# simplified chinese

Name: SimHei
Class: GB
Provides(60): STHeiti-Regular
Provides(60): STKaiti-Regular
Provides(60): STHeiti-Light
Filename(50): SimHei.ttf

Name: SimSun
Class: GB
Provides(60): STSong-Light
Provides(60): STFangsong-Light
Provides(60): STFangsong-Regular
Filename(50): SimSun.ttf

# traditional chinese

Name: MingLiU
Class: CNS
Provides(60): MHei-Medium
Provides(60): MKai-Medium
Provides(60): MSung-Medium
Provides(60): MSung-Light
Filename(50): MingLiU.ttf

Name: PMingLiU
Class: CNS
Filename(50): PMingLiU.ttf

# japanese

Name: MS-Gothic
Class: Japan
Provides(95): GothicBBB-Medium
Provides(95): GothicBBBPro-Medium
Provides(95): MidashiGo-MB31
Provides(95): MidashiGoPro-MB31
Provides(95): FutoGoB101-Bold
Provides(95): FutoGoB101Pro-Bold
Provides(95): MidashiGo-MB31
Provides(95): MidashiGoPro-MB31
Provides(95): Jun101-Light
Provides(95): Jun101Pro-Light
Filename(50): MS Gothic.ttf
Filename(30): MS-Gothic.ttf

Name: MS-Mincho
Class: Japan
Provides(95): Ryumin-Light
Provides(95): RyuminPro-Light
Provides(95): FutoMinA101-Bold
Provides(95): FutoMinA101Pro-Bold
Filename(50): MS Mincho.ttf
Filename(30): MS-Mincho.ttf

Name: MS-PGothic
Class: Japan
Filename(50): MS PGothic.ttf
Filename(30): MS-PGothic.ttf

Name: MS-PMincho
Class: Japan
Filename(50): MS PMincho.ttf
Filename(30): MS-PMincho.ttf

Name: Meiryo
Class: Japan
Filename(50): Meiryo.ttf

Name: Meiryo-Bold
Class: Japan
Filename(50): Meiryo Bold.ttf
Filename(30): Meiryo-Bold.ttf

Name: Meiryo-BoldItalic
Class: Japan
Filename(50): Meiryo Bold Italic.ttf
Filename(30): Meiryo-BoldItalic.ttf

Name: Meiryo-Italic
Class: Japan
Filename(50): Meiryo Italic.ttf
Filename(30): Meiryo-Italic.ttf


### Local Variables:
### perl-indent-level: 2
### tab-width: 2
### indent-tabs-mode: nil
### End:
# vim: set tabstop=2 expandtab autoindent:
