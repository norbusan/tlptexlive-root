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
__copyright__ = "Copyright 2010, Stevan White"
__date__ = "$Date:: 2013-04-09 12:44:41 +0200#$"
__version__ = "$Revision: 1.6 $"

import fontforge
import psMat
from sys import stdout

__doc__ = """ 
Replaces the Braille Pattern range in a font.  There must already be
characters defined there.

Two auxiliar glyphs, in variables glyphOff and glyphOn below, represent the
off and on state of the Braille dots, respectively.

One also needs to set the font file path, the width between columns of dots,
and the width between rows of dots, as well as the width of the glyphs.

The first 64 Braille Patterns consist of two columns of four dots,
the bottom two of which are all zero.  The other 6 dots are represented
by the bit patterns of the octal digits of the offset from the range start.

The remaining three sets of 64 patterns repeat the first set, with 
the bottom two dots being the bit pattern for the numbers 1 to 4 in binary.

There are standards for the *punching* of patterns, e.g.
	National Library of Congress
	National Library Service for the Blind and Physically Handicapped
	Specification #800, 2008
	Braille Books and Pamphlets
	http://www.loc.gov/nls/specs/800_march5_2008.pdf
Among other things, it specifies:
	base dot diameter 0.057
	distance center-to-center in a cell 0.092
	distance center-to-center in adjacent cells 0.254
which ratios with a fixed width of 600EM should result in
	center-to-center in cell = 160EM
	center-to-center adjacent = 440EM
	diameter = 99EM

"""

font = fontforge.open( '../../../sfd/FreeMono.sfd' )

glyphOff = 'braille_off'
glyphOn = 'braille_on'
colwidth = 160
rowheight = -160
glyphwidth = 600

def drawdot( g, col, row, on ):
	move = psMat.translate( col * colwidth, row * rowheight )
	if on:
		g.addReference( glyphOn, move )
	else:
		g.addReference( glyphOff, move )

def createAndName( font, off ):
	return font.createChar( 0x2800 + off, 'braille%0.2X' % off )

def drawtopsix( g, off ):
	print 'created', 'braille%0.2X' % off
	g.clear()
	g.right_side_bearing = glyphwidth
	for col in range ( 0, 2 ):
		for row in range ( 0, 3 ):
			print 'shift', ( 3 * col + row )
			state = ( 1 << ( 3 * col + row ) ) & off
			drawdot( g, col, row, state )

# Contrary to the FontForge docs, font.createChar does *not* create a 
# glyph if one doesn't exist, but *does* re-name it if it already exists.
for off in range ( 0, 0x0100 ):
	g = createAndName( font, off )
	drawtopsix( g, off )
	drawdot( g, 0, 3, ( off / 0x40 ) % 2 != 0 )
	drawdot( g, 1, 3, off / 0x80 != 0 )

font.save()
