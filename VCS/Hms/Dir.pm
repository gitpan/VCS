package VCS::Hms::Dir;

use Carp;

@ISA = qw(VCS::Hms);

use strict;

sub new {
    my($proto, $name) = @_;
    my $class = ref($proto) || $proto;

    $name .= '/' if (substr($name, -1, 1) ne '/');
 
    # warn "Creating Dir object $name\n";
    # verify if the HMS directory exists
    my $result = system("fls $name>/dev/null");
    return undef if $result != 0 ; 

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
    my @fll = split("\n",`fll -l $self->{NAME}`);

    my @result = () ;
    foreach (@fll)
      {
        my ($mode,$lock,$size,$month,$date,$h_y,$name,$locked_rev) = 
          split /\s+/;
        if ($mode =~ /^d/) {
            push @result,VCS::Hms::Dir->new($name);
        } else {
            push @result,VCS::Hms::File->new($name);
        }
      }
    return @result;
}

1;
