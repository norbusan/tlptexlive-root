# $Id: TLConfFile.pm 21770 2011-03-20 18:34:02Z karl $
# TeXLive::TLConfFile.pm - reading and writing conf files
# Copyright 2010, 2011 Norbert Preining
# This file is licensed under the GNU General Public License version 2
# or any later version.

package TeXLive::TLConfFile;

use TeXLive::TLUtils;
use File::Temp qw/tempfile/;

my $svnrev = '$Revision: 21770 $';
my $_modulerevision;
if ($svnrev =~ m/: ([0-9]+) /) {
  $_modulerevision = $1;
} else {
  $_modulerevision = "unknown";
}
sub module_revision {
  return $_modulerevision;
}

sub new
{
  my $class = shift;
  my ($fn, $cc, $sep) = @_;
  my $self = {} ;
  $self{'file'} = $fn;
  $self{'cc'} = $cc;
  $self{'sep'} = $sep;
  bless $self, $class;
  return $self->reparse;
}

sub reparse
{
  my $self = shift;
  my %config = parse_config_file($self->file, $self->cc, $self->sep);
  my $lastkey = undef;
  $self{'keyvalue'} = ();
  $self{'confdata'} = \%config;
  $self{'changed'} = 0;
  my $in_postcomment = 0;
  for my $i (0..$config{'lines'}) {
    if ($config{$i}{'type'} eq 'comment') {
      $lastkey = undef;
      $is_postcomment = 0;
    } elsif ($config{$i}{'type'} eq 'data') {
      $lastkey = $config{$i}{'key'};
      $self{'keyvalue'}{$lastkey}{'value'} = $config{$i}{'value'};
      $self{'keyvalue'}{$lastkey}{'line'}  = $i;
      $self{'keyvalue'}{$lastkey}{'status'} = 'unchanged';
      if (defined($config{$i}{'postcomment'})) {
        $in_postcomment = 1;
      } else {
        $in_postcomment = 0;
      }
    } elsif ($config{$i}{'type'} eq 'empty') {
      $lastkey = undef;
      $is_postcomment = 0;
    } elsif ($config{$i}{'type'} eq 'continuation') {
      if (defined($lastkey)) {
        if (!$in_postcomment) {
          $self{'keyvalue'}{$lastkey}{'value'} .= $config{$i}{'value'};
        }
      }
      # otherwise we are in a continuation of a comment!!! so nothing to do
    } else {
      print "-- UNKNOWN TYPE\n";
    }
  }
  return $self;
}

sub file
{
  my $self = shift;
  return($self{'file'});
}
sub cc
{
  my $self = shift;
  return($self{'cc'});
}
sub sep
{
  my $self = shift;
  return($self{'sep'});
}

sub key_present
{
  my ($self, $key) = @_;
  return defined($self{'keyvalue'}{$key});
}

sub keys
{
  my $self = shift;
  return keys(%{$self{'keyvalue'}});
}

sub value
{
  my ($self, $key, $value) = @_;
  if (defined($value)) {
    if (defined($self{'keyvalue'}{$key})) {
      if ($self{'keyvalue'}{$key}{'value'} ne $value) {
        $self{'keyvalue'}{$key}{'value'} = $value;
        # as long as the key/value pair is not new, we set its status to changed
        if ($self{'keyvalue'}{$key}{'status'} ne 'new') {
          $self{'keyvalue'}{$key}{'status'} = 'changed';
        }
        $self{'changed'} = 1;
      }
    } else {
      $self{'keyvalue'}{$key}{'value'} = $value;
      $self{'keyvalue'}{$key}{'status'} = 'new';
      $self{'changed'} = 1;
    }
  }
  if (defined($self{'keyvalue'}{$key})) {
    return $self{'keyvalue'}{$key}{'value'};
  }
  return;
}

sub delete_key
{
  my ($self, $key) = @_;
  %config = %{$self{'confdata'}};
  if (defined($self{'keyvalue'}{$key})) {
    $self{'keyvalue'}{$key}{'status'} = 'deleted';
    $self{'changed'} = 1;
  }
}

