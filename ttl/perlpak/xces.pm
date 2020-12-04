# TTL and all included Perl modules is (C) Radu Ion (radu@racai.ro) and ICIA 2005-2018.
# Permission is granted for research and personal use ONLY.
#
# Provides a set of functions to read and write XCES corpuses.
#
# ver 0.1: created 01-Sep-04
# ver 0.2: fixed a getTU bug, 02-Sep-04
# ver 0.3: added tag mapping from MSDs to CTAGS, 15-Dec-04
# ver 0.31: added the whole msd tag which tells the XCES parser to extract whole/first 2 chars of the MSD (1/0), 15-Dec-04
# ver 0.4: added the punctuation to tag mapping ...
# ver 0.5: fixed a bug with the mappings. You can avoid them if you like.
# ver 0.55: added sentence ID to the returned hash. NOT FINAL YET !! Ultimately, we will have sid1 -> sent1, sid2 -> sent2 for m:n alignements.
# ver 0.56: added LPAR si RPAR
# ver 1.0: added the generation function
# ver 1.1: added a better %phash.
# ver 1.11 : added STAR.
# ver 1.2 : added setCategoryAna()
# ver 1.3 : added chunk attribute.
# ver 1.31: added TILDA, STAR2, STAR3 to %phash and %phashrev
# ver 1.4: added getpHash(), getpHashRev() to obtain the punctuation hashes, 19-Apr-05
# ver 1.5: 27-Apr-05, added HYPHEN in phashes and HELLIP cu doi de LL ...
# ver 1.6: 27-May-05, added AMPER, UNDERSC, POUND
# ver 1.7: 24-Jun-05, added genXCESHeader( corpusid );
# ver 1.8: 01-Jul-05, Am modificat un pic sa pot lucra cu doua corpusuri. Merge numai getTU !
# ver 1.9: 07-Jul-05, added BQUOT
# ver 2.0: 13-Jul-05, added wns attribute + getAttrValue + getAttrOrder + setAttrValue.
# ver 2.1: 14-Jul-05, added sub printCTUFile( $$$$ ); which prints to a filehandle. Also, automatic CORPUSID
# ver 2.2: 02-Sep-05, added head attribute.
# ver 2.21: 02-Sep-05, if langfilter is empty, get all languages (for getNextTU and getTU). Also print all languages if the lang input vector is empty.
# ver 2.22: 14-Sep-05, added punctuation to the phash and phashrev
# ver 2.23: 28-Sep-05, added wordphash with chars or strings that belong to a word. Needed by ttl.pm
# ver 2.24: 29-Sep-05, added closephash with chars or strings that end something. Needed by ttl.pm
# ver 2.3: 15-Dec-05, added support for generating empty objects: TU and word. For creation of TUs.
# ver 2.4: 19-Dec-05, fixed a bug with category and whole msd.
# ver 2.5: 28-Feb-06, fixed a bug with reading the corpus when it's indented.
# ver 2.6, 31-Mar-06, added '_' to wordphash.
# ver 2.7, 25-Apr-06, added openphash
# ver 2.8, 25-Apr-06, added openclosephash
# ver 2.9, 07-Jun-06, added printCTUString() ...
# ver 3.0, 08-Jun-06, added print null attrs flag ...
# ver 3.1, 23-Aug-06, fixed a bug with mappings and category flag ...
# ver 3.2, 23-Aug-06, added new DBLQ symbols !
# ver 3.3, 11-Mar-07, Radu ION, added isPunct( word )
# ver 3.4, 18-May-07, Radu ION, fixed a bug with categories ...
# ver 3.41, 15-Oct-07, Radu ION, fixed &rdquor; double quotes.
# ver 4.0, 19-Sep-08, Radu ION, added parsing of a single tu as string.
# ver 4.1, 03-Feb-09, Radu ION, added sub genXCESHeaderPath( $$ ).
# ver 4.2, 04-Feb-09, Radu ION, added UTF-8 header to genXCESHeaderPath( $$ ).
# ver 4.3, 11-Mar-10, Radu ION, added &bull; to punctuation.
# ver 5.0, 26-Mar-10, Radu ION, added 'id' attribute.
# ver 5.1, 18-May-10, Radu ION, added getCorpusID()
# ver 5.2, 03-Nov-10, Radu ION, added '&euro;'
# ver 5.3, 26-Apr-11, Radu ION, added punctuation from "Dictionarul Literaturii Romane".
# ver 5.4, 17-Mar-17, Radu ION, added punctuation from "Corola".
# ver 5.5, 06-Oct-17, Radu ION, added punctuation from "Agenda".
# ver 5.6, 24-Nov-17, Radu ION, added ordering over the set of open/close (double) quote punctuation.
# ver 5.7, 04-Jul-18, Radu ION, added '&quot;'

