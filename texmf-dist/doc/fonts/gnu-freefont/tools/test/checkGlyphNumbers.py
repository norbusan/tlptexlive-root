#!/usr/bin/env ../utility/fontforge-interp.sh
__license__ = """
This file is part of GNU FreeFont.

GNU FreeFont is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

GNU FreeFont is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
GNU FreeFont.  If not, see <http://www.gnu.org/licenses/>. 
"""
__author__ = "Stevan White"
__email__ = "stevan.white@googlemail.com"
__copyright__ = "Copyright 2009, 2010, 2011 Stevan White"
__date__ = "$Date:: 2014-09-07 17:58:30 +0900#$"
__version__ = "$Revision: 2969 $"

__doc__ = """
For most unicode ranges, glyph slot numbers should be the same as the
Unicode value.
The Private Use ranges are the exception: those characters should have a
definate non-Unicode number: -1

This script checks that this is the case, and prints out a warning
whenever it isn't.
"""

import fontforge
import sys

problem = False

def inPrivateUseRange( glyph ):
	e = glyph.encoding

	return ( ( e >= 0xE000 and e <= 0xF8FF )
	    or ( e >= 0xFF000 and e <= 0xFFFFD )
	    or ( e >= 0x100000 and e <= 0x10FFFD ) )

def isSpecialTrueType( glyph ):
	""" Fontforge treats three control characters as the special 
	TrueType characters recommended by that standard
	"""
	e = glyph.encoding

	return e == 0 or e == 1 or e == 0xD

from os import path
def checkGlyphNumbers( fontDir, fontFile ):
	if isinstance( fontFile, ( list, tuple ) ):
		print "In directory " + fontDir
		for fontName in fontFile:
			checkGlyphNumbers( fontDir, fontName )
		return

	print "Checking slot numbers in " + fontFile
	font = fontforge.open( path.join( fontDir, fontFile ) )

	g = font.selection.all()
	g = font.selection.byGlyphs

	valid = True
	for glyph in g:
		if isSpecialTrueType( glyph ):
			# FIXME really should complain if it DOESNT exist
			pass
		elif inPrivateUseRange( glyph ):
			if glyph.unicode != -1:
				print "Glyph at slot " + str( glyph.encoding ) \
					+ " is Private Use but has Unicode"
				problem = True
		else:
			if glyph.encoding != glyph.unicode:
				print "Glyph at slot " + str( glyph.encoding ) \
					+ " has wrong Unicode"
				problem = True

# --------------------------------------------------------------------------
args = sys.argv[1:]

if len( args ) < 1 or len( args[0].strip() ) == 0:
	checkGlyphNumbers( '../../sfd/',
		( 'FreeSerif.sfd', 'FreeSerifItalic.sfd',
		'FreeSerifBold.sfd', 'FreeSerifBoldItalic.sfd',
		'FreeSans.sfd', 'FreeSansOblique.sfd',
		'FreeSansBold.sfd', 'FreeSansBoldOblique.sfd',
		'FreeMono.sfd', 'FreeMonoOblique.sfd',
		'FreeMonoBold.sfd', 'FreeMonoBoldOblique.sfd' ) )
else:
	checkGlyphNumbers( args[0], args[1:] )

if problem:
	sys.exit( 1 )