sub rename_key
{
  my ($self, $oldkey, $newkey) = @_;
  %config = %{$self{'confdata'}};
  for my $i (0..$config{'lines'}) {
    if (($config{$i}{'type'} eq 'data') &&
        ($config{$i}{'key'} eq $oldkey)) {
      $config{$i}{'key'} = $newkey;
      $self{'changed'} = 1;
    }
  }
  if (defined($self{'keyvalue'}{$oldkey})) {
    $self{'keyvalue'}{$newkey} = $self{'keyvalue'}{$oldkey};
    delete $self{'keyvalue'}{$oldkey};
    $self{'keyvalue'}{$newkey}{'status'} = 'changed';
    $self{'changed'} = 1;
  }
}

sub is_changed
{
  my $self = shift;
  return $self{'changed'};
}

sub save
{
  my $self = shift;
  my $outarg = shift;
  my $closeit = 0;
  # unless $outarg is defined or we are changed, return immediately
  return if (! ( defined($outarg) || $self->is_changed));
  #
  %config = %{$self{'confdata'}};
  #
  # determine where to write to
  my $out = $outarg;
  my $fhout;
  if (!defined($out)) {
    $out = $config{'file'};
    my $dn = TeXLive::TLUtils::dirname($out);
    TeXLive::TLUtils::mkdirhier($dn);
    if (!open(CFG, ">$out")) {
      tlwarn("Cannot write to $out: $!\n");
      return 0;
    }
    $closeit = 1;
    $fhout = \*CFG;
  } else {
    # check what we got there for $out
    if (ref($out) eq 'SCALAR') {
      # that is a file name
      my $dn = TeXLive::TLUtils::dirname($out);
      TeXLive::TLUtils::mkdirhier($dn);
      if (!open(CFG, ">$out")) {
        tlwarn("Cannot write to $out: $!\n");
        return 0;
      }
      $fhout = \*CFG;
      $closeit = 1;
    } elsif (ref($out) eq 'GLOB') {
      # that hopefully is a fh
      $fhout = $out;
    } else {
      tlwarn("Unknown out argument $out\n");
      return 0;
    }
  }
    
  #
  # first we write the config file as close as possible to orginal layout,
  # and after that we add new key/value pairs
  for my $i (0..$config{'lines'}) {
    my $is_changed = 0;
    if ($config{$i}{'type'} eq 'comment') {
      print $fhout "$config{$i}{'value'}";
      print $fhout ($config{$i}{'multiline'} ? "\\\n" : "\n");
    } elsif ($config{$i}{'type'} eq 'empty') {
      print $fhout ($config{$i}{'multiline'} ? "\\\n" : "\n");
    } elsif ($config{$i}{'type'} eq 'data') {
      # we have to check whether the original data has been changed!!
      if ($self{'keyvalue'}{$config{$i}{'key'}}{'status'} eq 'changed') {
        $is_changed = 1;
        print $fhout "$config{$i}{'key'} $config{'sep'} $self{'keyvalue'}{$config{$i}{'key'}}{'value'}";
        if (defined($config{$i}{'postcomment'})) {
          print $fhout $config{$i}{'postcomment'};
        }
        print $fhout ($config{$i}{'multiline'} ? "\\\n" : "\n");
      } elsif ($self{'keyvalue'}{$config{$i}{'key'}}{'status'} eq 'deleted') {
        $is_changed = 1;
      } else {
        print $fhout "$config{$i}{'original'}";
        print $fhout ($config{$i}{'multiline'} ? "\\\n" : "\n");
      }
    } elsif ($config{$i}{'type'} eq 'continuation') {
      if ($is_changed) {
        # ignore continuation lines
      } else {
        print $fhout "$config{$i}{'value'}";
        print $fhout ($config{$i}{'multiline'} ? "\\\n" : "\n");
      }
    }
  }
  #
  # save new keys
  for my $k (CORE::keys %{$self{'keyvalue'}}) {
    if ($self{'keyvalue'}{$k}{'status'} eq 'new') {
      print $fhout "$k $config{'sep'} $self{'keyvalue'}{$k}{'value'}\n";
    }
  }
  close $fhout if $closeit;
  #
  # reparse myself
  if (!defined($outarg)) {
    $self->reparse;
  }
}