package xces;

use strict;
use warnings;
use utf8;

#Input: the set of languages that is to be read from a translation unit.
#Output: hash reference, a hash that contains the TU with those languages or 0 if we have reached the EOF of the file.
sub getNextTU( @ );
#Inpus: TU id (Ozz.1 for instance) and a reference to the array of languages to be extracted.
#Output: hash reference, a hash that contains the TU with those languages or 0 if we have reached the EOF of the file.
sub getTU( $$ );
#Input: corpus file.
sub setCorpus( $ );
#Input: a ref to a hash with <lang> => <mapping file> entries. Mapping file: MSD tab CTAG enter
#All languages that are to be read have to have mappings.
#Effect: reads in the map file.
sub setMapping( $ );
#Input: the $tu as returned by getTU(), pointer to the array of languages to be printed, the tu id string.
#Output: nothing
sub printCTU( $$$ );
#Input: the $tu as returned by getTU(), pointer to the array of languages to be printed, the tu id string and the file handle to print to.
#Output: nothing
sub printCTUFile( $$$$ );
#Input: the $tu as returned by getTU(), pointer to the array of languages to be printed and the tu id string.
#Output: the tu string
sub printCTUString( $$$ );
#Inpus: set 'whole MSD' flag: when this is 1, the whole MSD is extracted from the XCES corpus. Otherwise, only the first 2 chars are extracted.
#Default: get all the chars ( $wholemsdflag = 1 )
sub setWholeMSD( $ );
#Input: set 'category tag' flag: when this is 1, the category in front of the tag is removed before continuing. Category is of the form '[0-9]+\+,'
#Default: tags with category ( $categoryflag = 0 )
sub setCategoryAna( $ );
#Input: chunk attribute flag: when this is 1, the chunk info is included.
#Default: chunk attribute default : 0 (not included).
sub setChunkAttribute( $ );
#Input: sense attribute flag: when this is 1, the sense info is included.
#Default: sense attribute default : 0 (not included).
sub setSenseAttribute( $ );
#Input: sense attribute flag: when this is 1, the head info is included.
#Default: head attribute default : 0 (not included).
sub setHeadAttribute( $ );
#Input: id attribute flag: when this is 1, the id info is included.
#Default: id attribute default : 0 (not included).
sub setIDAttribute( $ );
#Input: if to print null attributes ... 1 yes
#Default: no null attrs: 0
sub setPrintNullAttrs( $ );
#Input: none
#Output: the %phash or %phashrev hashes.
sub getpHash();
sub getpHashRev();
sub getwordpHash();
sub getclosepHash();
sub getopenpHash();
sub getopenclosepHash();
sub getopencloseQuoteOrdering();
#Input: the corpus string to appear in <text id="...">
#Output: vector of header lines with \n at the end.
sub genXCESHeader( $ );
sub genXCESHeaderPath( $$ );
#Initializari ... NU PUTEM LUCRA SIMULTAN CU DOUA corpusuri ... folosind numai xces.pm. Va trebui s-o fac clasa candva.
sub initStaticGetTU();
sub initStaticGetNextTU();
#Input: the word as an ref to an array holding the attributes and the attr name ('chunk' for instance). The word is taken via the $tu returned by getNextTU sau getTU and with the specified lang: $tu->{"en"}->[1] for instance.
#Output: the value of the attribute of undef() if the attr is not set or a unknown attribute is received.
sub getAttrValue( $$ );
#Input: the word as an ref to an array holding the attributes, the attr name ('chunk' for instance) and the attr value. The word is taken via the $tu returned by getNextTU sau getTU and with the specified lang: $tu->{"en"}->[1] for instance.
#Output: the value of the attribute of undef() if the attr is not set or a unknown attribute is received.
sub setAttrValue( $$$ );
#Output: the hash of the attributes in a list (stored internally).
sub getAttrOrder();
#Input: TU id.
#Output: a pointer to a TU hash as that obtained by getNextTU.
sub getEmptyTUHash( $ );
#Input: language, sentence id, sentence (array of words - see getEmptyWord), TU hash from getEmptyTUHash.
#Output: the TU hash with the lang and SIDlang keys inserted.
sub addSentenceToTUHash( $$$$ );
#Output: a pointer to an array of undef() values. Size equal to the number of attributes defined.
sub getEmptyWord();
#Input: a word such as the one from getEmptyWord();
#Output: 1 if this word contains punctuation ...
sub isPunct( $ );
#Input: an XCES string as a <tu> ... </tu> and language.
#Output: an XCES sent as stored in the %tu hash.
sub parseStringSeg( $ );
#Output: the value of $CORPUSID local variable.
sub getCorpusID();

