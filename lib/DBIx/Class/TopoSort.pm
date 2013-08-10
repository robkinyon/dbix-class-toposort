package DBIx::Class::TopoSort;

use 5.008_004;

use strict;
use warnings FATAL => 'all';

{
    no strict 'refs';
    *{"DBIx::Class::Schema::toposort"} = sub {
        my $self = shift;
        return $self->sources;
    };
}

1;
__END__
