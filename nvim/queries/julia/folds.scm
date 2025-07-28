[
  (macro_definition)

  (if_statement)
  (try_statement)
  (while_statement)
  (let_statement)
  (quote_statement)

  (compound_statement)
] @fold

((vector_expression) @expr
  (#make-range-extended! "fold" @expr "start" 0 0 @expr "end" 0 0)
  (#set! foldtext_start "[")
  (#set! foldtext_start_hl "@punctuation.bracket.julia")
  (#set! foldtext_end "]")
  (#set! foldtext_end_hl "@punctuation.bracket.julia")
)

((if_statement
  condition: (_) @cond) @if
  ; ends with a `end`, have the folded region end just before that.
  (#make-range-extended! "fold" @cond "end" 0 1 @if "end" 0 -3) 
)

((for_statement
  (for_binding) @bind) @if
  ; ends with a `end`, have the folded region end just before that.
  (#make-range-extended! "fold" @bind "end" 0 1 @if "end" 0 -3) 
)

; (
 ; [
  ; (for_statement
   ; (for_binding) @from
  ; ) @to
 ; (function_definition
   ; parameters: (parameter_list) @from) @to
 ; (module_definition
   ; name: (identifier) @from) @to
 ; ]
 ; (#make-range-extended! "fold" @from "end" 0 1 @to "end" 0 0)
 ; (#set! foldtext_start "")
 ; (#set! foldtext_start_hl "")
 ; (#set! foldtext_end "end")
 ; (#set! foldtext_end_hl "@keyword")
; )

(
 (do_clause) @fold
 (#set! foldtext_start "do")
 (#set! foldtext_start_hl "@keyword")
 (#set! foldtext_end "end")
 (#set! foldtext_end_hl "@keyword")
)

(
 (function_definition
   (signature) @sig) @fn
 (#make-range-extended! "fold" @sig "end" 0 1 @fn "end" 0 -3)
)

(
 (struct_definition) @struct
 (#make-range-extended! "fold" @struct "start" 0 1000 @struct "end" 0 -3)
)

(
 (matrix_expression) @mx
 (#make-range-extended! "fold" @mx "start" 0 1 @mx "end" 0 -1)
 (#set! "priority" 101)
)
(
 (argument_list) @ls
 (#make-range-extended! "fold" @ls "start" 0 1 @ls "end" 0 -1)
)
