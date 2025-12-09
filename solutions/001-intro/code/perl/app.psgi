use JSON::RPC::Lite;
use List::Util qw(sum any);
use Scalar::Util qw(looks_like_number);

method 'sum' => sub {
    my @numbers = @{$_[0]};
    die "rpc_invalid_params: items must be numbers" if any { !looks_like_number($_) } @numbers;
    return sum(@numbers);
};
as_psgi_app;
