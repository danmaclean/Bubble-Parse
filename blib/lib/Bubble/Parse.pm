package Bubble::Parse;

use 5.006;
use strict;
use warnings FATAL => 'all';
use FileHandle;
use Tie::Handle::CSV;
use Data::Dumper;
use Bubble::Bubble;
use Bio::Seq;
use Carp;

=head1 NAME

Bubble::Parse - The great new Bubble::Parse!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Bubble::Parse;

    my $foo = Bubble::Parse->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

Create a new file object representing the Bubbleparse output

	my $bp = Bubble::Parse->new(
			-csv => "somefile.csv",
			-fasta => "somefile.fasta"
			
	);

=cut

sub new {
    my $class_name = shift;
    my $self = {};
    bless ($self, $class_name);
	my %arg = @_;
	$$self{_csvfile} = $arg{-csv};
	my $csv_fh = Tie::Handle::CSV->new($$self{_csvfile}, 
		header => 1, 
		key_case => 'any', 
		open_mode => '<'
		) || die "couldn't open file $$self{_csvfile}\n\n";
	$$self{_csvfh} = $csv_fh; #actual file handle
	$$self{_matchfile} = $arg{'-matchfile'};
	
	$$self{_header} = $$self{_csvfh}->header;
	my @headerarr = split(/,/,$$self{_csvfh}->header);
	my $headerarr_ref = \@headerarr;
	$$self{_headerarr} = $headerarr_ref;
	
	#now do the fasta file
	$$self{_fastafile} = $arg{-fasta};
	
	##a hash of positions of the sequence header in the fasta files ..
	$self->_get_match_file_positions;
	return $self;
}

#get the position in bytes of each fasta entry and make an index
sub _get_match_file_positions{
	
	my $self = shift;
	my $info = {};
	my $fasta = FileHandle->new( "$$self{_fastafile}", "r") || croak "could not open FASTA file $$self{_fastafile}";
	while (my $line = $fasta->getline){
		if ($line =~ m/^>/){
			my $string_length = _length_in_bytes($line);
			$line =~ m/^>match_(\d+)_path_(\d+)/;
			my ($match_num,$match_path) = ($1,$2);
			my $pos = tell($fasta) - $string_length;
			$$info{$match_num}{$match_path} = $pos; 
		}
	}
	$$self{_match_file_index} = $info;
	warn Dumper $info;
	$$self{_fasta_fh} = $fasta;
}

#returns a hash of attributes for the match sought including sequence
sub _seek_sequence{
	my ($self,$match_num) = @_;
	my $seqs =  {};
	my $headers = {};
		
	foreach my $path (keys %{$$self{_match_file_index}{$match_num}}){
		my $pos = $$self{_match_file_index}{$match_num}{$path};
		seek($$self{_fasta_fh},$pos,0);
		my $header = $$self{_fasta_fh}->getline;
		chomp $header;
		$header =~ s/^>//;
		
		my @info = split(/\s+/,$header);
		my $name = shift @info;
		foreach my $pair (@info){
			my @pr = split(/:/,$pair);
			$$headers{$path}{$pr[0]} = $pr[1];
		}
		
		my $seq = "";
		while(my $line = $$self{_fasta_fh}->getline){
			last if $line =~ m/^>/;
			chomp $line;
			$seq .= $line;
		}
		warn $seq;
		warn $name;
		$$seqs{$path} = Bio::Seq->new(-seq => $seq, -id => $name);
	}
	
	
	return ($seqs, $headers);
}


sub _length_in_bytes{

	use bytes;
	return length shift;

}

=head2 header

Returns a string of the header titles from the csv file

	my $header = $bp->header;

=cut

sub header{
	my $self = shift;
	$$self{_header};
}


=head2 headerarr

Returns an arrayref of the header titles from the csv file

	my @headers = @{$bp->headerarr};

=cut

sub headerarr{
	my $self = shift;
	$$self{_headerarr};
}

=head2 next

Returns the next Bubble::Bubble object representing a single bubble

	while (my $bub = $bp->next){
	 ##do stuff
	}

=cut

sub next{
	my $self = shift;
	my $fh = $$self{_csvfh};
	my $csv_obj = <$fh>;
	my $match = $csv_obj->{'match'};
	
	my ($seq_obj_hash, $headers_hash) = $self->_seek_sequence($match);
	
	#work out the names of the attrs in the fasta header
	#and how many paths
	my %tmp;
	my %paths;
	foreach my $path (keys %{$headers_hash}){
		$paths{$path} = 1;
		foreach my $att (keys %{$$headers_hash{$path} }){
			$tmp{$att} = 1; 
		}
	} 
	
	my @seq_headers = keys %tmp;
	my @paths = keys %paths;
	return Bubble::Bubble->new(
		-csv_obj => $csv_obj,
		-seq_obj => $seq_obj_hash, #will be hashref of Bio::Seq objects (one for each path)
		-csv_headers => $self->headerarr,
		-seq_header_info => $headers_hash, #will be hashref of info from fasta headers, (one set for each path)
		-seq_headers => \@seq_headers, #arrayref of header info in fasta file
		-paths => \@paths
	);
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

1; # End of Bubble::Parse
