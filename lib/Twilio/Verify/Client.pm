package Twilio::Verify::Client;

use strict;
use warnings;

use URI::Escape;
use JSON::MaybeXS;
use Carp qw(croak);
use LWP::UserAgent;
use HTTP::Request::Common qw(GET POST DELETE);

our $api_base_uri = 'https://api.authy.com/protected/json/phones/verification';

sub new {
  my ($class, $args) = @_;

  croak "Missing api key." unless $$args{api_key};

  my $attribs = { %$args };

  my $self = bless {}, $class;

  $$self{attribs} = $attribs;
  $$self{ua} = LWP::UserAgent->new;

  return $self
}

sub send_verification_code {
  my ($self, $args) = @_;

  croak "Missing via." unless $$args{via};
  croak "Missing country code." unless $$args{country_code};
  croak "Missing phone number." unless $$args{phone_number};

  $$args{api_key} = $$self{attribs}->{api_key};

  my $req = POST "$api_base_uri/start", $args;
  my ($res_json, $res_obj) = $self->send_request($req, { decode_json => 1 });

  return $res_json
}

sub verify_verification_code {
  my ($self, $args) = @_;

  croak "Missing country code." unless $$args{country_code};
  croak "Missing phone number." unless $$args{phone_number};
  croak "Missing verification code." unless $$args{verification_code};

  $$args{api_key} = $$self{attribs}->{api_key};

  my $req = GET "$api_base_uri/check?" . $self->make_query_string($args);
  my ($res_json, $res_obj) = $self->send_request($req, { decode_json => 1 });

  return $res_json
}

sub make_query_string {
  my ($self, $arguments) = @_;

  if(ref $arguments eq 'HASH') {
    my @pairs;

    foreach my $key (keys %{$arguments}) {
      push @pairs, uri_escape($key) . '=' . uri_escape($$arguments{$key})
    }

    return join '&', @pairs
  }
}

sub send_request {
  my ($self, $req, $args) = @_;

  $args = ref $args eq 'HASH' ? $args : {};

  $req->header('Authorization', "Bearer $$args{bearer_token}")
    if $$args{bearer_token};

  my $res = $self->{ua}->request($req);

  if($res->is_success) {
    return decode_json($res->decoded_content), $res if $$args{decode_json};
    return $res->decoded_content, $res
  }

  croak $res->decoded_content
}

1;