#!/usr/bin/perl
#
# minimize_workflow.pl
#
# Utility to remove all metadata and objects associated with a
# Resolve Actions Express workflow, leaving only the base XML
# in-tact.
#
# Written by Derek Pascarella

# Include modules.
use strict;
use File::Slurp;

# Define input parameters.
my $workflow_source = $ARGV[0];
my $workflow_destination = $ARGV[1];

# Print error messages for missing input or other errors.
if(!defined $workflow_source || $workflow_source eq "")
{
	die "Error: Must specify source and destination files.\n";
	print "Usage: minimize_workflow <source_file> <destination_file>\n";
}
elsif(!defined $workflow_destination || $workflow_destination eq "")
{
	die "Error: Must specify source and destination files.\n";
	print "Usage: minimize_workflow <source_file> <destination_file>\n";
}
elsif(!-e $workflow_source)
{
	die "Error: Source file is unreadable or does not exist.\n";
	print "Usage: minimize_workflow <source_file> <destination_file>\n";
}

# Open source workflow.
my $workflow_source_contents = read_file($workflow_source);

# Extract workflow XML from source file.
(my $workflow_source_xml) = $workflow_source_contents =~ /Xoml=\"\s*([^]]+)\"\sXomlStatus=\"/x;

# Extract workflow name from source file.
(my $workflow_source_name) = $workflow_source_contents =~ /Name=\"\s*([^]]+)\"\sDescription=\"/x;

# Extract workflow description from source file.
(my $workflow_source_description) = $workflow_source_contents =~ /Description=\"\s*([^]]+)\"\sXoml=\"/x;

# Store new destination workflow XML.
my $workflow_destination_xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<Workflow>\n\t<WorkflowInfo Name=\"$workflow_source_name\" Description=\"$workflow_source_description\" Details=\"\" XML=\"$workflow_source_xml\" />\n\t<Tags>\n\t</Tags>\n</Workflow>";

# Print status messages.
print "Workflow Name:\t\t$workflow_source_name\n";
print "Workflow Description:\t";

if($workflow_source_description eq "")
{
	print "N/A\n\n";
}
else
{
	print "$workflow_source_description\n\n";
}

# Write new workflow XML to destination file.
open(DEST, ">", $workflow_destination) or die $!;
print DEST $workflow_destination_xml;
close(DEST);

# Print final status message.
print "New workflow saved as \"$workflow_destination\".\n";