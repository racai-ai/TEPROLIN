# TTL and all included Perl modules is (C) Radu Ion (radu@racai.ro) and ICIA 2005-2018.
# Permission is granted for research and personal use ONLY.
#
# Tokenizing, Tagging and Lemmatizing free running text: TTL
#
# ver 0.1, 07-Sep-05, Radu ION, created.
# ver 0.2, 07-Sep-05, Radu ION, implemented the sentence splitter.
# ver 0.3, 08-Sep-05, Radu ION, implemented the tokenizer.
# ver 0.4, 09-Sep-05, Radu ION, implemented mtsegout for tokenizer.
# ver 0.5, 12-Sep-05, Radu ION, implemented training for tagger (HMM based, like TnT).
# ver 0.6, 14-Sep-05, Radu ION, implemented the tagger.
# ver 0.7, 19-Sep-05, Radu ION, implemented the Viterbi decoder.
# ver 0.8, 19-Sep-05, Radu ION, various tweaks for sentsplitter.
# ver 0.9, 20-Sep-05, Radu ION, lemmatizer functions.
# ver 1.0, 20-Sep-05, Radu ION, implemented the lemmatizer.
# ver 1.1, 28-Sep-05, Radu ION, implemented lemmatizer heuristics and heuristics evaluation in training
# ver 1.2, 28-Sep-05, Radu ION, fixing several bugs in tokenizer and sentence splitting.
# ver 1.3, 28-Sep-05, Radu ION, added specific tags to the suffix tree. Configure option.
# ver 1.31, 29-Sep-05, Radu ION, added Name heuristics to the tokenizer.
# ver 1.4, 29-Sep-05, Radu ION, fixed a tokenizer bug which splitted the punctuation: for instance '' was splitted into ' '
# ver 1.41, 29-Sep-05, Radu ION, fixed another bug in the sentsplitter when some punctuation is left as a sentence.
# ver 1.5, 29-Sep-05, Radu ION, fixed a bug in tagger: Se Y sau se PXA: daca apare cu litera mare il face Y indiferent de unde apare. Am adaugat optiunea MATCH la probword si la taggerviterbi
# ver 1.6, 30-Sep-05, Radu ION, added output options in CONFOUT
# ver 1.7, 03-Oct-05, Radu ION, added unknown words output for tagger when DEBUG == 1
# ver 1.71, 03-Oct-05, Radu ION, fixed a bug in sentence splitter.
# ver 1.8, 17-Jan-06, Radu ION, added Recover code to the tagger.
# ver 1.81, 18-Jan-06, Radu ION, added other Recover functions.
# ver 1.9, 18-Jan-06, Radu ION, fixed a huge bug with tag guessing in probword ... but the correct formula doesn't work ! Kept the old formula.
# ver 2.0, 19-Jan-06, Radu ION: HEAVY MEMORY OPTIMIZATION. This version: CONFTAG{LEX} and CONFTAG{AFX} are going to trees ...
# ver 2.1, 20-Jan-06, Radu ION: HEAVY MEMORY OPTIMIZATION. This version: CONFTTAG{AFX} into file ... still not working ... various tweaks @ recover code ...
# ver 3.0, 20-Jan-06, Radu ION: DBD tata !! Nu merge nimic ! :)) This version: CONFTAG{LEX} and CONFTAG{AFX} go to BDB databases.
# ver 3.1, 21-Jan-06, Radu ION: some bugs in DBD handling ... $N was not saved ...
# ver 3.2, 21-Jan-06, Radu ION: recover tbls go to BDBs ... and endProcessing for untie all DBDs ...
# ver 3.3, 21-Jan-06, Radu ION: added conftrainrecover();
# ver 3.4, 23-Jan-06, Radu ION: added a fix for tokenize with splits that are uppercase ...
# ver 3.5, 24-Jan-06, Radu ION: fixed several bugs in recoverMSD and readRecoverRules.
# ver 4.0, 01-Mar-06, Radu ION: added conftrainrecover() again !! :)).
# ver 4.1, 24-Mar-06, Radu ION: fixed bugs in sentsplitter
# ver 4.2, 28-Mar-06, Radu ION: fixed lemmatizer to work with MSD tbl.wordform
# ver 4.21, 28-Mar-06, Radu ION: fixed output probability in the lemma ...
# ver 4.22, 29-Mar-06, Radu ION: fixed again tokenizer in conjunction with the 3.4 fixes ...
# ver 4.3, 31-Mar-06, Radu ION: fixed a bug in tokenizer at punctuation split ...
# ver 4.4, 13-Apr-06, Radu ION: fixed a bug in sentsplitter with e.g. which was splitted ...
# ver 4.5, 13-Apr-06, Radu ION: fixed a bug in tokenizer with % replacing diacs ... :))
# ver 5.0, 19-Apr-06, Radu ION: added Named Entity Recognition ....
# ver 5.5, 20-Apr-06, Radu ION: completely rewritten sentsplitter ...
# ver 5.6, 25-Apr-06, Radu ION: MARKERSPLIT in tokenizer ...
# ver 5.7, 26-Apr-06, Radu ION: added some modifications concerning NERs to the lemmatizer.
# ver 6.0, 27-Apr-06, Radu ION: transformed TTL into an object. %CONFSSPLIT, %CONFTAG, %CONFLEM are not global anymore ...
# ver 6.1, 03-May-06, Radu ION: some minor corrections at DLL functions ...
# ver 6.2, 06-Jun-06, Radu ION: case insensitive abbrev match ...
# ver 6.3, 14-Aug-06, Radu ION: major bug in traintagger in AFX DB ... we only consider affixes in the current training corpus. Update is failing !
# ver 6.4, 16-Aug-06, Radu ION: ignoring wrong mappings: put the wordform as the lemma in these cases ...
# ver 6.5, 16-Aug-06, Radu ION: lemmatizer: search in TBL first and then apply copy wordform and others ...
# ver 6.6, 29-Aug-06, Radu ION: train lemmatizer: skip _ words ... as they have complicated lemmas ...
# ver 6.7, 01-Sep-06, Radu ION: modified traintagger and trainrecover to skip _ words ... no suffixes for these words.
# ver 6.71, 07-Feb-07, Radu ION: modified readRecoverRules to handle empty rule files ...
# ver 6.72, 07-Feb-07, Radu ION: modified chooseLemma to handle no heur stats (M=0)
# ver 6.73, 20-Feb-07, Radu ION: modified outputformat for line ...
# ver 6.80, 21-Feb-07, Radu ION: removed a bug from sentsplitter where &abreve; at sentence final would become &abreve ;
# ver 6.81, 21-Feb-07, Radu ION: removed a bug from sentsplitter (final abbrev pct was toknized).
# ver 6.82, 27-Feb-07, Radu ION: added some modifications to the trainrecover function ... skip - words also ...
# ver 7.0, 26-Apr-07, Radu ION: added chunking to TTL ...
# ver 7.1, 26-Apr-07, Radu ION: fixed a bug with abbrev recognition ... try the longer ones first ...
# ver 7.2, 26-Apr-07, Radu ION: fixed a bug where the diac like punctuation was not splitted ...
# ver 7.3, 27-Apr-07, Radu ION: fixed a bug with are/ara/Vmsp3 in loc de are/avea/Vmip3s (Markov modeling trebuie aplicat doar in cazurile in care rulerul nu are nimic de zis).
# ver 7.4, 03-May-07, Radu ION: added debug info to sentsplitter
# ver 7.41, 15-Oct-07, Radu ION: tweaked lemma out probability ...
# ver 7.5, 25-Feb-08, Radu ION: added Web Services with SOAP::Lite functionality.
# ver 7.6, 26-Feb-08, Radu ION: added XCES output for the input string.
# ver 7.61, 28-Feb-08, Radu ION: forgot to close the file in sentsplitter
# ver 7.62, 29-Feb-08, Radu ION: added debug info to object distruction ...
# ver 7.7, 03-Mar-08, Radu ION: modified lemmatizer to gen lemma as wordform if COPYWORDFORM is set no matter if the wordform is in TBL ...
# ver 7.8, 14-Apr-09, Radu ION: modified lemmatizer to search for word case, lower case or sentence case in tbl before guessing ...
# ver 7.9, 11-Mar-10, Radu ION: modified XCES function to produce escapes for <, > and &.
# ver 8.0, 04-May-10, Radu ION: fixed the lemmatization problem in which, for the same wordform/tag, there were more than 1 lemmas available.
# ver 8.1, 12-May-10, Radu ION: added some more escapes ...
# ver 8.2, 12-May-10, Radu ION: bug with <w lemma="&quot;" ana="DBLQ">&quot;</w>
# ver 8.3, 21-Apr-11, Radu ION: added wsXCESPart().
# ver 8.4, 27-Apr-11, Radu ION: resolved a bug with TTL_NAMED_ENTITY left in the output (in tokenizer()).
# ver 8.41, 11.11.2011, Radu ION: added binmode( UTF8) on sentsplitter files...
# ver 8.5, 11.11.2011, Radu ION: fixed chunking function getBlocks();
# ver 8.6, 24.07.2012, Radu ION: fixed a bug in tokenizer where -&ndash; was split incorrectly.
# ver 8.7, 14.12.2012, Radu ION: fixed 'tmp.txt' temp files for multiple instances running simultaneously.
# ver 8.8, 29.08.2013, Radu ION: fixed "Illegal division by zero" in computeLambdas( $$ ).
# ver 8.9, 29.03.2016, Radu ION: fixed spurious token when you have an entity at the beginning/end of the sentence.
# ver 9.0, 24.11.2017, Radu ION: fixed &laquo; ... &raquo; and friends swapping in tokenizer.
# ver 9.1, 17.12.2018, Radu ION: adapted this module for inclusion in ReTeRom's TEPROLIN platform.

package pdk::ttl;

use warnings;
use strict;
use Algorithm::Diff qw( sdiff );
use BerkeleyDB;
# ver 9.1: removed use lib as it is already given
# from the main calling script.
use xces;
use rxgram;
use hashset;

my( $UTF8HEAD ) = "\x{ef}\x{bb}\x{bf}";
my( %CONFTTAG ) = (
	"LEX" => undef(),
	"123" => undef(),
	"AFX" => undef(),
	#Suffix length: integer, IN: MUST BE EQUAL with CONFTAG SUFFL !
	"SUFFL" => undef(),
	#Suffix tree : build it for these tags only. Because an unknown word many be a N,V,A,R or NP,Y but not pronoun and the like.
	"SUFFTAGS" => undef(),
	#Here you may have 'line', 'column' or 'tbl' (like in tbl.wordform)
	"CORPUSSTYLE" => undef(),
	"TRAINFILE" => undef(),
	"UPCASETAGS" => undef(),
	#Mode: fresh or update
	"MODE" => "fresh",
	#These may be reordered or removed but wordform and tag must be present.
	"ATTRORDER" => [ "wordform", "lemma", "tag" ],
	"DEBUG" => 0
);
my( %CONFTRAINREC ) = (
	#4.0
	#The MSD TBL file to read in ...
	"TBLMSDTXTFILE" => undef(),
	#File to write MSD tbl ... IN
	"DBTBLMSD" => undef(),
	#File to write MSDSUFF BDB, IN.
	"DBMSDSUFF" => undef(),
	#File to write to ... MSDFREQ BDB, IN.
	"DBMSDFREQ" => undef(),
	#Suffix length for MSD guessing, IN. MUST BE THE SAME AS IN CONFTAG !!
	"MSDSFXLEN" => undef(),
	#What MSDs to consider, IN, MUST BE THE SAME AS IN CONFTAG !!
	"MSDMATCH" => undef(),
	"DEBUG" => 0
);
my( %CONFTLEM ) = (
	"TBL" => undef(),
	#Daca e 0, ia tot tbl-ul pentru un tag dat.
	"TESTSAMPLEPERTAG" => 1000,
	"LCSOVERWF" => 0.6,
	"SAVERULEFREQ" => 10,
	"TRAINTAGS" => undef(),
	"MODELFILE" => undef(),
	"DEBUG" => 0
);
my( %CONFOUT ) = (
	#Format options are: line, column, xces, tab
	"FORMAT" => "line",
	#Relevant only for line and column.
	"ATTRORDER" => [ "wordform", "lemma", "tag" ]
);

#Input: pointer to a hash table with config keys.
#Output: void
sub confsentsplitter( $$ );
#Input: pointer to a hash table with config keys.
#Output: void
sub conftokenizer( $$ );
#Input: pointer to a hash table with config keys.
#Output: void
sub conftagger( $$ );
#Input: pointer to a hash table with config keys.
#Output: void
sub conftraintagger( $$ );
#Input: pointer to a hash table with config keys.
#Output: void
sub conflemmatizer( $$ );
#Input: pointer to a hash table with config keys.
#Output: void
sub conftrainlemmatizer( $$ );
#Input:The .txt file to be splitted.
#Output: hash pointer to the file structure: paragraph -> sent -> sent string;
#5.0 A new and improved sentsplitter with NER.
sub sentsplitter( $$ );
#end 5.0
#Input:string of the sentence.
#Output: array pointer to the sentence;
sub tokenizer( $$ );
#Input: paragraph no, sent no and pointer to the array of the tokens of the sentence (from tokenizer)
#Output: mtseg like output
sub mtsegoutput( $$$$ );
#Input: nothing.
#Output: none.
sub traintagger( $ );
#Input: pointer to the array of the tokens of the sentence (from tokenizer) and pointer to the array of the tags assigned by tokenizer and pointer to the array of tags assigned by NER engine.
#Output: array pointer to the POS sequence.
sub tagger( $$$$ );
#Input: pointer to the array of the tokens of the sentence with POS-tags (from tagger).
#Output: tnt like output
sub tntoutput( $$ );
#5.7
#Input: pointer to the array of the tokens of the sentence and pointer to the array of the POS tags for the sentence and pointer of the array with NER tags for the sentence.
#Output: array pointer to the POS-tagged sentence with lemmas;
sub lemmatizer( $$$$ );
#Input: nothing; input comes from conftrain.
#Output: nothing
sub trainLemModel( $ );
#Input: the MM for a given tag
#Output: nothing
sub computeLambdas( $$ );
#Input: worform, lemma and the rules hash from the model.
#Output: nothing
sub learnRules( $$$$ );
#Input: lemma and MM pentru un tag ...
sub learnMM( $$$ );
#Saves the lemmatizer model
sub saveLemModel( $$$ );
#Loads the lemmatizer model
sub loadLemModel( $$ );
#Input: pointer to a hash table with config keys.
#Output: void
sub confoutputformat( $$ );
#Input: $FHANDLE (pointer), toksent, tagsent and lemsent, language, tu id and sentence id.
#Output: in a file (taken from config) output the annotated text.
sub outputformat( $$$$$$$$ );

sub generateLemmas( $$$ );
sub computeMM( $$$$ );
sub computeMMDirect( $$$$ );
sub applyMM( $$$$ );
sub guessLemma( $$$ );
sub chooseLemma( $$$$ );

#Input: file of abbreviations mtseg style. Returns the pointer to the hash in "ABBREV" key.
#Output: the hash.
sub readAbbrev( $$ );
#Input: file of compounds mtseg style. Returns the pointer to the hash in "MERGE" key.
#Output: the hash.
sub readMergeStrings( $$ );
#Input: file of left and right splits mtseg style. Returns the pointer to the hash in "SPLIT" key.
#Output: the hash.
sub readSplitStrings( $$ );
#Input: file of the lexicon and file of the suffix trees and the update procedure. For read, use 'update'.
sub readLexicon( $$$$ );
sub readTrigrams( $$ );
sub readTblWordform( $$ );
#8.0
sub readProbTblWordform( $$ );

#Helper functions. This must be called once prior to call mtsegoutput( $$$ ).
sub initmtsegout();
#Must be called after the last sentence in the file.
sub endmtsegout();
#Called when training a tagger on a line corpus. Internal function.
sub getAttributes( $$ );
#Input: word and k letters at the end of it.
sub extractSuffix( $$$ );
sub taggerviterbi( $ );
sub probtrig( $$ );
sub probword( $$$$$ );
sub extractSGMLChars( $$ );

#RECOVER FUNCTIONS.
#Input tbl.wordform with MSDs, and the length of suffix for MSD estimation and the MSDs to analyse.
sub readTblWordformTree( $$$$ );
#Input: wordform and array of MSDs of THE SAME CATEGORY !!
sub computeMostProbableMSD( $$$$$$$ );
#Input: TBLTREE from readTBLTREE and wordform.
sub getMSDFromTBLTree( $$$ );
#Input CTAG to MSD map table ...
sub readTAGtoMSDMapping( $$ );
#4.2
sub readMSDtoTAGMapping( $$ );
#Input: rules file ...
sub readRecoverRules( $$ );
sub recoverMSD( $$$$ );

#ver 2.0, 3.0
sub lexAddWordToDB( $$$$$ );
sub lexExistsWordInDB( $$$ );
sub lexExistsWordWithTagInDB( $$$$ );
sub lexGetInfoFromDB( $$$ );
sub lexGetFreqFromDB( $$$$ );
#end 2.0, 3.0

#ver 2.1
sub recAddWordToTbl( $$$$ );
sub recAddSuffToTree( $$$$ );
#3.1
sub recGetTreeGoodies( $$$ );
#MUST BE CALLED after the TTL functions !!
sub endProcessing( $ );
sub trainrecover( $ );
sub conftrainrecover( $$ );
#end 3.1
#end 2.1

#5.0
sub readNERGrammar( $$ );
sub readNERFilter( $$ );
#end 5.0
sub endProcessing( $ );

#ver 7.0 chunker
#Input: object and a $tagsent for tagger
sub getBlocks( $$ );
#Input: object and the output from getBlocks()
sub arrangeBlocks( $$ );
sub confchunker( $$ );
#Input: object and a $tagsent for tagger
sub chunker( $$ );

sub endProcessing( $ ) {
	my( $this ) = shift( @_ );
	my( $CONFTAG ) = $this->{"CONFTAG"};
	
	untie( %{ $CONFTAG->{"LEX"} } );
	untie( %{ $CONFTAG->{"AFX"} } );
	untie( %{ $CONFTAG->{"TBLMSD"} } ) if ( $CONFTAG->{"RECOVER"} == 1 );
	untie( %{ $CONFTAG->{"MSDSUFF"} } ) if ( $CONFTAG->{"RECOVER"} == 1 );
	untie( %{ $CONFTAG->{"MSDFREQ"} } ) if ( $CONFTAG->{"RECOVER"} == 1 );
}

sub readAbbrev( $$ ) {
	my( $this ) = shift( @_ );
	my( %abbr ) = ();

	open( ABBR, "< $_[0]" ) or die( "ttl::readAbbrev : could not open file !\n" );
	
	while ( my $line = <ABBR> ) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		$line =~ s/\r?\n$//;

		my( @toks ) = split( /\s+/, $line );

		#ver 7.1
		$abbr{$toks[0]} = length( $toks[0] );
	}

	close( ABBR );

	return \%abbr;
}

#5.0
sub readNERGrammar( $$ ) {
	my( $this ) = shift( @_ );
	my( $grmFile ) = $_[0];
	my( $nterm, $grmm ) = rxgram::parseGrammar( $grmFile );

	return { "NTERM" => $nterm, "GRAMMAR" => $grmm };
}

sub readNERFilter( $$ ) {
	my( $this ) = shift( @_ );
	my( $filterFile ) = $_[0];
	my( $lcnt ) = 0;
	my( %rxfilter ) = ();

	open( RXFLT, "< " . $filterFile ) or die( "ttl::readNERFilter : cannot open \'$filterFile\' !\n" );
	
	while ( my $line = <RXFLT> ) {
		$lcnt++;
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;

		next if ( $line =~ /^$/ || $line =~ /^#/ );

		if ( $line =~ /^apply\s+([^\s]+)\s+priority\s+([^\s]+)\s+ctag\s+([^\s]+)\s+msd\s+([^\s]+)\s+emsd\s+([^\s]+)$/ ) {
			my( $ssymb, $nice, $ctagval, $msdval, $emsdval ) = ( $1, $2, $3, $4, $5 );

			if ( exists( $rxfilter{$ssymb} ) ) {
				die( "ttl::readNERFilter : the start symbol \'$ssymb\' is duplicated @ line $lcnt !\n" );
			}
			else {
				$rxfilter{$ssymb} = { "CTAG" => $ctagval, "NICE" => $nice, "MSD" => $msdval, "EMSD" => $emsdval };
			}
		}
		elsif ( $line =~ /^skip\s+([^\s]+)\s+priority\s+([^\s]+)\s+ctag\s+([^\s]+)\s+msd\s+([^\s]+)\s+emsd\s+([^\s]+)$/ ) {
			#Nothing ... :)
		}
		else {
			die( "ttl::readNERFilter : syntax error @ line $lcnt !\n" );
		}
	}

	close( RXFLT );

	return \%rxfilter;
}
#end 5.0

sub confsentsplitter( $$ ) {
	my( $this ) = shift( @_ );
	my( %conf ) = %{ $_[0] };
	my( $CONFSSPLIT ) = $this->{"CONFSSPLIT"};

	#5.0
	if ( ! exists( $conf{"NERENG"} ) || ! defined( $conf{"NERENG"} ) ) {
		die( "ttl::confsentsplitter : config key NERENG has no value !\n" );
	}
	else {
		$CONFSSPLIT->{"NERENG"} = $conf{"NERENG"};
	}
	#end 5.0

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFSSPLIT->{$k} ) ) {
			SWK1: {
				$k eq "ABBREV" and do {
					$CONFSSPLIT->{$k} = $this->readAbbrev( $conf{$k} );
					last;
				};

				#5.0
				$k eq "NERGRMM" and do {
					if ( $CONFSSPLIT->{"NERENG"} ) {
						$CONFSSPLIT->{$k} = $this->readNERGrammar( $conf{$k} );
					}
					else {
						$CONFSSPLIT->{$k} = { "NTERM" => {}, "GRAMMAR" => {} };
					}
					last;
				};

				$k eq "NERFILT" and do {
					if ( $CONFSSPLIT->{"NERENG"} ) {
						$CONFSSPLIT->{$k} = $this->readNERFilter( $conf{$k} );
					}
					else {
						$CONFSSPLIT->{$k} = {};
					}
					
					last;
				};
				#end 5.0

				$CONFSSPLIT->{$k} = $conf{$k};
			}
		}
	}

	foreach my $k ( keys( %{ $CONFSSPLIT } ) ) {
		if ( ! defined( $CONFSSPLIT->{$k} ) ) {
			die( "ttl::confsentsplitter : config key $k has no value !\n" );
		}
	}
}

