#!/usr/bin/python
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
__copyright__ = "Copyright 2009, 2010, 2011, Stevan White"
__date__ = "$Date:: 2013-04-09 12:44:41 +0200#$"
__version__ = "$Revision: 1.9 $"
__doc__ = """
Makes an HTML table showing how many glyphs are in each range in each font,
and tries to collate that with the OS/2 character range support bit flags.

Runs under FontForge.
	fontforge -script ranges.py

This is a hack--in no way authoritative.  
Lots of guesswork; much is wrong; the coding is gross.

See
http://www.w3.org/TR/REC-CSS2/notes.html
http://shlimazl.nm.ru/eng/fonts_ttf.htm
http://www.evertype.com/standards/iso10646/ucs-collections.html

The intervals are partly just the assigned interval, but often I have
listed the ranges that have characters assigned to them.
"""

import fontforge
from sys import stderr
from time import tzset, strftime
from OpenType.UnicodeRanges import *

def total_intervals( intervals ):
	num = 0
	for i in intervals:
		num += i.len()
	return num

def count_glyphs_in_intervals( font, intervals ):
	num = 0
	for r in intervals:
		if r.begin < len( font ) and r.end < len( font ):
			# select() will throw up if try to select value 
			# beyond the range of the encoding
			try: 
				font.selection.select( ( 'ranges', None ),
					r.begin, r.end )
				g = font.selection.byGlyphs
				for e in g:
					num += 1
			except ValueError:
				print >> stderr, "interval " + str( r ) \
				+ " not representable in " + font.fontname
				exit( 1 )
	return num

special_TT_points = ( 0x00, 0x01, 0x0D )

def codepointIsSpecialTT( encoding ):
	""" See Recommendations for OpenType Fonts
	http://www.microsoft.com/typography/otspec/recom.htm """
	return encoding in special_TT_points

class SupportInfo:
	def __init__( self, os2bit, supports, total ):
		self.os2bit = os2bit
		self.supports = supports
		self.total = total

class FontSupport:
	""" A record of support for all OS/2 ranges within a single font.
	    Uses a dictionary internally, to avoid loss of the index info.
	"""
	def __init__( self, fontPath, short ):
		font = fontforge.open( fontPath )
		self.name = font.fontname
		self.short = short
		self.myInfos = {}
		self.totalGlyphs = 0
		self.fontTotalGlyphs = 0
		self.privateUseGlyphs = 0

		r = font.os2_unicoderanges

		# print >> stderr, font.fontname, hex( r[0] ), hex( r[1] ),hex( r[2] ),hex( r[3] );

		nRanges = len( ulUnicodeRange )

		for index in range( 0, nRanges ):
			byte = index / 32
			bit = index % 32

			self.collectRangeInfo( font, r[byte], bit, index )

		for g in font.glyphs():
			self.fontTotalGlyphs += 1
			cp = g.encoding
			if ( not codepointIsInSomeRange( cp )
				and not codepointIsSpecialTT( cp ) ):
				print >> stderr, font.fontname, \
					"no range for", hex( cp )

		""" '''Would like to check that special TT slots are
		present, but don't know how...'''
		for cp in special_TT_points:
			font.selection.all()
			if not cp in font.selection.byGlyphs:
				print >> stderr, font.fontname, \
					"special TT glyph missing", hex( cp )
		"""

	def collectRangeInfo( self, font, os2supportbyte, bit, index ):
		supports = ( os2supportbyte & (1 << bit) ) != 0
		rangeName = ulUnicodeRange[index][1]
		intervals = ulUnicodeRange[index][2]
		nglyphs = count_glyphs_in_intervals( font, intervals )
		self.setRangeSupport( index, supports, nglyphs )
		self.totalGlyphs += nglyphs
		if index == 60 or index == 90:
			self.privateUseGlyphs += nglyphs 

	def setRangeSupport( self, idx, supports, total ):
		if self.myInfos.has_key( idx ):
			print >> stderr, "OS/2 index ", idx, " duplicated"
			exit( 1 )
		self.myInfos[idx] = SupportInfo( idx, supports, total )

	def getInfo( self, idx ):
		if not self.myInfos.has_key( idx ):
			print >> stderr, "OS/2 index ", idx, " not found"
			exit( 1 )
		return self.myInfos[ idx ]

table_head = '''
<table class="fontrangereport" cellspacing="0" cellpadding="0" frame="box" rules="all">
<caption>
OS/2 character ranges vs. font faces
</caption>
<colgroup>
<col /><col /><col />
</colgroup>
<colgroup>
<col class="roman"/><col /><col /><col />
<col /><col /><col /><col />
</colgroup>
<colgroup>
<col class="roman"/><col /><col /><col />
<col /><col /><col /><col />
</colgroup>
<colgroup>
<col class="roman"/><col /><col /><col />
<col /><col /><col /><col />
</colgroup>
<thead>
<tr><th>OS/2 character range</th>
<th>range<br />total</th>
<td></td>
%s
</tr>
</thead>'''

