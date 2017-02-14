#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(){
    char* ptr = strdup("00983");
    printf("raw: %s\n", ptr);
    while(ptr[0] == '0'){
        ptr++;
    }
    printf("adj: %s\n", ptr);
    return 0;
}
