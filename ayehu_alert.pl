#!/usr/bin/perl
#
# ayehu_alert.pl
# Usage: ayehu_alert --host <LABEL> --mode <GET/POST> --sid <SESSION_ID> alertKey1 "alert value 1" alertKey2 "alert value 2"
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
my $usage = "Usage: ayehu_alert --host <LABEL> --mode <GET/POST> --sid <SESSION_ID> alertKey1 \"alert value 1\" alertKey2 \"alert value 2\"\n";

# Define location of configuration file.
my $config_file = "/etc/ayehu.conf";

# Our variables.
my $i;
my $url;
my $http;
my $secret;
my $response;
my $post_data;
my %hosts;
my %key_value;
my @host_info;

# Our arguments.
my $sid = "0";
my $mode;
my $host;

# Define our parameters and arguments.
GetOptions(
	'host=s' => \$host,
	'mode=s' => \$mode,
	'sid=s' => \$sid
);

# Convert "mode" and "sid" to lowercase.
$mode = lc($mode);
$sid = lc($sid);

# Print usage and exit if no host label is given.
if($host eq "")
{
	&error_message("host");
}

# Print usage and exit if no valid HTTP mode is given.
if($mode ne "post" && $mode ne "get")
{
	&error_message("mode");
}

# Print usage and exit if invalid session ID is given.
if($sid != 0 && length($sid) != 36)
{
	&error_message("sid");
}

# Print usage and exit if an odd number of key-value pairs is given for a "POST" request.
if($mode eq "post" && (scalar(@ARGV) % 2 != 0 || scalar(@ARGV) == 0))
{
	&error_message("keyvalue");
}

# Open configuration file.
open(FH, '<', $config_file) or die $!;

# Read file to find settings for specified target host.
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
		# Remove trailing and leading whitespace from each element of "host_info".
		foreach(@host_info)
		{
			$_ =~ s/^\s+|\s+$//;
		}

		# Current configuration entry matches "host" so store hash key with URL and secret.
		if($host_info[0] eq $host)
		{
			$hosts{$host_info[0]}{url} = $host_info[1];
			$hosts{$host_info[0]}{secret} = $host_info[2];
		}
	}
}

# Close configuration file.
close(FH);

# Print usage and exit if no suitable host setting found in configuration file.
if(keys %hosts == 0)
{
	&error_message("config");
}

# Add each key-value pair from arguments to "key_value" hash.
for($i = 0; $i < scalar(@ARGV); $i += 2)
{
	$key_value{$ARGV[$i]} = $ARGV[$i + 1];
}

# Create new "HTTP::Tiny" object.
$http = HTTP::Tiny->new;

# Send "POST" request per value of "mode" parameter.
if($mode eq "post")
{
	# Build and encode JSON payload.
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
}

# Print response results.
&response_message($response->{'success'}, $mode);

# Our "error_message" subroutine prints specific usage errors and exits.
sub error_message
{
	if($_[0] eq "keyvalue")
	{
		print "One or more key(s) missing a value!\n";
	}
	elsif($_[0] eq "host")
	{
		print "Target host missing!\n";
	}
	elsif($_[0] eq "mode")
	{
		print "Invalid or missing mode!\n";
	}
	elsif($_[0] eq "sid")
	{
		print "Invalid session ID!\n";
	}
	elsif($_[0] eq "config")
	{
		print "No configuration found in $config_file for \"$host\".\n";
	}

	print $usage;

	exit;
}

# Our "response_message" subroutine prints the response details of the request.
sub response_message
{
	# The request was successful.
	if($_[0])
	{
		# Begin success message.
		print "Status:\t\tSuccess\n";

		# Print successful "POST" results.
		if($_[1] eq "post")
		{
			print "Session ID:\t" . decode_json($response->{'content'})->{'SessionID'} . "\n";
			print "Payload:\t$post_data\n";
		}
		# Print successful "GET" results.
		elsif($_[1] eq "get")
		{
			print "Response:\t" . decode_json($response->{'content'})->{'Response'} . "\n";
		}
	}
	# The response failed.
	else
	{
		# Print failed "POST" results.
		print "Status:\tFailure\n";
		print "Reason:\t" . $response->{'reason'} . "\n";
	}
}
