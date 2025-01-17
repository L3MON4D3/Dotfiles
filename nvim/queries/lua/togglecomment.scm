(variable_declaration) @togglecomment
(function_declaration) @togglecomment

; make sure assignment-statement does not work in (local_declaration
; (assignment_statement)), only if it is a top-level statement, or in a body.
( (assignment_statement) @togglecomment (#root-child @togglecomment) )
(block (assignment_statement) @togglecomment)

; same as assignment-statement, only allow commenting function-calls if they're
; not part of an assignment.
( (function_call) @togglecomment (#root-child @togglecomment) )
(block (function_call) @togglecomment)

(if_statement) @togglecomment
(for_statement) @togglecomment
(while_statement) @togglecomment

(field) @togglecomment

(return_statement) @togglecomment
