requires 'DBIx::Class';
requires 'Graph';

on test => sub {
  requires 'Test::Exception'   => '0.21';
  requires 'Test::DBIx::Class' => '0.01';
  requires 'Test::More'        => '0.88'; # done_testing
  requires 'Test::Deep'        => '0.01';
  requires 'List::MoreUtils'   => '0.01'; # first_index
  requires 'YAML::XS'          => '0.01'; # Force a usable YAML parser
};