#start 5.5
sub sentsplitter( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFSSPLIT ) = $this->{"CONFSSPLIT"};
	
	my( $pcount ) = 0;
	my( %sent ) = ();
	my( $line ) = "\n";
	#Default: UNIX;
	my( $LINETERM ) = "\n";

	my( @sentbreakrxv ) = sort {
		return $CONFSSPLIT->{"SENTBREAK"}->{$a} <=> $CONFSSPLIT->{"SENTBREAK"}->{$b};
	} keys( %{ $CONFSSPLIT->{"SENTBREAK"} } );

	my( $sentbreakrx ) = join( "|", @sentbreakrxv );

	#Building close punct regular expression.
	my( %closephash ) = xces::getclosepHash();
	my( %closephash2 ) = ();

	foreach my $p ( keys( %closephash ) ) {
		my( $qmp ) = quotemeta( $p );

		$qmp = "(?:" . $qmp . ")";

		$closephash2{$qmp} = 1 / length( $p );
	}

	my( @closepunctrxv ) = sort {
		return $closephash2{$a} <=> $closephash2{$b};
	} keys( %closephash2 );
	my( $closepunctrx ) = join( "|", @closepunctrxv );

	#Building open punct regular expression.
	my( %openphash ) = xces::getopenpHash();
	my( %openphash2 ) = ();

	foreach my $p ( keys( %openphash ) ) {
		my( $qmp ) = quotemeta( $p );
		
		$qmp = "(?:" . $qmp . ")";

		$openphash2{$qmp} = 1 / length( $p );
	}

	my( @openpunctrxv ) = sort {
		return $openphash2{$a} <=> $openphash2{$b};
	} keys( %openphash2 );
	my( $openpunctrx ) = join( "|", @openpunctrxv );

	#Building openclose punct regular expression.
	my( %openclosephash ) = xces::getopenclosepHash();
	my( %openclosephash2 ) = ();

	foreach my $p ( keys( %openclosephash ) ) {
		my( $qmp ) = quotemeta( $p );
		
		$qmp = "(?:" . $qmp . ")";

		$openclosephash2{$qmp} = 1 / length( $p );
	}

	my( @openclosepunctrxv ) = sort {
		return $openclosephash2{$a} <=> $openclosephash2{$b};
	} keys( %openclosephash2 );
	my( $openclosepunctrx ) = join( "|", @openclosepunctrxv );

	open( TXT, "< $_[0]" ) or die( "ttl::sentsplitter : could not open file !\n" );
	binmode( TXT, ":utf8" );
	
	$line = <TXT>;
	( $LINETERM ) = ( $line =~ /(\r?\n)$/ );

	if ( ! defined( $LINETERM ) ) {
		#Default: UNIX;
		$LINETERM = "\n";
	}
	
	close( TXT );

	open( TXT, "< $_[0]" ) or die( "ttl::sentsplitter : could not open file !\n" );
	binmode( TXT, ":utf8" );
	
	$line = $LINETERM;
	
	my( $linenumber ) = 0;
	
	while ( 1 ) {
		do {
			$line = <TXT>;
			$linenumber++;
			$line =~ s/^${UTF8HEAD}// if ( defined( $line ) && $line ne "" );
		}
		while ( ! eof( TXT ) && $line =~ /^${LINETERM}$/ );
		last if ( eof( TXT ) && ! defined( $line ) );
		
		my( @mline ) = ();

		#If we find an empty line, increment the paragraph count.
		$pcount++;

		while ( ! eof( TXT ) && $line !~ /^${LINETERM}$/ ) {
			$line =~ s/${LINETERM}$//;
			push( @mline, $line );
			$line = <TXT>;
			$linenumber++;
			$line =~ s/^${UTF8HEAD}// if ( defined( $line ) && $line ne "" );
		}

		do {
			$line =~ s/${LINETERM}$//;
			push( @mline, $line );
		}
		if ( eof( TXT ) && $line !~ /^${LINETERM}$/ );

		my( @realsentences ) = ();
		my( @firstsplitting ) = ();
		
		#EOL splitting ...
		if ( $CONFSSPLIT->{"EOLSENTBREAK"} == 1 ) {
			@firstsplitting = @mline;
		}
		else {
			push( @firstsplitting, join( " ", @mline ) );
		}
		
		print( STDERR "ttl::sentsplitter : have read text up to line number $linenumber !\n" ) if ( $CONFSSPLIT->{"DEBUG"} );

		foreach my $sfs ( @firstsplitting ) {
			my( $s ) = $sfs;
			
			#Remove all double, triple ... spaces ...
			#NER does not work otherwise ...
			$s =~ s/ +/ /g;
			
			my( @sdiacs ) = ();
			my( @sabbrv ) = ();
			my( @sentty ) = ();

			#Get Named Entities ...
			if ( $CONFSSPLIT->{"NERENG"} == 1 ) {
				my( $nonterminals ) = $CONFSSPLIT->{"NERGRMM"}->{"NTERM"};
				my( $nergrammar ) = $CONFSSPLIT->{"NERGRMM"}->{"GRAMMAR"};
				my( $nerfilter ) = $CONFSSPLIT->{"NERFILT"};
				my( $nercount ) = 1;

				foreach my $nr ( sort { $nerfilter->{$a}->{"NICE"} <=> $nerfilter->{$b}->{"NICE"} } keys( %{ $nerfilter } ) ) {
					die( "ttl::sentsplitter : NER engine : symbol \'$nr\' is not defined at all !\n" )
						if ( ! exists( $nonterminals->{$nr} ) );
					die( "ttl::sentsplitter : NER engine : symbol \'$nr\' is not a NER rule (not a start symbol) !\n" )
						if ( exists( $nonterminals->{$nr} ) && $nonterminals->{$nr} != 1 );
					die( "ttl::sentsplitter : NER engine : symbol \'$nr\' is defined but it does not exist in the grammar (not a start symbol ... ?)\n" )
						if ( exists( $nonterminals->{$nr} ) && ! exists( $nergrammar->{$nr} ) );

					my( @nerrules ) = @{ $nergrammar->{$nr} };

					foreach my $rls ( @nerrules ) {
						while ( $s =~ /$rls/g ) {
							my( $leftm, $rightm ) = ( $1, $3 );

							push( @sentty, { "NERID" => "__NER_${nr}_${nercount}__", "NER" => $2 } );
							$s =~ s/$rls/$leftm __NER_${nr}_${nercount}__ $rightm/;
							$nercount++;
						}
					}
				}
			} #end NER ...
			
			my( $abbrcnt ) = 1;

			#Get abbreviations ...
			#S-ar putea sa trebuiasca sa pui in resurse Low case and Up case ...
			#ver 7.1 try the longer ones first ...
			foreach my $abbr ( sort { $CONFSSPLIT->{"ABBREV"}->{$b} <=> $CONFSSPLIT->{"ABBREV"}->{$a} } keys( %{ $CONFSSPLIT->{"ABBREV"} } ) ) {
				$abbr = quotemeta( $abbr );
							
				#6.2 no case sensitive ...
				#ver 6.81
				while ( $s =~ /[^0-9a-zA-Z&;_-](${abbr})[^0-9a-zA-Z&;_-]/i ) {
					push( @sabbrv, [ "__ABBR${abbrcnt}__", $1 ] );
					$s =~ s/([^0-9a-zA-Z&;_-])(${abbr})([^0-9a-zA-Z&;_-])/$1__ABBR${abbrcnt}__$3/i;
					$abbrcnt++;
				}

				#End and begin abbrev were not recognized ...
				if( $s =~ /^(${abbr})[^0-9a-zA-Z&;_-]/i ) {
					push( @sabbrv, [ "__ABBR${abbrcnt}__", $1 ] );
					$s =~ s/^(${abbr})([^0-9a-zA-Z&;_-])/__ABBR${abbrcnt}__$2/i;
					$abbrcnt++;
				}

				if( $s =~ /[^0-9a-zA-Z&;_-](${abbr})$/i ) {
					push( @sabbrv, [ "__ABBR${abbrcnt}__", $1 ] );
					$s =~ s/([^0-9a-zA-Z&;_-])(${abbr})$/$1__ABBR${abbrcnt}__/i;
					$abbrcnt++;
				}
			}

			#Get diacs
			@sdiacs = ( $s =~ /(&.+?;)/g );
			$s =~ s/&.+?;/__DIAC__/g;

			#Split the sentences around sentence break boundaries ...
			#Taking into account the open/close punctuation ...
			my( @containedsentences ) = ();
			my( $sbrkchars ) = '\.:;\?!';
			
			if ( $CONFSSPLIT->{"NOSPLIT"} == 0 ) {
				my( @sentboundaryevals ) = (
					'$s =~ s/([^#${sbrkchars}])(${sentbreakrx})\s*((?:${openclosepunctrx}|${closepunctrx}))\s*(${sentbreakrx})([^#${sbrkchars}]|$)/$1#$2#$3#__SSPLITHERE__#$4#$5/g;',
					'$s =~ s/([^#${sbrkchars}])(${sentbreakrx})\s*(${openclosepunctrx})\s*(${openclosepunctrx})([^#${sbrkchars}]|$)/$1#$2#$3#__SSPLITHERE__#$4#$5/g;',
					'$s =~ s/([^#${sbrkchars}])(${sentbreakrx})\s*(${openclosepunctrx})([^#${sbrkchars}]|$)/$1#$2#__SSPLITHERE__#$3#$4/g;',
					'$s =~ s/([^#${sbrkchars}])(${openclosepunctrx})\s*(${sentbreakrx})([^#${sbrkchars}]|$)/$1#$2#$3#__SSPLITHERE__#$4/g;',
					'$s =~ s/([^#${sbrkchars}])(${closepunctrx})\s*(${sentbreakrx})([^#${sbrkchars}]|$)/$1#$2#$3#__SSPLITHERE__#$4/g;',
					'$s =~ s/([^#${sbrkchars}])(${sentbreakrx})\s*(${closepunctrx})([^#${sbrkchars}]|$)/$1#$2#$3#__SSPLITHERE__#$4/g;',
					'$s =~ s/([^#${sbrkchars}])(${sentbreakrx})([^#${sbrkchars}]|$)/$1#$2#__SSPLITHERE__#$3/g;'
				);
				
				for ( my $i = 0; $i < scalar( @sentboundaryevals ); $i++ ) {
					eval $sentboundaryevals[$i];
				}
				
				@containedsentences = split( /__SSPLITHERE__/, $s );
			}
			else {
				@containedsentences = ( $s );
			}
			
			#Fixing replacements ...
			foreach my $cs ( @containedsentences ) {
				$cs =~ s/#/ /g;
			}

			#Reinsert diacs ...
			foreach my $cs ( @containedsentences ) {
				while ( $cs =~ /__DIAC__/ ) {
					my( $nextdiac ) = shift( @sdiacs );

					$cs =~ s/__DIAC__/$nextdiac/;
				}
			}

			#Reinsert abbreviations ...
			foreach my $ab ( @sabbrv ) {
				my( $abbrstr, $abbr ) = @{ $ab };
				
				$abbr =~ s/\s+/_/g;
				
				foreach my $cs ( @containedsentences ) {
					while ( $cs =~ /$abbrstr/ ) {
						if ( $CONFSSPLIT->{"NERANN"} == 1 ) {
							my( $xmlinfo ) = "<entity nerss=\"none\" ctag=\"Y\" ana=\"Yn\" eana=\"Ed\">$abbr</entity>";

							$cs =~ s/$abbrstr/$xmlinfo/;
						}
						else {
							$cs =~ s/$abbrstr/$abbr/;
						}
					}
				}
			}
			

			#Reinsert NERs ...
			NEXTNER:
			foreach my $ner ( @sentty ) {
				#'LM' => ' '
				#'NER' => '#5m'
				#'NERID' => '__NER(IntegerS)_14__'
				#'RM' => ' '					
				my( $nerid, $nerstr ) = ( $ner->{"NERID"}, $ner->{"NER"} );
				my( $nernt ) = ( $nerid =~ /__NER_([^_]+)_/ );

				$nerstr =~ s/\s+/_/g;

				foreach my $cs ( @containedsentences ) {
					if ( $cs =~ /$nerid/ ) {
						if ( $CONFSSPLIT->{"NERANN"} == 1 ) {
							my( $ctag, $msd, $emsd ) = ( $CONFSSPLIT->{"NERFILT"}->{$nernt}->{"CTAG"}, $CONFSSPLIT->{"NERFILT"}->{$nernt}->{"MSD"}, $CONFSSPLIT->{"NERFILT"}->{$nernt}->{"EMSD"} );
							my( $xmlinfo ) = "<entity nerss=\"$nernt\" ctag=\"$ctag\" ana=\"$msd\" eana=\"$emsd\">$nerstr</entity>";

							$cs =~ s/$nerid/$xmlinfo/;

							next NEXTNER;
						}
						else {
							$cs =~ s/$nerid/$nerstr/;

							next NEXTNER;
						}
					}
				}
			}

			#Done ...
			push( @realsentences, @containedsentences );
		}
		
		my( @finalsentences ) = ();
		
		#Ultimele prelucrari ...
		for ( my $i = 0; $i < scalar( @realsentences ); $i++ ) {
			#Eliminam spatiile duble sau triple ...
			$realsentences[$i] =~ s/ +/ /g;
			$realsentences[$i] =~ s/^\s+//;
			$realsentences[$i] =~ s/\s+$//;
			
			next if ( $realsentences[$i] =~ /^\r?\n?$/ );

			#Despartim sentence break daca e cazul ...
			#ver 6.80
			if ( $realsentences[$i] =~ /${sentbreakrx}$/ && $realsentences[$i] !~ /\s${sentbreakrx}$/ ) {
				if ( $realsentences[$i] =~ /(?:^|\s)(.+;)$/ ) {
					my( $lastword ) = $1;
					my( $noamp, $nosemi ) = ( 0, 0 );

					$noamp = ( $lastword =~ s/&/&/g );
					$nosemi = ( $lastword =~ s/;/;/g );

					if ( $noamp == 0 || $noamp != $nosemi ) {
						$realsentences[$i] =~ s/(${sentbreakrx})$/ $1/;
					}
				}
				else {
					$realsentences[$i] =~ s/(${sentbreakrx})$/ $1/;
				}
			}
			
			if ( $realsentences[$i] =~ /^(?:(?:${openclosepunctrx})|(?:${closepunctrx})|(?:${sentbreakrx}))$/ && scalar( @finalsentences ) > 0 ) {
				$finalsentences[$#finalsentences] .= " " . $realsentences[$i];
				next;
			}
			
			push( @finalsentences, $realsentences[$i] );
		}
		
		#Fill in the %sent hash ...
		for ( my $i = 0; $i < scalar( @finalsentences ); $i++ ) {
			if ( ! exists( $sent{$pcount} ) ) {
				$sent{$pcount} = { $i + 1 => $finalsentences[$i] };
			}
			else {
				$sent{$pcount}->{$i + 1} = $finalsentences[$i];
			}
		}
	} #end of input ...

	#7.61
	close( TXT );
	return \%sent;
}
#end 5.5

sub readMergeStrings( $$ ) {
	my( $this ) = shift( @_ );
	my( %merge ) = ( "LENGTH" => 0 );

	open( MRG, "< $_[0]" ) or die( "ttl::readMergeStrings : could not open file !\n" );
	
	while ( my $line = <MRG> ) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		$line =~ s/\r?\n$//;

		my( @toks ) = split( /\s+/, $line );
		my( @complenv ) = split( /_/, $toks[0] );
		my( $complen ) = scalar( @complenv );

		$merge{$toks[0]} = 1;
		
		if ( $merge{"LENGTH"} < $complen ) {
			$merge{"LENGTH"} = $complen;
		}
	}

	close( MRG );

	return \%merge;
}

sub readSplitStrings( $$ ) {
	my( $this ) = shift( @_ );
	my( %splt ) = ( "RIGHT" => { "_RL" => 0 }, "LEFT" => { "_LL" => 0 }, "COMP" => {}, "MSPLIT" => {} );

	open( SPLIT, "< $_[0]" ) or die( "ttl::readSplitStrings : could not open file !\n" );
	
	while ( my $line = <SPLIT> ) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		$line =~ s/\r?\n$//;

		my( @toks ) = split( /\s+/, $line );

		if ( $toks[1] eq "RIGHTSPLIT" ) {
			$splt{"RIGHT"}->{$toks[0]} = 1;

			if ( length( $toks[0] ) > $splt{"RIGHT"}->{"_RL"} ) {
				$splt{"RIGHT"}->{"_RL"} = length( $toks[0] );
			}
		}
		elsif ( $toks[1] eq "LEFTSPLIT" ) {
			$splt{"LEFT"}->{$toks[0]} = 1;

			if ( length( $toks[0] ) > $splt{"LEFT"}->{"_LL"} ) {
				$splt{"LEFT"}->{"_LL"} = length( $toks[0] );
			}
		}
		elsif ( $toks[1] eq "COMPOUND" ) {
			$splt{"COMP"}->{$toks[0]} = 1;
		}
		#5.6
		elsif ( $toks[1] eq "MARKERSPLIT" ) {
			my( @splwords ) = split( /#/, $toks[0] );
			my( $msword ) = join( "", @splwords );
			
			$splt{"MSPLIT"}->{$msword} = \@splwords;
		}
	}
	
	close( SPLIT );

	return \%splt;
}

sub conftokenizer( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFTOK ) = $this->{"CONFTOK"};
	my( %conf ) = %{ $_[0] };

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFTOK->{$k} ) ) {
			SWK2: {
				$k eq "MERGE" and do {
					$CONFTOK->{$k} = $this->readMergeStrings( $conf{$k} );
					last;
				};

				$k eq "SPLIT" and do {
					$CONFTOK->{$k} = $this->readSplitStrings( $conf{$k} );
					last;
				};

				$CONFTOK->{$k} = $conf{$k};
			}
		}
	}

	foreach my $k ( keys( %{ $CONFTOK } ) ) {
		if ( ! defined( $CONFTOK->{$k} ) ) {
			die( "ttl::conftokenizer : config key $k has no value !\n" );
		}

		if ( $k eq "PUNCTSPLIT" ) {
			my( %phash ) = xces::getpHash();
			my( %punctsplhash ) = ();

			foreach my $p ( keys( %phash ) ) {
				my( $qmp ) = quotemeta( $p );

				$punctsplhash{$qmp} = 1 / length( $p );
			}

			$CONFTOK->{$k} = \%punctsplhash;
		}
	}
}

