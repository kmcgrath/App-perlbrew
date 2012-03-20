#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::Spec;

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

describe 'perlbrew exec perl -E "say 42"' => sub {
    it "invokes all perls" => sub {
        my $app = App::perlbrew->new(qw(exec perl -E), "say 42");

        my @perls = $app->installed_perls;

        $app->expects("do_system")->exactly(4)->returns(
            sub {
                my ($self, @args) = @_;

                is_deeply \@args, ["perl", "-E", "say 42"];

                my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});

                my $perl_installation = shift @perls;

                is $perlbrew_bin_path,      file($App::perlbrew::PERLBREW_ROOT, "bin");
                is $perlbrew_perl_bin_path, file($App::perlbrew::PERLBREW_ROOT, "perls", $perl_installation->{name}, "bin"), "perls/". $perl_installation->{name} . "/bin";

                return 0;
            }
        );

        $app->run;
    };
};

describe 'perlbrew exec --with perl-5.12.3 perl -E "say 42"' => sub {
    it "invokes perl-5.12.3/bin/perl" => sub {
        my $app = App::perlbrew->new(qw(exec --with perl-5.12.3 perl -E), "say 42");

        $app->expects("do_system")->returns(
            sub {
                my ($self, @args) = @_;

                is_deeply \@args, ["perl", "-E", "say 42"];

                my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});

                is $perlbrew_bin_path,      file($App::perlbrew::PERLBREW_ROOT, "bin");
                is $perlbrew_perl_bin_path, file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.12.3", "bin");

                return 0;
            }
        );

        $app->run;
    };
};

runtests unless caller;
