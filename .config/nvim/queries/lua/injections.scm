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
