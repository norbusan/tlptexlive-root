#!/usr/bin/python
# -*- coding: utf-8 -*-
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
for testing arabic characters, their behavior and consistency with presentation
forms.

Runs under normal Python, version 2.7 or above.

Typical usage:
arabic_test.py "Arabic test page.html"
"""
import sys
from codecs import open
from string import Template
from io import StringIO
from unicodedata import normalize, name, unidata_version, decomposition

_module_missing_msg = """Please run
	generate_arabic_shaping.py
to generate
	arabic_shaping.py"""

try:
	from arabic_shaping import joining_type
except:
	print( _module_missing_msg, file=sys.stderr)
	sys.exit( 1 )

if len(sys.argv) > 1:
	outfile = sys.argv[1]
else:
	outfile = 'Arabic test page.html'

sys.stdout = open(outfile, 'w', 'utf-8')

def uniname(char):
	return name(char, new_names.get(char, "&lt;reserved-{:04X}&gt;".format(ord(char))))

def non_positional_name(char):
	return uniname(char).replace(' INITIAL','').replace(' FINAL','').replace(' MEDIAL','').replace(' ISOLATED','').replace(' FORM','')

arabic_ranges = list(range(0x600, 0x61B + 1))
arabic_ranges.extend(range(0x61E, 0x6FF + 1))
arabic_ranges.extend(range(0x750, 0x77F + 1))
arabic_ranges.extend(range(0x8A0, 0x8B1 + 1))
arabic_ranges.extend(range(0x8E4, 0x8FF + 1))
arabic_ranges.extend(range(0xFB50, 0xFBC1 + 1))
arabic_ranges.extend(range(0xFBD3, 0xFD3F + 1))
arabic_ranges.extend(range(0xFD50, 0xFD8F + 1))
arabic_ranges.extend(range(0xFD92, 0xFDC7 + 1))
arabic_ranges.extend(range(0xFDF0, 0xFDFD + 1))
arabic_ranges.extend(range(0xFE70, 0xFE74 + 1))
arabic_ranges.extend(range(0xFE76, 0xFEFC + 1))

unicode61_new_ranges = [0x604, 0x8A0]
unicode61_new_ranges.extend(range(0x8A2, 0x8AC + 1))
unicode61_new_ranges.extend(range(0x8E4, 0x8FE + 1))
unicode62_new_ranges = [0x605, 0x8A1]
unicode62_new_ranges.extend(range(0x8AD, 0x8B1 + 1))
unicode62_new_ranges.append(0x8FF)
new_names = {}
new_names['\u0604'] = 'ARABIC SIGN SAMVAT'
new_names['\u0605'] = 'ARABIC NUMBER MARK ABOVE'
new_names['\u08A0'] = 'ARABIC LETTER BEH WITH SMALL V BELOW'
new_names['\u08A1'] = 'ARABIC LETTER BEH WITH HAMZA ABOVE'
new_names['\u08A2'] = 'ARABIC LETTER JEEM WITH TWO DOTS ABOVE'
new_names['\u08A3'] = 'ARABIC LETTER TAH WITH TWO DOTS ABOVE'
new_names['\u08A4'] = 'ARABIC LETTER FEH WITH DOT BELOW AND THREE DOTS ABOVE'
new_names['\u08A5'] = 'ARABIC LETTER QAF WITH DOT BELOW'
new_names['\u08A6'] = 'ARABIC LETTER LAM WITH DOUBLE BAR'
new_names['\u08A7'] = 'ARABIC LETTER MEEM WITH THREE DOTS ABOVE'
new_names['\u08A8'] = 'ARABIC LETTER YEH WITH TWO DOTS BELOW AND HAMZA ABOVE'
new_names['\u08A9'] = 'ARABIC LETTER YEH WITH TWO DOTS BELOW AND DOT ABOVE'
new_names['\u08AA'] = 'ARABIC LETTER REH WITH LOOP'
new_names['\u08AB'] = 'ARABIC LETTER WAW WITH DOT WITHIN'
new_names['\u08AC'] = 'ARABIC LETTER ROHINGYA YEH'
new_names['\u08E4'] = 'ARABIC CURLY FATHA'
new_names['\u08E5'] = 'ARABIC CURLY DAMMA'
new_names['\u08E6'] = 'ARABIC CURLY KASRA'
new_names['\u08E7'] = 'ARABIC CURLY FATHATAN'
new_names['\u08E8'] = 'ARABIC CURLY DAMMATAN'
new_names['\u08E9'] = 'ARABIC CURLY KASRATAN'
new_names['\u08EA'] = 'ARABIC TONE ONE DOT ABOVE'
new_names['\u08EB'] = 'ARABIC TONE TWO DOTS ABOVE'
new_names['\u08EC'] = 'ARABIC TONE LOOP ABOVE'
new_names['\u08ED'] = 'ARABIC TONE ONE DOT BELOW'
new_names['\u08EE'] = 'ARABIC TONE TWO DOTS BELOW'
new_names['\u08EF'] = 'ARABIC TONE LOOP BELOW'
new_names['\u08F0'] = 'ARABIC OPEN FATHATAN'
new_names['\u08F1'] = 'ARABIC OPEN DAMMATAN'
new_names['\u08F2'] = 'ARABIC OPEN KASRATAN'
new_names['\u08F3'] = 'ARABIC SMALL HIGH WAW'
new_names['\u08F4'] = 'ARABIC FATHA WITH RING'
new_names['\u08F5'] = 'ARABIC FATHA WITH DOT ABOVE'
new_names['\u08F6'] = 'ARABIC KASRA WITH DOT BELOW'
new_names['\u08F7'] = 'ARABIC LEFT ARROWHEAD ABOVE'
new_names['\u08F8'] = 'ARABIC RIGHT ARROWHEAD ABOVE'
new_names['\u08F9'] = 'ARABIC LEFT ARROWHEAD BELOW'
new_names['\u08FA'] = 'ARABIC RIGHT ARROWHEAD BELOW'
new_names['\u08FB'] = 'ARABIC DOUBLE RIGHT ARROWHEAD ABOVE'
new_names['\u08FC'] = 'ARABIC DOUBLE RIGHT ARROWHEAD ABOVE WITH DOT'
new_names['\u08FD'] = 'ARABIC RIGHT ARROWHEAD ABOVE WITH DOT'
new_names['\u08FE'] = 'ARABIC DAMMA WITH DOT'
new_names['\u08AD'] = 'ARABIC LETTER LOW ALEF'
new_names['\u08AE'] = 'ARABIC LETTER DAL WITH THREE DOTS BELOW'
new_names['\u08AF'] = 'ARABIC LETTER SAD WITH THREE DOTS BELOW'
new_names['\u08B0'] = 'ARABIC LETTER GAF WITH INVERTED STROKE'
new_names['\u08B1'] = 'ARABIC LETTER STRAIGHT WAW'
new_names['\u08FF'] = 'ARABIC MARK SIDEWAYS NOON GHUNNA'

# Unicode 6.0 additions not present in Python 2.7
new_names['\u0620'] = 'ARABIC LETTER KASHMIRI YEH'
new_names['\u065F'] = 'ARABIC WAVY HAMZA BELOW'
new_names['\uFBB2'] = 'ARABIC SYMBOL DOT ABOVE'
new_names['\uFBB3'] = 'ARABIC SYMBOL DOT BELOW'
new_names['\uFBB4'] = 'ARABIC SYMBOL TWO DOTS ABOVE'
new_names['\uFBB5'] = 'ARABIC SYMBOL TWO DOTS BELOW'
new_names['\uFBB6'] = 'ARABIC SYMBOL THREE DOTS ABOVE'
new_names['\uFBB7'] = 'ARABIC SYMBOL THREE DOTS BELOW'
new_names['\uFBB8'] = 'ARABIC SYMBOL THREE DOTS POINTING DOWNWARDS ABOVE'
new_names['\uFBB9'] = 'ARABIC SYMBOL THREE DOTS POINTING DOWNWARDS BELOW'
new_names['\uFBBA'] = 'ARABIC SYMBOL FOUR DOTS ABOVE'
new_names['\uFBBB'] = 'ARABIC SYMBOL FOUR DOTS BELOW'
new_names['\uFBBC'] = 'ARABIC SYMBOL DOUBLE VERTICAL BAR BELOW'
new_names['\uFBBD'] = 'ARABIC SYMBOL TWO DOTS VERTICALLY ABOVE'
new_names['\uFBBE'] = 'ARABIC SYMBOL TWO DOTS VERTICALLY BELOW'
new_names['\uFBBF'] = 'ARABIC SYMBOL RING'
new_names['\uFBC0'] = 'ARABIC SYMBOL SMALL TAH ABOVE'
new_names['\uFBC1'] = 'ARABIC SYMBOL SMALL TAH BELOW'

'''Class Equiv stores the correspondence between a code point and its NFKC-normalized equivalent,
for usual characters it is the character itself, for decomposable characters it is the compatibility
decompostion.'''
class Equiv:
	code_point = 0
	compat = 0
	def __init__(self, code_point, compat):
		self.code_point = code_point
		self.compat = compat
	def sort_key(self):
		return '{:02X}'.format(len(self.compat.lstrip(' '))) + self.compat.lstrip(' ')
	def __repr__(self):
		return 'Equiv(0x{:04X}, compat={})'.format(self.code_point, self.compat)

equivs = []
for cp in arabic_ranges:
	normalized = normalize('NFKC', unichr(cp))
	equivs.append(Equiv(cp, normalized))
# Sort our characters by length of the decomposition and by decomposition itself
equivs.sort(key=Equiv.sort_key)
#for e in equivs:
#	print(e, file=sys.stderr)

contextual_form_formats = { 'isolat':'{}', 'final>':'&zwj;{}', 'medial':'&zwj;{}&zwj;', 'initia':'{}&zwj;' }
contextual_forms = 'isolat', 'final>', 'medial', 'initia'
current_line = {}
equiv = None
char = None
def store_contextual_form():
	# print('store_contextual_form', equiv, file=sys.stderr)
	compat_disp = equiv.compat
	if equiv.compat[0] == ' ': compat_disp = '\u00A0' + compat_disp[1:]
	#nonlocal current_line
	form_cells = StringIO()
	form = decomposition(char)[1:7]
	print('<td class="ch">{}{}</td>'.format(contextual_form_formats.get(form, '{}').format(compat_disp),
		'<small><br/>{}</small>'.format(ord_mul(compat_disp)) if len(compat_disp) >=2 else ''), file=form_cells)
	print('<td class="ch">{}<small><br />{:04X}</small></td>'.format(char, equiv.code_point), file=form_cells)
	#if current_line.get(form, 'not found') != 'not found': print('collision', current_line[form].rstrip(), equiv, file=stderr)
	current_line[form] = form_cells.getvalue()
	form_cells.close()
		
table_head = '''
<table frame="box" rules="rows">
{}
<colgroup><col/><col/></colgroup>
<colgroup id="characterCols"><col span="2"/><col span="2"/><col span="2"/><col span="2"/></colgroup>
<tr>
<th rowspan="2">General<br />Unicode</th>
<th rowspan="2">Name</th>
<th colspan="8">Contextual Forms</th>
</tr>
<tr><th>Isolated</th><th>Isolated (compat)</th><th>Final</th><th>Final (compat)</th>
<th>Medial</th><th>Medial (compat)</th><th>Initial</th><th>Initial (compat)</th></tr>'''

def print_table():
	global current_line, char
	def end_line():
		for form in contextual_forms:
			print(current_line.get(form, '<td colspan="2"></td>').rstrip())
		print('</tr>')
		current_line.clear()
	def print_equiv(equiv):
		# print('print_equiv', equiv, file=sys.stderr)
		cp = equiv.code_point
		char = unichr(cp)
		print('<tr{}><td>{}</td>'.format(' class="nextVersion"' if cp in unicode61_new_ranges else ' class="furtherFuture"' if cp in unicode62_new_ranges else '',
			'compat' if len(equiv.compat.replace(' ', '')) > 1 else '{:04X}'.format(ord(equiv.compat.lstrip()[0]))))
		print('<td>{}</td>'.format(non_positional_name(char)))
		if equiv.compat.replace(' ', '') == char: # character is not a decomposable character, or is a standalone combining mark (decomposable to space + combining mark)
			i = 0
			for form in contextual_forms:
				print('<td class="ch">{}</td><td></td>'.format(contextual_form_formats[form].format(char)))
				i += 1
				if { 'T':'isolat', 'U':'isolat', 'C':'isolat', 'R':'final>', 'D':'' }[joining_type(cp)] == form:
					break
			if i < 4:
				print('<td colspan="{}"></td>'.format((4 - i) * 2))
			print('</tr>')
		else:
			end_line()

	print(table_head.format(caption))
	last_equiv = None
	global equiv
	for equiv in equivs:
		char = unichr(equiv.code_point)

		if last_equiv:
			#special case FC03 because there is one set of plain YEH WITH HAMZA ABOVE WITH ALEF MAKSURA and one of 'uighur kirghiz' compatibility ligatures
			if equiv.compat.lstrip() == last_equiv.compat.lstrip() and equiv.code_point != 0xFC03:
				store_contextual_form()
			else:
				print_equiv(last_equiv)
				if equiv.compat != char:
					store_contextual_form()
		last_equiv = equiv
	print_equiv(last_equiv)
	print('</table>')

def ord_mul(s):
	code_points = ''
	for c in s:
		code_points += '{:X} '.format(ord(c))
	return code_points[:-1]

html_heading = Template('''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
<title>$title</title>
<style type="text/css">
.captionSquare { float: left; width: 2em; height: 1em; margin-right: 0.5em }
caption { width: 60em; text-align: left }
table { text-align: center; font-family: FreeSerif }
td { padding: 10px }
small { font-size: small }
#characterCols { border-left: medium double black; border-right: medium double black }
.nextVersion { background-color: #CCFF99 }
.furtherFuture { background-color: #FFFFCC }
.name { width: 10em }
.ch { vertical-align: baseline; line-height: 75%; font-size: 250%; width: 1em; direction: rtl }
.empty { background:#EEEEEE }
</style>
</head>
<body>
<h1>$title</h1>
<p>Choose the font to test: <select onchange="changefont(this)"><option>FreeSerif</option><option>FreeSerif, bold</option><option>FreeMono</option></select></p>
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
	print(html_heading.substitute(title='Test for Unicode Arabic range'))
	print_table()
	print('</body>')
	print('</html>')

print_arabic_test_page()
