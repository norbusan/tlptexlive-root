#!/usr/bin/python
from __future__ import print_function
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
__author__ = "Emmanuel Vallois"
__email__ = "vallois@polytech.unice.fr"
__copyright__ = "Copyright 2011 Emmanuel Vallois"
__date__ = "$Date$"
__version__ = "$Revision$"
__doc__ = """
Generates test script 
	arab_shaping.py
from a file
	ArabicShaping.txt
which may be obtained from
	http://www.unicode.org/Public/UNIDATA/ArabicShaping.txt
"""

'''Convert Unicode ArabicShaping.txt to a Python module containing its data.'''

import sys

sys.stdout = open('arabic_shaping.py', 'w')

print('''#!/usr/bin/python
__license__ = """''' + __license__ + '''
"""
__doc__ = """
Module containing UCD ArabicShaping.txt data."""

from unicodedata import name
from collections import OrderedDict

class ArabicShaping:
	def __init__(self, code_point, short_name, joining_type, joining_group):
		self.code_point = code_point
		self.short_name = short_name
		self.joining_type = joining_type
		self.joining_group = joining_group
	def __repr__(self):
		return 'ArabicShaping({:X}, {}, {}, {})'.format(self.code_point, self.short_name, self.joining_type, self.joining_group)

arabic_shapings = OrderedDict()''')
with open('ArabicShaping.txt') as f:
	for line in f:
		if not line.strip() or line[0] == '#': continue
		line = line[:-1] #removes the \n at the end of the line
		fields = line.split('; ')
		print("arabic_shapings[0x{0[0]}] = ArabicShaping(0x{0[0]}, '{0[1]}', '{0[2]}', '{0[3]}')".format(fields))
		if fields[0] == '08A0':
			print('''arabic_shapings[0x08A1] = ArabicShaping(0x8A1, 'BEH WITH HAMZA ABOVE','D','BEH')''')
print('''arabic_shapings[0x08AE] = ArabicShaping(0x8AE, 'DAL WITH THREE DOTS BELOW', 'R', 'DAL')
arabic_shapings[0x08AF] = ArabicShaping(0x8AF, 'SAD WITH THREE DOTS BELOW', 'D', 'SAD')
arabic_shapings[0x08B0] = ArabicShaping(0x8B0, 'GAF WITH INVERTED STROKE', 'D', 'GAF')
arabic_shapings[0x08B1] = ArabicShaping(0x8B1, 'STRAIGHT WAW', 'R', 'WAW')''')

print('''
def short_name(cp):
	shaping = arabic_shapings.get(cp)
	return shaping and shaping.short_name or name(unichr(cp))

def joining_type(cp):
	shaping = arabic_shapings.get(cp)
	return shaping and shaping.joining_type or 'U'

def joining_group(cp):
	shaping = arabic_shapings.get(cp)
	return shaping and shaping.joining_group or 'No_Joining_Group\'''')
