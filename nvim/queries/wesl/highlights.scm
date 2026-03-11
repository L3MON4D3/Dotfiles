; comments

(line_comment) @comment.line
(block_comment) @comment.block

; variables, types, constants

(identifier) @variable

(param
  name: (_) @variable.parameter)

(struct_decl
  name: (_) @type)

(struct_member
  name: (_) @variable.other.member)

(named_component_expression
  component: (_) @variable.other.member)

((identifier) @type
  (#match? @type "^[A-Z]"))

((identifier) @constant
  (#match? @constant "^[A-Z0-9_]+$"))

(type_specifier
    (identifier) @type)

; imports (WESL extension)

(import_item (identifier) @namespace)

(import_path (identifier) @namespace)

(ident_path (identifier) @namespace)

(import_item (identifier) @type
  (#match? @type "^[A-Z]"))

(import_item (identifier) @constant
  (#match? @constant "^[A-Z0-9_]+$"))

; functions

(function_decl 
  (function_header
    (identifier) @function))

(call_expression
  (identifier) @function.call)

(func_call_statement
  (identifier) @function)

; templates

(template_list) @punctuation

(type_specifier
  (template_list
    (identifier) @type))

(template_list
  (template_list
    (identifier) @type))

(variable_decl ; this is var<storage> et.al
  (template_list
    (identifier) @keyword.storage.modifier))

; attributes

(attribute
  (identifier) @attribute) @attribute

(attribute
  (identifier) @attribute
  (argument_list
    (identifier) @variable.builtin)
  (#eq? @attribute "builtin"))

; literals

(bool_literal) @constant.builtin.boolean
(int_literal) @constant.numeric.integer
(hex_int_literal) @constant.numeric.integer
(float_literal) @constant.numeric.float

; keywords

[
  "alias"
  "virtual" ; Bevy / naga_oil extension
] @keyword

[
  "switch"
  "case"
  "default"
  "break"
  "continue"
  "continuing"
  "discard"
  "const_assert"
] @keyword.control

[ "fn" ] @keyword.control.function
[ "if" "else" ] @keyword.control.conditional
[ "loop" "for" "while" ] @keyword.control.repeat
[ "return" ] @keyword.control.return
[ "var" "let" "const" "override" "struct" ] @keyword.storage.type
[ "diagnostic" "enable" "requires" ] @keyword.directive
[ "import" "as" ] @keyword.control.import ; WESL import extension

; expressions

[
  "-" "!" "~" "*" "&" ; unary
  "^" "|" "/" "%" "+" "&&" "||" (shift_left) (shift_right) ; binary
  (less_than) (greater_than) (less_than_equal) (greater_than_equal) "==" "!=" ; relational
  "+=" "-=" "*=" "/=" "%=" "|=" "^=" "++" "--" "=" ; assign
  "->" ; return
] @operator

; punctuation

[ "(" ")" "[" "]" "{" "}" ] @punctuation.bracket
[ "," "." ":" "::" ";" ] @punctuation.delimiter

; preprocessor

[ (preproc_directive) "#import" ] @keyword.directive

; reserved (except "as" and "import")
; it's debated whether we should highlight them.

; [
;   "NULL" "Self" "abstract" "active" "alignas"
;   "alignof" "asm" "asm_fragment" "async" "attribute"
;   "auto" "await" "become" "cast" "catch"
;   "class" "co_await" "co_return" "co_yield" "coherent"
;   "column_major" "common" "compile" "compile_fragment" "concept"
;   "const_cast" "consteval" "constexpr" "constinit" "crate"
;   "debugger" "decltype" "delete" "demote" "demote_to_helper"
;   "do" "dynamic_cast" "enum" "explicit" "export"
;   "extends" "extern" "external" "fallthrough" "filter"
;   "final" "finally" "friend" "from" "fxgroup"
;   "get" "goto" "groupshared" "highp" "impl"
;   "implements" "inline" "instanceof" "interface"
;   "layout" "lowp" "macro" "macro_rules" "match"
;   "mediump" "meta" "mod" "module" "move"
;   "mut" "mutable" "namespace" "new" "nil"
;   "noexcept" "noinline" "nointerpolation" "non_coherent" "noncoherent"
;   "noperspective" "null" "nullptr" "of" "operator"
;   "package" "packoffset" "partition" "pass" "patch"
;   "pixelfragment" "precise" "precision" "premerge" "priv"
;   "protected" "pub" "public" "readonly" "ref"
;   "regardless" "register" "reinterpret_cast" "require" "resource"
;   "restrict" "self" "set" "shared" "sizeof"
;   "smooth" "snorm" "static" "static_assert" "static_cast"
;   "std" "subroutine" "super" "target" "template"
;   "this" "thread_local" "throw" "trait" "try"
;   "type" "typedef" "typeid" "typename" "typeof"
;   "union" "unless" "unorm" "unsafe" "unsized"
;   "use" "using" "varying" "virtual" "volatile"
;   "wgsl" "where" "with" "writeonly" "yield" 
; ] @keyword
