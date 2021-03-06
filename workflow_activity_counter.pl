#!/usr/bin/perl
#
# workflow_activity_counter.pl
# Usage: workflow_activity_counter.pl <workflow_file.xml>
# 
# Derek Pascarella <derekp@ayehu.com>
# Ayehu, Inc.
#
# Count the number of activities in a given Workflow XML file.  The full file
# path should be passed to this script as an argument.
#
# This script can be executed on Windows using the Strawberry Perl distribution
# (http://strawberryperl.com/) and executed at the Windows command prompt as
# follows:
# > perl C:\folder\workflow_activity_counter.pl C:\folder\Workflow.xml
#
# For Windows users, note that a shortcut can be created with the path
# "perl C:\folder\workflow_activity_counter.pl", after which Workflow XML files
# can be dragged from the file explorer directly onto the shortcut.  This would
# launch a command prompt window and display the activity count results.
#
# Windows users may also create a shortcut in their local "SendTo" folder (foud
# at "C:\Users\<user>\AppData\Roaming\Microsoft\Windows\SendTo") which contains
# a target path of "perl C:\full\path\to\workflow_activity_counter.pl".  Once
# created, one can right-click on a Workflow XML file, navigate to the
# "Send To" menu and select the newly created shortcut.  This would launch a
# command prompt window and display the activity count results.
#
# If utilizing either of these shortcut methods, simply uncomment the last line
# of this script.
#
# Sample output:
#    Workflow file: C:\Workflows\SSH - Linux - Service Status.xml
#    Workflow name: SSH - Linux - Service Status
# Total activities: 4

# Our modules.
use strict;

# Our variables.
my $count = 0;
my $workflow_file = $ARGV[0];
my $workflow_xml;
my $workflow_name;

# Open Workflow XML file or print error if not found.
open(FH, '<', $workflow_file) or die $!;

# Iterate through each line of the file until the Workflow XML is found.
while(<FH>)
{
	if(grep/\<WorkflowInfo/, $_)
	{
		# Store current line of file in "workflow_xml".
		$workflow_xml = $_;
	}
}

# Close Workflow XML file.
close(FH);

# Extract the Workflow's name from the XML.
$workflow_name = $workflow_xml;
$workflow_name =~ s/^[^Name=\"]*Name=\"//;
$workflow_name =~ s/\" Description.*//;
$workflow_name =~ s/^\s+|\s+$//g;

# Count the number of instances "x:Name=&quot;" is found in the Workflow XML.
$count = (() = $workflow_xml =~ /x:Name=&quot;/gi) - 1;

# Print results.
print "   Workflow file: $workflow_file\n";
print "   Workflow name: $workflow_name\n";
print "Total activities: $count\n";

# Uncomment the next line if using the shortcut method on Windows to ensure
# command prompt doesn't disappear after this script has finished executing.
#<STDIN>;
