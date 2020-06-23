from argparse import ArgumentParser
from pycparser import c_parser
import os, lark, json, subprocess, tempfile

def parse_args():
    parser = ArgumentParser()
    
    parser.add_argument("input",
        help="input file or directory")
    
    parser.add_argument("-o",
        dest="output", metavar="output",
        help="output file (default: a.out)")
    
    parser.add_argument('-A', action='store_true', help='dump ast')
    parser.add_argument('-S', action='store_true', help='output assembly')

    parser.set_defaults(output="a.out")
    
    return parser.parse_args()

class Transformer(lark.Transformer):
    def __init__(self):
        self.vars = ''
        self.i = 0

    def start(self, _):
        return self.vars + _[0] + ';'
    
    def call(self, _):
        return f'{_[0]}({_[1]})'
    
    def args(self, _):
        return ", ".join(_)
    
    def arg(self, _):
        return str(_[1])
    
    def expr(self, _):
        return _[0]
    
    def none(self, _):
        return "0"
    
    def array(self, _):
        if len(_) == 0:
            return "0"
        '''
        self.vars += f"void *a{self.i} = {{{', '.join(_)},0}};\n"
        self.i += 1
        return f"a{self.i-1}"
        '''
        self.vars += f"void *a{self.i}[{len(_) + 1}];"
        for i, e in enumerate(_ + [0]):
            self.vars += f'a{self.i}[{i}] = {e};'
        self.i += 1
        return f"a{self.i-1}"

    def string(self, _):
        return json.dumps(eval(_[0]))

grammar = '''
start: call
call: NAME "(" args? ")"
args: arg ("," arg)*
arg: NAME "=" expr
expr: call | string | array | none
none: "None"
array: "[" [expr ("," expr)*] "]"
string: STRING

NAME: /[a-zA-Z_]\w*/
STRING : /[ubf]?r?("(?!"").*?(?<!\\\\)(\\\\\\\\)*?"|'(?!'').*?(?<!\\\\)(\\\\\\\\)*?')/i
%ignore /[\\t \\n\\f]+/
'''

cg_fmt = '''
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

typedef struct {{
    char *code;
    int x;
}} result_t;

void Emit(result_t *result, char *format, ...) {{
    #define sz 0x1000
    char code[sz];
    va_list args;
    va_start(args, format);
    vsnprintf(code, sz, format, args);
    result->code = realloc(result->code, strlen(result->code) + strlen(code) + 1);
    strcat(result->code, code);
    va_end(args);
    #undef sz
}}

{}

int main(void) {{
{}
    return 0;
}}
'''

bf = b'''#!/usr/bin/env bfmake
stk 32
#call("_main")
end
'''

try:
    codegen
except:
    with open(os.path.join(os.path.dirname(__file__), 'gen.c')) as f:
        codegen = f.read()

if __name__ == "__main__":
    args = parse_args()

    with open(args.input) as file:
        code = file.read()

    parser = c_parser.CParser()
    ast = parser.parse(code, filename=args.input)
    
    if args.A:
        ast.show()
        exit()

    parser = lark.Lark(grammar, parser='lalr', transformer=Transformer())
    lines = parser.parse(str(ast)).splitlines()
    gen = '\n'.join(f'    {line}' for line in lines)
    cg = cg_fmt.format(codegen, gen).encode()

    with tempfile.NamedTemporaryFile() as cc:
        subprocess.run(['gcc', '-xc', '-w', '-', '-o', cc.name], input=cg)
        asm = subprocess.run([cc.name], stdout=-1).stdout

    if args.S:
        with open(args.output, 'wb') as f:
            f.write((bf + asm).strip())
            exit()

    with tempfile.NamedTemporaryFile(suffix='asm') as f:
        f.write((bf + asm).strip())
        f.seek(0)
        subprocess.run(['bfmake', '-o', args.output, f.name])
        with open(args.output, 'r+') as f:
            bf = f.read()
            f.seek(0)      
            f.write('#!/usr/bin/env bfi\n' + bf)
