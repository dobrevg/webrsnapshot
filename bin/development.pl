#!/usr/bin/env perl
#######################################################################
# This file is part of Webrsnapshot - The web interface for rsnapshot
# Copyright© (2013-2017) Georgi Dobrev (dobrev.g at gmail dot com)
#
# Webrsnapshot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Webrsnapshot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Webrsnapshot. If not, see <http://www.gnu.org/licenses/>.
#######################################################################
use strict;
use warnings;
use File::Basename;
my $dirname = dirname(__FILE__);
system("$dirname/morbo $dirname/../webrsnapshot.pl --listen http://*:3000");