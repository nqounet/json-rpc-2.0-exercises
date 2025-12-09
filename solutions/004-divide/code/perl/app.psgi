use JSON::RPC::Lite;
use Scalar::Util qw(looks_like_number);
use List::Util qw(any);

method 'divide' => sub {
    my $params = shift;
    my ($dividend, $divisor);
    if (ref $params eq 'ARRAY') {
        $dividend = $params->[0];
        $divisor  = $params->[1];
    }
    elsif (ref $params eq 'HASH') {
        $dividend = $params->{dividend};
        $divisor  = $params->{divisor};
    }
    else {
        die "rpc_invalid_params";
    }

    die "rpc_invalid_params: expected two numbers" unless defined $dividend && defined $divisor;
    die "rpc_invalid_params: dividend and divisor must be numbers" if any { !looks_like_number($_) } ($dividend, $divisor);
    die "rpc_invalid_params: division by zero" if $divisor == 0;

    # perform division (allow float)
    my $res = $dividend / $divisor;
    return $res;
};

as_psgi_app;
