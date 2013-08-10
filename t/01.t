use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Deep;

BEGIN {
    {
        package MyApp::Schema::Result::Artist;
        use base 'DBIx::Class::Core';
        __PACKAGE__->table('artists');
        __PACKAGE__->add_columns(
            id => {
                data_type => 'int',
                is_nullable => 0,
                is_auto_increment => 1,
            },
        );
        __PACKAGE__->set_primary_key('id');
    }

    {
        package MyApp::Schema;
        use base 'DBIx::Class::Schema';
        __PACKAGE__->register_class(Artist => 'MyApp::Schema::Result::Artist');
    }
}

use Test::DBIx::Class qw(:resultsets);

use_ok 'DBIx::Class::TopoSort';

my @tables = Schema->toposort();
cmp_deeply( [@tables], ['Artist'], "One table toposort is just the table" );

done_testing;
