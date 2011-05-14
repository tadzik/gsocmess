#inlined due to Rakudobug
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

class Pod6::Actions {
#    use Pod6::Nodes;

    method TOP($/) {
        make $<pod_content>.ast;
    }

    method pod_content:sym<block>($/) {
        make $<pod_block>.ast;
    }

    method pod_content:sym<text>($/) {
        make $<pod_text_para>».ast.values;
    }

    method pod_text_para($/) {
        make $<text>.Str.subst(/\s+/, ' ', :g).subst(/^^\s*/, '').subst(/\s*$$/, '');
    }

    method pod_block:sym<delimited>($/) {
        my $block;
        my @content;
        for $<pod_content>».ast {
            @content.push: |$_
        }
        # XXX: Should be Pod::Block::Named::$type somehow
        $block = Pod6::Block::Named.new(content => @content);
        make $block;
    }
}

# vim: ft=perl6
