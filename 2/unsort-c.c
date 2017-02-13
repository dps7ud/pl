#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct node {
    char * head;
    char * val;
    struct node * tail;
} ;

int main(int argc, char** argv) {
    FILE *input;
    char *inName = argv[1];
    char buffer[80];
    struct node * lines = NULL; 
    int line_count = 0;
    char filename[80];

    strcpy(filename, argv[1]);
    strcat(filename, "-lex'");

    input = fopen(inName, "r");
//    while(EOF != fscanf(input, "%s", buffer)){
    while( fgets(buffer, 80, input) ){
        struct node * new_cell = malloc(sizeof(*new_cell)); 
        new_cell -> head = strdup(buffer); 
        /* In a real C program we'd have to worry about freeing the memory
         * allocated by strdup (and the memory from malloc!) ... let's ignore
         * that, too. */ 
        new_cell -> tail = lines; 
        lines = new_cell; 
        line_count++;
    }
    {
        char * * array; 
        int i = 0;
        FILE * outfile;
        outfile = fopen(filename, "w");
        array = malloc(line_count * sizeof(*array));
        /* line needs sizeof(char *) bytes. */ 
        while (lines != NULL) { /* while we're not at the end */ 
            array[i] = lines->head; 
            i++; 
            lines = lines->tail; 
        } 
        //for (i=0; i<line_count; i++) {
        for (i=1; i<=line_count; i++) {
//            printf("%s\n",array[i]);
            fprintf(outfile, "%s", array[line_count - i]);
        } 
    } 
    return 0;
} 
