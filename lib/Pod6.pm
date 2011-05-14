module Pod6;
use Pod6::Grammar;
use Pod6::Actions;

our sub parse($what) {
    Pod6::Grammar.parse($what, :actions(Pod6::Actions.new)).ast
}

# vim: ft=perl6
