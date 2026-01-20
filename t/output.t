#!perl
## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
use strict;
use warnings;

our $VERSION = 0.001;

use utf8;
use Test2::V0;
set_encoding('utf8');

use JSON qw( decode_json encode_json );

use Path::Tiny qw( path );

my $tempfile_path;
BEGIN {
    my $tempfile = Path::Tiny->tempfile;
    $tempfile_path = q{}.$tempfile->path;
}

use Log::Any qw($log);
use Log::Any::Adapter 'JSONLines', file => $tempfile_path;

# last line logged
sub last_line {
    my $line = (path($tempfile_path)->lines_utf8({ chomp => 1 }))[-1];
    return decode_json $line;
}

subtest 'plain string' => sub {
    $log->debug('hello, world');
    is(
        last_line(),
        {
            message   => 'hello, world',
        },
        'plain string logged as-is',
    );
    $log->debug('こんにちは世界');
    is(
        last_line(),
        {
            message   => 'こんにちは世界',
        },
        'plain high-bit utf8 string logged as-is',
    );
};

subtest 'structure' => sub {
    $log->debug('hello, world', { age=>123, name=>'Smith' });
    is(
        last_line(),
        {
            message   => 'hello, world',
            age       => 123,
            name      => 'Smith',
        },
        'plain string with structure',
    );
    $log->debug({ age=>'123', name=>'Smith' });
    is(
        last_line(),
        {
            age  => '123',
            name => 'Smith',
        },
        'only structure',
    );
    $log->debug({ age=>123, name=>'Smith' }, { gender => 'F' });
    is(
        last_line(),
        {
            messages => [
                {
                    age  => '123',
                    name => 'Smith',
                },
                {
                    gender => 'F',
                }
            ],
        },
        'structures',
    );

    $log->debug('hello, world', sub { 'Tester'; });
    is(
        last_line(),
        {
            messages => [
                'hello, world',
                'Tester',
            ],
        },
        'plain string, hash, code and array',
    );
    $log->debug(sub { 'Tester'; }, 'hello, world');
    is(
        last_line(),
        {
            messages => [
                'Tester',
                'hello, world',
            ],
        },
        'plain string, hash, code and array',
    );
    $log->debug('hello, world', { age=>123, name=>'Smith' }, sub { 'Tester'; }, [1,2,3]);
    is(
        last_line(),
        {
            messages => [
                'hello, world',
                {
                    age  => '123',
                    name => 'Smith',
                },
                'Tester',
                [1,2,3],
            ],
        },
        'plain string, hash, code and array',
    );
    $log->debug([1,2,3]);
    is(
        last_line(),
        {
            messages => [ 1,2,3, ],
        },
        'array',
    );
};

done_testing;
