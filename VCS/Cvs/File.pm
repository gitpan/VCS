package VCS::Cvs::File;

@ISA = qw(VCS::Cvs VCS::File);

use VCS::Cvs;
use Carp;
use File::Basename;

use strict;

sub new {
    my ($class, $url) = @_;
    my $self = $class->init($url);
    my $path = $self->path;
    die "$class->new: $path: $!\n" unless -f $path;
    die "$class->new: $path not in a CVS directory: $!\n"
        unless -d dirname($path) . '/CVS';
    die "$class->new: $path failed to split log\n"
        unless $self->_split_log;
    $self;
}

# evil assumption - no query strings on URL!
sub versions {
    my($self, $lastflag) = @_;
    my @rq_version = @_;
    my ($header, @log_revs) = $self->_split_log;
    my $header_info = $self->_parse_log_header($header);
    my $last_rev = $header_info->{'head'};
    my ($rev_head, $rev_tail) = ($last_rev =~ /(.*)\.(\d+)$/);
    return VCS::Cvs::Version->new("$self->{URL}/$rev_head.$rev_tail")
        if defined $lastflag;
    map {
        VCS::Cvs::Version->new("$self->{URL}/$rev_head.$_")
    } (1..$rev_tail);
}

1;
