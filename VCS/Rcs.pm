package VCS::Rcs;

use strict;
use vars qw($VERSION);
use VCS::Rcs::Dir;
use VCS::Rcs::File;
use VCS::Rcs::Version;

$VERSION = '0.01';

my $LOG_CMD = "rlog";

my %LOG_CACHE;

sub _boiler_plate_info {
    my ($self, $what) = @_;
    my ($header, $log) = $self->_split_log($self->{VERSION});
    my $rev_info = $self->_parse_log_rev($log);
    $rev_info->{$what};
}

sub _split_log {
    my ($self, $version) = @_;
    my $log_text;
    $version = "" unless defined $version;
    my $cache_id = $self->name . '/' . $version;
    unless (defined($log_text = $LOG_CACHE{$cache_id})) {
        my $cmd =
            $LOG_CMD .
            (defined $version ? " -r$version" : '') .
            " $self->{NAME} |";
        $LOG_CACHE{$cache_id} = $log_text = $self->_read_pipe($cmd);
    }
    my @sections = split /\n[=\-]+\n/, $log_text;
#map { print "SEC: $_\n" } @sections;
    @sections;
}

sub _parse_log_rev {
    my ($self, $text) = @_;
    my ($rev_line, $blurb, @reason) = split /\n/, $text;
    my %info = map {
        split /:\s+/
    } split /;\s*/, $blurb;
    my ($junk, $rev) = split /\s+/, $rev_line;
    $info{'revision'} = $rev;
    $info{'reason'} = \@reason;
#print "REASON: @reason\n";
#map { print "$_ => $info{$_}\n" } keys %info;
    \%info;
}

sub _parse_log_header {
    my ($self, $text) = @_;
    my @parts = $text =~ /^(\S.*?)(?=^\S|\Z)/gms;
    chomp @parts;
#map { print "PART: $_\n" } @parts;
    my %info = map {
        split /:\s*/, $_, 2
    } @parts;
#map { print "$_ => $info{$_}\n" } keys %info;
    \%info;
}

sub _read_pipe {
    my ($self, $cmd) = @_;
    local *PIPE;
    open PIPE, $cmd;
    local $/ = undef;
    my $contents = <PIPE>;
    close PIPE;
    return $contents;
}

1;
