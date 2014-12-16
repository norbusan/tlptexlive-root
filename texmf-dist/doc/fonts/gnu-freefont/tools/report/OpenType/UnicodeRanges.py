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
__copyright__ = "Copyright 2009, 2010, 2011, 2012, Stevan White"
__date__ = "$Date:: 2014-10-20 07:05:35 +0900#$"
__version__ = "$Revision: 2997 $"

__doc__ = """
Encodes the correspondence between Unicode code intervals
and the script support field 'ulUnicodeRange' of OpenType fonts.

A Unicode script range, such as Greek, is not an unbroken list of 
characters, but rather several "intervals" of defined characters,
broken by undefined or reserved character slots.

OpenType contains an attempt to report whether a given font supports
a certain range of Unicode, e.g. Greek or Kanji.  This was done using
a bit mask, with (roughly) one bit for each range.

This is complicated by:
	1) some ranges overlap, or have other interactions
		A) Greek and Coptic are not completely distinct
		B) Accent ranges are often used by several scripts
		C) FontForge has the occasional bug in its internal
		notion of Unicode ranges
	2) What is meant by "support"?  Is it enough to have a single
	glyph in a range, to say it is supported?
	3) both Unicode and OpenType are in a state of flux

See 

Roadmap tf the BMP
http://www.unicode.org/roadmaps/bmp/

The intervals are partly just the assigned interval, but often I have
listed the ranges that have characters assigned to them.

OpenType standard: OS/2 and Windows Metrics
http://www.microsoft.com/typography/otspec/os2.htm

Apple Developer: The TrueType Font File
http://developer.apple.com/fonts/TTRefMan/RM06/Chap6.html
Says 128 bits are split into 96 and 32 bits.
96 is Unicode block, 32 for script sets...

Cascading Style Sheets Level 2 Revision 1 (CSS 2.1) Specification
http://www.w3.org/TR/CSS2/
"""

class interval:
	def __init__( self, begin, end ):
		self.begin = begin
		self.end = end

	def len( self ):
		return 1 + self.end - self.begin

	def __str__( self ):
		return '[' + str( self.begin ) + ',' + str( self.end ) + ']'

	def contains( self, val ):
		return val <= self.end and val >= self.begin

