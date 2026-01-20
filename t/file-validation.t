#!perl
## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
use strict;
use warnings;

our $VERSION = 0.001;

use utf8;
use Test2::V0;
set_encoding('utf8');

use Path::Tiny qw( path );
use Log::Any::Adapter::JSONLines;

# Test error handling for invalid file parameter references
# According to lib/Log/Any/Adapter/JSONLines.pm line 331,
# the code should croak if the file parameter is a reference but not a GLOB

subtest 'invalid file reference - ARRAY ref' => sub {
    my $array_ref = [1, 2, 3];
    
    like(
        dies { Log::Any::Adapter::JSONLines->new(file => $array_ref) },
        qr/Invalid file/,
        'ARRAY reference should cause error'
    );
};

subtest 'invalid file reference - HASH ref' => sub {
    my $hash_ref = { key => 'value' };
    
    like(
        dies { Log::Any::Adapter::JSONLines->new(file => $hash_ref) },
        qr/Invalid file/,
        'HASH reference should cause error'
    );
};

subtest 'invalid file reference - SCALAR ref' => sub {
    my $scalar = 'test';
    my $scalar_ref = \$scalar;
    
    like(
        dies { Log::Any::Adapter::JSONLines->new(file => $scalar_ref) },
        qr/Invalid file/,
        'SCALAR reference should cause error'
    );
};

subtest 'invalid file reference - CODE ref' => sub {
    my $code_ref = sub { return 'test'; };
    
    like(
        dies { Log::Any::Adapter::JSONLines->new(file => $code_ref) },
        qr/Invalid file/,
        'CODE reference should cause error'
    );
};

subtest 'invalid file reference - REF ref' => sub {
    my $inner_ref = [1, 2, 3];
    my $ref_ref = \$inner_ref;
    
    like(
        dies { Log::Any::Adapter::JSONLines->new(file => $ref_ref) },
        qr/Invalid file/,
        'REF reference should cause error'
    );
};

subtest 'valid file reference - GLOB ref (filehandle)' => sub {
    open my $fh, '>', \my $buffer or die "Cannot open filehandle: $!";
    
    my $result = lives { Log::Any::Adapter::JSONLines->new(file => $fh) };
    ok($result, 'GLOB reference (filehandle) should be accepted');
    
    close $fh;
};

subtest 'valid file reference - string path' => sub {
    my $tempfile = Path::Tiny->tempfile;
    my $tempfile_path = $tempfile->stringify;
    
    my $result = lives { Log::Any::Adapter::JSONLines->new(file => $tempfile_path) };
    ok($result, 'String file path should be accepted');
};

done_testing;
