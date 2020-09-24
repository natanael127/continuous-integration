#include "../inc/strings.h"

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
    while(*dest++ != '\0');
    dest--;
    my_strcpy(dest, src);
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
