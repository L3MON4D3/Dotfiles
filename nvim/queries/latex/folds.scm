[
  (chapter)
  (part)
  (paragraph)
  (subparagraph)
  (comment_environment)
  (block_comment)
  (displayed_equation)
] @fold

((brack_group_key_value) @group
  (#make-range-extended! fold @group "start" 0 1 @group "end" 0 -1) )

(generic_environment
  (begin) @beg
  end: (end) @end
  (#make-range-extended! "fold" @beg "end" 0 1 @end "start" 0 1) )

(generic_environment
  (begin name: (_ text: (_) @name)) @beg
  (generic_command command: (_) @cname arg: (_ (text) @carg))
  end: (end) @end
  (#eq? @name "frame")
  (#eq? @cname "\\frametitle")

  (#make-range-extended! "fold" @beg "end" 0 1 @end "start" 0 1)

  (#set-from-nodetext-gsub! foldtext_start @carg "^" " [" "$" "]")
  (#set! foldtext_start_hl "@markup.heading.latex")

  (#set! priority 1001) )

(math_environment
  (begin) @beg
  end: (end) @end
  (#make-range-extended! "fold" @beg "end" 0 1 @end "start" 0 1) )

(
 (section
  text: (_) @label) @sec
  (#make-range-extended! "fold" @label "end" 0 1 @sec "end" 0 1) )
(
 (subsection
  text: (_) @label) @sec
  (#make-range-extended! "fold" @label "end" 0 1 @sec "end" 0 1) )
(
 (subsubsection
  text: (_) @label) @sec
  (#make-range-extended! "fold" @label "end" 0 1 @sec "end" 0 1) )
