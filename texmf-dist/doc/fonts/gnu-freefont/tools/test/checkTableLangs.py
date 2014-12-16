#!/usr/bin/env python
# coding: utf-8

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
__copyright__ = "Copyright 2013 Stevan White"
__date__ = "$Date:: 2013-04-09 12:58:21 +0200#$"
__version__ = "$Revision: 2527 $"

__doc__ = """
Check FontForge SFD files for font feature tables which won't be activated
because they lack a script-language that was listed in another table.

For example
-----------
	table A to activate on: latn{'dflt'}
	table B to activate on: latn{'dflt', 'ESP '}
Then table A will *not* be activated for Spanish text, although it would
have been without the presence of the specification for B.

Likewise
-------
	table A to activate on: DFLT{'dflt'}
	table B to activate on: grek{'dflt'}
Then table A will *not* be activated for Greek text, although it would
have been without the presence of the specification for B.

The deal is, "dflt" behaves as a wildcard for languages, but only for those
which aren't listed *anywhere* among *any* of the tables of the current font. 
Likewise, "DFLT{dflt}" behaves as a wildcard for script-language, but only for
those which aren't listed *anywhere* among *any* of the tables of the current
font. 
(For better or worse that's how it is.)

This effect may be used to disable an otherwise general table for a specific
language, by simply creating another table that specifies the language, and
not listing the language explicitly in the first table.  So discretion must
be used in judging the output of this program--it may be that the font
designer *intends* to disable a feature for a specific script.

Unfortunately, in fonts that deal with multiple features with multiple
languages, this can get very tricky, and often results in features being
*accidentally* disabled.

This script looks for tables which are specified for language 'dflt', then
checks if the inclusion of a language in some other table disables any of them.

AFTER EXPERIMENTATION: it appears that the GPOS lookups are affected by
the script/languages of the GSUB lookups, but *not vice-versa*.  That is,
specifying a language tag for a given script in a GPOS table does not
disable a GSUB lookup for the same script that doesn't specify that language. 
However, specifying a language tag in a GSUB table disables a GPOS lookup
for the same script that doesn't specify the language tag.

FIXME: this program makes no distinction between GPOS and GSUB.
"""
from sys import argv, exit, stderr, stdout
import re

def explain_error_and_quit( e='' ):
	if e:
		print >> stderr, 'Error: ', e
	print >> stderr, "Usage:"
	print >> stderr, "       checkTableLangs sfd-file-path"
	exit( 1 )

"""
Typical line, with "scrp<dflt>"
Lookup: 6 0 0 "'ccmp' iogonek glyph decompos. in Latin"  {"'ccmp' iogonek glyph decomp in Latin-1"  } ['ccmp' ('latn' <'dflt' > ) ]

More complex: with "DFLT<dflt>"
Lookup: 1 0 0 "'onum' oldstyle figures"  {"'onum' oldstyle figures-subtable" ("oldstyle" ) "'onum' oldstyle figures-1" ("oldstyle" ) } ['onum' ('DFLT' <'dflt' > 'arab' <'dflt' > 'grek' <'dflt' > 'latn' <'dflt' > ) 'onum' ('latn' <'CAT ' 'DEU ' 'ESP ' 'ISM ' 'TRK ' 'VIT ' 'dflt' > ) 'onum' ('cyrl' <'BGR ' 'MKD ' 'SRB ' 'dflt' > ) ]

"""
	
_lookup_re = re.compile( "^Lookup: (\d) (\d) (\d) (.*)$" )
_data_re = re.compile( '''^"(.+)"\s+{(.+)}\s+\[(.+)\]''' )
_dquot_names_re = re.compile( '"([^"]+)"' )
_squot_names_re = re.compile( "'([^']+)'" )
_type_scriptlangs_re = re.compile( "'([^']{4})'\s+<([^<]*)>" )

def collect_lookups_from_sfd( f ):
	lookups = {}
	firstline = True
	for line in f:
		if firstline:
			if not line.startswith( "SplineFontDB: " ):
				explain_error_and_quit(
				"doesn't look like FontForge SFD file." )
			firstline = False

		m = _lookup_re.match( line )
		if m:
			data = m.group( 4 )
			dm = _data_re.match( data )
			if dm:
				parse_lookup( dm, lookups )
	return lookups

def parse_lookup( dm, lookups ):
	tableName = dm.group( 1 )
	subtableNames = dm.group( 2 )
	scriptNames = dm.group( 3 )
	lookups[tableName] = {}
	#if subtableNames:
	#	names = _dquot_names_re.findall( subtableNames )
	if scriptNames:
		scn = _type_scriptlangs_re.findall( scriptNames )
		for s in scn:
			script = s[0]
			langs = s[1]
			lngs = set( _squot_names_re.findall( langs ) )
			if not script in lookups[tableName]:
				lookups[tableName][script] = set()
			lookups[tableName][script] |= lngs

