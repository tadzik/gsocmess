#inlined due to Rakudobug
class Pod6::Block {
    has @.content;
}

class Pod6::Block::Comment is Pod6::Block { }

class Pod6::Block::Para is Pod6::Block { }

class Pod6::Block::Heading is Pod6::Block {
    has $.level;
}

class Pod6::Block::Code is Pod6::Block {
    has @.allowed;
}

class Pod6::Block::Named is Pod6::Block {
    has $.name;
}

class Pod6::Block::Table is Pod6::Block {
    has $.caption;
    has @.headers; # optional, may be empty
}

class Pod6::FormattingCode is Pod6::Block { }

class Pod6::FormattingCode::B is Pod6::FormattingCode { }

class Pod6::FormattingCode::C is Pod6::FormattingCode { }

class Pod6::FormattingCode::K is Pod6::FormattingCode { }

class Pod6::Item is Pod6::Block {
    # a list item. There should be no List block
    # or any other Item container
    has $.level;
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
        make $<pod_textcontent>».ast.values;
    }

    method pod_text_para($/) {
        make self.formatted_text($<text>.Str);
    }

    method pod_textcontent:sym<regular>($/) {
        make self.formatted_text($<text>.Str);
    }

    method pod_textcontent:sym<code>($/) {
        my $s := $<spaces>.Str;
        my $t := $<text>.Str.subst("\n$s", "\n", :g).chomp;
        make Pod6::Block::Code.new(content => $t);
    }

    method pod_block:sym<delimited>($/) {
        make self.any_block($/);
    }

    method pod_block:sym<delimited_raw>($/) {
        make self.raw_block($/);
    }

    method pod_block:sym<delimited_table>($/) {
        make self.table($/);
    }

    method pod_block:sym<paragraph>($/) {
        make self.any_block($/);
    }

    method pod_block:sym<paragraph_raw>($/) {
        make self.raw_block($/);
    }

    method pod_block:sym<paragraph_table>($/) {
        make self.table($/);
    }

    method pod_block:sym<abbreviated>($/) {
        make self.any_block($/);
    }

    method pod_block:sym<abbreviated_raw>($/) {
        make self.raw_block($/);
    }

    method pod_block:sym<abbreviated_table>($/) {
        make self.table($/);
    }

    method any_block($/) {
        my $name := $<type>.Str;
        my @content;
        for $<pod_content>».ast {
            @content.push: @($_);
        }
        if $name ~~ /^item \d*$/ {
            return self.list_item($/, @content);
        }
        # XXX: Should be Pod::Block::Named::$type somehow
        return Pod6::Block::Named.new(
            name    => $name,
            content => @content,
        );
    }

    method raw_block($/) {
        my @content = ~$<pod_content>;
        if $<type> eq 'code' {
            return Pod6::Block::Code.new(content => @content);
        } else {
            return Pod6::Block::Comment.new(content => @content);
        }
    }

    method table($/) {
        return Pod6::Block::Table.new(
            content => $<table_content>.ast.list
        );
    }

    method table_content($/) {
        make $<table_row>».ast;
    }

    method table_row($/) {
        make $<table_cell>».ast
    }

    method table_cell($/) {
        make $/.Str;
    }

    method list_item($/, @content) {
        return Pod6::Item.new(
            level   => $<type>.substr(4),
            content => @content,
        );
    }

    method formatted_text($a) {
        $a.subst(/\s+/, ' ', :g).subst(/^^\s*/, '').subst(/\s*$$/, '');
    }
}
# vim: ft=perl6
