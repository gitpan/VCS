package VCS::File;

my $PREFIX = 'VCS';

use Carp;
use File::Basename;

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

sub versions {
}

1;

__END__

=head1 NAME

VCS::File - module for access to a file under version control

=head1 SYNOPSIS

    use VCS;
    my $f = VCS::File->new($file);
    print $f->name . "\n";
    foreach my $v ($f->versions) {
        print "\tversion: " . $v->version . "\t" . ref($v) . "\n";
    }

=head1 DESCRIPTION

C<VCS::File> abstracts access to a file under version control.

=head1 METHODS

Methods marked with a "*" are not yet finalised/implemented.

=head2 VCS::File->create_new($name) *

C<$name> is a file name, absolute or relative.  Creates data as
appropriate to convince the VCS that there is a file, and returns an
object of class C<VCS::File>, or undef if it fails. This is a pure
virtual method, which must be over-ridden, and cannot be called
directly in this class (a C<die> will result).

=head2 VCS::File->introduce($version_args) *

C<$version_args> is a hash-ref, see L<VCS::Version> for details.
Implementation classes are expected to use something similar to this
code, to call create_new in the right C<VCS::Version> subclass:

    sub introduce {
        my ($class, $version_args) = @_;
        my $call_class = $class;
        $call_class =~ s/[^:]+$/Version/;
        return $call_class->create_new($version_args);
    }

This is a pure virtual method, which must be over-ridden, and cannot be
called directly in this class (a C<die> will result).

=head2 VCS::File->new($file)

C<$file> is a file name, absolute or relative.  Returns an object
of class C<VCS::File>, or undef if it fails.

=head2 $file->name

Returns the C<$file> argument to C<new>.

=head2 $file->versions

Returns a list of objects of class C<VCS::Version>, in order of ascending
revision number. If it is passed an extra (defined) argument, it only
returns the last version as a C<VCS::Version>.

=head1 SEE ALSO

L<VCS>.

=head1 COPYRIGHT

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
