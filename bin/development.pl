#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
my $dirname = dirname(__FILE__);
system("$dirname/morbo $dirname/../webrsnapshot.pl");
