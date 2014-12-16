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
__copyright__ = "Copyright 2009, 2010, Stevan White"
__date__ = "$Date:: 2013-05-21 05:15:23 +0900#$"
__version__ = "$Revision: 2589 $"

__doc__ = """
Diagnostic tool that checks that fonts are really monospace.

Allows characters to have 0 width though (note this is controversial)

Also: in order for box-drawing characters to connect properly, it is 
important that the glyphs all lie between 800 and -200EM vertically.
"""

import fontforge
import sys

problem = False

def ismonomono( fontfilename ):
	print "Checking character bounding boxes: " + fontfilename
	font = fontforge.open( fontfilename )

	g = font.selection.all()
	g = font.selection.byGlyphs

	nonzero = 0

	for e in g:
		if nonzero == 0:
			if e.width > 0:
				nonzero = e.width
		else:
			if e.width > 0 and e.width != nonzero:
				print '  ' + e.glyphname \
					+ '(' + str( e.encoding ) \
					+ ') width is ' + str( e.width ) \
					+ ' not ' + str( nonzero )
				problem = True

		( xmin, ymin, xmax, ymax ) = e.boundingBox()
		if ymin < -200 or ymax > 800:
			print '  ' + e.glyphname + ' goes between heights ' \
				+ str( ymin )  + ' and ' + str( ymax )
	""" 
	For FontForge handling of TrueType/OpenType magic characters:
	1) check that 0x0000 0x0001, 0x000D exist and have names
		.notdef, .null, nonmarkingreturn
	2) check that 0x0000 and 0x000D are width 600, and
	0x0001 has no glyph and is width 0

	Othewise complain that FontForge may not treat it right.
	"""
	if not 0x0000 in font \
		or font[0x0000].glyphname != '.notdef' \
		or font[0x0000].width != nonzero:
		print 'Should be full-width ".notdef" glyph at 0x0000.'
	if not 0x0001 in font \
		or font[0x0001].glyphname != '.null' \
		or font[0x0001].width != 0:
		print 'Should be zero-width ".null" glyph at 0x0001.'
	if not 0x000D in font \
		or font[0x000D].glyphname != 'nonmarkingreturn' \
		or font[0x000D].width != nonzero:
		print 'Should be full-width "nonmarkingreturn" glyph at 0x000D.'

scriptname = sys.argv[0];
argc = len( sys.argv )

if argc > 1:
	for i in range( 1, argc ):
		ismonomono( sys.argv[i] )

if problem:
	sys.exit( 1 )
else:
	sys.exit( 0 )
