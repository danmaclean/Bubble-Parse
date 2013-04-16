package Bubble::Runner;

use 5.006;
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
=head1 NAME

Bubble::Blower - The great new Bubble::Blower!

Will set up and run Bubbleparse if provided with cortex output files

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Bubble::Blower;

    my $foo = Bubble::Blower->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new



=cut

sub new {
    my $class_name = shift;
    my $self = {};
	my %args = @_;
    bless ($self, $class_name);

}



1; # End of Bubble::Blower