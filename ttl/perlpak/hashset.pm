# TTL and all included Perl modules is (C) Radu Ion (radu@racai.ro) and ICIA 2005-2018.
# Permission is granted for research and personal use ONLY.
#
# A few functions on sets. They take as arguments pointers to lists of scalars only.
#
package hashset;

#These functions receive pointers to lists of scalars which represent sets !
sub intersection( $$ );
sub union( $$ );
sub diff( $$ );
sub memberOf( $$ );
sub makeThisASet( $ );
sub isVoid( $ );
sub areEqual( $$ );
sub isIncluded( $$ );

return 1;

#A ^ B
#Complexity: |A| + |B|
#A and B are supposed to be sets.
sub intersection( $$ ) {
	my( $A, $B ) = ( $_[0], $_[1] );
	my( @rez ) = ();
	my( %hashSmall ) = ();

	( ! ref( $A ) || ! ref( $B ) ) and do { print( "hashset::intersection() -> Not pointer arguments !\n" ); return \@rez; };
	( scalar( @{ $A } ) == 0 || scalar( @{ $B } ) == 0 ) and return \@rez;

	if ( scalar( @{ $A } ) > scalar( @{ $B } ) ) {
		my( $rtmp );

		$rtmp = $A;
		$A = $B;
		$B = $rtmp;
	}

	foreach my $i ( @{ $A } ) {
		$hashSmall{$i} = 1;
	}

	foreach my $j ( @{ $B } ) {
		if ( exists( $hashSmall{$j} ) ) {
			@rez = ( @rez, $j );
		}
	}

	return \@rez;
}

#A == B ?
#0 if false
#1 if true
#A and B are supposed to be sets.
sub areEqual( $$ ) {
	my( $A, $B ) = ( $_[0], $_[1] );
	my( %hash ) = ();
	my( @rez ) = ();

	( ! ref( $A ) || ! ref( $B ) ) and do { print( "hashset::areEqual() -> Not pointer arguments !\n" ); return 0 };
	( scalar( @{ $A } ) == 0 && scalar( @{ $B } ) != 0 ) and return 0;
	( scalar( @{ $A } ) != 0 && scalar( @{ $B } ) == 0 ) and return 0;
	( scalar( @{ $A } ) != scalar( @{ $B } ) ) and return 0;
	( scalar( @{ $A } ) == 0 && scalar( @{ $B } ) == 0 ) and return 1;
	
	foreach my $i ( @{ $A } ) {
		$hash{$i} = 1;
	}

	foreach my $j ( @{ $B } ) {
		return 0 if ( ! exists( $hash{$j} ) );
	}

	return 1;
}

#A V B
#Complexity: |A| + |B|
#A and B are supposed to be sets.
sub union( $$ ) {
	my( $A, $B ) = ( $_[0], $_[1] );
	my( %hash ) = ();
	my( @rez ) = ();

	( ! ref( $A ) || ! ref( $B ) ) and do { print( "hashset::union() -> Not pointer arguments !\n" ); return \@rez; };
	( scalar( @{ $A } ) == 0 ) and return $B;
	( scalar( @{ $B } ) == 0 ) and return $A;
	( scalar( @{ $A } ) == 0 && scalar( @{ $B } ) == 0 ) and return \@rez;
	
	foreach my $i ( @{ $A } ) {
		$hash{$i} = 1;
	}

	foreach my $j ( @{ $B } ) {
		$hash{$j} = 1;
	}

	@rez = keys( %hash );

	return \@rez;
}

#A - B
#Complexity: |A| + |B|
#A and B are supposed to be sets.
sub diff( $$ ) {
	my( $A, $B ) = ( $_[0], $_[1] );
	my( @rez ) = ();
	my( %hashB ) = ();
	
	( ! ref( $A ) || ! ref( $B ) ) and do { print( "hashset::diff() -> Not pointer arguments !\n" ); return \@rez; };
	( scalar( @{ $A } ) == 0 ) and return \@rez;
	
	foreach my $i ( @{ $B } ) {
		$hashB{$i} = 1;
	}

	foreach my $j ( @{ $A } ) {
		if ( ! exists( $hashB{$j} ) ) {
			@rez = ( @rez, $j );
		}
	}

	return \@rez;
}

#elem is a member of r_set ...
sub memberOf( $$ ) {
	my( $elem, $r_set ) = ( $_[0], $_[1] );
	my( $k );
	
	foreach $k ( @{ $r_set } ) {
		if ( $elem eq $k ) {
			return 1;
		}
	}
	
	return 0;
}

sub makeThisASet( $ ) {
	my( $A ) = ( $_[0] );
	my( %nset ) = ();
	my( @newset ) = ();

	( ! ref( $A ) ) and do { print( "hashset::makeThisASet() -> Not pointer arguments !\n" ); return \@newset; };
	( scalar( @{ $A } ) == 0 ) and return \@newset;

	foreach my $j ( @{ $A } ) {
		$nset{$j} = 1;
	}

	@newset = keys( %nset );

	return \@newset;
}

sub isVoid( $ ) {
	my( $A ) = $_[0];

	( ! ref( $A ) ) and do { print( "hashset::isVoid() -> Not pointer argument !\n" ), return -1; };

	return scalar( @{ $A } ) == 0;
}

sub isIncluded( $$ ) {
	my( $A, $B ) = ( $_[0], $_[1] );
	my( @rez ) = ();
	my( %hashB ) = ();
	
	( ! ref( $A ) || ! ref( $B ) ) and do { print( "hashset::diff() -> Not pointer arguments !\n" ); return 0; };
	( scalar( @{ $A } ) == 0 || scalar( @{ $B } ) == 0 ) and return 1;

	foreach my $i ( @{ $B } ) {
		$hashB{$i} = 1;
	}

	foreach my $j ( @{ $A } ) {
		if ( ! exists( $hashB{$j} ) ) {
			return 0;
		}
	}

	return 1;
}
