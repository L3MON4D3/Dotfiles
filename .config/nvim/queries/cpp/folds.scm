; inherits: c

[
 (catch_clause)
 (lambda_expression)
] @fold

(
 [
  (try_statement
   (compound_statement) @comp
  ) @outer
 ]

 (#make-range-extended! "fold" @comp "start" 0 0 @outer "end_" 0 0)
 (#set! foldtext_start "{")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end "}")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

(
 [
  (class_specifier
   (field_declaration_list) @fold)
  (namespace_definition
    (declaration_list) @fold)
  (for_range_loop
   (compound_statement) @fold
  )
 ]

 (#set! foldtext_start "{")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end "}")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

(
 compound_statement (compound_statement) @fold

 (#set! foldtext_start "{")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end "}")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

 (field_declaration
   type: (enum_specifier)
   default_value: (initializer_list)) @fold

(compound_statement
  (declaration
  	(function_declarator
  	  (parameter_list) @fold))
 (#set! foldtext_start "(")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end ")")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

(
 (function_definition
  (function_declarator) @decl ) @def
 (#make-range-extended! "fold" @decl "end_" 0 1 @def "end_" 0 0)
 (#set! foldtext_start "{")
 (#set! foldtext_start_hl "@punctuation.bracket")
 (#set! foldtext_end "}")
 (#set! foldtext_end_hl "@punctuation.bracket")
)

; collapse public/protected/private
; siblings
(
 (field_declaration_list
  (access_specifier) @first .
  (_ declarator: (_))* .
  (access_specifier) @second)
 (#make-range-extended! "fold" @first "end_" 0 1 @second "end_" -1 0)
 (#set! foldtext_start "")
 (#set! foldtext_start_hl "")
 (#set! foldtext_end "")
 (#set! foldtext_end_hl "")
)

; last specifier
(
 (field_declaration_list
  (access_specifier) @last . (_ declarator: (_) )* . (_ declarator: (_) ) . ) @list
 ; big col-offset so we end up at the end of the line.
 (#make-range-extended! "fold" @last "end_" 0 1 @list "end_" -1 300)
 (#set! foldtext_start "")
 (#set! foldtext_start_hl "")
 (#set! foldtext_end "")
 (#set! foldtext_end_hl "")
)
