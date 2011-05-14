# The Pod classes we need
# (in order of appearance, or not)
# Code
# !Comment (no Comment, it's ignored)
# List
# B<>, I<>, L<> and moar
# Tables

class Pod6::Block {
    has @.content;
}

class Pod6::Block::Para is Pod6::Block { }

class Pod6::Block::Heading is Pod6::Block {
    has $.level;
}

class Pod6::Block::Code is Pod6::Block {
    has @.allowed;
}

class Pod6::Block::Named is Pod6::Block { }

class Pod6::Block::Table is Pod6::Block {
    has $.caption;
    has @.headers; # optional, may be empty
}

class Pod6::FormattingCode is Pod6::Block { }

class Pod6::FormattingCode::B is Pod6::FormattingCode { }

class Pod6::FormattingCode::C is Pod6::FormattingCode { }

class Pod6::FormattingCode::K is Pod6::FormattingCode { }

class Pod6::List {
    # this is not a block. In Damian Conway's implementation it is,
    # but at this very moment I don't see much connection. Maybe
    # rereading the spec or implementing things later on will open
    # my eyes
    has $.numbered;
    has @.elements; # one of those may be a Pod6::List as well
}


# vim: ft=perl6
