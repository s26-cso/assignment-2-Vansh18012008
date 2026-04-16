#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<dlfcn.h>

int main() 
{
    char op[10];
    int num1,num2;

    while(scanf("%s %d %d",op,&num1,&num2) == 3) 
    {
        // build library name: lib<op>.so
        char libname[20];
        sprintf(libname,"./lib%s.so",op);

        // load library
        void *handle = dlopen(libname,RTLD_LAZY);
        if(!handle) 
        {
            printf("Error loading library\n");
            continue;
        }

        // get function pointer
        int (*func)(int, int);
        func = (int (*)(int, int)) dlsym(handle, op);

        if(!func) 
        {
            printf("Error finding function\n");
            dlclose(handle);
            continue;
        }

        // call function
        int result = func(num1, num2);

        // print result
        printf("%d\n",result);

        // unload library (VERY IMPORTANT)
        dlclose(handle);
    }

    return 0;
}
