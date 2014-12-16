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
__copyright__ = "Copyright 2011, 2012, Stevan White"
__date__ = "$Date:: 2013-05-21 05:15:23 +0900#$"
__version__ = "$Revision: 2589 $"
__doc__ = """
Common tools used by the generate scripts.
"""

import re

_re_vstr = re.compile( '\$Revision: (\d*)\s*\$(.*)' )

def trim_version_str( font ):
	""" SVN automatically puts a revision number between dollar signs
	in the sfd file's Version string.
	However the OpenType standard recommends
		Version n.m
	Where n and m are decimal numbers.
	"""
	vstr_match = _re_vstr.match( font.version )
	ot_stdized = ''
	if vstr_match:
		trimmed = vstr_match.group( 1 )
		rest = vstr_match.group( 2 )
		otstdized = '0412.' + trimmed + rest
		font.version = otstdized
		#font.appendSFNTName( n[0], n[1], otstdized )
		return trimmed
	return otstdized

