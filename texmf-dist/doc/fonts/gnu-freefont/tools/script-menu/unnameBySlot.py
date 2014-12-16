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
__date__ = "$Date: 2010-09-14 13:02:02 $"
__version__ = "$Revision: 1.3 $"

__doc__ = """
For use from the FontForge Script Menu.
Add it to the Scripts Menu using the Preferences dialog.

Sets the name and unicode values of the selected range of slots to 
the encoding, that is
	Name:	uniXXXX
	Unocode:	u+XXXX
where XXXX is the 4-digit hex value for the slot encoding.

Careful! it changes the falue whether it was previously set or not.

Detailed info is printed to standard output (see by launching FontForge
from a console).
"""

import fontforge

def explain_error_and_quit( e ):
	if e:
		print 'Error: ', e
	exit( 1 )

try:
	glyphs = fontforge.activeFont().selection.byGlyphs
	for g in glyphs:
		newname = 'NameMe.%s' %( str( g.encoding ) )
		print "naming " + str( g.glyphname ) + ' as ' + newname
		g.glyphname =  newname
		g.unicode = -1
except ValueError, e:
	explain_error_and_quit( e )