sub tokenizer( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFSSPLIT ) = $this->{"CONFSSPLIT"};
	my( $CONFTOK ) = $this->{"CONFTOK"};
	my( $CONFTAG ) = $this->{"CONFTAG"};
	#5.0 ...
	my( $inputsentencestring ) = $_[0];
	my( @sspltners ) = ( $inputsentencestring =~ /(<entity .+?<\/entity>)/g );

	#8.4
	$inputsentencestring =~ s/<entity .+?<\/entity>/ TTL_NAMED_ENTITY /g;
	#8.9
	$inputsentencestring =~ s/^\s+//;
	$inputsentencestring =~ s/\s+$//;
	
	my( @sentencerpl ) = split( /\s+/, $inputsentencestring );
	#end 5.0 ...
	
	#This splits punctuation and what is in SPLIT conf key from any given word.
	my( $subsplit ) = sub {
		my( @insent ) = @{ $_[0] };
		my( @outsent11 ) = ();
		my( @outsent1 ) = ();
		my( @outsent2 ) = ();

		my( @sentbreakrxv ) = sort {
			return $CONFSSPLIT->{"SENTBREAK"}->{$a} <=> $CONFSSPLIT->{"SENTBREAK"}->{$b};
		} keys( %{ $CONFSSPLIT->{"SENTBREAK"} } );
		my( @punctsplitrxv ) = sort {
			return $CONFTOK->{"PUNCTSPLIT"}->{$a} <=> $CONFTOK->{"PUNCTSPLIT"}->{$b};
		} keys( %{ $CONFTOK->{"PUNCTSPLIT"} } );

		my( $punctsplitrx ) = join( "|", @punctsplitrxv );
		my( $sentbreakrx ) = join( "|", @sentbreakrxv );
		my( $splitpflag ) = 1;
		
		my( %wordchars2 ) = xces::getwordpHash();
		my( %wordchars ) = ( "[0-9A-Za-z_]" => 1 );

		foreach my $p ( keys( %wordchars2 ) ) {
			my( $qmp ) = quotemeta( $p );

			$wordchars{$qmp} = 1 / length( $p );
		}

		my( @wordpunctrxv ) = sort {
			return $wordchars{$a} <=> $wordchars{$b};
		} keys( %wordchars );
		my( $wordcharsrx ) = join( "|", @wordpunctrxv );

		#ver 7.2
		my( @specpunct ) = ();
		
		foreach my $pct ( sort { length( $b ) <=> length( $a ) } keys( %{ $CONFTOK->{"PUNCTSPLIT"} } ) ) {
			if ( $pct =~ /^\\&.+\\;$/ ) {
				push( @specpunct, $pct );
			}
		}
		
		my( $specialpunctrx ) = join( "|", @specpunct );
		
		#ver 9.0
		my @punctsplitordered = xces::getopencloseQuoteOrdering();
		
		foreach my $pct ( keys( %{ $CONFTOK->{"PUNCTSPLIT"} } ) ) {
			if ( $pct =~ /^\\&.+\\;$/ ) {
				if ( ! grep( /$pct/, @punctsplitordered ) ) {
					my $temp_pct = $pct;
					
					$temp_pct =~ s/\\//g;
					push( @punctsplitordered, $temp_pct );
				}
			}
		}
		
		foreach my $pct ( @punctsplitordered ) {
			$pct = quotemeta( $pct );
		}
		
		#Split the punctuation at the word boundaries...
		#Aici va trebui sa aplici procesul asta repetitiv pana cand nu mai ai ce splitui.
		while ( $splitpflag ) {
			$splitpflag = 0;
			@outsent11 = ();

			foreach my $w ( @insent ) {
				#Ca sa nu mai sparga punctuatia cand e singura.
				if ( $w =~ /^(?:${punctsplitrx})$/ || $w =~ /^(?:${sentbreakrx})$/ ) {
					push( @outsent11, $w );
					next;
				}

				#Ca sa nu mai sparga punctuatia cand e vorba de un split deja facut ...
				#4.3
				if ( exists( $CONFTOK->{"SPLIT"}->{"COMP"}->{$w} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"COMP"}->{lc( $w )} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"RIGHT"}->{$w} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"RIGHT"}->{lc( $w )} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"LEFT"}->{$w} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"LEFT"}->{lc( $w )} )
				) {
					push( @outsent11, $w );
					next;
				}

				my( $nodiacw ) = $w;

				# ver 7.2
				# ver 9.0
				# Ai grija sa inlocuiesti punctuatia pereche, e.g. &laquo; ... &raquo; in aceeasi ordine!
				my( @punctdiacs ) = ();
				
				foreach my $pct ( @punctsplitordered ) {
					if ( $pct =~ /^\\&.+\\;$/ ) {
						my( @pcts ) = ( $nodiacw =~ /($pct)/g );
						
						push( @punctdiacs, @pcts );
						$nodiacw =~ s/$pct/PUNCTHEREMAN/g
					}
				}
				
				my( @diacs ) = ( $nodiacw =~ /(&.+?;)/g );

				#Bucata asta e ca sa nu splituim ; de la sfarsitul unui diacritic.
				#4.5 replaced with DIAC HERE MAN ! :))
				$nodiacw =~ s/&.+?;/DIACHEREMAN/g;
								
				# ver 7.2
				foreach my $pd ( @punctdiacs ) {
					$nodiacw =~ s/PUNCTHEREMAN/$pd/;
				}

				# ver 8.6
				my( $leftpunct, $wres, $rightpunct ) = ( $nodiacw =~ /^(${punctsplitrx})?(.*?)(${punctsplitrx})?$/ );

				foreach my $d ( @diacs ) {
					$wres =~ s/DIACHEREMAN/$d/;
				}

				if ( defined( $leftpunct ) || defined( $rightpunct ) ) {
					$splitpflag = 1;
				}

				foreach my $ww ( $leftpunct, $wres, $rightpunct ) {
					if ( defined( $ww ) ) {
						push( @outsent11, $ww );
					}
				}
			} #end current iteration

			@insent = @outsent11;
		} #end split punctuation

		#Scoatem punctele din cuvinte ...
		foreach my $w11 ( @outsent11 ) {
			my( @pctwords ) = split( /(${specialpunctrx})/, $w11 );
			
			foreach my $w ( @pctwords ) {
				next if ( ! defined( $w ) || $w eq "" );
				
				if ( $w =~ /^${specialpunctrx}$/ ) {
					push( @outsent1, $w );
					next;
				}
				
				if ( $w =~ /^(?:${wordcharsrx})+$/ ) {
					push( @outsent1, $w );
					next;
				}

				my( @wchars ) = ( $w =~ /(${wordcharsrx})/g );
				my( $tw ) = $w;

				$tw =~ s/${wordcharsrx}/__WCHR__/g;

				my( @pnewwords ) = split( /((?:__WCHR__)+)/, $tw );
				
				if ( scalar( @pnewwords ) > 1 ) {

					foreach my $pnw ( @pnewwords ) {
						next if ( ! defined( $pnw ) || $pnw eq "" );
						
						if ( $pnw !~ /__WCHR__/ ) {
							#Daca sunt mai multe puncte la un loc, le splituim.
							push( @outsent1, split( //, $pnw ) );
						}
						else {
							while ( $pnw =~ /__WCHR__/ ) {
								my( $nwchar ) = shift( @wchars );

								$pnw =~ s/__WCHR__/$nwchar/;
							}

							push( @outsent1, $pnw );
						}
					}
				}
				else {
					push( @outsent1, $w );
				}
			} #end split after special punct ...
		} #end all words ...

		my( $splitflag ) = 1;
		my( $leftpreflen ) = $CONFTOK->{"SPLIT"}->{"LEFT"}->{"_LL"};
		my( $rightpreflen ) = $CONFTOK->{"SPLIT"}->{"RIGHT"}->{"_RL"};

		while ( $splitflag ) {
			$splitflag = 0;

			@outsent2 = ();

			#Split the words ...
			WORD:
			foreach my $w ( @outsent1 ) {
				my( @letw ) = split( //, $w );

				#5.6
				if ( exists( $CONFTOK->{"SPLIT"}->{"MSPLIT"}->{$w} ) ) {
					my( @mswords ) = @{ $CONFTOK->{"SPLIT"}->{"MSPLIT"}->{$w} };
					
					foreach my $sw ( @mswords ) {
						my( @letsw ) = split( //, $sw );
						
						foreach my $swl ( @letsw ) {
							if ( shift( @letw ) ne $swl ) {
								$swl = uc( $swl );
							}
						}
						
						$sw = join( "", @letsw );
					}
					
					push( @outsent2, @mswords );
					next;
				}
				elsif ( exists( $CONFTOK->{"SPLIT"}->{"MSPLIT"}->{lc( $w )} ) ) {
					my( @mswords ) = @{ $CONFTOK->{"SPLIT"}->{"MSPLIT"}->{lc( $w )} };

					foreach my $sw ( @mswords ) {
						my( @letsw ) = split( //, $sw );
						
						foreach my $swl ( @letsw ) {
							if ( shift( @letw ) ne $swl ) {
								$swl = uc( $swl );
							}
						}
						
						$sw = join( "", @letsw );
					}
					
					push( @outsent2, @mswords );
					next;
				}
				#end 5.6

				if ( exists( $CONFTOK->{"SPLIT"}->{"COMP"}->{$w} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"COMP"}->{lc( $w )} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"RIGHT"}->{$w} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"RIGHT"}->{lc( $w )} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"LEFT"}->{$w} ) ||
					 exists( $CONFTOK->{"SPLIT"}->{"LEFT"}->{lc( $w )} )
				) {
					push( @outsent2, $w );
					next;
				}

				for ( my $i = 0; $i < scalar( @letw ) && $i < $leftpreflen; $i++ ) {
					my( $leftpref ) = join( "", @letw[0 .. $i] );

					if ( exists( $CONFTOK->{"SPLIT"}->{"LEFT"}->{$leftpref} ) ) {
						push( @outsent2, $leftpref );
						push( @outsent2, join( "", @letw[$i + 1 .. $#letw] ) );
						$splitflag = 1;
						next WORD;
					}

					#Lowercase case ... ver 3.4
					if ( exists( $CONFTOK->{"SPLIT"}->{"LEFT"}->{lc( $leftpref )} ) ) {
						push( @outsent2, $leftpref );
						push( @outsent2, join( "", @letw[$i + 1 .. $#letw] ) );
						$splitflag = 1;
						next WORD;
					}
				}

				for ( my $i = $#letw; $i >= 0 && $#letw - $i + 1 <= $rightpreflen; $i-- ) {
					my( $rightpref ) = join( "", @letw[$i .. $#letw] );

					if ( exists( $CONFTOK->{"SPLIT"}->{"RIGHT"}->{$rightpref} ) ) {
						push( @outsent2, join( "", @letw[0 .. $i - 1] ) );
						push( @outsent2, $rightpref );
						$splitflag = 1;
						next WORD;
					}
					
					#Lowercase case ... ver 3.4
					if ( exists( $CONFTOK->{"SPLIT"}->{"RIGHT"}->{lc( $rightpref )} ) ) {
						push( @outsent2, join( "", @letw[0 .. $i - 1] ) );
						push( @outsent2, $rightpref );
						$splitflag = 1;
						next WORD;
					}
				}

				push( @outsent2, $w );
			}

			@outsent1 = @outsent2;
		} #end split flag ...

		return @outsent2;
	}; #end SPLIT sub.
	
	#This recognizes the compounds in the splitted sentence.
	my( $submerge ) = sub {
		my( @insent ) = @{ $_[0] };
		my( @outsent ) = ();
		my( $winlen ) = $CONFTOK->{"MERGE"}->{"LENGTH"};

		NEXTI:
		for ( my $i = 0; $i < scalar( @insent ); $i++ ) {
			my( @window ) = ();

			for ( my $j = $i; $j < $i + $winlen && $j < scalar( @insent ); $j++ ) {
				push( @window, $insent[$j] );
			}

			for ( my $j = $#window; $j > 0; $j-- ) {
				my( $compcand ) = join( "_", @window[0 .. $j] );

				if ( exists( $CONFTOK->{"MERGE"}->{$compcand} ) ) {
					push( @outsent, $compcand );
					$i = $j + $i;
					next NEXTI;
				}
			}

			push( @outsent, $insent[$i] );
		}

		return @outsent;
	};

	#This recognizes certain regular expression matched tokens.
	#Not implemented yet.
	my( $subner ) = sub {
		my( @insent ) = @{ $_[0] };
		my( @outsent ) = ();
		my( %phash ) = xces::getpHash();

		my( @sentbreakrxv ) = sort {
			return $CONFSSPLIT->{"SENTBREAK"}->{$a} <=> $CONFSSPLIT->{"SENTBREAK"}->{$b};
		} keys( %{ $CONFSSPLIT->{"SENTBREAK"} } );
		my( @punctsplitrxv ) = sort {
			return $CONFTOK->{"PUNCTSPLIT"}->{$a} <=> $CONFTOK->{"PUNCTSPLIT"}->{$b};
		} keys( %{ $CONFTOK->{"PUNCTSPLIT"} } );
		
		my( $sentbreakrx ) = join( "|", @sentbreakrxv );
		my( $punctsplitrx ) = join( "|", @punctsplitrxv );

		my( @toktags ) = ();
		my( @nertags ) = ();

		foreach my $t ( @insent ) {
			#5.6
			if ( $t =~ /^<entity/ ) {
				#<entity nerss="AddressS" ctag="NNP" ana="Np" eana="Edla">Joe\'s_Restaurant,_1023_Abbot_Kinney_Blvd.,_Venice</entity>
				my( $nernt, $ctag, $ana, $eana, $nerstr ) = ( $t =~ /^<entity nerss=\"(.+?)\" ctag=\"(.+?)\" ana=\"(.+?)\" eana=\"(.+?)\">(.+?)<\/entity>$/ );
				
				push( @outsent, $nerstr );	
				push( @toktags, $ctag );
				push( @nertags, $ana . "," . $eana );
				
				next;
			}
			
			push( @outsent, $t );
			push( @nertags, undef() );

			#Name heuristics ...
			if ( $CONFTOK->{"ENABLENAMEHEUR"} && exists( $CONFTAG->{"LEX"} ) && defined( $CONFTAG->{"LEX"} ) ) {
				#ver 2.0
				if ( ! $this->lexExistsWordInDB( $CONFTAG->{"LEX"}, $t ) && ! $this->lexExistsWordInDB( $CONFTAG->{"LEX"}, lc( $t ) ) ) {
				#end 2.0
					my( $l1, $l2 ) = split( //, $t );

					if ( $l1 =~ /^[A-Z]$/ || $l2 =~ /^[A-Z]$/ ) {
						push( @toktags, $CONFTOK->{"NAMETAG"} );
						next;
					}
				}
			}

			if ( $t =~ /^${punctsplitrx}$/ || $t =~ /^${sentbreakrx}$/ ) {
				push( @toktags, $phash{$t} );
				next;
			}

			push( @toktags, undef() );
		}

		return ( \@outsent, \@toktags, \@nertags );
	};

	my( @tokenizertags ) = ();
	my( @namedentytags ) = ();

	foreach my $op ( @{ $CONFTOK->{"OPORDER"} } ) {
		@sentencerpl = $subsplit->( \@sentencerpl ) if ( $op eq "split" && $CONFTOK->{"NOTOK"} == 0 );
		@sentencerpl = $submerge->( \@sentencerpl ) if ( $op eq "merge" && $CONFTOK->{"NOTOK"} == 0 );
	}
	
	#5.6
	my( @sentencener ) = @sentencerpl;

	foreach my $w ( @sentencener ) {
		if ( $w eq "TTL_NAMED_ENTITY" ) {
			$w = shift( @sspltners );
		}
	}
	#end 5.6

	return $subner->( \@sentencener );
}

{
	my( $pcount ) = 0;

	sub initmtsegout() {
		$pcount = 0;
	}

	sub endmtsegout() {
		return ( "\t)SENT\t</S>\n", "\t)PAR\t</P>\n" );
	}

	#Paragraph id and sentence id must be integers > 0 !!
	sub mtsegoutput( $$$$ ) {
		my( $this ) = shift( @_ );
		my( $CONFSSPLIT ) = $this->{"CONFSSPLIT"};
		my( $CONFTOK ) = $this->{"CONFTOK"};
		my( $p, $s ) = ( $_[0], $_[1] );
		my( @sent ) = @{ $_[2] };
		my( @mtsegout ) = ();

		my( @sentbreakrxv ) = sort {
			return $CONFSSPLIT->{"SENTBREAK"}->{$a} <=> $CONFSSPLIT->{"SENTBREAK"}->{$b};
		} keys( %{ $CONFSSPLIT->{"SENTBREAK"} } );

		my( @punctsplitrxv ) = sort {
			return $CONFTOK->{"PUNCTSPLIT"}->{$a} <=> $CONFTOK->{"PUNCTSPLIT"}->{$b};
		} keys( %{ $CONFTOK->{"PUNCTSPLIT"} } );
		
		my( $sentbreakrx ) = join( "|", @sentbreakrxv );
		my( $punctsplitrx ) = join( "|", @punctsplitrxv );


		if ( $pcount == 0 ) {
			push( @mtsegout, "\t(PAR\t<P FROM=\"$p\">\n" );
			push( @mtsegout, "\t(SENT\t<S FROM=\"$p.$s\">\n" );

			$pcount = $p;
		}
		elsif ( $pcount == $p ) {
			push( @mtsegout, "\t)SENT\t</S>\n" );
			push( @mtsegout, "\t(SENT\t<S FROM=\"$p.$s\">\n" );
		}
		elsif ( $pcount < $p ) {
			push( @mtsegout, "\t)SENT\t</S>\n" );
			push( @mtsegout, "\t)PAR\t</P>\n" );
			push( @mtsegout, "\t(PAR\t<P FROM=\"$p\">\n" );
			push( @mtsegout, "\t(SENT\t<S FROM=\"$p.$s\">\n" );
		}

		my( $charcount ) = 1;

		foreach my $w ( @sent ) {
			my( $toktype ) = "TOK";

			SWTOKTYPE: {
				( $w =~ /^(?:${sentbreakrx})$/ || $w =~ /^(?:${punctsplitrx})$/ ) and $toktype = "PUNCT";
				exists( $CONFSSPLIT->{"ABBREV"}->{$w} ) and $toktype = "ABBR";
				exists( $CONFTOK->{"SPLIT"}->{"LEFT"}->{$w} ) and $toktype = "LSPLIT";
				exists( $CONFTOK->{"SPLIT"}->{"RIGHT"}->{$w} ) and $toktype = "RSPLIT";
				exists( $CONFTOK->{"SPLIT"}->{"COMP"}->{$w} ) and $toktype = "COMP";
				exists( $CONFTOK->{"MERGE"}->{$w} ) and $toktype = "COMP";
			}

			push( @mtsegout, 
				$p . "." . $s . "/" . $charcount . "\t" .
				$toktype . "\t" . 
				$w . "\n"
			);

			$charcount += length( $w ) + 1;
		}

		return @mtsegout;
	}
}

sub extractSuffix( $$$ ) {
	my( $this ) = shift( @_ );
	my( $word, $k ) = ( $_[0], $_[1] );
	my( @wordletters ) = split( //, $word );
	my( @suff ) = ();
	my( $kcount ) = 0;

	for ( my $i = $#wordletters; $i >= 0; $i-- ) {
		if ( $wordletters[$i] ne ";" && $wordletters[$i] ne "&" ) {
			unshift( @suff, $wordletters[$i] );
			$kcount++;
		}
		elsif ( $wordletters[$i] eq ";" ) {
			my( $diac ) = "";

			while ( $i >= 0 && $wordletters[$i] ne "&" ) {
				$diac = $wordletters[$i] . $diac;
				$i--;
			}

			if ( $i >= 0 ) {
				$diac = "&" . $diac;
				unshift( @suff, $diac );
				$kcount++;
			}
		}

		last if ( $kcount == $k );
	}

	return join( "", @suff );
}

#ver 3.0
#ver 2.0
sub lexAddWordToDB( $$$$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $word, $tag, $freq ) = ( $_[0], $_[1], $_[2], $_[3] );

	if ( ! exists( $dbh->{$word} ) ) {
		$dbh->{$word} = $tag . ":" . $freq;
	}
	else {
		my( $values ) = $dbh->{$word};
		my( @pairs ) = split( /,/, $values );
		my( @newpairs ) = ();
		my( $foundtag ) = 0;

		foreach my $p ( @pairs ) {
			my( $t, $f ) = split( /:/, $p );

			if ( $t eq $tag ) {
				$f += $freq;
				$foundtag = 1;
			}

			push( @newpairs, $t . ":" . $f );
		}

		push( @newpairs, $tag . ":" . $freq ) if ( ! $foundtag );

		$dbh->{$word} = join( ",", @newpairs );
	}
}

sub lexExistsWordInDB( $$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $word ) = ( $_[0], $_[1] );

	return exists( $dbh->{$word} );
}

sub lexExistsWordWithTagInDB( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $word, $tag ) = ( $_[0], $_[1], $_[2] );

	if ( ! exists( $dbh->{$word} ) ) {
		return 0;
	}

	my( $values ) = $dbh->{$word};
	my( @pairs ) = split( /,/, $values );

	foreach my $p ( @pairs ) {
		my( $t, $f ) = split( /:/, $p );

		return 1 if ( $t eq $tag );
	}

	return 0;
}

sub lexGetInfoFromDB( $$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $word ) = ( $_[0], $_[1] );

	if ( ! exists( $dbh->{$word} ) ) {
		return {};
	}

	my( $values ) = $dbh->{$word};
	my( @pairs ) = split( /,/, $values );
	my( %info ) = ();

	foreach my $p ( @pairs ) {
		my( $t, $f ) = split( /:/, $p );

		$info{$t} = $f;
	}

	return \%info;
}

sub lexGetFreqFromDB( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $word, $tag ) = ( $_[0], $_[1], $_[2] );

	if ( ! exists( $dbh->{$word} ) ) {
		return undef();
	}

	my( $values ) = $dbh->{$word};
	my( @pairs ) = split( /,/, $values );
	my( %info ) = ();

	foreach my $p ( @pairs ) {
		my( $t, $f ) = split( /:/, $p );

		$info{$t} = $f;
	}

	if ( ! exists( $info{$tag} ) ) {
		return undef();
	}

	return $info{$tag};
}
#end 2.0
#end 3.0

#Input: lex file and suff file.
#ver 3.0
sub readLexicon( $$$$ ) {
	my( $this ) = shift( @_ );
	my( %lexicon ) = ();
	my( %sufftree ) = ();
	my( $lexdbFile ) = $_[0];
	my( $suffdbFile ) = $_[1];
	my( $updateproc ) = $_[2];
	my( $lexbdobj, $suffbdobj ) = ( undef(), undef() );

	if ( defined( $lexdbFile ) && $lexdbFile ne "" ) {
		SWUPD: {
			#Ok ...
			( -f( $lexdbFile ) && $updateproc eq "fresh" ) and do {
				$lexbdobj = tie( %lexicon, "BerkeleyDB::Hash", "-Filename" => $lexdbFile, "-Flags" => DB_TRUNCATE, "-Mode" => 0666 );
				last;
			};

			#Ok.
			( -f( $lexdbFile ) && $updateproc eq "update" ) and do {
				$lexbdobj = tie( %lexicon, "BerkeleyDB::Hash", "-Filename" => $lexdbFile, "-Mode" => 0666 );
				last;
			};

			#Ok.
			( ! -f( $lexdbFile ) && $updateproc eq "fresh" ) and do {
				$lexbdobj = tie( %lexicon, "BerkeleyDB::Hash", "-Filename" => $lexdbFile, "-Flags" => DB_CREATE, "-Mode" => 0666 );
				last;
			};

			#Ok.
			( ! -f( $lexdbFile ) && $updateproc eq "update" ) and do {
				$lexbdobj = tie( %lexicon, "BerkeleyDB::Hash", "-Filename" => $lexdbFile, "-Flags" => DB_CREATE, "-Mode" => 0666 );
			};
		}

		if ( ! defined( $lexbdobj ) ) {
			die( "ttl::readLexicon() : cannot open file \'$lexdbFile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
		}
	}
	else {
		die( "ttl::readLexicon() : not defined file name LEX !\n" );
	}

	if ( defined( $suffdbFile ) && $suffdbFile ne "" ) {
		SWUPD: {
			#Ok ...
			( -f( $suffdbFile ) && $updateproc eq "fresh" ) and do {
				$suffbdobj = tie( %sufftree, "BerkeleyDB::Hash", "-Filename" => $suffdbFile, "-Flags" => DB_TRUNCATE, "-Mode" => 0666 );
				last;
			};

			#Ok.
			( -f( $suffdbFile ) && $updateproc eq "update" ) and do {
				$suffbdobj = tie( %sufftree, "BerkeleyDB::Hash", "-Filename" => $suffdbFile, "-Mode" => 0666 );
				last;
			};

			#Ok.
			( ! -f( $suffdbFile ) && $updateproc eq "fresh" ) and do {
				$suffbdobj = tie( %sufftree, "BerkeleyDB::Hash", "-Filename" => $suffdbFile, "-Flags" => DB_CREATE, "-Mode" => 0666 );
				last;
			};

			#Ok.
			( ! -f( $suffdbFile ) && $updateproc eq "update" ) and do {
				$suffbdobj = tie( %sufftree, "BerkeleyDB::Hash", "-Filename" => $suffdbFile, "-Flags" => DB_CREATE, "-Mode" => 0666 );
			};
		}

		if ( ! defined( $suffbdobj ) ) {
			die( "ttl::readLexicon() : cannot open file \'$suffdbFile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
		}
	}
	else {
		die( "ttl::readLexicon() : not defined file name AFX !\n" );
	}

	#ver 3.1
	my( $N ) = ( exists( $lexicon{"<N>"} ) ? $lexicon{"<N>"} : 0 );
	my( $theta ) = ( exists( $lexicon{"<THETA>"} ) ? $lexicon{"<THETA>"} : 0 );
	my( $lambda1 ) = ( exists( $lexicon{"<LAMBDA1>"} ) ? $lexicon{"<LAMBDA1>"} : 0 );
	my( $lambda2 ) = ( exists( $lexicon{"<LAMBDA2>"} ) ? $lexicon{"<LAMBDA2>"} : 0 );
	my( $lambda3 ) = ( exists( $lexicon{"<LAMBDA3>"} ) ? $lexicon{"<LAMBDA3>"} : 0 );
	#end 3.1

	return {
		"LEX" => \%lexicon,
		"AFX" => \%sufftree,
		"N" => $N,
		"THETA" => $theta,
		"LAMBDA1" => $lambda1,
		"LAMBDA2" => $lambda2,
		"LAMBDA3" => $lambda3
	};
}
#end 3.0

sub readTrigrams( $$ ) {
	my( $this ) = shift( @_ );
	my( %ngrams ) = ();

	open( TRG, "< $_[0]" ) or die( "ttl::readTrigrams : could not open file !\n" );
	
	while ( my $line = <TRG> ) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		$line =~ s/\r?\n$//;

		my( @toks ) = split( /\s+/, $line );

		$ngrams{$toks[0]} = $toks[1];
	}

	close( TRG );

	return \%ngrams;
}

sub conftagger( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFTAG ) = $this->{"CONFTAG"};
	my( %conf ) = %{ $_[0] };
	my( %setattrs ) = ();

	$CONFTAG->{"RECOVER"} = $conf{"RECOVER"} if ( exists( $conf{"RECOVER"} ) );
	$CONFTAG->{"DEBUG"} = $conf{"DEBUG"} if ( exists( $conf{"DEBUG"} ) );

	$setattrs{"RECOVER"} = 1;
	$setattrs{"DEBUG"} = 1;

	if ( $CONFTAG->{"RECOVER"} ) {
		if ( exists( $conf{"MSDMATCH"} ) ) {
			$CONFTAG->{"MSDMATCH"} = $conf{"MSDMATCH"};
			$setattrs{"MSDMATCH"} = 1;
		}
		else {
			die( "ttl::conftagger : config key MSDMATCH has no value !\n" );
		}

		if ( exists( $conf{"MSDSFXLEN"} ) ) {
			$CONFTAG->{"MSDSFXLEN"} = $conf{"MSDSFXLEN"};
			$setattrs{"MSDSFXLEN"} = 1;
		}
		else {
			die( "ttl::conftagger : config key MSDSFXLEN has no value !\n" );
		}

		if ( exists( $conf{"TBLMSD"} ) ) {
			$CONFTAG->{"TBLMSD"} = $conf{"TBLMSD"};
		}
		else {
			die( "ttl::conftagger : config key TBLMSD has no value !\n" );
		}

		if ( exists( $conf{"MSDSUFF"} ) ) {
			$CONFTAG->{"MSDSUFF"} = $conf{"MSDSUFF"};
		}
		else {
			die( "ttl::conftagger : config key MSDSUFF has no value !\n" );
		}

		if ( exists( $conf{"MSDFREQ"} ) ) {
			$CONFTAG->{"MSDFREQ"} = $conf{"MSDFREQ"};
		}
		else {
			die( "ttl::conftagger : config key MSDFREQ has no value !\n" );
		}
	}

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFTAG->{$k} ) ) {
			SWK3: {
				$k eq "LEX" and do {
					my( %readlexhash ) = %{ $this->readLexicon( $conf{$k}, $conf{"AFX"}, "update" ) };

					$CONFTAG->{$k} = $readlexhash{"LEX"};
					$CONFTAG->{"AFX"} = $readlexhash{"AFX"};
					$CONFTAG->{"N"} = $readlexhash{"N"};
					$CONFTAG->{"THETA"} = $readlexhash{"THETA"};
					$CONFTAG->{"LAMBDA1"} = $readlexhash{"LAMBDA1"};
					$CONFTAG->{"LAMBDA2"} = $readlexhash{"LAMBDA2"};
					$CONFTAG->{"LAMBDA3"} = $readlexhash{"LAMBDA3"};

					$setattrs{$k} = 1;
					$setattrs{"AFX"} = 1;
					$setattrs{"N"} = 1;
					$setattrs{"THETA"} = 1;
					$setattrs{"LAMBDA1"} = 1;
					$setattrs{"LAMBDA2"} = 1;
					$setattrs{"LAMBDA3"} = 1;
					last;
				};

				$k eq "123" and do {
					$CONFTAG->{$k} = $this->readTrigrams( $conf{$k} );
					$setattrs{$k} = 1;
					last;
				};

				$k eq "RRULES" and do {
					if ( $CONFTAG->{"RECOVER"} ) {
						$CONFTAG->{"RRULES"} = $this->readRecoverRules( $conf{$k} );
					}
					else {
						$CONFTAG->{"RRULES"} = {};
					}

					$setattrs{"RRULES"} = 1;
					last;
				};

				$k eq "TAGTOMSD" and do {
					if ( $CONFTAG->{"RECOVER"} ) {
						$CONFTAG->{"TAGTOMSD"} = $this->readTAGtoMSDMapping( $conf{$k} );
					}
					else {
						$CONFTAG->{"TAGTOMSD"} = {};
					}
					
					$setattrs{"TAGTOMSD"} = 1;
					last;
				};

				$k eq "TBLMSD" and do {
					if ( $CONFTAG->{"RECOVER"} ) {
						my( $tbltree, $msdsuff, $msdfreq, $rtheta ) = $this->readTblWordformTree( $conf{$k}, $CONFTAG->{"MSDSFXLEN"}, $CONFTAG->{"MSDMATCH"} );
						
						$CONFTAG->{"TBLMSD"} = $tbltree;
						$CONFTAG->{"MSDSUFF"} = $msdsuff;
						$CONFTAG->{"MSDFREQ"} = $msdfreq;
						$CONFTAG->{"RTHETA"} = $rtheta;
					}
					else {
						$CONFTAG->{"TBLMSD"} = {};
						$CONFTAG->{"MSDSUFF"} = {};
						$CONFTAG->{"RTHETA"} = 0.000001;
						$CONFTAG->{"MSDFREQ"} = {};
					}

					$setattrs{"TBLMSD"} = 1;
					$setattrs{"MSDSUFF"} = 1;
					$setattrs{"RTHETA"} = 1;
					$setattrs{"MSDFREQ"} = 1;
					last;
				};

				$CONFTAG->{$k} = $conf{$k} if ( ! exists( $setattrs{$k} ) );
			}
		}
	}

	foreach my $k ( keys( %{ $CONFTAG } ) ) {
		if ( ! defined( $CONFTAG->{$k} ) ) {
			die( "ttl::conftagger : config key $k has no value !\n" );
		}
	}
}

########################## Revise 2.0 ######################################
{
	my( $lexicon, $ngrams, $sufftree );
	my( $N, $theta, $lambda1, $lambda2, $lambda3 );
	my( @sent );
	my( @tokt );
	#5.6
	my( @nert );
	
	sub tagger( $$$$ ) {
		my( $this ) = shift( @_ );
		my( $CONFTAG ) = $this->{"CONFTAG"};
		@sent = @{ $_[0] };
		@tokt = @{ $_[1] };
		@nert = @{ $_[2] };

		$lexicon = $CONFTAG->{"LEX"};
		$sufftree = $CONFTAG->{"AFX"};
		$ngrams = $CONFTAG->{"123"};
		$N = $CONFTAG->{"N"};
		$theta = $CONFTAG->{"THETA"};
		$lambda1 = $CONFTAG->{"LAMBDA1"};
		$lambda2 = $CONFTAG->{"LAMBDA2"};
		$lambda3 = $CONFTAG->{"LAMBDA3"};

		#1.8 Recover if it's the case ...
		my( $ctagsent ) = $this->taggerviterbi();
		#5.6
		my( @msdsent ) = $this->recoverMSD( \@sent, $ctagsent, \@nert );

		return ( $ctagsent, \@msdsent );
	}

	sub resortsolutions( $$ ) {
		my( $this ) = shift( @_ );
		my( @sol ) = @{ $_[0] };

		my( @ssol ) = sort {
			return $a->{"DELTA"} <=> $b->{"DELTA"};
		} @sol;

		return @ssol;
	}

	sub probtrig( $$ ) {
		my( $this ) = shift( @_ );
		my( $CONFTAG ) = $this->{"CONFTAG"};
		my( @trig ) = @{ $_[0] };
		my( $t3 ) = $trig[2];
		my( $t2 ) = $trig[1];
		my( $t1t2 ) = join( ",", @trig[0 .. 1] );
		my( $t2t3 ) = join( ",", @trig[1 .. 2] );
		my( $t1t2t3 ) = join( ",", @trig[0 .. 2] );

		my( $estPt3 ) = ( exists( $ngrams->{$t3} ) ? $ngrams->{$t3} / $N : 0 );
		my( $estPt3_t2 ) = ( exists( $ngrams->{$t2t3} ) && exists( $ngrams->{$t2} ) ? $ngrams->{$t2t3} / $ngrams->{$t2} : 0 );
		my( $estPt3_t1t2 ) = ( exists( $ngrams->{$t1t2t3} ) && exists( $ngrams->{$t1t2} ) ? $ngrams->{$t1t2t3} / $ngrams->{$t1t2} : 0 );

		my( $Pt3_t1t2 ) = $lambda1 * $estPt3 + $lambda2 * $estPt3_t2 + $lambda3 * $estPt3_t1t2;

		if ( $Pt3_t1t2 < $CONFTAG->{"LOWPROB"} ) {
			return abs( log( $CONFTAG->{"LOWPROB"} ) );
		}
		
		return abs( log( $Pt3_t1t2 ) );
	}

	sub probword( $$$$$ ) {
		my( $this ) = shift( @_ );
		my( $CONFTAG ) = $this->{"CONFTAG"};
		my( $word, $tag ) = ( $_[0], $_[1] );
		my( $OPERATION ) = $_[2];
		my( $SUFFLEN ) = $_[3];

		if ( ! exists( $ngrams->{$tag} ) ) {
			return abs( log( $CONFTAG->{"LOWPROB"} ) );
		}

		SWOPER: {
			$OPERATION eq "EXACTMATCH" and do {
				#ver 2.0
				my( %thash ) = %{ $this->lexGetInfoFromDB( $lexicon, $word ) };
				#end 2.0

				if ( exists( $thash{$tag} ) ) {
					return abs( log( $thash{$tag} / $ngrams->{$tag} ) );
				}
				else {
					return abs( log( $CONFTAG->{"LOWPROB"} ) );
				}
			};

			$OPERATION eq "LCMATCH" and do {
				$word = lc( $word );

				#ver 2.0
				my( %thash ) = %{ $this->lexGetInfoFromDB( $lexicon, $word ) };
				#end 2.0

				if ( exists( $thash{$tag} ) ) {
					return abs( log( $thash{$tag} / $ngrams->{$tag} ) );
				}
				else {
					return abs( log( $CONFTAG->{"LOWPROB"} ) );
				}
			};

			#ver 1.5
			#If the word appears as lower and upper case ...
			$OPERATION eq "MATCH" and do {
				#ver 2.0
				my( %thashuc ) = %{ $this->lexGetInfoFromDB( $lexicon, $word ) };
				my( %thashlc ) = %{ $this->lexGetInfoFromDB( $lexicon, lc( $word ) ) };
				#end 2.0
				my( %thash ) = ();

				foreach my $t ( keys( %thashuc ) ) {
					if ( ! exists( $thash{$t} ) ) {
						$thash{$t} = $thashuc{$t};
					}
				}

				foreach my $t ( keys( %thashlc ) ) {
					if ( ! exists( $thash{$t} ) ) {
						$thash{$t} = $thashlc{$t};
					}
					else {
						$thash{$t} += $thashlc{$t};
					}
				}

				if ( exists( $thash{$tag} ) ) {
					return abs( log( $thash{$tag} / $ngrams->{$tag} ) );
				}
				else {
					return abs( log( $CONFTAG->{"LOWPROB"} ) );
				}
			};

			$OPERATION eq "GUESS" and do {
				return abs( log( $CONFTAG->{"LOWPROB"} ) ) if ( $SUFFLEN == 0 );

				my( $suff ) = $this->extractSuffix( lc( $word ), $SUFFLEN );
				my( $P ) = $ngrams->{$tag} / $N;
				my( $P2 ) = $ngrams->{$tag} / $N;
				#ver 2.0
				my( $Psuff ) = ( $this->lexExistsWordInDB( $sufftree, $suff ) ? $this->lexGetFreqFromDB( $sufftree, $suff, "_FREQ" ) / $N : 0 );
				#end 2.0

				for ( my $k = 1; $k <= $SUFFLEN; $k++ ) {
					my( $crtsuff ) = $this->extractSuffix( lc( $word ), $k );
					#ver 2.0
					my( $estP ) = (
						$this->lexExistsWordInDB( $sufftree, $crtsuff ) && $this->lexExistsWordWithTagInDB( $sufftree, $crtsuff, $tag )
						?
						$this->lexGetFreqFromDB( $sufftree, $crtsuff, $tag ) / $this->lexGetFreqFromDB( $sufftree, $crtsuff, "_FREQ" )
						:
						0
					);
					#end 2.0

					#1.9 Bug !!
					# Gresit !! Am busit formula din Brants ... :(
					# Probleme e ca aia buna nu merge ... Cred ca a gresit Brants in articol si asta care e mai jos e buna !
					$P = ( $estP + $theta * $P ) / ( 1 + $theta );
				}

				return abs( log( ( $P * $Psuff ) / $P2 ) );
			};
		}
	}

	sub taggerviterbi( $ ) {
		my( $this ) = shift( @_ );
		my( $CONFTAG ) = $this->{"CONFTAG"};
		my( @vpath ) = ();
		my( $tag ) = $tokt[0];
		my( $word ) = $sent[0];
		my( %unkpositions ) = ();

		if ( defined( $tag ) ) {
			my( @fwamb ) = ();
			my( %tri ) = ( "TRI" => [ "#", "#", $tag ], "DELTA" => $this->probtrig( [ "#", "#", $tag ] ), "PHI" => -1 );

			$fwamb[0] = \%tri;

			push( @vpath, \@fwamb );
		}
		else {
			my( $OPER ) = "";
			my( %thash ) = ();
			my( $SUFFLEN ) = 0;

			#Cuvantul este in lexicon ...
			#ver 2.0
			if ( $word ne lc( $word ) && $this->lexExistsWordInDB( $lexicon, $word ) && $this->lexExistsWordInDB( $lexicon, lc( $word ) ) ) {
			#end 2.0
				$OPER = "MATCH";

				#ver 2.0
				my( %thashuc ) = %{ $this->lexGetInfoFromDB( $lexicon, $word ) };
				my( %thashlc ) = %{ $this->lexGetInfoFromDB( $lexicon, lc( $word ) ) };
				#end 2.0

				foreach my $t ( keys( %thashuc ) ) {
					if ( ! exists( $thash{$t} ) ) {
						$thash{$t} = $thashuc{$t};
					}
				}

				foreach my $t ( keys( %thashlc ) ) {
					if ( ! exists( $thash{$t} ) ) {
						$thash{$t} = $thashlc{$t};
					}
					else {
						$thash{$t} += $thashlc{$t};
					}
				}
			} #end if both variants are there.
			#ver 2.0
			elsif ( $this->lexExistsWordInDB( $lexicon, $word ) ) {
			#ver 2.0
				$OPER = "EXACTMATCH";
				#ver 2.0
				%thash = %{ $this->lexGetInfoFromDB( $lexicon, $word ) };
				#end 2.0
			} #end EXACT MATCH word
			#Cuvantul lower case este in lexicon ...
			elsif ( $this->lexExistsWordInDB( $lexicon, lc( $word ) ) ) {
				$OPER = "LCMATCH";
				#ver 2.0
				%thash = %{ $this->lexGetInfoFromDB( $lexicon, lc( $word ) ) };
				#end 2.0
			} #end LC word
			#UNKNOWN word ... guessing.
			else {
				$unkpositions{0} = 1;
				$OPER = "GUESS";

				for ( my $k = $CONFTAG->{"SUFFL"}; $k >= 1; $k-- ) {
					my( $suff ) = $this->extractSuffix( lc( $word ), $k );

					#ver 2.0
					if ( $this->lexExistsWordInDB( $sufftree, $suff ) ) {
						%thash = %{ $this->lexGetInfoFromDB( $sufftree, $suff ) };
					#end 2.0
						$SUFFLEN = $k;
						last;
					}
				}

				if ( $SUFFLEN == 0 ) {
					%thash = ( "_FREQ" => 1, "X" => 1 );
				}
			}

			my( @fwamb ) = ();
			foreach my $t ( keys( %thash ) ) {
				next if ( $t eq "_FREQ" );

				my( %tri ) = ();

				$tri{"TRI"} = [ "#", "#", $t ];
				$tri{"DELTA"} = $this->probtrig( [ "#", "#", $t ] ) + $this->probword( $word, $t, $OPER, $SUFFLEN );
				$tri{"PHI"} = -1;

				push( @fwamb, \%tri );
			}

			push( @vpath, \@fwamb );
		}

		for ( my $i = 1; $i < scalar( @tokt ); $i++ ) {
			$tag = $tokt[$i];
			$word = $sent[$i];

			my( @amb ) = ();

			if ( defined( $tag ) ) {
				my( @prevtri ) = @{ $vpath[$i - 1] };
				my( %newtri ) = ();

				foreach my $tr ( @prevtri ) {
					my( @oldtr ) = @{ $tr->{"TRI"} };
					my( @newtr ) = ( $oldtr[1], $oldtr[2], $tag );

					if ( ! exists( $newtri{join( ",", @newtr )} ) ) {
						$newtri{join( ",", @newtr )} = 1;
					}
				} #end construct new trigrams ...

				foreach my $tr ( keys( %newtri ) ) {
					my( @newtr ) = split( /,/, $tr );
					my( %tri ) = ();

					$tri{"TRI"} = \@newtr;
					$tri{"DELTA"} = -1;

					for ( my $j = 0; $j < scalar( @prevtri ); $j++ ) {
						my( $ptr ) = $prevtri[$j];
						my( @oldtr ) = @{ $ptr->{"TRI"} };

						#Asta este testul de link ...
						next if ( $oldtr[1] ne $newtr[0] || $oldtr[2] ne $newtr[1] );

						if ( $tri{"DELTA"} == -1 ) {
							$tri{"DELTA"} = $ptr->{"DELTA"} + $this->probtrig( \@newtr );
							$tri{"PHI"} = $j;
						}
						else {
							if ( $tri{"DELTA"} > $ptr->{"DELTA"} + $this->probtrig( \@newtr ) ) {
								$tri{"DELTA"} = $ptr->{"DELTA"} + $this->probtrig( \@newtr );
								$tri{"PHI"} = $j;
							}
						}
					}

					push( @amb, \%tri );
				} #end all new trigrams ...
			} #end defined tag inside
			else {
				my( $OPER ) = "";
				my( %thash ) = ();
				my( $SUFFLEN ) = 0;

				#Cuvantul este in lexicon ...
				#ver 2.0
				if ( $word ne lc( $word ) && $this->lexExistsWordInDB( $lexicon, $word ) && $this->lexExistsWordInDB( $lexicon, lc( $word ) ) ) {
				#end 2.0
					$OPER = "MATCH";
					
					#ver 2.0
					my( %thashuc ) = %{ $this->lexGetInfoFromDB( $lexicon, $word ) };
					my( %thashlc ) = %{ $this->lexGetInfoFromDB( $lexicon, lc( $word ) ) };
					#end 2.0
					
					foreach my $t ( keys( %thashuc ) ) {
						if ( ! exists( $thash{$t} ) ) {
							$thash{$t} = $thashuc{$t};
						}
					}

					foreach my $t ( keys( %thashlc ) ) {
						if ( ! exists( $thash{$t} ) ) {
							$thash{$t} = $thashlc{$t};
						}
						else {
							$thash{$t} += $thashlc{$t};
						}
					}
				} #end if both variants are there.
				#ver 2.0
				elsif ( $this->lexExistsWordInDB( $lexicon, $word ) ) {
				#end 2.0
					$OPER = "EXACTMATCH";
					#ver 2.0
					%thash = %{ $this->lexGetInfoFromDB( $lexicon, $word ) };
					#end 2.0
				} #end EXACT MATCH word
				#Cuvantul lower case este in lexicon ...
				elsif ( $this->lexExistsWordInDB( $lexicon, lc( $word ) ) ) {
					$OPER = "LCMATCH";
					#ver 2.0
					%thash = %{ $this->lexGetInfoFromDB( $lexicon, lc( $word ) ) };
					#end 2.0
				} #end LC word
				#UNKNOWN word ... guessing.
				else {
					$unkpositions{$i} = 1;
					$OPER = "GUESS";

					for ( my $k = $CONFTAG->{"SUFFL"}; $k >= 1; $k-- ) {
						my( $suff ) = $this->extractSuffix( lc( $word ), $k );

						#ver 2.0
						if ( $this->lexExistsWordInDB( $sufftree, $suff ) ) {
							%thash = %{ $this->lexGetInfoFromDB( $sufftree, $suff ) };
						#ver 2.0
							$SUFFLEN = $k;
							last;
						}
					}

					if ( $SUFFLEN == 0 ) {
						%thash = ( "_FREQ" => 1, "X" => 1 );
					}
				}

				my( %newtri ) = ();
				my( @prevtri ) = @{ $vpath[$i - 1] };

				foreach my $t ( keys( %thash ) ) {
					next if ( $t eq "_FREQ" );

					foreach my $tr ( @prevtri ) {
						my( @oldtr ) = @{ $tr->{"TRI"} };
						my( @newtr ) = ( $oldtr[1], $oldtr[2], $t );

						if ( ! exists( $newtri{join( ",", @newtr )} ) ) {
							$newtri{join( ",", @newtr )} = 1;
						}
					} #end construct new trigrams ...
				} #for all ambiguities I ...

				foreach my $tr ( keys( %newtri ) ) {
					my( @newtr ) = split( /,/, $tr );
					my( $t ) = $newtr[2];
					my( %tri ) = ();

					$tri{"TRI"} = \@newtr;
					$tri{"DELTA"} = -1;

					for ( my $j = 0; $j < scalar( @prevtri ); $j++ ) {
						my( $ptr ) = $prevtri[$j];
						my( @oldtr ) = @{ $ptr->{"TRI"} };

						#Asta este testul de link ...
						next if ( $oldtr[1] ne $newtr[0] || $oldtr[2] ne $newtr[1] );

						if ( $tri{"DELTA"} == -1 ) {
							$tri{"DELTA"} = $ptr->{"DELTA"} + $this->probtrig( \@newtr ) + $this->probword( $word, $t, $OPER, $SUFFLEN );
							$tri{"PHI"} = $j;
						}
						else {
							if ( $tri{"DELTA"} > $ptr->{"DELTA"} + $this->probtrig( \@newtr ) + $this->probword( $word, $t, $OPER, $SUFFLEN ) ) {
								$tri{"DELTA"} = $ptr->{"DELTA"} + $this->probtrig( \@newtr ) + $this->probword( $word, $t, $OPER, $SUFFLEN );
								$tri{"PHI"} = $j;
							}
						}
					}

					push( @amb, \%tri );
				} #end all new trigrams ...
			} #end ! defined tag inside.

			push( @vpath, \@amb );
		} #end $i
	
		#Backtrack to recover the tags ...
		my( @lastamb ) = @{ $vpath[$#vpath] };
		my( $logP ) = $lastamb[0]->{"DELTA"};
		my( $phi ) = $lastamb[0]->{"PHI"};
		my( $lasttag ) = $lastamb[0]->{"TRI"}->[2];

		foreach my $tr ( @lastamb ) {
			if ( $tr->{"DELTA"} < $logP ) {
				$logP = $tr->{"DELTA"};
				$phi = $tr->{"PHI"};
				$lasttag = $tr->{"TRI"}->[2];
			}
		}

		$tokt[$#tokt] = $lasttag;

		if ( $CONFTAG->{"DEBUG"} ) {
			if ( exists( $unkpositions{$#tokt} ) ) {
				print( STDERR $sent[$#tokt] . "\t" . $tokt[$#tokt] . "\n" );
			}
		}

		for ( my $k = $#vpath - 1; $k >= 0; $k-- ) {
			my( @crtamb ) = @{ $vpath[$k] };
			
			$tokt[$k] = $crtamb[$phi]->{"TRI"}->[2];

			if ( $CONFTAG->{"DEBUG"} ) {
				if ( exists( $unkpositions{$k} ) ) {
					print( STDERR $sent[$k] . "\t" . $tokt[$k] . "\n" );
				}
			}

			$phi = $crtamb[$phi]->{"PHI"};
		}

		return \@tokt;
	} #end Viterbi decoder.
}
########################## End revise 2.0 ######################################

########################### Revise 7.0 #############################################
sub getBlocks( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFCHUNK ) = $this->{"CONFCHUNK"};
	my( $grammar ) = $CONFCHUNK->{"GRAMMAR"};
	my( @ssyms ) = @{ $CONFCHUNK->{"CHUNKS"} };
	my( $MAXLINELEN ) = $CONFCHUNK->{"MAXLINELEN"};
	my( $DEBUG ) = $CONFCHUNK->{"DEBUG"};
	my( @sent ) = @{ $_[0] };
	my( @chunks ) = ();
	#8.5
	my( @reclines ) = ();
	my( @crtrecline ) = ();
	my( %phashrev ) = xces::getpHashRev();

	foreach my $t ( @sent ) {
		#8.5
		#If it's punctuation, split the sequence of CTAGS to match against regex.
		if ( exists( $phashrev{$t} ) ) {
			push( @crtrecline, "<" . $t . ">" );
			push( @reclines, join( "", @crtrecline ) );
			@crtrecline = ();
		}
		else {
			push( @crtrecline, "<" . $t . ">" );
		}
	}
	
	#8.5
	if ( scalar( @crtrecline ) > 0 ) {
		push( @reclines, join( "", @crtrecline ) );
		@crtrecline = ();
	}

	foreach my $ss ( @ssyms ) {
		die ( "ttl::getBlocks: $ss is not a production !\n" ) if ( ! exists( $grammar->{$ss} ) );
		
		my( @ssrules ) = @{ $grammar->{$ss} };

		die ( "ttl::getBlocks: $ss has more than one regular expression associated !\n" ) if ( scalar( @ssrules ) > 1 );

		my( $r ) = $ssrules[0];
		#8.5
		my( @block ) = ();
		
		#8.5
		foreach my $recline ( @reclines ) {
			#Acount for < and >
			if ( length( $recline ) > 3 * $MAXLINELEN ) {
				warn( "ttl::getBlocks: recline length is '" . length( $recline ) . "'! Skipping...\n" )
					if ( $DEBUG );
				next;
			}
			
			while ( $recline =~ /($r)/g ) {
				push( @block, $1 );
			}
		}
		
		my( $cnt ) = 1;

		foreach my $e ( @block ) {
			my( $te ) = $e;

			$te =~ s/^<//;
			$te =~ s/>$//;

			my( @tags ) = split( /></, $te );
			my( @rtags ) = ();
			my( $at ) = -1;
			my( $len ) = scalar( @tags );

			for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
				#Le sarim pe alea adnotate.
				next if ( exists( $chunks[$i] ) && exists( ( $chunks[$i] )->{$ss} ) );

				if ( $sent[$i] eq $tags[0] ) {
					if ( scalar( @rtags ) == 0 ) {
						$at = $i;
					}
					
					push( @rtags, shift( @tags ) );
					last if ( scalar( @tags ) == 0 );
				}
				else {
					if ( scalar( @tags ) < $len ) {
						unshift( @tags, @rtags );
						@rtags = ();
						$at = -1;
					}
				}
			}
			
			if ( $at >= 0 ) {
				for ( my $i = $at; $i < $at + $len; $i++ ) {
					if ( exists( $chunks[$i] ) ) {
						( $chunks[$i] )->{$ss} = $cnt;
					}
					else {
						my( %cathash ) = ();

						$cathash{$ss} = $cnt;
						$chunks[$i] = \%cathash;
					}
				}
			}
			else {
				#warn( "xceschunk::getBlocks() : NF RX $e!!\n" );
			}

			$cnt++;
		}
	}

	my( $temprecline ) = "";

	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		my( $c ) = $chunks[$i];
		
		if ( defined( $c ) && ref( $c ) ) {
			$temprecline .= "_";
		}
		else {
			$temprecline .= "<" . $sent[$i] . ">";
		}
	}

	return ( \@chunks, $temprecline );
}

sub arrangeBlocks( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFCHUNK ) = $this->{"CONFCHUNK"};

	my( $chunks ) = $_[0];
	my( %lengths ) = ();
	my( $pos ) = 0;

	foreach my $c ( @{ $chunks } ) {
		my( %cat );

		if ( defined( $c ) ) {
			%cat = %{ $c };
		}
		else {
			%cat = ();
		}

		foreach my $c ( keys( %cat ) ) {
			my( $key ) = $c . "#" . $cat{$c};

			if ( exists( $lengths{$key} ) ) {
				$lengths{$key}++;
			}
			else {
				$lengths{$key} = 1;
			}
		}

		$pos++;
	}

	foreach my $c ( @{ $chunks } ) {
		if ( defined( $c ) && scalar( keys( %{ $c } ) ) == 0 ) {
			$c = undef();
		}

		if ( defined( $c ) ) {
			my( @chunkys ) = ();

			foreach my $k ( keys( %{ $c } ) ) {
				my( $lkey ) = $k . "#" . $c->{$k};

				push( @chunkys, $lkey . "/" . $lengths{$lkey} );
			}

			my( @schunkys ) = sort {
				my( $k1 ) = ( split( /\//, $a ) )[1];
				my( $k2 ) = ( split( /\//, $b ) )[1];

				return $k2 <=> $k1;
			} @chunkys;

			my( @finalchunks ) = ();

			foreach my $c ( @schunkys ) {
				my( $cc ) = ( split( /\//, $c ) )[0];

				push( @finalchunks, $cc );
			}

			$c = join( ",", @finalchunks );
		} #end defined chunk ...
	}

	return $chunks;
}

sub confchunker( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFCHUNK ) = $this->{"CONFCHUNK"};
	my( %conf ) = %{ $_[0] };

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFCHUNK->{$k} ) ) {
			SWCHUNK: {
				$k eq "GRAMFILE" and do {
					my( $grammar ) = $this->readNERGrammar( $conf{$k} );
					
					$CONFCHUNK->{"GRAMMAR"} = $grammar->{"GRAMMAR"};
					$CONFCHUNK->{"NONTERM"} = $grammar->{"NTERM"};
					
					last;
				};
			}
			
			$CONFCHUNK->{$k} = $conf{$k};
		}
	}
	
	if ( ! exists( $CONFCHUNK->{"CHUNKS"} ) || ! ref( $CONFCHUNK->{"CHUNKS"} ) || scalar( @{ $CONFCHUNK->{"CHUNKS"} } ) == 0 ) {
		die( "ttl::confchunker : config key CHUNKS is not properly defined !\n" );
	}

	foreach my $k ( keys( %{ $CONFCHUNK } ) ) {
		if ( ! defined( $CONFCHUNK->{$k} ) ) {
			die( "ttl::confchunker : config key $k has no value !\n" );
		}
	}
}

sub chunker( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFCHUNK ) = $this->{"CONFCHUNK"};
	my( $tagsent ) = $_[0];
	my( $chunks, $recline ) = $this->getBlocks( $tagsent );
	
	return $this->arrangeBlocks( $chunks );
}
########################### End Revise 7.0 #########################################

sub conftraintagger( $$ ) {
	my( $this ) = shift( @_ );
	my( %conf ) = %{ $_[0] };

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFTTAG{$k} ) ) {
			$CONFTTAG{$k} = $conf{$k};
		}
	}

	foreach my $k ( keys( %CONFTTAG ) ) {
		if ( ! defined( $CONFTTAG{$k} ) ) {
			die( "ttl::conftraintagger : config key $k has no value !\n" );
		}
	}
}

sub traintagger( $ ) {
	my( $this ) = shift( @_ );
	my( $CONFSSPLIT ) = $this->{"CONFSSPLIT"};
	my( %ngrams ) = ();
	#ver 2.0
	my( $lexicon ) = {};
	my( $sufftree ) = {};
	#end 2.0
	my( $lambda1, $lambda2, $lambda3 ) = ( 0, 0, 0 );
	my( $theta ) = 0;
	my( $N ) = 0;
	my( $sufflen ) = $CONFTTAG{"SUFFL"};

	die( "ttl::traintagger : undefined suffix length !\n" ) if ( ! defined( $sufflen ) || $sufflen eq "" );
	die( "ttl::traintagger : undefined suffix tags vector !\n" ) if ( ! defined( $CONFTTAG{"SUFFTAGS"} ) || ! ref( $CONFTTAG{"SUFFTAGS"} ) );

	my( @sufftagsv ) = @{ $CONFTTAG{"SUFFTAGS"} };
	my( %sufftags ) = ();

	foreach my $st ( @sufftagsv ) {
		$sufftags{$st} = 1;
	}

	#ver 3.0
	my( %readlexhash ) = %{ $this->readLexicon( $CONFTTAG{"LEX"}, $CONFTTAG{"AFX"}, $CONFTTAG{"MODE"} ) };

	#ver 2.0
	$lexicon = $readlexhash{"LEX"};
	$sufftree = $readlexhash{"AFX"};
	$N = $readlexhash{"N"};
	%readlexhash = ();
	#end 2.0

	#ver 3.0
	#ver 6.3 This code is wrong !! $sufftree must be updated !
	#Saving suffix tree ...
#	untie( %{ $sufftree } );
#	$sufftree = undef();

#	my( %sufftree2 ) = ();
#	my( $suffbdobj ) = undef();

#	$suffbdobj = tie( %sufftree2, "BerkeleyDB::Hash", "-Filename" => $CONFTTAG{"AFX"}, "-Flags" => DB_TRUNCATE, "-Mode" => 0666 );

#	if ( ! defined( $suffbdobj ) ) {
#		die( "ttl::traintagger() : cannot open file \'" . $CONFTTAG{"AFX"} . "\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
#	}
	#end 3.0
		
	if ( $CONFTTAG{"MODE"} eq "update" ) {
		if ( exists( $CONFTTAG{"123"} ) && defined( $CONFTTAG{"123"} ) && $CONFTTAG{"123"} ne "" ) {
			%ngrams = %{ $this->readTrigrams( $CONFTTAG{"123"} ) };
		}
	}
	#end 3.0

	my( $findngrams ) = sub {
		my( $n ) = $_[0];
		my( @seq ) = @{ $_[1] };
		my( @ngrams ) = ();

		for ( my $i = 0; $i < scalar( @seq ) - $n + 1; $i++ ) {
			push( @ngrams, join( ",", @seq[$i .. $i + $n - 1] ) );
		}

		return @ngrams;
	};

	open( TRAIN, "< " . $CONFTTAG{"TRAINFILE"} );

	my( $lcnt ) = 0;

	SWCORPUSTYPE: {
		$CONFTTAG{"CORPUSSTYLE"} eq "line" and do {
			#Fa testu ca ATTRORDER sa contina wordform, lemma si tag !! Daca nu sunt toate (indiferent de ordine) nu merge !!
			my( @attrorder ) = @{ $CONFTTAG{"ATTRORDER"} };

			die( "ttl::traintagger : for the \'line\' corpus style, the attribute order MUST be: wordform, lemma, tag !\n" )
				if ( scalar( @attrorder ) != 3 || $attrorder[0] ne "wordform" || $attrorder[1] ne "lemma" || $attrorder[2] ne "tag" );

			NEXTLINE:
			while ( my $line = <TRAIN> ) {
				$lcnt++;
				$line =~ s/^\s+//;
				$line =~ s/\s+$//;
				$line =~ s/\r?\n$//;

				my( @toks ) = split( /\s+/, $line );
				my( @tagseq ) = ( "#", "#" );

				foreach my $t ( @toks ) {
					$N++;

					my( $wordform, $lemma, $tag ) = $this->getAttributes( $t );

					die( "ttl::traintagger : not defined wordform or tag @ line $lcnt !\n" ) if ( ! defined( $tag ) || ! defined( $wordform ) );
					push( @tagseq, $tag );

					my( $founduct ) = 0;

					foreach my $uct ( @{ $CONFTTAG{"UPCASETAGS"} } ) {
						if ( $uct eq $tag ) {
							$founduct = 1;
							last;
						}
					}

					if ( ! $founduct ) {
						$wordform = lc( $wordform );
					}

					#ver 2.0
					$this->lexAddWordToDB( $lexicon, $wordform, $tag, 1 );
					#ver 3.0
					$this->lexAddWordToDB( $lexicon, $wordform, "_FREQ", 1 );

					#ver 6.3
					#my( $tagfreq ) = $this->lexGetFreqFromDB( $lexicon, $wordform, $tag );

					#ver 6.7
					if ( exists( $sufftags{$tag} ) && $wordform !~ /_/ ) {
						#Building the suffix hash ...
						my( %assignedsuff ) = ();
						
						for ( my $k = 1; $k <= $sufflen; $k++ ) {
							my( $suff ) = lc( $this->extractSuffix( $wordform, $k ) );

							#If the word has fewer letters than sufflen, the longest suffix will be added several times.
							#This restricts that.
							if ( ! exists( $assignedsuff{$suff} ) ) {
								#ver 2.0
								#ver 6.3
								#$this->lexAddWordToDB( \%sufftree2, $suff, $tag, $tagfreq );
								$this->lexAddWordToDB( $sufftree, $suff, $tag, 1 );
								#Compute the freq of the suffixes ...
								#ver 6.3
								#$this->lexAddWordToDB( \%sufftree2, $suff, "_FREQ", $tagfreq );
								$this->lexAddWordToDB( $sufftree, $suff, "_FREQ", 1 );
								#end 2.0
							}

							$assignedsuff{$suff} = 1;
						} #end for building the suffix tree.
					} #end if tag is in the suffix tag list.
					#end 3.0
					#end 2.0
				}

				push( @tagseq, "\$" );

				for ( my $n = 1; $n <= 3; $n++ ) {
					my( @ngrmsarr ) = $findngrams->( $n, \@tagseq );

					foreach my $ng ( @ngrmsarr ) {
						if ( ! exists( $ngrams{$ng} ) ) {
							$ngrams{$ng} = 1;
						}
						else {
							$ngrams{$ng}++;
						}
					}
				}

				print( STDERR "ttl::traintagger : $lcnt lines scanned.\n" ) if ( $CONFTTAG{"DEBUG"} && $lcnt % 1000 == 0 );
			} #end train file ...

			last;
		};

		$CONFTTAG{"CORPUSSTYLE"} eq "column" and do {
			my( @attrorder ) = @{ $CONFTTAG{"ATTRORDER"} };
			my( @thisattrorder ) = ( "wordform", "lemma", "tag" );
			my( @sentbreakrxv ) = sort {
				return $CONFSSPLIT->{"SENTBREAK"}->{$a} <=> $CONFSSPLIT->{"SENTBREAK"}->{$b};
			} keys( %{ $CONFSSPLIT->{"SENTBREAK"} } );
			my( $sentbreakrx ) = join( "|", @sentbreakrxv );

			while ( 1 ) {
				last if ( eof( TRAIN ) );

				my( $line );
				my( @tagseq ) = ( "#", "#" );

				while ( 1 ) {
					last if ( eof( TRAIN ) );
					
					$line = <TRAIN>;
					$lcnt++;
					$line =~ s/^\s+//;
					$line =~ s/\s+$//;
					$line =~ s/\r?\n$//;
					
					next if ( $line =~ /^$/ );

					my( @toks ) = split( /\s+/, $line );
					my( @attrs ) = ( undef(), undef(), undef() );

					if ( scalar( @toks ) != scalar( @attrorder ) ) {
						die( "ttl::traintagger (column) : number of tokens != number of attrs @ line $lcnt !\n" );
					}
					else {
						for ( my $i = 0; $i < scalar( @attrorder ); $i++ ) {
							for ( my $j = 0; $j < scalar( @thisattrorder ); $j++ ) {
								if ( $attrorder[$i] eq $thisattrorder[$j] ) {
									$attrs[$j] = $toks[$i];
								}
							}
						}
					}

					my( $wordform, $lemma, $tag ) = @attrs;

					die( "ttl::traintagger (column) : not defined wordform or tag @ line $lcnt !\n" ) if ( ! defined( $wordform ) || ! defined( $tag ) );
					$N++;

					my( $founduct ) = 0;

					foreach my $uct ( @{ $CONFTTAG{"UPCASETAGS"} } ) {
						if ( $uct eq $tag ) {
							$founduct = 1;
							last;
						}
					}

					if ( ! $founduct ) {
						$wordform = lc( $wordform );
					}

					#ver 2.0
					$this->lexAddWordToDB( $lexicon, $wordform, $tag, 1 );
					#ver 3.0
					$this->lexAddWordToDB( $lexicon, $wordform, "_FREQ", 1 );

					#ver 6.3
					#my( $tagfreq ) = $this->lexGetFreqFromDB( $lexicon, $wordform, $tag );

					#ver 6.7
					if ( exists( $sufftags{$tag} ) && $wordform !~ /_/ ) {
						#Building the suffix hash ...
						my( %assignedsuff ) = ();
						
						for ( my $k = 1; $k <= $sufflen; $k++ ) {
							my( $suff ) = lc( $this->extractSuffix( $wordform, $k ) );

							#If the word has fewer letters than sufflen, the longest suffix will be added several times.
							#This restricts that.
							if ( ! exists( $assignedsuff{$suff} ) ) {
								#ver 2.0
								#ver 6.3
								#$this->lexAddWordToDB( \%sufftree2, $suff, $tag, $tagfreq );
								$this->lexAddWordToDB( $sufftree, $suff, $tag, 1 );
								#Compute the freq of the suffixes ...
								#ver 6.3
								#$this->lexAddWordToDB( \%sufftree2, $suff, "_FREQ", $tagfreq );
								$this->lexAddWordToDB( $sufftree, $suff, "_FREQ", 1 );
								#end 2.0
							}

							$assignedsuff{$suff} = 1;
						} #end for building the suffix tree.
					} #end if tag is in the suffix tag list.
					#end 3.0
					#end 2.0
					push( @tagseq, $tag );
					
					print( STDERR "ttl::traintagger : $lcnt lines scanned.\n" ) if ( $CONFTTAG{"DEBUG"} && $lcnt % 1000 == 0 );

					last if ( $wordform =~ /^${sentbreakrx}$/ );
				} #end current sentence

				push( @tagseq, "\$" );

				next if ( scalar( @tagseq ) <= 3 );

				for ( my $n = 1; $n <= 3; $n++ ) {
					my( @ngrmsarr ) = $findngrams->( $n, \@tagseq );

					foreach my $ng ( @ngrmsarr ) {
						if ( ! exists( $ngrams{$ng} ) ) {
							$ngrams{$ng} = 1;
						}
						else {
							$ngrams{$ng}++;
						}
					}
				}
			} #end file
			
			last;
		};

		#This is not a corpus but a lexicon thus making the updating of %ngrams only at the level of unigrams.
		$CONFTTAG{"CORPUSSTYLE"} eq "tbl" and do {
			my( @attrorder ) = @{ $CONFTTAG{"ATTRORDER"} };

			die( "ttl::traintagger : for the \'tbl\' corpus style, the attribute order MUST be: wordform, lemma, tag !\n" )
				if ( scalar( @attrorder ) != 3 || $attrorder[0] ne "wordform" || $attrorder[1] ne "lemma" || $attrorder[2] ne "tag" );

			while ( my $line = <TRAIN> ) {
				$lcnt++;
				$line =~ s/^\s+//;
				$line =~ s/\s+$//;
				$line =~ s/\r?\n$//;

				next if ( $line =~ /^$/ );
				
				my( @toks ) = split( /\s+/, $line );

				next if ( scalar( @toks ) != 3 );

				my( $wordform, $lemma, $tag ) = @toks;

				if ( $lemma eq "=" ) {
					$lemma = $wordform;
				}

				my( $founduct ) = 0;

				foreach my $uct ( @{ $CONFTTAG{"UPCASETAGS"} } ) {
					if ( $uct eq $tag ) {
						$founduct = 1;
						last;
					}
				}

				if ( ! $founduct ) {
					$wordform = lc( $wordform );
				}

				$N++;

				#Update lexicon ...
				#ver 2.0
				$this->lexAddWordToDB( $lexicon, $wordform, $tag, 1 );
				#ver 3.0
				$this->lexAddWordToDB( $lexicon, $wordform, "_FREQ", 1 );

				#ver 6.3
				#my( $tagfreq ) = $this->lexGetFreqFromDB( $lexicon, $wordform, $tag );

				#ver 6.7
				if ( exists( $sufftags{$tag} ) && $wordform !~ /_/ ) {
					#Building the suffix hash ...
					my( %assignedsuff ) = ();
					
					for ( my $k = 1; $k <= $sufflen; $k++ ) {
						my( $suff ) = lc( $this->extractSuffix( $wordform, $k ) );

						#If the word has fewer letters than sufflen, the longest suffix will be added several times.
						#This restricts that.
						if ( ! exists( $assignedsuff{$suff} ) ) {
							#ver 2.0
							#ver 6.3
							#$this->lexAddWordToDB( \%sufftree2, $suff, $tag, $tagfreq );
							$this->lexAddWordToDB( $sufftree, $suff, $tag, 1 );
							#Compute the freq of the suffixes ...
							#ver 6.3
							#$this->lexAddWordToDB( \%sufftree2, $suff, "_FREQ", $tagfreq );
							$this->lexAddWordToDB( $sufftree, $suff, "_FREQ", 1 );
							#end 2.0
						}

						$assignedsuff{$suff} = 1;
					} #end for building the suffix tree.
				} #end if tag is in the suffix tag list.
				#end 3.0
				#end 2.0

				#Update the unigrams ...
				if ( ! exists( $ngrams{$tag} ) ) {
					$ngrams{$tag} = 1;
				}
				else {
					$ngrams{$tag}++;
				}

				print( STDERR "ttl::traintagger : $lcnt lines scanned.\n" ) if ( $CONFTTAG{"DEBUG"} && $lcnt % 1000 == 0 );
			}
			
			last;
		};
	} #end filling the %lexicon and %ngrams ...

	if ( exists( $CONFTTAG{"123"} ) && defined( $CONFTTAG{"123"} ) && $CONFTTAG{"123"} ne "" ) {
		#Computing theta ...
		my( $s ) = 0;
		my( $Pmed ) = 0;

		foreach my $t ( keys( %ngrams ) ) {
			next if ( $t =~ /,/ );
			next if ( $t eq "#" || $t eq "\$" );

			$Pmed += $ngrams{$t} / $N;
			$s++;
		}
		
		$Pmed = $Pmed / $s;

		foreach my $t ( keys( %ngrams ) ) {
			next if ( $t =~ /,/ );
			next if ( $t eq "#" || $t eq "\$" );

			$theta += ( ( $ngrams{$t} / $N ) - $Pmed ) * ( ( $ngrams{$t} / $N ) - $Pmed );
		}

		$theta = $theta / ( $s - 1 );

		#Computing lambdas ...
		foreach my $t ( keys( %ngrams ) ) {
			my( @ng ) = split( /,/, $t );

			if ( scalar( @ng ) == 3 ) {
				my( $t1, $t2, $t3 ) = @ng;
				my( $l3case ) = ( $ngrams{$t1 . "," . $t2} - 1 == 0 ? 0 : ( $ngrams{$t1 . "," . $t2 . "," . $t3} - 1 ) / ( $ngrams{$t1 . "," . $t2} - 1 ) );
				my( $l2case ) = ( $ngrams{$t2} - 1 == 0 ? 0 : ( $ngrams{$t2 . "," . $t3} - 1 ) / ( $ngrams{$t2} - 1 ) );
				my( $l1case ) = ( $N == 0 ? 0 : ( $ngrams{$t3} - 1 ) / ( $N - 1 ) );

				if ( $l3case >= $l1case && $l3case >= $l2case ) {
					$lambda3 += $ngrams{$t1 . "," . $t2 . "," . $t3};
				}

				if ( $l2case >= $l1case && $l2case >= $l3case ) {
					$lambda2 += $ngrams{$t1 . "," . $t2 . "," . $t3};
				}

				if ( $l1case >= $l2case && $l1case >= $l3case ) {
					$lambda1 += $ngrams{$t1 . "," . $t2 . "," . $t3};
				}
			}
		}

		my( $lambdnorm ) = $lambda1 + $lambda2 + $lambda3;

		$lambda1 = $lambda1 / $lambdnorm;
		$lambda2 = $lambda2 / $lambdnorm;
		$lambda3 = $lambda3 / $lambdnorm;
	} #end if defined 123 hash key ...

	#Write the trigram model ...
	if ( exists( $CONFTTAG{"123"} ) && defined( $CONFTTAG{"123"} ) && $CONFTTAG{"123"} ne "" ) {
		open( TRIG, "> " . $CONFTTAG{"123"} );
		
		foreach my $t ( keys( %ngrams ) ) {
			print( TRIG $t . "\t" . $ngrams{$t} . "\n" );
		}

		close( TRIG );
	}

	#ver 6.3 Wrong code below ...
	#Saving the suffix tree ...
	#untie( %sufftree2 );
	#$suffbdobj = undef();
		
	#Saving the lexicon ...
	$lexicon->{"<N>"} = $N;
	$lexicon->{"<THETA>"} = $theta;
	$lexicon->{"<LAMBDA1>"} = $lambda1;
	$lexicon->{"<LAMBDA2>"} = $lambda2;
	$lexicon->{"<LAMBDA3>"} = $lambda3;

	untie( %{ $lexicon } );
	#ver 6.3
	untie( %{ $sufftree } );
	
	close( TRAIN );
}

sub getAttributes( $$ ) {
	my( $this ) = shift( @_ );
	my( $tok ) = $_[0];
	my( $wordform, $lemma, $tag );

	if ( $tok =~ s/\//\//g == 2 ) {
		( $wordform, $lemma, $tag ) = split( /\//, $tok );
	}
	else {
		( $tag ) = ( $tok =~ /\/([^\/]+)$/ );
		$tok =~ s/\/([^\/]+)$//;

		my( @lettok ) = split( //, $tok );
		
		if ( scalar( @lettok ) % 2 == 1 ) {
			my( $midx ) = int( scalar( @lettok ) / 2 );

			$wordform = join( "", @lettok[0 .. $midx - 1] );
			$lemma = join( "", @lettok[$midx + 1 .. $#lettok] );
		}
		else {
			$wordform = $lemma = "_?_";
			#warn( "Wrong !!\n" );
		}
	}

	return ( $wordform, $lemma, $tag );
}

sub extractSGMLChars( $$ ) {
	my( $this ) = shift( @_ );
	my( $word ) = $_[0];
	my( @diacs ) = ( $word =~ /(&.+?;)/g );
	my( @out ) = ();

	$word =~ s/&.+?;/=/g;

	my( @eqlett ) = split( //, $word );

	foreach my $l ( @eqlett ) {
		if ( $l ne "=" ) {
			push( @out, $l );
		}
		else {
			push( @out, shift( @diacs ) );
		}
	}

	return @out;
}

sub trainLemModel( $ ) {
	my( $this ) = shift( @_ );
	my( $tblfile, $testsample, $ttags, $file ) = ( $CONFTLEM{"TBL"}, $CONFTLEM{"TESTSAMPLEPERTAG"}, $CONFTLEM{"TRAINTAGS"}, $CONFTLEM{"MODELFILE"} );
	my( $linecnt ) = 0;
	my( %lemmodel ) = ();
	my( %evaltbl ) = ();

	print( STDERR "Scanning $tblfile ...\n" ) if ( $CONFTLEM{"DEBUG"} );
	open( TBL, "< $tblfile" ) or die( "ttl::trainLemModel : file $tblfile could not be opened !\n" );
	
	while ( my $line = <TBL> ) {
		$linecnt++;
		print( STDERR "ttl::trainLemModel : $linecnt lines scanned ...\n" ) if ( $CONFTLEM{"DEBUG"} && $linecnt % 1000 == 0 );
		$line =~ s/\r?\n$//;

		next if ( $line =~ /^$/ || $line =~ /^#/ );

		my( @toks ) = split( /\s+/, $line );

		do {
			warn( "ttl::trainLemModel : not 3 tokens @ $linecnt in $tblfile !\n" ) if ( $CONFTLEM{"DEBUG"} );
			next;
		} if ( scalar( @toks ) != 3 );
		
		my( $wordform, $lemma, $tag ) = ( $toks[0], ( ( $toks[1] eq "=" ) ? $toks[0] : $toks[1] ), $toks[2] );

		#ver 6.6
		next if ( $wordform =~ /_/ || $lemma =~ /_/ );

		if ( exists( $ttags->{$tag} ) ) {
			if ( ! exists( $lemmodel{$tag} ) ) {
				$lemmodel{$tag} = { "MMOD" => {}, "RULES" => {} };
			}

			if ( ! exists( $evaltbl{$tag} ) ) {
				$evaltbl{$tag} = [];
			}

			#Test on everything ...
			if ( $testsample == 0 ) {
				push( @{ $evaltbl{$tag} }, [ $wordform, $lemma ] );

				$this->learnMM( $lemma, $lemmodel{$tag}->{"MMOD"} );
				$this->learnRules( $wordform, $lemma, $lemmodel{$tag}->{"RULES"} ) if ( $wordform ne $lemma );
			}
			else {
				if ( $linecnt % 3 == 0 && exists( $evaltbl{$tag} ) && scalar( @{ $evaltbl{$tag} } ) < $testsample ) {
					push( @{ $evaltbl{$tag} }, [ $wordform, $lemma ] );
				}
				else {
					$this->learnMM( $lemma, $lemmodel{$tag}->{"MMOD"} );
					$this->learnRules( $wordform, $lemma, $lemmodel{$tag}->{"RULES"} ) if ( $wordform ne $lemma );
				}
			}
		}
	}
	
	close( TBL );

	print( STDERR "Computing lambdas ...\n" ) if ( $CONFTLEM{"DEBUG"} );
	foreach my $t ( keys( %lemmodel ) ) {
		$this->computeLambdas( $lemmodel{$t}->{"MMOD"} );
	}

	print( STDERR "Evaluating the lemma heuristics on the test set ...\n" ) if ( $CONFTLEM{"DEBUG"} );

	foreach my $tag ( keys( %evaltbl ) ) {
		print( STDERR "Evaluating the lemma heuristics on $tag ...\n" ) if ( $CONFTLEM{"DEBUG"} );
		foreach my $wflem ( @{ $evaltbl{$tag} } ) {
			my( $wordform, $lemma ) = @{ $wflem };

			if ( exists( $lemmodel{$tag} ) ) {
				if ( ! exists( $lemmodel{$tag}->{"HEUR"} ) ) {
					$lemmodel{$tag}->{"HEUR"} = { "_NLEM" => 1 };
				}
				else {
					$lemmodel{$tag}->{"HEUR"}->{"_NLEM"}++;
				}
				
				my( @plemmas ) = $this->generateLemmas( lc( $wordform ), $lemmodel{$tag}->{"RULES"} );
				my( $hlemmas ) = $this->guessLemma( \@plemmas, $lemmodel{$tag}->{"MMOD"} );

				foreach my $h ( keys( %{ $hlemmas } ) ) {
					my( $hlem ) = $hlemmas->{$h};

					if ( defined( $hlem ) && lc( $lemma ) eq $hlem ) {
						if ( ! exists( $lemmodel{$tag}->{"HEUR"}->{$h} ) ) {
							$lemmodel{$tag}->{"HEUR"}->{$h} = 1;
						}
						else {
							$lemmodel{$tag}->{"HEUR"}->{$h}++;
						}
					}
				} #end every hi

				my( @heurs ) = keys( %{ $hlemmas } );

				for ( my $i = 0; $i < scalar( @heurs ) - 1; $i++ ) {
					my( $hilemma ) = $hlemmas->{$heurs[$i]};

					for ( my $j = $i + 1; $j < scalar( @heurs ); $j++ ) {
						my( $hjlemma ) = $hlemmas->{$heurs[$j]};

						if ( defined( $hilemma ) && defined( $hjlemma ) && $hilemma eq lc( $lemma ) && $hjlemma eq lc( $lemma ) ) {
							my( $hkey ) = $heurs[$i] . "," . $heurs[$j];

							if ( ! exists( $lemmodel{$tag}->{"HEUR"}->{$hkey} ) ) {
								$lemmodel{$tag}->{"HEUR"}->{$hkey} = 1;
							}
							else {
								$lemmodel{$tag}->{"HEUR"}->{$hkey}++;
							}
						}
					}
				} #end hi,hj
			} #exists lemmodel{tag}
		}
	}
	
	$this->saveLemModel( \%lemmodel, $file );
}

sub computeLambdas( $$ ) {
	my( $this ) = shift( @_ );
	my( $mm ) = $_[0];
	my( $L1, $L2, $L3, $L4 ) = ( 0, 0, 0, 0 );

	foreach my $g ( keys( %{ $mm } ) ) {
		my( @glet ) = $this->extractSGMLChars( $g );

		next if ( scalar( @glet ) < 4 );

		my( $f1234 ) = $mm->{$g};
		my( $f123 ) = $mm->{join( "", @glet[0 .. 2] )};
		my( $f234 ) = $mm->{join( "", @glet[1 .. 3] )};
		my( $f34 ) = $mm->{join( "", @glet[2 .. 3] )};
		my( $f23 ) = $mm->{join( "", @glet[1 .. 2] )};
		my( $f3 ) = $mm->{$glet[2]};
		my( $f4 ) = $mm->{$glet[3]};
		my( $N ) = $mm->{"_N"};

		my( $case4 ) = ( $f123 == 1 ? 0 : ( $f1234 - 1 ) / ( $f123 - 1 ) );
		my( $case3 ) = ( $f23 == 1 ? 0 : ( $f234 - 1 ) / ( $f23 - 1 ) );
		my( $case2 ) = ( $f3 == 1 ? 0 : ( $f34 - 1 ) / ( $f3 - 1 ) );
		my( $case1 ) = ( $N == 1 ? 0 : ( $f4 - 1 ) / ( $N - 1 ) );

		my( @lambdas ) = ( [ \$L1, $case1 ], [ \$L2, $case2 ], [ \$L3, $case3 ], [ \$L4, $case4 ] );
		my( @slambdas ) = sort {
			$b->[1] <=> $a->[1];
		} @lambdas;
		my( $maxval ) = $slambdas[0]->[1];

		for ( my $j = 0; $j < scalar( @slambdas ); $j++ ) {
			my( $cval ) = $slambdas[$j]->[1];
			
			do {
				${ $slambdas[$j]->[0] } += $f1234;
			}
			if ( abs( $cval - $maxval ) < 0.1e-20 );
		}
	}

	my( $sum ) = $L1 + $L2 + $L3 + $L4;

	# ver. 8.8
	$sum = 1 if ( $sum == 0 );
	
	$mm->{"_L1"} = $L1 / $sum;
	$mm->{"_L2"} = $L2 / $sum;
	$mm->{"_L3"} = $L3 / $sum;
	$mm->{"_L4"} = $L4 / $sum;
}

sub learnRules( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $wordform, $lemma, $rules ) = ( $_[0], $_[1], $_[2] );
	my( @wflet ) = $this->extractSGMLChars( $wordform );
	my( @lemlet ) = $this->extractSGMLChars( $lemma );
	my( @wflemsdiff ) = sdiff( \@wflet, \@lemlet );
	my( @possibleLCS ) = ();
	my( $startpos, $length ) = ( -1, 0 );
	my( $setpos ) = 0;
	
	for ( my $i = 0; $i < scalar( @wflemsdiff ); $i++ ) {
		my( $dv ) = $wflemsdiff[$i];

		if ( $dv->[0] eq "u" ) {
			if ( ! $setpos ) {
				$startpos = $i;
				$setpos = 1;
			}
			$length++;
		}
		else {
			push( @possibleLCS, [ $length, $startpos ] );
			( $startpos, $length ) = ( -1, 0 );
			$setpos = 0;
		}
	}

	if ( $startpos != -1 ) {
		push( @possibleLCS, [ $length, $startpos ] );
	}
	
	my( @spossibleLCS ) = sort {
		$b->[0] <=> $a->[0];
	} @possibleLCS;
	my( $winner ) = shift( @spossibleLCS );
	my( $LCS ) = join( "", map { $_->[1] } @wflemsdiff[$winner->[1] .. $winner->[1] + $winner->[0] - 1] );
	
	#CONDITIE DE INVATARE !!
	my( @LCSchars ) = $this->extractSGMLChars( $LCS );
	my( @wordformchars ) = $this->extractSGMLChars( $wordform );

	return if ( scalar( @LCSchars ) / scalar( @wordformchars ) < $CONFTLEM{"LCSOVERWF"} );

	$wordform =~ s/$LCS/{LCS}/;
	$lemma =~ s/$LCS/{LCS}/;

	my( $rule ) = $wordform . "->" . $lemma;

	if ( ! exists( $rules->{$rule} ) ) {
		$rules->{$rule} = 1;
	}
	else {
		$rules->{$rule}++;
	}
}

sub learnMM( $$$ ) {
	my( $this ) = shift( @_ );
	my( $lemma, $markovmodel ) = ( $_[0], $_[1] );
	my( @charlemma ) = $this->extractSGMLChars( $lemma );
	my( @llemma ) = ( ">", ">", @charlemma, "<" );
	
	for ( my $i = 0; $i < scalar( @llemma ); $i++ ) {
		my( $char ) = $llemma[$i];

		if ( ! exists( $markovmodel->{$char} ) ) {
			$markovmodel->{$char} = 1;
		}
		else {
			$markovmodel->{$char}++;
		}
	}

	for ( my $i = 0; $i <= scalar( @llemma ) - 2; $i++ ) {
		my( $bigram ) = $llemma[$i] . $llemma[$i + 1];

		if ( ! exists( $markovmodel->{$bigram} ) ) {
			$markovmodel->{$bigram} = 1;
		}
		else {
			$markovmodel->{$bigram}++;
		}
	}

	for ( my $i = 0; $i <= scalar( @llemma ) - 3; $i++ ) {
		my( $trigram ) = $llemma[$i] . $llemma[$i + 1] . $llemma[$i + 2];

		if ( ! exists( $markovmodel->{$trigram} ) ) {
			$markovmodel->{$trigram} = 1;
		}
		else {
			$markovmodel->{$trigram}++;
		}
	}

	for ( my $i = 0; $i <= scalar( @llemma ) - 4; $i++ ) {
		my( $fourgram ) = $llemma[$i] . $llemma[$i + 1] . $llemma[$i + 2] . $llemma[$i + 3];

		if ( ! exists( $markovmodel->{$fourgram} ) ) {
			$markovmodel->{$fourgram} = 1;
		}
		else {
			$markovmodel->{$fourgram}++;
		}
	}

	$markovmodel->{"_N"} += scalar( @llemma );
}

sub saveLemModel( $$$ ) {
	my( $this ) = shift( @_ );
	my( $model, $file ) = ( $_[0], $_[1] );

	open( LM, "> $file" ) or die( "ttl::saveLemModel : cannot open $file for writing !\n" );

	foreach my $t ( keys( %{ $model } ) ) {
		my( $mm, $rules, $heurstats ) = ( $model->{$t}->{"MMOD"}, $model->{$t}->{"RULES"}, $model->{$t}->{"HEUR"} );

		print( LM "#The heuristic freq:\n" );
		foreach my $k ( sort keys( %{ $heurstats } ) ) {
			print( LM "$t\tHR\t$k\t" . $heurstats->{$k} . "\n" );
		}

		print( LM "#The Markov Model parameters:\n" );
		print( LM "$t\tMM\t_N\t" . $mm->{"_N"} . "\n" );
		print( LM "$t\tMM\t_L1\t" . $mm->{"_L1"} . "\n" );
		print( LM "$t\tMM\t_L2\t" . $mm->{"_L2"} . "\n" );
		print( LM "$t\tMM\t_L3\t" . $mm->{"_L3"} . "\n" );
		print( LM "$t\tMM\t_L4\t" . $mm->{"_L4"} . "\n\n" );
		
		print( LM "#Uni, Bi and Trigrams:\n" );
		foreach my $mmk ( keys( %{ $mm } ) ) {
			next if ( $mmk =~ /^_[NL][123]?$/ );
			print( LM "$t\tMM\t" . $mmk . "\t" . $mm->{$mmk} . "\n" );
		}
		print( LM "\n" );

		print( LM "#Rules:\n" );
		foreach my $r ( keys( %{ $rules } ) ) {
			#CONDITIE DE INVATARE !!
			print( LM "$t\tRUL\t" . $r . "\t" . $rules->{$r} . "\n" ) if ( $rules->{$r} > $CONFTLEM{"SAVERULEFREQ"} );
		}
	}

	close( LM );
}

sub loadLemModel( $$ ) {
	my( $this ) = shift( @_ );
	my( %lemmodel );

	open( MOD, "< $_[0]" ) or die( "ttl::loadLemModel : file $_[0] could not be opened !\n" );
	
	while ( my $line = <MOD> ) {
		$line =~ s/\r?\n$//;

		next if ( $line =~ /^$/ || $line =~ /^#/ );

		my( @toks ) = split( /\s+/, $line );
		my( $tag, $mod, $key, $value ) = ( $toks[0], $toks[1], $toks[2], $toks[3] );
		my( $mmodel, $rules, $heur );
		
		if ( ! exists( $lemmodel{$tag} ) ) {
			$lemmodel{$tag} = { "MMOD" => {}, "RULES" => {}, "HEUR" => {} };
		}

		$mmodel = $lemmodel{$tag}->{"MMOD"};
		$rules = $lemmodel{$tag}->{"RULES"};
		$heur = $lemmodel{$tag}->{"HEUR"};

		SWMMM: {
			$mod eq "MM" and do {
				$mmodel->{$key} = $value;
				last SWMMM;
			};

			$mod eq "RUL" and do {
				$rules->{$key} = $value;
				last SWMMM;
			};

			$mod eq "HR" and do {
				$heur->{$key} = $value;
				last SWMMM;
			};
		}
	}
	
	close( MOD );

	return ( \%lemmodel );
}

sub generateLemmas( $$$ ) {
	my( $this ) = shift( @_ );
	my( $word ) = $_[0];
	my( $rules ) = $_[1];
	my( @lemmas ) = ();

	foreach my $r ( keys( %{ $rules } ) ) {
		my( @rule ) = split( /->/, $r );
		
		$rule[0] =~ s/{LCS}/(.+)/;

		my( $LCS ) = ( $word =~ /^$rule[0]$/ );

		next if ( ! defined( $LCS ) );

		$rule[1] =~ s/{LCS}/$LCS/;

		push( @lemmas, [ $rule[1], $rules->{$r} ] );
	}

	return @lemmas;
}

sub computeMM( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $CONFLEM ) = $this->{"CONFLEM"};
	my( $word, $mm, $opermode ) = ( $_[0], $_[1], $_[2] );
	my( @word ) = ();
	
	SWMOD1: {
		$opermode eq "SUFF" and @word = ( $this->extractSGMLChars( $word ), "<" );
		$opermode eq "PREF" and @word = ( ">", ">", $this->extractSGMLChars( $word ) );
		$opermode eq "WORD" and @word = ( ">", ">", $this->extractSGMLChars( $word ), "<" );
	}
	
	my( $logscore ) = 0;
	my( $notexistent ) = 0;

	if ( scalar( @word ) == 2 ) {
		my( $P1, $P2 ) = ( 0, 0 );

		if ( exists( $mm->{$word[1]} ) && exists( $mm->{"_N"} ) ) {
			$P1 = $mm->{"_L1"} * ( $mm->{$word[1]} / $mm->{"_N"} );
		}
		else {
			warn( "ttl::computeMM : not existent unigram \'" . $word[1] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
		}
		
		if ( exists( $mm->{$word[0]} ) && exists( $mm->{$word[0] . $word[1]} ) ) {
			$P2 = $mm->{"_L2"} * ( $mm->{$word[0] . $word[1]} / $mm->{$word[0]} );
		}
		else {
			warn( "ttl::computeMM : not existent unigram \'" . $word[0] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent bigram \'" . $word[0] . $word[1] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}

		my( $P ) = $P1 + $P2;

		if ( $P == 0 ) {
			$P = $CONFLEM->{"LOWPROB"};
		}

		return abs( log( $P ) );
	}

	if ( scalar( @word ) == 3 ) {
		my( $P1, $P2, $P3 ) = ( 0, 0, 0 );

		if ( exists( $mm->{$word[2]} ) && exists( $mm->{"_N"} ) ) {
			$P1 = $mm->{"_L1"} * ( $mm->{$word[2]} / $mm->{"_N"} );
		}
		else {
			warn( "ttl::computeMM : not existent unigram \'" . $word[2] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
		}
		
		if ( exists( $mm->{$word[1]} ) && exists( $mm->{$word[1] . $word[2]} ) ) {
			$P2 = $mm->{"_L2"} * ( $mm->{$word[1] . $word[2]} / $mm->{$word[1]} );
		}
		else {
			warn( "ttl::computeMM : not existent unigram \'" . $word[1] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent bigram \'" . $word[1] . $word[2] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}

		if ( exists( $mm->{$word[0] . $word[1]} ) && exists( $mm->{$word[0] . $word[1] . $word[2]} ) ) {
			$P3 = $mm->{"_L3"} * ( $mm->{$word[0] . $word[1] . $word[2]} / $mm->{$word[0] . $word[1]} );
		}
		else {
			warn( "ttl::computeMM : not existent bigram \'" . $word[0] . $word[1] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent trigram \'" . $word[0] . $word[1] . $word[2] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}

		my( $P ) = $P1 + $P2 + $P3;

		if ( $P == 0 ) {
			$P = $CONFLEM->{"LOWPROB"};
		}

		return abs( log( $P ) );
	}

	for ( my $i = 0; $i <= scalar( @word ) - 4; $i++ ) {
		my( $P1, $P2, $P3, $P4 ) = ( 0, 0, 0, 0 );

		if ( exists( $mm->{$word[$i + 3]} ) && exists( $mm->{"_N"} ) ) {
			$P1 = $mm->{"_L1"} * ( $mm->{$word[$i + 3]} / $mm->{"_N"} );
		}
		else {
			warn( "ttl::computeMM : not existent unigram \'" . $word[$i + 3] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
		}
		
		if ( exists( $mm->{$word[$i + 2]} ) && exists( $mm->{$word[$i + 2] . $word[$i + 3]} ) ) {
			$P2 = $mm->{"_L2"} * ( $mm->{$word[$i + 2] . $word[$i + 3]} / $mm->{$word[$i + 2]} );
		}
		else {
			warn( "ttl::computeMM : not existent unigram \'" . $word[$i + 2] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent bigram \'" . $word[$i + 2] . $word[$i + 3] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}
		
		if ( exists( $mm->{$word[$i + 1] . $word[$i + 2]} ) && exists( $mm->{$word[$i + 1] . $word[$i + 2] . $word[$i + 3]} ) ) {
			$P3 = $mm->{"_L3"} * ( $mm->{$word[$i + 1] . $word[$i + 2] . $word[$i + 3]} / $mm->{$word[$i + 1] . $word[$i + 2]} );
		}
		else {
			warn( "ttl::computeMM : not existent bigram \'" . $word[$i + 1] . $word[$i + 2] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent trigram \'" . $word[$i + 1] . $word[$i + 2] . $word[$i + 3] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}

		if ( exists( $mm->{$word[$i] . $word[$i + 1] . $word[$i + 2]} ) && exists( $mm->{$word[$i] . $word[$i + 1] . $word[$i + 2] . $word[$i + 3]} ) ) {
			$P4 = $mm->{"_L4"} * ( $mm->{$word[$i] . $word[$i + 1] . $word[$i + 2] . $word[$i + 3]} / $mm->{$word[$i] . $word[$i + 1] . $word[$i + 2]} );
		}
		else {
			warn( "ttl::computeMM : not existent trigram \'" . $word[$i] . $word[$i + 1] . $word[$i + 2] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent fourgram \'" . $word[$i] . $word[$i + 1] . $word[$i + 2] . $word[$i + 3] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}
		
		my( $P ) = $P1 + $P2 + $P3 + $P4;

		if ( $P == 0 ) {
			$P = $CONFLEM->{"LOWPROB"};
		}

		$logscore += abs( log( $P ) );
	}

	return $logscore;
}

sub computeMMDirect( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $CONFLEM ) = $this->{"CONFLEM"};
	my( $word, $mm, $opermode ) = ( $_[0], $_[1], $_[2] );
	my( @word ) = ();
	
	SWMOD1: {
		$opermode eq "SUFF" and @word = ( $this->extractSGMLChars( $word ), "<" );
		$opermode eq "PREF" and @word = ( ">", ">", $this->extractSGMLChars( $word ) );
		$opermode eq "WORD" and @word = ( ">", ">", $this->extractSGMLChars( $word ), "<" );
	}
	
	my( $logscore ) = 0;
	my( $notexistent ) = 0;

	if ( scalar( @word ) == 2 ) {
		my( $P1, $P2 ) = ( 0, 0 );

		if ( exists( $mm->{$word[0]} ) && exists( $mm->{$word[0] . $word[1]} ) ) {
			$P2 = $mm->{$word[0] . $word[1]} / $mm->{$word[0]};
		}
		else {
			warn( "ttl::computeMM : not existent unigram \'" . $word[0] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent bigram \'" . $word[0] . $word[1] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}

		my( $P ) = $P1 + $P2;

		if ( $P == 0 ) {
			$P = $CONFLEM->{"LOWPROB"};
		}

		return abs( log( $P ) );
	}

	if ( scalar( @word ) == 3 ) {
		my( $P1, $P2, $P3 ) = ( 0, 0, 0 );

		if ( exists( $mm->{$word[0] . $word[1]} ) && exists( $mm->{$word[0] . $word[1] . $word[2]} ) ) {
			$P3 = $mm->{$word[0] . $word[1] . $word[2]} / $mm->{$word[0] . $word[1]};
		}
		else {
			warn( "ttl::computeMM : not existent bigram \'" . $word[0] . $word[1] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent trigram \'" . $word[0] . $word[1] . $word[2] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}

		my( $P ) = $P1 + $P2 + $P3;

		if ( $P == 0 ) {
			$P = $CONFLEM->{"LOWPROB"};
		}

		return abs( log( $P ) );
	}

	for ( my $i = 0; $i <= scalar( @word ) - 4; $i++ ) {
		my( $P1, $P2, $P3, $P4 ) = ( 0, 0, 0, 0 );

		if ( exists( $mm->{$word[$i] . $word[$i + 1] . $word[$i + 2]} ) && exists( $mm->{$word[$i] . $word[$i + 1] . $word[$i + 2] . $word[$i + 3]} ) ) {
			$P4 = $mm->{$word[$i] . $word[$i + 1] . $word[$i + 2] . $word[$i + 3]} / $mm->{$word[$i] . $word[$i + 1] . $word[$i + 2]};
		}
		else {
			warn( "ttl::computeMM : not existent trigram \'" . $word[$i] . $word[$i + 1] . $word[$i + 2] . "\' or,\n" ) if ( $CONFLEM->{"DEBUG"} );
			warn( "ttl::computeMM : not existent fourgram \'" . $word[$i] . $word[$i + 1] . $word[$i + 2] . $word[$i + 3] . "\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
		}
		
		my( $P ) = $P1 + $P2 + $P3 + $P4;

		if ( $P == 0 ) {
			$P = $CONFLEM->{"LOWPROB"};
		}

		$logscore += abs( log( $P ) );
	}

	return $logscore;
}

sub applyMM( $$$$ ) {
	my( $this ) = shift( @_ );
	my( @alllemmas ) = @{ $_[0] };
	my( $mm ) = $_[1];
	my( $mmMODE ) = $_[2];

	foreach my $l ( @alllemmas ) {
		my( $OPER ) = "SUFF";
		my( @lchars ) = $this->extractSGMLChars( $l->[0] );
				
		for ( my $k = $#lchars; $k > 0; $k-- ) {
			my( $suff ) = join( "", @lchars[$k .. $#lchars] );
			my( $mmS ) = 0;
			
			SWMMMODE1: {
				$mmMODE eq "L" and $mmS = $this->computeMM( $suff, $mm, "SUFF" );
				$mmMODE eq "S" and $mmS = $this->computeMMDirect( $suff, $mm, "SUFF" );
			}

			push( @{ $l }, $mmS );
		}

		SWMMMODE2: {
			$mmMODE eq "L" and push( @{ $l }, $this->computeMM( $l->[0], $mm, "WORD" ) );
			$mmMODE eq "S" and push( @{ $l }, $this->computeMMDirect( $l->[0], $mm, "WORD" ) );
		}
	}

	#Contine: lema, frecventa regulii de lematizare, scor MM2, scor MM3, ..., scor MMk
	return @alllemmas;
}

sub conftrainlemmatizer( $$ ) {
	my( $this ) = shift( @_ );
	my( %conf ) = %{ $_[0] };

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFTLEM{$k} ) ) {
			$CONFTLEM{$k} = $conf{$k};
		}
	}

	foreach my $k ( keys( %CONFTLEM ) ) {
		if ( ! defined( $CONFTLEM{$k} ) ) {
			die( "ttl::conftrainlemmatizer : config key $k has no value !\n" );
		}
	}

}

sub readTblWordform( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFLEM ) = $this->{"CONFLEM"};
	my( $linecnt ) = 0;
	my( %tbl ) = ();

	open( TBL, "< $_[0]" ) or die( "ttl::readTblWordform : Cannot open tbl.wordform !\n" );
	
	while ( my $line = <TBL> ) {
		$linecnt++;
		print( STDERR "ttl::readTblWordform : $linecnt lines scanned ...\n" ) if ( $CONFLEM->{"DEBUG"} && $linecnt % 1000 == 0 );
		$line =~ s/\r?\n$//;

		next if ( $line =~ /^$/ || $line =~ /^#/ );

		my( @toks ) = split( /\s+/, $line );

		do {
			warn( "ttl::readTblWordform : not 3 tokens @ $linecnt in " . $_[0] . " !\n" ) if ( $CONFLEM->{"DEBUG"} );
			next;
		} if ( scalar( @toks ) != 3 );
		
		my( $wordform, $lemma, $tag ) = ( $toks[0], ( ( $toks[1] eq "=" ) ? $toks[0] : $toks[1] ), $toks[2] );

		if ( ! exists( $tbl{$wordform} ) ) {
			$tbl{$wordform} = { $tag => $lemma };
		}
		else {
			if ( ! exists( $tbl{$wordform}->{$tag} ) ) {
				$tbl{$wordform}->{$tag} = $lemma;
			}
			else {
				warn( "ttl::readTblWordform : for $wordform,$tag with lemma \'" . $tbl{$wordform}->{$tag} . "\' another lemma was found: \'$lemma\' !\n" ) if ( $CONFLEM->{"DEBUG"} );
			}
		}
	}

	close( TBL );
	return \%tbl;
}

#8.0
#Probabilities tbl wordform with entries of the form:
#cr&ucirc;tes	croire			Vmis2p	0.8
#cr&ucirc;tes	cro&icirc;tre	Vmis2p	0.2
sub readProbTblWordform( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFLEM ) = $this->{"CONFLEM"};
	my( $linecnt ) = 0;
	my( %tbl ) = ();

	open( TBL, "< $_[0]" ) or die( "ttl::readProbTblWordform : Cannot open tbl.wordform with probabilities !\n" );
	
	while ( my $line = <TBL> ) {
		$linecnt++;
		
		$line =~ s/^\s+//;
		$line =~ s/\r?\n$//;

		next if ( $line =~ /^$/ || $line =~ /^#/ );

		my( @toks ) = split( /\s+/, $line );

		do {
			warn( "ttl::readProbTblWordform : not 4 tokens @ $linecnt in " . $_[0] . " !\n" ) if ( $CONFLEM->{"DEBUG"} );
			next;
		} if ( scalar( @toks ) != 4 );
		
		my( $wordform, $lemma, $tag, $prob ) = ( $toks[0], ( ( $toks[1] eq "=" ) ? $toks[0] : $toks[1] ), $toks[2], $toks[3] );

		if ( ! exists( $tbl{$wordform} ) ) {
			$tbl{$wordform} = { $tag => { $lemma => $prob } };
		}
		else {
			if ( ! exists( $tbl{$wordform}->{$tag} ) ) {
				$tbl{$wordform}->{$tag} = { $lemma => $prob };
			}
			else {
				$tbl{$wordform}->{$tag}->{$lemma} = $prob;
			}
		}
	}

	close( TBL );
	return \%tbl;
}

sub conflemmatizer( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFLEM ) = $this->{"CONFLEM"};
	my( %conf ) = %{ $_[0] };

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFLEM->{$k} ) ) {
			SWK4: {
				$k eq "TBL" and do {
					$CONFLEM->{$k} = $this->readTblWordform( $conf{$k} );
					last;
				};
				
				#ver 8.0
				$k eq "AMBTBL" and do {
					$CONFLEM->{$k} = $this->readProbTblWordform( $conf{$k} );
					last;
				};

				$k eq "LMODEL" and do {
					$CONFLEM->{$k} = $this->loadLemModel( $conf{$k} );
					last;
				};

				#4.2
				$k eq "MSDTOTAG" and do {
					$CONFLEM->{$k} = $this->readMSDtoTAGMapping( $conf{$k} );
					last;
				};

				$k eq "TAGTOMSD" and do {
					$CONFLEM->{$k} = $this->readTAGtoMSDMapping( $conf{$k} );
					last;
				};

				$CONFLEM->{$k} = $conf{$k};
			}
		}
	}

	foreach my $k ( keys( %{ $CONFLEM } ) ) {
		if ( ! defined( $CONFLEM->{$k} ) ) {
			die( "ttl::conflemmatizer : config key $k has no value !\n" );
		}
	}
}

sub guessLemma( $$$ ) {
	my( $this ) = shift( @_ );
	my( @plemmas ) = @{ $_[0] };
	my( $mmodel ) = $_[1];
	my( $finallemma ) = "?";
	my( @plemmas_rmms ) = ();
	my( @plemmas_rmml ) = ();
	
#	@plemmas_rmms = $this->applyMM( \@plemmas, $mmodel, "S" );
	@plemmas_rmml = $this->applyMM( \@plemmas, $mmodel, "L" );

	my( $heurMAXMMSScore ) = sub {
		my( @temp ) = sort {
			my( @av ) = @{ $a };
			my( @bv ) = @{ $b };

			return $av[$#av] <=> $bv[$#bv];

		} @plemmas_rmms;

		return ( "HMAXMMSSCORE" => $temp[0]->[0] );
	};

	my( $heurMAXMMLScore ) = sub {
		my( @temp ) = sort {
			my( @av ) = @{ $a };
			my( @bv ) = @{ $b };

			return $av[$#av] <=> $bv[$#bv];

		} @plemmas_rmml;

		return ( "HMAXMMLSCORE" => $temp[0]->[0] );
	};

	my( $heurMAXRuleFreq ) = sub {
		my( @temp ) = sort {
			my( @av ) = @{ $a };
			my( @bv ) = @{ $b };

			return $bv[1] <=> $av[1];
		} @plemmas;

		return ( "HMAXRFREQ" => $temp[0]->[0] );
	};

	my( $heurMAXTableScoreS ) = sub {
		my( %scorehash ) = ();
		my( %finalschash ) = ();
		my( $maxlength ) = 0;

		foreach my $t ( @plemmas_rmms ) {
			my( @la ) = @{ $t };
			my( $lemma ) = $la[0];
			my( @hmma ) = @la[2 .. $#la];

			if ( scalar( @hmma ) > $maxlength ) {
				$maxlength = scalar( @hmma );
			}

			$scorehash{$lemma} = \@hmma;
			$finalschash{$lemma} = 0;
		}

		for ( my $i = 0; $i < $maxlength; $i++ ) {
			my( @crtvec ) = ();

			foreach my $l ( keys( %scorehash ) ) {
				my( @hmma ) = @{ $scorehash{$l} };

				if ( exists( $hmma[$i] ) ) {
					push( @crtvec, [ $l, $hmma[$i] ] );
				}
				else {
					push( @crtvec, [ $l, $hmma[$#hmma] ] );
				}
			}

			my( @scrtvec ) = sort {
				return $b->[1] <=> $a->[1];
			} @crtvec;

			for ( my $j = $#scrtvec; $j >= 0; $j-- ) {
				my( $l, $mms ) = @{ $scrtvec[$j] };

				$finalschash{$l} += ( ( $j + 1 ) / scalar( @scrtvec ) ) * ( $i + 1 );
			}
		}

		my( @finallems2 ) = map { [ $_, $finalschash{$_} ] } keys( %finalschash );
		my( @finallems ) = sort {
			$b->[1] <=> $a->[1];
		} @finallems2;

		return ( "HMAXTBLSCORES" => $finallems[0]->[0] );
	};

	my( $heurMAXTableScoreL ) = sub {
		my( %scorehash ) = ();
		my( %finalschash ) = ();
		my( $maxlength ) = 0;

		foreach my $t ( @plemmas_rmml ) {
			my( @la ) = @{ $t };
			my( $lemma ) = $la[0];
			my( @hmma ) = @la[2 .. $#la];

			if ( scalar( @hmma ) > $maxlength ) {
				$maxlength = scalar( @hmma );
			}

			$scorehash{$lemma} = \@hmma;
			$finalschash{$lemma} = 0;
		}

		for ( my $i = 0; $i < $maxlength; $i++ ) {
			my( @crtvec ) = ();

			foreach my $l ( keys( %scorehash ) ) {
				my( @hmma ) = @{ $scorehash{$l} };

				if ( exists( $hmma[$i] ) ) {
					push( @crtvec, [ $l, $hmma[$i] ] );
				}
				else {
					push( @crtvec, [ $l, $hmma[$#hmma] ] );
				}
			}

			my( @scrtvec ) = sort {
				return $b->[1] <=> $a->[1];
			} @crtvec;

			for ( my $j = $#scrtvec; $j >= 0; $j-- ) {
				my( $l, $mms ) = @{ $scrtvec[$j] };

				$finalschash{$l} += ( ( $j + 1 ) / scalar( @scrtvec ) ) * ( $i + 1 );
			}
		}

		my( @finallems2 ) = map { [ $_, $finalschash{$_} ] } keys( %finalschash );
		my( @finallems ) = sort {
			$b->[1] <=> $a->[1];
		} @finallems2;

		return ( "HMAXTBLSCOREL" => $finallems[0]->[0] );
	};

	my( $heurMAXTableScoreLemmaLenS ) = sub {
		my( %scorehash ) = ();
		my( %finalschash ) = ();
		my( $maxlength ) = 0;

		foreach my $t ( @plemmas_rmms ) {
			my( @la ) = @{ $t };
			my( $lemma ) = $la[0];
			my( @hmma ) = @la[2 .. $#la];

			if ( scalar( @hmma ) > $maxlength ) {
				$maxlength = scalar( @hmma );
			}

			$scorehash{$lemma} = \@hmma;
			$finalschash{$lemma} = 0;
		}

		for ( my $i = 0; $i < $maxlength; $i++ ) {
			my( @crtvec ) = ();

			foreach my $l ( keys( %scorehash ) ) {
				my( @hmma ) = @{ $scorehash{$l} };

				if ( exists( $hmma[$i] ) ) {
					push( @crtvec, [ $l, $hmma[$i] ] );
				}
				else {
					push( @crtvec, [ $l, $hmma[$#hmma] ] );
				}
			}

			my( @scrtvec ) = sort {
				return $b->[1] <=> $a->[1];
			} @crtvec;

			for ( my $j = $#scrtvec; $j >= 0; $j-- ) {
				my( $l, $mms ) = @{ $scrtvec[$j] };

				$finalschash{$l} += ( ( $j + 1 ) / scalar( @scrtvec ) ) * ( $i + 1 );
			}
		}

		foreach my $l ( keys( %finalschash ) ) {
			my( @lchars ) = $this->extractSGMLChars( $l );

			$finalschash{$l} = $finalschash{$l} / scalar( @lchars );
		}

		my( @finallems2 ) = map { [ $_, $finalschash{$_} ] } keys( %finalschash );
		my( @finallems ) = sort {
			$b->[1] <=> $a->[1];
		} @finallems2;

		return ( "HMAXTBLSCORELEMLENS" => $finallems[0]->[0] );
	};

	my( $heurMAXTableScoreLemmaLenL ) = sub {
		my( %scorehash ) = ();
		my( %finalschash ) = ();
		my( $maxlength ) = 0;

		foreach my $t ( @plemmas_rmml ) {
			my( @la ) = @{ $t };
			my( $lemma ) = $la[0];
			my( @hmma ) = @la[2 .. $#la];

			if ( scalar( @hmma ) > $maxlength ) {
				$maxlength = scalar( @hmma );
			}

			$scorehash{$lemma} = \@hmma;
			$finalschash{$lemma} = 0;
		}

		for ( my $i = 0; $i < $maxlength; $i++ ) {
			my( @crtvec ) = ();

			foreach my $l ( keys( %scorehash ) ) {
				my( @hmma ) = @{ $scorehash{$l} };

				if ( exists( $hmma[$i] ) ) {
					push( @crtvec, [ $l, $hmma[$i] ] );
				}
				else {
					push( @crtvec, [ $l, $hmma[$#hmma] ] );
				}
			}

			my( @scrtvec ) = sort {
				return $b->[1] <=> $a->[1];
			} @crtvec;

			for ( my $j = $#scrtvec; $j >= 0; $j-- ) {
				my( $l, $mms ) = @{ $scrtvec[$j] };

				$finalschash{$l} += ( ( $j + 1 ) / scalar( @scrtvec ) ) * ( $i + 1 );
			}
		}

		foreach my $l ( keys( %finalschash ) ) {
			my( @lchars ) = $this->extractSGMLChars( $l );

			$finalschash{$l} = $finalschash{$l} / scalar( @lchars );
		}

		my( @finallems2 ) = map { [ $_, $finalschash{$_} ] } keys( %finalschash );
		my( @finallems ) = sort {
			$b->[1] <=> $a->[1];
		} @finallems2;

		return ( "HMAXTBLSCORELEMLENL" => $finallems[0]->[0] );
	};

	my( %hlemmas ) = (
#		$heurMAXMMSScore->(),
		$heurMAXMMLScore->(),
		$heurMAXRuleFreq->(),
#		$heurMAXTableScoreS->(),
#		$heurMAXTableScoreLemmaLenS->(),
		$heurMAXTableScoreL->(),
		$heurMAXTableScoreLemmaLenL->()
	);

	return \%hlemmas;
}

sub chooseLemma( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $CONFLEM ) = $this->{"CONFLEM"};
	my( $hlemmas ) = $_[0];
	my( $heurstats ) = $_[1];
	my( $word ) = $_[2];
	my( %lemmas ) = ();

	foreach my $h ( keys( %{ $hlemmas } ) ) {
		$lemmas{$hlemmas->{$h}} = 1 if ( defined( $hlemmas->{$h} ) && $hlemmas->{$h} ne "" );
	}

	foreach my $l ( keys( %lemmas ) ) {
		my( %stocvarhlemmas ) = ();

		foreach my $h ( keys( %{ $hlemmas } ) ) {
			if ( $hlemmas->{$h} eq $l ) {
				$stocvarhlemmas{$h} = 1;
			}
			else {
				$stocvarhlemmas{$h} = 0;
			}
		}

		my( $lprobsum ) = 0;
		my( $M ) = 0;

		foreach my $h ( keys( %{ $heurstats } ) ) {
			next if ( $h !~ /,/ );

			$M++;

			my( $lefth, $righth ) = split( /,/, $h );
			my( $c ) = $heurstats->{$h};
			my( $N ) = $heurstats->{"_NLEM"};
			my( $x ) = $heurstats->{$lefth} - $c;
			my( $y ) = $heurstats->{$righth} - $c;
			my( $stocvarval ) = $stocvarhlemmas{$lefth} . "|" . $stocvarhlemmas{$righth};

			SWVARTYPE: {
				$stocvarval eq "1|1" and do { $lprobsum += $c / ( $c + $y ) if ( ( $c + $y ) > 0 ) };
				$stocvarval eq "1|0" and do { $lprobsum += $x / ( $N - $y - $c ) if ( ( $N - $y - $c ) > 0 ) };
				$stocvarval eq "0|1" and do { $lprobsum += $y / ( $c + $y ) if ( ( $c + $y ) > 0 ) };
				$stocvarval eq "0|0" and do { $lprobsum += ( $N - $x - $y - $c ) / ( $N - $y - $c ) if ( ( $N - $y - $c ) > 0 ) };
			}
		}

		# ver 6.72
		if ( $M == 0 ) {
			$lemmas{$l} = 0;
		}
		else {
			$lemmas{$l} = $lprobsum / $M;
		}
	} #end all lemmas.

	my( @outlemmas ) = sort {
		return $lemmas{$b} <=> $lemmas{$a};
	} keys( %lemmas );

	if ( scalar( @outlemmas ) == 0 ) {
		if ( $CONFLEM->{"OUTPUTPROB"} ) {
			return "(WF)" . $word;
		}
		else {
			return $word;
		}
	}
	else {
		my( $outlem ) = $outlemmas[0];
		my( $outlemprob ) = $lemmas{$outlem};

		#7.41
		if ( $outlemprob > $CONFLEM->{"OUTPUTTHR"} ) {
			return $outlem;
		}
		#4.21
		elsif ( $CONFLEM->{"OUTPUTPROB"} ) {
			return "(" . ( int( $outlemprob * 100 ) / 100 ) . ")" . $outlem;
		}
		else {
			return $outlem;
		}
	}
}

#4.2 revision ...
sub lemmatizer( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $CONFLEM ) = $this->{"CONFLEM"};
	my( @sent ) = @{ $_[0] };
	my( @tags ) = @{ $_[1] };
	#5.7
	my( @ners ) = @{ $_[2] };
	my( @lems ) = ();

	my( $tblwf ) = $CONFLEM->{"TBL"};
	my( $lemmod ) = $CONFLEM->{"LMODEL"};
	#4.2
	my( $recflag ) = $CONFLEM->{"RECOVERED"};
	my( $msdtotagmap ) = $CONFLEM->{"MSDTOTAG"};
	my( $tagtomsdmap ) = $CONFLEM->{"TAGTOMSD"};
	#8.0
	my( $amblemmastbl ) = $CONFLEM->{"AMBTBL"};
	my( %phashrev ) = xces::getpHashRev();

	die( "ttl::lemmatizer : not the same length !\n" ) if ( scalar( @sent ) != scalar( @tags ) );

	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		my( $word, $tag, $nertag ) = ( $sent[$i], $tags[$i], $ners[$i] );
		
		#5.7
		#If we had NER going on, lemma == wordform, no matter the tag !!
		if ( defined( $nertag ) && $nertag ne "" ) {
			push( @lems, $word );
			next;
		}

		#If we have punctuation ...
		if ( exists( $phashrev{$tag} ) ) {
			push( @lems, $word );
			next;
		}

		my( $cpywfflag ) = 0;
		my( $upcaseflag ) = 0;
		my( $ctag, $msd );

		#4.2
		if ( $recflag ) {
			$msd = $tag;
			
			#6.4
			if ( ! exists( $msdtotagmap->{$msd} ) ) {
				warn( "ttl::lemmatizer : \'$word\'/\'$msd\' : msd \'$msd\' is not in mapping !\n" ) if ( $this->{"CONFLEM"}->{"DEBUG"} );
				push( @lems, $word );
				next;
			}

			$ctag = $msdtotagmap->{$msd};
		}
		else {
			$ctag = $tag;

			#6.4
			if ( ! exists( $tagtomsdmap->{$ctag} ) ) {
				warn( "ttl::lemmatizer : \'$word\'/\'$ctag\' : ctag \'$ctag\' is not in mapping !\n" ) if ( $this->{"CONFLEM"}->{"DEBUG"} );
				push( @lems, $word );
				next;
			}
			
			my( @tmpmsds ) = @{ $tagtomsdmap->{$ctag} };
			
			$msd = $tmpmsds[0];
			
			foreach my $m ( @tmpmsds ) {
				if ( exists( $tblwf->{$word}->{$m} ) || exists( $tblwf->{lc( $word )}->{$m} ) ) {
					$msd = $m;
					last;
				}
			}
		}

		foreach my $cpyt ( @{ $CONFLEM->{"COPYWORDFORM"} } ) {
			if ( $cpyt eq $ctag ) {
				$cpywfflag = 1;
				last;
			}
		}

		foreach my $uct ( @{ $CONFLEM->{"UPCASETAGS"} } ) {
			if ( $uct eq $ctag ) {
				$upcaseflag = 1;
				last;
			}
		}

		#ver 6.5 ...
		#ver 7.7 ...
		if ( $cpywfflag ) {
			if ( $upcaseflag ) {
				push( @lems, $word );
			}
			else {
				push( @lems, lc( $word ) );
			}

			next;
		}
		
		#7.8
		my( $scword ) = do {
			my( @scwlet ) = split( //, $word );
			
			
			if ( $scwlet[0] eq "&" ) {
				$scwlet[1] = uc( $scwlet[1] );
			}
			else {
				$scwlet[0] = uc( $scwlet[0] );
			}
			
			join( "", @scwlet );
		};

		my( $sclcword ) = do {
			my( @scwlet ) = split( //, lc( $word ) );
			
			
			if ( $scwlet[0] eq "&" ) {
				$scwlet[1] = uc( $scwlet[1] );
			}
			else {
				$scwlet[0] = uc( $scwlet[0] );
			}
			
			join( "", @scwlet );
		};
		
		#8.0 If there are more than 1 lemma for that word ...
		#Am implementat-o doar pentru RECOVER=1 (lematizare cu MSD-uri)
		if ( $recflag ) {
			my( %choicelemmas ) = ();
			
			if ( exists( $amblemmastbl->{$word} ) && exists( $amblemmastbl->{$word}->{$msd} ) ) {
				%choicelemmas = %{ $amblemmastbl->{$word}->{$msd} };
			}
			elsif ( exists( $amblemmastbl->{$scword} ) && exists( $amblemmastbl->{$scword}->{$msd} ) ) {
				%choicelemmas = %{ $amblemmastbl->{$scword}->{$msd} };
			}
			elsif ( exists( $amblemmastbl->{$sclcword} ) && exists( $amblemmastbl->{$sclcword}->{$msd} ) ) {
				%choicelemmas = %{ $amblemmastbl->{$sclcword}->{$msd} };
			}
			elsif ( exists( $amblemmastbl->{lc( $word )} ) && exists( $amblemmastbl->{lc( $word )}->{$msd} ) ) {
				%choicelemmas = %{ $amblemmastbl->{lc( $word )}->{$msd} };
			}
			
			if ( scalar( keys( %choicelemmas ) ) > 0 ) {
				my( @sproblemmas ) = sort { $choicelemmas{$b} <=> $choicelemmas{$a} } keys( %choicelemmas );
				my( @sellems ) = $sproblemmas[0];
				
				for ( my $k = 1; $k < scalar( @sproblemmas ); $k++ ) {
					if ( $sproblemmas[0] eq $sproblemmas[$k] ) {
						push( @sellems, $sproblemmas[$k] );
					}
					else {
						last;
					}
				}
				
				my( @slengthsellems ) = sort { length( $a ) <=> length( $b ) } @sellems;
				
				push( @lems, $slengthsellems[0] );
				next;
			}
		}
		#End 8.0

		if ( exists( $tblwf->{$word} ) && exists( $tblwf->{$word}->{$msd} ) ) {
			push( @lems, $tblwf->{$word}->{$msd} );
		}
		#7.8
		elsif ( exists( $tblwf->{$scword} ) && exists( $tblwf->{$scword}->{$msd} ) ) {
			push( @lems, $tblwf->{$scword}->{$msd} );
		}
		elsif ( exists( $tblwf->{$sclcword} ) && exists( $tblwf->{$sclcword}->{$msd} ) ) {
			push( @lems, $tblwf->{$sclcword}->{$msd} );
		}
		elsif ( exists( $tblwf->{lc( $word )} ) && exists( $tblwf->{lc( $word )}->{$msd} ) ) {
			push( @lems, $tblwf->{lc( $word )}->{$msd} );
		}
		else {
			if ( ! exists( $lemmod->{$ctag} ) ) {
				if ( $upcaseflag ) {
					push( @lems, $word );
				}
				else {
					push( @lems, lc( $word ) );
				}
			}
			else {
				$word = lc( $word );

				my( @plemmas ) = $this->generateLemmas( $word, $lemmod->{$ctag}->{"RULES"} );

				if ( scalar( @plemmas ) == 0 ) {
					if ( $CONFLEM->{"OUTPUTPROB"} ) {
						push( @lems, "(WF)" . $word );
					}
					else {
						push( @lems, $word );
					}

					next;
				}

				my( $heurlemmas ) = $this->guessLemma( \@plemmas, $lemmod->{$ctag}->{"MMOD"} );

				push( @lems, $this->chooseLemma( $heurlemmas, $lemmod->{$ctag}->{"HEUR"}, $word ) );
			} #if not upcase lemma
		} #if not in tbl.wordform
	} #end sent

	return \@lems;
}

sub confoutputformat( $$ ) {
	my( $this ) = shift( @_ );
	my( %conf ) = %{ $_[0] };

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFOUT{$k} ) ) {
			$CONFOUT{$k} = $conf{$k};
		}
	}

	foreach my $k ( keys( %CONFOUT ) ) {
		if ( ! defined( $CONFOUT{$k} ) ) {
			die( "ttl::confoutputformat : config key $k has no value !\n" );
		}
	}
}

sub outputformat( $$$$$$$$ ) {
	my( $this ) = shift( @_ );
	my( $FHANDLE ) = $_[0];
	my( $toksent, $tagsent, $lemsent ) = ( $_[1], $_[2], $_[3] );

	die( "ttl::outputformat : tok sent : not an array pointer !\n" ) if ( ref( $toksent ) ne "ARRAY" );
	die( "ttl::outputformat : tag sent : not an array pointer !\n" ) if ( ref( $tagsent ) ne "ARRAY" );
	die( "ttl::outputformat : lem sent : not an array pointer !\n" ) if ( ref( $lemsent ) ne "ARRAY" );

	my( $lang, $tuid, $sid ) = ( $_[4], $_[5], $_[6] );
	#Trebuie ca macar una din sent sa nu fie vida. Daca sunt mai multe nevide, trebuie sa aiba aceeasi dimensiune.
	my( %attrtosent ) = ( "wordform" => $toksent, "tag" => $tagsent, "lemma" => $lemsent );
	my( @attrorder ) = @{ $CONFOUT{"ATTRORDER"} };

	#Verificam ca atributele date sunt corecte.
	foreach my $a ( @attrorder ) {
		if ( ! exists( $attrtosent{$a} ) ) {
			die( "ttl::outputformat : attribute \'$a\' is not recognized !\n" );
		}
	}

	#Verificam ca toate propozitiile nonvide au aceeasi lungime.
	for ( my $i = 0; $i < scalar( @attrorder ) - 1; $i++ ) {
		for ( my $j = $i + 1; $j < scalar( @attrorder ); $j++ ) {
			if ( scalar( @{ $attrtosent{$attrorder[$i]} } ) > 0 && scalar( @{ $attrtosent{$attrorder[$j]} } ) > 0 ) {
				if ( scalar( @{ $attrtosent{$attrorder[$i]} } ) != scalar( @{ $attrtosent{$attrorder[$j]} } ) ) {
					die( "ttl::outputformat : \'" . $attrorder[$i] . "\' sent has different length from \'" . $attrorder[$j] . "\' sent.\n" );
				}
			}
		}
	}

	SWOUTMODE: {
		$CONFOUT{"FORMAT"} eq "line" and do {
			my( @out ) = ();
			my( @sents ) = ();
			my( $slen ) = 0;

			foreach my $a ( @attrorder ) {
				push( @sents, $attrtosent{$a} );
				$slen = scalar( @{ $attrtosent{$a} } );
			}

			for ( my $i = 0; $i < $slen; $i++ ) {
				my( @crtstrv ) = ();

				for ( my $j = 0; $j < scalar( @sents ); $j++ ) {
					push( @crtstrv, $sents[$j]->[$i] );
				}

				push( @out, join( "/", @crtstrv ) );
			}

			#6.73
			if ( defined( $sid ) && $sid ne "" ) {
				print( $FHANDLE $sid . "\t" . join( " ", @out ) . "\n" );
			}
			else {
				print( $FHANDLE join( " ", @out ) . "\n" );
			}
			
			last;
		};

		#With this you loose the sentence marking !
		$CONFOUT{"FORMAT"} eq "column" and do {
			my( @sents ) = ();
			my( $slen ) = 0;

			foreach my $a ( @attrorder ) {
				push( @sents, $attrtosent{$a} );
				$slen = scalar( @{ $attrtosent{$a} } );
			}

			for ( my $i = 0; $i < $slen; $i++ ) {
				my( @crtstrv ) = ();

				for ( my $j = 0; $j < scalar( @sents ); $j++ ) {
					push( @crtstrv, $sents[$j]->[$i] );
				}

				print( $FHANDLE join( "\t", @crtstrv ) . "\n" );
			}
			
			last;
		};

		$CONFOUT{"FORMAT"} eq "xces" and do {
			die( "ttl::outputformat : unimplemented mode \'" . $CONFOUT{"FORMAT"} . "\'.\n" );
			last;
		};

		$CONFOUT{"FORMAT"} eq "tbl" and do {
			die( "ttl::outputformat : unimplemented mode \'" . $CONFOUT{"FORMAT"} . "\'.\n" );
			last;
		};

		die( "ttl::outputformat : unkown output mode \'" . $CONFOUT{"FORMAT"} . "\' !\n" );
	}
}

#ver 3.2
sub recAddWordToTbl( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $word, $msd ) = ( $_[0], $_[1], $_[2] );

	if ( ! exists( $dbh->{$word} ) ) {
		$dbh->{$word} = $msd . ":" . 1;
	}
	else {
		my( $values ) = $dbh->{$word};
		my( @pairs ) = split( /,/, $values );
		my( @newpairs ) = ();
		my( $foundtag ) = 0;

		foreach my $p ( @pairs ) {
			my( $m, $f ) = split( /:/, $p );

			if ( $m eq $msd ) {
				$f++;
				$foundtag = 1;
			}

			push( @newpairs, $m . ":" . $f );
		}

		push( @newpairs, $msd . ":" . 1 ) if ( ! $foundtag );

		$dbh->{$word} = join( ",", @newpairs );
	}
}

sub recAddSuffToTree( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $suff, $msd ) = ( $_[0], $_[1], $_[2] );

	if ( ! exists( $dbh->{$suff} ) ) {
		$dbh->{$suff} = $msd . ":" . 1;
	}
	else {
		my( $values ) = $dbh->{$suff};
		my( @pairs ) = split( /,/, $values );
		my( @newpairs ) = ();
		my( $foundtag ) = 0;

		foreach my $p ( @pairs ) {
			my( $m, $f ) = split( /:/, $p );

			if ( $m eq $msd ) {
				$f++;
				$foundtag = 1;
			}

			push( @newpairs, $m . ":" . $f );
		}

		push( @newpairs, $msd . ":" . 1 ) if ( ! $foundtag );

		$dbh->{$suff} = join( ",", @newpairs );
	}
}
#end 3.2

#4.0
sub conftrainrecover( $$ ) {
	my( $this ) = shift( @_ );
	my( %conf ) = %{ $_[0] };

	foreach my $k ( keys( %conf ) ) {
		if ( exists( $CONFTRAINREC{$k} ) ) {
			$CONFTRAINREC{$k} = $conf{$k};
		}
	}

	foreach my $k ( keys( %CONFTRAINREC ) ) {
		if ( ! defined( $CONFTRAINREC{$k} ) ) {
			die( "ttl::conftrainrecover : config key $k has no value !\n" );
		}
	}
}

sub trainrecover( $ ) {
	my( $this ) = shift( @_ );
	#TBLMSDTXTFILE
	my( $asciitblmsdfile ) = $CONFTRAINREC{"TBLMSDTXTFILE"};
	#DBTBLMSD
	my( $tblmsdfile ) = $CONFTRAINREC{"DBTBLMSD"};
	#DBMSDSUFF
	my( $msdsufffile ) = $CONFTRAINREC{"DBMSDSUFF"};
	#DBMSDFREQ
	my( $msdfreqfile ) = $CONFTRAINREC{"DBMSDFREQ"};
	#MSDSFXLEN
	my( $MSDSFXLN ) = $CONFTRAINREC{"MSDSFXLEN"};
	my( $MSDMTCHRX ) = $CONFTRAINREC{"MSDMATCH"};

	my( %TBLTREE ) = ();
	my( %MSDSUFF ) = ();
	my( %MSDFREQ ) = ();

	die( "ttl::trainrecover() : undefined MSDSFXLN !\n" ) if ( ! defined( $MSDSFXLN ) );
	#This MSD reg ex selects from the pool of MSDs those MSDs for which the suffix analysis is done.
	die( "ttl::trainrecover() : undefined MSDMTCHRX !\n" ) if ( ! defined( $MSDMTCHRX ) );

	my( $dbobj ) = undef();

	if ( -f( $tblmsdfile ) ) {
		$dbobj = tie( %TBLTREE, "BerkeleyDB::Hash", "-Filename" => $tblmsdfile, "-Flags" => DB_TRUNCATE, "-Mode" => 0666 );

		if ( ! defined( $dbobj ) ) {
			die( "ttl::trainrecover() : cannot truncate file \'$tblmsdfile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
		}
	}
	else {
		$dbobj = tie( %TBLTREE, "BerkeleyDB::Hash", "-Filename" => $tblmsdfile, "-Flags" => DB_CREATE, "-Mode" => 0666 );

		if ( ! defined( $dbobj ) ) {
			die( "ttl::trainrecover() : cannot create file \'$tblmsdfile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
		}
	}

	$dbobj = undef();

	if ( -f( $msdsufffile ) ) {
		$dbobj = tie( %MSDSUFF, "BerkeleyDB::Hash", "-Filename" => $msdsufffile, "-Flags" => DB_TRUNCATE, "-Mode" => 0666 );

		if ( ! defined( $dbobj ) ) {
			die( "ttl::trainrecover() : cannot truncate file \'$msdsufffile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
		}
	}
	else {
		$dbobj = tie( %MSDSUFF, "BerkeleyDB::Hash", "-Filename" => $msdsufffile, "-Flags" => DB_CREATE, "-Mode" => 0666 );

		if ( ! defined( $dbobj ) ) {
			die( "ttl::trainrecover() : cannot create file \'$msdsufffile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
		}
	}

	$dbobj = undef();

	if ( -f( $msdfreqfile ) ) {
		$dbobj = tie( %MSDFREQ, "BerkeleyDB::Hash", "-Filename" => $msdfreqfile, "-Flags" => DB_TRUNCATE, "-Mode" => 0666 );

		if ( ! defined( $dbobj ) ) {
			die( "ttl::trainrecover() : cannot truncate file \'$msdfreqfile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
		}
	}
	else {
		$dbobj = tie( %MSDFREQ, "BerkeleyDB::Hash", "-Filename" => $msdfreqfile, "-Flags" => DB_CREATE, "-Mode" => 0666 );

		if ( ! defined( $dbobj ) ) {
			die( "ttl::trainrecover() : cannot create file \'$msdfreqfile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
		}
	}

	$MSDFREQ{"<N>"} = 0;

	open( TBL, "< " . $asciitblmsdfile ) or die( "ttl::trainrecover() : could not open file ASCII MSD file ...\n");

	my( $lcnt ) = 0;
	
	while ( my $line = <TBL> ) {
		$lcnt++;

		print( STDERR "ttl::trainrecover() : $lcnt lines read ...\n" ) if ( $lcnt % 1000 == 0 && $CONFTRAINREC{"DEBUG"} );

		$line =~ s/^\s+//;
		$line =~ s/\s+$//;

		next if ( $line =~ /^$/ || $line =~ /^#/ );
		
		my( @toks ) = split( /\s+/, $line );
		
		$toks[1] = $toks[0] if ( $toks[1] eq "=" );

		my( $wordform, $lemma, $msd ) = @toks;

		$this->recAddWordToTbl( \%TBLTREE, $wordform, $msd );

		#ver 6.7
		#ver 6.82
		if ( $msd =~ /$MSDMTCHRX/ && $wordform !~ /_/ && $wordform !~ /-/ ) {
			$MSDFREQ{"<N>"}++;

			if ( ! exists( $MSDFREQ{$msd} ) ) {
				$MSDFREQ{$msd} = 1;
			}
			else {
				$MSDFREQ{$msd}++;
			}

			my( @charswf ) = $this->extractSGMLChars( $wordform );

			for ( my $i = 0; $i < $MSDSFXLN; $i++ ) {
				my( $leftidx ) = $#charswf - $i;
				my( $rightidx ) = $#charswf;

				last if ( $leftidx < 0 );

				my( @crtsuff ) = @charswf[$leftidx .. $rightidx];
				my( $strcrtsuff ) = join( "", @crtsuff );

				$this->recAddSuffToTree( \%MSDSUFF, $strcrtsuff, $msd );
				$this->recAddSuffToTree( \%MSDSUFF, $strcrtsuff, "<FREQ>" );
			}
		}
	}

	close( TBL );

	#Compute RTHETA (TnT, Brants article).
	my( $RTHETA ) = 0;
	my( $PMED ) = 0;
	my( $s ) = scalar( keys( %MSDFREQ ) ) - 1;

	foreach my $msd ( keys( %MSDFREQ ) ) {
		$PMED += $MSDFREQ{$msd} / ( $MSDFREQ{"<N>"} * $s );
	}

	foreach my $msd ( keys( %MSDFREQ ) ) {
		my( $Ptj ) = $MSDFREQ{$msd} / $MSDFREQ{"<N>"};
		my( $squareterm ) = ( $Ptj - $PMED ) * ( $Ptj - $PMED );

		$RTHETA += $squareterm / ( $s - 1 );
	}

	$MSDFREQ{"<RTHETA>"} = $RTHETA;

	#Saving files ...
	$dbobj = undef();
	untie( %TBLTREE );
	untie( %MSDSUFF );
	untie( %MSDFREQ );
}

#Input tbl.wordform with MSDs ...
sub readTblWordformTree( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $CONFTAG ) = $this->{"CONFTAG"};
	my( %TBLTREE ) = ();
	my( %MSDSUFF ) = ();
	my( %MSDFREQ ) = ();
	my( $MSDSFXLN ) = $_[1];

	die( "ttl::readTblWordformTree : undefined MSDSFXLN !\n" ) if ( ! defined( $MSDSFXLN ) );

	#This MSD reg ex selects from the pool of MSDs those MSDs for which the suffix analysis is done.
	my( $MSDMTCHRX ) = $_[2];

	die( "ttl::readTblWordformTree : undefined MSDMTCHRX !\n" ) if ( ! defined( $MSDMTCHRX ) );

	print( STDERR "ttl::readTblWordformTree : reading files ...\n" ) if ( $CONFTAG->{"DEBUG"} );

	my( $msddbFile ) = $CONFTAG->{"TBLMSD"};
	my( $suffdbFile ) = $CONFTAG->{"MSDSUFF"};
	my( $freqdbFile ) = $CONFTAG->{"MSDFREQ"};
	my( $dbobj ) = undef();

	if ( defined( $msddbFile ) && $msddbFile ne "" ) {
		if ( -f( $msddbFile ) ) {
			$dbobj = tie( %TBLTREE, "BerkeleyDB::Hash", "-Filename" => $msddbFile, "-Mode" => 0666 );

			if ( ! defined( $dbobj ) ) {
				die( "ttl::readTblWordformTree() : cannot open file \'$msddbFile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
			}
		}
		else {
			die( "ttl::readTblWordformTree() : not defined file name TBLMSD!\n" );
		}
	}
	else {
		die( "ttl::readTblWordformTree() : not defined file name TBLMSD!\n" );
	}

	$dbobj = undef();

	if ( defined( $suffdbFile ) && $suffdbFile ne "" ) {
		if ( -f( $suffdbFile ) ) {
			$dbobj = tie( %MSDSUFF, "BerkeleyDB::Hash", "-Filename" => $suffdbFile, "-Mode" => 0666 );

			if ( ! defined( $dbobj ) ) {
				die( "ttl::readTblWordformTree() : cannot open file \'$suffdbFile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
			}
		}
		else {
			die( "ttl::readTblWordformTree() : not defined file name MSDSUFF!\n" );		
		}
	}
	else {
		die( "ttl::readTblWordformTree() : not defined file name MSDSUFF!\n" );
	}

	if ( defined( $freqdbFile ) && $freqdbFile ne "" ) {
		if ( -f( $freqdbFile ) ) {
			$dbobj = tie( %MSDFREQ, "BerkeleyDB::Hash", "-Filename" => $freqdbFile, "-Mode" => 0666 );

			if ( ! defined( $dbobj ) ) {
				die( "ttl::readTblWordformTree() : cannot open file \'$freqdbFile\': $!\nBerkeleyDB::Error : $BerkeleyDB::Error\n" );
			}
		}
		else {
			die( "ttl::readTblWordformTree() : not defined file name MSDFREQ!\n" );
		}
	}
	else {
		die( "ttl::readTblWordformTree() : not defined file name MSDFREQ!\n" );
	}

	return ( \%TBLTREE, \%MSDSUFF, \%MSDFREQ, $MSDFREQ{"<RTHETA>"} );
}

sub recGetTreeGoodies( $$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $suff ) = ( $_[0], $_[1] );

	if ( ! exists( $dbh->{$suff} ) ) {
		return {};
	}

	my( $values ) = $dbh->{$suff};
	my( @pairs ) = split( /,/, $values );
	my( %goodies ) = ();

	foreach my $p ( @pairs ) {
		my( $m, $f ) = split( /:/, $p );

		$goodies{$m} = $f;
	}
	
	return \%goodies;
}

#Input: wordform and array of MSDs of THE SAME CATEGORY !!
sub computeMostProbableMSD( $$$$$$$ ) {
	my( $this ) = shift( @_ );
	my( $CONFTAG ) = $this->{"CONFTAG"};
	my( $wordform ) = $_[0];
	my( @MSD ) = @{ $_[1] };
	my( $SFXLN ) = $_[2];
	my( $MSDTREE ) = $_[3];
	my( $MSDFREQ ) = $_[4];
	my( $RTHETA ) = $_[5];
	my( @charswf ) = $this->extractSGMLChars( $wordform );
	my( $bestMSD ) = undef();
	my( $bestP ) = 0;

	foreach my $msd ( @MSD ) {
		my( $P ) = $CONFTAG->{"LOWPROB"};
		
		if ( exists( $MSDFREQ->{$msd} ) ) {
			$P = $MSDFREQ->{$msd} / $MSDFREQ->{"<N>"};
		}
		
		for ( my $i = 0; $i < $SFXLN; $i++ ) {
			my( $leftidx ) = $#charswf - $i;
			my( $rightidx ) = $#charswf;

			last if ( $leftidx < 0 );

			my( @crtsuff ) = @charswf[$leftidx .. $rightidx];
			my( $strcrtsuff ) = join( "", @crtsuff );
			my( $MSDgod ) = $this->recGetTreeGoodies( $MSDTREE, $strcrtsuff );
			my( $estP ) = ( exists( $MSDgod->{$msd} ) ? $MSDgod->{$msd} / $MSDgod->{"<FREQ>"} : 0 );

			$P = ( $estP + $RTHETA * $P ) / ( 1 + $RTHETA );
		}

		if ( $P > $bestP ) {
			$bestP = $P;
			$bestMSD = $msd;
		}
	} #end all msds for this word ...

	#If cannot assign best MSD, choose the most frequent MSD ... :)
	if ( ! defined( $bestMSD ) ) {
		my( $maxFREQ ) = 0;

		foreach my $msd ( @MSD ) {
			if ( exists( $MSDFREQ->{$msd} ) ) {
				if ( $MSDFREQ->{$msd} > $maxFREQ ) {
					$maxFREQ = $MSDFREQ->{$msd};
					$bestMSD = $msd;
				}
			}
		}
	}

	return $bestMSD;
}

#Input: TBLTREE from readTBLTREE and wordform.
sub getMSDFromTBLTree( $$$ ) {
	my( $this ) = shift( @_ );
	my( $dbh, $wordform ) = ( $_[0], $_[1] );

	if ( ! exists( $dbh->{$wordform} ) ) {
		return ();
	}

	my( $values ) = $dbh->{$wordform};
	my( @pairs ) = split( /,/, $values );
	my( @MSD ) = ();

	foreach my $p ( @pairs ) {
		my( $m, $f ) = split( /:/, $p );

		push( @MSD, $m );
	}
	
	return @MSD;
}

#Input CTAG to MSD map table ...
#Ncns	NN  for instance ...
sub readTAGtoMSDMapping( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFTAG ) = $this->{"CONFTAG"};
	my( %TAGMSD ) = ();

	print( STDERR "ttl::readTAGtoMSDMapping : reading file $_[0] ...\n" ) if ( $CONFTAG->{"DEBUG"} );
	open( MAP, "< $_[0]" ) or die( "ttl::readTAGtoMSDMapping : could not open file ...\n" );
	
	while ( my $line = <MAP> ) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;

		next if ( $line =~ /^$/ );
		
		my( @toks ) = split( /\s+/, $line );
		
		if ( ! exists( $TAGMSD{$toks[1]} ) ) {
			$TAGMSD{$toks[1]} = [ $toks[0] ];
		}
		else {
			push( @{ $TAGMSD{$toks[1]} }, $toks[0] );
		}
	}

	close( MAP );

	return \%TAGMSD;
}

#Same file as inpus as to the reverse function ...
#Ncns	NN  for instance ...
sub readMSDtoTAGMapping( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFTAG ) = $this->{"CONFTAG"};
	my( %MSDTAG ) = ();

	print( STDERR "ttl::readMSDtoTAGMapping : reading file $_[0] ...\n" ) if ( $CONFTAG->{"DEBUG"} );
	open( MAP, "< $_[0]" ) or die( "ttl::readMSDtoTAGMapping : could not open file ...\n" );
	
	while ( my $line = <MAP> ) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;

		next if ( $line =~ /^$/ );
		
		my( @toks ) = split( /\s+/, $line );
		
		if ( ! exists( $MSDTAG{$toks[0]} ) ) {
			$MSDTAG{$toks[0]} = $toks[1];
		}
		else {
			warn( "ttl::readMSDtoTAGMapping : duplicate mapping for $toks[0] !\n" );
		}
	}

	close( MAP );

	return \%MSDTAG;
}

#Input: rules file ...
sub readRecoverRules( $$ ) {
	my( $this ) = shift( @_ );
	my( $CONFTAG ) = $this->{"CONFTAG"};
	my( %RRULES ) = ();

	print( STDERR "ttl::readRecoverRules : reading file $_[0] ...\n" )  if ( $CONFTAG->{"DEBUG"} );
	open( RUL, "< $_[0]" ) or die( "ttl::readRecoverRules : could not open file ...\n" );
	
	while ( ! eof( RUL ) ) {
		my( $crtrule ) = "";
		my( $line ) = "";

		while ( $line !~ /\s*end\s*$/ ) {
			#ver 6.71
			last if ( eof( RUL ) );
			
			$line = <RUL>;
			$line =~ s/^\s+//;
			
			while ( $line =~ /^\s*;/ || $line =~ /^$/ ) {
				#ver 6.71
				last if ( eof( RUL ) );
				
				$line = <RUL>;
				$line =~ s/^\s+//;
			}
			
			#ver 6.71
			$crtrule .= $line if ( $line !~ /^\s*;/ );
		}

		$crtrule =~ s/\n/ /g;
		$crtrule =~ s/^\s+//;
		$crtrule =~ s/\s+$//;
		
		#ver 6.71
		last if ( $crtrule eq "" && eof( RUL ) );

		my( $itemrx ) = "(?:(?:not\\s+)?[+-][0-9]+\\s+[^ ]+?)";
		my( $anditemrx ) = "(?:(?:${itemrx}\\s+and\\s+)+${itemrx}|${itemrx})";
		my( $disjrx ) = "(?:(?:${anditemrx}\\s+or\\s+)+${anditemrx}|${anditemrx})";

		if ( $crtrule !~ /^choose\s+.+?\s+if\s+$disjrx\s+end$/ ) {
			die( "ttl::readRecoverRules : rule \'$crtrule\' is not well formed !\n" );
		}

		my( $rulehead ) = ( $crtrule =~ /^choose\s+([^\s]+)\s+if/ );
		my( @rulebody ) = ();

		$crtrule =~ s/^choose\s+[^\s]+\s+if\s+//;
		
		while ( $crtrule =~ /(?:(.+?)\s+or\s+)|(?:(.+?)\s+end$)/g ) {
			push( @rulebody, $1 ) if ( defined( $1 ) );
			push( @rulebody, $2 ) if ( defined( $2 ) );
		}

		if ( ! exists( $RRULES{$rulehead} ) ) {
			my( @oritems ) = ();

			foreach my $rb ( @rulebody ) {
				my( @ands ) = split( /\s+and\s+/, $rb );
				my( %rbody ) = ();

				foreach my $a ( @ands ) {
					my( $not, $pos, $rx ) = ( $a =~ /^(not\s+)?([-+]?[0-9]+\s+)?(.+)$/ );
					
					$not =~ s/\s+$// if ( defined( $not ) );
					
					if ( defined( $pos ) ) {
						$pos =~ s/\s+$//;
					}
					else {
						die( "ttl::readRecoverRules : rule head \'$rulehead\' has no position somewhere in it!\n" );
					}

					if ( defined( $not ) ) {
						$rbody{$pos} = { "<NEG>" => 1, "<RX>" => $rx };
					}
					else {
						$rbody{$pos} = { "<NEG>" => 0, "<RX>" => $rx };
					}
				} #end rule item.

				push( @oritems, \%rbody );
			}

			$RRULES{$rulehead} = \@oritems;
		}
		else {
			die( "ttl::readRecoverRules : rule head \'$rulehead\' is duplicated !\n" );
		}
	} #end of file.

	close( RUL );

	return \%RRULES;
}

sub recoverMSD( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $CONFTAG ) = $this->{"CONFTAG"};
	my( @sent ) = @{ $_[0] };
	my( @ctags ) = @{ $_[1] };
	#5.6
	my( @ners ) = @{ $_[2] };
	my( @msds ) = ();
	my( %phashrev ) = xces::getpHashRev();

	return @msds if ( ! $CONFTAG->{"RECOVER"} );
	
	#5.6
	if ( scalar( @sent ) != scalar( @ctags ) || scalar( @sent ) != scalar( @ners ) ) {
		warn( "ttl::recoverMSD : not equal sentence and ctags arrays or sentence and NERs arrays !\n" );
		return @msds;
	}

	@msds = ( undef() ) x scalar( @sent );

	#Step 1: Map punctuation tags ...
	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		my( $tag ) = $ctags[$i];

		if ( defined( $tag ) && exists( $phashrev{$tag} ) ) {
			$msds[$i] = $tag;
		}
	} #end step 1
	
	#5.6
	#Step 1.1: Map NERs ...
	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		my( $nerval ) = $ners[$i];
		
		if ( defined( $nerval ) && $nerval ne "" ) {
			my( $nermsd, $neremsd ) = split( /,/, $nerval );
			
			if ( $CONFTAG->{"RECOVERNER"} ) {
				$msds[$i] = $neremsd;
			}
			else {
				$msds[$i] = $nermsd;
			}
		}
	} #end step 1.1

	#Step 2: Use the MSD tbl.wordform and the TAG to MSD mapping to recover msds ...
	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		next if ( defined( $msds[$i] ) );

		my( $wordform ) = $sent[$i];
		my( $tag ) = $ctags[$i];
		my( @tagtomsdmap ) = ();
		my( @wordtomsdmap ) = $this->getMSDFromTBLTree( $CONFTAG->{"TBLMSD"}, $wordform );
		my( @wordtomsdmaplc ) = $this->getMSDFromTBLTree( $CONFTAG->{"TBLMSD"}, lc( $wordform ) );

		foreach my $lcm ( @wordtomsdmaplc ) {
			my( $found ) = 0;

			foreach my $scm ( @wordtomsdmap ) {
				if ( $scm eq $lcm ) {
					$found = 1;
					last;
				}
			}

			push( @wordtomsdmap, $lcm ) if ( ! $found );
		}

		if ( exists( $CONFTAG->{"TAGTOMSD"}->{$tag} ) ) {
			@tagtomsdmap = @{ $CONFTAG->{"TAGTOMSD"}->{$tag} };
		}

		if ( scalar( @wordtomsdmap ) == 0 ) {
			@wordtomsdmap = $this->getMSDFromTBLTree( $CONFTAG->{"TBLMSD"}, lc( $wordform ) );
		}


		my( @inters ) = @{ hashset::intersection( \@tagtomsdmap, \@wordtomsdmap ) };

		SWINT: {
			scalar( @inters ) == 0 and do {
				SWVOIDINT: {
					#Unknown word : not in tbl ... OK.
					( scalar( @wordtomsdmap ) == 0 && scalar( @tagtomsdmap ) > 0 ) and do {
						$msds[$i] = \@tagtomsdmap;
						last;
					};

					#Unknown word not in tbl and with a tag that does not exist in mapping ... BAD.
					( scalar( @wordtomsdmap ) == 0 && scalar( @tagtomsdmap ) == 0 ) and do {
						warn( "ttl::recoverMSD (step 2), word not in tbl, tag not in mapping: void intersection for \'$wordform\'/\'$tag\' !!\n" );
						$msds[$i] = $tag; #N-am ce face altceva ... :(
						last;
					};

					#Word in tbl and with a tag that does not exist in mapping ... BAD.
					( scalar( @wordtomsdmap ) > 0 && scalar( @tagtomsdmap ) == 0 ) and do {
						warn( "ttl::recoverMSD (step 2), word in tbl, tag not in mapping: void intersection for \'$wordform\'/\'$tag\' !!\n" );
						$msds[$i] = \@wordtomsdmap;
						last;
					};

					#Word in tbl and with a tag that does exist in mapping ... VERY BAD.
					( scalar( @wordtomsdmap ) > 0 && scalar( @tagtomsdmap ) > 0 ) and do {
						warn( "ttl::recoverMSD (step 2), word in tbl, tag in mapping: void intersection for \'$wordform\'/\'$tag\' !!\n" );
						$msds[$i] = \@tagtomsdmap;
						last;
					};
				}

				last;
			};

			scalar( @inters ) == 1 and do {
				$msds[$i] = $inters[0];
				last;
			};

			scalar( @inters ) > 1 and do {
				$msds[$i] = \@inters;
			};
		}
	} #end step 2

	#Step 3: Markov modelling on ambiguities from the same category ...
	#Skip cases where ambiguity can be resolved by ruler ...
	my( %rules ) = %{ $CONFTAG->{"RRULES"} };
	
	WORD3:
	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		my( $wordform ) = $sent[$i];
		my( $tag ) = $ctags[$i];
		my( $msd ) = $msds[$i];

		#If we have ambiguity ...
		if ( ref( $msd ) ) {
			my( @msdamblist ) = @{ $msd };
			my( $category ) = substr( $msdamblist[0], 0, 1 );
			my( $mmmsdsrx ) = $CONFTAG->{"MSDMATCH"};

			#IF all MSDs are from MSDMATCH ...
			foreach my $m ( @msdamblist ) {
				if ( $m !~ /$mmmsdsrx/ || $category ne substr( $m, 0, 1 ) ) {
					next WORD3;
				}
			}
			
			my( @matchedheads ) = ();
			
			#Check if ruler can resove this ...
			foreach my $m ( @msdamblist ) {
				my( @matchedheads ) = ();

				foreach my $r ( keys( %rules ) ) {
					my( $rheadrx ) = $r;

					$rheadrx =~ s/#/(.)/g;

					if ( $m =~ /$rheadrx/ ) {
						push( @matchedheads, $r );
					}
				}

				if ( scalar( @matchedheads ) > 0 ) {
					#Well, it can ... So skip this one ...
					next WORD3;
				}
			}
			
			#Guess the best msd ...
			my( $bestMSD ) = $this->computeMostProbableMSD( lc( $wordform ), $msd, $CONFTAG->{"MSDSFXLEN"}, $CONFTAG->{"MSDSUFF"}, $CONFTAG->{"MSDFREQ"}, $CONFTAG->{"RTHETA"} );

			if ( ! defined( $bestMSD ) ) {
				$msds[$i] = $tag;
			}
			else {
				$msds[$i] = $bestMSD;
			}
		}
	} #end step 3.

	#Step 4: Recover rules on ambiguities not from the same category ...
	%rules = %{ $CONFTAG->{"RRULES"} };
	
	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		my( $wordform ) = $sent[$i];
		my( $tag ) = $ctags[$i];
		my( $msd ) = $msds[$i];

		#If we have ambiguity ...
		if ( ref( $msd ) ) {
			my( @msdamblist ) = @{ $msd };
			my( @msdpassedlist ) = ();
			my( @msdremaininglist ) = ();

			STEP4AMBMSDS:
			foreach my $m ( @msdamblist ) {
				my( @matchedheads ) = ();

				#Incercam regulile in ordinea descrescatoare a rule headului ...
				foreach my $r ( keys( %rules ) ) {
					my( $rheadrx ) = $r;

					$rheadrx =~ s/#/(.)/g;

					if ( $m =~ /$rheadrx/ ) {
						push( @matchedheads, $r );
					}
				}

				my( @smatchedheads ) = sort {
					return length( $b ) <=> length( $a );
				} @matchedheads;

				if ( scalar( @matchedheads ) == 0 ) {
					push( @msdremaininglist, $m );
					next;
				}
				
				STEP4RULES:
				foreach my $r ( @smatchedheads ) {
					my( $rheadrx ) = $r;
					my( @rbody ) = @{ $rules{$r} };

					$rheadrx =~ s/#/(.)/g;

					my( @boundv ) = ( $m =~ /$rheadrx/ );

					foreach my $rb ( @rbody ) {
						my( %disj ) = %{ $rb };
						my( $match ) = 1;

						DISJ:
						foreach my $idx ( keys( %disj ) ) {
							my( %andbody ) = %{ $disj{$idx} };

							if ( exists( $msds[$i + $idx] ) ) {
								my( $msdi ) = $msds[$i + $idx];
								my( @msdirxor ) = split( /\|/, $andbody{"<RX>"} );
								
								if ( ref( $msdi ) ) {
									$match = 0;
									last; #Next disjunct ...
								}

								my( $randormatch ) = 0;

								RANDOR:
								foreach my $msdirx ( @msdirxor ) {
									my( $unifyno ) = ( $msdirx =~ s/#/(.)/g );
									
									if ( ! $andbody{"<NEG>"} ) {
										if ( $msdi =~ /$msdirx/ ) {
											if ( $unifyno > 0 ) {
												my( @boundv2 ) = ( $msdi =~ /$msdirx/ );

												if ( scalar( @boundv ) != scalar( @boundv2 ) ) {
													next RANDOR;
												}

												for ( my $i = 0; $i < scalar( @boundv ); $i++ ) {
													if ( $boundv[$i] ne $boundv2[$i] && $boundv[$i] ne "-" && $boundv2[$i] ne "-" ) {
														next RANDOR;
													}
												}
											}

											$randormatch = 1;
											last;
										}
									}
									else {
										if ( $msdi =~ /$msdirx/ ) {
											$match = 0;
											next DISJ; #Next disjunct ...
										}
									}
								}

								if ( ! $randormatch ) {
									$match = 0;
									last;
								}
							}
							else {
								$match = 0;
								last; #Next disjunct ...
							}
						} #for all anded idxes ...

						if ( $match ) {
							push( @msdpassedlist, $m );
							next STEP4AMBMSDS;
						}
					} #for disjoint clauses ...
				} #end for all rules
			} #end for all amb msds ...

			if ( scalar( @msdpassedlist ) == 1 ) {
				$msds[$i] =	$msdpassedlist[0];
			}
			elsif ( scalar( @msdremaininglist ) == 1 ) {
				$msds[$i] =	$msdremaininglist[0];
			}
			else {
				#Nothing is changed ...
				$msds[$i] = \@msdamblist;
			}
		} #end if ref $msd
	} #end step 4.

	#Step 41: Markov modelling on ambiguities from the same category if step 4 didn't resolve them ...
		
	WORD41:
	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		my( $wordform ) = $sent[$i];
		my( $tag ) = $ctags[$i];
		my( $msd ) = $msds[$i];

		#If we have ambiguity ...
		if ( ref( $msd ) ) {
			my( @msdamblist ) = @{ $msd };
			my( $category ) = substr( $msdamblist[0], 0, 1 );
			my( $mmmsdsrx ) = $CONFTAG->{"MSDMATCH"};

			#IF all MSDs are from MSDMATCH ...
			foreach my $m ( @msdamblist ) {
				if ( $m !~ /$mmmsdsrx/ || $category ne substr( $m, 0, 1 ) ) {
					next WORD41;
				}
			}
			
			#Guess the best msd ...
			my( $bestMSD ) = $this->computeMostProbableMSD( lc( $wordform ), $msd, $CONFTAG->{"MSDSFXLEN"}, $CONFTAG->{"MSDSUFF"}, $CONFTAG->{"MSDFREQ"}, $CONFTAG->{"RTHETA"} );

			if ( ! defined( $bestMSD ) ) {
				$msds[$i] = $tag;
			}
			else {
				$msds[$i] = $bestMSD;
			}
		}
	} #end step 41.

	#Step 5: Use internal mapping for undef MSDs ...
	for ( my $i = 0; $i < scalar( @sent ); $i++ ) {
		my( $wordform ) = $sent[$i];
		my( $tag ) = $ctags[$i];
		my( $msd ) = $msds[$i];

		if ( ! defined( $msd ) || ref( $msd ) ) {
			if ( exists( $CONFTAG->{"MSDMAP"}->{$tag} ) ) {
				$msds[$i] = $CONFTAG->{"MSDMAP"}->{$tag};
			}
		}
		
		if ( ref( $msds[$i] ) ) {
			$msds[$i] = join( ",", @{ $msds[$i] } );
		}
	} #end step 5

	return @msds;
}

############################################################## End original TTL code ################################################################

############################################################## Web Services code begins here ########################################################
#Internal: get scalars, arrays or hashes ...
#Input: object and 1 or array[1, 2, gogu] or hash{a:1,b:2}
#RESERVED ,{}[]:
sub valueParse( $$ );

#Input: default, Class Name as 'pdk::ttl'; Constructs the object.
sub new( $ );

#Input: reference to the object and config string for %CONFSSPLIT ...
#For instance: EOLSENTBREAK=1; NOSPLIT=1; NERENG=0
sub wsConfSentenceSplitter( $$ );
#Allow modifications: EOLSENTBREAK, NOSPLIT, NERENG
#Input: reference to the object and string to split up in sentences ...
#Output: string
sub wsSentenceSplitter( $$ );

#Input: reference to the object and config string for %CONFTOK ...
#Allow modifications: ENABLENAMEHEUR, NOTOK
sub wsConfTokenizer( $$ );
#Input: reference to the object and a sentence from the result of wsSentenceSplitter()
#Output: string
sub wsTokenizer( $$ );

#Input: reference to the object and config string for %CONFTAG ...
#Allow modifications: RECOVER, RECOVERNER
sub wsConfTagger( $$ );
#Input: reference to the object and the result of wsTokenizer()
#Output: string
sub wsTagger( $$ );

#Input: reference to the object and config string for %CONFLEM ...
#Allow modifications: OUTPUTTHR, OUTPUTPROB
sub wsConfLemmatizer( $$ );
#Input: reference to the object and the result of wsTagger()
sub wsLemmatizer( $$ );

#Input: reference to the object and config string for %CONFCHUNK ...
#Allow modifications: CHUNKS
#For instance CHUNKS=array[Pp, Vp, Ap]
sub wsConfChunker( $$ );
#Input: reference to the object and the result of wsLemmatizer()
sub wsChunker( $$ );

#Input: object, language, a paragraph id prefix and a string to a text fragment
#Output: a list of ICIA XCES 
sub wsXCES( $$$$ );

#Input: object, language, a paragraph id prefix, a string to a text fragment and last OZZ
#Output: a list of ICIA XCES 
sub wsXCESPart( $$$$$ );

#7.62
my( $OBJNO ) = 1;

sub new( $ ) {
	my( $classname ) = $_[0];
	my( $this ) = {};

	my( %CONFSSPLIT ) = (
		"ABBREV" => undef(),
		#Daca asta este 1, considera EOL si ca sfarsit de propozitie.
		"EOLSENTBREAK" => 1,
		#Daca este 1, atunci fiecare linie este o propozitie.
		"NOSPLIT" => 0,
		#0 - off , 1 - on
		"NERENG" => undef(),
		#0 - join words by _, 1 - add <entity .../> information also
		"NERANN" => 1,
		"NERGRMM" => undef(),
		"NERFILT" => undef(),
		#Numerele indica prioritatea in care vor fi incercate.
		"SENTBREAK" => {
			"(?:[\\.\\?!:;])" => 2,
			"(?:[\\?!]\\s*)+" => 1,
			"(?:\\?(?:\\.\\s*)+)" => 1,
			"(?:!(?:\\.\\s*)+)" => 1,
			"(?:\\.\\s*)+" => 1
		},
		"DEBUG" => 0
	);

	#5.0: MUST RECEIVE SENTENCES with NERANNOTATION on !!
	my( %CONFTOK ) = (
		#Daca este 1 atunci spatiul este delimitatorul de cuvinte.
		"NOTOK" => 0,
		#Ordinea in care se vor aplica operatiile de tokenizare.
		"OPORDER" => [ "split", "merge" ],
		"MERGE" => undef(),
		"SPLIT" => undef(),
		#This would be initialized in conftokenizer from the xces::phash.
		"PUNCTSPLIT" => {},
		#Enable name heuristics: if the word is capitalized and it doesn't appear in the lexicon, then tag it as NP
		#This requires configuring the tagger also.
		"ENABLENAMEHEUR" => 1,
		"NAMETAG" => undef(),
		"DEBUG" => 0
	);

	my( %CONFTAG ) = (
		#The lexicon DB, IN
		"LEX" => undef(),
		#The trigrams hash, IN
		"123" => undef(),
		#Suffix tree DB : read from file, IN.
		"AFX" => undef(),
		#Suffix length: integer, IN: MUST BE EQUAL with CONFTTAG SUFFL !
		"SUFFL" => undef(),
		#Below there are the TnT parameters, COMP
		"N" => undef(),
		"THETA" => undef(),
		"LAMBDA1" => undef(),
		"LAMBDA2" => undef(),
		"LAMBDA3" => undef(),
		"LOWPROB" => 0.1e-30,
		#0 or 1: if 1 the CTAG to MSD recovering is done. IN
		"RECOVER" => 0,
		#5.6 version: to enter the NER MSD or the simple MSD ... IN
		"RECOVERNER" => 0,
		#The rules for recovering ... IN
		"RRULES" => undef(),
		#The TBLMSD, MSDSUFF and MSDFREQ are saved in BDB files.
		"TBLMSD" => undef(),
		"MSDSUFF" => undef(),
		"MSDFREQ" => undef(),
		"RTHETA" => undef(),
		#Suffix length for MSD guessing, IN
		"MSDSFXLEN" => undef(),
		#MSD to CTAG mapping, IN
		"TAGTOMSD" => undef(),
		#For which MSDs to build suff tree, IN.
		#"^Nc|^Vm|^A"
		"MSDMATCH" => undef(),
		#What CTAGS receive direct mappings, IN.
		#{ "R" => "Rgp", "Y" => "Yn", "NP" => "Np" }
		"MSDMAP" => undef(),
		"DEBUG" => 0
	);
	
	#ver 7.0
	my( %CONFCHUNK ) = (
		#what chunks to output
		#these must be start symbols in the GRAMFILE ...
		"CHUNKS" => [ "Pp", "Np", "Vp", "Ap" ],
		#in file of the grammar for chunks
		"GRAMFILE" => undef(),
		#produced by reading file at GRAMFILE
		"GRAMMAR" => undef(),
		#produced by reading file at GRAMFILE
		"NONTERM" => undef(),
		#8.5
		#This line length is meant to protect a huge regex max against a big line.
		#We obtain 'Out of memory' errors.
		#In tokens.
		"MAXLINELEN" => 50,
		"DEBUG" => 1
	);

	my( %CONFLEM ) = (
		#Lemele de aici le las asa cum apar in text.
		"UPCASETAGS" => undef(),
		#Lemele de aici le copiem pur si simplu fara a le mai trece prin tbl.wordform
		"COPYWORDFORM" => undef(),
		#4.2
		#This is the MSD tbl.wordform ...
		"TBL" => undef(),
		#4.2
		#MSD to CTAG mapping, IN
		"MSDTOTAG" => undef(),
		"TAGTOMSD" => undef(),
		#4.2
		#If we have CTAGs (0) or MSDs (1) ...
		"RECOVERED" => undef(),
		"LMODEL" => undef(),
		"LOWPROB" => 0.1e-30,
		#If the lemma has the output prob. lower than or equal than this, it will be output.
		"OUTPUTTHR" => 0.8,
		#This may be 0 or 1: if 1, the prob below OUTPUTTHR is returned with the lemma.
		"OUTPUTPROB" => 1,
		#8.0 MSD tbl.wordform with lemma probabilities ...
		"AMBTBL" => undef(),
		"DEBUG" => 0
	);

	$this->{"CONFSSPLIT"} = \%CONFSSPLIT;
	$this->{"CONFTOK"} = \%CONFTOK;
	$this->{"CONFTAG"} = \%CONFTAG;
	#ver 7.0
	$this->{"CONFCHUNK"} = \%CONFCHUNK;
	$this->{"CONFLEM"} = \%CONFLEM;
	#7.62
	$this->{"OBJNO"} = $OBJNO;
	
	$OBJNO++;
	
	bless( $this, $classname );
	return $this;
}

sub valueParse( $$ ) {
	my( $this ) = shift( @_ );
	my( $val ) = $_[0];
	
	SWVAL: {
		$val =~ /^array\[(.+)\]$/ and do {
			my( $content ) = $1;
			my( @arrvals ) = split( /,\s*/, $content );
			my( @retvals ) = ();
			
			foreach my $v ( @arrvals ) {
				if ( defined( $v ) && $v ne "" ) {
					push( @retvals, $v );
				}
			}
			
			return \@retvals;
		};

		$val =~ /^hash\{(.+)\}$/ and do {
			my( $content ) = $1;
			my( @arrvals ) = split( /,\s*/, $content );
			my( %retvals ) = ();

			foreach my $v ( @arrvals ) {
				my( $key, $value ) = split( /\s*=>\s*/, $v );
				
				if ( defined( $key ) && $key ne "" && defined( $value ) && $value ne "" ) {
					$retvals{$key} = $value;
				}
			}
			
			return \%retvals;
		};
	}
	
	return \$val;
}


#Allowed: EOLSENTBREAK NOSPLIT NERENG
sub wsConfSentenceSplitter( $$ ) {
	my( $this ) = shift( @_ );
	my( $CNFSTR ) = $_[0];
	my( %conf ) = ();
	my( @KV ) = split( /;\s*/, $CNFSTR );
	
	foreach my $p ( @KV ) {
		my( $ckey, $cvalue ) = ( $p =~ /^([A-Z]+)\s*=\s*(.+)$/ );
				
		if ( defined( $ckey ) && defined( $cvalue ) && $ckey ne "" && $cvalue ne "" ) {
			my( $pvalue ) = $this->valueParse( $cvalue );
			
			SWCKEY1: {
				$ckey eq "EOLSENTBREAK" and do {
					$this->{"CONFSSPLIT"}->{"EOLSENTBREAK"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};

				$ckey eq "NOSPLIT" and do {
					$this->{"CONFSSPLIT"}->{"NOSPLIT"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};

				$ckey eq "NERENG" and do {
					$this->{"CONFSSPLIT"}->{"NERENG"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};
			}
		}
	}
}

sub wsSentenceSplitter( $$ ) {
	my( $this ) = shift( @_ );
	my( $instring ) = $_[0];
	#TnT format with a \n after each sentence ...
	my( $outstring ) = "";
	#8.7
	my( $tempfile ) = "tmp-" . int( rand( 10 ) ) . int( rand( 10 ) ) . int( rand( 10 ) ) . ".txt";

	#8.7
	open( TMP, ">", $tempfile ) or return "error (ttl::wsSentenceSplitter) : cannot open temporary file '$tempfile' ...\n";
	binmode( TMP, ":utf8" );
	
	#Normalize EOL convention to UNIX
	$instring =~ s/\r\n/\n/gs;
	$instring =~ s/\r/\n/gs;
	
	print( TMP $instring ) if ( $instring =~ /\n$/s );
	print( TMP $instring . "\n" ) if ( $instring !~ /\n$/s );
	
	close( TMP );

	#Call sentsplitter on temp file ...
	#8.7
	my( %sent ) = %{ $this->sentsplitter( $tempfile ) };

	#Calling the tokenizer now on the sentences ...
	foreach my $p ( sort { $a <=> $b } keys( %sent ) ) {
		foreach my $s ( sort { $a <=> $b } keys( %{ $sent{$p} } ) ) {
			#Windows conventions for EOL.
			$outstring .= $sent{$p}->{$s} . "\r\n";
		}
	}

	#Return the sentece split input string ...
	#8.7
	unlink( $tempfile );
	return $outstring;
}

#Allowed: ENABLENAMEHEUR, NOTOK
sub wsConfTokenizer( $$ ) {
	my( $this ) = shift( @_ );
	my( $CNFSTR ) = $_[0];
	my( @KV ) = split( /;\s*/, $CNFSTR );
	
	foreach my $p ( @KV ) {
		my( $ckey, $cvalue ) = ( $p =~ /^([A-Z]+)\s*=\s*(.+)$/ );
				
		if ( defined( $ckey ) && defined( $cvalue ) && $ckey ne "" && $cvalue ne "" ) {
			my( $pvalue ) = $this->valueParse( $cvalue );
			
			SWCKEY1: {
				$ckey eq "ENABLENAMEHEUR" and do {
					$this->{"CONFTOK"}->{"ENABLENAMEHEUR"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};

				$ckey eq "NOTOK" and do {
					$this->{"CONFTOK"}->{"NOTOK"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};
			}
		}
	}
}

sub wsTokenizer( $$ ) {
	my( $this ) = shift( @_ );
	my( $instring ) = $_[0];
	#TnT format with a \n after each sentence ...
	my( $outstring ) = "";

	#Using UNIX conventions for the EOL.
	$instring =~ s/\r?\n$//;

	my( $sentence, $toktags, $nertags ) = $this->tokenizer( $instring );

	for ( my $i = 0; $i < scalar( @{ $sentence } ); $i++ ) {
		$outstring .= $sentence->[$i];

		if ( defined( $toktags->[$i] ) && defined( $nertags->[$i] ) ) {
			$outstring .= "\t" . $toktags->[$i] . "\t" . $nertags->[$i] . "\r\n";
		}
		elsif ( defined( $toktags->[$i] ) ) {
			$outstring .= "\t" . $toktags->[$i] . "\r\n";
		}
		else {
			$outstring .= "\r\n";
		}
	}

	#Return the sentece tokenized input string ...
	return $outstring;
}
#Allow modifications: RECOVER, RECOVERNER
sub wsConfTagger( $$ ) {
	my( $this ) = shift( @_ );
	my( $CNFSTR ) = $_[0];
	my( @KV ) = split( /;\s*/, $CNFSTR );
	
	foreach my $p ( @KV ) {
		my( $ckey, $cvalue ) = ( $p =~ /^([A-Z]+)\s*=\s*(.+)$/ );
				
		if ( defined( $ckey ) && defined( $cvalue ) && $ckey ne "" && $cvalue ne "" ) {
			my( $pvalue ) = $this->valueParse( $cvalue );
			
			SWCKEY1: {
				$ckey eq "RECOVER" and do {
					$this->{"CONFTAG"}->{"RECOVER"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};

				$ckey eq "RECOVERNER" and do {
					$this->{"CONFTAG"}->{"RECOVERNER"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};
			}
		}
	}
}

sub wsTagger( $$ ) {
	my( $this ) = shift( @_ );
	my( $instring ) = $_[0];
	#TnT format with a \n after each sentence ...
	my( $outstring ) = "";

	my( @pairs ) = split( /\r?\n/, $instring );
	my( @toksent ) = ();
	my( @recsent ) = ();
	my( @nersent ) = ();

	foreach my $p ( @pairs ) {
		my( $wordform, $tag, $ner ) = split( /\s+/, $p );

		push( @toksent, $wordform );
		push( @recsent, $tag );
		push( @nersent, $ner );
	}

	my( $ctagsent, $msdsent ) = $this->tagger( \@toksent, \@recsent, \@nersent );
	my( @tagsent ) = ();

	if ( scalar( @{ $msdsent } ) > 0 ) {
		@tagsent = @{ $msdsent };
	}
	else {
		@tagsent = @{ $ctagsent };
	}

	my( @taggedsentence ) = ();

	for ( my $i = 0; $i < scalar( @toksent ); $i++ ) {
		if ( defined( $nersent[$i] ) ) {
			push( @taggedsentence, $toksent[$i] . "\t" . $tagsent[$i] . "\t" . $nersent[$i] );
		}
		else {
			push( @taggedsentence, $toksent[$i] . "\t" . $tagsent[$i] );
		}
	}

	$outstring = join( "\r\n", @taggedsentence );

	return $outstring;
}

#Allow modifications: OUTPUTTHR, OUTPUTPROB, RECOVERED
sub wsConfLemmatizer( $$ ) {
	my( $this ) = shift( @_ );
	my( $CNFSTR ) = $_[0];
	my( @KV ) = split( /;\s*/, $CNFSTR );
	
	foreach my $p ( @KV ) {
		my( $ckey, $cvalue ) = ( $p =~ /^([A-Z]+)\s*=\s*(.+)$/ );
				
		if ( defined( $ckey ) && defined( $cvalue ) && $ckey ne "" && $cvalue ne "" ) {
			my( $pvalue ) = $this->valueParse( $cvalue );
			
			SWCKEY1: {
				$ckey eq "OUTPUTTHR" and do {
					$this->{"CONFLEM"}->{"OUTPUTTHR"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^(?:0\.[0-9]+|1)$/ );
					last;
				};

				$ckey eq "OUTPUTPROB" and do {
					$this->{"CONFLEM"}->{"OUTPUTPROB"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};

				$ckey eq "RECOVERED" and do {
					$this->{"CONFLEM"}->{"RECOVERED"} = $$pvalue if ( ref( $pvalue ) eq "SCALAR" and $$pvalue =~ /^[01]$/ );
					last;
				};
			}
		}
	}
}

sub wsLemmatizer( $$ ) {
	my( $this ) = shift( @_ );
	my( $instring ) = $_[0];
	#TnT format with a \n after each sentence ...
	my( $outstring ) = "";
	
	#If the user recovered the MSD with wsTagger and set RECOVERED to 0, we must set RECOVERED to 1
	if ( $this->{"CONFTAG"}->{"RECOVER"} == 1 ) {
		$this->{"CONFLEM"}->{"RECOVERED"} = 1;
	}
	else {
		$this->{"CONFLEM"}->{"RECOVERED"} = 0;
	}

	my( @pairs ) = split( /\r?\n/, $instring );
	my( @toksent ) = ();
	my( @tagsent ) = ();
	my( @nersent ) = ();

	foreach my $p ( @pairs ) {
		my( $wordform, $tag, $ner ) = split( /\s+/, $p );

		push( @toksent, $wordform );
		push( @tagsent, $tag );
		push( @nersent, $ner );
	}

	my( $lsent ) = $this->lemmatizer( \@toksent, \@tagsent, \@nersent );
	my( @lemsent ) = @{ $lsent };

	my( @lemmatizedsentence ) = ();

	for ( my $i = 0; $i < scalar( @toksent ); $i++ ) {
		push( @lemmatizedsentence, $toksent[$i] . "\t" . $tagsent[$i] . "\t" . $lemsent[$i] );
	}

	$outstring = join( "\r\n", @lemmatizedsentence );

	return $outstring;
}

#Allow modifications: CHUNKS
sub wsConfChunker( $$ ) {
	my( $this ) = shift( @_ );
	my( $CNFSTR ) = $_[0];
	my( @KV ) = split( /;\s*/, $CNFSTR );
	
	foreach my $p ( @KV ) {
		my( $ckey, $cvalue ) = ( $p =~ /^([A-Z]+)\s*=\s*(.+)$/ );
				
		if ( defined( $ckey ) && defined( $cvalue ) && $ckey ne "" && $cvalue ne "" ) {
			my( $pvalue ) = $this->valueParse( $cvalue );
			
			SWCKEY1: {
				$ckey eq "CHUNKS" and do {
					$this->{"CONFCHUNK"}->{"CHUNKS"} = $pvalue if ( ref( $pvalue ) eq "ARRAY" );
					last;
				};
			}
		}
	}
}

#For this to work, we need to configure the lemmatizer. It is configured in a web service environment.
sub wsChunker( $$ ) {
	my( $this ) = shift( @_ );
	my( $instring ) = $_[0];
	#TnT format with a \n after each sentence ...
	my( $outstring ) = "";
	my( $recflag ) = $this->{"CONFLEM"}->{"RECOVERED"};
	my( $msdtotagmap ) = $this->{"CONFLEM"}->{"MSDTOTAG"};

	my( @pairs ) = split( /\r?\n/, $instring );
	my( @toksent ) = ();
	my( @msdsent ) = ();
	my( @tagsent ) = ();
	my( @lemsent ) = ();

	foreach my $p ( @pairs ) {
		my( $wordform, $tag, $lem ) = split( /\s+/, $p );

		push( @toksent, $wordform );
		
		#If we had RECOVER, we need to come back to CTAGS
		if ( $recflag ) {
			if ( exists( $msdtotagmap->{$tag} ) ) {
				push( @tagsent, $msdtotagmap->{$tag} );
			}
			else {
				push( @tagsent, $tag );
			}
		}
		else {
			push( @tagsent, $tag );
		}
		
		push( @msdsent, $tag );
		push( @lemsent, $lem );
	}
	
	my( $chunks ) = $this->chunker( \@tagsent );
	
	for ( my $i = 0; $i < scalar( @toksent ); $i++ ) {
		if ( defined( $chunks->[$i] ) ) {
			$outstring .= $toksent[$i] . "\t" . $msdsent[$i] . "\t" . $lemsent[$i] . "\t" . $chunks->[$i] . "\r\n";
		}
		else {
			$outstring .= $toksent[$i] . "\t" . $msdsent[$i] . "\t" . $lemsent[$i] . "\r\n";
		}
	}
	
	return $outstring;
}

sub wsXCES( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $lang, $parprfxid, $instring ) = @_;
	
	if ( ! defined( $lang ) ) {
		return "error (ttl::wsXCES) : no input language supplied ...\n";
	}
	
	if ( ! defined( $instring ) ) {
		return "error (ttl::wsXCES) : I have nothing to process ...\n";
	}
	
	my( $outstring ) = "";
	my( %phash ) = xces::getpHash();
	my( %attrorder ) = xces::getAttrOrder();
	
	#TTL on in input string ...
	my( $ssplit ) = $this->wsSentenceSplitter( $instring );
	my( @sentences ) = split( /\r?\n/, $ssplit );
	
	for ( my $i = 0; $i < scalar( @sentences ); $i++ ) {
		my( $s ) = $sentences[$i];
		my( $schunked ) = $this->wsChunker( $this->wsLemmatizer( $this->wsTagger( $this->wsTokenizer( $s ) ) ) );
		my( @pairs ) = split( /\r?\n/, $schunked );
		
		#XCES the result ...
		if ( $parprfxid ne "" ) {
			#8.1
			my( $xmlparprfxid ) = $parprfxid;

			$xmlparprfxid =~ s/</&lt;/g;
			$xmlparprfxid =~ s/>/&gt;/g;
			$xmlparprfxid =~ s/\"/&quot;/g;
						
			$outstring .= "<seg lang=\"$lang\"><s id=\"${xmlparprfxid}." . ( $i + 1 ) . "\">";
		}
		else {
			$outstring .= "<seg lang=\"$lang\"><s id=\"" . ( $i + 1 ) . "\">";
		}
		
		foreach my $p ( @pairs ) {
			my( $wf, $msd, $lem, $chk ) = split( /\s+/, $p );

			#8.2 bug with <w lemma="&quot;" ana="DBLQ">&quot;</w>
			if ( exists( $phash{$wf} ) ) {
				$wf =~ s/</&lt;/g;
				$wf =~ s/>/&gt;/g;
				$wf = "&amp;" if ( $wf eq "&" );
				
				$outstring .= "<c>" . $wf . "</c>";
				next;
			}
			
			#7.9 Need to escape the XML elements ...
			$wf =~ s/</&lt;/g;
			$wf =~ s/>/&gt;/g;

			$lem =~ s/</&lt;/g;
			$lem =~ s/>/&gt;/g;
			#8.1
			$lem =~ s/\"/&quot;/g;
			
			my( %attribs ) = ( "ana" => $msd, "lemma" => $lem, "chunk" => $chk );
			my( @atvalues ) = ();

			foreach my $at ( sort { $attrorder{$a} <=> $attrorder{$b} } keys( %attribs ) ) {
				if ( defined( $attribs{$at} ) ) {
					push( @atvalues, $at . "=" . "\"" . $attribs{$at} . "\"" );
				}
			}

			$outstring .= "<w " . join( " ", @atvalues ) . ">" . $wf . "</w>";
		} #end all sentence
		
		$outstring .= "</s></seg>\r\n";
	}

	return $outstring;
}

sub wsXCESPart( $$$$$ ) {
	my( $this ) = shift( @_ );
	my( $lang, $parprfxid, $instring, $ozz ) = @_;
	
	if ( ! defined( $lang ) ) {
		return "error (ttl::wsXCESPart) : no input language supplied ...\n";
	}
	
	if ( ! defined( $instring ) ) {
		return "error (ttl::wsXCESPart) : I have nothing to process ...\n";
	}
	
	my( $outstring ) = "";
	my( %phash ) = xces::getpHash();
	my( %attrorder ) = xces::getAttrOrder();
	
	#TTL on in input string ...
	my( $ssplit ) = $this->wsSentenceSplitter( $instring );
	my( @sentences ) = split( /\r?\n/, $ssplit );
	
	for ( my $i = 0; $i < scalar( @sentences ); $i++ ) {
		my( $s ) = $sentences[$i];
		my( $schunked ) = $this->wsChunker( $this->wsLemmatizer( $this->wsTagger( $this->wsTokenizer( $s ) ) ) );
		my( @pairs ) = split( /\r?\n/, $schunked );
		my( $outstring2 ) = "<tu id=\"" . $$ozz . "\">\r\n";
		
		#XCES the result ...
		if ( $parprfxid ne "" ) {
			#8.1
			my( $xmlparprfxid ) = $parprfxid;

			$xmlparprfxid =~ s/</&lt;/g;
			$xmlparprfxid =~ s/>/&gt;/g;
			$xmlparprfxid =~ s/\"/&quot;/g;
						
			$outstring2 .= "<seg lang=\"$lang\"><s id=\"${xmlparprfxid}." . ( $i + 1 ) . "\">";
		}
		else {
			$outstring2 .= "<seg lang=\"$lang\"><s id=\"" . ( $i + 1 ) . "\">";
		}
		
		foreach my $p ( @pairs ) {
			my( $wf, $msd, $lem, $chk ) = split( /\s+/, $p );

			#8.2 bug with <w lemma="&quot;" ana="DBLQ">&quot;</w>
			if ( exists( $phash{$wf} ) ) {
				$wf =~ s/</&lt;/g;
				$wf =~ s/>/&gt;/g;
				$wf = "&amp;" if ( $wf eq "&" );
				
				$outstring2 .= "<c>" . $wf . "</c>";
				next;
			}
			
			#7.9 Need to escape the XML elements ...
			$wf =~ s/</&lt;/g;
			$wf =~ s/>/&gt;/g;

			$lem =~ s/</&lt;/g;
			$lem =~ s/>/&gt;/g;
			#8.1
			$lem =~ s/\"/&quot;/g;
			
			my( %attribs ) = ( "ana" => $msd, "lemma" => $lem, "chunk" => $chk );
			my( @atvalues ) = ();

			foreach my $at ( sort { $attrorder{$a} <=> $attrorder{$b} } keys( %attribs ) ) {
				if ( defined( $attribs{$at} ) ) {
					push( @atvalues, $at . "=" . "\"" . $attribs{$at} . "\"" );
				}
			}

			$outstring2 .= "<w " . join( " ", @atvalues ) . ">" . $wf . "</w>";
		} #end all sentence
		
		$outstring2 .= "</s></seg>\r\n</tu>\r\n\r\n";
		$outstring .= $outstring2;
		$$ozz++;
	}

	return $outstring;
}

sub DESTROY {
	my( $this ) = shift( @_ );
	
	print( STDERR "pdk::ttl : the object " . $this->{"OBJNO"} . " is going out of scope ... cleaning up.\n" );
	$this->endProcessing();
}

############################################################## WebServices code ends here ################################################################

1;
