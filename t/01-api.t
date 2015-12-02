#!perl -T
use strict;
use warnings;
use Test::More;

plan tests => 8;


my $module = "XML::C14N";

# load the module
use_ok $module;

# check the exported functions/constants
can_ok __PACKAGE__, qw< C14N_1_0 C14N_1_1 C14N_EC >;

# check the object API
can_ok $module, qw< new >;
my $object = eval { $module->new };
is $@, "", '$object = $module->new';
isa_ok $object, $module, '$object';
can_ok $object, qw<
    c14n_method prefix_list with_comments xpath xpath_context
    canonicalize
>;

# check default values
is $object->c14n_method, C14N_1_0(), "default: c14n is 1.0";
is $object->with_comments, 0, "default: don't keep comments";

