package Bubble::Bubble;

use 5.006;
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
=head1 NAME

Bubble::Bubble - The great new Bubble::Bubble!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Bubble::Bubble;

    my $foo = Bubble::Bubble->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

Create a new object representing the Bubble::Bubble output. usually called from Bubble::Parse->next

	my $b = Bubble::Bubble->new(
			-csv_obj => $csv #Tie::Handle::CSV line object
			-seq_obj => $seq_obj_hash #Hashref for hash of path numbers and Bio::Seq objects e.g  (1 => Bio::Seq object)
			-csv_headers => \@csv_headers #array ref of the headers in the csv file
			-seq_headers => $headers_hash #array ref of headers info in the fasta file
			-seq_header_info => #hashref for hash of path numbers and header info from fasta gule
			-paths => \@paths #array ref of path names through the bubble
			-coverages => $coverages_hash #hashref for hash of path numbers and arrays of coverages eg (1 => \@(1,2,3) )
	);

=cut

sub new {
    my $class_name = shift;
    my $self = {};
	my %args = @_;
    bless ($self, $class_name);
	$$self{_csv_obj} = $args{-csv_obj};
	$$self{_seq_obj} = $args{-seq_obj};
	$$self{_csv_headers} = $args{-csv_headers};
	$$self{_seq_headers} = $args{-seq_headers};
	$$self{_seq_header_info} = $args{-seq_header_info};
	$$self{_paths} = $args{-paths};
	$$self{_coverages} = $args{-coverages};
	warn Dumper $self;
	return $self;
}

=head2 paths

returns an array ref of the path names in this bubble

	$b->paths # (1,2);
	
=cut

sub paths{
	my $self = shift;
	$$self{_paths};
}

=head2 get

get returns attributes for the bubble from the data portion in the csv or the sequence portion in the fasta file

EG from the csv file

	$b->get('rank')  #returns value for the bubbles'Rank' from the csv file for this bubble,
	$b->get('Rank')  #is case insensitive 

EG from the Fasta file

	$b->get('fst_coverage', 1) #gets the value of fst_coverage for path 1
	
	
Here is the info from the Bubbleparse manual for the information in the header of the fasta files

length - the length of the sequence, in nucleotides.
 type - the type of bubble discovered. This consists of two characters, the first representing the start node, the second the end node. An R indicates a reverse branch Y node, an F a forward branch Y node and an X indicates an X node.
 pre length - the length of the flanking before the bubble path sequence.
 mid length - the length of the path through the bubble.
 post length - the length of the flanking after the bubble path sequence.
 cX average coverage - the mean coverage for colour X of path through bubble (ie. not including flanking).
 average coverage - the mean coverage of the whole sequence (including flanking).
 min coverage - the lowest coverage of any node in the sequence.
 max coverage - the highest coverage of any node in the sequence.
 fst f - valid edges in the de Bruijn graph in the forward orientation for the first kmer of the path that generated the sequence.
 fst r - valid edges in the de Bruijn graph in the reverse orientation for the first kmer of the path that generated the sequence.
 fst kmer - the first kmer in the sequence.
 lst f - valid edges in the de Bruijn graph in the forward orientation for the last kmer of the path that generated the sequence.
 lst r - valid edges in the de Bruijn graph in the reverse orientation for the last kmer of the path that generated the sequence.
 lst kmer - the last kmer in the sequence

Here is the info from the Bubbleparse manual for the information for in the CSV file

 Rank - gives the rank within this type, with 1 the highest rank.
 Match - gives the match number, which can be cross referenced with the Cortex output files.
 Num Pth - indicates the number of paths through the bubble.
 Type - the type of the bubble, according to the classification given in Section 2.2.
 Lngst Cntig - gives the length of the longest contig associated with the bubble - that is, the length of the longest path through the bubble, plus flanking. For SNPs, paths through the bubble will all have the same length, but for indels, path lengths are likely to be different.
 Path Len - gives the length of the first two (or three, if present) paths through the bubble. This length does not include flanking.
 Flags - shows the status of a number of flags associated with the entry. Most of these can be ignored, but look out for an R which indicates the match is a reverse compliment repeat. These will appear at the bottom of tables.
 c0 Coverage - provides the mean coverage in colour 0 along the first (P0) and second (P1) paths through the bubble.
 c1 Coverage - provides the mean coverage in colour 1 along the first (P0) and second (P1) paths through the bubble.
 c0 Coverage % - provides the colour 0 percentage coverage along the first (P0) and second (P1) paths through the bubble. The sum of colour 0 percentages along all paths will add up to 100.
 c1 Coverage % - provides the colour 1 percentage coverage along the first (P0) and second (P1) paths through the bubble. The sum of colour 0 percentages along all paths will add up to 100.
 Difference - provides a measure of how much the coverage percentage differs from the expected coverage ratio.
	
NOTE: some attributes are in both the CSV and in the fasta file under different names, so can be retrieved separately if desired.

=cut

sub get {
	my ($self,$thing,$path) = @_;
	if (grep /$thing/i, @{$$self{_csv_headers} } ){
		return $$self{_csv_obj}->{$thing};
	}
	elsif(grep /$thing/i, @{$$self{_seq_headers} } ){
		return $$self{_seq_header_info}{$path}{$thing};
	}
	else{
		return undef;
	}
}

=head2 seq

returns Bio::Seq object of path sequence

	$b->seq('1') #returns Bio::Seq object of path 1
	$b->seq('1')->seq returns sequence string of path 1

=cut

sub seq{
	my ($self,$path) = @_;	
	return $$self{_seq_obj}{$path};
}

=head2 coverage

returns array ref of coverages for a path

	$b->coverage('1') #returns arrayref of coverages for path 1
	$b->coverage('1')->[0] #returns scalar of coverage for path 1 at first position 

=cut

sub coverage{
	my ($self,$path) = @_;	
	return $$self{_coverages}{$path};
}

=head1 AUTHOR

Dan MacLean, C<< <maclean.daniel at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-bubble-parse at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Bubble-Parse>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Bubble::Parse


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Bubble-Parse>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Bubble-Parse>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Bubble-Parse>

=item * Search CPAN

L<http://search.cpan.org/dist/Bubble-Parse/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Dan MacLean.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Bubble::Bubble