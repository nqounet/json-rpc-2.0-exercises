use JSON::RPC::Lite;
use List::Util   qw(sum any);
use Scalar::Util qw(looks_like_number);

method 'subtract' => sub {
    my $params = shift;
    my $minuend;
    my $subtrahend;
    if (ref $params eq 'ARRAY') {
        $minuend    = $params->[0];
        $subtrahend = $params->[1];
    }
    elsif (ref $params eq 'HASH') {
        $minuend    = $params->{minuend};
        $subtrahend = $params->{subtrahend};
    }else{
        die "rpc_invalid_params";
    }
    die "rpc_invalid_params: expected two numbers" unless defined $minuend && defined $subtrahend;
    die "rpc_invalid_params: minuend and subtrahend must be numbers" if any { !looks_like_number($_) } ($minuend, $subtrahend);
    return $minuend - $subtrahend;
};
as_psgi_app;
