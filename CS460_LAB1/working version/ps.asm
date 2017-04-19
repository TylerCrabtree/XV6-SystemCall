
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "types.h"
//Altered file (important!)
// this is the main file for the 'ps' command 

int main(){
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	56                   	push   %esi
   e:	53                   	push   %ebx
   f:	51                   	push   %ecx
  10:	83 ec 4c             	sub    $0x4c,%esp

struct uproc *u;
int limit=5;
  13:	c7 45 dc 05 00 00 00 	movl   $0x5,-0x24(%ebp)
struct uproc table[limit];
  1a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1d:	8d 41 ff             	lea    -0x1(%ecx),%eax
  20:	89 45 d8             	mov    %eax,-0x28(%ebp)
  23:	89 c8                	mov    %ecx,%eax
  25:	ba 00 00 00 00       	mov    $0x0,%edx
  2a:	69 f2 e0 00 00 00    	imul   $0xe0,%edx,%esi
  30:	6b d8 00             	imul   $0x0,%eax,%ebx
  33:	01 f3                	add    %esi,%ebx
  35:	be e0 00 00 00       	mov    $0xe0,%esi
  3a:	f7 e6                	mul    %esi
  3c:	01 d3                	add    %edx,%ebx
  3e:	89 da                	mov    %ebx,%edx
  40:	89 c8                	mov    %ecx,%eax
  42:	c1 e0 02             	shl    $0x2,%eax
  45:	89 c8                	mov    %ecx,%eax
  47:	ba 00 00 00 00       	mov    $0x0,%edx
  4c:	69 f2 e0 00 00 00    	imul   $0xe0,%edx,%esi
  52:	6b d8 00             	imul   $0x0,%eax,%ebx
  55:	01 f3                	add    %esi,%ebx
  57:	be e0 00 00 00       	mov    $0xe0,%esi
  5c:	f7 e6                	mul    %esi
  5e:	01 d3                	add    %edx,%ebx
  60:	89 da                	mov    %ebx,%edx
  62:	89 c8                	mov    %ecx,%eax
  64:	c1 e0 02             	shl    $0x2,%eax
  67:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  6e:	29 c2                	sub    %eax,%edx
  70:	89 d0                	mov    %edx,%eax
  72:	8d 50 03             	lea    0x3(%eax),%edx
  75:	b8 10 00 00 00       	mov    $0x10,%eax
  7a:	83 e8 01             	sub    $0x1,%eax
  7d:	01 d0                	add    %edx,%eax
  7f:	b9 10 00 00 00       	mov    $0x10,%ecx
  84:	ba 00 00 00 00       	mov    $0x0,%edx
  89:	f7 f1                	div    %ecx
  8b:	6b c0 10             	imul   $0x10,%eax,%eax
  8e:	29 c4                	sub    %eax,%esp
  90:	89 e0                	mov    %esp,%eax
  92:	83 c0 03             	add    $0x3,%eax
  95:	c1 e8 02             	shr    $0x2,%eax
  98:	c1 e0 02             	shl    $0x2,%eax
  9b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

int grab =0;
  9e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
int i=0;
  a5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

char *uprocstate[] = { "UNUSED", "EMBRYO", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE" };
  ac:	c7 45 ac d4 09 00 00 	movl   $0x9d4,-0x54(%ebp)
  b3:	c7 45 b0 db 09 00 00 	movl   $0x9db,-0x50(%ebp)
  ba:	c7 45 b4 e2 09 00 00 	movl   $0x9e2,-0x4c(%ebp)
  c1:	c7 45 b8 eb 09 00 00 	movl   $0x9eb,-0x48(%ebp)
  c8:	c7 45 bc f4 09 00 00 	movl   $0x9f4,-0x44(%ebp)
  cf:	c7 45 c0 fc 09 00 00 	movl   $0x9fc,-0x40(%ebp)


grab=getprocs(limit,table);
  d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  d9:	83 ec 08             	sub    $0x8,%esp
  dc:	50                   	push   %eax
  dd:	ff 75 dc             	pushl  -0x24(%ebp)
  e0:	e8 5a 04 00 00       	call   53f <getprocs>
  e5:	83 c4 10             	add    $0x10,%esp
  e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
struct uproc table1[grab];
  eb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  ee:	8d 41 ff             	lea    -0x1(%ecx),%eax
  f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  f4:	89 c8                	mov    %ecx,%eax
  f6:	ba 00 00 00 00       	mov    $0x0,%edx
  fb:	69 f2 e0 00 00 00    	imul   $0xe0,%edx,%esi
 101:	6b d8 00             	imul   $0x0,%eax,%ebx
 104:	01 f3                	add    %esi,%ebx
 106:	be e0 00 00 00       	mov    $0xe0,%esi
 10b:	f7 e6                	mul    %esi
 10d:	01 d3                	add    %edx,%ebx
 10f:	89 da                	mov    %ebx,%edx
 111:	89 c8                	mov    %ecx,%eax
 113:	c1 e0 02             	shl    $0x2,%eax
 116:	89 c8                	mov    %ecx,%eax
 118:	ba 00 00 00 00       	mov    $0x0,%edx
 11d:	69 f2 e0 00 00 00    	imul   $0xe0,%edx,%esi
 123:	6b d8 00             	imul   $0x0,%eax,%ebx
 126:	01 f3                	add    %esi,%ebx
 128:	be e0 00 00 00       	mov    $0xe0,%esi
 12d:	f7 e6                	mul    %esi
 12f:	01 d3                	add    %edx,%ebx
 131:	89 da                	mov    %ebx,%edx
 133:	89 c8                	mov    %ecx,%eax
 135:	c1 e0 02             	shl    $0x2,%eax
 138:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 13f:	29 c2                	sub    %eax,%edx
 141:	89 d0                	mov    %edx,%eax
 143:	8d 50 03             	lea    0x3(%eax),%edx
 146:	b8 10 00 00 00       	mov    $0x10,%eax
 14b:	83 e8 01             	sub    $0x1,%eax
 14e:	01 d0                	add    %edx,%eax
 150:	b9 10 00 00 00       	mov    $0x10,%ecx
 155:	ba 00 00 00 00       	mov    $0x0,%edx
 15a:	f7 f1                	div    %ecx
 15c:	6b c0 10             	imul   $0x10,%eax,%eax
 15f:	29 c4                	sub    %eax,%esp
 161:	89 e0                	mov    %esp,%eax
 163:	83 c0 03             	add    $0x3,%eax
 166:	c1 e8 02             	shr    $0x2,%eax
 169:	c1 e0 02             	shl    $0x2,%eax
 16c:	89 45 c8             	mov    %eax,-0x38(%ebp)
grab= getprocs(grab,table1);
 16f:	8b 45 c8             	mov    -0x38(%ebp),%eax
 172:	83 ec 08             	sub    $0x8,%esp
 175:	50                   	push   %eax
 176:	ff 75 d0             	pushl  -0x30(%ebp)
 179:	e8 c1 03 00 00       	call   53f <getprocs>
 17e:	83 c4 10             	add    $0x10,%esp
 181:	89 45 d0             	mov    %eax,-0x30(%ebp)
// this is where the user sees the system call being evoked!
printf(1,"'ps' command evoked!\n"); 
 184:	83 ec 08             	sub    $0x8,%esp
 187:	68 03 0a 00 00       	push   $0xa03
 18c:	6a 01                	push   $0x1
 18e:	e8 8b 04 00 00       	call   61e <printf>
 193:	83 c4 10             	add    $0x10,%esp
for(u=table1;i<grab;u++){
 196:	8b 45 c8             	mov    -0x38(%ebp),%eax
 199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 19c:	e9 84 00 00 00       	jmp    225 <main+0x225>
char *pstate=uprocstate[u->state];
 1a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1a4:	8b 40 18             	mov    0x18(%eax),%eax
 1a7:	8b 44 85 ac          	mov    -0x54(%ebp,%eax,4),%eax
 1ab:	89 45 c4             	mov    %eax,-0x3c(%ebp)
printf(1,"Name = %d ", u->name); 
 1ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1b1:	83 ec 04             	sub    $0x4,%esp
 1b4:	50                   	push   %eax
 1b5:	68 19 0a 00 00       	push   $0xa19
 1ba:	6a 01                	push   $0x1
 1bc:	e8 5d 04 00 00       	call   61e <printf>
 1c1:	83 c4 10             	add    $0x10,%esp
printf(1,"State = %d ",pstate); 
 1c4:	83 ec 04             	sub    $0x4,%esp
 1c7:	ff 75 c4             	pushl  -0x3c(%ebp)
 1ca:	68 24 0a 00 00       	push   $0xa24
 1cf:	6a 01                	push   $0x1
 1d1:	e8 48 04 00 00       	call   61e <printf>
 1d6:	83 c4 10             	add    $0x10,%esp
printf(1,"SZ ID = %d ",u->sz); 
 1d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1dc:	8b 40 14             	mov    0x14(%eax),%eax
 1df:	83 ec 04             	sub    $0x4,%esp
 1e2:	50                   	push   %eax
 1e3:	68 30 0a 00 00       	push   $0xa30
 1e8:	6a 01                	push   $0x1
 1ea:	e8 2f 04 00 00       	call   61e <printf>
 1ef:	83 c4 10             	add    $0x10,%esp
printf(1,"Parent ID = %d\n",u->pid); 
 1f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1f5:	8b 40 10             	mov    0x10(%eax),%eax
 1f8:	83 ec 04             	sub    $0x4,%esp
 1fb:	50                   	push   %eax
 1fc:	68 3c 0a 00 00       	push   $0xa3c
 201:	6a 01                	push   $0x1
 203:	e8 16 04 00 00       	call   61e <printf>
 208:	83 c4 10             	add    $0x10,%esp

printf(1,"\n"); 
 20b:	83 ec 08             	sub    $0x8,%esp
 20e:	68 4c 0a 00 00       	push   $0xa4c
 213:	6a 01                	push   $0x1
 215:	e8 04 04 00 00       	call   61e <printf>
 21a:	83 c4 10             	add    $0x10,%esp
i++;
 21d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
grab=getprocs(limit,table);
struct uproc table1[grab];
grab= getprocs(grab,table1);
// this is where the user sees the system call being evoked!
printf(1,"'ps' command evoked!\n"); 
for(u=table1;i<grab;u++){
 221:	83 45 e4 1c          	addl   $0x1c,-0x1c(%ebp)
 225:	8b 45 e0             	mov    -0x20(%ebp),%eax
 228:	3b 45 d0             	cmp    -0x30(%ebp),%eax
 22b:	0f 8c 70 ff ff ff    	jl     1a1 <main+0x1a1>

printf(1,"\n"); 
i++;
}

printf(1," End'ps' command!\n"); 
 231:	83 ec 08             	sub    $0x8,%esp
 234:	68 4e 0a 00 00       	push   $0xa4e
 239:	6a 01                	push   $0x1
 23b:	e8 de 03 00 00       	call   61e <printf>
 240:	83 c4 10             	add    $0x10,%esp
exit();
 243:	e8 57 02 00 00       	call   49f <exit>

00000248 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 248:	55                   	push   %ebp
 249:	89 e5                	mov    %esp,%ebp
 24b:	57                   	push   %edi
 24c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 24d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 250:	8b 55 10             	mov    0x10(%ebp),%edx
 253:	8b 45 0c             	mov    0xc(%ebp),%eax
 256:	89 cb                	mov    %ecx,%ebx
 258:	89 df                	mov    %ebx,%edi
 25a:	89 d1                	mov    %edx,%ecx
 25c:	fc                   	cld    
 25d:	f3 aa                	rep stos %al,%es:(%edi)
 25f:	89 ca                	mov    %ecx,%edx
 261:	89 fb                	mov    %edi,%ebx
 263:	89 5d 08             	mov    %ebx,0x8(%ebp)
 266:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 269:	90                   	nop
 26a:	5b                   	pop    %ebx
 26b:	5f                   	pop    %edi
 26c:	5d                   	pop    %ebp
 26d:	c3                   	ret    

0000026e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 26e:	55                   	push   %ebp
 26f:	89 e5                	mov    %esp,%ebp
 271:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 27a:	90                   	nop
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	8d 50 01             	lea    0x1(%eax),%edx
 281:	89 55 08             	mov    %edx,0x8(%ebp)
 284:	8b 55 0c             	mov    0xc(%ebp),%edx
 287:	8d 4a 01             	lea    0x1(%edx),%ecx
 28a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 28d:	0f b6 12             	movzbl (%edx),%edx
 290:	88 10                	mov    %dl,(%eax)
 292:	0f b6 00             	movzbl (%eax),%eax
 295:	84 c0                	test   %al,%al
 297:	75 e2                	jne    27b <strcpy+0xd>
    ;
  return os;
 299:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29c:	c9                   	leave  
 29d:	c3                   	ret    

0000029e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 29e:	55                   	push   %ebp
 29f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2a1:	eb 08                	jmp    2ab <strcmp+0xd>
    p++, q++;
 2a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2a7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
 2ae:	0f b6 00             	movzbl (%eax),%eax
 2b1:	84 c0                	test   %al,%al
 2b3:	74 10                	je     2c5 <strcmp+0x27>
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 10             	movzbl (%eax),%edx
 2bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2be:	0f b6 00             	movzbl (%eax),%eax
 2c1:	38 c2                	cmp    %al,%dl
 2c3:	74 de                	je     2a3 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	0f b6 00             	movzbl (%eax),%eax
 2cb:	0f b6 d0             	movzbl %al,%edx
 2ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d1:	0f b6 00             	movzbl (%eax),%eax
 2d4:	0f b6 c0             	movzbl %al,%eax
 2d7:	29 c2                	sub    %eax,%edx
 2d9:	89 d0                	mov    %edx,%eax
}
 2db:	5d                   	pop    %ebp
 2dc:	c3                   	ret    

000002dd <strlen>:

uint
strlen(char *s)
{
 2dd:	55                   	push   %ebp
 2de:	89 e5                	mov    %esp,%ebp
 2e0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2e3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2ea:	eb 04                	jmp    2f0 <strlen+0x13>
 2ec:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f3:	8b 45 08             	mov    0x8(%ebp),%eax
 2f6:	01 d0                	add    %edx,%eax
 2f8:	0f b6 00             	movzbl (%eax),%eax
 2fb:	84 c0                	test   %al,%al
 2fd:	75 ed                	jne    2ec <strlen+0xf>
    ;
  return n;
 2ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 302:	c9                   	leave  
 303:	c3                   	ret    

00000304 <memset>:

void*
memset(void *dst, int c, uint n)
{
 304:	55                   	push   %ebp
 305:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 307:	8b 45 10             	mov    0x10(%ebp),%eax
 30a:	50                   	push   %eax
 30b:	ff 75 0c             	pushl  0xc(%ebp)
 30e:	ff 75 08             	pushl  0x8(%ebp)
 311:	e8 32 ff ff ff       	call   248 <stosb>
 316:	83 c4 0c             	add    $0xc,%esp
  return dst;
 319:	8b 45 08             	mov    0x8(%ebp),%eax
}
 31c:	c9                   	leave  
 31d:	c3                   	ret    

0000031e <strchr>:

char*
strchr(const char *s, char c)
{
 31e:	55                   	push   %ebp
 31f:	89 e5                	mov    %esp,%ebp
 321:	83 ec 04             	sub    $0x4,%esp
 324:	8b 45 0c             	mov    0xc(%ebp),%eax
 327:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 32a:	eb 14                	jmp    340 <strchr+0x22>
    if(*s == c)
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	0f b6 00             	movzbl (%eax),%eax
 332:	3a 45 fc             	cmp    -0x4(%ebp),%al
 335:	75 05                	jne    33c <strchr+0x1e>
      return (char*)s;
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	eb 13                	jmp    34f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 33c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 340:	8b 45 08             	mov    0x8(%ebp),%eax
 343:	0f b6 00             	movzbl (%eax),%eax
 346:	84 c0                	test   %al,%al
 348:	75 e2                	jne    32c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 34a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 34f:	c9                   	leave  
 350:	c3                   	ret    

00000351 <gets>:

char*
gets(char *buf, int max)
{
 351:	55                   	push   %ebp
 352:	89 e5                	mov    %esp,%ebp
 354:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 357:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 35e:	eb 42                	jmp    3a2 <gets+0x51>
    cc = read(0, &c, 1);
 360:	83 ec 04             	sub    $0x4,%esp
 363:	6a 01                	push   $0x1
 365:	8d 45 ef             	lea    -0x11(%ebp),%eax
 368:	50                   	push   %eax
 369:	6a 00                	push   $0x0
 36b:	e8 47 01 00 00       	call   4b7 <read>
 370:	83 c4 10             	add    $0x10,%esp
 373:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 376:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 37a:	7e 33                	jle    3af <gets+0x5e>
      break;
    buf[i++] = c;
 37c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37f:	8d 50 01             	lea    0x1(%eax),%edx
 382:	89 55 f4             	mov    %edx,-0xc(%ebp)
 385:	89 c2                	mov    %eax,%edx
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	01 c2                	add    %eax,%edx
 38c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 390:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 392:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 396:	3c 0a                	cmp    $0xa,%al
 398:	74 16                	je     3b0 <gets+0x5f>
 39a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 39e:	3c 0d                	cmp    $0xd,%al
 3a0:	74 0e                	je     3b0 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a5:	83 c0 01             	add    $0x1,%eax
 3a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3ab:	7c b3                	jl     360 <gets+0xf>
 3ad:	eb 01                	jmp    3b0 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3af:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3b3:	8b 45 08             	mov    0x8(%ebp),%eax
 3b6:	01 d0                	add    %edx,%eax
 3b8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3be:	c9                   	leave  
 3bf:	c3                   	ret    

000003c0 <stat>:

int
stat(char *n, struct stat *st)
{
 3c0:	55                   	push   %ebp
 3c1:	89 e5                	mov    %esp,%ebp
 3c3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c6:	83 ec 08             	sub    $0x8,%esp
 3c9:	6a 00                	push   $0x0
 3cb:	ff 75 08             	pushl  0x8(%ebp)
 3ce:	e8 0c 01 00 00       	call   4df <open>
 3d3:	83 c4 10             	add    $0x10,%esp
 3d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3dd:	79 07                	jns    3e6 <stat+0x26>
    return -1;
 3df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3e4:	eb 25                	jmp    40b <stat+0x4b>
  r = fstat(fd, st);
 3e6:	83 ec 08             	sub    $0x8,%esp
 3e9:	ff 75 0c             	pushl  0xc(%ebp)
 3ec:	ff 75 f4             	pushl  -0xc(%ebp)
 3ef:	e8 03 01 00 00       	call   4f7 <fstat>
 3f4:	83 c4 10             	add    $0x10,%esp
 3f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3fa:	83 ec 0c             	sub    $0xc,%esp
 3fd:	ff 75 f4             	pushl  -0xc(%ebp)
 400:	e8 c2 00 00 00       	call   4c7 <close>
 405:	83 c4 10             	add    $0x10,%esp
  return r;
 408:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 40b:	c9                   	leave  
 40c:	c3                   	ret    

0000040d <atoi>:

int
atoi(const char *s)
{
 40d:	55                   	push   %ebp
 40e:	89 e5                	mov    %esp,%ebp
 410:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 413:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 41a:	eb 25                	jmp    441 <atoi+0x34>
    n = n*10 + *s++ - '0';
 41c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 41f:	89 d0                	mov    %edx,%eax
 421:	c1 e0 02             	shl    $0x2,%eax
 424:	01 d0                	add    %edx,%eax
 426:	01 c0                	add    %eax,%eax
 428:	89 c1                	mov    %eax,%ecx
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	8d 50 01             	lea    0x1(%eax),%edx
 430:	89 55 08             	mov    %edx,0x8(%ebp)
 433:	0f b6 00             	movzbl (%eax),%eax
 436:	0f be c0             	movsbl %al,%eax
 439:	01 c8                	add    %ecx,%eax
 43b:	83 e8 30             	sub    $0x30,%eax
 43e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 441:	8b 45 08             	mov    0x8(%ebp),%eax
 444:	0f b6 00             	movzbl (%eax),%eax
 447:	3c 2f                	cmp    $0x2f,%al
 449:	7e 0a                	jle    455 <atoi+0x48>
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
 44e:	0f b6 00             	movzbl (%eax),%eax
 451:	3c 39                	cmp    $0x39,%al
 453:	7e c7                	jle    41c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 455:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 458:	c9                   	leave  
 459:	c3                   	ret    

0000045a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 45a:	55                   	push   %ebp
 45b:	89 e5                	mov    %esp,%ebp
 45d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 460:	8b 45 08             	mov    0x8(%ebp),%eax
 463:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 466:	8b 45 0c             	mov    0xc(%ebp),%eax
 469:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 46c:	eb 17                	jmp    485 <memmove+0x2b>
    *dst++ = *src++;
 46e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 471:	8d 50 01             	lea    0x1(%eax),%edx
 474:	89 55 fc             	mov    %edx,-0x4(%ebp)
 477:	8b 55 f8             	mov    -0x8(%ebp),%edx
 47a:	8d 4a 01             	lea    0x1(%edx),%ecx
 47d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 480:	0f b6 12             	movzbl (%edx),%edx
 483:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 485:	8b 45 10             	mov    0x10(%ebp),%eax
 488:	8d 50 ff             	lea    -0x1(%eax),%edx
 48b:	89 55 10             	mov    %edx,0x10(%ebp)
 48e:	85 c0                	test   %eax,%eax
 490:	7f dc                	jg     46e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 492:	8b 45 08             	mov    0x8(%ebp),%eax
}
 495:	c9                   	leave  
 496:	c3                   	ret    

00000497 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 497:	b8 01 00 00 00       	mov    $0x1,%eax
 49c:	cd 40                	int    $0x40
 49e:	c3                   	ret    

0000049f <exit>:
SYSCALL(exit)
 49f:	b8 02 00 00 00       	mov    $0x2,%eax
 4a4:	cd 40                	int    $0x40
 4a6:	c3                   	ret    

000004a7 <wait>:
SYSCALL(wait)
 4a7:	b8 03 00 00 00       	mov    $0x3,%eax
 4ac:	cd 40                	int    $0x40
 4ae:	c3                   	ret    

000004af <pipe>:
SYSCALL(pipe)
 4af:	b8 04 00 00 00       	mov    $0x4,%eax
 4b4:	cd 40                	int    $0x40
 4b6:	c3                   	ret    

000004b7 <read>:
SYSCALL(read)
 4b7:	b8 05 00 00 00       	mov    $0x5,%eax
 4bc:	cd 40                	int    $0x40
 4be:	c3                   	ret    

000004bf <write>:
SYSCALL(write)
 4bf:	b8 10 00 00 00       	mov    $0x10,%eax
 4c4:	cd 40                	int    $0x40
 4c6:	c3                   	ret    

000004c7 <close>:
SYSCALL(close)
 4c7:	b8 15 00 00 00       	mov    $0x15,%eax
 4cc:	cd 40                	int    $0x40
 4ce:	c3                   	ret    

000004cf <kill>:
SYSCALL(kill)
 4cf:	b8 06 00 00 00       	mov    $0x6,%eax
 4d4:	cd 40                	int    $0x40
 4d6:	c3                   	ret    

000004d7 <exec>:
SYSCALL(exec)
 4d7:	b8 07 00 00 00       	mov    $0x7,%eax
 4dc:	cd 40                	int    $0x40
 4de:	c3                   	ret    

000004df <open>:
SYSCALL(open)
 4df:	b8 0f 00 00 00       	mov    $0xf,%eax
 4e4:	cd 40                	int    $0x40
 4e6:	c3                   	ret    

000004e7 <mknod>:
SYSCALL(mknod)
 4e7:	b8 11 00 00 00       	mov    $0x11,%eax
 4ec:	cd 40                	int    $0x40
 4ee:	c3                   	ret    

000004ef <unlink>:
SYSCALL(unlink)
 4ef:	b8 12 00 00 00       	mov    $0x12,%eax
 4f4:	cd 40                	int    $0x40
 4f6:	c3                   	ret    

000004f7 <fstat>:
SYSCALL(fstat)
 4f7:	b8 08 00 00 00       	mov    $0x8,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	ret    

000004ff <link>:
SYSCALL(link)
 4ff:	b8 13 00 00 00       	mov    $0x13,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	ret    

00000507 <mkdir>:
SYSCALL(mkdir)
 507:	b8 14 00 00 00       	mov    $0x14,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	ret    

0000050f <chdir>:
SYSCALL(chdir)
 50f:	b8 09 00 00 00       	mov    $0x9,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	ret    

00000517 <dup>:
SYSCALL(dup)
 517:	b8 0a 00 00 00       	mov    $0xa,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	ret    

0000051f <getpid>:
SYSCALL(getpid)
 51f:	b8 0b 00 00 00       	mov    $0xb,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	ret    

00000527 <sbrk>:
SYSCALL(sbrk)
 527:	b8 0c 00 00 00       	mov    $0xc,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	ret    

0000052f <sleep>:
SYSCALL(sleep)
 52f:	b8 0d 00 00 00       	mov    $0xd,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	ret    

00000537 <uptime>:
SYSCALL(uptime)
 537:	b8 0e 00 00 00       	mov    $0xe,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <getprocs>:
SYSCALL(getprocs)
 53f:	b8 16 00 00 00       	mov    $0x16,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 547:	55                   	push   %ebp
 548:	89 e5                	mov    %esp,%ebp
 54a:	83 ec 18             	sub    $0x18,%esp
 54d:	8b 45 0c             	mov    0xc(%ebp),%eax
 550:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 553:	83 ec 04             	sub    $0x4,%esp
 556:	6a 01                	push   $0x1
 558:	8d 45 f4             	lea    -0xc(%ebp),%eax
 55b:	50                   	push   %eax
 55c:	ff 75 08             	pushl  0x8(%ebp)
 55f:	e8 5b ff ff ff       	call   4bf <write>
 564:	83 c4 10             	add    $0x10,%esp
}
 567:	90                   	nop
 568:	c9                   	leave  
 569:	c3                   	ret    

0000056a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 56a:	55                   	push   %ebp
 56b:	89 e5                	mov    %esp,%ebp
 56d:	53                   	push   %ebx
 56e:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 571:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 578:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 57c:	74 17                	je     595 <printint+0x2b>
 57e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 582:	79 11                	jns    595 <printint+0x2b>
    neg = 1;
 584:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 58b:	8b 45 0c             	mov    0xc(%ebp),%eax
 58e:	f7 d8                	neg    %eax
 590:	89 45 ec             	mov    %eax,-0x14(%ebp)
 593:	eb 06                	jmp    59b <printint+0x31>
  } else {
    x = xx;
 595:	8b 45 0c             	mov    0xc(%ebp),%eax
 598:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 59b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5a2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5a5:	8d 41 01             	lea    0x1(%ecx),%eax
 5a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b1:	ba 00 00 00 00       	mov    $0x0,%edx
 5b6:	f7 f3                	div    %ebx
 5b8:	89 d0                	mov    %edx,%eax
 5ba:	0f b6 80 b8 0c 00 00 	movzbl 0xcb8(%eax),%eax
 5c1:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5cb:	ba 00 00 00 00       	mov    $0x0,%edx
 5d0:	f7 f3                	div    %ebx
 5d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d9:	75 c7                	jne    5a2 <printint+0x38>
  if(neg)
 5db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5df:	74 2d                	je     60e <printint+0xa4>
    buf[i++] = '-';
 5e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e4:	8d 50 01             	lea    0x1(%eax),%edx
 5e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5ea:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5ef:	eb 1d                	jmp    60e <printint+0xa4>
    putc(fd, buf[i]);
 5f1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f7:	01 d0                	add    %edx,%eax
 5f9:	0f b6 00             	movzbl (%eax),%eax
 5fc:	0f be c0             	movsbl %al,%eax
 5ff:	83 ec 08             	sub    $0x8,%esp
 602:	50                   	push   %eax
 603:	ff 75 08             	pushl  0x8(%ebp)
 606:	e8 3c ff ff ff       	call   547 <putc>
 60b:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 60e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 612:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 616:	79 d9                	jns    5f1 <printint+0x87>
    putc(fd, buf[i]);
}
 618:	90                   	nop
 619:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 61c:	c9                   	leave  
 61d:	c3                   	ret    

0000061e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 61e:	55                   	push   %ebp
 61f:	89 e5                	mov    %esp,%ebp
 621:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 624:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 62b:	8d 45 0c             	lea    0xc(%ebp),%eax
 62e:	83 c0 04             	add    $0x4,%eax
 631:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 634:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 63b:	e9 59 01 00 00       	jmp    799 <printf+0x17b>
    c = fmt[i] & 0xff;
 640:	8b 55 0c             	mov    0xc(%ebp),%edx
 643:	8b 45 f0             	mov    -0x10(%ebp),%eax
 646:	01 d0                	add    %edx,%eax
 648:	0f b6 00             	movzbl (%eax),%eax
 64b:	0f be c0             	movsbl %al,%eax
 64e:	25 ff 00 00 00       	and    $0xff,%eax
 653:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 656:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 65a:	75 2c                	jne    688 <printf+0x6a>
      if(c == '%'){
 65c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 660:	75 0c                	jne    66e <printf+0x50>
        state = '%';
 662:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 669:	e9 27 01 00 00       	jmp    795 <printf+0x177>
      } else {
        putc(fd, c);
 66e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 671:	0f be c0             	movsbl %al,%eax
 674:	83 ec 08             	sub    $0x8,%esp
 677:	50                   	push   %eax
 678:	ff 75 08             	pushl  0x8(%ebp)
 67b:	e8 c7 fe ff ff       	call   547 <putc>
 680:	83 c4 10             	add    $0x10,%esp
 683:	e9 0d 01 00 00       	jmp    795 <printf+0x177>
      }
    } else if(state == '%'){
 688:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 68c:	0f 85 03 01 00 00    	jne    795 <printf+0x177>
      if(c == 'd'){
 692:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 696:	75 1e                	jne    6b6 <printf+0x98>
        printint(fd, *ap, 10, 1);
 698:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69b:	8b 00                	mov    (%eax),%eax
 69d:	6a 01                	push   $0x1
 69f:	6a 0a                	push   $0xa
 6a1:	50                   	push   %eax
 6a2:	ff 75 08             	pushl  0x8(%ebp)
 6a5:	e8 c0 fe ff ff       	call   56a <printint>
 6aa:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ad:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b1:	e9 d8 00 00 00       	jmp    78e <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6b6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ba:	74 06                	je     6c2 <printf+0xa4>
 6bc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6c0:	75 1e                	jne    6e0 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c5:	8b 00                	mov    (%eax),%eax
 6c7:	6a 00                	push   $0x0
 6c9:	6a 10                	push   $0x10
 6cb:	50                   	push   %eax
 6cc:	ff 75 08             	pushl  0x8(%ebp)
 6cf:	e8 96 fe ff ff       	call   56a <printint>
 6d4:	83 c4 10             	add    $0x10,%esp
        ap++;
 6d7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6db:	e9 ae 00 00 00       	jmp    78e <printf+0x170>
      } else if(c == 's'){
 6e0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e4:	75 43                	jne    729 <printf+0x10b>
        s = (char*)*ap;
 6e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e9:	8b 00                	mov    (%eax),%eax
 6eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f6:	75 25                	jne    71d <printf+0xff>
          s = "(null)";
 6f8:	c7 45 f4 61 0a 00 00 	movl   $0xa61,-0xc(%ebp)
        while(*s != 0){
 6ff:	eb 1c                	jmp    71d <printf+0xff>
          putc(fd, *s);
 701:	8b 45 f4             	mov    -0xc(%ebp),%eax
 704:	0f b6 00             	movzbl (%eax),%eax
 707:	0f be c0             	movsbl %al,%eax
 70a:	83 ec 08             	sub    $0x8,%esp
 70d:	50                   	push   %eax
 70e:	ff 75 08             	pushl  0x8(%ebp)
 711:	e8 31 fe ff ff       	call   547 <putc>
 716:	83 c4 10             	add    $0x10,%esp
          s++;
 719:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 71d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 720:	0f b6 00             	movzbl (%eax),%eax
 723:	84 c0                	test   %al,%al
 725:	75 da                	jne    701 <printf+0xe3>
 727:	eb 65                	jmp    78e <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 729:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 72d:	75 1d                	jne    74c <printf+0x12e>
        putc(fd, *ap);
 72f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 732:	8b 00                	mov    (%eax),%eax
 734:	0f be c0             	movsbl %al,%eax
 737:	83 ec 08             	sub    $0x8,%esp
 73a:	50                   	push   %eax
 73b:	ff 75 08             	pushl  0x8(%ebp)
 73e:	e8 04 fe ff ff       	call   547 <putc>
 743:	83 c4 10             	add    $0x10,%esp
        ap++;
 746:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74a:	eb 42                	jmp    78e <printf+0x170>
      } else if(c == '%'){
 74c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 750:	75 17                	jne    769 <printf+0x14b>
        putc(fd, c);
 752:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 755:	0f be c0             	movsbl %al,%eax
 758:	83 ec 08             	sub    $0x8,%esp
 75b:	50                   	push   %eax
 75c:	ff 75 08             	pushl  0x8(%ebp)
 75f:	e8 e3 fd ff ff       	call   547 <putc>
 764:	83 c4 10             	add    $0x10,%esp
 767:	eb 25                	jmp    78e <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 769:	83 ec 08             	sub    $0x8,%esp
 76c:	6a 25                	push   $0x25
 76e:	ff 75 08             	pushl  0x8(%ebp)
 771:	e8 d1 fd ff ff       	call   547 <putc>
 776:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 779:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77c:	0f be c0             	movsbl %al,%eax
 77f:	83 ec 08             	sub    $0x8,%esp
 782:	50                   	push   %eax
 783:	ff 75 08             	pushl  0x8(%ebp)
 786:	e8 bc fd ff ff       	call   547 <putc>
 78b:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 78e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 795:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 799:	8b 55 0c             	mov    0xc(%ebp),%edx
 79c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79f:	01 d0                	add    %edx,%eax
 7a1:	0f b6 00             	movzbl (%eax),%eax
 7a4:	84 c0                	test   %al,%al
 7a6:	0f 85 94 fe ff ff    	jne    640 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7ac:	90                   	nop
 7ad:	c9                   	leave  
 7ae:	c3                   	ret    

000007af <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7af:	55                   	push   %ebp
 7b0:	89 e5                	mov    %esp,%ebp
 7b2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b5:	8b 45 08             	mov    0x8(%ebp),%eax
 7b8:	83 e8 08             	sub    $0x8,%eax
 7bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7be:	a1 d4 0c 00 00       	mov    0xcd4,%eax
 7c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c6:	eb 24                	jmp    7ec <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	8b 00                	mov    (%eax),%eax
 7cd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d0:	77 12                	ja     7e4 <free+0x35>
 7d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d8:	77 24                	ja     7fe <free+0x4f>
 7da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dd:	8b 00                	mov    (%eax),%eax
 7df:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e2:	77 1a                	ja     7fe <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e7:	8b 00                	mov    (%eax),%eax
 7e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ef:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f2:	76 d4                	jbe    7c8 <free+0x19>
 7f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f7:	8b 00                	mov    (%eax),%eax
 7f9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7fc:	76 ca                	jbe    7c8 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 801:	8b 40 04             	mov    0x4(%eax),%eax
 804:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 80b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80e:	01 c2                	add    %eax,%edx
 810:	8b 45 fc             	mov    -0x4(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	39 c2                	cmp    %eax,%edx
 817:	75 24                	jne    83d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 819:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81c:	8b 50 04             	mov    0x4(%eax),%edx
 81f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 822:	8b 00                	mov    (%eax),%eax
 824:	8b 40 04             	mov    0x4(%eax),%eax
 827:	01 c2                	add    %eax,%edx
 829:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	8b 00                	mov    (%eax),%eax
 834:	8b 10                	mov    (%eax),%edx
 836:	8b 45 f8             	mov    -0x8(%ebp),%eax
 839:	89 10                	mov    %edx,(%eax)
 83b:	eb 0a                	jmp    847 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 83d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 840:	8b 10                	mov    (%eax),%edx
 842:	8b 45 f8             	mov    -0x8(%ebp),%eax
 845:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 847:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84a:	8b 40 04             	mov    0x4(%eax),%eax
 84d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 854:	8b 45 fc             	mov    -0x4(%ebp),%eax
 857:	01 d0                	add    %edx,%eax
 859:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 85c:	75 20                	jne    87e <free+0xcf>
    p->s.size += bp->s.size;
 85e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 861:	8b 50 04             	mov    0x4(%eax),%edx
 864:	8b 45 f8             	mov    -0x8(%ebp),%eax
 867:	8b 40 04             	mov    0x4(%eax),%eax
 86a:	01 c2                	add    %eax,%edx
 86c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 872:	8b 45 f8             	mov    -0x8(%ebp),%eax
 875:	8b 10                	mov    (%eax),%edx
 877:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87a:	89 10                	mov    %edx,(%eax)
 87c:	eb 08                	jmp    886 <free+0xd7>
  } else
    p->s.ptr = bp;
 87e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 881:	8b 55 f8             	mov    -0x8(%ebp),%edx
 884:	89 10                	mov    %edx,(%eax)
  freep = p;
 886:	8b 45 fc             	mov    -0x4(%ebp),%eax
 889:	a3 d4 0c 00 00       	mov    %eax,0xcd4
}
 88e:	90                   	nop
 88f:	c9                   	leave  
 890:	c3                   	ret    

00000891 <morecore>:

static Header*
morecore(uint nu)
{
 891:	55                   	push   %ebp
 892:	89 e5                	mov    %esp,%ebp
 894:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 897:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 89e:	77 07                	ja     8a7 <morecore+0x16>
    nu = 4096;
 8a0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a7:	8b 45 08             	mov    0x8(%ebp),%eax
 8aa:	c1 e0 03             	shl    $0x3,%eax
 8ad:	83 ec 0c             	sub    $0xc,%esp
 8b0:	50                   	push   %eax
 8b1:	e8 71 fc ff ff       	call   527 <sbrk>
 8b6:	83 c4 10             	add    $0x10,%esp
 8b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8bc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c0:	75 07                	jne    8c9 <morecore+0x38>
    return 0;
 8c2:	b8 00 00 00 00       	mov    $0x0,%eax
 8c7:	eb 26                	jmp    8ef <morecore+0x5e>
  hp = (Header*)p;
 8c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d2:	8b 55 08             	mov    0x8(%ebp),%edx
 8d5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8db:	83 c0 08             	add    $0x8,%eax
 8de:	83 ec 0c             	sub    $0xc,%esp
 8e1:	50                   	push   %eax
 8e2:	e8 c8 fe ff ff       	call   7af <free>
 8e7:	83 c4 10             	add    $0x10,%esp
  return freep;
 8ea:	a1 d4 0c 00 00       	mov    0xcd4,%eax
}
 8ef:	c9                   	leave  
 8f0:	c3                   	ret    

000008f1 <malloc>:

void*
malloc(uint nbytes)
{
 8f1:	55                   	push   %ebp
 8f2:	89 e5                	mov    %esp,%ebp
 8f4:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f7:	8b 45 08             	mov    0x8(%ebp),%eax
 8fa:	83 c0 07             	add    $0x7,%eax
 8fd:	c1 e8 03             	shr    $0x3,%eax
 900:	83 c0 01             	add    $0x1,%eax
 903:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 906:	a1 d4 0c 00 00       	mov    0xcd4,%eax
 90b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 912:	75 23                	jne    937 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 914:	c7 45 f0 cc 0c 00 00 	movl   $0xccc,-0x10(%ebp)
 91b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91e:	a3 d4 0c 00 00       	mov    %eax,0xcd4
 923:	a1 d4 0c 00 00       	mov    0xcd4,%eax
 928:	a3 cc 0c 00 00       	mov    %eax,0xccc
    base.s.size = 0;
 92d:	c7 05 d0 0c 00 00 00 	movl   $0x0,0xcd0
 934:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 937:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93a:	8b 00                	mov    (%eax),%eax
 93c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 942:	8b 40 04             	mov    0x4(%eax),%eax
 945:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 948:	72 4d                	jb     997 <malloc+0xa6>
      if(p->s.size == nunits)
 94a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94d:	8b 40 04             	mov    0x4(%eax),%eax
 950:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 953:	75 0c                	jne    961 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 955:	8b 45 f4             	mov    -0xc(%ebp),%eax
 958:	8b 10                	mov    (%eax),%edx
 95a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95d:	89 10                	mov    %edx,(%eax)
 95f:	eb 26                	jmp    987 <malloc+0x96>
      else {
        p->s.size -= nunits;
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	8b 40 04             	mov    0x4(%eax),%eax
 967:	2b 45 ec             	sub    -0x14(%ebp),%eax
 96a:	89 c2                	mov    %eax,%edx
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 972:	8b 45 f4             	mov    -0xc(%ebp),%eax
 975:	8b 40 04             	mov    0x4(%eax),%eax
 978:	c1 e0 03             	shl    $0x3,%eax
 97b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 981:	8b 55 ec             	mov    -0x14(%ebp),%edx
 984:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 987:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98a:	a3 d4 0c 00 00       	mov    %eax,0xcd4
      return (void*)(p + 1);
 98f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 992:	83 c0 08             	add    $0x8,%eax
 995:	eb 3b                	jmp    9d2 <malloc+0xe1>
    }
    if(p == freep)
 997:	a1 d4 0c 00 00       	mov    0xcd4,%eax
 99c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99f:	75 1e                	jne    9bf <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9a1:	83 ec 0c             	sub    $0xc,%esp
 9a4:	ff 75 ec             	pushl  -0x14(%ebp)
 9a7:	e8 e5 fe ff ff       	call   891 <morecore>
 9ac:	83 c4 10             	add    $0x10,%esp
 9af:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b6:	75 07                	jne    9bf <malloc+0xce>
        return 0;
 9b8:	b8 00 00 00 00       	mov    $0x0,%eax
 9bd:	eb 13                	jmp    9d2 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	8b 00                	mov    (%eax),%eax
 9ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9cd:	e9 6d ff ff ff       	jmp    93f <malloc+0x4e>
}
 9d2:	c9                   	leave  
 9d3:	c3                   	ret    
