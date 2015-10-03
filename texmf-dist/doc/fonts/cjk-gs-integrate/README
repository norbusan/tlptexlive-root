Configuring GhostScript for CJK CID/TTF fonts
=============================================

This script searches a list of directories for CJK fonts, and makes
them available to an installed GhostScript. In the simplest case with
sufficient privileges, a run without arguments should effect in a
complete setup of GhostScript.

Usage
-----

`````
[perl] cjk-gs-integrate[.pl] [OPTIONS]
`````

#### Options ####

`````
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
`````

#### Command like options ####

`````
  --only-aliases        do only regenerate the cidfmap.alias file instead of all
  --list-aliases        lists the available aliases and their options, with the
                        selected option on top
  --list-all-aliases    list all possible aliases without searching for actually
                        present files
  --list-fonts          lists the fonts found on the system
  --info                combines the above two information
`````

Operation
---------

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

How and which directories are searched
--------------------------------------

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

Output files
------------

If no output option is given, the program searches for a GhostScript
interpreter 'gs' and determines its Resource directory. This might
fail, in which case one need to pass the output directory manually.

Since the program adds files and link to this directory, sufficient
permissions are necessary.

Aliases
-------

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

Authors, Contributors, and Copyright
------------------------------------

The script and its documentation was written by Norbert Preining, based
on research and work by Yusuke Kuroki, Bruno Voisin, Munehiro Yamamoto
and the TeX Q&A wiki page.

The script is licensed under GNU General Public License Version 3 or later.
The contained font data is not copyrightable.

