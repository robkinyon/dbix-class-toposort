use Module::Build 0.28; # for prepare_metadata

use strict;
use warnings FATAL => 'all';

my $build = Module::Build->new(
    module_name => 'DBIx::Class::TopoSort',
    license => 'perl',
    requires => {
        'perl'  => '5.008_004',
        'Graph' => '0.96',
    },
    build_requires => {
        #'File::Path'      => '0.01',
        #'File::Temp'      => '0.01',
        #'Pod::Usage'      => '1.3',
        #'Test::Warn'      => '0.08',
        #'Test::Exception' => '0.21',
        'Test::DBIx::Class' => '0.01',
        'Test::More'        => '0.88', # done_testing
        'Test::Deep'        => '0.01',
    },
    create_makefile_pl => 'traditional',
    create_readme  =>  1,
    add_to_cleanup => [
        'META.yml', '*.bak', '*.gz', 'Makefile.PL', 'cover_db',
    ],
    test_files => 't/??_*.t',
    meta_merge => {
        resources => {
            repository => 'https://github.com/robkinyon/dbix-class-toposort',
        }
    },
);

$build->create_build_script;
