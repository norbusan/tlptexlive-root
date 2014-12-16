#!/usr/bin/fontforge -script 

__author__ = "Stevan White <stevan.white@googlemail.com>"

import fontforge
import sys
from OpenType.UnicodeRanges import *

def get_kern_subtables( font ):
	try:
		tables = []
		for lookup in font.gpos_lookups:
			if font.getLookupInfo( lookup )[0] == 'gpos_pair':
				sts = font.getLookupSubtables( lookup )
				for st in sts:
					if font.isKerningClass( st ):
						tables.append( st )
		return tables
	except EnvironmentError, ( e ):
		print >> sys.stderr, 'EnvironmentError ' + str( e )
	except TypeError, ( t ):
		print >> sys.stderr, 'TypeError ' + str( t )
	return None
preamble = """
<html>
<head>
<style type="text/css">
	.nonexistent { background-color: red; }
	td { text-align: right; font-family: inherit; }
	.I td { font-style: italic; }
	.B td { font-weight: bold; }
	.BI td { font-weight: bold; font-style: italic; }
	td { line-height: 1; }
	.classes td { text-align: left; vertical-align: top; }
	td span { font-weight: normal; font-style: normal; font-size: smaller; color: lime; }
	td span.pos { color: magenta; }
	td.zero { color: gray; }
</style>
</head>
<body>
"""
postamble="""
</body>
</html>
"""

def print_kerns( fontPath ):
	font = fontforge.open( fontPath )
	print  '<h2>Kerning classes in  ' + font.fontname + '</h2>'
	weight = ''
	if font.os2_weight > 500:
		weight = 'B'
	style = ''
	if font.italicangle < 0.0:
		style = 'I'
	print  '<div  style="font-family: ' + font.familyname + '" '  \
		+ 'class="' + weight + style + '">'
	subtables = get_kern_subtables( font )
	for st in subtables:
		print  '<h3>Subtable ' + st + '</h3>'
		printKernsOfSubtable( font, st )
	print  '</div>'
	sys.stdout.flush()

def printKernsOfSubtable( font, subtable ):
	kclass = font.getKerningClass( subtable )
	n = 0
	leftclasses = kclass[0]
	rightclasses = kclass[1]
	kerns = kclass[2]
	nr = len( rightclasses )
	print '<table class="classes"><tr>'
	print '<th>left classes: </th>'
	print '<th>right classes: </th>'
	print '<tr><td>'
	for lc in leftclasses:
		if lc:
			for c in lc:
				printentity( font, c )
		print "<br />"
	print "</td>"
	print "<td>"
	for rc in rightclasses:
		if rc:
			for c in rc:
				printentity( font, c )
		print "<br />"
	print "</td>"
	print "</tr>"
	print "</table>"
	print "<table>"
	print "<tr>"
	print "<th></th>"
	for rc in rightclasses:
		if rc:
			sys.stdout.write( "<th>" )
			printentity( font, rc[0] )
			sys.stdout.write( "</th>" )
	print "</tr>"
	for lc in leftclasses:
		m = 0
		if lc:
			print "<tr>"
			sys.stdout.write( "<th>" )
			printentity( font, lc[0] )
			sys.stdout.write( "</th>" )
			for rc in rightclasses:
				kern = kerns[ n * nr + m ]
				if rc:
					ccolor = ''
					ncolor = ''
					if kern > 0:
						ncolor = ' class="pos"'
					if kern == 0:
						ccolor = ' class="zero"'
					sys.stdout.write( '<td' + ccolor + '><span' + ncolor + '>' )
					if kern == 0:
						sys.stdout.write( '&nbsp;' )
					else:
						sys.stdout.write( str( kern ) )
					sys.stdout.write( '</span><br />' )
					printpair( font, lc[0], rc[0] )
					sys.stdout.write( '</td>' )
				m += 1
			print "</tr>"
		n += 1
	print "</table>"

def printentity( font, a ):
	s = font.findEncodingSlot( a )
	v = formatted_hex_value( s )
	if s == -1:
		v = '<span class="nonexistent">&nbsp;</span>'
		print >> sys.stderr, font.fullname, 'Missing glyph: ' + a
	elif not codepointIsInSomeRange( s ):
		print >> sys.stderr, font.fullname, 'Non-unicode: ' + v
	sys.stdout.write( v )

def printpair( font, p, q ):
	printentity( font, p )
	printentity( font, q )
	sys.stdout.write( ' ' )

def formatted_hex_value( n ):
	return '%s%0.4x%s' %( "&#x", n, ";" )

def printlist( lst ):
	s = ''
	delim = ''
	for m in lst:
		s += delim + m
		delim = ' '
	print s

print preamble
#print_kerns( '/home/swhite/font_stuff/urwsr-ttf/URWPalladioL-Roman-test.sfd' )
print_kerns( '../../sfd/FreeSerif.sfd' )
print_kerns( '../../sfd/FreeSerifItalic.sfd' )
print_kerns( '../../sfd/FreeSerifBold.sfd' )
print_kerns( '../../sfd/FreeSerifBoldItalic.sfd' )
print_kerns( '../../sfd/FreeSans.sfd' )
print_kerns( '../../sfd/FreeSansOblique.sfd' )
print_kerns( '../../sfd/FreeSansBold.sfd' )
print_kerns( '../../sfd/FreeSansBoldOblique.sfd' )
print_kerns( '../../sfd/FreeMono.sfd' )
print_kerns( '../../sfd/FreeMonoOblique.sfd' )
print_kerns( '../../sfd/FreeMonoBold.sfd' )
print_kerns( '../../sfd/FreeMonoBoldOblique.sfd' )
print postamble
