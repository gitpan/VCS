package VCS::Version;

my $PREFIX = 'VCS';

sub new {
    my $class = shift;
    $class =~ s#^$PREFIX##;
    foreach my $impl (VCS->implementations) {
        my $this_class = "$impl$class";
        my $self = $this_class->new(@_);
        return $self if defined $self;
    }
    return;
}

sub name {
}

sub version {
}

sub tags {
}

sub text {
}

sub diff {
}

sub author {
}

sub date {
}

sub reason {
}

1;

__END__

=head1 NAME

VCS::Version - module for access to a VCS version

=head1 SYNOPSIS

    use VCS;
    die "Usage: $0 file version\n" unless @ARGV == 2;
    my $version = VCS::Version->new(@ARGV);
    print "Methods of \$version:\n",
        "name: ", $version->name, "\n",
        "author: ", $version->author, "\n",
        "version: ", $version->version, "\n",
        ;

=head1 DESCRIPTION

VCS::Version abstracts a single revision of a file under version
control.

=head1 METHODS

Methods marked with a "*" are not yet finalised/implemented.

=head2 VCS::Version->create_new(@version_args) *

C<@version_args> is a list which will be treated as a hash, with
contents as follow:

    @version_args = (
        name    => 'a file name',
        version => 'an appropriate version identifier',
        tags    => [ 'A_TAG_NAME', 'SECOND_TAG' ],
        author  => 'the author name',
        reason  => 'the reason for the checkin',
        text    => 'either literal text, or a ref to the filename',
    );

This is a pure virtual method, which must be over-ridden, and cannot be
called directly in this class (a C<die> will result).

=head2 VCS::Version->new($file, $version)

C<$file> is a filename, absolute or relative. C<$version> is a version
number, or tag. Returns an object of class C<VCS::Version>, or undef
if it fails. Implementation classes must be careful not to return an
object unless they mean it.

=head2 $version->name

Returns the C<$file> argument to C<new>.

=head2 $version->version

Returns the C<$version> argument to C<new>.

=head2 $version->tags

Returns a list of tags applied to this version.

=head2 $version->text

Returns the text of this version of the file.

=head2 $version->diff($other_version)

Returns the differences (in C<diff -u> format) between this version and
the other version. Currently, the other version must also be a
C<VCS::Version> object.

=head2 $version->author

Returns the name of the user who checked in this version.

=head2 $version->date

Returns the date this version was checked in.

=head2 $version->reason

Returns the reason given on checking in this version.

=head1 SEE ALSO

L<VCS>.

=head1 COPYRIGHT

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
