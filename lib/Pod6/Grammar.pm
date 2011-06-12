grammar Pod6::Grammar {
    token TOP {
        :my $*VMARGIN := -1;
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
        <?{ $*VMARGIN >= 0 ?? ~$<spaces> eq $*VMARGIN !! 1 }>
        $<text> = [
            \h* <!before '=' \w> \N+ <pod_newline>
        ] +
    }

    token pod_textcontent:sym<code> {
        $<spaces>=[ \h* ]
        <?{ $*VMARGIN >= 0 ?? ~$<spaces> ne $*VMARGIN !! 1 }>
        $<text> = [
            [<!before '=' \w> \N+] ** [<pod_newline> $<spaces>]
        ]
    }

    proto token pod_block { <...> }

    token pod_block:sym<delimited> {
        ^^
        $<spaces> = [ \h* ]
        {}
        :my $*VMARGIN := ~$<spaces>;
        '=begin' \h+ <!before 'END'> <identifier> <pod_newline>+
        [
         <pod_content> *
         ^^ \h* '=end' \h+ $<identifier> <pod_newline>
         ||  <.panic: '=begin without matching =end'>
        ]
    }

    token pod_block:sym<delimited_raw> {
        ^^ \h* '=begin' \h+ <!before 'END'>
                        $<identifier>=[ 'code' || 'comment' ]
                        <pod_newline>+
        [
         $<pod_content> = [ .*? ]
         ^^ \h* '=end' \h+ $<identifier> <pod_newline>
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
        ^^ \h* '=for' \h+ <!before 'END'> <identifier> <pod_newline>
        $<pod_content> = <pod_text_para> *
    }

    token pod_block:sym<paragraph_raw> {
        ^^ \h* '=for' \h+ <!before 'END'>
                          $<identifier>=[ 'code' || 'comment' ]
                          <pod_newline>
        $<pod_content> = <pod_text_para> *
    }

    token pod_block:sym<abbreviated> {
        ^^ \h* '=' <!before begin || end || for || END>
                   <identifier> <pod_newline>?
        $<pod_content> = <pod_text_para> *
    }

    token pod_block:sym<abbreviated_raw> {
        ^^ \h* '=' $<identifier>=[ 'code' || 'comment' ]
                   [ <pod_newline> || \h+ ]?
        $<pod_content> = <pod_text_para> *
    }

    token pod_newline {
        \h* \n
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
