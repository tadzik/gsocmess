grammar Pod6::Grammar {
    token TOP {
        :my $*VMARGIN    := 0;
        :my $*ALLOW_CODE := 0;
        <pod_newline>*
        <pod_content>
        <pod_newline>*
    }

    proto token pod_content { <...> }

    token pod_content:sym<block> {
        <pod_newline>*
        <pod_block>
        <pod_newline>*
    }

    # any number of paragraphs of text
    token pod_content:sym<text> {
        <pod_newline>*
        <pod_textcontent> ** <pod_newline>+
        <pod_newline>*
    }

    proto token pod_textcontent { <...> }

    # a single paragraph of text
    token pod_text_para {
        $<text> = [
            \h* <!before '=' \w> \N+ <pod_newline>
        ] +
    }

    # text not being code
    token pod_textcontent:sym<regular> {
        $<spaces>=[ \h* ]
        <?{ !$*ALLOW_CODE
            or ($<spaces>.to - $<spaces>.from) <= $*VMARGIN }>
        $<text> = [
            \h* <!before '=' \w> \N+ <pod_newline>
        ] +
    }

    token pod_textcontent:sym<code> {
        $<spaces>=[ \h* ]
        <?{ $*ALLOW_CODE
            and ($<spaces>.to - $<spaces>.from) > $*VMARGIN }>
        $<text> = [
            [<!before '=' \w> \N+] ** [<pod_newline> $<spaces>]
        ]
    }

    proto token pod_block { <...> }

    token pod_block:sym<delimited> {
        ^^
        $<spaces> = [ \h* ]
        '=begin' \h+ <!before 'END'>
        {}
        :my $*VMARGIN := $<spaces>.to - $<spaces>.from;
        :my $*ALLOW_CODE := 0;
        $<type> = [
            <pod_code_parent> { $*ALLOW_CODE := 1 }
            || <identifier>
        ]
        <pod_newline>+
        [
         <pod_content> *
         ^^ \h* '=end' \h+ $<type> <pod_newline>
         ||  <.panic: '=begin without matching =end'>
        ]
    }

    token pod_block:sym<delimited_raw> {
        ^^ \h* '=begin' \h+ $<type>=[ 'code' || 'comment' ]
                        <pod_newline>+
        [
         $<pod_content> = [ .*? ]
         ^^ \h* '=end' \h+ $<type> <pod_newline>
         ||  <.panic: '=begin without matching =end'>
        ]
    }

    token pod_block:sym<delimited_table> {
        ^^ \h* '=begin' \h+ 'table' <pod_newline>+
        [
         <table_content>
         ^^ \h* '=end' \h+ 'table' <pod_newline>
         ||  <.panic: '=begin without matching =end'>
        ]
    }

    token pod_block:sym<end> {
        ^^ \h*
        [
            || '=begin' \h+ 'END' <pod_newline>
            || '=for'   \h+ 'END' <pod_newline>
            || '=END' \h+
        ]
        .*
    }

    token pod_block:sym<paragraph> {
        ^^
        $<spaces> = [ \h* ]
        {}
        :my $*VMARGIN := $<spaces>.to - $<spaces>.from;
        :my $*ALLOW_CODE := 0;
        '=for' \h+ <!before 'END'>
        $<type> = [
            <pod_code_parent> { $*ALLOW_CODE := 1 }
            || <identifier>
        ]

        <pod_newline>
        $<pod_content> = <pod_textcontent>?
    }

    token pod_block:sym<paragraph_raw> {
        ^^ \h* '=for' \h+ $<type>=[ 'code' || 'comment' ]
                          <pod_newline>
        $<pod_content> = <pod_text_para>
    }

    token pod_block:sym<paragraph_table> {
        ^^ \h* '=for' \h+ 'table' <pod_newline>
        <table_content>
    }

    token pod_block:sym<abbreviated> {
        ^^
        $<spaces> = [ \h* ]
        {}
        :my $*VMARGIN := $<spaces>.to - $<spaces>.from;
        :my $*ALLOW_CODE := 0;
        '=' <!before begin\s || end\s || for\s || END\s || table\s>
        $<type> = [
            <pod_code_parent> { $*ALLOW_CODE := 1 }
            || <identifier>
        ]
        \s
        $<pod_content> = <pod_textcontent>?
    }

    token pod_block:sym<abbreviated_raw> {
        ^^ \h* '=' $<type>=[ 'code' || 'comment' ] \s
        $<pod_content> = <pod_text_para> *
    }

    token pod_block:sym<abbreviated_table> {
        ^^ \h* '=table' <pod_newline>
        <table_content>
    }

    token table_content {
        <table_row>+
    }

    token table_row {
        \h* <table_cell> ** [ \h+'|'\h+ || \h+'+'\h+ || \h\h+ ] \n
    }

    token table_cell {
        <!before '=' \w> # no pod directives
        [
            <!before \h\h+ || \h'|'\h || \h'+'\h> \N
        ]+
    }

    token pod_newline {
        \h* \n
    }

    token pod_code_parent {
        'pod' <!before \w> || 'item' \d* <!before \w>
        # TODO: Also Semantic blocks one day
    }

# XXX From the Perl 6 grammar, do not copy to Rakudo
    token apostrophe {
        <[ ' \- ]>
    }

    token identifier {
        <.ident> [ <.apostrophe> <.ident> ]*
    }

    method panic($a) {
        die $a
    }
}

# vim: ft=perl6
