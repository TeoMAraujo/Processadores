int mul(int a, int b);
int factorial(int n);

int main(void) {
    int n = 7;
    int f = factorial(n);   // 5! = 120
    return f;
}
int mul(int a, int b) {
    int result = 0;
    int i;
    for (i = 0; i < b; i = i + 1) {
        result = result + a;
    }
    return result;
}
int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return mul(n, factorial(n - 1));
}