my( $CORPUS ) = "";
my( $CORPUSID ) = "XCESCorpus";
my( %hSEEK ) = ();
my( %tagmappings ) = ();
my( $wholemsdflag ) = 1;
my( $categoryflag ) = 0;
my( $chunkflag ) = 0;
my( $senseflag ) = 0;
my( $headflag ) = 0;
#ver 5.0
my( $idflag ) = 0;
my( $nullprint ) = 0;

#Non word chars that may appear in a word.
my( %wordphash ) = (
	"&" => "AMPER",
	";" => "SCOLON",
	"'" => "QUOT",
	"&rsquo;" => "QUOT",
	"-" => "DASH",
	"_" => "UNDERSC",
	"." => "PERIOD",
	'$' => "DOLLAR",
	"%" => "PERCENT"
);

my( %closephash ) = (
	")" => "RPAR",
	"]" => "RSQR",
	"}" => "RCURL",
	"&rdquor;" => "DBLQ",
	"&rsquor;" => "QUOT",
	"&rsquo;" => "QUOT",
	"&rdquo;" => "DBLQ",
	"&raquo;" => "DBLQ",
	"''" => "DBLQ",
);

my( %openphash ) = (
	"(" => "LPAR",
	"[" => "LSQR",
	"{" => "LCURL",
	"``" => "DBLQ",
	",," => "DBLQ",
	"&ldquor;" => "DBLQ",
	"&lsquor;" => "QUOT",
	"&lsquo;" => "QUOT",
	"&ldquo;" => "DBLQ",
	"&laquo;" => "DBLQ"
);

# ver 5.6
# l = Left
# r = Right
# Do not change the ordering!
my( @openclosequoteordering ) = (
	"&lsquo;",
	"&rsquo;",
	"&lsquor;",
	"&rsquor;",
	"&laquo;",
	"&raquo;",
	"&ldquor;",
	"&rdquor;",
	"&ldquo;",
	"&rdquo;"
);

my( %openclosephash ) = (
	"\"" => "DBLQ",
	"''" => "DBLQ",
	"'`" => "DBLQ",
	"`'" => "DBLQ",
);

my( %phash ) = (
	"!" => "EXCL",
	"!..." => "EXCLHELLIP",
	"," => "COMMA",
	"-" => "DASH",
	"--" => "DASH",
	"." => "PERIOD",
	"..." => "HELLIP",
	"&mldr;" => "HELLIP",
	":" => "COLON",
	";" => "SCOLON",
	"?" => "QUEST",
	"?..." => "QUESTHELLIP",
	"/" => "SLASH",
	"\\" => "BSLASH",
	"(" => "LPAR",
	")" => "RPAR",
	"[" => "LSQR",
	"]" => "RSQR",
	"{" => "LCURL",
	"}" => "RCURL",
	"&" => "AMPER",
	"\"" => "DBLQ",
	"&quot;" => "DBLQ",
	"&laquo;" => "DBLQ",
	"&raquo;" => "DBLQ",
	"&rsquo;" => "QUOT",
	"&lsquo;" => "QUOT",
	"&rdquo;" => "DBLQ",
	"&ldquo;" => "DBLQ",
	"&rdquor;" => "DBLQ",
	"&ldquor;" => "DBLQ",
	"&lsquor;" => "QUOT",
	"&rsquor;" => "QUOT",
	"&minus;" => "DASH",
	"&ndash;" => "DASH",
	"&mdash;" => "DASH",
	"''" => "DBLQ",
	"``" => "DBLQ",
	"'`" => "DBLQ",
	"`'" => "DBLQ",
	",," => "DBLQ",
	"=" => "EQUAL",
	"+" => "PLUS",
	"'" => "QUOT",
	"*" => "STAR",
	"**" => "STAR2",
	"***" => "STAR3",
	"~" => "TILDA",
	"&amp;" => "AMPER",
	"&ast;" => "STAR",
	"_" => "UNDERSC",
	"&pound;" => "POUND",
	"&horbar;" => "DASH",
	"&boxh;" => "BULLET",
	"`" => "BQUOT",
	"&gt;" => "GT",
	"&lt;" => "LT",
	"&ge;" => "GE",
	"&le;" => "LE",
	">" => "GT",
	"<" => "LT",
	'$' => "DOLLAR",
	"%" => "PERCENT",
	"^" => "CAP",
	"|" => "OR",
	"&bull;" => "BULLET",
	"&euro;" => "EURO"
);

