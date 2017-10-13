#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int cmp(const void *p, const void *q){
    const char **a = (const char **)p;
    const char **b = (const char **)q;
    return strcmp(*a ,*b );
}

int debug(char** file, int len){
    int i;
    printf("[");
    for(i = 0; i < len; i++){
        printf("%s,",file[i]);
    }
    printf("]\n");
    return 0;
}

int getNumber(char** list, int len, char* string){
    int i;
    for(i = 0; i < len; i++){
        if(!strcmp(string, list[i])){
            return i;
        }
    }
    return -1;
}

void success(char** answer, int length){
    int i;
    for(i = 0; i < length; i++){
        printf("%s\n",answer[i]);
    } return;
    }

int main(){
    /*
    *   esize: size of everything
    *   elen : actual length of 'everything'
    *   ulen : actual length of 'uniques'
    *   everythin:   array holding input order
    *   uniques:    array holding sorted unique tasks
    *               after sorting, the indicies of this 
    *               array are paired uniquely with each task
    */
    int esize = 4;
    int elen = 0;
    int ulen = 0;
    int alen = 0;
    char ** ans;
    char ** everything;
    char ** uniques;


    /*
    *   deps: array holding the number of tasks upon which each task dependent
    *   line        : buffer used to process input
    *   i,j         : ints used for loop indexing
    */
    char line[64];
    int i,j;
    everything = (char**) malloc(esize * sizeof(char*));
    //Read tasks into 'everythin'
    while(scanf("%s",line) == 1){
        everything[elen] = (char*) malloc(strlen(line) + 1);
        strcpy(everything[elen], line);
        elen++;
        //printf("%d\n",elen);
        if(elen == esize){
            everything = realloc(everything, 2 * esize * sizeof(char*));
            esize *= 2;
        }
    }
    uniques = (char**) malloc(elen * sizeof(char*));
    ans = (char**) malloc(elen * sizeof(char*));
    // pull out a list of unique tasks
    for(i = 0; i < elen; i++){
        for(j = 0; j < ulen; j++){
            if(!strcmp(everything[i],uniques[j])){
                break;
            }
        }
        if(j == ulen){
            //printf("%s\n",everything[i]);
            uniques[ulen] = (char*) malloc(strlen(everything[i]) + 1);
            strcpy(uniques[ulen],everything[i]);
            ulen++;
        }
    }

    printf("Everything: ");
    debug(everything, elen);
    printf("Uniques: ");
    debug(uniques, ulen);
    //Sort uniques
    qsort(uniques, ulen, sizeof(uniques[0]), cmp);
    printf("Sorted: ");
    debug(uniques, ulen);
    //Build deps
    int deps [ulen];
    memset( deps, 0, ulen * sizeof(int));
    for( i = 0; i < elen; i += 2){
        j = getNumber(uniques, ulen, everything[i]);
        deps[j]++;
    }
    int k = 0;
    while(1){
        if(alen == ulen){success(ans,alen); return 0;}
        //Find first element with zero dependencies
        for(i = 0; i < ulen; i++){
            if(!deps[i]){
                //set deps[i] < 0
                deps[i]--;
                //Find all tasks depending on uniques[i]
                //  for each one, get the index and decrement 
                //  the dependency
                for(j = 1; j < elen; j += 2){
                    if(!strcmp(everything[j],uniques[i])){
                        k = getNumber(uniques, ulen, everything[j-1]);
                        deps[k]--;
                    }
                }
                //Add uniques[i] to the answer list
                ans[alen] = (char*) malloc(strlen(uniques[i]) + 1);
                strcpy(ans[alen], uniques[i]);
                alen++;
                break;
            }
        }
        if(i == ulen){printf("cycle\n"); return 0;}
    } 
    return 0;
}
