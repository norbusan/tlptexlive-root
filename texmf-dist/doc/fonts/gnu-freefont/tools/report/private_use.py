#!/usr/bin/env ../utility/fontforge-interp.sh

__doc__ = """
private_use.py

	fontforge -script private_use.py font_file_path...

Output is HTML showing all the font's glyphs that are in Unicode "Private Use"
areas.
Also reports whether glyphs have references, or if they are ligatures.
"""
__author__ = "Stevan White <stevan.white@googlemail.com>"
__date__ = "Dec 2009"
__version__ = "$Revision: 1.2 $"

import fontforge
import sys


preamble = """<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Private Use area</title>
<style type="text/css">
	.nonchar { background-color: red; }
	table, tr, td { font-family: inherit; }
	table, tr, td { font-style: inherit; }
	table, tr, td { font-weight: inherit; }
	td { text-align: right; }
	td { line-height: 1; }
	.ligatures td { width: 2em; }
	.ligatures th { text-align: left; font-family: freemono, monospace; }
</style>
</head>
<body>
"""

def makePreamble():
	return preamble

postamble="""
</body>
</html>
"""

def print_private( fontPath ):
	font = fontforge.open( fontPath )

	print  '<div style="font-family: \'' + font.familyname + '\'; ' \
			 '\">'
	print  '<h2>Private Use Area in  ' + font.fontname + '</h2>'

	font.selection.select(("ranges",None),0xe000,0xf8ff)
	print  '<table>'
	for g in font.selection.byGlyphs:
		print  '<tr><td>'
		print '%s%0.4x%s' %( "0x", g.encoding, "" )
		print  '</td><td>'
		print  '' + g.glyphname
		print  '</td><td>'
		if g.getPosSub( '*' ):
			print "is ligature"
		if g.references:
			print "has references"
		print  '</td><td>'
		print  '</td></tr>'
		
	print  '</table>'
	print  '</div>'
	sys.stdout.flush()

def printentity( font, s ):
	if s == -1:
		print >> sys.stderr, 'Missing glyph: ' + a
		sys.stdout.write( '<span class="nonchar">&nbsp;</span>' )
	else:
		sys.stdout.write( formatted_hex_value( s ) )

def formatted_hex_value( n ):
	return '%s%0.4x%s' %( "&#x", n, ";" )

args = sys.argv[1:]

if len( args ) < 1 or len( args[0].strip() ) == 0:
	sys.exit( 0 )

print makePreamble()
for font_name in args:
	print_private( font_name )
print postamble
