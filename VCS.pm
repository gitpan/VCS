package VCS;

my @IMPLEMENTATIONS;
my $CONTAINER_PAT = '(' . join('|', qw(VCS/Dir VCS/File VCS/Version)) . ')';

use vars qw($VERSION);
use VCS::Dir;
use VCS::File;
use VCS::Version;

$VERSION = '0.01';

sub implementations {
    my $class = shift;
    return @IMPLEMENTATIONS if @IMPLEMENTATIONS;
    my @impls = _find_implementations(@INC);
    $class->add_implementations(@impls);
    @IMPLEMENTATIONS;
}

sub _find_implementations {
    my @impls = map {
        my $search_dir = $_;
        map {
            s#^$search_dir/*##;
            s#/+#::#g;
            s#\.pm$##;
            $_
        } grep {
            !/$CONTAINER_PAT\.pm$/
        } glob "$search_dir/VCS/*.pm"
    } @_;
    @impls;
}

sub add_implementations {
    my ($class, @implementations) = @_;
    # first, strip out all occurrences of these from the existing list
    my %mask = map { ($_ => 1) } @implementations;
    @IMPLEMENTATIONS = grep { !$mask{$_} } @IMPLEMENTATIONS;
    map { eval "require $_" || die } @implementations;
    unshift @IMPLEMENTATIONS, @implementations;
}

1;

__END__

=head1 NAME

VCS - Library for generic Version Control System access in Perl

=head1 SYNOPSIS

    use VCS;
    $file = VCS::File->new($ARGV[0]);
    print $file->name, ":\n";
    for $version ($file->versions) {
        print
            $version->version,
            ' was checked in by ',
            $version->author,
            "\n",
            ;
    }

=head1 DESCRIPTION

C<VCS> is an API for abstracting access to all version control systems
from Perl code. This is achieved in a similar fashion to the C<DBI>
suite of modules. There are "container" classes, C<VCS::Dir>,
C<VCS::File>, and C<VCS::Version>, and "implementation" classes, such
as C<VCS::Cvs::Dir>, C<VCS::Cvs::File>, and C<VCS::Cvs::Version>, which
are subclasses of their respective "container" classes.

The "container" classes work as follows: when the C<new> method of a
container class is called, it will cycle through each of the known
implementation classes, trying its C<new> method with the given
arguments until one returns a defined result, which will then be
returned.

An implementation class is recognised as follows: its name starts with
C<VCS::>, and C<require "VCS/Classname.pm"> will load the appropriate
implementation classes corresponding to the container classes.

In general, implementation classes' C<new> methods must be careful not
to return "false positives", by rigorously checking if their arguments
conform to their particular version control system.

=head1 METHODS

=head2 VCS->implementations

Returns a list of the implementations, in the order in which they will
be tried by the container classes. The first time it is called (as
determined by whether there are any implementations known), it will
search @INC for all compliant implementations.

=head2 VCS->add_implementations(@implementations)

C<@implementations> is moved/added to the front of the list, so use this
also to set the default or control the order of implementations tried.

=head1 AVAILABILITY 

VCS.pm and its friends will initially be available from 
http://www.astray.com/VCS/ and later from CPAN.

=head1 COPYRIGHT 

Copyright (c) 1998 Leon Brocard. All rights reserved. This program is free 
software; you can redistribute it and/or modify it under the same terms
as Perl itself. 

=head1 SEE ALSO

L<VCS::Cvs>, L<VCS::Dir>, L<VCS::File>, L<VCS::Version>.