# NOTE the OpenType spec is much more thorough
ulUnicodeRange = [
[0,	'Basic Latin', [interval(0,1),	# Nul character, mapped to notdef
					# and .nul; required by TrueType
			interval(0x0d, 0x0d),	# non-marking return
	interval(0x20, 0x7E)] ],	# Latin range
[1,	'Latin-1 Supplement',[interval(0xA0, 0xFF)] ],
[2,	'Latin Extended-A',	[interval(0x0100, 0x017F)] ],
[3,	'Latin Extended-B',     [interval(0x0180, 0x024F)]],
[4,	'IPA and Phonetic Extensions',     [interval(0x0250, 0x02AF),
			interval(0x1D00, 0x1D7F),	# Phonetic Extensions
			interval(0x1D80, 0x1DBF)	# Phonetic Extensions S.
	]],
[5,	'Spacing Modifier Letters',     [interval(0x02B0, 0x02FF),
			interval(0xA700, 0xA71F)	# Modifier Tone Letters
	]],
[6,	'Combining Diacritical Marks (+suppl.)',     [interval(0x0300, 0x036F),
			interval(0x1DC0, 0x1DF5),	# Supplement
			interval(0x1DFC, 0x1DFF)	# Supplement
			] ],
[7,	'Greek and Coptic',     [interval(0x0370, 0x0377),
			interval(0x037A, 0x037F),
			interval(0x0384, 0x038A),
			interval(0x038C, 0x038C),
			interval(0x038E, 0x03A1),
			interval(0x03A3, 0x03FF)
			] ],
[8,	'Coptic',     [interval(0x2C80, 0x2CF3),
			interval(0x2CF9, 0x2CFF)
		] ],
[9,	'Cyrillic (+suppl., +ext.-A, -B)',     [
	interval(0x0400, 0x04FF),	# Cyrillic
	interval(0x0500, 0x052F),	# Cyrillic Supplement
	interval(0x2DE0, 0x2DFF),	# Cyrillic Extended-A
	interval(0xA640, 0xA69D),	# Cyrillic Extended-B
	interval(0xA69F, 0xA69F)
	]
	],
[10,	'Armenian',     [interval(0x0531, 0x0556),
			interval(0x0559, 0x055F),
			interval(0x0561, 0x0587),
			interval(0x0589, 0x058A),
			interval(0x058D, 0x058F)
			]
	],
[11,	'Hebrew',    [
			interval(0x0591, 0x05C7),
			interval(0x05D0, 0x05EA),
			interval(0x05F0, 0x05F4)
			# See also Alphabetic Presentation Forms
		]],
[12,	'Vai',    [interval(0xA500, 0xA62B),
		]],
[13,	'Arabic (+suppl.)',     [interval(0x0600, 0x061C),
			interval(0x061E, 0x06FF),
			interval(0x0750, 0x077F)	# Supplement
	]
	],
[14,	"N'Ko", [interval(0x07C0, 0x07FF)]],
[15,	'Devanagari (+ext.)',     [ interval(0x0900, 0x097F),
			interval(0xA8E0, 0xA8FB),	# Extended
			interval(0x1CD0, 0x1CF6),	# Vedic Extensions
			interval(0x1CF8, 0x1CF9)
			]],
[16,	'Bengali',     [interval(0x0980, 0x0983),
		interval(0x0985, 0x098C),
		interval(0x098F, 0x0990),
		interval(0x0993, 0x09A8),
		interval(0x09AA, 0x09B0),
		interval(0x09B2, 0x09B2),
		interval(0x09B6, 0x09B9),
		interval(0x09BC, 0x09C4),
		interval(0x09C7, 0x09C8),
		interval(0x09CB, 0x09CE),
		interval(0x09D7, 0x09D7),
		interval(0x09DC, 0x09DD),
		interval(0x09DF, 0x09E3),
		interval(0x09E6, 0x09FB),
	]],
[17,	'Gurmukhi',     [interval(0x0A01, 0x0A03),
		interval(0x0A05, 0x0A0A),
		interval(0x0A0F, 0x0A10),
		interval(0x0A13, 0x0A28),
		interval(0x0A2A, 0x0A30),
		interval(0x0A32, 0x0A33),
		interval(0x0A35, 0x0A36),
		interval(0x0A38, 0x0A39),
		interval(0x0A3C, 0x0A3C),
		interval(0x0A3E, 0x0A42),
		interval(0x0A47, 0x0A48),
		interval(0x0A4B, 0x0A4D),
		interval(0x0A51, 0x0A51),
		interval(0x0A59, 0x0A5C),
		interval(0x0A5E, 0x0A5E),
		interval(0x0A66, 0x0A75),
		]],
[18,	'Gujarati',     [interval(0x0A81, 0x0A83),
		interval(0x0A85, 0x0A8D),
		interval(0x0A8F, 0x0A91),
		interval(0x0A93, 0x0AA8),
		interval(0x0AAA, 0x0AB0),
		interval(0x0AB2, 0x0AB3),
		interval(0x0AB5, 0x0AB9),
		interval(0x0ABC, 0x0AC5),
		interval(0x0AC7, 0x0AC9),
		interval(0x0ACB, 0x0ACD),
		interval(0x0AD0, 0x0AD0),
		interval(0x0AE0, 0x0AE3),
		interval(0x0AE6, 0x0AEF),
		interval(0x0AF0, 0x0AF1)
		]],
[19,	'Oriya',     [interval(0x0B01, 0x0B03),
		interval(0x0B05, 0x0B0C),
		interval(0x0B0F, 0x0B10),
		interval(0x0B13, 0x0B28),
		interval(0x0B2A, 0x0B30),
		interval(0x0B32, 0x0B33),
		interval(0x0B35, 0x0B39),
		interval(0x0B3C, 0x0B44),
		interval(0x0B47, 0x0B48),
		interval(0x0B4B, 0x0B4D),
		interval(0x0B56, 0x0B57),
		interval(0x0B5C, 0x0B5D),
		interval(0x0B5F, 0x0B63),
		interval(0x0B66, 0x0B77),
	]],
[20,	'Tamil',     [interval(0x0B82, 0x0B83),
		interval(0x0B85, 0x0B8A),
		interval(0x0B8E, 0x0B90),
		interval(0x0B92, 0x0B95),
		interval(0x0B99, 0x0B9A),
		interval(0x0B9C, 0x0B9C),
		interval(0x0B9E, 0x0B9F),
		interval(0x0BA3, 0x0BA4),
		interval(0x0BA8, 0x0BAA),
		interval(0x0BAE, 0x0BB9),
		interval(0x0BBE, 0x0BC2),
		interval(0x0BC6, 0x0BC8),
		interval(0x0BCA, 0x0BCD),
		interval(0x0BD0, 0x0BD0),
		interval(0x0BD7, 0x0BD7),
		interval(0x0BE6, 0x0BFA)
	]],
[21,	'Telugu',     [interval(0x0C01, 0x0C03),
		interval(0x0C05, 0x0C0C),
		interval(0x0C0E, 0x0C11),
		interval(0x0C12, 0x0C28),
		interval(0x0C2A, 0x0C33),
		interval(0x0C35, 0x0C39),
		interval(0x0C3d, 0x0C44),
		interval(0x0C46, 0x0C48),
		interval(0x0C4a, 0x0C4d),
		interval(0x0C55, 0x0C56),
		interval(0x0C58, 0x0C59),
		interval(0x0C60, 0x0C63),
		interval(0x0C66, 0x0C6f),
		interval(0x0C78, 0x0C7f),
			]
			],
[22,	'Kannada',     [interval(0x0C81, 0x0C83),
		interval(0x0C85, 0x0C8C),		
		interval(0x0C8E, 0x0C90),		
		interval(0x0C92, 0x0CA8),		
		interval(0x0CAA, 0x0CB3),		
		interval(0x0CB5, 0x0CB9),		
		interval(0x0CBC, 0x0CC4),		
		interval(0x0CC6, 0x0CC8),		
		interval(0x0CCA, 0x0CCD),		
		interval(0x0CD5, 0x0CD6),		
		interval(0x0CDE, 0x0CDE),		
		interval(0x0CE0, 0x0CE3),		
		interval(0x0CE6, 0x0CEF),		
		interval(0x0CF1, 0x0CF2),		
	]],
[23,	'Malayalam',     [interval(0x0D01, 0x0D03),
		interval(0x0D05, 0x0D0C),
		interval(0x0D0E, 0x0D10),
		interval(0x0D12, 0x0D3A),
		interval(0x0D3D, 0x0D44),
		interval(0x0D46, 0x0D48),
		interval(0x0D4A, 0x0D4E),
		interval(0x0D57, 0x0D57),
		interval(0x0D60, 0x0D63),
		interval(0x0D66, 0x0D75),
		interval(0x0D79, 0x0D7F),
	]],
[24,	'Thai',     [interval(0x0E01, 0x0E3A),
			interval(0x0E3F, 0x0E5B)
			]
		],
[25,	'Lao',     [interval(0x0E80, 0x0EFF)]],
[26,	'Georgian (+suppl.)',    [
		interval(0x10A0, 0x10C5),
		interval(0x10C7, 0x10C7),
		interval(0x10CD, 0x10CD),
		interval(0x10D0, 0x10FF),
		interval(0x2D00, 0x2D25) # Supplement
		]],
[27,	'Balinese', [interval(0x1B00, 0x1B7F)]],
#	'Batak', [interval(0x1BC0, 0x1BFF)]],
[28,	'Hangul Jamo',     [interval(0x1100, 0x11FF)]],
[29,	'Latin Extended (Additional,C,D)',     [
		interval(0x1E00, 0x1EFF),	# Additional
		interval(0x2C60, 0x2C7F),	# C
		interval(0xA720, 0xA78E),	# D
		interval(0xA790, 0xA7AD),	# D
		interval(0xA7B0, 0xA7B1),	# D
		interval(0xA7F7, 0xA7FF)	# D
		]],
[30,	'Greek Extended',     [interval(0x1F00, 0x1F15),
		interval(0x1F18, 0x1F1D),
		interval(0x1F20, 0x1F45),
		interval(0x1F48, 0x1F4D),
		interval(0x1F50, 0x1F57),
		interval(0x1F59, 0x1F59),
		interval(0x1F5B, 0x1F5B),
		interval(0x1F5D, 0x1F5D),
		interval(0x1F5F, 0x1F7D),
		interval(0x1F80, 0x1FB4),
		interval(0x1FB6, 0x1FC4),
		interval(0x1FC6, 0x1FD3),
		interval(0x1FD6, 0x1FDB),
		interval(0x1FDD, 0x1FEF),
		interval(0x1FF2, 0x1FF4),
		interval(0x1FF6, 0x1FFE)
	]],
[31,	'General Punctuation (+suppl.)',     [interval(0x2000, 0x2064),
		interval(0x2066, 0x2069),
		# interval(0x206A, 0x206F),	# deprecated
		interval(0x2E00, 0x2E42),	# Supplemental
	]],
[32,	'Superscripts and Subscripts',     [interval(0x2070, 0x2071),
		interval(0x2074, 0x208E),
		interval(0x2090, 0x209C)
	]
	],
[33,	'Currency Symbols',     [interval(0x20A0, 0x20BD)]],
[34,	'Combining Diacritical Marks for Symbols',     [interval(0x20D0, 0x20F0)]],
[35,	'Letterlike Symbols',     [interval(0x2100, 0x214F)]],
[36,	'Number Forms',     [interval(0x2150, 0x2189)]],
[37,	'Arrows (+suppl.)',     [interval(0x2190, 0x21FF),
	interval(0x27F0, 0x27FF),	# Supplemental Arrows-A
	interval(0x2900, 0x297F),	# Supplemental Arrows-B
	interval(0x2B00, 0x2B73),	# Miscellaneous Symbols and Arrows
	interval(0x2B76, 0x2B95),	# "
	interval(0x2B98, 0x2BB9),	# "
	interval(0x2BBD, 0x2BC8),	# "
	interval(0x2BCA, 0x2BD1)	# "
	]],
[38,	'Mathematical Operators',     [ 
	interval(0x2200, 0x22FF),
	interval(0x2A00, 0x2AFF),	# Supplemental Mathematical Operators
	interval(0x27C0, 0x27EF),	# Miscellaneous Mathematical Symbols-A
	interval(0x2980, 0x29FF)	# Miscellaneous Mathematical Symbols-B
	]
		],
[39,	'Miscellaneous Technical',     [interval(0x2300, 0x23FA)]],
[40,	'Control Pictures',     [interval(0x2400, 0x2426)]],
[41,	'Optical Character Recognition',     [interval(0x2440, 0x244A)]],
[42,	'Enclosed Alphanumerics',     [
	interval(0x2460, 0x24FF),
	interval(0x1F100, 0x1F10C),	# Supplement
	interval(0x1F110, 0x1F12E),	# Supplement
	interval(0x1F130, 0x1F16B),	# Supplement
	interval(0x1F170, 0x1F19A),	# Supplement
	interval(0x1F1E6, 0x1F1FF)	# Supplement
	]],
[43,	'Box Drawing',     [interval(0x2500, 0x257F)]],
[44,	'Block Elements',     [interval(0x2580, 0x259F)]],
[45,	'Geometric Shapes',     [interval(0x25A0, 0x25FF)]],
[46,	'Miscellaneous Symbols',     [
			interval(0x2600, 0x26FF),
			]
			],
[47,	'Dingbats',     [interval(0x2700, 0x27BF),
	]],
[48,	'CJK Symbols and Punctuation', [interval(0x3000, 0x303F)]],
[49,	'Hiragana', [interval(0x3040, 0x309F)]],
[50,	'Katakana', [interval(0x30A0, 0x30FF)]],
[51,	'Bopomofo', [interval(0x3100, 0x312F)]],
[52,	'Hangul Compatibility Jamo', [interval(0x3130, 0x318F)]],
[53,	'Kanbun', [interval(0x3190, 0x319F)]], # was CJK Miscellaneous
[54,	'Enclosed CJK Letters and Months', [interval(0x3200, 0x32FF)]],
[55,	'CJK Compatibility', [interval(0x3300, 0x33FF)]],
# 'Lisu', [interval(0xA4D0, 0xA4FF)]],
[56,	'Hangul Syallables', [interval(0xAC00, 0xD7A3)]],
[57,	'Non-Plane 0', [interval(0xD800, 0xDFFF)]],
[58,	'Phoenician', [interval(0x10900, 0x1091B), 
		interval(0x1091F, 0x1091F)], True],
[59,	'CJK Unified Ideographs', [interval(0x4E00, 0x9FFF)]], #FIXME complex
# Meetai Mayek ABC0 ABFF
[60,	'Private Use Area', [interval(0xE000, 0xF8FF)]],
[61,	'CJK Compatibility Ideographs', [interval(0xF900, 0xFAFF)]],
[62,	'Alphabetic Presentation Forms', [
			interval(0xFB00, 0xFB06),
			interval(0xFB13, 0xFB17),
			interval(0xFB1D, 0xFB36),
			interval(0xFB38, 0xFB3C),
			interval(0xFB3E, 0xFB3E),
			interval(0xFB40, 0xFB41),
			interval(0xFB43, 0xFB44),
			interval(0xFB46, 0xFB4F),
		]],
[63,	'Arabic Presentation Forms-A', [interval(0xFB50, 0xFBC1),
				interval(0xFBD3, 0xFD3F),
				interval(0xFD50, 0xFD8F),
				interval(0xFD92, 0xFDC7),
				interval(0xFDF0, 0xFDFD)
				]
		],
[64,	'Combining Half Marks', [interval(0xFE20, 0xFE2D)]],
[65,	'CJK Compatibility Forms', [interval(0xFE10, 0xFE1F),	# Vertical forms
		interval(0xFE30, 0xFE4F)	# Compatability forms
	]],
[66,	'Small Form Variants', [interval(0xFE50, 0xFE52),
				interval(0xFE54, 0xFE66),
				interval(0xFE68, 0xFE6B)
				]
		],
[67,	'Arabic Presentation Forms-B', [interval(0xFE70, 0xFE74),
				interval(0xFE76, 0xFEFC),
				interval(0xFEFF, 0xFEFF)
				]
		],
[68,	'Halfwidth and Fullwidth Forms', [interval(0xFF00, 0xFFEF)]],
[69,	'Specials', [interval(0xFFF9, 0xFFFD)]],
[70, 	'Tibetan', [interval(0x0F00, 0x0FFF)]],
[71, 	'Syriac', [interval(0x0700, 0x070D),
		interval(0x070F, 0x074A),
		interval(0x074D, 0x074F)
	]],
[72, 	'Thaana', [interval(0x0780, 0x07B1)]],
[73, 	'Sinhala', [interval(0x0D82, 0x0D83),
		interval(0x0D85, 0x0D96),
		interval(0x0D9A, 0x0DB1),
		interval(0x0DB3, 0x0DBB),
		interval(0x0DBD, 0x0DBD),
		interval(0x0DC0, 0x0DC6),
		interval(0x0DCA, 0x0DCA),
		interval(0x0DCF, 0x0DD4),
		interval(0x0DD6, 0x0DD6),
		interval(0x0DD8, 0x0DDF),
		interval(0x0DE6, 0x0DEF),
		interval(0x0DF2, 0x0DF4)]],
[74, 	'Myanmar', [interval(0x1000, 0x109F)]],
[75, 	'Ethiopic (+suppl., +ext.)', [
		interval(0x1200, 0x1248),
		interval(0x124A, 0x124D),
		interval(0x1250, 0x1256),
		interval(0x1258, 0x1258),
		interval(0x125A, 0x125D),
		interval(0x1260, 0x1288),
		interval(0x128A, 0x128D),
		interval(0x1290, 0x12B0),
		interval(0x12B2, 0x12B5),
		interval(0x12B8, 0x12BE),
		interval(0x12C0, 0x12C0),	# page 2
		interval(0x12C2, 0x12C5),
		interval(0x12C8, 0x12D6),
		interval(0x12D8, 0x1310),
		interval(0x1312, 0x1315),
		interval(0x1318, 0x135A),
		interval(0x135D, 0x137C),
		interval(0x1380, 0x139F),	# supplement
		interval(0x2D80, 0x2DDF)	# extended
		]
		],
[76,	'Cherokee', [interval(0x13A0, 0x13F4)]],
[77, 	'Unified Canadian Aboriginal Syllabics',
		[interval(0x1400, 0x167F),
		interval(0x18B0, 0x18F5)	# UCAS Extended
		]
		],
[78, 	'Ogham', [interval(0x1680, 0x169F)]],
[79, 	'Runic', [interval(0x16A0, 0x16F8)]],
[80, 	'Khmer (+symbols)', [interval(0x1780, 0x17FF),
		interval(0x19E0, 0x19FF)	# symbols
	]],
[81, 	'Mongolian', [interval(0x1800, 0x18AF)]],	#FIXME ranges
[82, 	'Braille Patterns', [interval(0x2800, 0x28FF)]],
[83, 	'Yi Syllables, Radicals', [interval(0xA000, 0xA0EF),
		interval(0xA490, 0xA4CF)]
		],
[84, 	'Tagalog Hanunoo Buhid Tagbanwa', 
		[interval(0x1700, 0x1714),
		interval(0x1720, 0x1736),
		interval(0x1740, 0x1753),
		interval(0x1750, 0x1773)
		]
		],
[85, 	'Old Italic', [interval(0x10300, 0x1031E),
			interval(0x10320, 0x10323)
	], True],
[86, 	'Gothic', [interval(0x10330, 0x1034A)], True],
[87, 	'Deseret', [interval(0x10400, 0x1044F)], True],
#'Karoshthi', [interval(0x10A00, 0x10A5F)], True],
#'Kaithi', [interval(0x11080, 0x110C1)], True],
#'Sora Sompeng', [interval(0x110D0, 0x110F0)], True],
#'Chakma', [interval(0x11100, 0x1114F)], True],
#'Sharada', [interval(0x11180, 0x111DF)], True],
#'Takri', [interval(0x11680, 0x116CF)], True],
#'Miao', [interval(0x16F00, 0x16F9F)], True],
[88, 	'Byzantine &amp; Western Musical Symbols', [interval(0x1D000, 0x1D0F5),
			interval(0x1D100, 0x1D126),
			interval(0x1D129, 0x1D1DD)
			], True],
[89, 	'Mathematical Alphanumeric Symbols', [interval(0x1D400, 0x1D454),
		interval(0x1D456, 0x1D49C),
		interval(0x1D49E, 0x1D49F),
		interval(0x1D4A2, 0x1D4A2),
		interval(0x1D4A5, 0x1D4A6),
		interval(0x1D4A9, 0x1D4AC),
		interval(0x1D4AE, 0x1D4B9),
		interval(0x1D4BB, 0x1D4BB),
		interval(0x1D4BD, 0x1D4C3),
		interval(0x1D4C5, 0x1D4FF),
		interval(0x1D500, 0x1D505),	# page 2
		interval(0x1D507, 0x1D50A),
		interval(0x1D50D, 0x1D514),
		interval(0x1D516, 0x1D51C),
		interval(0x1D51E, 0x1D539),
		interval(0x1D53B, 0x1D53E),
		interval(0x1D540, 0x1D544),
		interval(0x1D546, 0x1D546),
		interval(0x1D54A, 0x1D550),
		interval(0x1D552, 0x1D5FF),	
		interval(0x1D600, 0x1D6A5),	# page 3
		interval(0x1D6A8, 0x1D6FF),
		interval(0x1D700, 0x1D7CB),	# page 4
		interval(0x1D7CE, 0x1D7FF),
	], True],
[90, 	'Private Use (plane 15,16)', [
		interval(0xFF000, 0xFFFFD),	# plane 15
		interval(0x100000, 0x10FFFD)	# plane 16
	], True],
[91, 	'Variation Selectors (+suppl.)', [interval(0xFE00, 0xFE0F),
		interval(0xE0100, 0xE01EF)	# supplement
		], True],
[92, 	'Tags', [interval(0xE0000, 0xE01EF)], True],
[93, 	'Limbu', [interval(0x1900, 0x194F)]],
[94, 	'Tai Le', [interval(0x1950, 0x196D),
		interval(0x1970, 0x1974)
	]],
[95, 	'New Tai Lue', [interval(0x1980, 0x19DF)]],
[96, 	'Buginese', [interval(0x1A00, 0x1A1B),
		interval(0x1A1E, 0x1A1F)]],
[97, 	'Glagolitic', [ interval(0x2C00, 0x2C2E),
		interval(0x2C30, 0x2C5E) ]],
[98, 	'Tifinagh', [interval(0x2D30, 0x2D67),
		interval(0x2D6F, 0x2D70),
		interval(0x2D7F, 0x2D7F)
	]],
[99, 	'Yijing Hexagram Symbols', [interval(0x4DC0, 0x4DFF)]],
[100, 	'Syloti Nagri', [interval(0xA800, 0xA82F)]],
[101, 	'Linear B Syllabary etc', [interval(0x10000, 0x1013F)], True],
[102, 	'Ancient Greek Numbers', [interval(0x10140, 0x1018C)], True],
[103, 	'Ugaritic', [interval(0x10380, 0x1039D),
		interval(0x1039F, 0x1039F)
	], True],
[104, 	'Old Persian', [interval(0x103A0, 0x103C3),
		interval(0x103C8, 0x103D6),
	], True],
[105, 	'Shavian', [interval(0x10450, 0x1047F)], True],
[106, 	'Osmanya', [interval(0x10480, 0x104AF)], True],
[107, 	'Cypriot Syllabary', [interval(0x10800, 0x1083F)], True],
[108, 	'Kharoshthi', [interval(0x10A00, 0x10A5F)], True],
[109, 	'Tai Xuan Jing Symbols', [interval(0x1D300, 0x1D35F)], True],
[110, 	'Cuneiform (+numbers)', [interval(0x12000, 0x12398),
		interval(0x12400, 0x1246E),
		interval(0x12470, 0x12474)
		], True],
[111, 	'Counting Rod Numerals', [interval(0x1D360, 0x1D37F)], True],
[112, 	'Sundanese', [interval(0x1B80, 0x1BAA),
		interval(0x1BAE, 0x1BB9)
	]],
[113, 	'Lepcha', [interval(0x1C00, 0x1C4F)]], # FIXME
[114, 	'Ol Chiki', [interval(0x1C50, 0x1C7F)]],
[115, 	'Saurashtra', [interval(0xA880, 0xA8C4),
		interval(0xA8CE, 0xA8D9)
	]],
[116, 	'Kayah Li', [interval(0xA900, 0xA92F)]],
[117, 	'Rejang', [interval(0xA930, 0xA953),
		interval(0xA95F, 0xA95F)
	]],
[118, 	'Cham', [interval(0xAA00, 0xAA5F)]], #FIXME more complex
[119, 	'Ancient Symbols', [interval(0x10190, 0x101CF)], True],
[120, 	'Phaistos Disc', [interval(0x101D0, 0x101FF)], True],
[121, 	'Carian, Lycian, Lydian', [interval(0x102A0, 0x102D0), #Carian
		interval(0x10280, 0x1029C),	# Lycian
		interval(0x10920, 0x10939),	# Lydian
		interval(0x1093F, 0x1093F)
	], True],
[122, 	'Domino and Mahjong Tiles', [
		interval(0x1F000, 0x1F02B),	# Mahjong
		interval(0x1F030, 0x1F093)	# Domino
	], True],
#[123-127, 	'Reserved for process-internal usage', []]
[123, 	'Unicode with no OS/2 range', [
					# really this is a complicated range
		interval(0x1F300, 0x1F5FF),	# Miscellaneous Symbols and Pictographs
	], True],
]


def codepointIsInSomeRange( encoding ):
	for ulr in ulUnicodeRange:
		ranges = ulr[2]
		for r in ranges:
			if r.contains( encoding ):
				return True
	return False

