#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 6;
use Data::Dumper;
my $samples_dir = "t/sample_data";

#plan tests => 3;

#check we can load all ok...
BEGIN {
    use_ok( 'Bubble::Parse' ) || print "Bail out!\n";

}
	#load
	require_ok( 'Bubble::Parse' );

	#check new object creates
	my $new_obj = Bubble::Parse->new(
				-csv => "$samples_dir/basic.csv",
				-fasta => "$samples_dir/basic.fa",
				-coverages => "$samples_dir/basic.cov"
	);
	isa_ok $new_obj, "Bubble::Parse", "can't create object";
	
	my $expected = "Rank,Match,NumPth,Type,LngstCntig,LenP0,LenP1,CovC0P0,CovC0P1,CovC1P0,CovC1P1,PcC0P0,PcC0P1,PcC1P0,PcC1P1,C0Dif,C1Dif,QTotal";
	my @expectedarr = split(/,/, $expected);
	my $expectedarr_ref = \@expectedarr;	

	ok($new_obj->header eq $expected,"didn't get expected header string");
	is_deeply($new_obj->headerarr, $expectedarr_ref, "didn't get expected header array");

	my $line = $new_obj->next;
	isa_ok $line, "Bubble::Bubble", "can't create object";
	warn Dumper $line->get('rank');
	
	warn Dumper $line->paths; #returns names of paths as array ref
	
	warn Dumper $line->get('max_coverage', "1"); #second argument is name of path
	
	warn Dumper $line->seq("1"); #gets sequence of given path;
	
	warn $line->seq("1")->seq; #eg print the sequence!!
	
	warn Dumper $line->coverage("1"); #print the coverage array
	
	warn Dumper $line->coverage("1")->[3]; #print a single value
	
diag( "Testing Bubble::Parse $Bubble::Parse::VERSION, Perl $], $^X" );

