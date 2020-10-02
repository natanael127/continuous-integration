#include "mathematics.h"

#define CONST_PI 3.14159265358979323846264338327950288419716939937510582097494

double my_int_power(double x, long long int n)
{
    double result = 1;

    if (n < 0)
    {
        n = -n;
        if (x != 0)
        {
            x = 1.0 / x;
        }
    }

    for (long long int k = 0; k < n; k++)
    {
        result *= x;
    }

    return result;
}

double my_cos(double x)
{
    return my_sin(x + 0.5*CONST_PI);
}

double my_sin(double x)
{
    double sign = 1, acumulator = 0.0;

    // Congruent angle (-2*pi to 2*pi)
    x = my_fmod(x, 2*CONST_PI);

    // Angle (0 to 2*pi) and sin(x) = -sin(-x)
    if (x < 0)
    {
        x = -x;
        sign *= -1;
    }

    // Argument of function from 0 to pi/2
    if (x > 0.5*CONST_PI && x <= 1.0*CONST_PI)
    {
        x = CONST_PI - x;
    }
    else if (x > 1.0*CONST_PI && x <= 1.5*CONST_PI)
    {
        x = x - CONST_PI;
        sign *= -1;
    }
    else if (x > 1.5*CONST_PI && x <= 2.0*CONST_PI)
    {
        x = 2*CONST_PI - x;
        sign *= -1;
    }

    // Taylor series
    for (int k = 0; k < 33; k++)
    {
        acumulator += my_int_power(-1.0, k) * my_int_power(x, 2*k+1)/my_factorial(2*k+1);
    }

    return sign * acumulator;
}

double my_fmod(double dividend, double divisor)
{
    double quotient = dividend / divisor;

    long long int integer_quotient = (long long int) quotient;

    return dividend - ((double) integer_quotient) * divisor;
}

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
