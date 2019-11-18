#!/usr/bin/perl
#
# ayehu_alert.pl
# Usage: ayehu_alert --host <LABEL> --mode <GET/POST> alertKey1 "alert value 1" alertKey2 "alert value 2"
#
# Derek Pascarella <derekp@ayehu.com>
# Ayehu, Inc.

# Use strict policy on syntax and data-types.
use strict;

# Our modules.
use HTTP::Tiny;
use Getopt::Long;
use JSON;

# Define usage help.
my $usage = "Usage: ayehu_alert --host <LABEL> --mode <GET/POST> alertKey1 \"alert value 1\" alertKey2 \"alert value 2\"\n";

# Define location of configuration file.
my $config_file = "/etc/ayehu.conf";

# Our variables.
my $url;
my $secret;
my %hosts;
my %key_value;
my @host_info;
my $post_data;
my $http;
my $response;
my $i;

# Our arguments.
my $sid = "0";
my $mode;
my $host;

# Define our parameters and arguments.
GetOptions(
	'host=s' => \$host,
	'mode=s' => \$mode,
	'sid=s' => \$sid
) or die $usage;

# Convert "mode" and "sid" to lowercase.
$mode = lc($mode);
$sid = lc($sid);

# Print usage and exit if insufficient arguments are given.
if(scalar(@ARGV) % 2 != 0 || $host eq "" || ($mode ne "post" && $mode ne "get"))
{
	print $usage;

	exit;
}

# Open configuration file.
open(FH, '<', $config_file) or die $!;

# Read and store information on each host from configuration file.
while(<FH>)
{
	# Skip blank lines and comments.
	next if /^$/;
	next if /^#/;

	# Store each property of the host into a separate element of "host_info".
	chomp;
	@host_info = split(/\|/, $_);

	# If three properties are present, store them in "hosts" hash.
	if(scalar(@host_info) == 3)
	{
		$hosts{$host_info[0]}{url} = $host_info[1];
		$hosts{$host_info[0]}{secret} = $host_info[2];
	}
}

# Close configuration file.
close(FH);

# Add each key-value pair from arguments to "key_value" hash.
for($i = 0; $i <= $#ARGV; $i += 2)
{
	$key_value{$ARGV[$i]} = $ARGV[$i + 1];
}

# Create new "HTTP::Tiny" object.
$http = HTTP::Tiny->new;

# Send "POST" request per value of "mode" parameter.
if($mode eq "post")
{
	# Encode JSON payload.
	$post_data = encode_json {
		root => {
			item => {
				auth => $hosts{$host}{secret},
				sessionid => $sid,
				%key_value
			}
		}
	};

	# Send "POST" request via "http" object.
	$response = $http->post(
		$hosts{$host}{url} => {
			content => $post_data,
			headers => { 'Content-Type' => 'application/json' }
		}
	);

	# Display successful results.
	if($response->{'success'} == 1)
	{
		print "Status:\t\tSuccess\n";
		print "Session ID:\t" . decode_json($response->{'content'})->{'SessionID'} . "\n";
		print "Payload:\t$post_data\n";
	}
	# Display unsuccessful results.
	else
	{
		print "Status:\tFailure\n";
		print "Reason:\t" . $response->{'reason'} . "\n";
	}
}
# Send "GET" request per value of "mode" parameter.
elsif($mode eq "get")
{
	# Send "GET" request via "http" object.
	$response = $http->get(
		$hosts{$host}{url} . "?query=" . $sid => {
			headers => {
				'auth' => $hosts{$host}{secret}
			}
		}
	);

	# Display successful results.
	if($response->{'success'} == 1)
	{
		print "Status:\t\tSuccess\n";
		print "Response:\t" . decode_json($response->{'content'})->{'Response'} . "\n";
	}
	# Display unsuccessful results.
	else
	{
		print "Status:\tFailure\n";
		print "Reason:\t" . $response->{'reason'} . "\n";
	}
}
