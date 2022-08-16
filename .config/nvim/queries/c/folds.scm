[
  (argument_list)
] @fold

; only match functions without initializer list.
(function_definition . (_)? . (function_declarator) . (compound_statement) @fold .)
