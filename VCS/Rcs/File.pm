package VCS::Rcs::File;

@ISA = qw(VCS::Rcs);

use File::Basename;

sub new {
#warn "CALL @_\n";
    my ($class, $name) = @_;
    return unless -f $name;
    return unless -d dirname($name) . '/RCS' or -f "$name,v";
    my $self = {};
    $self->{NAME} = $name; # The name of the directory
    bless $self, $class;
    return unless $self->_split_log;
    return $self;
}

sub name {
    my $self = shift;
    $self->{NAME};
}

sub versions {
    my($self, $lastflag) = @_;
    my @rq_version = @_;
    my ($header, @log_revs) = $self->_split_log;
    my $header_info = $self->_parse_log_header($header);
    my $last_rev = $header_info->{'head'};
#warn "last_rev: $last_rev\n";
    my ($rev_head, $rev_tail) = ($last_rev =~ /(.*)\.(\d+)$/);
    return VCS::Rcs::Version->new($self->{NAME}, "$rev_head.$rev_tail")
        if defined $lastflag;
    map {
        VCS::Rcs::Version->new($self->{NAME}, "$rev_head.$_")
    } (1..$rev_tail);
}

1;
