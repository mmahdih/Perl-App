#!/usr/bin/perl
use strict;
use warnings;

use lib '.';

use FileLogger;

FileLogger::open("logtest.log");
FileLogger::set_level(2);
FileLogger::log(2,"This is a test message");

FileLogger::close();