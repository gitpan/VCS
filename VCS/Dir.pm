package VCS::Dir;

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

sub content {
}

1;

__END__

=head1 NAME

VCS::Dir - module for access to a VCS directory

=head1 SYNOPSIS

    use VCS;
    my $d = VCS::Dir->new($dir);
    print $d->name . "\n";
    foreach my $x ($d->content) {
        print "\t" . $x->name . "\t" . ref($x) . "\n";
    }

=head1 DESCRIPTION

C<VCS::Dir> abstracts access to a directory under version control.

=head1 METHODS

Methods marked with a "*" are not yet finalised/implemented.

=head2 VCS::Dir-E<gt>create_new($dir) *

C<$dir> is a directory name, absolute or relative.  Creates data as
appropriate to convince the VCS that there is a file-container, and
returns an object of class C<VCS::Dir>, or undef if it fails. This is a
pure virtual method, which must be over-ridden, and cannot be called
directly in this class (a C<die> will result).

=head2 VCS::Dir-E<gt>introduce($name, $create_class) *

C<$name> is a file or directory name, absolute or relative.
C<$create_class> is either C<File> or C<Dir>, and implementation
classes are expected to use something similar to this code, to call the
appropriate create_new:

    sub introduce {
        my ($class, $name, $create_class) = @_;
        my $call_class = $class;
        $call_class =~ s/[^:]+$/$create_class/;
        return $call_class->create_new($name);
    }

This is a pure virtual method, which must be over-ridden, and cannot be
called directly in this class (a C<die> will result).

=head2 VCS::Dir-E<gt>new($dir)

C<$dir> is a directory name, absolute or relative.  Returns an object
of class C<VCS::Dir>, or undef if it fails.

=head2 $dir-E<gt>name

Returns the C<$dir> argument to C<new>.

=head2 $dir-E<gt>content

Returns a list of objects, either of class C<VCS::Dir> or
C<VCS::File>, corresponding to files and directories within this
directory.

=head1 SEE ALSO

L<VCS>.

=head1 COPYRIGHT

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
