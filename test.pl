#!perl
use strict;
use Test::More tests => 24;

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
    my $tf = "/tmp/vcstestarc.$$.uue";
    my $repository = "$td/repository";
    my $sandbox = "$td/sandbox";
    my $base_url = "vcs://localhost/VCS::Cvs$sandbox/td";
    to_file($tf, <<'EOF');
begin 644 vcstest-cvs.tgz
M'XL(`$CR03T``^W2RVK#,!`%4&^MKQ!T6QR-X\:TVGC313]#D=5&Q(\B*2;]
M^X[24,BBH9M0"O=@+-FZC,:/U*]Z'U:O?G#W2W$;BI1JFJ90K-U<CEFS61>J
M?:C5NN5<R_F:5%M(=:-^+AQB,D%*'EVXGKN^_D_MG.E+JFHMC+4N1BWBQ[B=
M!YX,L]U'4>8'?\H)&5/P-FEAYW%T4RJ[.]EI(00OBMXD5]9*445\K"O55*2J
M^E&7YI!V<Y"YC"[Y92<GGX_O6FR#F>S.\4:3.R;N@70N13^4(OIUJ=Q3[Z(5
M7?ZM17=N<9C?1+?4?)TX=9Y^;7E:>IE\\F:0P2T^^GGZ#O8D29A\6HAO_O4G
=`P``````````````````````./D$&"TW%P`H````
`
end
EOF
    $ENV{CVSROOT} = $repository;
    system <<EOF;
mkdir -p $sandbox || exit 1
mkdir -p $repository || exit 1
cvs init
cd $repository
uudecode -o /dev/stdout $tf | tar zxf -
rm $tf
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
    my ($td, $test_num) = @_;
    my $base_url = "vcs://localhost/VCS::Rcs$td";
    my $tf = "/tmp/vcstestarc.$$.uue";
    to_file($tf, <<'EOF');
begin 644 vcstest.tgz
M'XL(`&"H\#L"`^W5P4Z$,!`&8*[T*9IX-3@#+$1[(3$>O.H3=*&Z1!8,[9+U
M[6W7C<:#1`]L-/Y?"&WHI!0&IDT[7D0+(\JI7*U\2U06^:?V**(R*W/F(B]]
MGRDKRTBNHA/86:='*7UKQOFX^?$_JO'Y?V@[LVC^F:C(\YG\9Q_Y+WR?.<TX
MDH3\+VY*103_5_C_[Z[O%]T#?E[_F=("]?^4^0][P/FT7/W/9^K_H>9_RG_*
M&:'^G\+&Z";F)%5"U[6Q5@G[LET/G>]T0_UD11P>_"I$2.O&MG9*U,-V:WH7
M5V>R4D((/R@:[4R<$G'"_L@2RA.F)+U4L=ZYS3#*,(V*_<MV1M[LGY58C[JO
M-\;?J#=[Y]?`*DS%7TS%_.VIPIH:8VM1A:]:5,<E=L.CJ/Q^5PGGHX[=MUL>
MAF[[UK6ZDZ.96ML._7M@PY*%#J>)_45L&@````````````````#P*[T".#CT
%#``H````
`
end
EOF
    system <<EOF;
mkdir $td || exit 1
cd $td
uudecode -o /dev/stdout $tf | tar zxf -
rm $tf
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

sub to_file {
    my ($file, $data) = @_;
    local *FH;
    open FH, ">$file" or die;
    print FH $data;
}
