[
 (switch_statement)
 (case_statement)
 (preproc_if)
 (preproc_elif)
 (preproc_else)
] @fold

(enum_specifier
  (enumerator_list) @list
(#make-range-extended! "fold" @list "start" 0 0 @list "end" 0 0)
(#set! foldtext_start "{")
(#set! foldtext_start_hl "@punctuation.bracket")
(#set! foldtext_end "}")
(#set! foldtext_end_hl "@punctuation.bracket"))

(struct_specifier
  (field_declaration_list) @list
(#make-range-extended! "fold" @list "start" 0 0 @list "end" 0 0)
(#set! foldtext_start "{")
(#set! foldtext_start_hl "@punctuation.bracket")
(#set! foldtext_end "}")
(#set! foldtext_end_hl "@punctuation.bracket"))

(
 [
  ; prevent elseif from becoming its' own fold
  ; (might be useful though....)
  (compound_statement
   (if_statement
   condition: (_)
   (compound_statement) @comp) @outer
  )
  (while_statement
   condition: (_)
   (compound_statement) @comp
  ) @outer
 ]

 (#make-range-extended! "fold" @comp "start" 0 0 @outer "end" 0 0)
 (#set! foldtext_start "{")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end "}")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

(
 (comment) @fold
 (#match? @fold "^/*")
 (#set! foldtext_start "/*")
 (#set! foldtext_start_hl "@comment.cpp")
 (#set! foldtext_end "*/")
 (#set! foldtext_end_hl "@comment.cpp")
)

(
 (for_statement
  (compound_statement) @fold)
 (#set! foldtext_start "{")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end "}")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

(
 (preproc_ifdef
   name: (identifier) @ident) @ifd

 (#make-range-extended! "fold" @ident "end" 0 1 @ifd "end" 0 0)
 (#set! foldtext_start "")
 (#set! foldtext_start_hl "")
 (#set! foldtext_end "#endif")
 (#set! foldtext_end_hl "@keyword")
)

(
 (argument_list) @fold
 (#set! foldtext_start "(")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end ")")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

; only match functions without initializer list.
(
 (function_definition . (_)? . (_)? . declarator: (_) . (compound_statement) @fold .)
 (#set! foldtext_start "{")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end "}")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

(
 (initializer_list) @fold
 (#set! foldtext_start "{")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end "}")
 (#set! foldtext_end_hl "@punctuation.bracket")
)
