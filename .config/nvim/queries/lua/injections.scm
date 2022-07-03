(function_call
  name: (_) @_fname
  arguments: (arguments (_) (string content: _ @luap))
  (#lua-match? @_fname "%.match$"))

(function_call
  name: (_) @_fname
  arguments: (arguments (string content: _ @luap))
  (#lua-match? @_fname ":match$") )

; (function_call
;   name: (_) @_fname
;   arguments: (arguments (_) (string content: _ @content))
;   (#lua-match? @_fname "parse")
;   (#set_injection_filetype_snippet_file!) )
