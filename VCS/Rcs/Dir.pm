package VCS::Rcs::Dir;

use Carp;

@ISA = qw(VCS::Rcs);

use strict;

sub new {
    my($proto, $name) = @_;
    my $class = ref($proto) || $proto;
    return undef unless (-d $name);
    $name .= '/' if (substr($name, -1, 1) ne '/');
    return undef unless -d $name . 'RCS' or glob "$name*,v";
    my $self = {};
    $self->{NAME} = $name; # The name of the directory
    bless $self, $class;
    return $self;
}

sub name {
    my $self = shift;
    $self->{NAME};
}

sub content {
    my $self = shift;
    opendir(DIR, $self->name);
    my @return = grep {
        (!/^\./) && (!/^RCS$/) && (-f $self->name . $_ || -d  $self->name . $_)
    } sort readdir(DIR);
    @return = map {
        my $name = $self->name . $_;
        if (-d $name) {
            VCS::Rcs::Dir->new($name)
        } else {
            VCS::Rcs::File->new($name)
        }
    } @return;
    closedir DIR;
    return @return;
}

1;
