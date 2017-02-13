#include <stdio.h>
int main(int argc, char **argv){
    FILE *input;
    char buffer[80];
    char *filename = argv[1];
    input = fopen(filename, "r");
    while(EOF != fscanf(input, "%s", buffer)){
        printf(buffer);
        printf("\n");
    }
    /* int fscanf?*/
}
