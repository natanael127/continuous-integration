#include <stdio.h>
#include "strings/inc/strings.h"
#include "git-description-parser/git_describe_parser.h"
#include "math/mathematics.h"
#include "dep_header.h"

#define SECTION_SEPARATOR "====================================\n"

int main(void)
{
    //Testing git description parser
    git_description_t my_description = git_describe_parse();

    printf("Commit hash: %s\n", my_description.commit_hash_short);
    printf("Raw description: %s\n", my_description.raw_description);
    printf("Version numbers: ");
    for (int counter = 0; counter < my_description.used_version_numbers; counter++) {
        printf("%i.", my_description.version_numbers[counter]);
    }
    printf("\b \n");
    printf("There are %i commits after the last tag\n", my_description.commits_after_tag);
    if (my_description.release_candidate_number < 0) {
        printf("It's a release!\n");
    } else {
        printf("It's just the release candidate #%i\n", my_description.release_candidate_number);
    }
    if (my_description.is_dirty) {
        printf("There are uncommited changes\n");
    } else {
        printf("Working tree clean\n");
    }
    
    //Testing strings
    printf(SECTION_SEPARATOR);
    char buffer[100];
    my_strcpy(buffer, "Testing");
    printf("(%s)\n", buffer);
    my_strcat(buffer, " my libs!");
    printf("(%s)\n", buffer);
    printf("(%i)\n", my_strcmp("abca", "abcd"));
    printf("(%i)\n", my_strcmp("abcx", "abcd"));

    //Testing math
    printf(SECTION_SEPARATOR);
    printf("5! = %lld\n", my_factorial(5));
    printf("0! = %lld\n", my_factorial(0));
    printf("1! = %lld\n", my_factorial(1));
    printf("C(5,2) = %lld\n", my_combination(5, 2));
    printf("P(5,2) = %lld\n", my_permutation(5, 2));
    printf("5.03 mod 1.20 = %f\n", my_fmod(5.03, 1.20));
    printf("sin(pi/2) = %f\n", my_sin(TEST_DEPENDENCY));
    printf("sin(428) = %f\n", my_sin(428));
    printf("sin(1) = %f\n", my_sin(1));
    printf("sin(2) = %f\n", my_sin(2));
    printf("sin(4) = %f\n", my_sin(4));
    printf("sin(6) = %f\n", my_sin(6));

    return 0;
}
