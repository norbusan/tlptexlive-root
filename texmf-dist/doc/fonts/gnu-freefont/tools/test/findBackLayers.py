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
__copyright__ = "Copyright 2009, 2010, Stevan White"
__date__ = "$Date:: 2013-05-21 05:15:23 +0900#$"
__version__ = "$Revision: 2589 $"

__doc__ = """
Check for glyphs with back layers.

Haven't see this actually work...
"""

import fontforge
from sys import exit

problem = False

def checkBackLayers( fontPath ):
	print "Checking " + fontPath
	font = fontforge.open( fontPath )

	g = font.selection.all()
	g = font.selection.byGlyphs

	nonzero = 0

	for e in g:
		if e.layer_cnt != 2:
			print e

checkBackLayers( '../sfd/FreeSerif.sfd' )
checkBackLayers( '../sfd/FreeSerifItalic.sfd' )
checkBackLayers( '../sfd/FreeSerifBold.sfd' )
checkBackLayers( '../sfd/FreeSerifBoldItalic.sfd' )
checkBackLayers( '../sfd/FreeSans.sfd' )
checkBackLayers( '../sfd/FreeSansOblique.sfd' )
checkBackLayers( '../sfd/FreeSansBold.sfd' )
checkBackLayers( '../sfd/FreeSansBoldOblique.sfd' )
checkBackLayers( '../sfd/FreeMono.sfd' )
checkBackLayers( '../sfd/FreeMonoOblique.sfd' )
checkBackLayers( '../sfd/FreeMonoBold.sfd' )
checkBackLayers( '../sfd/FreeMonoBoldOblique.sfd' )

if problem:
	exit( 0 )
else:
	exit( 1 )
