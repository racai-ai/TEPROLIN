# TTL and all included Perl modules is (C) Radu Ion (radu@racai.ro) and ICIA 2005-2018.
# Permission is granted for research and personal use ONLY.
#
# String conversions.
#
# ver 0.1, 07-Jun-06, Radu ION, created.
# ver 0.2, 11-Jul-08, Radu ION, added UTF7
# ver 0.3, 06-Jul-10, Radu ION, added decode to Perl internals for SGML->UTF8.
# ver 0.4, 07-Jul-10, Radu ION, checked and modified Unicode, UTF8-perl, UTF8 modes. Tested all functions properly.
# ver 0.5, 18-Jan-13, Radu ION, fixed a bug with '&.+?;' to recognize entities: '&[A-Za-z]+;'.
# ver 0.6, 18-Jan-13, Radu ION, no die() when an unknown entity is detected. Just report, preserve and go on.
# ver 0.7, 17-Mar-17, Radu ION, removed 'no' annotation and used hex code > 255 instead.
# ver 0.8, 18-Mar-17, Radu ION, added 0-9. to the range of chars to be recognized in SGML entities
# ver 0.9, 06-Oct-17, Radu ION, added some exceptions to what's in the map.

package pdk::enccnv;

use strict;
use warnings;
use Unicode::String;
use utf8;

#Input: [classname], path to sgmlunic.ent file.
sub new( $$ );
#Input: [object], from encoding, to encoding, string
#Output: string that was converted.
sub convert( $$$$ );
#Input: [object], from encoding, to encoding, infile path, outfile path
#Output: nothing
sub convertFile( $$$$$ );
#Input: [object]
#Output: list of supported encodings.
sub getencodings( $ );

sub new( $$ ) {
	my( $classname ) = $_[0];
	my( $entfile ) = $_[1];
	my( $this ) = {};
	my( %sgmltohex ) = ();
	my( %hextosgml ) = ();
	
	open( ENT, "< $entfile" ) or die( "pdk::strconv::new : could not open the entities file ...\n" );
	
	while ( my $line = <ENT> ) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		
		my( @toks ) = split( /\s+/, $line );
		
		$sgmltohex{$toks[0]} = $toks[1];
		
		if ( hex( "0x" . $toks[1] ) > 255 ) {
			$hextosgml{$toks[1]} = $toks[0];
		}
		# Exceptions of below 255 chars that have to be in the hextosgml hash
		# 1. « and » quotes
		# 2. Celsius °
		# 3. Times ×
		elsif (
			$toks[1] eq "00AB" || $toks[1] eq "00BB" ||
			$toks[1] eq "00B0" ||
			$toks[1] eq "00D7"
		) {
			$hextosgml{$toks[1]} = $toks[0];
		}
		else {
			my( $uncchr ) = Unicode::String->new();
						
			$uncchr->chr( hex( "0x" . $toks[1] ) );
			my( $outstring ) = $uncchr->utf8();

			utf8::decode( $outstring );
			
			if ( $outstring =~ /^\p{L}$/ ) {
				$hextosgml{$toks[1]} = $toks[0];
			}
		}
	}
	
	close( ENT );
	
	$this->{"SGMLTOHEX"} = \%sgmltohex;
	$this->{"HEXTOSGML"} = \%hextosgml;
	
	bless( $this, $classname );
	return $this;
}

