(function_call
  name: (_) @_fname
  arguments: (arguments (_) (string content: _ @luap))
  (#lua-match? @_fname "%.match$"))

(function_call
  name: (_) @_fname
  arguments: (arguments (string content: _ @luap))
  (#lua-match? @_fname ":match$") )

(function_call
  name: (_) @_fname
  arguments: (arguments (string content: _ @lua))
  (#lua-match? @_fname "exec_lua") )

((function_call
  name: [
    (identifier) @_cdef_identifier
    (_ _ (identifier) @_cdef_identifier)
  ]
  arguments: (arguments (string content: _ @c)))
  (#eq? @_cdef_identifier "cdef"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @vim)))
  (#any-of? @_vimcmd_identifier "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_exec"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @query) .))
  (#eq? @_vimcmd_identifier "vim.treesitter.query.set_query"))

((function_call
  name: (_) @language
  arguments: (arguments (string content: _ @content)) ))

;; highlight string as query if starts with `;; query`
(string content: _ @query (#lua-match? @query "^%s*;+%s?query"))

((comment) @luadoc
  (#lua-match? @luadoc "[-][-][-][%s]*@")
  (#offset! @luadoc 0 3 0 0))

; string.match("123", "%d+")
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "find" "match"))
  arguments: (arguments (_) . (string content: _ @luap)))

(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "gmatch" "gsub"))
  arguments: (arguments (_) (string content: _ @luap)))

; ("123"):match("%d+")
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "find" "match"))
    arguments: (arguments . (string content: _ @luap)))

(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "gmatch" "gsub"))
    arguments: (arguments (string content: _ @luap)))

(comment) @comment
