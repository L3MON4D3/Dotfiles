[
  (indented_code_block)
] @fold

((fenced_code_block
  .
  (fenced_code_block_delimiter) @from .
  (info_string)? @from
  (fenced_code_block_delimiter) @to .
 )
 ; make sure to cover the entire line.
 (#make-range-extended! "fold" @from "end" 0 1 @to "end" 0 0)
 (#set! foldtext_start "")
 (#set! foldtext_start_hl "")
 (#set! foldtext_end "```")
 (#set! foldtext_end_hl "@punctuation.delimiter")
)

( (section
   (atx_heading heading_content: (_) @heading ) ) @section
 ; end of section is one line to high, I think.. just move endpoint to end of previous line
 (#make-range-extended! "fold" @heading "end" 0 0 @section "end" -1 1000)
 )
