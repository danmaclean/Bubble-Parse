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

	my $bp = Bubble::Bubble->new(
			-csv_obj => Tie::Handle::CSV line object
			-seq_obj => Bio::Seq object
			-csv_headers => array ref of headers in the csv file
			-seq_headers => array ref of info in the fasta file header
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
	warn Dumper $self;
	return $self;
}

=head2 paths

	returns an array ref of the path names in this bubble
	
=cut

sub paths{
	my $self = shift;
	$$self{_paths};
}

=head2 get

	get returns attributes for the bubble, from the data portion in the csv  or the sequence portion in the fasta file

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

=cut

sub seq{
	my ($self,$path) = @_;	
	return $$self{_seq_obj}{$path};
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