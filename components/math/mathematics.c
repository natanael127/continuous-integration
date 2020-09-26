#include "mathematics.h"

unsigned long long my_factorial(unsigned int n)
{
    unsigned long long result = 1;
    
    for (unsigned int counter = 1; counter <= n; counter++)
    {
        result = result * counter;
    }
    
    return result;
}

unsigned long long my_combination(unsigned int n, unsigned int r)
{
    return my_factorial(n) / ( my_factorial(r) * my_factorial(n - r) );
}

unsigned long long my_permutation(unsigned int n, unsigned int r)
{
    return my_factorial(n) / my_factorial(n - r);
}
