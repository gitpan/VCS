#!perl
use strict;
use Test::More tests => 24;
use Cwd;

BEGIN { use_ok( 'VCS' ) }

require Data::Dumper;
my @segments = VCS->parse_url('vcs://localhost/VCS::Cvs/file/path/?query=1');

my $dd=<<'EOF';
$VAR1 = [
          'localhost',
          'VCS::Cvs',
          '/file/path/',
          'query=1'
        ];
EOF
is(Data::Dumper::Dumper(\@segments),$dd,'Parse URL');


my $td = "/tmp/vcstestdir.$$";
test_rcs($td);
test_cvs($td);


sub test_cvs {
    my ($td) = @_;
    my $distribution = cwd;
    my $repository = "$td/repository";
    my $sandbox = "$td/sandbox";
    my $base_url = "vcs://localhost/VCS::Cvs$sandbox/td";
    $ENV{CVSROOT} = $repository;
    system <<EOF;
mkdir -p $sandbox || exit 1
mkdir -p $repository || exit 1
cvs init
cd $repository
cp -R $distribution/t/cvs_testfiles/* .
cd $sandbox
cvs -Q co td
cd td/dir
cvs -Q tag mytag1 file
cvs -Q tag mytag2 file
cd ../..
EOF

    my $f = VCS::File->new("$base_url/dir/file");
    ok(defined $f,'VCS::File->new');

    my $h = $f->tags();
    is($h->{mytag1},'1.2','file tags 1');
    is($h->{mytag2},'1.2','file tags 2');

    my @versions = $f->versions;
    ok(scalar(@versions),'versions');
    my ($old, $new) = @versions;
    is($old->version(),'1.1','old version');
    is($new->version(),'1.2','new version');
    is($new->date(),'2001/11/13 04:10:29','date');
    is($new->author(),'user','author');

    my $d = VCS::Dir->new("$base_url/dir");
    ok (defined($d),'Dir');

    my @c = $d->content;
    is(scalar(@c),1,'content');
    is($c[0]->url(),"$base_url/dir/file",'cotent url');

    system <<EOF;
[ -d $td ] && rm -rf $td
EOF
}

# inputs: test directory, next test number to output
sub test_rcs {
    my ($td) = @_;
    my $distribution = cwd;
    my $base_url = "vcs://localhost/VCS::Rcs$td";
    system <<EOF;
mkdir $td || exit 1
cd $td
cp -R $distribution/t/rcs_testfiles/* .
cd dir
rcs -q -nmytag1: file
rcs -q -nmytag2: file
EOF

    my $f = VCS::File->new("$base_url/dir/file");
    ok(defined $f,'VCS::File->new');

    my $h = $f->tags();
    is($h->{mytag1},'1.2','file tags 1');
    is($h->{mytag2},'1.2','file tags 2');

    my @versions = $f->versions;
    ok(scalar(@versions),'versions');
    my ($old, $new) = @versions;
    is($old->version(),'1.1','old version');
    is($new->version(),'1.2','new version');
    is($new->date(),'2001/11/13 04:10:29','date');
    is($new->author(),'user','author');

    my $d = VCS::Dir->new("$base_url/dir");
    ok (defined($d),'Dir');

    my @c = $d->content;
    is(scalar(@c),1,'content');
    is($c[0]->url(),"$base_url/dir/file",'cotent url');

    system <<EOF;
[ -d $td ] && rm -rf $td
EOF
}

