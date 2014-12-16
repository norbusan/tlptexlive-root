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
__date__ = "$Date:: 2013-04-09 12:44:41 +0200#$"
__version__ = "$Revision: 1.5 $"

__doc__ = """
Runs the FontForge validate function on all the font faces.
Prints report on standard output.
Returns 1 if problems found 0 otherwise.
"""

import fontforge
import sys

problem = False


""" Haven't really figured out why TT limit warniings are turndd on,
	or where the limits are set.
"""
def countPointsInLayer( layer ):
	problem = True
	p = 0
	for c in layer:
		p += len( c )
	return p

def printProblemLine( e, msg ):
	print "\t" + e.glyphname + msg 

def dealWithValidationState( state, e ):
	if state & 0x2:
		printProblemLine( e, " has open contour" )
	if state & 0x4:
		printProblemLine( e, " intersects itself" )
	if state & 0x8:
		printProblemLine( e, " is drawn in wrong direction" )
	if state & 0x10:
		printProblemLine( e, " has a flipped reference" )
	if state & 0x20:
		printProblemLine( e, " is missing extrema" )
	if state & 0x40:
		printProblemLine( e, " is missing a reference in a table" )
	if state & 0x80:
		printProblemLine( e, " has more than 1500 pts" )
	if state & 0x100:
		printProblemLine( e, " has more than 96 hints" )
	if state & 0x200:
		printProblemLine( e, " has invalid PS name" )
	"""
	# Not meaningfully set for non-TrueType fonts )
	if state & 0x400:
		printProblemLine( e, " has more points than allowed by TT: " + str( countPointsInLayer( e.layers[1] ) ) )
	if state & 0x800:
		printProblemLine( e, " has more paths than allowed by TT" )
	if state & 0x1000:
		printProblemLine( e, " has more points in composite than allowed by TT" )
	if state & 0x2000:
		printProblemLine( e, " has more paths in composite than allowed by TT" )
	if state & 0x4000:
		printProblemLine( e, " has instruction longer than allowed" )
	if state & 0x8000:
		printProblemLine( e, " has more references than allowed" )
	if state & 0x10000:
		printProblemLine( e, " has references deeper than allowed" )
	if state & 0x20000:
		print e.glyphname + " fpgm or prep tables longer than allowed" )
	"""

def validate( dir, fontFile ):
	try:
		font = fontforge.open( dir + fontFile )
		print "Validating " + fontFile

		g = font.selection.all()
		g = font.selection.byGlyphs

		valid = True
		for e in g:
			state = e.validate()
			if state != 0:
				dealWithValidationState( state, e )
		font.validate
	except Exception, e:
		problem = True
		print >> sys.stderr, str( e )

validate( '../sfd/', 'FreeSerif.sfd' )
validate( '../sfd/', 'FreeSerifItalic.sfd' )
validate( '../sfd/', 'FreeSerifBold.sfd' )
validate( '../sfd/', 'FreeSerifBoldItalic.sfd' )
validate( '../sfd/', 'FreeSans.sfd' )
validate( '../sfd/', 'FreeSansOblique.sfd' )
validate( '../sfd/', 'FreeSansBold.sfd' )
validate( '../sfd/', 'FreeSansBoldOblique.sfd' )
validate( '../sfd/', 'FreeMono.sfd' )
validate( '../sfd/', 'FreeMonoOblique.sfd' )
validate( '../sfd/', 'FreeMonoBold.sfd' )
validate( '../sfd/', 'FreeMonoBoldOblique.sfd' )

validate( '../sfd/', 'FreeSerif.ttf' )
validate( '../sfd/', 'FreeSerifItalic.ttf' )
validate( '../sfd/', 'FreeSerifBold.ttf' )
validate( '../sfd/', 'FreeSerifBoldItalic.ttf' )
validate( '../sfd/', 'FreeSans.ttf' )
validate( '../sfd/', 'FreeSansOblique.ttf' )
validate( '../sfd/', 'FreeSansBold.ttf' )
validate( '../sfd/', 'FreeSansBoldOblique.ttf' )
validate( '../sfd/', 'FreeMono.ttf' )
validate( '../sfd/', 'FreeMonoOblique.ttf' )
validate( '../sfd/', 'FreeMonoBold.ttf' )
validate( '../sfd/', 'FreeMonoBoldOblique.ttf' )

validate( '../sfd/', 'FreeSerif.otf' )
validate( '../sfd/', 'FreeSerifItalic.otf' )
validate( '../sfd/', 'FreeSerifBold.otf' )
validate( '../sfd/', 'FreeSerifBoldItalic.otf' )
validate( '../sfd/', 'FreeSans.otf' )
validate( '../sfd/', 'FreeSansOblique.otf' )
validate( '../sfd/', 'FreeSansBold.otf' )
validate( '../sfd/', 'FreeSansBoldOblique.otf' )
validate( '../sfd/', 'FreeMono.otf' )
validate( '../sfd/', 'FreeMonoOblique.otf' )
validate( '../sfd/', 'FreeMonoBold.otf' )
validate( '../sfd/', 'FreeMonoBoldOblique.otf' )


if problem:
	sys.exit( 1 )
