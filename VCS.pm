package VCS;

my @IMPLEMENTATIONS;
my $CONTAINER_PAT = '(' . join('|', qw(VCS/Dir VCS/File VCS/Version)) . ')';

use vars qw($VERSION);
use VCS::Dir;
use VCS::File;
use VCS::Version;

$VERSION = '0.04';

sub implementations {
    my $class = shift;
    return @IMPLEMENTATIONS if @IMPLEMENTATIONS;
    my @impls = _find_implementations(@INC);
    $class->add_implementations(@impls);
    @IMPLEMENTATIONS;
}

sub _class2file {
    my $class = shift;
    $class =~ s#::#/#g;
    $class .= '.pm';
    $class;
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
    } grep {
        -d "$_/VCS"
    } @_;
    @impls;
}

sub add_implementations {
    my ($class, @implementations) = @_;
    # first, strip out all occurrences of these from the existing list
    my %mask = map { ($_ => 1) } @implementations;
    @IMPLEMENTATIONS = grep { !$mask{$_} } @IMPLEMENTATIONS;
	# drat, VCS::CVS and VCS::PVCS aren't one of ours...
	@implementations = grep { $_ !~ /CVS|PVCS/ } @implementations;
    map { require(_class2file($_)) } @implementations;
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
        print $version->version,
              ' was checked in by ',
              $version->author,
              "\n";
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

=head1 VCS METHODS

=head2 VCS-E<gt>implementations

Returns a list of the implementations, in the order in which they will
be tried by the container classes. The first time it is called (as
determined by whether there are any implementations known), it will
search @INC for all compliant implementations.

=head2 VCS-E<gt>add_implementations(@implementations)

C<@implementations> is moved/added to the front of the list, so use this
also to set the default or control the order of implementations tried.

=head1 VCS::* METHODS

Please refer to the documentation for L<VCS::Dir>, L<VCS::File>, 
and L<VCS::Version>; as well as the implementation specific documentation
as in L<VCS::Cvs>, L<VCS::Rcs>.

=head1 AVAILABILITY

VCS.pm and its friends are available from CPAN.  There is a web page
at:

    http://www.astray.com/VCS/

as well as a sourceforge project page at:

    http://sourceforge.net/projects/vcs/

=head1 MAILING LIST

There is currently a mailing list about VCS. Go to the following
webpage to subscribe to it:

    http://www.astray.com/mailman/listinfo/vcs

There is a web archive of the mailing list at:

    http://www.astray.com/pipermail/vcs/

General queries should be made directly to the mailing list.

=head1 COPYRIGHT

Copyright (c) 1998-2001 Leon Brocard. All rights reserved. This
program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

L<VCS::Cvs>, L<VCS::Dir>, L<VCS::File>, L<VCS::Rcs>, L<VCS::Version>.
