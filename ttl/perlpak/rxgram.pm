# TTL and all included Perl modules is (C) Radu Ion (radu@racai.ro) and ICIA 2005-2018.
# Permission is granted for research and personal use ONLY.
# 
# Reads in the regular expression grammar specifications from the files.
# Constructs the translator to PERL reg exes.
# 
# ver 0.1 : created Radu ION.
# ver 0.2, 19-Apr-06, Radu ION, fixed a bug in replace values with not defined left hand side nonterminals ...
# ver 0.3, 21-Apr-06, Radu ION, fixed a bug in replace ...

package rxgram;

use strict;
use warnings;

sub setFlags( $ );
sub parseGrammar( $ );
sub errorsPrint( $$ );
sub errorCodes();
sub expandTerm( $$ );

#A left hand side nonterminal and again the same nonterminal
sub checkRecursion( $ );
sub checkProductivity( $ );
#Face match pe orice pereche de tag-uri ...
sub checkPar( $$$$ );
sub validateGrammar();

sub replaceRules();

my( %nonterm ) = ();
my( %grammar ) = ();
#Check recursivity and productivity
my( %flags ) = ( "GRMVALREC" => 1, "GRMVALPROD" => 1, "GRMVALDEBUG" => 0 );

#Flags
my( $nontermsec ) = 0;
my( $rulesec ) = 0;
my( $nostartsym ) = 1;

my( $sec ) = "";

sub setFlags( $ ) {
	my( %setflags ) = %{ $_[0] };

	foreach my $k ( keys( %setflags ) ) {
		if ( exists( $flags{$k} ) ) {
			$flags{$k} = $setflags{$k} if ( defined( $setflags{$k} ) && ( $setflags{$k} == 0 || $setflags{$k} == 1 ) );
		}
	}
}

