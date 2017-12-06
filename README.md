# Twilio::Verify::Client #
A client for a limited subset of Twilio's SMS verification API.

## Example Usage ##
```
#!/usr/perl/bin

use strict;
use warnings;

use lib 'lib';

use Data::Dumper;
use Twilio::Verify::Client;

my ($action, $country_code, $phone_number, $verification_code) = @ARGV;
my $res;

die 'No country code provided.' unless $country_code;
die 'No phone number provided.' unless $phone_number;

my $client = Twilio::Verify::Client->new({
  api_key => 'your_api_key'
});

if($action eq 'send') {
  $res = $client->send_verification_code({
    country_code => $country_code,
    phone_number => $phone_number,
    via => 'sms'
  })
}
elsif($action eq 'check') {
  die 'No verification code provided.' unless $verification_code;

  $res = $client->verify_verification_code({
    country_code => $country_code,
    phone_number => $phone_number,
    verification_code => $verification_code
  })
}
else {
  die 'Invalid action.'
}

print Dumper($res);

1
```