use strict;
use warnings;
 
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

use JSON;
 
my $ua = LWP::UserAgent->new(timeout => 10);
$ua->env_proxy;
 
# my $response = $ua->get('http://192.168.224.132/data');
# my $reply = $ua->post("http://192.168.224.132/reply", Content => "Hello World");
 

# Set up the server address
my $url = 'http://192.168.224.132/';

# Create the JSON data
my %data = (
    sensor => "Hi",
    value1 => 24.5,
    value2 => 45.3
);

# Convert Perl hash to JSON string
my $json_data = encode_json(\%data);

# Create the HTTP POST request
my $request = POST($url,
    'Content-Type' => 'application/json',
    Content        => $json_data
);


# Send the request and get the response
my $response = $ua->request($request);



if ($response->is_success) {
    print $response->decoded_content;
}
else {
    die $response->status_line;
}