def printall( lookups ):
	for tn in lookups:
		print tn
		for script in lookups[tn]:
			print '\t', script, ', '.join( lookups[tn][script] )

def reverse_table_script( lookups ):
	""" reverse the table-script relationship """
	scriptTable = {}
	for (name, script_data) in lookups.items():
		for script in script_data:
			if script not in scriptTable:
				scriptTable[script] = set()
			scriptTable[script].add( name )
	return scriptTable

def reverse_table_script_lang( lookups ):
	""" reverse the table-script relationship """
	scriptLangTable = []
	for (name, script_data) in lookups.items():
		for script in script_data:
			for lang in script_data[script]:
				sl = ( script, lang )
				if sl not in scriptLangTable:
					scriptLangTable[sl] = set()
				scriptLangTable[sl].add( sl )
	return scriptLangTable

def tables_with_dflt_entry( lookups ):
	""" tables with a 'dflt' entry, associated script of the entry """
	tablesWdflt = {}
	scriptTable = reverse_table_script( lookups )
	for (script,names) in scriptTable.items():
		for name in names:
			allLangs = []
			lngs = lookups[name][script]
			if 'dflt' in lngs:
				tablesWdflt[name] = script
	return tablesWdflt

def tables_with_DFLT_dflt_entry( lookups ):
	""" tables with a 'dflt' entry, associated script of the entry """
	tablesWdflt = {}
	scriptTable = reverse_table_script( lookups )
	dfltLngs = set(['dflt'])
	for (script,names) in scriptTable.items():
		if script == 'DFLT':
			for name in names:
				allLangs = []
				lngs = lookups[name][script]
				if lngs == dfltLngs:
					tablesWdflt[name] = script
	return tablesWdflt

def tables_disbled_for_script( lookups ):
	""" For each table with a 'dflt' language for a given script,
	note the explicit languages listed for the script, and search all
	other tables for languages in that script *not* explicitly listed
	in the current table.
	"""
	disabled = {}
	scriptTable = reverse_table_script( lookups )
	tablesWdflt = tables_with_dflt_entry( lookups )
	dfltLang = set( ['dflt'] )
	for name in tablesWdflt:
		script = tablesWdflt[name]
		explicit = lookups[name][script] - dfltLang
		tablesBesidesThis = scriptTable[script] - set( [name] )
		for other in tablesBesidesThis:
			otherExplicit = lookups[other][script] - dfltLang
			conflict = otherExplicit - explicit
			if conflict:
				if not name in disabled:
					disabled[name] = []
				disabled[name].append( ( other, conflict ) )
	return disabled

def tables_disbled_for_script_lang( lookups ):
	""" For each table with a 'DFLT{dflt}' script-language, note the
	explicit script-languages in the table, and search all other tables
	for script-languages *not* explicitly listed in the current table.
	"""
	disabled = {}
	scriptTable = reverse_table_script( lookups )
	tablesWdflt = tables_with_DFLT_dflt_entry( lookups )
	dfltScrptLang = { 'DFLT':['dflt'] }

	for name in tablesWdflt:
		explicit = dict( lookups[name] )
		del explicit['DFLT']
		tablesBesidesThis = dict( lookups )
		if 'DFLT' in tablesBesidesThis:
			del tablesBesidesThis['DFLT']
		for other in tablesBesidesThis:
			otherExplicit = dict( lookups[other] )
			if 'DFLT' in otherExplicit:
				del otherExplicit['DFLT']
			conflict = set( otherExplicit ) - set( explicit )
			if conflict:
				if not name in disabled:
					disabled[name] = []
				disabled[name].append( ( other, conflict ) )
	return disabled

# =======================================================================
filename = argv[1] if len( argv ) > 1 else ''
if not filename:
	explain_error_and_quit()

f = None
try:
	f = open( filename, 'r' )
except Exception as e:
	explain_error_and_quit( e )

lookups = collect_lookups_from_sfd( f )
#printall( lookups )
disabled4Script = tables_disbled_for_script( lookups )
disabled4ScriptLang = tables_disbled_for_script_lang( lookups )

for feat in sorted( disabled4Script ):
	print "feature", '"' + feat + '"', "disabled for languages"
	allothers = []
	alllangs = set()
	for ( other, langs ) in disabled4Script[feat]:
		alllangs |= langs
		allothers.append( other )
	print "\t", list( alllangs )
	print '\tby "' + allothers[0] + ('" &cet' if len( allothers ) else '' )

for feat in sorted( disabled4ScriptLang ):
	print "feature", '"' + feat + '"', "disabled for script/language"
	allothers = []
	alllangs = set()
	for ( other, langs ) in disabled4ScriptLang[feat]:
		alllangs |= langs
		allothers.append( other )
	print "\t", list( alllangs )
	print '\tby "' + allothers[0] + ('" &cet' if len( allothers ) else '' )

