#!perl -w
use strict;
use Test::More;

use App::mepan;

# test App::mepan here
my $app = App::mepan->new('--version');

my $help = $app->help_message;
note $help;
ok $help, 'help_message';

ok $app->appname,         'appname';
ok $app->version_message, 'version_message';

my $v = do {
    open my $fh, '>', \my $buffer;
    local *STDOUT = $fh;
    $app->run(); # do version
    $buffer;
};
like $v, qr/perl/;

my $x = `$^X -Ilib script/mepan --version`;
like $x, qr/perl/, 'exec mepan --version';


done_testing;
