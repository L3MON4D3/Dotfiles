[
  (argument_list)
] @fold


(compound_statement
  (declaration
  	(function_declarator
  	  (parameter_list) @fold)))

; if function has initializer-list: collapse body with it.
(
  (field_initializer_list) @start
  (compound_statement) @end
  (#make-range-row-offset! "fold" @start -1 @end 0)
)
; only match functions without initializer list.
(function_definition . (primitive_type)? . (function_declarator) . (compound_statement) @fold .)
