#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";
use VCS;
use Getopt::Long;
use File::Basename;

my $opt_recurse = 0;
GetOptions('recurse' => \$opt_recurse);

my $dir = $ARGV[0] || die <<EOF;
Usage: $0 dir
    or $0 -recurse dir
EOF

chdir dirname $dir;
$dir = basename $dir;

show($dir, 0);

sub show {
    my($dir, $depth) = @_;
#warn "show: $dir, $depth\n";
    my $d = VCS::Dir->new($dir);
#warn "got: $d\n";
    disp($d, $depth);
    foreach my $x ($d->content) {
        if ($opt_recurse && (ref($x) =~ /::Dir$/)) {
            show($x->name, $depth+1);
        } else {
            disp($x, $depth+1);
        }
    }
}

sub disp {
    my ($obj, $depth) = @_;
    print
        "\t" x $depth,
        $obj->name,
        "\t",
        ref($obj),
        "\n",
        ;
}
