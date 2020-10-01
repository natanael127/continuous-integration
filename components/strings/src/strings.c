#include "../inc/strings.h"

unsigned int my_strlen(const char *str)
{
    unsigned int result = 0;

    while(*str++ != '\0')
    {
        result++;
    }

    return result;
}

void my_strcpy(char *dest, const char *src)
{
    while(*src != '\0')
    {
        *dest++ = *src++;
    }

    *dest = '\0';
}

void my_strcat(char *dest, const char *src)
{
    my_strcpy(&dest[my_strlen(dest)], src);
}

char my_strcmp(const char *str1, const char *str2)
{
    while (*str1 != '\0' && *str2 != '\0' && *str1 == *str2)
    {
        str1++;
        str2++;
    }
    return (*str1) - (*str2);
}
