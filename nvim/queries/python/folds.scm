; [
  ; (function_definition)
  ; (class_definition)
  ; (while_statement)
  ; (for_statement)
  ; (if_statement)
  ; (with_statement)
  ; (try_statement)
  ; (match_statement)
  ; (import_from_statement)
  ; (parameters)
  ; (argument_list)
  ; (parenthesized_expression)
  ; (generator_expression)
  ; (list_comprehension)
  ; (set_comprehension)
  ; (dictionary_comprehension)
  ; (tuple)
  ; (list)
  ; (set)
  ; (dictionary)
  ; (string)
; ] @fold

(
 (class_definition) @class
 (#make-range-extended! "fold" @class "start" 0 300 @class "end" 0 0)
)

(
 (function_definition (parameters) @parms) @fn
 (#make-range-extended! "fold" @parms "end" 0 300 @fn "end" 0 0)
)

[
  (import_statement)
  (import_from_statement)
]+ @fold
