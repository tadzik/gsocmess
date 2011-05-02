class Pod6::Block {
    has @.content;
}

class Pod6::Block::Para is Pod6::Block {
    # nothing special. BOARing!
}

class Pod6::Block::Heading is Pod6::Block {
    has $.level;
}

class Pod6::Block::Code is Pod6::Block {
    has @.allowed;
}

class Pod6::Block::Table is Pod6::Block {
    has $.caption;
    has @.headers; # optional, may be empty
}

class Pod6::FormattingCode is Pod6::Block {
    # apparently, it is. It has contents, can be nested
}

class Pod6::FormattingCode::B is Pod6::FormattingCode {
    # BOARing
}

class Pod6::FormattingCode::C is Pod6::FormattingCode {
    # COARing
}

class Pod6::FormattingCode::K is Pod6::FormattingCode {
    # KOARi... whatever
}

# vim: ft=perl6
