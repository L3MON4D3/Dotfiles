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

; some stupid comment
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

; non-last specifiers, account for *-quantifier-bug.
(
 (field_declaration_list
  (access_specifier) @aspec . (_) @last . (access_specifier) )
 (#not-any-of? @last "private" "public" "protected")
 ; big col-offset so we end up at the end of the line.
 (#make-range-extended! "fold" @aspec "end_" 0 1 @last "end_" 0 0)
)

(
 (field_declaration_list
  (access_specifier) @aspec . (_)* @items . (_) @last . (access_specifier) )
 (#not-any-of? @items "private" "public" "protected")
 (#not-any-of? @last "private" "public" "protected")
 ; big col-offset so we end up at the end of the line.
 (#make-range-extended! "fold" @aspec "end_" 0 1 @last "end_" 0 0)
)

; last specifier, account for *-quantifier-bug.
(
 (field_declaration_list
  (access_specifier) @aspec . (_) @last . )
 (#not-any-of? @last "private" "public" "protected")
 ; big col-offset so we end up at the end of the line.
 (#make-range-extended! "fold" @aspec "end_" 0 1 @last "end_" 0 0)
)

(
 (field_declaration_list
  (access_specifier) @aspec . (_)* @items . (_) @last . )
 (#not-any-of? @items "private" "public" "protected")
 (#not-any-of? @last "private" "public" "protected")
 ; big col-offset so we end up at the end of the line.
 (#make-range-extended! "fold" @aspec "end_" 0 1 @last "end_" 0 0)
)
