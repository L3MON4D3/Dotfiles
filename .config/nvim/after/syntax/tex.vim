if has('conceal')
    syn match texMathSymbol '\\{' contained conceal cchar={
    syn match texMathSymbol '\\}' contained conceal cchar=}
    syn match texMathSymbol '\\setminus' contained conceal cchar=\
    syn match texMathSymbol '\\mathcal{P}' contained conceal cchar=P
    syn match texMathSymbol '\\limits' contained conceal
    syn match texMathSymbol '\\cdot' contained conceal cchar=⋅
    syn match texMathSymbol '\\displaystyle' contained conceal
endif
