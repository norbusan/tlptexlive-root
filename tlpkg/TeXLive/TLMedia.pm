# $Id: TLMedia.pm 20380 2010-11-09 08:33:39Z preining $
# TeXLive::TLMedia.pm - module for accessing TeX Live Media
# Copyright 2008, 2009, 2010 Norbert Preining
# This file is licensed under the GNU General Public License version 2
# or any later version.

package TeXLive::TLMedia;

my $svnrev = '$Revision: 20380 $';
my $_modulerevision;
if ($svnrev =~ m/: ([0-9]+) /) {
  $_modulerevision = $1;
} else {
  $_modulerevision = "unknown";
}
sub module_revision {
  return $_modulerevision;
}


use TeXLive::TLConfig;
use TeXLive::TLUtils qw(copy win32 dirname mkdirhier basename download_file
                        merge_into debug ddebug info tlwarn log);
use TeXLive::TLPDB;
use TeXLive::TLWinGoo;

sub new
{
  my ($class, @args) = @_;
  # 0 elements -> -1
  # 1 arg      ->  0
  # even args  ->  uneven
  my $location;
  my %params;
  my $self = { };
  my $tlpdbfile;
  if ($#args % 2) {
    # even number of arguments, the first must be the location
    %params = @args;
    $location = $params{'-location'};
    $tlpdbfile = $params{'-tlpdbfile'};
  } else {
    # odd number of arguments
    $location = shift @args;
  }
  my $media;
  # of no argument is given we assume NET and default URL
  if (!defined($location)) {
    return;
  }
  # no default by itself ...
  # $location = "$TeXLiveURL" unless (defined($location));
  # do media autodetection
  if ($location =~ m,http://|ftp://,) {
    $media = 'NET';
  } else {
    if ($location =~ m,file://*(.*)$,) {
      $location = "/$1";
    }
    if (-d "$location/texmf/web2c") {
      $media = 'DVD';
    } elsif (-d "$location/$Archive") {
      $media = 'CD';
    } else {
      # we cannot find the right type, return undefined, that should
      # make people notice
      return;
    }
  }
  my $tlpdb;
  if (defined($tlpdbfile)) {
    # we got the tlpdb file for a specific location
    debug("Loading TLPDB from $tlpdbfile for $location ...\n");
    $tlpdb = TeXLive::TLPDB->new;
    if ($tlpdb->from_file($tlpdbfile)) {
      # found a positive number of packages
      $tlpdb->root($location);
    } else {
      # couldn't read from tlpdb
      return(undef);
    }
  } else {
    debug("Loading $location/$InfraLocation/$DatabaseName ...\n");
    $tlpdb = TeXLive::TLPDB->new(root => $location);
    return(undef) unless defined($tlpdb);
  }
  my (@all_c, @std_c, @lang_c, @lang_doc_c);
  my (@schemes);
  my %revs;
  foreach my $pkg ($tlpdb->list_packages) {
    my $tlpobj = $tlpdb->{'tlps'}{$pkg};
    $revs{$tlpobj->name} = $tlpobj->revision;
    if ($tlpobj->category eq "Collection") {
      push @all_c, $pkg;
      if ($pkg =~ /collection-lang/) {
        push @lang_c, $pkg;
      } elsif ($pkg =~ /documentation/) {
        if ($pkg =~ /documentation-base/) {
          push @std_c, $pkg;
        } else {
          push @lang_doc_c, $pkg;
        }
      } else {
        push @std_c, $pkg;
      }
    } elsif ($tlpobj->category eq "Scheme") {
      push @schemes, $pkg;
    }
  }
  my (@systems);
  @systems = $tlpdb->available_architectures;
  $self->{'media'} = $media;
  $self->{'location'} = $location;
  $self->{'tlpdb'} = $tlpdb;
  $self->{'release'} = $tlpdb->config_release;
  @{ $self->{'all_collections'} } = @all_c;
  @{ $self->{'std_collections'} } = @std_c;
  @{ $self->{'lang_collections'} } = @lang_c;
  @{ $self->{'lang_doc_collections'} } = @lang_doc_c;
  @{ $self->{'schemes'} } = @schemes;
  @{ $self->{'systems'} } = @systems;
  %{ $self->{'pkgrevs'} } = %revs;
  bless $self, $class;
  return $self;
}

