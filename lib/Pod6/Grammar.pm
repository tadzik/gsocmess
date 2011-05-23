grammar Pod6::Grammar {
    token TOP {
        \n* <pod_content> \n*
    }

    proto token pod_content { <...> }

    token pod_content:sym<block> {
        \n*
        <pod_block>
        \n*
    }

    # any number of paragraphs of text
    token pod_content:sym<text> {
        \n*
        <pod_text_para> ** [\h* \n]+
        \n*
    }

    # a single paragraph of text
    token pod_text_para {
        $<text> = [ \h* <!before '=' \w> \N+ \n ] +
    }

    proto token pod_block { <...> }

    token pod_block:sym<delimited> {
        ^^ \h* '=begin' \h+ <ident> \h* \n
        [
         <pod_content> *
         ^^ \h* '=end' \h+ $<ident> \h* \n
#         ||  <.panic: '=begin without matching =end'>
        ]
    }

    token pod_block:sym<paragraph> {
        ^^ \h* '=for' \h+ <ident> \h* \n
        $<pod_content> = <pod_text_para> *
    }

    token pod_block:sym<abbreviated> {
        ^^ \h* '=' <!before begin || end || for> <ident>
        $<pod_content> = <pod_text_para> *
    }
}

# vim: ft=perl6
