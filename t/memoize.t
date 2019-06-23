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
        );
        __PACKAGE__->set_primary_key('id');
    }

    {
        package MyApp::Schema;
        use base 'DBIx::Class::Schema';
        __PACKAGE__->register_class(Artist => 'MyApp::Schema::Result::Artist');
        __PACKAGE__->load_components('TopoSort');
    }
}

use Test::DBIx::Class qw(:resultsets);

my $count = 0;
{
    no strict 'refs';
    no warnings 'redefine';
    my $old_toposort = \&DBIx::Class::TopoSort::toposort;
    *{"DBIx::Class::TopoSort::toposort"} = sub {
        $count++;
        $old_toposort->(@_);
    };
}

lives_ok { Schema->disable_toposort_memoize } 'We can disable without a problem';

cmp_ok($count, '==', 0, 'No calls yet');

Schema->toposort;
cmp_ok($count, '==', 1, 'We have a call');

Schema->toposort;
cmp_ok($count, '==', 2, 'We have another call');

Schema->enable_toposort_memoize;

lives_ok { Schema->enable_toposort_memoize } 'We can enable again without a problem';

Schema->toposort();
cmp_ok($count, '==', 3, 'We have a call after memoize');

Schema->toposort();
cmp_ok($count, '==', 3, 'We have no additional calls after memoize');

Schema->disable_toposort_memoize;

Schema->toposort;
cmp_ok($count, '==', 4, 'We have calls again after disabling memoize');

done_testing;