#
# parse/write config file
# these functions allow reading and writing of config files
# that consists of comments (comment char/string is the second argument)
# and pairs
#   \s* key \s* SEP \s* value \s*
# where SEP is the third argument,
# and key does not contain neither white space nor SEP
# and value can be arbitry
#
# continuation lines are allowed
# Furthermore, at least the separator has to be on the same line as the key!!
# Continuations followed by comment lines are invalid!
#
sub parse_config_file {
  my ($file, $cc, $sep) = @_;
  my @data;
  if (!open(CFG, "<$file")) {
    @data = ();
  } else {
    @data = <CFG>;
    chomp(@data);
    close(CFG);
  }

  my %config = ();
  $config{'file'} = $file;
  $config{'cc'} = $cc;
  $config{'sep'} = $sep;

  my $lines = $#data;
  my $cont_running = 0;
  for my $l (0..$lines) {
    $config{$l}{'original'} = $data[$l];
    if ($cont_running) {
      if ($data[$l] =~ m/^(.*)\\$/) {
        $config{$l}{'type'} = 'continuation';
        $config{$l}{'multiline'} = 1;
        $config{$l}{'value'} = $1;
        next;
      } else {
        # last line of a continuation
        # do nothing, we will finish here
        $config{$l}{'type'} = 'continuation';
        $config{$l}{'value'} = $data[$l];
        $cont_running = 0;
        next;
      }
    }
    # ignore continuation after comments, that is the behaviour the
    # kpathsea library is using, so we follow it here
    if ($data[$l] =~ m/$cc/) {
      $data[$l] =~ s/\\$//;
    }
    # continuation line
    if ($data[$l] =~ m/^(.*)\\$/) {
      $cont_running = 1;
      $config{$l}{'multiline'} = 1;
      # remove the continuation marker so that we can do everything
      # as normal below
      $data[$l] =~ s/\\$//;
      # we will continue below
    }
    # from now on, if $cont_running == 1, then it means that
    # we are in the FIRST line of a multi line setting, so evaluate
    # it accordingly to get the key if necessary

    # empty lines are treated as comments
    if ($data[$l] =~ m/^\s*$/) {
      $config{$l}{'type'} = 'empty';
      next;
    }
    if ($data[$l] =~ m/^\s*$cc/) {
      # save the full line as is into the config hash
      $config{$l}{'type'} = 'comment';
      $config{$l}{'value'} = $data[$l];
      next;
    }
    # mind that the .*? is making the .* NOT greedy, ie matching as few as
    # possible. That way we can get rid of the comments at the end of lines
    if ($data[$l] =~ m/^\s*([^\s$sep]+)\s*$sep\s*(.*?)(\s*)?($cc.*)?$/) {
      $config{$l}{'type'} = 'data';
      $config{$l}{'key'} = $1;
      $config{$l}{'value'} = $2;
      if (defined($3)) {
        my $postcomment = $3;
        if (defined($4)) {
          $postcomment .= $4;
        }
        # check that there is actually a comment in the second part of the
        # line. Otherwise we might add the continuation lines of that
        # line to the value
        if ($postcomment =~ m/$cc/) {
          $config{$l}{'postcomment'} = $postcomment;
        }
      }
      next;
    }
    # if we are still here, that means we cannot evaluate the config file
    # give a BIG FAT WARNING but save the line as comment and continue 
    # anyway
    warn("WARNING WARNING WARNING\n");
    warn("Cannot parse config file $file ($cc, $sep)\n");
    warn("The following line (l.$l) seems to be wrong:\n");
    warn(">>> $data[$l]\n");
    warn("We will treat this line as a comment!\n");
    $config{$l}{'type'} = 'comment';
    $config{$l}{'value'} = $data[$l];
  }
  # save the number of lines in the config hash
  $config{'lines'} = $lines;
  return %config;
}

sub dump_config_data {
  my $foo = shift;
  my %config = %{$foo};
  print "config file name: $config{'file'}\n";
  print "config comment char: $config{'cc'}\n";
  print "config separator: $config{'sep'}\n";
  print "config lines: $config{'lines'}\n";
  for my $i (0..$config{'lines'}) {
    print "line ", $i+1, ": $config{$i}{'type'}";
    if ($config{$i}{'type'} eq 'comment') {
      print "\nCOMMNENT = $config{$i}{'value'}\n";
    } elsif ($config{$i}{'type'} eq 'data') {
      print "\nKEY = $config{$i}{'key'}\nVALUE = $config{$i}{'value'}\n";
    } elsif ($config{$i}{'type'} eq 'empty') {
      print "\n";
      # do nothing
    } elsif ($config{$i}{'type'} eq 'continuation') {
      print "\nVALUE = $config{$i}{'value'}\n";
    } else {
      print "-- UNKNOWN TYPE\n";
    }
  }
}
      