# returns a scalar (0) on error
# returns a reference to a hash with actions on success
sub install_package {
  my ($self, $pkg, $totlpdb, $nopostinstall, $fallbackmedia) = @_;
  my $fromtlpdb = $self->tlpdb;
  my $ret;
  die("TLMedia not initialized, cannot find tlpdb!") unless (defined($fromtlpdb));
  my $tlpobj = $fromtlpdb->get_package($pkg);
  if (!defined($tlpobj)) {
    if (defined($fallbackmedia)) {
      if ($ret = $fallbackmedia->install_package($pkg,$totlpdb, $nopostinstall)) {
        debug("installed $pkg from fallback\n");
        return $ret;
      } else {
        tlwarn("$0: Cannot find package $pkg (in fallback, either)\n");
        return 0;
      }
    } else {
      tlwarn("$0: Cannot find package $pkg\n");
      return 0;
    }
  } else {
    my $container_src_split = $fromtlpdb->config_src_container;
    my $container_doc_split = $fromtlpdb->config_doc_container;
    # get options about src/doc splitting from $totlpdb
    my $opt_src = $totlpdb->option("install_srcfiles");
    my $opt_doc = $totlpdb->option("install_docfiles");
    my $real_opt_doc = $opt_doc;
    my $reloc = 1 if $tlpobj->relocated;
    my $container;
    my @installfiles;
    my $location = $self->location;
    # make sure that there is no terminal / in $location, otherwise we
    # will get double // somewhere
    $location =~ s!/$!!;
    foreach ($tlpobj->runfiles) {
      # s!^!$location/!;
      push @installfiles, $_;
    }
    foreach ($tlpobj->allbinfiles) {
      # s!^!$location/!;
      push @installfiles, $_;
    }
    if ($opt_src) {
      foreach ($tlpobj->srcfiles) {
        # s!^!$location/!;
        push @installfiles, $_;
      }
    }
    if ($real_opt_doc) {
      foreach ($tlpobj->docfiles) {
        # s!^!$location/!;
        push @installfiles, $_;
      }
    }
    my $media = $self->media;
    if ($media eq 'DVD') {
      $container = \@installfiles;
    } elsif ($media eq 'CD') {
      if (-r "$location/$Archive/$pkg.zip") {
        $container = "$location/$Archive/$pkg.zip";
      } elsif (-r "$location/$Archive/$pkg.tar.xz") {
        $container = "$location/$Archive/$pkg.tar.xz";
      } else {
        tlwarn("Cannot find a package $pkg (.zip or .xz) in $location/$Archive\n");
        next;
      }
    } elsif (&media eq 'NET') {
      $container = "$location/$Archive/$pkg.$DefaultContainerExtension";
    }
    $self->_install_package ($container, $reloc, \@installfiles, $totlpdb) 
      || return(0);
    # if we are installing from CD or NET we have to fetch the respective
    # source and doc packages $pkg.source and $pkg.doc and install them, too
    if (($media eq 'NET') || ($media eq 'CD')) {
      # we install split containers under the following conditions:
      # - the container were split generated
      # - src/doc files should be installed
      # (- the package is not already a split one (like .i386-linux))
      # the above test has been removed because it would mean that
      #   texlive.infra.doc.tar.xz
      # will never be installed, and we do already check that there
      # are at all src/doc files, which in split packages of the form 
      # foo.ARCH are not present. And if they are present, than that is fine,
      # too (bin-foobar.win32.doc.tar.xz)
      # - there are actually src/doc files present
      if ($container_src_split && $opt_src && $tlpobj->srcfiles) {
        my $srccontainer = $container;
        $srccontainer =~ s/(\.tar\.xz|\.zip)$/.source$1/;
        $self->_install_package ($srccontainer, $reloc, \@installfiles, $totlpdb) 
          || return(0);
      }
      if ($container_doc_split && $real_opt_doc && $tlpobj->docfiles) {
        my $doccontainer = $container;
        $doccontainer =~ s/(\.tar\.xz|\.zip)$/.doc$1/;
        $self->_install_package ($doccontainer, $reloc, \@installfiles, $totlpdb) 
          || return(0);
      }
      #
      # if we installed from NET/CD and we got a relocatable container
      # make sure that the stray texmf-dist/tlpkg directory is removed
      # in USER MODE that should NOT be done because we keep the information
      # there, but for now do it unconditionally
      if ($tlpobj->relocated) {
        my $reloctree = $totlpdb->root . "/" . $TeXLive::TLConfig::RelocTree;
        my $tlpkgdir = $reloctree . "/" . $TeXLive::TLConfig::InfraLocation;
        my $tlpod = $tlpkgdir .  "/tlpobj";
        TeXLive::TLUtils::rmtree($tlpod) if (-d $tlpod);
        # we try to remove the tlpkg directory, that will succeed only
        # if it is empty. So in normal installations it won't be, but
        # if we are installing a relocated package it is texmf-dist/tlpkg
        # which will be (hopefully) empty
        rmdir($tlpkgdir) if (-d "$tlpkgdir");
      }
    }
    # we don't want to have wrong information in the tlpdb, so remove the
    # src/doc files if they are not installed ...
    if (!$opt_src) {
      $tlpobj->clear_srcfiles;
    }
    if (!$real_opt_doc) {
      $tlpobj->clear_docfiles;
    }
    # if a package is relocatable we have to cancel the reloc prefix
    # and unset the relocated setting
    # before we save it to the local tlpdb
    if ($tlpobj->relocated) {
      $tlpobj->cancel_reloc_prefix;
      $tlpobj->relocated(0);
    }
    # we have to write out the tlpobj file since it is contained in the
    # archives (.tar.xz) but at DVD install time we don't have them
    my $tlpod = $totlpdb->root . "/tlpkg/tlpobj";
    mkdirhier( $tlpod );
    open(TMP,">$tlpod/".$tlpobj->name.".tlpobj") or
      die("Cannot open tlpobj file for ".$tlpobj->name);
    $tlpobj->writeout(\*TMP);
    close(TMP);
    $totlpdb->add_tlpobj($tlpobj);
    $totlpdb->save;
    # compute the return value
    TeXLive::TLUtils::announce_execute_actions("enable", $tlpobj);
    if (!$nopostinstall) {
      # do the postinstallation actions
      #
      # Run the post installation code in the postaction tlpsrc entries
      # in case we are on w32 and the admin did install for himself only
      # we switch off admin mode
      if (win32() && admin() && !$totlpdb->option("w32_multi_user")) {
        non_admin();
      }
      # for now desktop_integration maps to both installation
      # of desktop shortcuts and menu items, but we can split them later
      &TeXLive::TLUtils::do_postaction("install", $tlpobj,
        $totlpdb->option("file_assocs"),
        $totlpdb->option("desktop_integration"),
        $totlpdb->option("desktop_integration"),
        $totlpdb->option("post_code"));
    }
  }
  return 1;
}

