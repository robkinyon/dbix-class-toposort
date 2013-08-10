package DBIx::Class::TopoSort;

use 5.008_004;

use strict;
use warnings FATAL => 'all';

use Graph;

{
    no strict 'refs';
    *{"DBIx::Class::Schema::toposort"} = sub {
        my $self = shift;
        my $g = Graph->new;

        my @s = $self->sources;

        my %table_source = map { 
            $self->source($_)->name => $_
        } @s;

        foreach my $name ( @s ) {
            my $source = $self->source($name);
            $g->add_vertex($name);

            foreach my $rel_name ( $source->relationships ) {
                my $rel_info = $source->relationship_info($rel_name);

                if ( $rel_info->{attrs}{is_foreign_key_constraint} ) {
                    $g->add_edge(
                        $table_source{$self->source($rel_info->{source})->name},
                        $name,
                    );
                }
            }
        }

        return $g->topological_sort();
    };
}

1;
__END__
