#!/usr/bin/python
from __future__ import print_function, unicode_literals
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
Writes in the file named by the first argument an HTML page comprising a table
for testing joining cursive script characters.

Runs under normal Python, version 2.7 or above.

Typical usage:
unicode_joining.py "Unicode joining test page.html"
"""
import sys
from codecs import open
from string import Template
from collections import OrderedDict
from itertools import chain

_module_missing_msg = """Please run
	generate_arabic_shaping.py
to generate
	arabic_shaping.py"""

try:
	from arabic_shaping import arabic_shapings, joining_type
except:
	print( _module_missing_msg, file=sys.stderr)
	sys.exit( 1 )

if len(sys.argv) > 1:
	outfile = sys.argv[1]
else:
	outfile = 'Unicode joining test page.html'

sys.stdout = open(outfile, 'w', 'utf-8')

class OrderedDefaultDict(OrderedDict):
	def __missing__(self, key):
		self[key] = rv = []
		return rv
	def move_to_end(self, key):
		tmp = self[key]
		del self[key]
		self[key] = tmp

arabic_ranges = tuple(chain(range(0x600, 0x6FF +1), range(0x750, 0x77F +1), range(0x8A0, 0x8FF)))
unicode61_new_ranges = [0x604, 0x8A0]
unicode61_new_ranges.extend(range(0x8A2, 0x8AC + 1))
unicode61_new_ranges.extend(range(0x8E4, 0x8FE + 1))
unicode62_new_ranges = [0x605, 0x8A1]
unicode62_new_ranges.extend(range(0x8AD, 0x8B1 + 1))
unicode62_new_ranges.append(0x8FF)

shapings = filter(lambda s: s.joining_type in 'RD' and (s.joining_group != 'No_Joining_Group' or s.code_point not in arabic_ranges), arabic_shapings.values())
jg_shapings_arabic = OrderedDefaultDict()
jg_shapings_other_scripts = OrderedDefaultDict()
for s in shapings:
	if s.code_point in arabic_ranges:
		jg_shapings_arabic[s.joining_group].append(s)
	else:
		jg_shapings_other_scripts[s.joining_group].append(s)
	if s.code_point == 0x62B:
		jg_shapings_arabic.move_to_end('TEH MARBUTA')
		jg_shapings_arabic['TEH MARBUTA GOAL']
	elif s.code_point == 0x642:
		jg_shapings_arabic.move_to_end('GAF')
		jg_shapings_arabic['SWASH KAF']
	elif s.code_point == 0x646:
		jg_shapings_arabic['NYA']
	elif s.code_point == 0x647:
		jg_shapings_arabic['KNOTTED HEH']
		jg_shapings_arabic['HEH GOAL']
	elif s.code_point == 0x64A:
		jg_shapings_arabic.move_to_end('FARSI YEH')
	elif s.code_point in chain(range(0x627, 0x63A + 1), range(0x641, 0x64A + 1)):
		jg_shapings_arabic.move_to_end(s.joining_group)

#for jg, ls in jg_shapings_arabic.items():
#	for s in ls:
#		print(jg, ls, file=sys.stderr)

table_head = '''
<table frame="box" rules="rows">
{}
<colgroup><col/><col/><col/></colgroup>
<colgroup id="characterCols"><col/><col/><col/><col/></colgroup>
<colgroup><col/></colgroup>'''
table_internal_title = '''<tr><td colspan="8"><h2>{}</h2></td></tr>
<tr>
<th rowspan="2">Joining Group</th>
<th rowspan="2">Code Point</th>
<th rowspan="2">Short Name</th>
<th colspan="5">Contextual Forms</th>
</tr>
<tr><th>Isolated</th><th>Final</th><th>Medial</th><th>Initial</th><th>Joined</th></tr>'''

def print_table():
	contextual_form_formats = { 'isolat':'{}', 'final>':'&zwj;{}', 'medial':'&zwj;{}&zwj;', 'initia':'{}&zwj;' }
	contextual_forms = 'isolat', 'final>', 'medial', 'initia'
	def print_shaping(shaping, rowspan):
		# print('print_shaping', shaping, file=sys.stderr)
		cp = shaping.code_point
		char = unichr(cp)
		print('<tr{}>'.format(' class="nextVersion"' if cp in unicode61_new_ranges else ' class="furtherFuture"' if cp in unicode62_new_ranges else ''))
		if rowspan:	print('<td rowspan="{}">{}</td>'.format(rowspan, shaping.joining_group))
		print('<td>{:04X}</td>'.format(cp))
		print('<td>{}</td>'.format(shaping.short_name))
		i = 0
		for form in contextual_forms:
			print('<td class="ch">{}</td>'.format(contextual_form_formats[form].format(char)))
			i += 1
			if { 'R':'final>', 'D':'' }[joining_type(cp)] == form:
				break
		if i < 4:
			print('<td colspan="{}"></td>'.format(4 - i))
		print('<td class="ch">{}</td>'.format('\u0640' * (4 - i) + char * (i - 1) + ' ' + char))
		print('</tr>')

	print(table_head.format(caption))
	print(table_internal_title.format('Arabic'))
	for shaping_list in jg_shapings_arabic.values():
		rowspan = len(shaping_list)
		for shaping in shaping_list:
			print_shaping(shaping, rowspan)
			rowspan = None

	print(table_internal_title.format('Syriac, Nko and Mandaic'))
	for shaping_list in jg_shapings_other_scripts.values():
		rowspan = len(shaping_list)
		for shaping in shaping_list:
			print_shaping(shaping, rowspan)
			rowspan = None

	print('</table>')

html_heading = Template('''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
<title>$title</title>
<style type="text/css">
.captionSquare { float: left; width: 2em; height: 1em; margin-right: 0.5em }
caption { width: 60em; text-align: left }
table { text-align: center; font-family: FreeSerif, FreeSans }
td { padding: 10px }
small { font-size: small }
#characterCols { border-left: medium double black; border-right: medium double black }
.nextVersion { background-color: #CCFF99 }
.furtherFuture { background-color: #FFFFCC }
.name { width: 10em }
.ch { vertical-align: baseline; line-height: 75%; font-size: 250%; direction: rtl }
.empty { background:#EEEEEE }
</style>
</head>
<body>
<h1>$title</h1>
<p>Choose the font to test: <select onchange="changefont(this)"><option>FreeSerif</option><option>FreeSerif, bold</option><option>FreeSans</option><option>FreeMono</option></select></p>
<script type="text/javascript">//<![CDATA[
function changefont(select) {
	var font = select.options.item(select.selectedIndex).value.split(', ');
	var bold = font.length > 1 ? font[1] == 'bold' : false;
	font = font[0];
	var elementsToStyle = document.getElementsByClassName("ch");
	
	for (i = 0; i < elementsToStyle.length; i++) {
		elementsToStyle[i].style.fontFamily = font;
		elementsToStyle[i].style.fontWeight = bold ? 'bold' : 'normal';
	}
}//]]></script>''')

caption='''<caption><span class="captionSquare nextVersion">&nbsp;</span> New characters in Unicode 6.1, which will be published in February 2012.
These can be relied upon and will not change or be removed. See <a href="http://www.unicode.org/Public/6.1.0/charts/blocks//U08A0.pdf">the
Unicode chart for the new block <b>Arabic Extended-A</b></a>, and for more about these characters, see <a href="http://std.dkuug.dk/JTC1/SC2/WG2/docs/n3734.pdf">N3734</a>
for U+0604, <a href="http://std.dkuug.dk/JTC1/SC2/WG2/docs/n3882.pdf">the complete
proposal</a> for most characters, <a href="http://std.dkuug.dk/JTC1/SC2/WG2/docs/n3791.pdf">N3791</a> for U+08F0-U+08F3.<br/>
<span class="captionSquare furtherFuture">&nbsp;</span> Future new characters in Unicode 6.2. These can will probably be standardized this way,
but could in principle still change or be removed. See <a href="http://std.dkuug.dk/JTC1/SC2/WG2/docs/n3990.pdf">N3990, in 4.2 Orthography</a> for U+0605,
<a href="http://std.dkuug.dk/JTC1/SC2/WG2/docs/n4072.pdf">N4072 proposal</a> about U+08AD-U+08B1, and
<a href="http://std.dkuug.dk/JTC1/SC2/WG2/docs/n3989.pdf">N3989 proposal</a> about U+08FF.</caption>'''

def print_arabic_test_page():
	print(html_heading.substitute(title='Test of Joining Characters From Unicode Cursive Scripts'))

	print_table()
	print('</body>')
	print('</html>')

print_arabic_test_page()
