package VCS::Cvs::Dir;

use Carp;
use VCS::Cvs;

@ISA = qw(VCS::Cvs);

use strict;

sub new {
    my($proto, $name) = @_;
    my $class = ref($proto) || $proto;
    return undef unless (-d $name);
    $name .= '/' if (substr($name, -1, 1) ne '/');
    return undef unless (-d $name . 'CVS');
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
    my($entry, $type, $path, $obj, @return);
    open(CONTENTS, $self->name . 'CVS/Entries');
    while (defined($entry = <CONTENTS>)) {
	($type, $path) = $entry =~ m|^([^/]*)/([^/]*)/|;
	$path = $self->name . $path;
	$obj = ($type eq 'D') ? VCS::Cvs::Dir->new($path) 
                              : VCS::Cvs::File->new($path);
	push @return, $obj if $obj;	    
    }
    close CONTENTS;
    return sort {$a->name cmp $b->name} @return;
}

1;