my( %phashrev ) = (
	"EURO" => 1,
	"BULLET" => 1,
	"LCURL" => 1,
	"RCURL" => 1,
	"UNDERSC" => 1,
	"POUND" => 1,
	"HYPHEN" => 1,
	"EXCL" => 1,
	"EXCLHELLIP" => 1,
	"COMMA" => 1,
	"DASH" => 1,
	"PERIOD" => 1,
	"HELLIP" => 1,
	"COLON" => 1,
	"SCOLON" => 1,
	"QUEST" => 1,
	"QUESTHELLIP" => 1,
	"SLASH" => 1,
	"BSLASH" => 1,
	"LPAR" => 1,
	"RPAR" => 1,
	"LSQR" => 1,
	"RSQR" => 1,
	"AMPER" => 1,
	"DBLQ" => 1,
	"EQUAL" => 1,
	"PLUS" => 1,
	"QUOT" => 1,
	"STAR" => 1,
	"STAR2" => 1,
	"STAR3" => 1,
	"TILDA" => 1,
	"BQUOT" => 1,
	"GE" => 1,
	"LE" => 1,
	"GT" => 1,
	"LT" => 1,
	"DOLLAR" => 1,
	"PERCENT" => 1,
	"CAP" => 1,
	"OR" => 1,
	#French punctuation
	"PUN" => 1,
	"SENT" => 1,
	"SYM" => 1,
	#End.
	"_PUNCT" => 1
);


return 1;

sub isPunct( $ ) {
	my( $w ) = $_[0];
	
	return 0 if ( ! defined( $w ) || ! ref( $w ) );
	
	my( $punctform ) = getAttrValue( $w, "wordform" );
	my( $punctana ) = getAttrValue( $w, "ana" );
	
	if ( defined( $punctform ) && defined( $punctana ) ) {
		if ( exists( $phash{$punctform} ) || exists( $phashrev{$punctana} ) ) {
			return 1;
		}
	}
	
	return 0;
}

sub genXCESHeader( $ ) {
	my( $cid ) = $_[0];

	if ( $cid eq "_USECORPUSID" ) {
		$cid = $CORPUSID;
	}

	my( @header ) = (
		"<?xml version=\"1.0\"?>\n",
		"\n",
		"<!DOCTYPE text [\n",
		"\t<!ENTITY % SGMLUniq SYSTEM \"sgmlunic.ent\">\n",
		"\t\t%SGMLUniq;\n",
		"]>\n",
		"\n",
		"<text id=\"$cid\">\n",
		"<body>\n\n"
	);

	return @header;
}

sub genXCESHeaderPath( $$ ) {
	my( $cid ) = $_[0];
	my( $sgmluniqp ) = $_[1];

	if ( $cid eq "_USECORPUSID" ) {
		$cid = $CORPUSID;
	}

	my( @header ) = (
		"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
		"\n",
		"<!DOCTYPE text [\n",
		"\t<!ENTITY % SGMLUniq SYSTEM \"${sgmluniqp}\">\n",
		"\t\t%SGMLUniq;\n",
		"]>\n",
		"\n",
		"<text id=\"$cid\">\n",
		"<body>\n\n"
	);

	return @header;
}

sub getpHash() {
	return %phash;
}

sub getpHashRev() {
	return %phashrev;
}

sub getwordpHash() {
	return %wordphash;
}

sub getclosepHash() {
	return %closephash;
}

sub getopenpHash() {
	return %openphash;
}

sub getopenclosepHash() {
	return %openclosephash;
}

sub getopencloseQuoteOrdering() {
	return @openclosequoteordering;
}

sub setCorpus( $ ) {
	$CORPUS = "" if ( ref( $_[0] ) );

	initStaticGetTU();
	initStaticGetNextTU();
	%hSEEK = ();
	
	$CORPUS = $_[0];
}

sub setMapping( $ ) {
	foreach my $k ( keys( %{ $_[0] } ) ) {
		my( $mfile ) = ( $_[0] )->{$k};

		next if ( ! defined( $mfile ) || $mfile eq "" );

		if ( ! open( MAP, "< $mfile" ) ) {
			return;
		}

		my( %tagmap ) = ();

		while ( my $line = <MAP> ) {
			chomp( $line );

			my( @parts ) = split( /\s+/, $line );
			$tagmap{$parts[0]} = $parts[1];
		}

		close( MAP );

		$tagmappings{$k} = \%tagmap;
	}
}

sub setWholeMSD( $ ) {
	if ( $_[0] =~ /^[0-9]+$/ ) {
		if ( $_[0] == 0 || $_[0] == 1 ) {
			$wholemsdflag = $_[0];
		}
	}
}