#
# _install_package
# actually does the installation work
# returns 1 on success and 0 on error
#
sub _install_package {
  my ($self, $what, $reloc, $filelistref, $totlpdb) = @_;

  my $media = $self->media;
  my $target = $totlpdb->root;
  my $tempdir = "$target/temp";

  my @filelist = @$filelistref;

  # we assume that $::progs has been set up!
  my $wget = $::progs{'wget'};
  my $xzdec = $::progs{'xzdec'};
  if (!defined($wget) || !defined($xzdec)) {
    tlwarn("_install_package: programs not set up properly, strange.\n");
    return(0);
  }

  if (ref $what) {
    # we are getting a ref to a list of files, so install from DVD
    my $location = $self->location;
    foreach my $file (@$what) {
      # @what is taken, not @filelist!
      # is this still needed?
      my $dn=dirname($file);
      mkdirhier("$target/$dn");
      copy "$location/$file", "$target/$dn";
    }
    # we always assume that copy will work
    return(1);
  } elsif ($what =~ m,\.tar(\.xz)?$,) {
    my $type = defined($1) ? "xz" : "tar";
      
    $target .= "/$TeXLive::TLConfig::RelocTree" if $reloc;

    # this is the case when we install from CD or the NET, or a backup
    #
    # in all other cases we create temp files .tar.xz (or use the present
    # one), xzdec them, and then call tar

    my $fn = basename($what);
    my $pkg = $fn;
    $pkg =~ s/\.tar(\.xz)?$//;
    mkdirhier("$tempdir");
    my $tarfile;
    my $remove_tarfile = 1;
    if ($type eq "xz") {
      my $xzfile = "$tempdir/$fn";
      $tarfile  = "$tempdir/$fn"; $tarfile =~ s/\.xz$//;
      my $xzfile_quote = $xzfile;
      my $tarfile_quote = $tarfile;
      my $target_quote = $target;
      if (win32()) {
        $xzfile =~ s!/!\\!g;
        $xzfile_quote = "\"$xzfile\"";
        $tarfile =~ s!/!\\!g;
        $tarfile_quote = "\"$tarfile\"";
        $target =~ s!/!\\!g;
        $target_quote = "\"$target\"";
      }
      if ($what =~ m,http://|ftp://,) {
        # we are installing from the NET
        # download the file and put it into temp
        if (!download_file($what, $xzfile) || (! -r $xzfile)) {
          tlwarn("Downloading \n");
          tlwarn("   $what\n");
          tlwarn("did not succeed, please retry.\n");
          unlink($tarfile, $xzfile);
          return(0);
        }
      } else {
        # we are installing from CD
        # copy it to temp
        copy($what, $tempdir);
      }
      debug("un-xzing $xzfile to $tarfile\n");
      system("$xzdec < $xzfile_quote > $tarfile_quote");
      if (! -f $tarfile) {
        tlwarn("_install_package: Unpacking $xzfile failed, please retry.\n");
        unlink($tarfile, $xzfile);
        return(0);
      }
      unlink($xzfile);
    } else {
      $tarfile = "$tempdir/$fn";
      if ($what =~ m,http://|ftp://,) {
        if (!download_file($what, $tarfile) || (! -r $tarfile)) {
          tlwarn("Downloading \n");
          tlwarn("   $what\n");
          tlwarn("failed, please retry.\n");
          unlink($tarfile);
          return(0);
        }
      } else {
        $tarfile = $what;
        $remove_tarfile = 0;
      }
    }
    my $ret = TeXLive::TLUtils::untar($tarfile, $target, $remove_tarfile);
    # remove the $pkg.tlpobj, we recreate it anyway again
    unlink ("$target/tlpkg/tlpobj/$pkg.tlpobj") 
      if (-r "$target/tlpkg/tlpobj/$pkg.tlpobj");
    return $ret;
  } else {
    tlwarn("_install_package: Don't know how to install $what\n");
    return(0);
  }
}

