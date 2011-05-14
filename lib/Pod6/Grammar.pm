grammar Pod6::Grammar {
    token TOP {
        \n* <pod_content> \n*
    }

    proto token pod_content { <...> }

    token pod_content:sym<block> {
        <pod_block>
    }

    # any number of paragraphs of text
    token pod_content:sym<text> {
        <pod_text_para> ** \n+
        \n*
    }

    # a single paragraph of text
    token pod_text_para {
        $<text> = [ \h* <![=]> \N+ \n ] +
    }

    proto token pod_block { <...> }

    token pod_block:sym<delimited> {
        ^^ \h* '=begin' \h+ <ident> \h* \n
        [
         <pod_content>?
         ^^ \h* '=end' \h+ $<ident> \h* \n
#         ||  <.panic: '=begin without matching =end'>
        ]
    }
}

# vim: ft=perl6