sub setCategoryAna( $ ) {
	if ( $_[0] =~ /^[0-9]+$/ ) {
		if ( $_[0] == 0 || $_[0] == 1 ) {
			$categoryflag = $_[0];
		}
	}
}

sub setChunkAttribute( $ ) {
	if ( $_[0] =~ /^[0-9]+$/ ) {
		if ( $_[0] == 0 || $_[0] == 1 ) {
			$chunkflag = $_[0];
		}
	}
}

sub setSenseAttribute( $ ) {
	if ( $_[0] =~ /^[0-9]+$/ ) {
		if ( $_[0] == 0 || $_[0] == 1 ) {
			$senseflag = $_[0];
		}
	}
}

sub setHeadAttribute( $ ) {
	if ( $_[0] =~ /^[0-9]+$/ ) {
		if ( $_[0] == 0 || $_[0] == 1 ) {
			$headflag = $_[0];
		}
	}
}

#ver 5.0
sub setIDAttribute( $ ) {
	if ( $_[0] =~ /^[0-9]+$/ ) {
		if ( $_[0] == 0 || $_[0] == 1 ) {
			$idflag = $_[0];
		}
	}
}

#ver 3.0
sub setPrintNullAttrs( $ ) {
	if ( $_[0] =~ /^[0-9]+$/ ) {
		if ( $_[0] == 0 || $_[0] == 1 ) {
			$nullprint = $_[0];
		}
	}
}