#
# remove_package removes a single package with all files (including the
# # tlpobj files) and the entry from the tlpdb.
sub remove_package {
  my ($self, $pkg, %opts) = @_;
  my $localtlpdb = $self->tlpdb;
  my $tlp = $localtlpdb->get_package($pkg);
  if (!defined($tlp)) {
    tlwarn ("$pkg: package not present, cannot remove\n");
  } else {
    my $currentarch = $self->platform();
    if ($pkg eq "texlive.infra" || $pkg eq "texlive.infra.$currentarch") {
      log ("Not removing $pkg, it is essential!\n");
      return 0;
    }
    # we have to chdir to $localtlpdb->root
    my $Master = $localtlpdb->root;
    chdir ($Master) || die "chdir($Master) failed: $!";
    my @files = $tlp->all_files;
    # also remove the .tlpobj file
    push @files, "tlpkg/tlpobj/$pkg.tlpobj";
    # and the ones from src/doc splitting
    if (-r "tlpkg/tlpobj/$pkg.source.tlpobj") {
      push @files, "tlpkg/tlpobj/$pkg.source.tlpobj";
    }
    if (-r "tlpkg/tlpobj/$pkg.doc.tlpobj") {
      push @files, "tlpkg/tlpobj/$pkg.doc.tlpobj";
    }
    #
    # some packages might be relocated, thus having the RELOC prefix
    # in user mode we just remove the prefix, in normal mode we
    # replace it with texmf-dist
    # since we don't have user mode 
    if ($tlp->relocated) {
      for (@files) {
        s:^$RelocPrefix/:$RelocTree/:;
      }
    }
    #
    # we want to check that a file is only listed in one package, so
    # in case that a file to be removed is listed in another package
    # we will warn and *not* remove it
    my %allfiles;
    for my $p ($localtlpdb->list_packages) {
      next if ($p eq $pkg); # we have to skip the to be removed package
      for my $f ($localtlpdb->get_package($p)->all_files) {
      	$allfiles{$f} = $p;
      }
    }
    my @goodfiles = ();
    my @badfiles = ();
    my @debugfiles = ();
    for my $f (@files) {
      # in usermode we have to add texmf-dist again for comparison
      if (defined($allfiles{$f})) {
        # this file should be removed but is mentioned somewhere, too
        # take into account if we got a warn list
        if (defined($opts{'remove-warn-files'})) {
          my %a = %{$opts{'remove-warn-files'}};
          if (defined($a{$f})) {
            push @badfiles, $f;
          } else {
            # NO NOTHING HERE!!!
            # DON'T PUSH IT ON @goodfiles, it will be removed, which we do
            # NOT want. We only want to supress the warning!
            push @debugfiles, $f;
          }
        } else {
          push @badfiles, $f;
        }
      } else {
        push @goodfiles, $f;
      }
    }
    if ($#debugfiles >= 0) {
      debug("The following files will not be removed due to the removal of $pkg.\n");
      debug("But we do not warn on it because they are moved to other packages.\n");
      for my $f (@debugfiles) {
        debug(" $f - $allfiles{$f}\n");
      }
    }
    if ($#badfiles >= 0) {
      # warn the user
      tlwarn("The following files should be removed due to the removal of $pkg,\n");
      tlwarn("but are part of another package, too.\n");
      for my $f (@badfiles) {
        tlwarn(" $f - $allfiles{$f}\n");
      }
    }
    #
    # Run only the postaction code thing now since afterwards the
    # files will be gone ...
    if (defined($opts{'nopostinstall'}) && $opts{'nopostinstall'}) {
      &TeXLive::TLUtils::do_postaction("remove", $tlp,
        0, # option_file_assocs,
        0, # option_desktop_integration, menu part
        0, # option_desktop_integration, desktop part
        $localtlpdb->option("post_code"));
    }
    # 
    my @removals = &TeXLive::TLUtils::removed_dirs (@goodfiles);
    # now do the removal
    for my $entry (@goodfiles) {
      unlink $entry;
    }
    for my $d (@removals) {
      rmdir $d;
    }
    $localtlpdb->remove_package($pkg);
    TeXLive::TLUtils::announce_execute_actions("disable", $tlp);
    # should we save at each removal???
    # advantage: the tlpdb actually reflects what is installed
    # disadvantage: removing a collection calls the save routine several times
    # still I consider it better that the tlpdb is in a consistent state
    $localtlpdb->save;
    #
    # Run the post installation code in the postaction tlpsrc entries
    # in case we are on w32 and the admin did install for himself only
    # we switch off admin mode
    if (win32() && admin() && !$localtlpdb->option("w32_multi_user")) {
      non_admin();
    }
    #
    # Run the post installation code in the postaction tlpsrc entries
    # the postaction code part cannot be evaluated now since the
    # files are already removed.
    # Again, desktop integration maps to desktop and menu links
    if (!$nopostinstall) {
      &TeXLive::TLUtils::do_postaction("remove", $tlp,
        $localtlpdb->option("file_assocs"),
        $localtlpdb->option("desktop_integration"),
        $localtlpdb->option("desktop_integration"),
        0);
    }
  }
  return 1;
}


