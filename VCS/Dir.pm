package VCS::Dir;

my $PREFIX = 'VCS';

sub new {
    my $container_classtype = shift;
    $container_classtype =~ s#^$PREFIX##;
    my ($hostname, $impl_class, $path, $query) = VCS->parse_url(@_);
    VCS->class_load($impl_class);
    my $this_class = "$impl_class$container_classtype";
    return $this_class->new(@_);
}

# assumes no query string
sub init {
    my($class, $url) = @_;
    my ($hostname, $impl_class, $path, $query) = VCS->parse_url($url);
    if (substr($path, -1, 1) ne '/') {
        $path .= '/';
        $url .= '/';
    }
    my $self = {};
    $self->{PATH} = $path;
    $self->{URL} = $url;
    bless $self, $class;
    return $self;
}

sub url {
    my $self = shift;
    $self->{URL};
}

sub content {
}

sub path {
    my $self = shift;
    $self->{PATH};
}

sub read_dir {
    my ($self, $dir) = @_;
    local *DIR;
    opendir DIR, $dir;
    my @d = grep { (!/^\.\.?$/) } readdir DIR;
    closedir DIR;
#warn "d: @d\n";
    @d;
}

1;

__END__

=head1 NAME

VCS::Dir - module for access to a VCS directory

=head1 SYNOPSIS

    use VCS;
    my $d = VCS::Dir->new($url);
    print $d->url . "\n";
    foreach my $x ($d->content) {
        print "\t" . $x->url . "\t" . ref($x) . "\n";
    }

=head1 DESCRIPTION

C<VCS::Dir> abstracts access to a directory under version control.

=head1 METHODS

Methods marked with a "*" are not yet finalised/implemented.

=head2 VCS::Dir-E<gt>create_new($url) *

C<$url> is a file-container URL.  Creates data as
appropriate to convince the VCS that there is a file-container, and
returns an object of class C<VCS::Dir>, or throws an exception if it
fails. This is a pure virtual method, which must be over-ridden, and
cannot be called directly in this class (a C<die> will result).

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

=head2 VCS::Dir-E<gt>new($url)

C<$url> is a file-container URL.  Returns an object of class
C<VCS::Dir>, or throws an exception if it fails. Normally, an override of
this method will call C<VCS::Dir-E<gt>init($url)> to make an object,
and then add to it as appropriate.

=head2 VCS::Dir-E<gt>init($url)

C<$url> is a file-container URL.  Returns an object of class
C<VCS::Dir>. This method calls C<VCS-E<gt>parse_url> to make sense of
the URL.

=head2 $dir-E<gt>url

Returns the C<$url> argument to C<new>.

=head2 $dir-E<gt>content

Returns a list of objects, either of class C<VCS::Dir> or
C<VCS::File>, corresponding to files and directories within this
directory.

=head2 $dir-E<gt>path

Returns the absolute path of the directory.

=head2 $dir-E<gt>read_dir($dir)

Returns the contents of the given filesystem directory. This is intended
as a utility method for subclasses.

=head1 SEE ALSO

L<VCS>.

=head1 COPYRIGHT

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