def print_font_range_table( fontSupportList ):
	headings = ''
	for fsl in fontSupportList:
		headings += '<th colspan="2">' + fsl.short + '</th>' 
	print table_head % ( headings )

	for r in ulUnicodeRange:
		idx = r[0]
		range_name = r[1]
		intervals = r[2]

		rowclass = ' class="low"'
		if idx > 122:
				rowclass = ' class="other"'
		else:
			if len( ulUnicodeRange[idx] ) > 3 and ulUnicodeRange[ idx ][3]:
				rowclass = ' class="high"'
			if idx == 60 or idx == 90:
				rowclass = ' class="private"'
			
		print '<tr%s><td>%s</td>' % ( rowclass, range_name )
		print '<td class="num">%i</td>' % (
				total_intervals( intervals ) )
		print '<td></td>' 
		for fsl in fontSupportList:
			supportInfo = fsl.getInfo( idx )
			supportString = ''
			if supportInfo.supports:
				supportString = '&bull;'
			totalStr = '&nbsp;'
			if supportInfo.total:
				totalStr = str( supportInfo.total )

			print '<td class="num">%s</td><td>%s</td>' % (
					totalStr, supportString )

		print '</tr>'
	print '<tr><th colspan="3">total in Unicode ranges</th>' 
	for fsl in fontSupportList:
		print '<td class="num" colspan="2">%i&nbsp;</td>' % (
					fsl.totalGlyphs )
	print '</tr>'
	print '<tr><th colspan="3">total in font</th>' 
	for fsl in fontSupportList:
		print '<td class="num" colspan="2">%i&nbsp;</td>' % (
					fsl.fontTotalGlyphs )
	print '</tr>'
	print '<tr><th colspan="3">total in Private Use</th>' 
	for fsl in fontSupportList:
		print '<td class="num" colspan="2">%i&nbsp;</td>' % (
					fsl.privateUseGlyphs )
	print '</tr>'
	# Would also like to total glyphs in ranges for each font,
	# and also print total glyphs in each font.
	print '</table>'

table_introduction = """
For historical reasons, TrueType classifies Unicode ranges according to
an extension of the old OS/2 character ranges.  This table shows how many
characters FontForge finds in each of the ranges for each face in the family.
"""

table_explanation = """
<p>
Ranges for which (FontForge reports that) the font's OS/2 support
bit is set are marked with a bullet.
</p>
<p>
For many ranges, I took the liberty of reducing the set of characters
considered to those listed for the range in the current Unicode charts.
The number of characters supported can thus be less than the width of the range.
</p>
<p>
The totals include glyphs in the Private Use areas (where there
are many ligatures, alternative forms, and glyph components).  The glyphs
in these areas do not correspond to Unicode characters.
</p>
<p>
Three control characters are inserted at 0x00, 0x01 and 0x0d to satisfy the
TrueType recommendations.  These are counted under Basic Latin, but other
control characters there are not counted.
</p>
<p>
Note that there is a discrepancy in the Greek Symbols, Hebrew Extended and
Arabic Extended ranges, between what FontForge reports here and in its Font
Info window under OS/2 Character Ranges. I don't know why, but these ranges
are also not well defined in the TrueType standard.
</p>
<p>
Note the two characters from Devanagri.  These are the danda and double-danda
used by other Indic scripts.
</p>
<p>
The ranges <span style="color: #555">beyond Unicode point 0xFFFF</span>, are
shaded.  </p>
"""

html_heading = '''
<html>
<head>
<title>
GNU FreeFont character range support
</title>
<style type="text/css">
	tr.high { color: #555 }
	tr.private { background-color: silver; }
	tr.other { background-color: #CCF; }
	td.num { text-align: right }
	td { padding-right: 0.25ex }
	th { padding: 0.25ex }
	.roman { border-left: medium black solid; }
	caption { font-size: larger; font-weight: bold; }
</style>
</head>
'''

def print_font_range_report( fontSupportList ):
	print html_heading

	print '<body>'
	print '<h1>'
	print 'GNU FreeFont support for OpenType OS/2 character ranges'
	print '</h1>'
	print '<p>'
	print table_introduction
	print '</p>'
	print_font_range_table( fontSupportList )
	print '<p>'
	print table_explanation
	tzset()
	print 'Generated by <code>range_report.py</code> on %s.' % (
			strftime('%X %x %Z') )
	print '</p>'
	print '</body>'

	print '</html>'

supportList = []
supportList.append( FontSupport( '../../sfd/FreeSerif.sfd', 'Srf' ) )
supportList.append( FontSupport( '../../sfd/FreeSerifItalic.sfd', 'Srf I' ) )
supportList.append( FontSupport( '../../sfd/FreeSerifBold.sfd', 'Srf B' ) )
supportList.append( FontSupport( '../../sfd/FreeSerifBoldItalic.sfd', 'Srf BI' ) )
supportList.append( FontSupport( '../../sfd/FreeSans.sfd', 'Sans' ) )
supportList.append( FontSupport( '../../sfd/FreeSansOblique.sfd', 'Sans O' ) )
supportList.append( FontSupport( '../../sfd/FreeSansBold.sfd', 'Sans B' ) )
supportList.append( FontSupport( '../../sfd/FreeSansBoldOblique.sfd', 'Sans BO' ) )
supportList.append( FontSupport( '../../sfd/FreeMono.sfd', 'Mono' ) )
supportList.append( FontSupport( '../../sfd/FreeMonoOblique.sfd', 'Mono O' ) )
supportList.append( FontSupport( '../../sfd/FreeMonoBold.sfd', 'Mono B' ) )
supportList.append( FontSupport( '../../sfd/FreeMonoBoldOblique.sfd', 'Mono BO' ) )

print_font_range_report( supportList )
