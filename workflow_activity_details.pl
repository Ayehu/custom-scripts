#!/usr/bin/perl
#
# workflow_activity_details.pl
# Usage: workflow_activity_details.pl <workflow_file.xml>
# 
# Derek Pascarella <derekp@ayehu.com>
# Ayehu, Inc.
#
# Display details of all activities in a given Workflow XML file, including the Workflow name, total number of activities, name of
# each activity and its type, as well as a list of activities that were given a duplicate name erroneously, which can occur during
# migration from EyeShare.
#
# The full file path should be passed to this script as an argument.
#
# This script can be executed on Windows using the Strawberry Perl distribution (http://strawberryperl.com/) and executed at the
# Windows command prompt as follows:
# > perl C:\full\path\to\workflow_activity_details.pl C:\full\path\to\Workflow.xml
#
# For Windows users, note that a shortcut can be created with the path "perl C:\full\path\to\workflow_activity_details.pl", after which
# Workflow XML files can be dragged from the file explorer directly onto the shortcut.  This would launch a command prompt window and
# display the activity count results.
#
# Windows users may also create a shortcut in their local "SendTo" folder (foud at "C:\Users\<user>\AppData\Roaming\Microsoft\Windows
# \SendTo") which contains a target path of "perl C:\full\path\to\workflow_activity_details.pl".  Once created, one can right-click
# on a Workflow XML file, navigate to the "Send To" menu and select the newly created shortcut.  This would launch a command prompt
# window and display the activity count results.
#
# If utilizing either of these shortcut methods, simply uncomment the last line of this script.
#
# Sample output:
# Workflow file: C:\Some\Folder\My Example Workflow.xml
# Workflow name: My Example Workflow
#
# Total activities: 5
# cmd_list_proc (SendSSHCommand)
# ssh_connect (StartSSHSession)
# ssh_disconnect (TerminateSSHSession)
# table_list_proc (ConvertTextToTable)
# table_list_proc (ConvertTextToTable)
#
# Duplicate Activities:
# table_list_proc (ConvertTextToTable, 2 occurrences)

# Our modules.
use strict;

# Our variables.
my $i;
my $workflow_file = $ARGV[0];
my $workflow_xml;
my $workflow_name;
my $activity_name;
my $activity_type;
my $activity_count_total;
my $activity_name_individual;
my $duplicates_found = 0;
my @split_workflow_name;
my @split_activity_name;
my @split_activity_type;
my %activities;
my %activities_type;

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
@split_workflow_name = split(/x:Name=&quot;/, $workflow_xml);
$workflow_name = $workflow_xml;
$workflow_name =~ s/^[^Name=\"]*Name=\"//;
$workflow_name =~ s/\" Description.*//;
$workflow_name =~ s/^\s+|\s+$//g;

# Create array containing data before and after "x:Name=&quot;".
@split_activity_name = split(/x:Name=&quot;/, $workflow_xml);

# Iterate through each element of "split_activity_name".
for($i = 1; $i <= $#split_activity_name; $i ++)
{
	# Parse out activity name and type.
	$activity_name = $split_activity_name[$i];
	@split_activity_type = split(/name=&quot;/, $activity_name);
	$activity_type = $split_activity_type[1];
	$activity_type =~ s/\&quot\;.*//;
	$activity_type =~ s/^\s+|\s+$//g;

	# If activity type could not be parsed, keep looking.
	if($activity_type eq "")
	{
		@split_activity_type = split(/TypeName=&quot;/, $activity_name);
		$activity_type = $split_activity_type[1];
		$activity_type =~ s/\&quot\;.*//;
		$activity_type =~ s/^\s+|\s+$//g;

		# If activity type could not be parsed, keep looking.
		if($activity_type eq "")
		{
			@split_activity_type = split(/label=&quot;/, $activity_name);
			$activity_type = $split_activity_type[1];
			$activity_type =~ s/\&quot\;.*//;
			$activity_type =~ s/^\s+|\s+$//g;
		}
	}

	# If the activity type is still unknown, default to "ReturnValue", as this particular activity's tag order is to blame.
	if($activity_type eq "")
	{
		$activity_type = "ReturnValue";
	}

	# Finish parsing out activity name and type.
	$activity_name =~ s/\&quot\;.*//;
	$activity_name =~ s/^\s+|\s+$//g;

	# Skip "CustomWorkflow", as its not actually an activity.
	if($activity_name ne "CustomWorkflow")
	{
		# Increase activity count by one (1) if occurence already recorded previously.
		if($activities{$activity_name} >= 1)
		{
			$activities{$activity_name} += $activities{$activity_name};
		}
		# Otherwise, set activity count to one (1).
		else
		{
			$activities{$activity_name} = 1;
		}

		# Store "activity_type" as a value for the "activity_name" key in the "activities_type" hash.
		$activities_type{$activity_name} = $activity_type;
	}
}

# Count the number of instances "pattern" is found in the Workflow XML.
$activity_count_total = (() = $workflow_xml =~ /x:Name=&quot;/gi) - 1;

# Print results.
print "Workflow file: $workflow_file\n";
print "Workflow name: $workflow_name\n\n";
print "Total activities: $activity_count_total\n";

# Iterate through "activities" hash and print number of occurrences for each activity.
foreach $activity_name_individual (sort {lc $a cmp lc $b} keys %activities)
{
	print "$activity_name_individual (" . $activities_type{$activity_name_individual} . ")\n";
}

# Continue results.
print "\nDuplicate Activities:\n";

# Iterate through "activities" hash and print number of occurrences for each activity with a duplicate name.
foreach $activity_name_individual (keys %activities)
{
	if($activities{$activity_name_individual} > 1)
	{
		print "$activity_name_individual ("
		. $activities_type{$activity_name_individual} . ", "
		. $activities{$activity_name_individual} . " occurrences)\n";

		$duplicates_found = 1;
	}
}

# No duplicate activity names were found.
if($duplicates_found == 0)
{
	print "<NONE>\n";
}

# Uncomment the next line if using the shortcut method on Windows to ensure command prompt doesn't disappear after this script has
# finished executing.
#<STDIN>;
