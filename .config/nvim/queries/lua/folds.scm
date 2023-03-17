(
  (for_statement
   clause: (_) @clause
   (_)
  ) @for_stmt
  (#make-range-extended! "fold" @clause "end_" 0 1 @for_stmt "end_" 0 0)
  (#set! foldtext_start "do")
  (#set! foldtext_start_hl "@conditional")
  (#set! foldtext_end "end")
  (#set! foldtext_end_hl "@conditional")
)

(
  (if_statement
   condition: (_) @cond
   (_)
  ) @if_stmt
  (#make-range-extended! "fold" @cond "end_" 0 1 @if_stmt "end_" 0 0)
  (#set! foldtext_start "then")
  (#set! foldtext_start_hl "@conditional")
  (#set! foldtext_end "end")
  (#set! foldtext_end_hl "@conditional")
)

(
  [
   (function_declaration
  	parameters: (_) @params)
   (function_definition
  	parameters: (_) @params)
   ] @fn
  (#make-range-extended! "fold" @params "end_" 0 1 @fn "end_" 0 0)
  (#set! foldtext_start "")
  (#set! foldtext_start_hl "")
  (#set! foldtext_end "end")
  (#set! foldtext_end_hl "@keyword.function")
)

(
  (table_constructor) @fold
  (#set! foldtext_start "{")
  (#set! foldtext_start_hl "@punctuation.bracket")
  (#set! foldtext_end "}")
  (#set! foldtext_end_hl "@punctuation.bracket")
)


(
 (function_call
  name: (_) @name
  (arguments) @fold)
 (#set! foldtext_start "(")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end ")")
 (#set! foldtext_end_hl "@punctuation.bracket")
 (#not-any-of? @name "it" "describe")
)