# member access functions
#
sub media { my $self = shift ; return $self->{'media'}; }
sub location { my $self = shift ; return $self->{'location'}; }
sub tlpdb { my $self = shift ; return $self->{'tlpdb'}; }
sub release { my $self = shift ; return $self->{'release'}; }
sub all_collections { my $self = shift; return @{ $self->{'all_collections'} }; }
sub std_collections { my $self = shift; return @{ $self->{'std_collections'} }; }
sub lang_collections { my $self = shift; return @{ $self->{'lang_collections'} }; }
sub lang_doc_collections { my $self = shift; return @{ $self->{'lang_doc_collections'} }; }
sub schemes { my $self = shift; return @{ $self->{'schemes'} }; }
sub systems { my $self = shift; return @{ $self->{'systems'} }; }

# deduce the platform of the referenced media as follows:
# - if the $tlpdb->setting("platform") is there it overrides the detected
#   setting
# - if it is not there call TLUtils::platform()
sub platform {
  # try to deduce the platform
  my $self = shift;
  my $tlpdb = $self->tlpdb;
  if (defined($tlpdb)) {
    my $ret = $tlpdb->setting("platform");
    return $ret if defined $ret;
  }
  # the platform setting wasn't found in the tlpdb, try TLUtils::platform
  return TeXLive::TLUtils::platform();
}

1;
__END__


=head1 NAME

C<TeXLive::TLMedia> -- TeX Live Media module

=head1 SYNOPSIS

  use TeXLive::TLMedia;

  my $tlneo = TeXLive::TLMedia->new('http://www.ctan.org/mirror/tl/');
  my $tlcd  = TeXLive::TLMedia->new('/mnt/tl-cd/');
  my $tldvd = TeXLive::TLMedia->new('/mnt/tl-dvd/');

=head1 DESCRIPTION

missing

=head1 MEMBER ACCESS FUNCTIONS

scalars: media, location, tlpdb, release
lists: all_collections, std_collections, lang_collections, lang_doc_collections,
schemes, systems

=head1 SEE ALSO

The modules L<TeXLive::TLConfig>, L<TeXLive::TLUtils>, L<TeXLive::TLPOBJ>, 
L<TeXLive::TLPDB>, L<TeXLive::TLTREE>.

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
