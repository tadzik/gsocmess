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
        return $<table_content>.ast;
    }

    method table_content($/) {
        my @rows = $<table_row>».ast;
        @rows    = self.process_rows(@rows);
        # we need 3 informations about the separators:
        #   how many of them are
        #   where is the first one
        #   are they different from each other
        # Given no separators, our table is just an ordinary, one-lined
        # table.
        # If there is one separator, the table has a header and
        # the actual content. If the first header is further than on the
        # second row, then the header is multi-lined.
        # If there's more than one separator, the table has a multi-line
        # header and a multi-line content.
        # Tricky, isn't it? Let's try to handle it sanely
        my $sepnum        = 0;
        my $firstsepindex = 0;
        my $differentseps = 0;
        my $firstsep;
        for @rows.kv -> $k, $v {
            if $v ~~ Str {
                $sepnum++;
                $firstsepindex or $firstsepindex = $k;
                if $firstsep {
                    if $firstsep ne $v { $differentseps = 1 }
                } else {
                    $firstsep = $v;
                }
            }
        }
        if $sepnum == 0 {
            # ordinary table, nothing fancy
            make Pod6::Block::Table.new(content => @rows);
        } elsif $sepnum == 1 {
            # header and a table
            if $firstsepindex == 1 {
                # one-lined header and a one-lined table
                say '# one-lined header and a one-lined table';
                my @head = @rows.shift.list;
                @rows.shift;
                make Pod6::Block::Table.new(
                    headers => @head,
                    content => @rows,
                );
            } else {
                # multi-line header and a one-lined-table
                say '# multi-line header and a one-lined-table';
                make Pod6::Block::Table.new(
                    headers => self.merge_rows(@rows[0..$firstsepindex-1]),
                    content => @rows[$firstsepindex+1 .. *-1],
                );
            }
        } else {
            say '# multi-lined header and multi-lined table';
            make Pod6::Block::Table.new;
        }
    }

    method process_rows(@rows) {
        # NOTE: This method uses as little of Perl 6 killer features as
        # possible: I'm keeping in mind that it'll have to be translated
        # to nqp quite soon

        # find the longest leading whitespace and strip it from every row
        # also remove trailing \n
        my $w = -1;
        for @rows -> $row {
            $row ~~ /\s+/;
            my $n = $/.to;
            if $n < $w or $w == -1 {
                $w = $n;
            }
        }
        for @rows.kv -> $k, $v {
            @rows[$k] = substr($v, $w).chomp;
        }
        # split the row between cells
        my @res;
        for @rows.kv -> $k, $v {
            if $v ~~ /^'='+ || ^'-'+ || ^'_'+ || ^\h+$/ {
                @res[$k] = $v;
            } elsif $v.index('|') {
                @res[$k] = $v.split(/\h+'|'\h+/);
            } elsif $v.index('+') {
                @res[$k] = $v.split(/\h+'+'\h+/);
            } else {
                @res[$k] = $v.split(/\h\h+/);
            }
        }
        return @res;
    }

    method merge_rows(@rows) {
        my @result = @rows[0].list;
        for 1..@rows.elems {
            for @rows[$_].kv -> $k, $v {
                @result[$k] = self.formatted_text(@result[$k] ~' '~ $v)
                    if $v;
            }
        }
        return @result;
    }

    method table_row($/) {
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
