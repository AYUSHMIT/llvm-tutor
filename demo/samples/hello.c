#include <stdio.h>

int square(int x) {
    return x * x;
}

int main() {
    int a = 3;
    int b = square(a);
    printf("Hello, LLVM! %d\n", b);
    return 0;
}
