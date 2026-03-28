(
 [
  (class_definition)
  (with_statement)
  (if_statement)
  (for_statement)
 ] @class
 (#make-range-extended! "fold" @class "start" 0 300 @class "end" 0 0)
)

(
 (function_definition (parameters) @parms) @fn
 (#make-range-extended! "fold" @parms "end" 0 300 @fn "end" 0 0)
)

(
 [
  (argument_list)
  (dictionary)
 ] @exclude_start_end
 (#make-range-extended! "fold" @exclude_start_end "start" 0 1 @exclude_start_end "end" 0 -1)
)

[
  (import_statement)
  (import_from_statement)
]+ @fold
