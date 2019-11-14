#!/usr/bin/perl
#
# ayehu_alert.pl
# Usage: ayehu_alert.pl alertKey1 "alertValue1" alertKey2 "alertValue2"
#
# Derek Pascarella <derekp@ayehu.com>
# Ayehu, Inc.
#
# Send data to Ayehu NG via the Web Service API.  Modify the "url" and
# "secret" variables to match your Web Service module's configuration.  This
# script is a useful way to send an HTTP POST request to an Ayehu NG server
# with a convenient wrapper that's executable at the command-line in a Linux
# or UNIX environment.
#
# The only requirements are the "JSON" and "HTTP::Tiny" Perl libraries.  This
# script can also be used on Windows using the Strawberry Perl distribution
# (http://strawberryperl.com/) and executed at the Windows command prompt as
# follows:
# > perl C:\folder\ayehu_alert.pl "alertValue1" alertKey2 "alertValue2"
#
# Sample output (success):
# Status:         Success
# URL:            http://localhost:8200/AyehuAPI/
# Password:       my_secret_password
# Session ID:     80efa8eb-320b-415d-be6d-2f7dca18a84c
# Payload:        {"root":{"item":{"auth":"my_secret_password","name":"Derek","location":"NYC","sessionid":"0"}}}
#
# Sample output (failure, incorrect endpoint URL given):
# Status: Failure
# Reason: Temporary Redirect
#
# Sample output (failure, incorrect secret phrase given):
# Status: Failure
# Reason: Unauthorized

# Use strict policy on syntax and data-types.
use strict;

# Our modules.
use HTTP::Tiny;
use JSON;

# Our variables.
my $url = "http://localhost:8200/AyehuAPI/";
my $secret = "my_secret_password";
my %key_value;
my $i;

# If at least one key-value pair wasn't given, display an error.
if(scalar(@ARGV) < 2)
{
	print "At least one key-value pair must be given.\n";
	print "Usage: ayehu_alert.pl alertKey1 \"alertValue1\" alertKey2 \"alertValue2\"\n";

	exit;
}
elsif(scalar(@ARGV) % 2 != 0)
{
	print "One or more key(s) have been given without a corresponding value.\n";
	print "Usage: ayehu_alert.pl alertKey1 \"alertValue1\" alertKey2 \"alertValue2\"\n";

	exit;
}
# Otherwise, proceed in adding each key-value pair to our hash.
else
{
	for($i = 0; $i <= $#ARGV; $i += 2)
	{
		$key_value{$ARGV[$i]} = $ARGV[$i + 1];
	}
}

# Encode JSON payload.
my $data = encode_json {
	root => {
		item => {
			auth => $secret,
			sessionid => "0",
			%key_value
		}
	}
};

# Create new "HTTP:Tiny" object.
my $http = HTTP::Tiny->new;

# Send POST request via "http" object.
my $response = $http->post($url => {
	content => $data,
	headers => {'Content-Type' => 'application/json'}
	});

# Display successful results.
if($response->{'success'} == 1)
{
	print "Status:\t\tSuccess\n";
	print "URL:\t\t$url\n";
	print "Secret:\t\t$secret\n";
	print "Session ID:\t" . decode_json($response->{'content'})->{'SessionID'} . "\n";
	print "Payload:\t$data\n";
}
# Display unsuccessful results.
else
{
	print "Status:\tFailure\n";
	print "Reason:\t" . $response->{'reason'} . "\n";
}
