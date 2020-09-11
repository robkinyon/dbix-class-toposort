# vim: set noai ts=4 sw=4:
use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Deep;
use Test::Exception;

BEGIN {
    {
        package MyApp::Schema::Result::Artist;
        use base 'DBIx::Class::Core';
        __PACKAGE__->table('artists');
        __PACKAGE__->add_columns(
            id => 'int',
            first_album_id => 'int',
        );
        __PACKAGE__->set_primary_key('id');
        __PACKAGE__->has_many('albums', 'MyApp::Schema::Result::Album', 'artist_id');
    }

    {
        package MyApp::Schema::Result::Album;
        use base 'DBIx::Class::Core';
        __PACKAGE__->table('albums');
        __PACKAGE__->add_columns(
            id => 'int',
            artist_id => 'int',
        );
        __PACKAGE__->set_primary_key('id');
        __PACKAGE__->belongs_to('artist', 'MyApp::Schema::Result::Artist', 'artist_id');
    }

    {
        package MyApp::Schema;
        use base 'DBIx::Class::Schema';
        __PACKAGE__->register_class(Artist => 'MyApp::Schema::Result::Artist');
        __PACKAGE__->register_class(Album => 'MyApp::Schema::Result::Album');
        __PACKAGE__->load_components('TopoSort');
    }
}

use Test::DBIx::Class qw(:resultsets);

{
    my @tables = Schema->toposort();
    cmp_deeply( [@tables], ['Artist', 'Album'], "Connected tables are returned in has_many order" );
}

{
    my @tables = Schema->toposort(
        add_dependencies => {
            Album => 'Artist',
        },
    );
    cmp_deeply( [@tables], ['Artist', 'Album'], "Adding an existing relationship is a no-op" );
}

dies_ok {
    Schema->toposort(
        add_dependencies => {
            Artist => 'Album',
        },
    )
} 'toposort dies with a cycle added via scalar';

throws_ok {
    Schema->toposort(
        detect_cycle => 1,
        add_dependencies => {
            Artist => 'Album',
        },
    )
} qr/Found circular relationships between \[(?:(?:Artist, Album)|(?:Album, Artist))\]/, 'detect_cycle shows the cycle';

dies_ok {
    Schema->toposort(
        add_dependencies => {
            Artist => [ 'Album' ],
        },
    )
} 'toposort dies with a cycle added via array';

throws_ok {
    Schema->toposort(
        add_dependencies => {
            Artist => [ 'NotATable' ],
        },
    )
} qr/Unknown parent 'NotATable' found in add_dependencies/, 'toposort dies with a unknown parent in add_dependencies';

throws_ok {
    Schema->toposort(
        add_dependencies => {
            NotATable => [ 'Album' ],
        },
    )
} qr/Unknown children 'NotATable' found in add_dependencies/, 'toposort dies with a unknown child in add_dependencies';

done_testing;