sub convert( $$$$ ) {
	my( $this ) = shift( @_ );
	my( $inenc, $outenc, $string ) = @_;
	my( $outstring );
	my( $sgmlcharrx ) = "&[A-Za-z0-9.]+;";
	
	SWCONVOPT: {
		( $inenc eq "UTF8" && $outenc eq "SGML" ) and do {
			my( $unicodestring ) = Unicode::String->new();
			my( @hexchars );
			my( @sgmlchars ) = ();
			
			$unicodestring->utf8( $string );
			@hexchars = split( /\s+/, $unicodestring->hex() );
			
			foreach my $hc ( @hexchars ) {
				$hc =~ s/^U\+//;
				$hc = uc( $hc );
				
				if ( exists( $this->{"HEXTOSGML"}->{$hc} ) ) {
					push( @sgmlchars, "&" . $this->{"HEXTOSGML"}->{$hc} . ";" );
				}
				else {
					push( @sgmlchars, chr( hex( $hc ) ) );
				}
			}
			
			$outstring = join( "", @sgmlchars );
			last;
		};

		( $inenc eq "SGML" && $outenc eq "UTF8" ) and do {
			my( @stringchars ) = split( /($sgmlcharrx)|/, $string );
			my( $unicodestring ) = Unicode::String->new( "" );
			
			foreach my $c ( @stringchars ) {
				if ( defined( $c ) && $c ne "" ) {
					if ( $c !~ /$sgmlcharrx/ ) {
						my( $uncchr ) = Unicode::String->new();
						
						$uncchr->chr( ord( $c ) );
						$unicodestring->append( $uncchr );
					}
					else {
						$c =~ s/^&//;
						$c =~ s/;//;
						
						my( $uncchr ) = Unicode::String->new();
						
						if ( exists( $this->{"SGMLTOHEX"}->{$c} ) ) {
							$uncchr->chr( hex( $this->{"SGMLTOHEX"}->{$c} ) );
							$unicodestring->append( $uncchr );
						}
						else {
							warn( "pdk::strconv::convert (\'$inenc\' -> \'$outenc\') : unknown SGML entity \'$c\' !\n" );

							my( @cchr ) = split( //, "&" . $c . ";" );
							
							foreach my $ac ( @cchr ) {
								my( $uc ) = Unicode::String->new();

								$uc->chr( ord( $ac ) );
								$unicodestring->append( $uc );
							}
						}
					}
				}
			}
			
			$outstring = $unicodestring->utf8();
			last;
		};

		( $inenc eq "SGML" && $outenc eq "UTF8-perl" ) and do {
			my( @stringchars ) = split( /($sgmlcharrx)|/, $string );
			my( $unicodestring ) = Unicode::String->new( "" );
			
			foreach my $c ( @stringchars ) {
				if ( defined( $c ) && $c ne "" ) {
					if ( $c !~ /$sgmlcharrx/ ) {
						my( $uncchr ) = Unicode::String->new();
						
						$uncchr->chr( ord( $c ) );
						$unicodestring->append( $uncchr );
					}
					else {
						$c =~ s/^&//;
						$c =~ s/;//;
						
						my( $uncchr ) = Unicode::String->new();
						
						if ( exists( $this->{"SGMLTOHEX"}->{$c} ) ) {
							$uncchr->chr( hex( $this->{"SGMLTOHEX"}->{$c} ) );
							$unicodestring->append( $uncchr );
						}
						else {
							warn( "pdk::strconv::convert (\'$inenc\' -> \'$outenc\') : unknown SGML entity \'$c\' !\n" );

							my( @cchr ) = split( //, "&" . $c . ";" );
							
							foreach my $ac ( @cchr ) {
								my( $uc ) = Unicode::String->new();

								$uc->chr( ord( $ac ) );
								$unicodestring->append( $uc );
							}
						}
					}
				}
			}
			
			$outstring = $unicodestring->utf8();
			#0.3
			#Turn the Unicode::String in utf8 to Perl internal UTF-8 representation - which is Unicode in principle ...
			utf8::decode( $outstring );
			last;
		};

		( $inenc eq "SGML" && $outenc eq "Unicode" ) and do {
			my( @stringchars ) = split( /($sgmlcharrx)|/, $string );
			my( $unicodestring ) = Unicode::String->new( "" );
			
			foreach my $c ( @stringchars ) {
				if ( defined( $c ) && $c ne "" ) {
					if ( $c !~ /$sgmlcharrx/ ) {
						my( $uncchr ) = Unicode::String->new();
						
						$uncchr->chr( ord( $c ) );
						$unicodestring->append( $uncchr );
					}
					else {
						$c =~ s/^&//;
						$c =~ s/;//;
						
						my( $uncchr ) = Unicode::String->new();
						
						if ( exists( $this->{"SGMLTOHEX"}->{$c} ) ) {
							$uncchr->chr( hex( $this->{"SGMLTOHEX"}->{$c} ) );
							$unicodestring->append( $uncchr );
						}
						else {
							warn( "pdk::strconv::convert (\'$inenc\' -> \'$outenc\') : unknown SGML entity \'$c\' !\n" );

							my( @cchr ) = split( //, "&" . $c . ";" );
							
							foreach my $ac ( @cchr ) {
								my( $uc ) = Unicode::String->new();

								$uc->chr( ord( $ac ) );
								$unicodestring->append( $uc );
							}
						}
					}
				}
			}
			
			#16 bit encoding of Unicode. It's recognized by Word and EditPlus.
			$outstring = $unicodestring->ucs2();
			last;
		};

		#ver 0.2
		( $inenc eq "SGML" && $outenc eq "UTF7" ) and do {
			my( @stringchars ) = split( /($sgmlcharrx)|/, $string );
			my( $unicodestring ) = Unicode::String->new( "" );
			
			foreach my $c ( @stringchars ) {
				if ( defined( $c ) && $c ne "" ) {
					if ( $c !~ /$sgmlcharrx/ ) {
						my( $uncchr ) = Unicode::String->new();
						
						$uncchr->chr( ord( $c ) );
						$unicodestring->append( $uncchr );
					}
					else {
						$c =~ s/^&//;
						$c =~ s/;//;
						
						my( $uncchr ) = Unicode::String->new();
						
						if ( exists( $this->{"SGMLTOHEX"}->{$c} ) ) {
							$uncchr->chr( hex( $this->{"SGMLTOHEX"}->{$c} ) );
							$unicodestring->append( $uncchr );
						}
						else {
							warn( "pdk::strconv::convert (\'$inenc\' -> \'$outenc\') : unknown SGML entity \'$c\' !\n" );

							my( @cchr ) = split( //, "&" . $c . ";" );
							
							foreach my $ac ( @cchr ) {
								my( $uc ) = Unicode::String->new();

								$uc->chr( ord( $ac ) );
								$unicodestring->append( $uc );
							}							
						}
					}
				}
			}
			
			$outstring = $unicodestring->utf7();
			last;
		};

		die( "pdk::strconv::convert : unimplemented conversion from \'$inenc\' to \'$outenc\' !\n" );
	}
	
	return $outstring;
}

sub getencodings( $ ) {
	my( $this ) = shift( @_ );
	
	return ( "UTF8", "SGML", "UTF7", "UTF8-perl", "Unicode" );
}

sub convertFile( $$$$$ ) {
	my( $this ) = shift( @_ );
	my( $inen, $outen, $infile, $outfile ) = @_;
	
	open( INF, "< $infile" ) or die( "pdk::enccnv::convertFile : cannot open file \'$infile\' !" );
	open( OUTF, "> $outfile" ) or die( "pdk::enccnv::convertFile : cannot open file \'$outfile\' !" );

	binmode( INF );
	binmode( OUTF );

	while ( my $buffer = <INF> ) {
		my( $towritestring ) = $this->convert( $inen, $outen, $buffer );
		
		print( OUTF $towritestring );
	}
	
	close( OUTF );
	close( INF );
}

1;
