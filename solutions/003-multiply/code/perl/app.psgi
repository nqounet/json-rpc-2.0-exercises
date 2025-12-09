use JSON::RPC::Lite;
use List::Util qw(reduce any);
use Scalar::Util qw(looks_like_number);

method 'multiply' => sub {
    my $params = $_[0];
    my @numbers;
    if (ref $params eq 'ARRAY') {
        @numbers = @{ $params };
    } elsif (ref $params eq 'HASH') {
        if (exists $params->{values} && ref $params->{values} eq 'ARRAY') {
            @numbers = @{ $params->{values} };
        } else {
            die "rpc_invalid_params: at least one number required";
        }
    } else {
        die "rpc_invalid_params: at least one number required";
    }
    die "rpc_invalid_params: at least one number required" unless @numbers;
    die "rpc_invalid_params: items must be numbers" if any { !looks_like_number($_) } @numbers;
    my $prod = reduce { $a * $b } 1, @numbers;
    return $prod;
};
as_psgi_app;
