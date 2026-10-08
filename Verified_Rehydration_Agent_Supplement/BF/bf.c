#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc,char**argv){FILE*f=fopen(argv[1],"rb");if(!f)return 2;
fseek(f,0,SEEK_END);long n=ftell(f);fseek(f,0,SEEK_SET);
char*p=malloc(n+1);fread(p,1,n,f);p[n]=0;fclose(f);
long*jmp=calloc(n,sizeof(long));long*st=calloc(n,sizeof(long));long sp=0;
for(long i=0;i<n;i++){if(p[i]=='[')st[sp++]=i;else if(p[i]==']'){long j=st[--sp];jmp[i]=j;jmp[j]=i;}}
unsigned char tape[65536]={0};long dp=0;
for(long ip=0;ip<n;ip++){switch(p[ip]){
case '>':dp++;break;case '<':dp--;break;
case '+':tape[dp]++;break;case '-':tape[dp]--;break;
case '.':putchar(tape[dp]);break;case ',':{int c=getchar();tape[dp]=(c==EOF)?0:c;}break;
case '[':if(!tape[dp])ip=jmp[ip];break;case ']':if(tape[dp])ip=jmp[ip];break;}}
return 0;}
