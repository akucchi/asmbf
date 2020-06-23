/* example codegen for bfcc
 * its able to compile program like:
 *
 *     int func() {
 *         return 5+6*10;
 *     }
 *
 *     int main() {
 *         return 0;
 *     }
 *
 * to add more features look at:
 * https://github.com/eliben/pycparser/blob/master/pycparser/c_ast.py
 */

#define REG_COUNT 6

static int regs[REG_COUNT];

int alloc_reg(void) {
    for (int i = 0; i < REG_COUNT; i++) {
        if (regs[i] == 0) {
            regs[i] = 1;
            return i + 1;
        }
    }

    return -1;    
}

void free_reg(int r) {
    regs[r - 1] = 0;
}

result_t *Constant(char *type, char *value) {
    result_t *result = malloc(sizeof(result_t));
    result->code = malloc(0);

    if (strcmp(type, "int") == 0) {
        result->x = alloc_reg();
        Emit(result, "mov r%d, %s\n", result->x, value);
    }

    return result;
}

result_t *Return(result_t *result) {
    if (result->x != 1) {
        Emit(result, "mov r1, r%d\n", result->x);
    }

    free_reg(result->x);
    Emit(result, "ret\n");
    return result;
}

result_t *BinaryOp(char *op, result_t *a, result_t *b) {
    Emit(a, "push r%d\n", a->x);
    Emit(a, "%s", b->code);
    Emit(a, "pop r%d\n", a->x);

    switch (*op) {
        case '*': Emit(a, "mul r%d, r%d\n", a->x, b->x); break;
        case '+': Emit(a, "add r%d, r%d\n", a->x, b->x); break;
        case '/': Emit(a, "div r%d, r%d\n", a->x, b->x); break;
        case '-': Emit(a, "sub r%d, r%d\n", a->x, b->x); break;
        default: fprintf(stderr, "error: unsupported op: %c\n", *op); break;
    }

    free_reg(b->x);
    return a;
}

// this should do something, but to
// make it compile simple programs, let
// it return 0 / NULL / specific values
int IdentifierType(char **names) { return 0; }
int TypeDecl(char *name, int x, int size) { return 0; }
result_t *FuncDecl(int a, int b) { return NULL; }
char *Decl(char *name, int a, int b, int c,
           result_t *d, int e, int f) { return name; }
void *Compound(void *code) { return code; }

result_t *FuncDef(char *name, int _, result_t **code) {
    result_t *result = malloc(sizeof(result_t));
    result->code = malloc(0);
    Emit(result, "@_%s\n", name);

    if (*code == 0) {
        Emit(result, "ret");
    }

    for (int i = 0; code[i]; i++) {
        Emit(result, "%s", code[i]->code);
    }

    return result;
}

void FileAST(result_t **results) {
    for (int i = 0; results[i]; i++) {
        printf("%s\n", results[i]->code);
    }
}
