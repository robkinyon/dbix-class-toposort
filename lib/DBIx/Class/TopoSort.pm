package DBIx::Class::TopoSort;

use 5.008_004;

use strict;
use warnings FATAL => 'all';

use Graph;

{
    no strict 'refs';
    *{"DBIx::Class::Schema::toposort_graph"} = sub {
        my $self = shift;
        my (%opts) = @_;

        my $g = Graph->new;

        my @source_names = $self->sources;

        my %table_source = map { 
            $self->source($_)->name => $_
        } @source_names;

        foreach my $name ( @source_names ) {
            my $source = $self->source($name);
            $g->add_vertex($name);

            foreach my $rel_name ( $source->relationships ) {
                next if grep { $_ eq $rel_name } @{$opts{skip}{$name}};
                my $rel_info = $source->relationship_info($rel_name);

                if ( $rel_info->{attrs}{is_foreign_key_constraint} ) {
                    $g->add_edge(
                        $table_source{$self->source($rel_info->{source})->name},
                        $name,
                    );
                }
            }
        }

        return $g;
    };
    *{"DBIx::Class::Schema::toposort"} = sub {
        my $self = shift;
        return $self->toposort_graph(@_)->toposort();
    };
}

1;
__END__
