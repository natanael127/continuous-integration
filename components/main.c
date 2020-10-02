#include <stdio.h>
#include "strings/inc/strings.h"
#include "math/mathematics.h"

int main(void)
{
    //Testing strings
    char buffer[100];
    my_strcpy(buffer, "Testing");
    printf("(%s)\n", buffer);
    my_strcat(buffer, " my libs!");
    printf("(%s)\n", buffer);
    printf("(%i)\n", my_strcmp("abca", "abcd"));
    printf("(%i)\n", my_strcmp("abcx", "abcd"));

    //Testing math
    printf("5! = %lld\n", my_factorial(5));
    printf("0! = %lld\n", my_factorial(0));
    printf("1! = %lld\n", my_factorial(1));
    printf("C(5,2) = %lld\n", my_combination(5, 2));
    printf("P(5,2) = %lld\n", my_permutation(5, 2));
    printf("5.03 mod 1.20 = %f\n", my_fmod(5.03, 1.20));
    printf("sin(pi/2) = %f\n", my_sin(1.570796327));
    printf("sin(428) = %f\n", my_sin(428));
    printf("sin(1) = %f\n", my_sin(1));
    printf("sin(2) = %f\n", my_sin(2));
    printf("sin(4) = %f\n", my_sin(4));
    printf("sin(6) = %f\n", my_sin(6));

    return 0;
}