sub write_config_file {
  my $foo = shift;
  my %config = %{$foo};
  for my $i (0..$config{'lines'}) {
    if ($config{$i}{'type'} eq 'comment') {
      print "$config{$i}{'value'}";
      print ($config{$i}{'multiline'} ? "\\\n" : "\n");
    } elsif ($config{$i}{'type'} eq 'data') {
      print "$config{$i}{'key'} $config{'sep'} $config{$i}{'value'}";
      if ($config{$i}{'multiline'}) {
        print "\\";
      }
      print "\n";
    } elsif ($config{$i}{'type'} eq 'empty') {
      print ($config{$i}{'multiline'} ? "\\\n" : "\n");
    } elsif ($config{$i}{'type'} eq 'continuation') {
      print "$config{$i}{'value'}";
      print ($config{$i}{'multiline'} ? "\\\n" : "\n");
    } else {
      print STDERR "-- UNKNOWN TYPE\n";
    }
  }
}


1;
__END__


=head1 NAME

C<TeXLive::TLConfFile> -- TeX Live Config File Access Module

=head1 SYNOPSIS

  use TeXLive::TLConfFile;

  $conffile = TeXLive::TLConfFile->new($file_name, $comment_char, $separator);
  $conffile->file;
  $conffile->cc;
  $conffile->sep;
  $conffile->key_present($key);
  $conffile->keys;
  $conffile->value($key [, $value]);
  $conffile->is_changed;
  $conffile->save;
  $conffile->reparse;

=head1 DESCRIPTION

This module allows parsing, changing, saving of configuration files
of a general style.

The configuration files (henceforth conffiles) can contain comments
initiated by the $comment_char defined at instantiation time.
Everything after a $comment_char, as well as empty lines, will be ignored.

The rest should consists of key/value pairs separated by the separator,
defined as well at instantiation time.

Whitespace around the separator, and before and after key and value 
are allowed.

Comments can be on the same line as key/value pairs and are also preserved
over changes.

Continuation lines (i.e., lines with last character being a backslash)
are allowed after key/value pairs, but the key and
the separator has to be on the same line.

Continuations are not possible in comments, so a terminal backslash in 
a comment will be ignored, and in fact not written out on save.

=head2 Methods

=over 4

=item B<< $conffile = TeXLive::TLConfFile->new($file_name, $comment_char, $separator) >>

instantiates a new TLConfFile and returns the object. The file specified
by C<$file_name> does not have to exist, it will be created at save time.

The C<$comment_char> can actually be any regular expression, but 
embedding grouping is a bad idea as it will break parsing.

The C<$separator> can also be any regular expression.

=item B<< $conffile->file >>

Returns the location of the configuration file. Not changeable (at the moment).

=item B<< $conffile->cc >>

Returns the comment character.

=item B<< $conffile->sep >>

Returns the separator.

=item B<< $conffile->key_present($key) >>

Returns true (1) if the given key is present in the config file, otherwise
returns false (0).

=item B<< $conffile->keys >>

Returns the list of keys currently set in the config file.

=item B<< $conffile->value($key [, $value]) >>

With one argument, returns the current setting of C<$key>, or undefined
if the key is not set.

With two arguments changes (or adds) the key/value pair to the config
file and returns the I<new> value.

=item B<< $conffile->rename_key($oldkey, $newkey) >>

Renames a key from C<$oldkey> to C<$newkey>. It does not automatically
save the new config file.

=item B<< $conffile->is_changed >>

Returns true (1) if some real change has happened in the configuration file,
that is a value has been changed to something different, or a new
setting has been added.

Note that changing a setting back to the original one will not reset
the changed flag.

=item B<< $conffile->save >>

Saves the config file, preserving as much structure and comments of 
the original file as possible.

=item B<< $conffile->reparse >>

Reparses the configuration file.


=back

=head1 EXAMPLES

For parsing a C<texmf.cnf> file you can use

  $tmfcnf = TeXLive::TLConfFile->new(".../texmf/web2c", "[#%]", "=");

since the allowed comment characters for texmf.cnf files are # and %.
After that you can query keys:

  $tmfcnf->value("TEXMFMAIN");
  $tmfcnf->value("trie_size", 900000);
 
=head1 AUTHORS AND COPYRIGHT

This script and its documentation were written for the TeX Live
distribution (L<http://tug.org/texlive>) and both are licensed under the
GNU General Public License Version 2 or later.

=cut

### Local Variables:
### perl-indent-level: 2
### tab-width: 2
### indent-tabs-mode: nil
### End:
# vim:set tabstop=2 expandtab: #
