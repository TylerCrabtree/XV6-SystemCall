#include "user.h"
#include "types.h"
//Altered file (important!)
// this is the main file for the 'ps' command 

int main(){

struct uproc *u;
int limit=5;
struct uproc table[limit];

int grab =0;
int i=0;

char *uprocstate[] = { "UNUSED", "EMBRYO", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE" };


grab=getprocs(limit,table);
struct uproc table1[grab];
grab= getprocs(grab,table1);
// this is where the user sees the system call being evoked!
printf(1,"'ps' command evoked!\n"); 
for(u=table1;i<grab;u++){
char *pstate=uprocstate[u->state];
printf(1,"Name = %d ", u->name); 
printf(1,"State = %d ",pstate); 
printf(1,"SZ ID = %d ",u->sz); 
printf(1,"Parent ID = %d\n",u->pid); 

printf(1,"\n"); 
i++;
}

printf(1," End'ps' command!\n"); 
exit();

}