#Char = byte !! seek and tell work !
sub fillSEEK() {
	open( CRP, "< " . $CORPUS );
	
	while ( my $line = <CRP> ) {
		#2.5
		if ( $line =~ /^\s*<text id=\"(.+?)\">/ ) {
			$CORPUSID = $1;
			next;
		}
		#2.5
		next if ( $line !~ /^\s*<tu id/ );

		#<tu id="Ozz.1">
		my( $OZZ ) = ( $line =~ /<tu id=\"(.+?)\">/ );

		$hSEEK{$OZZ} = tell( CRP ) - length( $line );
	}
	
	close( CRP );
}

{
	my( $gettucall ) = 0;
	my( $reqOZZ ) = "";

	sub initStaticGetTU() {
		$gettucall = 0;
		$reqOZZ = "";
	}

	sub getTU( $$ ) {
		if ( scalar( keys( %hSEEK ) ) == 0 ) {
			fillSEEK();
		}
		
		my( @langfilter ) = @{ $_[1] };

		$reqOZZ = $_[0];
		$gettucall = 1;

		my( $hres ) = getNextTU( @langfilter );
		
		$gettucall = 0;

		return $hres;
	}

	{
		my( $opened ) = 0;
		my( $corpus ) = "CRP";

		sub initStaticGetNextTU() {
			$opened = 0;
			$corpus = "CRP";
		}
		
		sub getNextTU( @ ) {
			my( @langfilter ) = @_;
			my( $line ) = "";
			my( $mline ) = "";
			my( %ret ) = ();
			my( $OZZ );

			if ( ! $opened ) {
				no strict;

				open( $corpus, "< " . $CORPUS );
				$opened = 1;
			}

			if ( eof( $corpus ) ) {
				close( $corpus );
				$opened = 0;

				return 0;
			}

			#If called from getTU ...
			if ( $gettucall ) {
				if ( defined( $reqOZZ ) && $reqOZZ ne "" ) {
					if ( exists( $hSEEK{$reqOZZ} ) ) {
						seek( $corpus, $hSEEK{$reqOZZ}, 0 );
					}
					else {
						return 0;
					}
				}
			}

			do {
				$line = <$corpus>;

				#2.5
				if ( $line =~ /^\s*<text id=\"(.+?)\">/ ) {
					$CORPUSID = $1;
				}
			}
			while ( ! eof( $corpus ) && $line !~ /<tu id=/ );

			if ( eof( $corpus ) ) {
				close( $corpus );
				$opened = 0;

				return 0;
			}

			( $OZZ ) = ( $line =~ /<tu id=\"(.+?)\">/ );

			$mline .= $line;
			do {
				$line = <$corpus>;
				$mline .= $line
			} while ( ! eof( $corpus ) && $line !~ /<\/tu>/ );

			if ( eof( $corpus ) ) {
				close( $corpus );
				$opened = 0;

				return 0;
			}

			#2.21
			my( $lrx ) = ".+?";
			
			$lrx = join( "|", @langfilter ) if ( scalar( @langfilter ) > 0 );

			#2.5
			my( @langs ) = ( $mline =~ /(<seg lang=\"(?:$lrx)\">.+?<\/seg>)/gs );

			$mline = "<tu id=\"$OZZ\">\n" . do {
				my( $llines ) = "";
				
				foreach my $l ( @langs ) {
					$llines .= $l . "\n";
				}
				
				$llines;		
			} . "</tu>\n";
			
			foreach my $l ( @langs ) {
				#ver 4.0
				my( $parsedseg ) = parseStringSeg( $l );
				my( $lg ) = $parsedseg->{"LANG"};
				my( $sent ) = $parsedseg->{"SENT"};
				my( $SID ) = $parsedseg->{"SID"};

				$ret{$lg} = $sent;
				$ret{"SID" . $lg} = $SID;
			}

			$ret{"OZZ"} = $OZZ;
			$ret{"CPART"} = $mline;
			
			return \%ret;
		}
	}
}

#ver 4.0
#Check here when you add a new attribute !!
sub parseStringSeg( $ ) {
	my( %parsedseg ) = ( "SID" => "", "LANG" => "", "SENT" => [] );
	my( $l ) = $_[0];
	my( @toks ) = ( $l =~ /(<(?:w|c).*?>.+?<\/(?:w|c)>)/g );
	my( $SID ) = ( $l =~ /<s id=\"(.+?)\">/ );
	my( @sent ) = ();
	my( $lg ) = ( $l =~ /<seg lang=\"(.+?)\">/ );
	my( %tagmap ) = ( ( exists( $tagmappings{$lg} ) ) ? %{ $tagmappings{$lg} } : () );

	foreach my $k ( @toks ) {
		#ver 5.0
		my( $lem, $pos, $chunk, $sense, $head, $idattr, $wd );

		$lem = undef();
		$pos = undef();
		$chunk = undef();
		$sense = undef();
		$head = undef();
		#ver 5.0
		$idattr = undef();
		$wd = undef();

		#3.0 ... inserted .*? to accept the NULL string ...
		( $lem ) = ( $k =~ /\slemma=\"(.*?)\"/ );

		# ver 2.4
		( $pos ) = ( $k =~ /\sana=\"(.*?)\"/ );
		# ver 1.2
		if ( defined( $pos ) ) {
			if ( $categoryflag ) {
				my( $tmppos ) = ( $pos =~ /^(?:[0-9]+\+,)?(.+)$/ );

				$pos = $tmppos if ( $wholemsdflag );
				$pos = substr( $tmppos, 0, 2 ) if ( ! $wholemsdflag );
			}
			else {
				my( $tmpcat, $tmppos ) = ( $pos =~ /^([0-9]+\+,)?(.+)$/ );

				if ( defined( $tmpcat ) ) {
					$pos = $tmpcat . $tmppos if ( $wholemsdflag );
					$pos = $tmpcat . substr( $tmppos, 0, 2 ) if ( ! $wholemsdflag );
				}
				else {
					$pos = $tmppos if ( $wholemsdflag );
					$pos = substr( $tmppos, 0, 2 ) if ( ! $wholemsdflag );
				}
			}
		}

		( $chunk ) = ( $k =~ /\schunk=\"(.*?)\"/ ) if ( $chunkflag );
		( $sense ) = ( $k =~ /\swns=\"(.*?)\"/ ) if ( $senseflag );
		( $head ) = ( $k =~ /\shead=\"(.*?)\"/ ) if ( $headflag );
		#ver 5.0
		( $idattr ) = ( $k =~ /\sid=\"(.*?)\"/ ) if ( $idflag );
		( $wd ) = ( $k =~ />([^><]+?)<\/w>/ );

		my( $pct ) = ( $k =~ />(.+?)<\/c>/ );

		SWWC: {
			defined( $wd ) and do {
				my( $pos2 ) = $pos;

				#3.1
				if ( $categoryflag ) {
					$pos2 = $tagmap{$pos} if ( $wholemsdflag == 1 && exists( $tagmap{$pos} ) );
				}
				else {
					my( $tmpcat, $pos3 ) = ( $pos2 =~ /^([0-9]+\+,)?(.+)$/ );

					# ver 3.4
					if ( defined( $tmpcat ) ) {
						$pos2 = $tmpcat . $tagmap{$pos3} if ( $wholemsdflag == 1 && exists( $tagmap{$pos3} ) );
					}
					else {
						$pos2 = $tagmap{$pos3} if ( $wholemsdflag == 1 && exists( $tagmap{$pos3} ) );
					}
				}

				#ver 5.0
				my( @tri ) = ( $wd, $lem, $pos2, $chunk, $sense, $head, $idattr );

				@sent = ( @sent, \@tri );

				last;
			};

			defined( $pct ) and do {
				my( @tri ) = ( $pct, $pct, ( ( exists( $phash{$pct} ) ) ? $phash{$pct} : "_PUNCT" ) );

				@sent = ( @sent, \@tri );
			};
		}
	} #end of sentence 'parsing'

	$parsedseg{"SID"} = $SID;
	$parsedseg{"SENT"} = \@sent;
	$parsedseg{"LANG"} = $lg;

	return \%parsedseg;
}

sub getAttrValue( $$ ) {
	my( %attrpos ) = getAttrOrder();
	my( $w ) = $_[0];
	my( $attrname ) = $_[1];
	my( $aidx ) = $attrpos{$attrname};

	return undef() if ( ! defined( $aidx ) );
	return $w->[$aidx];
}

sub setAttrValue( $$$ ) {
	my( %attrpos ) = getAttrOrder();
	my( $w ) = $_[0];
	my( $attrname ) = $_[1];
	my( $attrval ) = $_[2];
	my( $aidx ) = $attrpos{$attrname};

	return 0 if ( ! defined( $aidx ) );
	
	$w->[$aidx] = $attrval;
	return 1;
}

#Check parseStringSeg when you add a new attribute.
sub getAttrOrder() {
	#If you add an attribute, add it to the END of this ONLY !!
	#ver 5.0
	return ( "wordform" => 0, "lemma" => 1, "ana" => 2, "chunk" => 3, "wns" => 4, "head" => 5, "id" => 6 );
}

sub printCTU( $$$ ) {
	my( $tu ) = $_[0];
	my( @langs ) = @{ $_[1] };
	my( $tuid ) = $_[2];

	if ( scalar( @langs ) == 0 ) {
		my( @tlangs ) = ();

		foreach my $k ( keys( %{ $tu } ) ) {
			if ( $k !~ /^OZZ/ && $k !~ /^CPART/ && $k !~ /^SID/ ) {
				push( @tlangs, $k );
			}
		}

		@langs = sort { $a cmp $b } @tlangs;
	}

	print( "<tu id=\"" . $tuid . "\">\n" );
	
	foreach my $l ( @langs ) {
		print( "<seg lang=\"$l\">" . "<s id=\"" . $tu->{"SID" . $l} . "\">" );
		foreach my $w ( @{ $tu->{$l} } ) {
			if ( exists( $phashrev{$w->[2]} ) ) {
				print( "<c>" . $w->[0] . "</c>" );
			}
			else {
				my( @attrstrings ) = ();
				my( %attrorder ) = getAttrOrder();
				my( $wordform ) = getAttrValue( $w, "wordform" );

				delete( $attrorder{"wordform"} );

				while ( scalar( keys( %attrorder ) ) > 0 ) {
					my( $minp ) = 1000;
					my( $minattr ) = "";

					foreach my $a ( keys( %attrorder ) ) {
						if ( $attrorder{$a} < $minp ) {
							$minp = $attrorder{$a};
							$minattr = $a;
						}
					}

					my( $value ) = getAttrValue( $w, $minattr );

					#ver 3.0
					if ( $nullprint ) {
						if ( defined( $value ) ) {
							push( @attrstrings, $minattr . "=" . "\"" . $value . "\"" );
						}
					}
					else {
						if ( defined( $value ) && $value ne "" ) {
							push( @attrstrings, $minattr . "=" . "\"" . $value . "\"" );
						}
					}

					delete( $attrorder{$minattr} );
				}
				
				print( "<w " . join( " ", @attrstrings ) . ">" . $wordform . "</w>" );
			}
		}
		print( "</s></seg>\n" );
	}

	print( "</tu>\n\n" );
}

#Input: tu id.
#Returns a pointer to a TU hash to be written with printCTU
sub getEmptyTUHash( $ ) {
	my( $tuid ) = $_[0];

	if ( ! defined( $tuid ) ) {
		$tuid = "";
	}

	return { "OZZ" => $tuid, "CPART" => "" };
}

#Input: language, sentence id, sentence (array of words from getEmptyWord and setAttrValue), TU hash from getEmptyTUHash.
sub addSentenceToTUHash( $$$$ ) {
	my( $lang, $sentid ) = ( $_[0], $_[1] );
	my( $sent, $tu ) = ( $_[2], $_[3] );

	$tu->{$lang} = $sent;
	$tu->{"SID" . $lang} = $sentid;

	return $tu;
}

#Get an empty pointer to an array which forms the words of the sentences in a TU hash.
sub getEmptyWord() {
	my( %attrorder ) = getAttrOrder();
	my( @newword ) = ( undef() ) x scalar( keys( %attrorder ) );
	
	return \@newword;
}

sub printCTUFile( $$$$ ) {
	no strict;

	my( $tu ) = $_[0];
	my( @langs ) = @{ $_[1] };
	my( $tuid ) = $_[2];
	my( $FHANDLE ) = $_[3];

	if ( scalar( @langs ) == 0 ) {
		my( @tlangs ) = ();

		foreach my $k ( keys( %{ $tu } ) ) {
			if ( $k !~ /^OZZ/ && $k !~ /^CPART/ && $k !~ /^SID/ ) {
				push( @tlangs, $k );
			}
		}

		@langs = sort { $a cmp $b } @tlangs;
	}

	print( $FHANDLE "<tu id=\"" . $tuid . "\">\n" );
	
	foreach my $l ( @langs ) {
		print( $FHANDLE "<seg lang=\"$l\">" . "<s id=\"" . $tu->{"SID" . $l} . "\">" );
		foreach my $w ( @{ $tu->{$l} } ) {
			if ( exists( $phashrev{$w->[2]} ) ) {
				print( $FHANDLE "<c>" . $w->[0] . "</c>" );
			}
			else {
				my( @attrstrings ) = ();
				my( %attrorder ) = getAttrOrder();
				my( $wordform ) = getAttrValue( $w, "wordform" );

				delete( $attrorder{"wordform"} );

				while ( scalar( keys( %attrorder ) ) > 0 ) {
					my( $minp ) = 1000;
					my( $minattr ) = "";

					foreach my $a ( keys( %attrorder ) ) {
						if ( $attrorder{$a} < $minp ) {
							$minp = $attrorder{$a};
							$minattr = $a;
						}
					}

					my( $value ) = getAttrValue( $w, $minattr );

					#ver 3.0
					if ( $nullprint ) {
						if ( defined( $value ) ) {
							push( @attrstrings, $minattr . "=" . "\"" . $value . "\"" );
						}
					}
					else {
						if ( defined( $value ) && $value ne "" ) {
							push( @attrstrings, $minattr . "=" . "\"" . $value . "\"" );
						}
					}

					delete( $attrorder{$minattr} );
				}
				
				print( $FHANDLE "<w " . join( " ", @attrstrings ) . ">" . $wordform . "</w>" );
			}
		}
		print( $FHANDLE "</s></seg>\n" );
	}

	print( $FHANDLE "</tu>\n\n" );
}

sub printCTUString( $$$ ) {
	my( $tu ) = $_[0];
	my( @langs ) = @{ $_[1] };
	my( $tuid ) = $_[2];
	my( $STRING ) = "";

	if ( scalar( @langs ) == 0 ) {
		my( @tlangs ) = ();

		foreach my $k ( keys( %{ $tu } ) ) {
			if ( $k !~ /^OZZ/ && $k !~ /^CPART/ && $k !~ /^SID/ ) {
				push( @tlangs, $k );
			}
		}

		@langs = sort { $a cmp $b } @tlangs;
	}

	$STRING .= "<tu id=\"" . $tuid . "\">\n";
	
	foreach my $l ( @langs ) {
		$STRING .= "<seg lang=\"$l\">" . "<s id=\"" . $tu->{"SID" . $l} . "\">";
		foreach my $w ( @{ $tu->{$l} } ) {
			if ( exists( $phashrev{$w->[2]} ) ) {
				$STRING .= "<c>" . $w->[0] . "</c>";
			}
			else {
				my( @attrstrings ) = ();
				my( %attrorder ) = getAttrOrder();
				my( $wordform ) = getAttrValue( $w, "wordform" );

				delete( $attrorder{"wordform"} );

				while ( scalar( keys( %attrorder ) ) > 0 ) {
					my( $minp ) = 1000;
					my( $minattr ) = "";

					foreach my $a ( keys( %attrorder ) ) {
						if ( $attrorder{$a} < $minp ) {
							$minp = $attrorder{$a};
							$minattr = $a;
						}
					}

					my( $value ) = getAttrValue( $w, $minattr );

					#ver 3.0
					if ( $nullprint ) {
						if ( defined( $value ) ) {
							push( @attrstrings, $minattr . "=" . "\"" . $value . "\"" );
						}
					}
					else {
						if ( defined( $value ) && $value ne "" ) {
							push( @attrstrings, $minattr . "=" . "\"" . $value . "\"" );
						}
					}

					delete( $attrorder{$minattr} );
				}
				
				$STRING .= "<w " . join( " ", @attrstrings ) . ">" . $wordform . "</w>";
			}
		}
		$STRING .= "</s></seg>\n";
	}

	$STRING .= "</tu>\n\n";
	return $STRING;
}

sub getCorpusID() {
	return $CORPUSID;
}
