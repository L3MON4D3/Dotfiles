import vim
import re
from time import sleep

def set_gvar(gVarName, gvarValue) :
    vim.vars[gVarName] = gvarValue

def create_item_placeholders(snip) :
    itemCount = int(vim.vars['lsC'])
    snippetBody = (
        '\\begin{${1:description}}\n' + 
	'\n'.join([
	    '\t\item $' + str(i+2) for i in range(itemCount)
	]) +
        '\n\end{$1}\n' 
    )
    snip.expand_anon(snippetBody)

def create_table_head(snip) :
    columnCount = int(vim.vars['tableC'])
    snippetBody = ( 
        '\\begin{tabular}{ ' +
    	' '.join([
            '${' + str(i+1) + ':c}' for i in range(columnCount)
    	]) + ' }\n\t$0\n\\end{tabular}'
    )
    snip.expand_anon(snippetBody)

def create_table_rows(snip) :
    columnCount = int(vim.vars['tableC'])
    rowCount = int(vim.vars['rowC'])
    snippetBody = '\n'.join([
        ' & '.join([
            '$' + str(i+j*columnCount+1) for i in range(columnCount)
        ]) + r' \\\\' for j in range(rowCount)
    ])
    snip.expand_anon(snippetBody)

def char_count_same(line, char1, char2) :
    return line.count(char1) == line.count(char2)

def expand_double_quotes(snip) :
    return snip.buffer[snip.line].count('"') % 2 == 1

def expand_single_quotes(snip) :
    return snip.buffer[snip.line].count("'") % 2 == 1

def expand_backticks(snip) :
    return snip.buffer[snip.line].count("`") % 2 == 1

def inside_switch_statement(snip) :
    return re.match(
        ".*switch\(.*", 
        snip.buffer[
            get_indent_lineNr(
                snip.line,
                True,
                str(int(vim.eval("indent(\".\")")) - 4)
            ) - 1 #-1: vim.buffer zero indexed, vim buffer 1 indexed
        ]
    )

def inside_if_statement_cpp(snip) :
    return re.match(
        ".*(if \()|(else if \().*", 
        snip.buffer[
            get_indent_lineNr(
                snip.line,
                True,
                str(get_current_indent()) 
            ) - 1 #-1: vim.buffer zero indexed, vim buffer 1 indexed
        ]
    )

def get_indent_lineNr(startLine, countUp, targetIndent) :
    crtL = startLine
    while (int(vim.eval("indent(" + str(crtL) + ")")) != int(targetIndent)) and (crtL != 0) :
        if countUp : crtL = crtL - 1
        else :
            crtL = crtL + 1
    return crtL

def get_indent_of(lineNr) :
    int(vim.eval("indent(" + str(int(lineNr)) + ")"))

def get_current_indent() :
    return int(vim.eval("indent(\".\")"))

def echo(text) :
    vim.command('echom "'+str(text)+'"')

def multiline(text) :
    lines = 0
    for line in text.splitlines() :
        if counts_as_line(line, get_current_indent()) :
            lines+=1
    return lines >= 1

def counts_as_line(line, whitespaceCount) :
    pre = len(line)
    line = line.lstrip(' ')
    post = len(line)
    if pre - post != whitespaceCount :
        return False
    return re.match('^((if|for|switch)\(|.*?;$)', line) != None

def add_paras(snip, textTS) :
    i=snip.snippet_start[0]
    b=snip.buffer[i]
    snip.buffer[i] = b+'{'
    s = snip.tabstops[textTS].end[0] + 1
    snip.buffer.append(' '*(get_current_indent()-4) + '}', s)
    vim.command('normal j$l')
    snip.expand_anon('$1')

def add_paras_after(snip) :
    start = get_indent_lineNr(snip.line, True, get_current_indent()) - 1
    snip.buffer[start] = snip.buffer[start] + '{'
    
def add_paras_after_cpp(snip) :
    add_paras_after(snip)
    
def java_docstring_snip(params, returnVal, excep, snip) :
    paramLs = params.split(', ')
    excepLs = excep.split(', ')
    docString = (
        '/**\n' +
        ' * $1\n' +
        (('\n'.join([
            ' *' + ' @param ' + paramLs[i].split(' ')[1] + ' $' + str(i + 2)
            for i in range(0, len(paramLs))
        ]) + '\n') if params!='' else '') +
        (('\n'.join([
            ' *' + ' @exception ' + excepLs[i] + ' $' + str(i + 2)
            for i in range(0, len(excepLs))
        ]) + '\n') if excep!='' else '') +
        (' * @return $' + str(len(paramLs) + 2) + '\n' if returnVal != 'void' else '') +
        ' */\n'
    )
    snip.expand_anon(docString)

def cpp_docstring_snip(params, returnVal, snip) :
    params = remove_para(params)
    params = remove_str(params)
    params = remove_char(params)
    params = ''.join(params.split('='))
    paramLs = params.split(', ')
    docString = (
        '/**\n' +
        ' * $1\n' + 
        ((' * \n' + '\n'.join([
            ' * @param ' + paramLs[i].split(' ')[1] + ' $' + str(i + 2)
            for i in range(0, len(paramLs))
        ]) + '\n') if params!='' else '') +
        (' *\n * @return $' + str(len(paramLs) + 2) + '\n' if returnVal != 'void' else '') +
        ' */'
    )
    snip.expand_anon(docString)

def remove_para(line) :
    while '{' in line :
        start = line.find('{')
        end = line.find('}')
        line = line[:start] + line[end+1:]
    return line

def remove_str(line) :
    while '"' in line :
        start = line.find('"')
        end = line.find('"', start+1)
        line = line[:start] + line[end+1:]
    return line

def remove_char(line) :
    while '\'' in line :
        start = line.find('\'')
        end = line.find('\'', start+1)
        line = line[:start] + line[end+1:]
    return line

def func_postJump(snip) :
    if snip.tabstop == 7 :
        java_docstring_snip(snip.tabstops[5].current_text, snip.tabstops[3].current_text, snip.tabstops[6].current_text, snip)

def cpp_func_postJump(snip) :
    if snip.tabstop == 5 :
        cpp_docstring_snip(snip.tabstops[3].current_text, snip.tabstops[1].current_text, snip)
    if snip.tabstop == 1 :
        set_gvar('crtFuncIndent', get_current_indent())
        
def get_classname(buf) :
    return vim.current.buffer.name.split('/')[-1].split('.')[0]

def get_field_type(snip, fieldName) :
    for line in snip.buffer :
        lsp = line.split(' ')
        echo(lsp[-1])
        if lsp[-1] == (fieldName+';') :
            #cut off ';'
            return lsp[-2]
    return 'lel'
