#!/usr/bin/fontforge -script
"""
For use on Metafont fonts.
To import glyphs each in individual .eps files into an empty font file.

First, process with 'mpost'.  Procedure is:

1) Make sure you have an mfplain mem file for mpost.  It may come with
   the distro, but it is possible also to generate it.  

   I found an mfplain.mp file somewhere.  Use it to make an mfplain.mem.
	   mpost -ini '\input mfplain.mp; dump'

2) Generate .eps files from a .mf file such as skt10.mf
	mpost '&./mfplain \mag=1; truecorners:=0; filenametemplate "%j-%4c.eps"; input skt10.mf'

   A bunch of eps files should result, with names like
   	skt10-012.eps
3) Use FontForge to make an empty font file, with a name like SKT.sfd
4) Run this script on the eps files like so
	freefont/tools/metafont/bulk_eps_import.py SKT.sfd skt10

Then clean up clean up clean up.
"""
__author__ = "Stevan White"
__email__ = "stevan.white@googlemail.com"
__copyright__ = "Copyright 2008, 2011, Stevan White"
__date__ = "$Date:: 2013-04-09 12:44:41 +0200#$"
__version__ = "$Revision: 1694 $"

import fontforge
import sys, os
import fnmatch, re

problem = False

def import_glyph( font, name, chrnum ):
	print "importing file: " + name + " to slot " + str( chrnum )

	g = font.createChar( chrnum )

	print "importing outlines " + name 
	g.importOutlines( name )
	# The glyphs produced by MetaPost usually have a grid, whose
	# right side seems to correspond to the proper right side bearing
	xmax = g.layers[1].boundingBox()[2]
	g.right_side_bearing = max( xmax, 0 )

scriptname = sys.argv[0];
argc = len( sys.argv )

file_pat = r'^([A-Za-z0-9]*)-(\d{3,4}).eps$'
file_pat = sys.argv[2] + r'-(\d{3,4}).eps$'
re_file_pat = re.compile( file_pat )

if argc > 2:
	fontfilename = sys.argv[1]
	font = fontforge.open( fontfilename )
	print "bulk importing to font file: " + fontfilename
	chrnum = 0
	directories = os.listdir('.')
	directories.sort()

	for glyphfile in directories:
		matches = re_file_pat.match( glyphfile )
		if matches:
			print "doing glyph " + glyphfile
			chrnum = int( matches.group(1) )
			import_glyph( font, glyphfile, chrnum )
	print "saving font in " + fontfilename 
	font.save()
	font.close()

sys.exit( int( problem ) )
