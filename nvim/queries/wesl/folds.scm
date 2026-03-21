([
  (import_collection)
  (switch_body)
  (compound_statement)
  ; (call_expression)
  (struct_body)
] @fold_with_brackets
(#make-range-extended! "fold" @fold_with_brackets "start" 0 1 @fold_with_brackets "end" 0 -1)
)

(
  (call_expression (_) @pre_arglist . (argument_list) . ) @ce
  (#make-range-extended! "fold" @pre_arglist "end" 0 0 @ce "end" 0 0)
  (#set! foldtext_start "(")
  (#set! foldtext_start_hl "@punctuation.bracket")
  (#set! foldtext_end ")")
  (#set! foldtext_end_hl "@punctuation.bracket")
)