sub parseGrammar( $ ) {
	%nonterm = ();
	%grammar = ();

	my( $lcnt ) = 0;
	open( GRM, "< $_[0]" ) or die( "rxgram::parseGrammar() : No such file $_[0]\n" );
	
	print( STDERR "rxgram::parseGrammar() : parsing file \'$_[0]\' ...\n" ) if ( $flags{"GRMVALDEBUG"} == 1 );
	LINE:
	while ( my $line = <GRM> ) {
		$lcnt++;
		next if ( $line =~ /^$/ || $line =~ /^#/ );

		$line =~ s/\r?\n$//;

		if ( $line eq "NONTERM:" ) {
			$nontermsec = 1;
			$sec = "NONTERM";
			next;
		}

		if ( $line eq "RULES:" ) {
			$rulesec = 1;
			$sec = "RULES";
			next;
		}

		SWP: {
			$sec eq "" and next LINE;

			$sec eq "NONTERM" and do {
				if ( $line =~ /^STARTSYM:(.+)$/ ) {
					my( $tline ) = $1;
					
					$tline =~ s/^\s+//;
					$tline =~ s/\s+$//;

					my( @startnt ) = split( /\s+/, $tline );

					foreach my $snt ( @startnt ) {
						#Start symbol: value 1.
						$nonterm{$snt} = 1;
					}

					$nostartsym = 0;
					next LINE;
				}

				if ( $line =~ /^META:(.+)$/ ) {
					my( $tline ) = $1;
					
					$tline =~ s/^\s+//;
					$tline =~ s/\s+$//;

					my( @startnt ) = split( /\s+/, $tline );

					foreach my $snt ( @startnt ) {
						#Metalanguage symbol: value 2.
						$nonterm{$snt} = 2;
					}

					$nostartsym = 0;
					next LINE;
				}

				if ( $line =~ /^PAIR:(.+)$/ ) {
					my( $tline ) = $1;

					$tline =~ s/^\s+//;
					$tline =~ s/\s+$//;

					my( @pairnt ) = split( /\s+/, $tline );
					my( $opentag, $closetag ) = ( "", "" );
					my( $opencnt, $closecnt ) = ( 0, 0 );

					foreach my $snt ( @pairnt ) {
						do { $opentag = $1; $opencnt++; } if ( $snt =~ /^OPEN:(.+)$/ );
						do { $closetag = $1; $closecnt++; } if ( $snt =~ /^CLOSE:(.+)$/ );
					}

					if ( $opencnt == 1 && $closecnt == 1  ) {
						if ( ! exists( $nonterm{"__PAIR"} ) ) {
							my( @pairs ) = ();

							push( @pairs, [ $opentag, $closetag ] );
							$nonterm{"__PAIR"} = \@pairs;
						}
						else {
							push( @{ $nonterm{"__PAIR"} }, [ $opentag, $closetag ] );
						}
					}
					else {
						errorsPrint( "PAIR_SYNFAIL", { "__line__" => $line } );
					}

					next LINE;
				}
				
				#Simple nonterminal.
				$nonterm{$line} = 0;
				
				last;
			};

			$sec eq "RULES" and do {
				my( $lhs, $rhs ) = split( /->/, $line );

				if ( ! defined( $lhs ) || ! defined( $rhs ) ) {
					errorsPrint( "NO_RULE_SEP", { "__line__" => $lcnt } );
				}
				
				$lhs =~ s/\s+//g;

				#0.2
				if ( ! exists( $nonterm{$lhs} ) ) {
					errorsPrint( "NONTERM_NOTDEF", { "__term__" => $lhs } );
				}

				$rhs =~ s/^\s+//;
				$rhs =~ s/\s+$//;

				my( @rhside ) = split( /\s+/, $rhs );
				my( @ruleitems ) = ();

				foreach my $rhse ( @rhside ) {
					#rhse is a terminal string
					if ( $rhse =~ /^\'.+?\'$/ ) {
						push( @ruleitems, $rhse );
						next;
					}
					
					if ( ! exists( $nonterm{$rhse} ) ) {
						my( @terms ) = expandTerm( $rhse, $line );

						push( @ruleitems, @terms );
					}
					else {
						push( @ruleitems, $rhse );
					}
				}

				if ( scalar( @ruleitems ) == 0 ) {
					errorsPrint( "EMPTY_RULE", { "__line__" => $lcnt } );
				}
				else {
					if ( ! exists( $grammar{$lhs} ) ) {
						my( @rules ) = ();

						push( @rules, \@ruleitems );
						$grammar{$lhs} = \@rules;
					}
					else {
						push( @{ $grammar{$lhs} }, \@ruleitems );
					}
				}
			};
		}
	}

	errorsPrint( "NO_NONTERM_SEC", { "__file__" => $_[0] } ) if ( ! $nontermsec );
	errorsPrint( "NO_RULES_SEC", { "__file__" => $_[0] } ) if ( ! $rulesec );
	errorsPrint( "NO_STARTSYM", {} ) if ( $nostartsym );

	close( GRM );

	print( STDERR "rxgram::parseGrammar() : validating grammar in \'$_[0]\' ...\n" ) if ( $flags{"GRMVALDEBUG"} == 1 );
	validateGrammar();
	#Aici gramatica poate fi folosita intr-un parser ...
	#Numai daca au fost verificate recursivitatea si productia, generam toate sirurile ...
	if ( $flags{"GRMVALREC"} == 1 && $flags{"GRMVALPROD"} == 1 ) {
		print( STDERR "rxgram::parseGrammar() : expanding rules from \'$_[0]\' ...\n" ) if ( $flags{"GRMVALDEBUG"} == 1 );
		replaceRules();
	}

	print( STDERR "rxgram::parseGrammar() : done with file \'$_[0]\'.\n" ) if ( $flags{"GRMVALDEBUG"} == 1 );
	
	my( %tempnonterm ) = %nonterm;
	my( %tempgrammar ) = %grammar;

	return( \%tempnonterm, \%tempgrammar );
}

sub errorsPrint( $$ ) {
	my( $errcode ) = $_[0];
	my( $templates ) = $_[1];
	my( $errhash ) = errorCodes();

	if ( exists( $errhash->{$errcode} ) ) {
		my( $errdesc ) = $errhash->{$errcode};
		my( $errorstring ) = $errdesc->{"string"};

		foreach my $t ( keys( %{ $templates } ) ) {
			$errorstring =~ s/$t/$templates->{$t}/eg;
		}

		if ( $errdesc->{"type"} eq "error" ) {
			die( "rxgram::errorsPrint() [error]: " . $errorstring );
		}
		else {
			warn( "rxgram::errorsPrint() [warning]: " . $errorstring );
		}
	}
	else {
		warn( "rxgram::errorsPrint() [warning]: Unknown error code.\n" );
	}
}

sub errorCodes() {
	my( %errhash ) = ();

	$errhash{"NO_RULE_SEP"} = { "type" => "error", "string" => "No \'->\' found at line __line__ !\n" };
	$errhash{"NO_NONTERM_SEC"} = { "type" => "error", "string" => "No NONTERM section found in __file__ !\n" };
	$errhash{"NO_RULES_SEC"} = { "type" => "error", "string" => "No RULES section found in __file__ !\n" };
	$errhash{"AMBIGUOUS_DEF"} = { "type" => "error", "string" => "Ambiguous definition in rule \'__rule__\'. Use space to separate nonterminals.\n" };
	$errhash{"NONTERM_NOTDEF"} = { "type" => "error", "string" => "Not defined nonterminal \'__term__\'. \n" };
	$errhash{"NO_STARTSYM"} = { "type" => "error", "string" => "No start symbol in NONTERM section. \n" };
	$errhash{"EMPTY_RULE"} = { "type" => "warning", "string" => "Empty rule found at line __line__. \n" };
	$errhash{"UNMATCHED_CTAG"} = { "type" => "error", "string" => "Unmatched close tag \'__tag__\' in rule \'__rule__\'. \n" };
	$errhash{"UNMATCHED_OTAG"} = { "type" => "error", "string" => "Unmatched open tag \'__tag__\' in rule \'__rule__\'. \n" };
	$errhash{"PAIR_SYNFAIL"} = { "type" => "error", "string" => "PAIR: syntax incorrect at \'__line__\'. Allowed one OPEN and one CLOSE.\n" };
	$errhash{"RECURSION_DETECTED"} = { "type" => "error", "string" => "Checking \'__term1__\', recursive definition of \'__term2__\' detected.\n" };
	$errhash{"NPTERM_DETECTED"} = { "type" => "error", "string" => "Checking \'__term1__\', not productive terminal \'__term2__\' detected.\n" };
	
	return \%errhash;
}

#TO DO: varianta recursiva: pentru un substring definit si altul nu, apeleaza functia pentru ala nedefinit.
sub expandTerm( $$ ) {
	my( @letters ) = split( //, $_[0] );
	my( $leftt, $rightt );
	my( $ambcount ) = 0;

	for ( my $i = 0; $i < scalar( @letters ) - 1; $i++ ) {
		my( $left ) = join( "", @letters[0 .. $i] );
		my( $right ) = join( "", @letters[$i + 1 .. $#letters] );

		if ( ( exists( $nonterm{$left} ) || $left =~ /^\'.+?\'$/ ) && ( exists( $nonterm{$right} ) || $right =~ /^\'.+?\'$/ ) ) {
			$leftt = $left;
			$rightt = $right;
			$ambcount++;
		}
	}

	if ( $ambcount > 1 ) {
		errorsPrint( "AMBIGUOUS_DEF", { "__rule__" => $_[1] } );
	}

	if ( $ambcount == 0 ) {
		errorsPrint( "NONTERM_NOTDEF", { "__term__" => $_[0] } );
	}
	
	return ( $leftt, $rightt );
}

{
	my( $leftp, $rightp ) = ( 0, 0 );

	sub checkPar( $$$$ ) {
		my( $opensym, $closesym ) = ( $_[2], $_[3] );
		my( $lhs ) = $_[0];
		my( @rulerhs ) = @{ $_[1] };
		
		for ( my $i = 0; $i < scalar( @rulerhs ); $i++ ) {
			$leftp++ if ( $rulerhs[$i] eq $opensym );
			$rightp++ if ( $rulerhs[$i] eq $closesym );

			if ( $leftp - $rightp < 0 ) {
				errorsPrint( "UNMATCHED_CTAG", { "__tag__" => $closesym, "__rule__" => join( " ", ( $lhs, "->", join( " ", @rulerhs ) ) ) } );
			}
		}

		if ( $leftp - $rightp > 0 ) {
			errorsPrint( "UNMATCHED_OTAG", { "__tag__" => $opensym, "__rule__" => join( " ", ( $lhs, "->", join( " ", @rulerhs ) ) ) } );
		}
	}
}

sub validateGrammar() {
	foreach my $nt ( keys( %grammar ) ) {
		my( @rules ) = @{ $grammar{$nt} };

		foreach my $rl ( @rules ) {
			my( @rule ) = @{ $rl };

			foreach my $tpair ( @{ $nonterm{"__PAIR"} } ) {
				my( $left, $right ) = @{ $tpair };
				
				checkPar( $nt, \@rule, $left, $right );
			}
		}
		
		if ( $flags{"GRMVALREC"} == 1 ) {
			checkRecursion( "__init" );
			my( @res ) = checkRecursion( $nt );

			errorsPrint( "RECURSION_DETECTED", { "__term1__" => $nt, "__term2__" => $res[1] } ) if ( $res[0] );
		}

		if ( $flags{"GRMVALPROD"} == 1 ) {
			my( @res ) = checkProductivity( $nt );

			errorsPrint( "NPTERM_DETECTED", { "__term1__" => $nt, "__term2__" => $res[1] } ) if ( ! $res[0] );
		}
	}
}

{
	my( %rqueue ) = ();

	sub checkRecursion( $ ) {
		if ( $_[0] eq "__init" ) {
			%rqueue = ();
			return( 0, 0 );
		}
	
		my( $cnt ) = $_[0];
		my( @rules ) = ( exists( $grammar{$cnt} ) ? @{ $grammar{$cnt} } : () );

		foreach my $rl ( @rules ) {
			my( @rule ) = @{ $rl };

			#Add nonterminal to queue ...
			$rqueue{$cnt} = 1;

			foreach my $re ( @rule ) {
				if ( $re eq $cnt ) {
					return ( 1, $cnt );
				}
				else {
					if ( exists( $rqueue{$re} ) ) {
						return ( 1, $re );
					}

					my( @res ) = checkRecursion( $re );
					
					return ( 1, $res[1] ) if ( $res[0] == 1 );
				}
			}
		}

		#Remove nonterminal because it is not recursive.
		delete( $rqueue{$cnt} );

		return ( 0, $cnt );
	}
}

sub checkProductivity( $ ) {
	my( $cnt ) = $_[0];
	my( @rules ) = ( exists( $grammar{$cnt} ) ? @{ $grammar{$cnt} } : () );

	return ( 1, $cnt ) if ( $cnt =~ /^\'.+\'$/ );
	
	foreach my $rl ( @rules ) {
		my( @rule ) = @{ $rl };

		foreach my $re ( @rule ) {
			if ( exists( $nonterm{$re} ) && ! exists( $grammar{$re} ) ) {
				return ( 0, $re );
			}
		}
	}

	return ( 1, $cnt );
}

sub replaceRules() {
	my( $expandflag ) = 0;

	do {
		$expandflag = 0;

		foreach my $nt ( keys( %grammar ) ) {
			my( $rules ) = $grammar{$nt};

			NEXTRULE:
			foreach my $rl ( @{ $rules } ) {
				for ( my $i = 0; $i < scalar( @{ $rl } ); $i++ ) {
					if ( $rl->[$i] !~ /^\'.+\'$/ ) {
						my( @exrules ) = @{ $grammar{$rl->[$i]} };

						for ( my $j = 1; $j < scalar( @exrules ); $j++ ) {
							my( @thisrulecopy ) = @{ $rl };
							
							splice( @thisrulecopy, $i, 1, @{ $exrules[$j] } );
							push( @{ $rules }, \@thisrulecopy );
						}

						splice( @{ $rl }, $i, 1, @{ $exrules[0] } );
						$expandflag = 1;
						next NEXTRULE;
					}
				}
			}
		}
	}
	while ( $expandflag );

	#Keep only the start symbols ...
	foreach my $nt ( keys( %grammar ) ) {
		my( $rules ) = $grammar{$nt};
		
		#Nu e prea corect ce fac eu aici dar tine ... modific hash-ul in timp ce-l parcurg.
		if ( exists( $nonterm{$nt} ) && defined( $nonterm{$nt} ) && $nonterm{$nt} == 2 ) {
			delete( $grammar{$nt} );
			next;
		}
		
		for ( my $i = 0; $i < scalar( @{ $rules } ); $i++ ) {
			my( @rule ) = @{ $rules->[$i] };
			
			#0.3
			map { $_ =~ s/^\'// } @rule;
			map { $_ =~ s/\'$// } @rule;
			
			my( $rx ) = join( "", @rule );

			print( STDERR $nt . "\t" . $rx . "\n" ) if ( $flags{"GRMVALDEBUG"} == 1 );
			
			$rules->[$i] = qr/$rx/;
		}
	}
}

1;
