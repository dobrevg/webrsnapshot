#!/usr/bin/perl
use strict;
use warnings;

use Crypt::PBKDF2;

my $pbkdf2 = Crypt::PBKDF2->new(
    hash_class => 'HMACSHA3',
    hash_args => {
        sha_size => 256,
    },
    iterations => 10000,
    salt_len => 10,
);

print "Username: ";
my $user = <STDIN>;
chomp $user;

print "Password: ";
my $pass = <STDIN>;
chomp $pass;

my $hash = $pbkdf2->generate($pass);
print $hash."\n";