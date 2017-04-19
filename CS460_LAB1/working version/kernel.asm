
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:
8010000c:	0f 20 e0             	mov    %cr4,%eax
8010000f:	83 c8 10             	or     $0x10,%eax
80100012:	0f 22 e0             	mov    %eax,%cr4
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
8010001a:	0f 22 d8             	mov    %eax,%cr3
8010001d:	0f 20 c0             	mov    %cr0,%eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
80100025:	0f 22 c0             	mov    %eax,%cr0
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp
8010002d:	b8 f6 37 10 80       	mov    $0x801037f6,%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 b8 85 10 80       	push   $0x801085b8
80100042:	68 60 c6 10 80       	push   $0x8010c660
80100047:	e8 85 4f 00 00       	call   80104fd1 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 05 11 80       	mov    0x80110574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 05 11 80       	mov    $0x80110564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 c6 10 80       	push   $0x8010c660
801000c1:	e8 2d 4f 00 00       	call   80104ff3 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 05 11 80       	mov    0x80110574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 c6 10 80       	push   $0x8010c660
8010010c:	e8 49 4f 00 00       	call   8010505a <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 c6 10 80       	push   $0x8010c660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 ce 4b 00 00       	call   80104cfa <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 05 11 80       	mov    0x80110570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 c6 10 80       	push   $0x8010c660
80100188:	e8 cd 4e 00 00       	call   8010505a <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 bf 85 10 80       	push   $0x801085bf
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 a5 26 00 00       	call   8010288c <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 d0 85 10 80       	push   $0x801085d0
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 64 26 00 00       	call   8010288c <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 d7 85 10 80       	push   $0x801085d7
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 c6 10 80       	push   $0x8010c660
80100255:	e8 99 4d 00 00       	call   80104ff3 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 05 11 80       	mov    0x80110574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 27 4b 00 00       	call   80104de5 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 c6 10 80       	push   $0x8010c660
801002c9:	e8 8c 4d 00 00       	call   8010505a <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 b5 10 80       	push   $0x8010b5c0
801003e2:	e8 0c 4c 00 00       	call   80104ff3 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 de 85 10 80       	push   $0x801085de
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec e7 85 10 80 	movl   $0x801085e7,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 b5 10 80       	push   $0x8010b5c0
8010055b:	e8 fa 4a 00 00       	call   8010505a <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 ee 85 10 80       	push   $0x801085ee
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 fd 85 10 80       	push   $0x801085fd
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 e5 4a 00 00       	call   801050ac <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 ff 85 10 80       	push   $0x801085ff
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 35 4c 00 00       	call   80105315 <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 4c 4b 00 00       	call   80105256 <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 90 10 80       	mov    0x80109000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 9f 64 00 00       	call   80106c3e <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 92 64 00 00       	call   80106c3e <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 85 64 00 00       	call   80106c3e <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 75 64 00 00       	call   80106c3e <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 80 07 11 80       	push   $0x80110780
801007eb:	e8 03 48 00 00       	call   80104ff3 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 7d 46 00 00       	call   80104ea0 <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100845:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
8010084b:	a1 38 08 11 80       	mov    0x80110838,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100879:	a1 38 08 11 80       	mov    0x80110838,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
801008b8:	a1 34 08 11 80       	mov    0x80110834,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 3c 08 11 80    	mov    %edx,0x8011083c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 b4 07 11 80    	mov    %dl,-0x7feef84c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100912:	8b 15 34 08 11 80    	mov    0x80110834,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100924:	a3 38 08 11 80       	mov    %eax,0x80110838
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 34 08 11 80       	push   $0x80110834
80100931:	e8 af 44 00 00       	call   80104de5 <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 80 07 11 80       	push   $0x80110780
80100954:	e8 01 47 00 00       	call   8010505a <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 13 11 00 00       	call   80101a83 <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 80 07 11 80       	push   $0x80110780
80100981:	e8 6d 46 00 00       	call   80104ff3 <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 80 07 11 80       	push   $0x80110780
801009a3:	e8 b2 46 00 00       	call   8010505a <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 75 0f 00 00       	call   8010192b <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 80 07 11 80       	push   $0x80110780
801009cb:	68 34 08 11 80       	push   $0x80110834
801009d0:	e8 25 43 00 00       	call   80104cfa <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009d8:	8b 15 34 08 11 80    	mov    0x80110834,%edx
801009de:	a1 38 08 11 80       	mov    0x80110838,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 34 08 11 80       	mov    0x80110834,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 34 08 11 80    	mov    %edx,0x80110834
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 34 08 11 80       	mov    0x80110834,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 34 08 11 80       	mov    %eax,0x80110834
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 80 07 11 80       	push   $0x80110780
80100a4e:	e8 07 46 00 00       	call   8010505a <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 ca 0e 00 00       	call   8010192b <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 02 10 00 00       	call   80101a83 <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a8c:	e8 62 45 00 00       	call   80104ff3 <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 c0 b5 10 80       	push   $0x8010b5c0
80100ace:	e8 87 45 00 00       	call   8010505a <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 4a 0e 00 00       	call   8010192b <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 03 86 10 80       	push   $0x80108603
80100af7:	68 c0 b5 10 80       	push   $0x8010b5c0
80100afc:	e8 d0 44 00 00       	call   80104fd1 <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 0b 86 10 80       	push   $0x8010860b
80100b0c:	68 80 07 11 80       	push   $0x80110780
80100b11:	e8 bb 44 00 00       	call   80104fd1 <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 ec 11 11 80 70 	movl   $0x80100a70,0x801111ec
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 e8 11 11 80 5f 	movl   $0x8010095f,0x801111e8
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 56 33 00 00       	call   80103e97 <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 09 1f 00 00       	call   80102a59 <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b5f:	e8 70 29 00 00       	call   801034d4 <begin_op>
  if((ip = namei(path)) == 0){
80100b64:	83 ec 0c             	sub    $0xc,%esp
80100b67:	ff 75 08             	pushl  0x8(%ebp)
80100b6a:	e8 74 19 00 00       	call   801024e3 <namei>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b79:	75 0f                	jne    80100b8a <exec+0x34>
    end_op();
80100b7b:	e8 e0 29 00 00       	call   80103560 <end_op>
    return -1;
80100b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b85:	e9 ce 03 00 00       	jmp    80100f58 <exec+0x402>
  }
  ilock(ip);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 d8             	pushl  -0x28(%ebp)
80100b90:	e8 96 0d 00 00       	call   8010192b <ilock>
80100b95:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b98:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b9f:	6a 34                	push   $0x34
80100ba1:	6a 00                	push   $0x0
80100ba3:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100ba9:	50                   	push   %eax
80100baa:	ff 75 d8             	pushl  -0x28(%ebp)
80100bad:	e8 e1 12 00 00       	call   80101e93 <readi>
80100bb2:	83 c4 10             	add    $0x10,%esp
80100bb5:	83 f8 33             	cmp    $0x33,%eax
80100bb8:	0f 86 49 03 00 00    	jbe    80100f07 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bbe:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bc4:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bc9:	0f 85 3b 03 00 00    	jne    80100f0a <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bcf:	e8 bf 71 00 00       	call   80107d93 <setupkvm>
80100bd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bd7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bdb:	0f 84 2c 03 00 00    	je     80100f0d <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100be1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100be8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bef:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bf8:	e9 ab 00 00 00       	jmp    80100ca8 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c00:	6a 20                	push   $0x20
80100c02:	50                   	push   %eax
80100c03:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c09:	50                   	push   %eax
80100c0a:	ff 75 d8             	pushl  -0x28(%ebp)
80100c0d:	e8 81 12 00 00       	call   80101e93 <readi>
80100c12:	83 c4 10             	add    $0x10,%esp
80100c15:	83 f8 20             	cmp    $0x20,%eax
80100c18:	0f 85 f2 02 00 00    	jne    80100f10 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c1e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c24:	83 f8 01             	cmp    $0x1,%eax
80100c27:	75 71                	jne    80100c9a <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c29:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c2f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c35:	39 c2                	cmp    %eax,%edx
80100c37:	0f 82 d6 02 00 00    	jb     80100f13 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c3d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c43:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c49:	01 d0                	add    %edx,%eax
80100c4b:	83 ec 04             	sub    $0x4,%esp
80100c4e:	50                   	push   %eax
80100c4f:	ff 75 e0             	pushl  -0x20(%ebp)
80100c52:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c55:	e8 e0 74 00 00       	call   8010813a <allocuvm>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c64:	0f 84 ac 02 00 00    	je     80100f16 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c6a:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c70:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c76:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c7c:	83 ec 0c             	sub    $0xc,%esp
80100c7f:	52                   	push   %edx
80100c80:	50                   	push   %eax
80100c81:	ff 75 d8             	pushl  -0x28(%ebp)
80100c84:	51                   	push   %ecx
80100c85:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c88:	e8 d6 73 00 00       	call   80108063 <loaduvm>
80100c8d:	83 c4 20             	add    $0x20,%esp
80100c90:	85 c0                	test   %eax,%eax
80100c92:	0f 88 81 02 00 00    	js     80100f19 <exec+0x3c3>
80100c98:	eb 01                	jmp    80100c9b <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c9a:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c9b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca2:	83 c0 20             	add    $0x20,%eax
80100ca5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca8:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100caf:	0f b7 c0             	movzwl %ax,%eax
80100cb2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cb5:	0f 8f 42 ff ff ff    	jg     80100bfd <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cbb:	83 ec 0c             	sub    $0xc,%esp
80100cbe:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc1:	e8 1f 0f 00 00       	call   80101be5 <iunlockput>
80100cc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc9:	e8 92 28 00 00       	call   80103560 <end_op>
  ip = 0;
80100cce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd8:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce8:	05 00 20 00 00       	add    $0x2000,%eax
80100ced:	83 ec 04             	sub    $0x4,%esp
80100cf0:	50                   	push   %eax
80100cf1:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf7:	e8 3e 74 00 00       	call   8010813a <allocuvm>
80100cfc:	83 c4 10             	add    $0x10,%esp
80100cff:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d02:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d06:	0f 84 10 02 00 00    	je     80100f1c <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0f:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d14:	83 ec 08             	sub    $0x8,%esp
80100d17:	50                   	push   %eax
80100d18:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d1b:	e8 40 76 00 00       	call   80108360 <clearpteu>
80100d20:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d26:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d29:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d30:	e9 96 00 00 00       	jmp    80100dcb <exec+0x275>
    if(argc >= MAXARG)
80100d35:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d39:	0f 87 e0 01 00 00    	ja     80100f1f <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4c:	01 d0                	add    %edx,%eax
80100d4e:	8b 00                	mov    (%eax),%eax
80100d50:	83 ec 0c             	sub    $0xc,%esp
80100d53:	50                   	push   %eax
80100d54:	e8 4a 47 00 00       	call   801054a3 <strlen>
80100d59:	83 c4 10             	add    $0x10,%esp
80100d5c:	89 c2                	mov    %eax,%edx
80100d5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d61:	29 d0                	sub    %edx,%eax
80100d63:	83 e8 01             	sub    $0x1,%eax
80100d66:	83 e0 fc             	and    $0xfffffffc,%eax
80100d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d76:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d79:	01 d0                	add    %edx,%eax
80100d7b:	8b 00                	mov    (%eax),%eax
80100d7d:	83 ec 0c             	sub    $0xc,%esp
80100d80:	50                   	push   %eax
80100d81:	e8 1d 47 00 00       	call   801054a3 <strlen>
80100d86:	83 c4 10             	add    $0x10,%esp
80100d89:	83 c0 01             	add    $0x1,%eax
80100d8c:	89 c1                	mov    %eax,%ecx
80100d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d9b:	01 d0                	add    %edx,%eax
80100d9d:	8b 00                	mov    (%eax),%eax
80100d9f:	51                   	push   %ecx
80100da0:	50                   	push   %eax
80100da1:	ff 75 dc             	pushl  -0x24(%ebp)
80100da4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da7:	e8 6b 77 00 00       	call   80108517 <copyout>
80100dac:	83 c4 10             	add    $0x10,%esp
80100daf:	85 c0                	test   %eax,%eax
80100db1:	0f 88 6b 01 00 00    	js     80100f22 <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dba:	8d 50 03             	lea    0x3(%eax),%edx
80100dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc0:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dc7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd8:	01 d0                	add    %edx,%eax
80100dda:	8b 00                	mov    (%eax),%eax
80100ddc:	85 c0                	test   %eax,%eax
80100dde:	0f 85 51 ff ff ff    	jne    80100d35 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de7:	83 c0 03             	add    $0x3,%eax
80100dea:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100df1:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100df5:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dfc:	ff ff ff 
  ustack[1] = argc;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0b:	83 c0 01             	add    $0x1,%eax
80100e0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e23:	83 c0 04             	add    $0x4,%eax
80100e26:	c1 e0 02             	shl    $0x2,%eax
80100e29:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	83 c0 04             	add    $0x4,%eax
80100e32:	c1 e0 02             	shl    $0x2,%eax
80100e35:	50                   	push   %eax
80100e36:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e3c:	50                   	push   %eax
80100e3d:	ff 75 dc             	pushl  -0x24(%ebp)
80100e40:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e43:	e8 cf 76 00 00       	call   80108517 <copyout>
80100e48:	83 c4 10             	add    $0x10,%esp
80100e4b:	85 c0                	test   %eax,%eax
80100e4d:	0f 88 d2 00 00 00    	js     80100f25 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e53:	8b 45 08             	mov    0x8(%ebp),%eax
80100e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e5f:	eb 17                	jmp    80100e78 <exec+0x322>
    if(*s == '/')
80100e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e64:	0f b6 00             	movzbl (%eax),%eax
80100e67:	3c 2f                	cmp    $0x2f,%al
80100e69:	75 09                	jne    80100e74 <exec+0x31e>
      last = s+1;
80100e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6e:	83 c0 01             	add    $0x1,%eax
80100e71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7b:	0f b6 00             	movzbl (%eax),%eax
80100e7e:	84 c0                	test   %al,%al
80100e80:	75 df                	jne    80100e61 <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e88:	83 c0 6c             	add    $0x6c,%eax
80100e8b:	83 ec 04             	sub    $0x4,%esp
80100e8e:	6a 10                	push   $0x10
80100e90:	ff 75 f0             	pushl  -0x10(%ebp)
80100e93:	50                   	push   %eax
80100e94:	e8 c0 45 00 00       	call   80105459 <safestrcpy>
80100e99:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea2:	8b 40 04             	mov    0x4(%eax),%eax
80100ea5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eb1:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eba:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ebd:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ebf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec5:	8b 40 18             	mov    0x18(%eax),%eax
80100ec8:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ece:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ed1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed7:	8b 40 18             	mov    0x18(%eax),%eax
80100eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100edd:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ee0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee6:	83 ec 0c             	sub    $0xc,%esp
80100ee9:	50                   	push   %eax
80100eea:	e8 8b 6f 00 00       	call   80107e7a <switchuvm>
80100eef:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ef2:	83 ec 0c             	sub    $0xc,%esp
80100ef5:	ff 75 d0             	pushl  -0x30(%ebp)
80100ef8:	e8 c3 73 00 00       	call   801082c0 <freevm>
80100efd:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f00:	b8 00 00 00 00       	mov    $0x0,%eax
80100f05:	eb 51                	jmp    80100f58 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f07:	90                   	nop
80100f08:	eb 1c                	jmp    80100f26 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f0a:	90                   	nop
80100f0b:	eb 19                	jmp    80100f26 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f0d:	90                   	nop
80100f0e:	eb 16                	jmp    80100f26 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f10:	90                   	nop
80100f11:	eb 13                	jmp    80100f26 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f13:	90                   	nop
80100f14:	eb 10                	jmp    80100f26 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f16:	90                   	nop
80100f17:	eb 0d                	jmp    80100f26 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f19:	90                   	nop
80100f1a:	eb 0a                	jmp    80100f26 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f1c:	90                   	nop
80100f1d:	eb 07                	jmp    80100f26 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f1f:	90                   	nop
80100f20:	eb 04                	jmp    80100f26 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f22:	90                   	nop
80100f23:	eb 01                	jmp    80100f26 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f25:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f26:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f2a:	74 0e                	je     80100f3a <exec+0x3e4>
    freevm(pgdir);
80100f2c:	83 ec 0c             	sub    $0xc,%esp
80100f2f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f32:	e8 89 73 00 00       	call   801082c0 <freevm>
80100f37:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f3e:	74 13                	je     80100f53 <exec+0x3fd>
    iunlockput(ip);
80100f40:	83 ec 0c             	sub    $0xc,%esp
80100f43:	ff 75 d8             	pushl  -0x28(%ebp)
80100f46:	e8 9a 0c 00 00       	call   80101be5 <iunlockput>
80100f4b:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f4e:	e8 0d 26 00 00       	call   80103560 <end_op>
  }
  return -1;
80100f53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f58:	c9                   	leave  
80100f59:	c3                   	ret    

80100f5a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f5a:	55                   	push   %ebp
80100f5b:	89 e5                	mov    %esp,%ebp
80100f5d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f60:	83 ec 08             	sub    $0x8,%esp
80100f63:	68 11 86 10 80       	push   $0x80108611
80100f68:	68 40 08 11 80       	push   $0x80110840
80100f6d:	e8 5f 40 00 00       	call   80104fd1 <initlock>
80100f72:	83 c4 10             	add    $0x10,%esp
}
80100f75:	90                   	nop
80100f76:	c9                   	leave  
80100f77:	c3                   	ret    

80100f78 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void){
80100f78:	55                   	push   %ebp
80100f79:	89 e5                	mov    %esp,%ebp
80100f7b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int true = 1;
80100f7e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  int pass = 0;
80100f85:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  acquire(&ftable.lock);
80100f8c:	83 ec 0c             	sub    $0xc,%esp
80100f8f:	68 40 08 11 80       	push   $0x80110840
80100f94:	e8 5a 40 00 00       	call   80104ff3 <acquire>
80100f99:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f9c:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100fa3:	eb 2d                	jmp    80100fd2 <filealloc+0x5a>
    if(f->ref == pass){
80100fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa8:	8b 40 04             	mov    0x4(%eax),%eax
80100fab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100fae:	75 1e                	jne    80100fce <filealloc+0x56>
      f->ref = true;
80100fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100fb6:	89 50 04             	mov    %edx,0x4(%eax)
      release(&ftable.lock);
80100fb9:	83 ec 0c             	sub    $0xc,%esp
80100fbc:	68 40 08 11 80       	push   $0x80110840
80100fc1:	e8 94 40 00 00       	call   8010505a <release>
80100fc6:	83 c4 10             	add    $0x10,%esp
      return f;
80100fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fcc:	eb 23                	jmp    80100ff1 <filealloc+0x79>
filealloc(void){
  struct file *f;
  int true = 1;
  int pass = 0;
  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fce:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fd2:	b8 d4 11 11 80       	mov    $0x801111d4,%eax
80100fd7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fda:	72 c9                	jb     80100fa5 <filealloc+0x2d>
      f->ref = true;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fdc:	83 ec 0c             	sub    $0xc,%esp
80100fdf:	68 40 08 11 80       	push   $0x80110840
80100fe4:	e8 71 40 00 00       	call   8010505a <release>
80100fe9:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100ff1:	c9                   	leave  
80100ff2:	c3                   	ret    

80100ff3 <filedup>:


struct file*
filedup(struct file *f){
80100ff3:	55                   	push   %ebp
80100ff4:	89 e5                	mov    %esp,%ebp
80100ff6:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100ff9:	83 ec 0c             	sub    $0xc,%esp
80100ffc:	68 40 08 11 80       	push   $0x80110840
80101001:	e8 ed 3f 00 00       	call   80104ff3 <acquire>
80101006:	83 c4 10             	add    $0x10,%esp
  int true = 1;
80101009:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  if(f->ref < true)
80101010:	8b 45 08             	mov    0x8(%ebp),%eax
80101013:	8b 40 04             	mov    0x4(%eax),%eax
80101016:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80101019:	7d 0d                	jge    80101028 <filedup+0x35>
    panic("filedup");
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	68 18 86 10 80       	push   $0x80108618
80101023:	e8 3e f5 ff ff       	call   80100566 <panic>
  f->ref++;
80101028:	8b 45 08             	mov    0x8(%ebp),%eax
8010102b:	8b 40 04             	mov    0x4(%eax),%eax
8010102e:	8d 50 01             	lea    0x1(%eax),%edx
80101031:	8b 45 08             	mov    0x8(%ebp),%eax
80101034:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101037:	83 ec 0c             	sub    $0xc,%esp
8010103a:	68 40 08 11 80       	push   $0x80110840
8010103f:	e8 16 40 00 00       	call   8010505a <release>
80101044:	83 c4 10             	add    $0x10,%esp
  return f;
80101047:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010104a:	c9                   	leave  
8010104b:	c3                   	ret    

8010104c <fileclose>:


void
fileclose(struct file *f)
{
8010104c:	55                   	push   %ebp
8010104d:	89 e5                	mov    %esp,%ebp
8010104f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101052:	83 ec 0c             	sub    $0xc,%esp
80101055:	68 40 08 11 80       	push   $0x80110840
8010105a:	e8 94 3f 00 00       	call   80104ff3 <acquire>
8010105f:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101062:	8b 45 08             	mov    0x8(%ebp),%eax
80101065:	8b 40 04             	mov    0x4(%eax),%eax
80101068:	85 c0                	test   %eax,%eax
8010106a:	7f 0d                	jg     80101079 <fileclose+0x2d>
    panic("fileclose");
8010106c:	83 ec 0c             	sub    $0xc,%esp
8010106f:	68 20 86 10 80       	push   $0x80108620
80101074:	e8 ed f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101079:	8b 45 08             	mov    0x8(%ebp),%eax
8010107c:	8b 40 04             	mov    0x4(%eax),%eax
8010107f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101082:	8b 45 08             	mov    0x8(%ebp),%eax
80101085:	89 50 04             	mov    %edx,0x4(%eax)
80101088:	8b 45 08             	mov    0x8(%ebp),%eax
8010108b:	8b 40 04             	mov    0x4(%eax),%eax
8010108e:	85 c0                	test   %eax,%eax
80101090:	7e 15                	jle    801010a7 <fileclose+0x5b>
    release(&ftable.lock);
80101092:	83 ec 0c             	sub    $0xc,%esp
80101095:	68 40 08 11 80       	push   $0x80110840
8010109a:	e8 bb 3f 00 00       	call   8010505a <release>
8010109f:	83 c4 10             	add    $0x10,%esp
801010a2:	e9 8b 00 00 00       	jmp    80101132 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010a7:	8b 45 08             	mov    0x8(%ebp),%eax
801010aa:	8b 10                	mov    (%eax),%edx
801010ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010af:	8b 50 04             	mov    0x4(%eax),%edx
801010b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010b5:	8b 50 08             	mov    0x8(%eax),%edx
801010b8:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010bb:	8b 50 0c             	mov    0xc(%eax),%edx
801010be:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010c1:	8b 50 10             	mov    0x10(%eax),%edx
801010c4:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010c7:	8b 40 14             	mov    0x14(%eax),%eax
801010ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010cd:	8b 45 08             	mov    0x8(%ebp),%eax
801010d0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010e0:	83 ec 0c             	sub    $0xc,%esp
801010e3:	68 40 08 11 80       	push   $0x80110840
801010e8:	e8 6d 3f 00 00       	call   8010505a <release>
801010ed:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010f3:	83 f8 01             	cmp    $0x1,%eax
801010f6:	75 19                	jne    80101111 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010f8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010fc:	0f be d0             	movsbl %al,%edx
801010ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101102:	83 ec 08             	sub    $0x8,%esp
80101105:	52                   	push   %edx
80101106:	50                   	push   %eax
80101107:	e8 f4 2f 00 00       	call   80104100 <pipeclose>
8010110c:	83 c4 10             	add    $0x10,%esp
8010110f:	eb 21                	jmp    80101132 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101111:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101114:	83 f8 02             	cmp    $0x2,%eax
80101117:	75 19                	jne    80101132 <fileclose+0xe6>
    begin_op();
80101119:	e8 b6 23 00 00       	call   801034d4 <begin_op>
    iput(ff.ip);
8010111e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101121:	83 ec 0c             	sub    $0xc,%esp
80101124:	50                   	push   %eax
80101125:	e8 cb 09 00 00       	call   80101af5 <iput>
8010112a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010112d:	e8 2e 24 00 00       	call   80103560 <end_op>
  }
}
80101132:	c9                   	leave  
80101133:	c3                   	ret    

80101134 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101134:	55                   	push   %ebp
80101135:	89 e5                	mov    %esp,%ebp
80101137:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010113a:	8b 45 08             	mov    0x8(%ebp),%eax
8010113d:	8b 00                	mov    (%eax),%eax
8010113f:	83 f8 02             	cmp    $0x2,%eax
80101142:	75 40                	jne    80101184 <filestat+0x50>
    ilock(f->ip);
80101144:	8b 45 08             	mov    0x8(%ebp),%eax
80101147:	8b 40 10             	mov    0x10(%eax),%eax
8010114a:	83 ec 0c             	sub    $0xc,%esp
8010114d:	50                   	push   %eax
8010114e:	e8 d8 07 00 00       	call   8010192b <ilock>
80101153:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101156:	8b 45 08             	mov    0x8(%ebp),%eax
80101159:	8b 40 10             	mov    0x10(%eax),%eax
8010115c:	83 ec 08             	sub    $0x8,%esp
8010115f:	ff 75 0c             	pushl  0xc(%ebp)
80101162:	50                   	push   %eax
80101163:	e8 e5 0c 00 00       	call   80101e4d <stati>
80101168:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010116b:	8b 45 08             	mov    0x8(%ebp),%eax
8010116e:	8b 40 10             	mov    0x10(%eax),%eax
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	50                   	push   %eax
80101175:	e8 09 09 00 00       	call   80101a83 <iunlock>
8010117a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010117d:	b8 00 00 00 00       	mov    $0x0,%eax
80101182:	eb 05                	jmp    80101189 <filestat+0x55>
  }
  return -1;
80101184:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101189:	c9                   	leave  
8010118a:	c3                   	ret    

8010118b <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010118b:	55                   	push   %ebp
8010118c:	89 e5                	mov    %esp,%ebp
8010118e:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101191:	8b 45 08             	mov    0x8(%ebp),%eax
80101194:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101198:	84 c0                	test   %al,%al
8010119a:	75 0a                	jne    801011a6 <fileread+0x1b>
    return -1;
8010119c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011a1:	e9 9b 00 00 00       	jmp    80101241 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011a6:	8b 45 08             	mov    0x8(%ebp),%eax
801011a9:	8b 00                	mov    (%eax),%eax
801011ab:	83 f8 01             	cmp    $0x1,%eax
801011ae:	75 1a                	jne    801011ca <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011b0:	8b 45 08             	mov    0x8(%ebp),%eax
801011b3:	8b 40 0c             	mov    0xc(%eax),%eax
801011b6:	83 ec 04             	sub    $0x4,%esp
801011b9:	ff 75 10             	pushl  0x10(%ebp)
801011bc:	ff 75 0c             	pushl  0xc(%ebp)
801011bf:	50                   	push   %eax
801011c0:	e8 e3 30 00 00       	call   801042a8 <piperead>
801011c5:	83 c4 10             	add    $0x10,%esp
801011c8:	eb 77                	jmp    80101241 <fileread+0xb6>
  if(f->type == FD_INODE){
801011ca:	8b 45 08             	mov    0x8(%ebp),%eax
801011cd:	8b 00                	mov    (%eax),%eax
801011cf:	83 f8 02             	cmp    $0x2,%eax
801011d2:	75 60                	jne    80101234 <fileread+0xa9>
    ilock(f->ip);
801011d4:	8b 45 08             	mov    0x8(%ebp),%eax
801011d7:	8b 40 10             	mov    0x10(%eax),%eax
801011da:	83 ec 0c             	sub    $0xc,%esp
801011dd:	50                   	push   %eax
801011de:	e8 48 07 00 00       	call   8010192b <ilock>
801011e3:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 50 14             	mov    0x14(%eax),%edx
801011ef:	8b 45 08             	mov    0x8(%ebp),%eax
801011f2:	8b 40 10             	mov    0x10(%eax),%eax
801011f5:	51                   	push   %ecx
801011f6:	52                   	push   %edx
801011f7:	ff 75 0c             	pushl  0xc(%ebp)
801011fa:	50                   	push   %eax
801011fb:	e8 93 0c 00 00       	call   80101e93 <readi>
80101200:	83 c4 10             	add    $0x10,%esp
80101203:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101206:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010120a:	7e 11                	jle    8010121d <fileread+0x92>
      f->off += r;
8010120c:	8b 45 08             	mov    0x8(%ebp),%eax
8010120f:	8b 50 14             	mov    0x14(%eax),%edx
80101212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101215:	01 c2                	add    %eax,%edx
80101217:	8b 45 08             	mov    0x8(%ebp),%eax
8010121a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010121d:	8b 45 08             	mov    0x8(%ebp),%eax
80101220:	8b 40 10             	mov    0x10(%eax),%eax
80101223:	83 ec 0c             	sub    $0xc,%esp
80101226:	50                   	push   %eax
80101227:	e8 57 08 00 00       	call   80101a83 <iunlock>
8010122c:	83 c4 10             	add    $0x10,%esp
    return r;
8010122f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101232:	eb 0d                	jmp    80101241 <fileread+0xb6>
  }
  panic("fileread");
80101234:	83 ec 0c             	sub    $0xc,%esp
80101237:	68 2a 86 10 80       	push   $0x8010862a
8010123c:	e8 25 f3 ff ff       	call   80100566 <panic>
}
80101241:	c9                   	leave  
80101242:	c3                   	ret    

80101243 <filewrite>:

//PAGEBREAK!
int
filewrite(struct file *f, char *addr, int n)
{
80101243:	55                   	push   %ebp
80101244:	89 e5                	mov    %esp,%ebp
80101246:	53                   	push   %ebx
80101247:	83 ec 24             	sub    $0x24,%esp
  int pass = 0;
8010124a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int r;
  if(f->writable == pass)
80101251:	8b 45 08             	mov    0x8(%ebp),%eax
80101254:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101258:	0f be c0             	movsbl %al,%eax
8010125b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010125e:	75 0a                	jne    8010126a <filewrite+0x27>
    return -1;
80101260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101265:	e9 1a 01 00 00       	jmp    80101384 <filewrite+0x141>
  if(f->type == FD_PIPE)
8010126a:	8b 45 08             	mov    0x8(%ebp),%eax
8010126d:	8b 00                	mov    (%eax),%eax
8010126f:	83 f8 01             	cmp    $0x1,%eax
80101272:	75 1d                	jne    80101291 <filewrite+0x4e>
    return pipewrite(f->pipe, addr, n);
80101274:	8b 45 08             	mov    0x8(%ebp),%eax
80101277:	8b 40 0c             	mov    0xc(%eax),%eax
8010127a:	83 ec 04             	sub    $0x4,%esp
8010127d:	ff 75 10             	pushl  0x10(%ebp)
80101280:	ff 75 0c             	pushl  0xc(%ebp)
80101283:	50                   	push   %eax
80101284:	e8 21 2f 00 00       	call   801041aa <pipewrite>
80101289:	83 c4 10             	add    $0x10,%esp
8010128c:	e9 f3 00 00 00       	jmp    80101384 <filewrite+0x141>
  if(f->type == FD_INODE){
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	8b 00                	mov    (%eax),%eax
80101296:	83 f8 02             	cmp    $0x2,%eax
80101299:	0f 85 d8 00 00 00    	jne    80101377 <filewrite+0x134>
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010129f:	c7 45 e8 00 1a 00 00 	movl   $0x1a00,-0x18(%ebp)
    int i = pass;
801012a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(i < n){
801012ac:	e9 a3 00 00 00       	jmp    80101354 <filewrite+0x111>
      int n1 = n - i;
801012b1:	8b 45 10             	mov    0x10(%ebp),%eax
801012b4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012bd:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801012c0:	7e 06                	jle    801012c8 <filewrite+0x85>
        n1 = max;
801012c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c5:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012c8:	e8 07 22 00 00       	call   801034d4 <begin_op>
      ilock(f->ip);
801012cd:	8b 45 08             	mov    0x8(%ebp),%eax
801012d0:	8b 40 10             	mov    0x10(%eax),%eax
801012d3:	83 ec 0c             	sub    $0xc,%esp
801012d6:	50                   	push   %eax
801012d7:	e8 4f 06 00 00       	call   8010192b <ilock>
801012dc:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012df:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012e2:	8b 45 08             	mov    0x8(%ebp),%eax
801012e5:	8b 50 14             	mov    0x14(%eax),%edx
801012e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801012ee:	01 c3                	add    %eax,%ebx
801012f0:	8b 45 08             	mov    0x8(%ebp),%eax
801012f3:	8b 40 10             	mov    0x10(%eax),%eax
801012f6:	51                   	push   %ecx
801012f7:	52                   	push   %edx
801012f8:	53                   	push   %ebx
801012f9:	50                   	push   %eax
801012fa:	e8 eb 0c 00 00       	call   80101fea <writei>
801012ff:	83 c4 10             	add    $0x10,%esp
80101302:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101305:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80101309:	7e 11                	jle    8010131c <filewrite+0xd9>
        f->off += r;
8010130b:	8b 45 08             	mov    0x8(%ebp),%eax
8010130e:	8b 50 14             	mov    0x14(%eax),%edx
80101311:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101314:	01 c2                	add    %eax,%edx
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 58 07 00 00       	call   80101a83 <iunlock>
8010132b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010132e:	e8 2d 22 00 00       	call   80103560 <end_op>

      if(r < 0)
80101333:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80101337:	78 29                	js     80101362 <filewrite+0x11f>
        break;
      if(r != n1)
80101339:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010133c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010133f:	74 0d                	je     8010134e <filewrite+0x10b>
        panic("short filewrite");
80101341:	83 ec 0c             	sub    $0xc,%esp
80101344:	68 33 86 10 80       	push   $0x80108633
80101349:	e8 18 f2 ff ff       	call   80100566 <panic>
      i += r;
8010134e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101351:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = pass;
    while(i < n){
80101354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101357:	3b 45 10             	cmp    0x10(%ebp),%eax
8010135a:	0f 8c 51 ff ff ff    	jl     801012b1 <filewrite+0x6e>
80101360:	eb 01                	jmp    80101363 <filewrite+0x120>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101362:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101366:	3b 45 10             	cmp    0x10(%ebp),%eax
80101369:	75 05                	jne    80101370 <filewrite+0x12d>
8010136b:	8b 45 10             	mov    0x10(%ebp),%eax
8010136e:	eb 14                	jmp    80101384 <filewrite+0x141>
80101370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101375:	eb 0d                	jmp    80101384 <filewrite+0x141>
  }
  panic("filewrite");
80101377:	83 ec 0c             	sub    $0xc,%esp
8010137a:	68 43 86 10 80       	push   $0x80108643
8010137f:	e8 e2 f1 ff ff       	call   80100566 <panic>
}
80101384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101387:	c9                   	leave  
80101388:	c3                   	ret    

80101389 <readsb>:
static void itrunc(struct inode*);


void
readsb(int dev, struct superblock *sb)
{
80101389:	55                   	push   %ebp
8010138a:	89 e5                	mov    %esp,%ebp
8010138c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
 
  bp = bread(dev, 1);
8010138f:	8b 45 08             	mov    0x8(%ebp),%eax
80101392:	83 ec 08             	sub    $0x8,%esp
80101395:	6a 01                	push   $0x1
80101397:	50                   	push   %eax
80101398:	e8 19 ee ff ff       	call   801001b6 <bread>
8010139d:	83 c4 10             	add    $0x10,%esp
801013a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a6:	83 c0 18             	add    $0x18,%eax
801013a9:	83 ec 04             	sub    $0x4,%esp
801013ac:	6a 10                	push   $0x10
801013ae:	50                   	push   %eax
801013af:	ff 75 0c             	pushl  0xc(%ebp)
801013b2:	e8 5e 3f 00 00       	call   80105315 <memmove>
801013b7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ba:	83 ec 0c             	sub    $0xc,%esp
801013bd:	ff 75 f4             	pushl  -0xc(%ebp)
801013c0:	e8 69 ee ff ff       	call   8010022e <brelse>
801013c5:	83 c4 10             	add    $0x10,%esp
}
801013c8:	90                   	nop
801013c9:	c9                   	leave  
801013ca:	c3                   	ret    

801013cb <bzero>:


static void
bzero(int dev, int bno)
{
801013cb:	55                   	push   %ebp
801013cc:	89 e5                	mov    %esp,%ebp
801013ce:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013d1:	8b 55 0c             	mov    0xc(%ebp),%edx
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	52                   	push   %edx
801013db:	50                   	push   %eax
801013dc:	e8 d5 ed ff ff       	call   801001b6 <bread>
801013e1:	83 c4 10             	add    $0x10,%esp
801013e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ea:	83 c0 18             	add    $0x18,%eax
801013ed:	83 ec 04             	sub    $0x4,%esp
801013f0:	68 00 02 00 00       	push   $0x200
801013f5:	6a 00                	push   $0x0
801013f7:	50                   	push   %eax
801013f8:	e8 59 3e 00 00       	call   80105256 <memset>
801013fd:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101400:	83 ec 0c             	sub    $0xc,%esp
80101403:	ff 75 f4             	pushl  -0xc(%ebp)
80101406:	e8 01 23 00 00       	call   8010370c <log_write>
8010140b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010140e:	83 ec 0c             	sub    $0xc,%esp
80101411:	ff 75 f4             	pushl  -0xc(%ebp)
80101414:	e8 15 ee ff ff       	call   8010022e <brelse>
80101419:	83 c4 10             	add    $0x10,%esp
}
8010141c:	90                   	nop
8010141d:	c9                   	leave  
8010141e:	c3                   	ret    

8010141f <balloc>:

static uint
balloc(uint dev)
{
8010141f:	55                   	push   %ebp
80101420:	89 e5                	mov    %esp,%ebp
80101422:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101425:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010142c:	8b 45 08             	mov    0x8(%ebp),%eax
8010142f:	83 ec 08             	sub    $0x8,%esp
80101432:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101435:	52                   	push   %edx
80101436:	50                   	push   %eax
80101437:	e8 4d ff ff ff       	call   80101389 <readsb>
8010143c:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010143f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101446:	e9 15 01 00 00       	jmp    80101560 <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010144b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101454:	85 c0                	test   %eax,%eax
80101456:	0f 48 c2             	cmovs  %edx,%eax
80101459:	c1 f8 0c             	sar    $0xc,%eax
8010145c:	89 c2                	mov    %eax,%edx
8010145e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101461:	c1 e8 03             	shr    $0x3,%eax
80101464:	01 d0                	add    %edx,%eax
80101466:	83 c0 03             	add    $0x3,%eax
80101469:	83 ec 08             	sub    $0x8,%esp
8010146c:	50                   	push   %eax
8010146d:	ff 75 08             	pushl  0x8(%ebp)
80101470:	e8 41 ed ff ff       	call   801001b6 <bread>
80101475:	83 c4 10             	add    $0x10,%esp
80101478:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010147b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101482:	e9 a6 00 00 00       	jmp    8010152d <balloc+0x10e>
      m = 1 << (bi % 8);
80101487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148a:	99                   	cltd   
8010148b:	c1 ea 1d             	shr    $0x1d,%edx
8010148e:	01 d0                	add    %edx,%eax
80101490:	83 e0 07             	and    $0x7,%eax
80101493:	29 d0                	sub    %edx,%eax
80101495:	ba 01 00 00 00       	mov    $0x1,%edx
8010149a:	89 c1                	mov    %eax,%ecx
8010149c:	d3 e2                	shl    %cl,%edx
8010149e:	89 d0                	mov    %edx,%eax
801014a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a6:	8d 50 07             	lea    0x7(%eax),%edx
801014a9:	85 c0                	test   %eax,%eax
801014ab:	0f 48 c2             	cmovs  %edx,%eax
801014ae:	c1 f8 03             	sar    $0x3,%eax
801014b1:	89 c2                	mov    %eax,%edx
801014b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b6:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014bb:	0f b6 c0             	movzbl %al,%eax
801014be:	23 45 e8             	and    -0x18(%ebp),%eax
801014c1:	85 c0                	test   %eax,%eax
801014c3:	75 64                	jne    80101529 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
801014c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c8:	8d 50 07             	lea    0x7(%eax),%edx
801014cb:	85 c0                	test   %eax,%eax
801014cd:	0f 48 c2             	cmovs  %edx,%eax
801014d0:	c1 f8 03             	sar    $0x3,%eax
801014d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014d6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014db:	89 d1                	mov    %edx,%ecx
801014dd:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014e0:	09 ca                	or     %ecx,%edx
801014e2:	89 d1                	mov    %edx,%ecx
801014e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014e7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014eb:	83 ec 0c             	sub    $0xc,%esp
801014ee:	ff 75 ec             	pushl  -0x14(%ebp)
801014f1:	e8 16 22 00 00       	call   8010370c <log_write>
801014f6:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014f9:	83 ec 0c             	sub    $0xc,%esp
801014fc:	ff 75 ec             	pushl  -0x14(%ebp)
801014ff:	e8 2a ed ff ff       	call   8010022e <brelse>
80101504:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101507:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150d:	01 c2                	add    %eax,%edx
8010150f:	8b 45 08             	mov    0x8(%ebp),%eax
80101512:	83 ec 08             	sub    $0x8,%esp
80101515:	52                   	push   %edx
80101516:	50                   	push   %eax
80101517:	e8 af fe ff ff       	call   801013cb <bzero>
8010151c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010151f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101522:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101525:	01 d0                	add    %edx,%eax
80101527:	eb 52                	jmp    8010157b <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101529:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010152d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101534:	7f 15                	jg     8010154b <balloc+0x12c>
80101536:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153c:	01 d0                	add    %edx,%eax
8010153e:	89 c2                	mov    %eax,%edx
80101540:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101543:	39 c2                	cmp    %eax,%edx
80101545:	0f 82 3c ff ff ff    	jb     80101487 <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010154b:	83 ec 0c             	sub    $0xc,%esp
8010154e:	ff 75 ec             	pushl  -0x14(%ebp)
80101551:	e8 d8 ec ff ff       	call   8010022e <brelse>
80101556:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101559:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101560:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101566:	39 c2                	cmp    %eax,%edx
80101568:	0f 87 dd fe ff ff    	ja     8010144b <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("Out: out");
8010156e:	83 ec 0c             	sub    $0xc,%esp
80101571:	68 4d 86 10 80       	push   $0x8010864d
80101576:	e8 eb ef ff ff       	call   80100566 <panic>
}
8010157b:	c9                   	leave  
8010157c:	c3                   	ret    

8010157d <bfree>:


static void
bfree(int dev, uint b)
{
8010157d:	55                   	push   %ebp
8010157e:	89 e5                	mov    %esp,%ebp
80101580:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101583:	83 ec 08             	sub    $0x8,%esp
80101586:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101589:	50                   	push   %eax
8010158a:	ff 75 08             	pushl  0x8(%ebp)
8010158d:	e8 f7 fd ff ff       	call   80101389 <readsb>
80101592:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101595:	8b 45 0c             	mov    0xc(%ebp),%eax
80101598:	c1 e8 0c             	shr    $0xc,%eax
8010159b:	89 c2                	mov    %eax,%edx
8010159d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015a0:	c1 e8 03             	shr    $0x3,%eax
801015a3:	01 d0                	add    %edx,%eax
801015a5:	8d 50 03             	lea    0x3(%eax),%edx
801015a8:	8b 45 08             	mov    0x8(%ebp),%eax
801015ab:	83 ec 08             	sub    $0x8,%esp
801015ae:	52                   	push   %edx
801015af:	50                   	push   %eax
801015b0:	e8 01 ec ff ff       	call   801001b6 <bread>
801015b5:	83 c4 10             	add    $0x10,%esp
801015b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801015be:	25 ff 0f 00 00       	and    $0xfff,%eax
801015c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c9:	99                   	cltd   
801015ca:	c1 ea 1d             	shr    $0x1d,%edx
801015cd:	01 d0                	add    %edx,%eax
801015cf:	83 e0 07             	and    $0x7,%eax
801015d2:	29 d0                	sub    %edx,%eax
801015d4:	ba 01 00 00 00       	mov    $0x1,%edx
801015d9:	89 c1                	mov    %eax,%ecx
801015db:	d3 e2                	shl    %cl,%edx
801015dd:	89 d0                	mov    %edx,%eax
801015df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e5:	8d 50 07             	lea    0x7(%eax),%edx
801015e8:	85 c0                	test   %eax,%eax
801015ea:	0f 48 c2             	cmovs  %edx,%eax
801015ed:	c1 f8 03             	sar    $0x3,%eax
801015f0:	89 c2                	mov    %eax,%edx
801015f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f5:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015fa:	0f b6 c0             	movzbl %al,%eax
801015fd:	23 45 ec             	and    -0x14(%ebp),%eax
80101600:	85 c0                	test   %eax,%eax
80101602:	75 0d                	jne    80101611 <bfree+0x94>
    panic("freeing free block");
80101604:	83 ec 0c             	sub    $0xc,%esp
80101607:	68 56 86 10 80       	push   $0x80108656
8010160c:	e8 55 ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101614:	8d 50 07             	lea    0x7(%eax),%edx
80101617:	85 c0                	test   %eax,%eax
80101619:	0f 48 c2             	cmovs  %edx,%eax
8010161c:	c1 f8 03             	sar    $0x3,%eax
8010161f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101622:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101627:	89 d1                	mov    %edx,%ecx
80101629:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010162c:	f7 d2                	not    %edx
8010162e:	21 ca                	and    %ecx,%edx
80101630:	89 d1                	mov    %edx,%ecx
80101632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101635:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101639:	83 ec 0c             	sub    $0xc,%esp
8010163c:	ff 75 f4             	pushl  -0xc(%ebp)
8010163f:	e8 c8 20 00 00       	call   8010370c <log_write>
80101644:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101647:	83 ec 0c             	sub    $0xc,%esp
8010164a:	ff 75 f4             	pushl  -0xc(%ebp)
8010164d:	e8 dc eb ff ff       	call   8010022e <brelse>
80101652:	83 c4 10             	add    $0x10,%esp
}
80101655:	90                   	nop
80101656:	c9                   	leave  
80101657:	c3                   	ret    

80101658 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101658:	55                   	push   %ebp
80101659:	89 e5                	mov    %esp,%ebp
8010165b:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
8010165e:	83 ec 08             	sub    $0x8,%esp
80101661:	68 69 86 10 80       	push   $0x80108669
80101666:	68 40 12 11 80       	push   $0x80111240
8010166b:	e8 61 39 00 00       	call   80104fd1 <initlock>
80101670:	83 c4 10             	add    $0x10,%esp
}
80101673:	90                   	nop
80101674:	c9                   	leave  
80101675:	c3                   	ret    

80101676 <ialloc>:

static struct inode* iget(uint dev, uint inum);

struct inode*
ialloc(uint dev, short type)
{
80101676:	55                   	push   %ebp
80101677:	89 e5                	mov    %esp,%ebp
80101679:	83 ec 38             	sub    $0x38,%esp
8010167c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010167f:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101683:	8b 45 08             	mov    0x8(%ebp),%eax
80101686:	83 ec 08             	sub    $0x8,%esp
80101689:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010168c:	52                   	push   %edx
8010168d:	50                   	push   %eax
8010168e:	e8 f6 fc ff ff       	call   80101389 <readsb>
80101693:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101696:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010169d:	e9 98 00 00 00       	jmp    8010173a <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
801016a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a5:	c1 e8 03             	shr    $0x3,%eax
801016a8:	83 c0 02             	add    $0x2,%eax
801016ab:	83 ec 08             	sub    $0x8,%esp
801016ae:	50                   	push   %eax
801016af:	ff 75 08             	pushl  0x8(%ebp)
801016b2:	e8 ff ea ff ff       	call   801001b6 <bread>
801016b7:	83 c4 10             	add    $0x10,%esp
801016ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c0:	8d 50 18             	lea    0x18(%eax),%edx
801016c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c6:	83 e0 07             	and    $0x7,%eax
801016c9:	c1 e0 06             	shl    $0x6,%eax
801016cc:	01 d0                	add    %edx,%eax
801016ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016d4:	0f b7 00             	movzwl (%eax),%eax
801016d7:	66 85 c0             	test   %ax,%ax
801016da:	75 4c                	jne    80101728 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801016dc:	83 ec 04             	sub    $0x4,%esp
801016df:	6a 40                	push   $0x40
801016e1:	6a 00                	push   $0x0
801016e3:	ff 75 ec             	pushl  -0x14(%ebp)
801016e6:	e8 6b 3b 00 00       	call   80105256 <memset>
801016eb:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016f1:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016f5:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016f8:	83 ec 0c             	sub    $0xc,%esp
801016fb:	ff 75 f0             	pushl  -0x10(%ebp)
801016fe:	e8 09 20 00 00       	call   8010370c <log_write>
80101703:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101706:	83 ec 0c             	sub    $0xc,%esp
80101709:	ff 75 f0             	pushl  -0x10(%ebp)
8010170c:	e8 1d eb ff ff       	call   8010022e <brelse>
80101711:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101717:	83 ec 08             	sub    $0x8,%esp
8010171a:	50                   	push   %eax
8010171b:	ff 75 08             	pushl  0x8(%ebp)
8010171e:	e8 ef 00 00 00       	call   80101812 <iget>
80101723:	83 c4 10             	add    $0x10,%esp
80101726:	eb 2d                	jmp    80101755 <ialloc+0xdf>
    }
    brelse(bp);
80101728:	83 ec 0c             	sub    $0xc,%esp
8010172b:	ff 75 f0             	pushl  -0x10(%ebp)
8010172e:	e8 fb ea ff ff       	call   8010022e <brelse>
80101733:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101736:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010173a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010173d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101740:	39 c2                	cmp    %eax,%edx
80101742:	0f 87 5a ff ff ff    	ja     801016a2 <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101748:	83 ec 0c             	sub    $0xc,%esp
8010174b:	68 70 86 10 80       	push   $0x80108670
80101750:	e8 11 ee ff ff       	call   80100566 <panic>
}
80101755:	c9                   	leave  
80101756:	c3                   	ret    

80101757 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101757:	55                   	push   %ebp
80101758:	89 e5                	mov    %esp,%ebp
8010175a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010175d:	8b 45 08             	mov    0x8(%ebp),%eax
80101760:	8b 40 04             	mov    0x4(%eax),%eax
80101763:	c1 e8 03             	shr    $0x3,%eax
80101766:	8d 50 02             	lea    0x2(%eax),%edx
80101769:	8b 45 08             	mov    0x8(%ebp),%eax
8010176c:	8b 00                	mov    (%eax),%eax
8010176e:	83 ec 08             	sub    $0x8,%esp
80101771:	52                   	push   %edx
80101772:	50                   	push   %eax
80101773:	e8 3e ea ff ff       	call   801001b6 <bread>
80101778:	83 c4 10             	add    $0x10,%esp
8010177b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010177e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101781:	8d 50 18             	lea    0x18(%eax),%edx
80101784:	8b 45 08             	mov    0x8(%ebp),%eax
80101787:	8b 40 04             	mov    0x4(%eax),%eax
8010178a:	83 e0 07             	and    $0x7,%eax
8010178d:	c1 e0 06             	shl    $0x6,%eax
80101790:	01 d0                	add    %edx,%eax
80101792:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101795:	8b 45 08             	mov    0x8(%ebp),%eax
80101798:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010179c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010179f:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017a2:	8b 45 08             	mov    0x8(%ebp),%eax
801017a5:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ac:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017b0:	8b 45 08             	mov    0x8(%ebp),%eax
801017b3:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ba:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017be:	8b 45 08             	mov    0x8(%ebp),%eax
801017c1:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801017c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c8:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017cc:	8b 45 08             	mov    0x8(%ebp),%eax
801017cf:	8b 50 18             	mov    0x18(%eax),%edx
801017d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d5:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017d8:	8b 45 08             	mov    0x8(%ebp),%eax
801017db:	8d 50 1c             	lea    0x1c(%eax),%edx
801017de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e1:	83 c0 0c             	add    $0xc,%eax
801017e4:	83 ec 04             	sub    $0x4,%esp
801017e7:	6a 34                	push   $0x34
801017e9:	52                   	push   %edx
801017ea:	50                   	push   %eax
801017eb:	e8 25 3b 00 00       	call   80105315 <memmove>
801017f0:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017f3:	83 ec 0c             	sub    $0xc,%esp
801017f6:	ff 75 f4             	pushl  -0xc(%ebp)
801017f9:	e8 0e 1f 00 00       	call   8010370c <log_write>
801017fe:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101801:	83 ec 0c             	sub    $0xc,%esp
80101804:	ff 75 f4             	pushl  -0xc(%ebp)
80101807:	e8 22 ea ff ff       	call   8010022e <brelse>
8010180c:	83 c4 10             	add    $0x10,%esp
}
8010180f:	90                   	nop
80101810:	c9                   	leave  
80101811:	c3                   	ret    

80101812 <iget>:

static struct inode*
iget(uint dev, uint inum)
{
80101812:	55                   	push   %ebp
80101813:	89 e5                	mov    %esp,%ebp
80101815:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101818:	83 ec 0c             	sub    $0xc,%esp
8010181b:	68 40 12 11 80       	push   $0x80111240
80101820:	e8 ce 37 00 00       	call   80104ff3 <acquire>
80101825:	83 c4 10             	add    $0x10,%esp
  empty = 0;
80101828:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010182f:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101836:	eb 5d                	jmp    80101895 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183b:	8b 40 08             	mov    0x8(%eax),%eax
8010183e:	85 c0                	test   %eax,%eax
80101840:	7e 39                	jle    8010187b <iget+0x69>
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	8b 00                	mov    (%eax),%eax
80101847:	3b 45 08             	cmp    0x8(%ebp),%eax
8010184a:	75 2f                	jne    8010187b <iget+0x69>
8010184c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010184f:	8b 40 04             	mov    0x4(%eax),%eax
80101852:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101855:	75 24                	jne    8010187b <iget+0x69>
      ip->ref++;
80101857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185a:	8b 40 08             	mov    0x8(%eax),%eax
8010185d:	8d 50 01             	lea    0x1(%eax),%edx
80101860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101863:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101866:	83 ec 0c             	sub    $0xc,%esp
80101869:	68 40 12 11 80       	push   $0x80111240
8010186e:	e8 e7 37 00 00       	call   8010505a <release>
80101873:	83 c4 10             	add    $0x10,%esp
      return ip;
80101876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101879:	eb 74                	jmp    801018ef <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    
8010187b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010187f:	75 10                	jne    80101891 <iget+0x7f>
80101881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101884:	8b 40 08             	mov    0x8(%eax),%eax
80101887:	85 c0                	test   %eax,%eax
80101889:	75 06                	jne    80101891 <iget+0x7f>
      empty = ip;
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
  struct inode *ip, *empty;

  acquire(&icache.lock);
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101891:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101895:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
8010189c:	72 9a                	jb     80101838 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    
      empty = ip;
  }


  if(empty == 0)
8010189e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018a2:	75 0d                	jne    801018b1 <iget+0x9f>
    panic("no: none inodes found");
801018a4:	83 ec 0c             	sub    $0xc,%esp
801018a7:	68 82 86 10 80       	push   $0x80108682
801018ac:	e8 b5 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ba:	8b 55 08             	mov    0x8(%ebp),%edx
801018bd:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801018c5:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801018dc:	83 ec 0c             	sub    $0xc,%esp
801018df:	68 40 12 11 80       	push   $0x80111240
801018e4:	e8 71 37 00 00       	call   8010505a <release>
801018e9:	83 c4 10             	add    $0x10,%esp

  return ip;
801018ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018ef:	c9                   	leave  
801018f0:	c3                   	ret    

801018f1 <idup>:

struct inode*
idup(struct inode *ip)
{
801018f1:	55                   	push   %ebp
801018f2:	89 e5                	mov    %esp,%ebp
801018f4:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018f7:	83 ec 0c             	sub    $0xc,%esp
801018fa:	68 40 12 11 80       	push   $0x80111240
801018ff:	e8 ef 36 00 00       	call   80104ff3 <acquire>
80101904:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101907:	8b 45 08             	mov    0x8(%ebp),%eax
8010190a:	8b 40 08             	mov    0x8(%eax),%eax
8010190d:	8d 50 01             	lea    0x1(%eax),%edx
80101910:	8b 45 08             	mov    0x8(%ebp),%eax
80101913:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101916:	83 ec 0c             	sub    $0xc,%esp
80101919:	68 40 12 11 80       	push   $0x80111240
8010191e:	e8 37 37 00 00       	call   8010505a <release>
80101923:	83 c4 10             	add    $0x10,%esp
  return ip;
80101926:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101929:	c9                   	leave  
8010192a:	c3                   	ret    

8010192b <ilock>:

void
ilock(struct inode *ip)
{
8010192b:	55                   	push   %ebp
8010192c:	89 e5                	mov    %esp,%ebp
8010192e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101931:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101935:	74 0a                	je     80101941 <ilock+0x16>
80101937:	8b 45 08             	mov    0x8(%ebp),%eax
8010193a:	8b 40 08             	mov    0x8(%eax),%eax
8010193d:	85 c0                	test   %eax,%eax
8010193f:	7f 0d                	jg     8010194e <ilock+0x23>
    panic("ilock");
80101941:	83 ec 0c             	sub    $0xc,%esp
80101944:	68 98 86 10 80       	push   $0x80108698
80101949:	e8 18 ec ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010194e:	83 ec 0c             	sub    $0xc,%esp
80101951:	68 40 12 11 80       	push   $0x80111240
80101956:	e8 98 36 00 00       	call   80104ff3 <acquire>
8010195b:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010195e:	eb 13                	jmp    80101973 <ilock+0x48>
    sleep(ip, &icache.lock);
80101960:	83 ec 08             	sub    $0x8,%esp
80101963:	68 40 12 11 80       	push   $0x80111240
80101968:	ff 75 08             	pushl  0x8(%ebp)
8010196b:	e8 8a 33 00 00       	call   80104cfa <sleep>
80101970:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101973:	8b 45 08             	mov    0x8(%ebp),%eax
80101976:	8b 40 0c             	mov    0xc(%eax),%eax
80101979:	83 e0 01             	and    $0x1,%eax
8010197c:	85 c0                	test   %eax,%eax
8010197e:	75 e0                	jne    80101960 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101980:	8b 45 08             	mov    0x8(%ebp),%eax
80101983:	8b 40 0c             	mov    0xc(%eax),%eax
80101986:	83 c8 01             	or     $0x1,%eax
80101989:	89 c2                	mov    %eax,%edx
8010198b:	8b 45 08             	mov    0x8(%ebp),%eax
8010198e:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101991:	83 ec 0c             	sub    $0xc,%esp
80101994:	68 40 12 11 80       	push   $0x80111240
80101999:	e8 bc 36 00 00       	call   8010505a <release>
8010199e:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019a1:	8b 45 08             	mov    0x8(%ebp),%eax
801019a4:	8b 40 0c             	mov    0xc(%eax),%eax
801019a7:	83 e0 02             	and    $0x2,%eax
801019aa:	85 c0                	test   %eax,%eax
801019ac:	0f 85 ce 00 00 00    	jne    80101a80 <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801019b2:	8b 45 08             	mov    0x8(%ebp),%eax
801019b5:	8b 40 04             	mov    0x4(%eax),%eax
801019b8:	c1 e8 03             	shr    $0x3,%eax
801019bb:	8d 50 02             	lea    0x2(%eax),%edx
801019be:	8b 45 08             	mov    0x8(%ebp),%eax
801019c1:	8b 00                	mov    (%eax),%eax
801019c3:	83 ec 08             	sub    $0x8,%esp
801019c6:	52                   	push   %edx
801019c7:	50                   	push   %eax
801019c8:	e8 e9 e7 ff ff       	call   801001b6 <bread>
801019cd:	83 c4 10             	add    $0x10,%esp
801019d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d6:	8d 50 18             	lea    0x18(%eax),%edx
801019d9:	8b 45 08             	mov    0x8(%ebp),%eax
801019dc:	8b 40 04             	mov    0x4(%eax),%eax
801019df:	83 e0 07             	and    $0x7,%eax
801019e2:	c1 e0 06             	shl    $0x6,%eax
801019e5:	01 d0                	add    %edx,%eax
801019e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ed:	0f b7 10             	movzwl (%eax),%edx
801019f0:	8b 45 08             	mov    0x8(%ebp),%eax
801019f3:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019fa:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a08:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0f:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a16:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a24:	8b 50 08             	mov    0x8(%eax),%edx
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a30:	8d 50 0c             	lea    0xc(%eax),%edx
80101a33:	8b 45 08             	mov    0x8(%ebp),%eax
80101a36:	83 c0 1c             	add    $0x1c,%eax
80101a39:	83 ec 04             	sub    $0x4,%esp
80101a3c:	6a 34                	push   $0x34
80101a3e:	52                   	push   %edx
80101a3f:	50                   	push   %eax
80101a40:	e8 d0 38 00 00       	call   80105315 <memmove>
80101a45:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a48:	83 ec 0c             	sub    $0xc,%esp
80101a4b:	ff 75 f4             	pushl  -0xc(%ebp)
80101a4e:	e8 db e7 ff ff       	call   8010022e <brelse>
80101a53:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a56:	8b 45 08             	mov    0x8(%ebp),%eax
80101a59:	8b 40 0c             	mov    0xc(%eax),%eax
80101a5c:	83 c8 02             	or     $0x2,%eax
80101a5f:	89 c2                	mov    %eax,%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a67:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a6e:	66 85 c0             	test   %ax,%ax
80101a71:	75 0d                	jne    80101a80 <ilock+0x155>
      panic("ilock: no type");
80101a73:	83 ec 0c             	sub    $0xc,%esp
80101a76:	68 9e 86 10 80       	push   $0x8010869e
80101a7b:	e8 e6 ea ff ff       	call   80100566 <panic>
  }
}
80101a80:	90                   	nop
80101a81:	c9                   	leave  
80101a82:	c3                   	ret    

80101a83 <iunlock>:


void
iunlock(struct inode *ip)
{
80101a83:	55                   	push   %ebp
80101a84:	89 e5                	mov    %esp,%ebp
80101a86:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a89:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a8d:	74 17                	je     80101aa6 <iunlock+0x23>
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	8b 40 0c             	mov    0xc(%eax),%eax
80101a95:	83 e0 01             	and    $0x1,%eax
80101a98:	85 c0                	test   %eax,%eax
80101a9a:	74 0a                	je     80101aa6 <iunlock+0x23>
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	8b 40 08             	mov    0x8(%eax),%eax
80101aa2:	85 c0                	test   %eax,%eax
80101aa4:	7f 0d                	jg     80101ab3 <iunlock+0x30>
    panic("iunlock");
80101aa6:	83 ec 0c             	sub    $0xc,%esp
80101aa9:	68 ad 86 10 80       	push   $0x801086ad
80101aae:	e8 b3 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101ab3:	83 ec 0c             	sub    $0xc,%esp
80101ab6:	68 40 12 11 80       	push   $0x80111240
80101abb:	e8 33 35 00 00       	call   80104ff3 <acquire>
80101ac0:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	8b 40 0c             	mov    0xc(%eax),%eax
80101ac9:	83 e0 fe             	and    $0xfffffffe,%eax
80101acc:	89 c2                	mov    %eax,%edx
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101ad4:	83 ec 0c             	sub    $0xc,%esp
80101ad7:	ff 75 08             	pushl  0x8(%ebp)
80101ada:	e8 06 33 00 00       	call   80104de5 <wakeup>
80101adf:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101ae2:	83 ec 0c             	sub    $0xc,%esp
80101ae5:	68 40 12 11 80       	push   $0x80111240
80101aea:	e8 6b 35 00 00       	call   8010505a <release>
80101aef:	83 c4 10             	add    $0x10,%esp
}
80101af2:	90                   	nop
80101af3:	c9                   	leave  
80101af4:	c3                   	ret    

80101af5 <iput>:


void
iput(struct inode *ip)
{
80101af5:	55                   	push   %ebp
80101af6:	89 e5                	mov    %esp,%ebp
80101af8:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101afb:	83 ec 0c             	sub    $0xc,%esp
80101afe:	68 40 12 11 80       	push   $0x80111240
80101b03:	e8 eb 34 00 00       	call   80104ff3 <acquire>
80101b08:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	8b 40 08             	mov    0x8(%eax),%eax
80101b11:	83 f8 01             	cmp    $0x1,%eax
80101b14:	0f 85 a9 00 00 00    	jne    80101bc3 <iput+0xce>
80101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1d:	8b 40 0c             	mov    0xc(%eax),%eax
80101b20:	83 e0 02             	and    $0x2,%eax
80101b23:	85 c0                	test   %eax,%eax
80101b25:	0f 84 98 00 00 00    	je     80101bc3 <iput+0xce>
80101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b32:	66 85 c0             	test   %ax,%ax
80101b35:	0f 85 88 00 00 00    	jne    80101bc3 <iput+0xce>

    if(ip->flags & I_BUSY)
80101b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3e:	8b 40 0c             	mov    0xc(%eax),%eax
80101b41:	83 e0 01             	and    $0x1,%eax
80101b44:	85 c0                	test   %eax,%eax
80101b46:	74 0d                	je     80101b55 <iput+0x60>
      panic("iput busy");
80101b48:	83 ec 0c             	sub    $0xc,%esp
80101b4b:	68 b5 86 10 80       	push   $0x801086b5
80101b50:	e8 11 ea ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b55:	8b 45 08             	mov    0x8(%ebp),%eax
80101b58:	8b 40 0c             	mov    0xc(%eax),%eax
80101b5b:	83 c8 01             	or     $0x1,%eax
80101b5e:	89 c2                	mov    %eax,%edx
80101b60:	8b 45 08             	mov    0x8(%ebp),%eax
80101b63:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b66:	83 ec 0c             	sub    $0xc,%esp
80101b69:	68 40 12 11 80       	push   $0x80111240
80101b6e:	e8 e7 34 00 00       	call   8010505a <release>
80101b73:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b76:	83 ec 0c             	sub    $0xc,%esp
80101b79:	ff 75 08             	pushl  0x8(%ebp)
80101b7c:	e8 a8 01 00 00       	call   80101d29 <itrunc>
80101b81:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b8d:	83 ec 0c             	sub    $0xc,%esp
80101b90:	ff 75 08             	pushl  0x8(%ebp)
80101b93:	e8 bf fb ff ff       	call   80101757 <iupdate>
80101b98:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b9b:	83 ec 0c             	sub    $0xc,%esp
80101b9e:	68 40 12 11 80       	push   $0x80111240
80101ba3:	e8 4b 34 00 00       	call   80104ff3 <acquire>
80101ba8:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bb5:	83 ec 0c             	sub    $0xc,%esp
80101bb8:	ff 75 08             	pushl  0x8(%ebp)
80101bbb:	e8 25 32 00 00       	call   80104de5 <wakeup>
80101bc0:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc6:	8b 40 08             	mov    0x8(%eax),%eax
80101bc9:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcf:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	68 40 12 11 80       	push   $0x80111240
80101bda:	e8 7b 34 00 00       	call   8010505a <release>
80101bdf:	83 c4 10             	add    $0x10,%esp
}
80101be2:	90                   	nop
80101be3:	c9                   	leave  
80101be4:	c3                   	ret    

80101be5 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101be5:	55                   	push   %ebp
80101be6:	89 e5                	mov    %esp,%ebp
80101be8:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101beb:	83 ec 0c             	sub    $0xc,%esp
80101bee:	ff 75 08             	pushl  0x8(%ebp)
80101bf1:	e8 8d fe ff ff       	call   80101a83 <iunlock>
80101bf6:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101bf9:	83 ec 0c             	sub    $0xc,%esp
80101bfc:	ff 75 08             	pushl  0x8(%ebp)
80101bff:	e8 f1 fe ff ff       	call   80101af5 <iput>
80101c04:	83 c4 10             	add    $0x10,%esp
}
80101c07:	90                   	nop
80101c08:	c9                   	leave  
80101c09:	c3                   	ret    

80101c0a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c0a:	55                   	push   %ebp
80101c0b:	89 e5                	mov    %esp,%ebp
80101c0d:	53                   	push   %ebx
80101c0e:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c11:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c15:	77 42                	ja     80101c59 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c17:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c1d:	83 c2 04             	add    $0x4,%edx
80101c20:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c2b:	75 24                	jne    80101c51 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c30:	8b 00                	mov    (%eax),%eax
80101c32:	83 ec 0c             	sub    $0xc,%esp
80101c35:	50                   	push   %eax
80101c36:	e8 e4 f7 ff ff       	call   8010141f <balloc>
80101c3b:	83 c4 10             	add    $0x10,%esp
80101c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c41:	8b 45 08             	mov    0x8(%ebp),%eax
80101c44:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c47:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c4d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c54:	e9 cb 00 00 00       	jmp    80101d24 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c59:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c5d:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c61:	0f 87 b0 00 00 00    	ja     80101d17 <bmap+0x10d>

    if((addr = ip->addrs[NDIRECT]) == 0)
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c74:	75 1d                	jne    80101c93 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 00                	mov    (%eax),%eax
80101c7b:	83 ec 0c             	sub    $0xc,%esp
80101c7e:	50                   	push   %eax
80101c7f:	e8 9b f7 ff ff       	call   8010141f <balloc>
80101c84:	83 c4 10             	add    $0x10,%esp
80101c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c90:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	8b 00                	mov    (%eax),%eax
80101c98:	83 ec 08             	sub    $0x8,%esp
80101c9b:	ff 75 f4             	pushl  -0xc(%ebp)
80101c9e:	50                   	push   %eax
80101c9f:	e8 12 e5 ff ff       	call   801001b6 <bread>
80101ca4:	83 c4 10             	add    $0x10,%esp
80101ca7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cad:	83 c0 18             	add    $0x18,%eax
80101cb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cc0:	01 d0                	add    %edx,%eax
80101cc2:	8b 00                	mov    (%eax),%eax
80101cc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ccb:	75 37                	jne    80101d04 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cda:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce0:	8b 00                	mov    (%eax),%eax
80101ce2:	83 ec 0c             	sub    $0xc,%esp
80101ce5:	50                   	push   %eax
80101ce6:	e8 34 f7 ff ff       	call   8010141f <balloc>
80101ceb:	83 c4 10             	add    $0x10,%esp
80101cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf4:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cf6:	83 ec 0c             	sub    $0xc,%esp
80101cf9:	ff 75 f0             	pushl  -0x10(%ebp)
80101cfc:	e8 0b 1a 00 00       	call   8010370c <log_write>
80101d01:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d04:	83 ec 0c             	sub    $0xc,%esp
80101d07:	ff 75 f0             	pushl  -0x10(%ebp)
80101d0a:	e8 1f e5 ff ff       	call   8010022e <brelse>
80101d0f:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d15:	eb 0d                	jmp    80101d24 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d17:	83 ec 0c             	sub    $0xc,%esp
80101d1a:	68 bf 86 10 80       	push   $0x801086bf
80101d1f:	e8 42 e8 ff ff       	call   80100566 <panic>
}
80101d24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d27:	c9                   	leave  
80101d28:	c3                   	ret    

80101d29 <itrunc>:

static void
itrunc(struct inode *ip)
{
80101d29:	55                   	push   %ebp
80101d2a:	89 e5                	mov    %esp,%ebp
80101d2c:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d36:	eb 45                	jmp    80101d7d <itrunc+0x54>
    if(ip->addrs[i]){
80101d38:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3e:	83 c2 04             	add    $0x4,%edx
80101d41:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d45:	85 c0                	test   %eax,%eax
80101d47:	74 30                	je     80101d79 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d49:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d4f:	83 c2 04             	add    $0x4,%edx
80101d52:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d56:	8b 55 08             	mov    0x8(%ebp),%edx
80101d59:	8b 12                	mov    (%edx),%edx
80101d5b:	83 ec 08             	sub    $0x8,%esp
80101d5e:	50                   	push   %eax
80101d5f:	52                   	push   %edx
80101d60:	e8 18 f8 ff ff       	call   8010157d <bfree>
80101d65:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	83 c2 04             	add    $0x4,%edx
80101d71:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d78:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d7d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d81:	7e b5                	jle    80101d38 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d83:	8b 45 08             	mov    0x8(%ebp),%eax
80101d86:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d89:	85 c0                	test   %eax,%eax
80101d8b:	0f 84 a1 00 00 00    	je     80101e32 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d91:	8b 45 08             	mov    0x8(%ebp),%eax
80101d94:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	8b 00                	mov    (%eax),%eax
80101d9c:	83 ec 08             	sub    $0x8,%esp
80101d9f:	52                   	push   %edx
80101da0:	50                   	push   %eax
80101da1:	e8 10 e4 ff ff       	call   801001b6 <bread>
80101da6:	83 c4 10             	add    $0x10,%esp
80101da9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101daf:	83 c0 18             	add    $0x18,%eax
80101db2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101db5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101dbc:	eb 3c                	jmp    80101dfa <itrunc+0xd1>
      if(a[j])
80101dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dcb:	01 d0                	add    %edx,%eax
80101dcd:	8b 00                	mov    (%eax),%eax
80101dcf:	85 c0                	test   %eax,%eax
80101dd1:	74 23                	je     80101df6 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ddd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101de0:	01 d0                	add    %edx,%eax
80101de2:	8b 00                	mov    (%eax),%eax
80101de4:	8b 55 08             	mov    0x8(%ebp),%edx
80101de7:	8b 12                	mov    (%edx),%edx
80101de9:	83 ec 08             	sub    $0x8,%esp
80101dec:	50                   	push   %eax
80101ded:	52                   	push   %edx
80101dee:	e8 8a f7 ff ff       	call   8010157d <bfree>
80101df3:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101df6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfd:	83 f8 7f             	cmp    $0x7f,%eax
80101e00:	76 bc                	jbe    80101dbe <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e02:	83 ec 0c             	sub    $0xc,%esp
80101e05:	ff 75 ec             	pushl  -0x14(%ebp)
80101e08:	e8 21 e4 ff ff       	call   8010022e <brelse>
80101e0d:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e10:	8b 45 08             	mov    0x8(%ebp),%eax
80101e13:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e16:	8b 55 08             	mov    0x8(%ebp),%edx
80101e19:	8b 12                	mov    (%edx),%edx
80101e1b:	83 ec 08             	sub    $0x8,%esp
80101e1e:	50                   	push   %eax
80101e1f:	52                   	push   %edx
80101e20:	e8 58 f7 ff ff       	call   8010157d <bfree>
80101e25:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e28:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2b:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e32:	8b 45 08             	mov    0x8(%ebp),%eax
80101e35:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e3c:	83 ec 0c             	sub    $0xc,%esp
80101e3f:	ff 75 08             	pushl  0x8(%ebp)
80101e42:	e8 10 f9 ff ff       	call   80101757 <iupdate>
80101e47:	83 c4 10             	add    $0x10,%esp
}
80101e4a:	90                   	nop
80101e4b:	c9                   	leave  
80101e4c:	c3                   	ret    

80101e4d <stati>:


void
stati(struct inode *ip, struct stat *st)
{
80101e4d:	55                   	push   %ebp
80101e4e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	8b 00                	mov    (%eax),%eax
80101e55:	89 c2                	mov    %eax,%edx
80101e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e5a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e60:	8b 50 04             	mov    0x4(%eax),%edx
80101e63:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e66:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e69:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e73:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e76:	8b 45 08             	mov    0x8(%ebp),%eax
80101e79:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e80:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 50 18             	mov    0x18(%eax),%edx
80101e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8d:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e90:	90                   	nop
80101e91:	5d                   	pop    %ebp
80101e92:	c3                   	ret    

80101e93 <readi>:

int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e93:	55                   	push   %ebp
80101e94:	89 e5                	mov    %esp,%ebp
80101e96:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e99:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ea0:	66 83 f8 03          	cmp    $0x3,%ax
80101ea4:	75 5c                	jne    80101f02 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ead:	66 85 c0             	test   %ax,%ax
80101eb0:	78 20                	js     80101ed2 <readi+0x3f>
80101eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eb9:	66 83 f8 09          	cmp    $0x9,%ax
80101ebd:	7f 13                	jg     80101ed2 <readi+0x3f>
80101ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ec6:	98                   	cwtl   
80101ec7:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101ece:	85 c0                	test   %eax,%eax
80101ed0:	75 0a                	jne    80101edc <readi+0x49>
      return -1;
80101ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ed7:	e9 0c 01 00 00       	jmp    80101fe8 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee3:	98                   	cwtl   
80101ee4:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101eeb:	8b 55 14             	mov    0x14(%ebp),%edx
80101eee:	83 ec 04             	sub    $0x4,%esp
80101ef1:	52                   	push   %edx
80101ef2:	ff 75 0c             	pushl  0xc(%ebp)
80101ef5:	ff 75 08             	pushl  0x8(%ebp)
80101ef8:	ff d0                	call   *%eax
80101efa:	83 c4 10             	add    $0x10,%esp
80101efd:	e9 e6 00 00 00       	jmp    80101fe8 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	8b 40 18             	mov    0x18(%eax),%eax
80101f08:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f0b:	72 0d                	jb     80101f1a <readi+0x87>
80101f0d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f10:	8b 45 14             	mov    0x14(%ebp),%eax
80101f13:	01 d0                	add    %edx,%eax
80101f15:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f18:	73 0a                	jae    80101f24 <readi+0x91>
    return -1;
80101f1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1f:	e9 c4 00 00 00       	jmp    80101fe8 <readi+0x155>
  if(off + n > ip->size)
80101f24:	8b 55 10             	mov    0x10(%ebp),%edx
80101f27:	8b 45 14             	mov    0x14(%ebp),%eax
80101f2a:	01 c2                	add    %eax,%edx
80101f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2f:	8b 40 18             	mov    0x18(%eax),%eax
80101f32:	39 c2                	cmp    %eax,%edx
80101f34:	76 0c                	jbe    80101f42 <readi+0xaf>
    n = ip->size - off;
80101f36:	8b 45 08             	mov    0x8(%ebp),%eax
80101f39:	8b 40 18             	mov    0x18(%eax),%eax
80101f3c:	2b 45 10             	sub    0x10(%ebp),%eax
80101f3f:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f49:	e9 8b 00 00 00       	jmp    80101fd9 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f4e:	8b 45 10             	mov    0x10(%ebp),%eax
80101f51:	c1 e8 09             	shr    $0x9,%eax
80101f54:	83 ec 08             	sub    $0x8,%esp
80101f57:	50                   	push   %eax
80101f58:	ff 75 08             	pushl  0x8(%ebp)
80101f5b:	e8 aa fc ff ff       	call   80101c0a <bmap>
80101f60:	83 c4 10             	add    $0x10,%esp
80101f63:	89 c2                	mov    %eax,%edx
80101f65:	8b 45 08             	mov    0x8(%ebp),%eax
80101f68:	8b 00                	mov    (%eax),%eax
80101f6a:	83 ec 08             	sub    $0x8,%esp
80101f6d:	52                   	push   %edx
80101f6e:	50                   	push   %eax
80101f6f:	e8 42 e2 ff ff       	call   801001b6 <bread>
80101f74:	83 c4 10             	add    $0x10,%esp
80101f77:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f7a:	8b 45 10             	mov    0x10(%ebp),%eax
80101f7d:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f82:	ba 00 02 00 00       	mov    $0x200,%edx
80101f87:	29 c2                	sub    %eax,%edx
80101f89:	8b 45 14             	mov    0x14(%ebp),%eax
80101f8c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f8f:	39 c2                	cmp    %eax,%edx
80101f91:	0f 46 c2             	cmovbe %edx,%eax
80101f94:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9a:	8d 50 18             	lea    0x18(%eax),%edx
80101f9d:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa0:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fa5:	01 d0                	add    %edx,%eax
80101fa7:	83 ec 04             	sub    $0x4,%esp
80101faa:	ff 75 ec             	pushl  -0x14(%ebp)
80101fad:	50                   	push   %eax
80101fae:	ff 75 0c             	pushl  0xc(%ebp)
80101fb1:	e8 5f 33 00 00       	call   80105315 <memmove>
80101fb6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fb9:	83 ec 0c             	sub    $0xc,%esp
80101fbc:	ff 75 f0             	pushl  -0x10(%ebp)
80101fbf:	e8 6a e2 ff ff       	call   8010022e <brelse>
80101fc4:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fca:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fd0:	01 45 10             	add    %eax,0x10(%ebp)
80101fd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fd6:	01 45 0c             	add    %eax,0xc(%ebp)
80101fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fdc:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fdf:	0f 82 69 ff ff ff    	jb     80101f4e <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fe5:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fe8:	c9                   	leave  
80101fe9:	c3                   	ret    

80101fea <writei>:


int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fea:	55                   	push   %ebp
80101feb:	89 e5                	mov    %esp,%ebp
80101fed:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ff7:	66 83 f8 03          	cmp    $0x3,%ax
80101ffb:	75 5c                	jne    80102059 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80102000:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102004:	66 85 c0             	test   %ax,%ax
80102007:	78 20                	js     80102029 <writei+0x3f>
80102009:	8b 45 08             	mov    0x8(%ebp),%eax
8010200c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102010:	66 83 f8 09          	cmp    $0x9,%ax
80102014:	7f 13                	jg     80102029 <writei+0x3f>
80102016:	8b 45 08             	mov    0x8(%ebp),%eax
80102019:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010201d:	98                   	cwtl   
8010201e:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80102025:	85 c0                	test   %eax,%eax
80102027:	75 0a                	jne    80102033 <writei+0x49>
      return -1;
80102029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010202e:	e9 3d 01 00 00       	jmp    80102170 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010203a:	98                   	cwtl   
8010203b:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80102042:	8b 55 14             	mov    0x14(%ebp),%edx
80102045:	83 ec 04             	sub    $0x4,%esp
80102048:	52                   	push   %edx
80102049:	ff 75 0c             	pushl  0xc(%ebp)
8010204c:	ff 75 08             	pushl  0x8(%ebp)
8010204f:	ff d0                	call   *%eax
80102051:	83 c4 10             	add    $0x10,%esp
80102054:	e9 17 01 00 00       	jmp    80102170 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102059:	8b 45 08             	mov    0x8(%ebp),%eax
8010205c:	8b 40 18             	mov    0x18(%eax),%eax
8010205f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102062:	72 0d                	jb     80102071 <writei+0x87>
80102064:	8b 55 10             	mov    0x10(%ebp),%edx
80102067:	8b 45 14             	mov    0x14(%ebp),%eax
8010206a:	01 d0                	add    %edx,%eax
8010206c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010206f:	73 0a                	jae    8010207b <writei+0x91>
    return -1;
80102071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102076:	e9 f5 00 00 00       	jmp    80102170 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
8010207b:	8b 55 10             	mov    0x10(%ebp),%edx
8010207e:	8b 45 14             	mov    0x14(%ebp),%eax
80102081:	01 d0                	add    %edx,%eax
80102083:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102088:	76 0a                	jbe    80102094 <writei+0xaa>
    return -1;
8010208a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010208f:	e9 dc 00 00 00       	jmp    80102170 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102094:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010209b:	e9 99 00 00 00       	jmp    80102139 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020a0:	8b 45 10             	mov    0x10(%ebp),%eax
801020a3:	c1 e8 09             	shr    $0x9,%eax
801020a6:	83 ec 08             	sub    $0x8,%esp
801020a9:	50                   	push   %eax
801020aa:	ff 75 08             	pushl  0x8(%ebp)
801020ad:	e8 58 fb ff ff       	call   80101c0a <bmap>
801020b2:	83 c4 10             	add    $0x10,%esp
801020b5:	89 c2                	mov    %eax,%edx
801020b7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ba:	8b 00                	mov    (%eax),%eax
801020bc:	83 ec 08             	sub    $0x8,%esp
801020bf:	52                   	push   %edx
801020c0:	50                   	push   %eax
801020c1:	e8 f0 e0 ff ff       	call   801001b6 <bread>
801020c6:	83 c4 10             	add    $0x10,%esp
801020c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020cc:	8b 45 10             	mov    0x10(%ebp),%eax
801020cf:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d4:	ba 00 02 00 00       	mov    $0x200,%edx
801020d9:	29 c2                	sub    %eax,%edx
801020db:	8b 45 14             	mov    0x14(%ebp),%eax
801020de:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020e1:	39 c2                	cmp    %eax,%edx
801020e3:	0f 46 c2             	cmovbe %edx,%eax
801020e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020ec:	8d 50 18             	lea    0x18(%eax),%edx
801020ef:	8b 45 10             	mov    0x10(%ebp),%eax
801020f2:	25 ff 01 00 00       	and    $0x1ff,%eax
801020f7:	01 d0                	add    %edx,%eax
801020f9:	83 ec 04             	sub    $0x4,%esp
801020fc:	ff 75 ec             	pushl  -0x14(%ebp)
801020ff:	ff 75 0c             	pushl  0xc(%ebp)
80102102:	50                   	push   %eax
80102103:	e8 0d 32 00 00       	call   80105315 <memmove>
80102108:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010210b:	83 ec 0c             	sub    $0xc,%esp
8010210e:	ff 75 f0             	pushl  -0x10(%ebp)
80102111:	e8 f6 15 00 00       	call   8010370c <log_write>
80102116:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102119:	83 ec 0c             	sub    $0xc,%esp
8010211c:	ff 75 f0             	pushl  -0x10(%ebp)
8010211f:	e8 0a e1 ff ff       	call   8010022e <brelse>
80102124:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102127:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010212a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010212d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102130:	01 45 10             	add    %eax,0x10(%ebp)
80102133:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102136:	01 45 0c             	add    %eax,0xc(%ebp)
80102139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010213c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010213f:	0f 82 5b ff ff ff    	jb     801020a0 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102145:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102149:	74 22                	je     8010216d <writei+0x183>
8010214b:	8b 45 08             	mov    0x8(%ebp),%eax
8010214e:	8b 40 18             	mov    0x18(%eax),%eax
80102151:	3b 45 10             	cmp    0x10(%ebp),%eax
80102154:	73 17                	jae    8010216d <writei+0x183>
    ip->size = off;
80102156:	8b 45 08             	mov    0x8(%ebp),%eax
80102159:	8b 55 10             	mov    0x10(%ebp),%edx
8010215c:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010215f:	83 ec 0c             	sub    $0xc,%esp
80102162:	ff 75 08             	pushl  0x8(%ebp)
80102165:	e8 ed f5 ff ff       	call   80101757 <iupdate>
8010216a:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010216d:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102170:	c9                   	leave  
80102171:	c3                   	ret    

80102172 <namecmp>:



int
namecmp(const char *s, const char *t)
{
80102172:	55                   	push   %ebp
80102173:	89 e5                	mov    %esp,%ebp
80102175:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102178:	83 ec 04             	sub    $0x4,%esp
8010217b:	6a 0e                	push   $0xe
8010217d:	ff 75 0c             	pushl  0xc(%ebp)
80102180:	ff 75 08             	pushl  0x8(%ebp)
80102183:	e8 23 32 00 00       	call   801053ab <strncmp>
80102188:	83 c4 10             	add    $0x10,%esp
}
8010218b:	c9                   	leave  
8010218c:	c3                   	ret    

8010218d <dirlookup>:

struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010218d:	55                   	push   %ebp
8010218e:	89 e5                	mov    %esp,%ebp
80102190:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102193:	8b 45 08             	mov    0x8(%ebp),%eax
80102196:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010219a:	66 83 f8 01          	cmp    $0x1,%ax
8010219e:	74 0d                	je     801021ad <dirlookup+0x20>
    panic("dirlookup not DIR");
801021a0:	83 ec 0c             	sub    $0xc,%esp
801021a3:	68 d2 86 10 80       	push   $0x801086d2
801021a8:	e8 b9 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021b4:	eb 7b                	jmp    80102231 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021b6:	6a 10                	push   $0x10
801021b8:	ff 75 f4             	pushl  -0xc(%ebp)
801021bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021be:	50                   	push   %eax
801021bf:	ff 75 08             	pushl  0x8(%ebp)
801021c2:	e8 cc fc ff ff       	call   80101e93 <readi>
801021c7:	83 c4 10             	add    $0x10,%esp
801021ca:	83 f8 10             	cmp    $0x10,%eax
801021cd:	74 0d                	je     801021dc <dirlookup+0x4f>
      panic("dirlink read");
801021cf:	83 ec 0c             	sub    $0xc,%esp
801021d2:	68 e4 86 10 80       	push   $0x801086e4
801021d7:	e8 8a e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801021dc:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021e0:	66 85 c0             	test   %ax,%ax
801021e3:	74 47                	je     8010222c <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801021e5:	83 ec 08             	sub    $0x8,%esp
801021e8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021eb:	83 c0 02             	add    $0x2,%eax
801021ee:	50                   	push   %eax
801021ef:	ff 75 0c             	pushl  0xc(%ebp)
801021f2:	e8 7b ff ff ff       	call   80102172 <namecmp>
801021f7:	83 c4 10             	add    $0x10,%esp
801021fa:	85 c0                	test   %eax,%eax
801021fc:	75 2f                	jne    8010222d <dirlookup+0xa0>

      if(poff)
801021fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102202:	74 08                	je     8010220c <dirlookup+0x7f>
        *poff = off;
80102204:	8b 45 10             	mov    0x10(%ebp),%eax
80102207:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010220a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010220c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102210:	0f b7 c0             	movzwl %ax,%eax
80102213:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102216:	8b 45 08             	mov    0x8(%ebp),%eax
80102219:	8b 00                	mov    (%eax),%eax
8010221b:	83 ec 08             	sub    $0x8,%esp
8010221e:	ff 75 f0             	pushl  -0x10(%ebp)
80102221:	50                   	push   %eax
80102222:	e8 eb f5 ff ff       	call   80101812 <iget>
80102227:	83 c4 10             	add    $0x10,%esp
8010222a:	eb 19                	jmp    80102245 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010222c:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010222d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102231:	8b 45 08             	mov    0x8(%ebp),%eax
80102234:	8b 40 18             	mov    0x18(%eax),%eax
80102237:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010223a:	0f 87 76 ff ff ff    	ja     801021b6 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102240:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102245:	c9                   	leave  
80102246:	c3                   	ret    

80102247 <dirlink>:


int
dirlink(struct inode *dp, char *name, uint inum)
{
80102247:	55                   	push   %ebp
80102248:	89 e5                	mov    %esp,%ebp
8010224a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;


  if((ip = dirlookup(dp, name, 0)) != 0){
8010224d:	83 ec 04             	sub    $0x4,%esp
80102250:	6a 00                	push   $0x0
80102252:	ff 75 0c             	pushl  0xc(%ebp)
80102255:	ff 75 08             	pushl  0x8(%ebp)
80102258:	e8 30 ff ff ff       	call   8010218d <dirlookup>
8010225d:	83 c4 10             	add    $0x10,%esp
80102260:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102263:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102267:	74 18                	je     80102281 <dirlink+0x3a>
    iput(ip);
80102269:	83 ec 0c             	sub    $0xc,%esp
8010226c:	ff 75 f0             	pushl  -0x10(%ebp)
8010226f:	e8 81 f8 ff ff       	call   80101af5 <iput>
80102274:	83 c4 10             	add    $0x10,%esp
    return -1;
80102277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010227c:	e9 9c 00 00 00       	jmp    8010231d <dirlink+0xd6>
  }


  for(off = 0; off < dp->size; off += sizeof(de)){
80102281:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102288:	eb 39                	jmp    801022c3 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228d:	6a 10                	push   $0x10
8010228f:	50                   	push   %eax
80102290:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102293:	50                   	push   %eax
80102294:	ff 75 08             	pushl  0x8(%ebp)
80102297:	e8 f7 fb ff ff       	call   80101e93 <readi>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	83 f8 10             	cmp    $0x10,%eax
801022a2:	74 0d                	je     801022b1 <dirlink+0x6a>
      panic("dirlink read");
801022a4:	83 ec 0c             	sub    $0xc,%esp
801022a7:	68 e4 86 10 80       	push   $0x801086e4
801022ac:	e8 b5 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022b1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022b5:	66 85 c0             	test   %ax,%ax
801022b8:	74 18                	je     801022d2 <dirlink+0x8b>
    iput(ip);
    return -1;
  }


  for(off = 0; off < dp->size; off += sizeof(de)){
801022ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022bd:	83 c0 10             	add    $0x10,%eax
801022c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022c3:	8b 45 08             	mov    0x8(%ebp),%eax
801022c6:	8b 50 18             	mov    0x18(%eax),%edx
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	39 c2                	cmp    %eax,%edx
801022ce:	77 ba                	ja     8010228a <dirlink+0x43>
801022d0:	eb 01                	jmp    801022d3 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801022d2:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022d3:	83 ec 04             	sub    $0x4,%esp
801022d6:	6a 0e                	push   $0xe
801022d8:	ff 75 0c             	pushl  0xc(%ebp)
801022db:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022de:	83 c0 02             	add    $0x2,%eax
801022e1:	50                   	push   %eax
801022e2:	e8 1a 31 00 00       	call   80105401 <strncpy>
801022e7:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801022ea:	8b 45 10             	mov    0x10(%ebp),%eax
801022ed:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f4:	6a 10                	push   $0x10
801022f6:	50                   	push   %eax
801022f7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022fa:	50                   	push   %eax
801022fb:	ff 75 08             	pushl  0x8(%ebp)
801022fe:	e8 e7 fc ff ff       	call   80101fea <writei>
80102303:	83 c4 10             	add    $0x10,%esp
80102306:	83 f8 10             	cmp    $0x10,%eax
80102309:	74 0d                	je     80102318 <dirlink+0xd1>
    panic("dirlink");
8010230b:	83 ec 0c             	sub    $0xc,%esp
8010230e:	68 f1 86 10 80       	push   $0x801086f1
80102313:	e8 4e e2 ff ff       	call   80100566 <panic>
  
  return 0;
80102318:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010231d:	c9                   	leave  
8010231e:	c3                   	ret    

8010231f <skipelem>:


static char*
skipelem(char *path, char *name)
{
8010231f:	55                   	push   %ebp
80102320:	89 e5                	mov    %esp,%ebp
80102322:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102325:	eb 04                	jmp    8010232b <skipelem+0xc>
    path++;
80102327:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010232b:	8b 45 08             	mov    0x8(%ebp),%eax
8010232e:	0f b6 00             	movzbl (%eax),%eax
80102331:	3c 2f                	cmp    $0x2f,%al
80102333:	74 f2                	je     80102327 <skipelem+0x8>
    path++;
  if(*path == 0)
80102335:	8b 45 08             	mov    0x8(%ebp),%eax
80102338:	0f b6 00             	movzbl (%eax),%eax
8010233b:	84 c0                	test   %al,%al
8010233d:	75 07                	jne    80102346 <skipelem+0x27>
    return 0;
8010233f:	b8 00 00 00 00       	mov    $0x0,%eax
80102344:	eb 7b                	jmp    801023c1 <skipelem+0xa2>
  s = path;
80102346:	8b 45 08             	mov    0x8(%ebp),%eax
80102349:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010234c:	eb 04                	jmp    80102352 <skipelem+0x33>
    path++;
8010234e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102352:	8b 45 08             	mov    0x8(%ebp),%eax
80102355:	0f b6 00             	movzbl (%eax),%eax
80102358:	3c 2f                	cmp    $0x2f,%al
8010235a:	74 0a                	je     80102366 <skipelem+0x47>
8010235c:	8b 45 08             	mov    0x8(%ebp),%eax
8010235f:	0f b6 00             	movzbl (%eax),%eax
80102362:	84 c0                	test   %al,%al
80102364:	75 e8                	jne    8010234e <skipelem+0x2f>
    path++;
  len = path - s;
80102366:	8b 55 08             	mov    0x8(%ebp),%edx
80102369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236c:	29 c2                	sub    %eax,%edx
8010236e:	89 d0                	mov    %edx,%eax
80102370:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102373:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102377:	7e 15                	jle    8010238e <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102379:	83 ec 04             	sub    $0x4,%esp
8010237c:	6a 0e                	push   $0xe
8010237e:	ff 75 f4             	pushl  -0xc(%ebp)
80102381:	ff 75 0c             	pushl  0xc(%ebp)
80102384:	e8 8c 2f 00 00       	call   80105315 <memmove>
80102389:	83 c4 10             	add    $0x10,%esp
8010238c:	eb 26                	jmp    801023b4 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010238e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102391:	83 ec 04             	sub    $0x4,%esp
80102394:	50                   	push   %eax
80102395:	ff 75 f4             	pushl  -0xc(%ebp)
80102398:	ff 75 0c             	pushl  0xc(%ebp)
8010239b:	e8 75 2f 00 00       	call   80105315 <memmove>
801023a0:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801023a9:	01 d0                	add    %edx,%eax
801023ab:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023ae:	eb 04                	jmp    801023b4 <skipelem+0x95>
    path++;
801023b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023b4:	8b 45 08             	mov    0x8(%ebp),%eax
801023b7:	0f b6 00             	movzbl (%eax),%eax
801023ba:	3c 2f                	cmp    $0x2f,%al
801023bc:	74 f2                	je     801023b0 <skipelem+0x91>
    path++;
  return path;
801023be:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023c1:	c9                   	leave  
801023c2:	c3                   	ret    

801023c3 <namex>:

static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023c3:	55                   	push   %ebp
801023c4:	89 e5                	mov    %esp,%ebp
801023c6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023c9:	8b 45 08             	mov    0x8(%ebp),%eax
801023cc:	0f b6 00             	movzbl (%eax),%eax
801023cf:	3c 2f                	cmp    $0x2f,%al
801023d1:	75 17                	jne    801023ea <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023d3:	83 ec 08             	sub    $0x8,%esp
801023d6:	6a 01                	push   $0x1
801023d8:	6a 01                	push   $0x1
801023da:	e8 33 f4 ff ff       	call   80101812 <iget>
801023df:	83 c4 10             	add    $0x10,%esp
801023e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023e5:	e9 bb 00 00 00       	jmp    801024a5 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801023ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023f0:	8b 40 68             	mov    0x68(%eax),%eax
801023f3:	83 ec 0c             	sub    $0xc,%esp
801023f6:	50                   	push   %eax
801023f7:	e8 f5 f4 ff ff       	call   801018f1 <idup>
801023fc:	83 c4 10             	add    $0x10,%esp
801023ff:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102402:	e9 9e 00 00 00       	jmp    801024a5 <namex+0xe2>
    ilock(ip);
80102407:	83 ec 0c             	sub    $0xc,%esp
8010240a:	ff 75 f4             	pushl  -0xc(%ebp)
8010240d:	e8 19 f5 ff ff       	call   8010192b <ilock>
80102412:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102418:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010241c:	66 83 f8 01          	cmp    $0x1,%ax
80102420:	74 18                	je     8010243a <namex+0x77>
      iunlockput(ip);
80102422:	83 ec 0c             	sub    $0xc,%esp
80102425:	ff 75 f4             	pushl  -0xc(%ebp)
80102428:	e8 b8 f7 ff ff       	call   80101be5 <iunlockput>
8010242d:	83 c4 10             	add    $0x10,%esp
      return 0;
80102430:	b8 00 00 00 00       	mov    $0x0,%eax
80102435:	e9 a7 00 00 00       	jmp    801024e1 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010243a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010243e:	74 20                	je     80102460 <namex+0x9d>
80102440:	8b 45 08             	mov    0x8(%ebp),%eax
80102443:	0f b6 00             	movzbl (%eax),%eax
80102446:	84 c0                	test   %al,%al
80102448:	75 16                	jne    80102460 <namex+0x9d>
      iunlock(ip);
8010244a:	83 ec 0c             	sub    $0xc,%esp
8010244d:	ff 75 f4             	pushl  -0xc(%ebp)
80102450:	e8 2e f6 ff ff       	call   80101a83 <iunlock>
80102455:	83 c4 10             	add    $0x10,%esp
      return ip;
80102458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245b:	e9 81 00 00 00       	jmp    801024e1 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102460:	83 ec 04             	sub    $0x4,%esp
80102463:	6a 00                	push   $0x0
80102465:	ff 75 10             	pushl  0x10(%ebp)
80102468:	ff 75 f4             	pushl  -0xc(%ebp)
8010246b:	e8 1d fd ff ff       	call   8010218d <dirlookup>
80102470:	83 c4 10             	add    $0x10,%esp
80102473:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102476:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010247a:	75 15                	jne    80102491 <namex+0xce>
      iunlockput(ip);
8010247c:	83 ec 0c             	sub    $0xc,%esp
8010247f:	ff 75 f4             	pushl  -0xc(%ebp)
80102482:	e8 5e f7 ff ff       	call   80101be5 <iunlockput>
80102487:	83 c4 10             	add    $0x10,%esp
      return 0;
8010248a:	b8 00 00 00 00       	mov    $0x0,%eax
8010248f:	eb 50                	jmp    801024e1 <namex+0x11e>
    }
    iunlockput(ip);
80102491:	83 ec 0c             	sub    $0xc,%esp
80102494:	ff 75 f4             	pushl  -0xc(%ebp)
80102497:	e8 49 f7 ff ff       	call   80101be5 <iunlockput>
8010249c:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010249f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024a5:	83 ec 08             	sub    $0x8,%esp
801024a8:	ff 75 10             	pushl  0x10(%ebp)
801024ab:	ff 75 08             	pushl  0x8(%ebp)
801024ae:	e8 6c fe ff ff       	call   8010231f <skipelem>
801024b3:	83 c4 10             	add    $0x10,%esp
801024b6:	89 45 08             	mov    %eax,0x8(%ebp)
801024b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024bd:	0f 85 44 ff ff ff    	jne    80102407 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801024c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024c7:	74 15                	je     801024de <namex+0x11b>
    iput(ip);
801024c9:	83 ec 0c             	sub    $0xc,%esp
801024cc:	ff 75 f4             	pushl  -0xc(%ebp)
801024cf:	e8 21 f6 ff ff       	call   80101af5 <iput>
801024d4:	83 c4 10             	add    $0x10,%esp
    return 0;
801024d7:	b8 00 00 00 00       	mov    $0x0,%eax
801024dc:	eb 03                	jmp    801024e1 <namex+0x11e>
  }
  return ip;
801024de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801024e1:	c9                   	leave  
801024e2:	c3                   	ret    

801024e3 <namei>:

struct inode*
namei(char *path)
{
801024e3:	55                   	push   %ebp
801024e4:	89 e5                	mov    %esp,%ebp
801024e6:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801024e9:	83 ec 04             	sub    $0x4,%esp
801024ec:	8d 45 ea             	lea    -0x16(%ebp),%eax
801024ef:	50                   	push   %eax
801024f0:	6a 00                	push   $0x0
801024f2:	ff 75 08             	pushl  0x8(%ebp)
801024f5:	e8 c9 fe ff ff       	call   801023c3 <namex>
801024fa:	83 c4 10             	add    $0x10,%esp
}
801024fd:	c9                   	leave  
801024fe:	c3                   	ret    

801024ff <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024ff:	55                   	push   %ebp
80102500:	89 e5                	mov    %esp,%ebp
80102502:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102505:	83 ec 04             	sub    $0x4,%esp
80102508:	ff 75 0c             	pushl  0xc(%ebp)
8010250b:	6a 01                	push   $0x1
8010250d:	ff 75 08             	pushl  0x8(%ebp)
80102510:	e8 ae fe ff ff       	call   801023c3 <namex>
80102515:	83 c4 10             	add    $0x10,%esp
}
80102518:	c9                   	leave  
80102519:	c3                   	ret    

8010251a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010251a:	55                   	push   %ebp
8010251b:	89 e5                	mov    %esp,%ebp
8010251d:	83 ec 14             	sub    $0x14,%esp
80102520:	8b 45 08             	mov    0x8(%ebp),%eax
80102523:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102527:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010252b:	89 c2                	mov    %eax,%edx
8010252d:	ec                   	in     (%dx),%al
8010252e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102531:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102535:	c9                   	leave  
80102536:	c3                   	ret    

80102537 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102537:	55                   	push   %ebp
80102538:	89 e5                	mov    %esp,%ebp
8010253a:	57                   	push   %edi
8010253b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010253c:	8b 55 08             	mov    0x8(%ebp),%edx
8010253f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102542:	8b 45 10             	mov    0x10(%ebp),%eax
80102545:	89 cb                	mov    %ecx,%ebx
80102547:	89 df                	mov    %ebx,%edi
80102549:	89 c1                	mov    %eax,%ecx
8010254b:	fc                   	cld    
8010254c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010254e:	89 c8                	mov    %ecx,%eax
80102550:	89 fb                	mov    %edi,%ebx
80102552:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102555:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102558:	90                   	nop
80102559:	5b                   	pop    %ebx
8010255a:	5f                   	pop    %edi
8010255b:	5d                   	pop    %ebp
8010255c:	c3                   	ret    

8010255d <outb>:

static inline void
outb(ushort port, uchar data)
{
8010255d:	55                   	push   %ebp
8010255e:	89 e5                	mov    %esp,%ebp
80102560:	83 ec 08             	sub    $0x8,%esp
80102563:	8b 55 08             	mov    0x8(%ebp),%edx
80102566:	8b 45 0c             	mov    0xc(%ebp),%eax
80102569:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010256d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102570:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102574:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102578:	ee                   	out    %al,(%dx)
}
80102579:	90                   	nop
8010257a:	c9                   	leave  
8010257b:	c3                   	ret    

8010257c <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010257c:	55                   	push   %ebp
8010257d:	89 e5                	mov    %esp,%ebp
8010257f:	56                   	push   %esi
80102580:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102581:	8b 55 08             	mov    0x8(%ebp),%edx
80102584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102587:	8b 45 10             	mov    0x10(%ebp),%eax
8010258a:	89 cb                	mov    %ecx,%ebx
8010258c:	89 de                	mov    %ebx,%esi
8010258e:	89 c1                	mov    %eax,%ecx
80102590:	fc                   	cld    
80102591:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102593:	89 c8                	mov    %ecx,%eax
80102595:	89 f3                	mov    %esi,%ebx
80102597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010259a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010259d:	90                   	nop
8010259e:	5b                   	pop    %ebx
8010259f:	5e                   	pop    %esi
801025a0:	5d                   	pop    %ebp
801025a1:	c3                   	ret    

801025a2 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025a2:	55                   	push   %ebp
801025a3:	89 e5                	mov    %esp,%ebp
801025a5:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025a8:	90                   	nop
801025a9:	68 f7 01 00 00       	push   $0x1f7
801025ae:	e8 67 ff ff ff       	call   8010251a <inb>
801025b3:	83 c4 04             	add    $0x4,%esp
801025b6:	0f b6 c0             	movzbl %al,%eax
801025b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025bf:	25 c0 00 00 00       	and    $0xc0,%eax
801025c4:	83 f8 40             	cmp    $0x40,%eax
801025c7:	75 e0                	jne    801025a9 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025cd:	74 11                	je     801025e0 <idewait+0x3e>
801025cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025d2:	83 e0 21             	and    $0x21,%eax
801025d5:	85 c0                	test   %eax,%eax
801025d7:	74 07                	je     801025e0 <idewait+0x3e>
    return -1;
801025d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025de:	eb 05                	jmp    801025e5 <idewait+0x43>
  return 0;
801025e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025e5:	c9                   	leave  
801025e6:	c3                   	ret    

801025e7 <ideinit>:

void
ideinit(void)
{
801025e7:	55                   	push   %ebp
801025e8:	89 e5                	mov    %esp,%ebp
801025ea:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801025ed:	83 ec 08             	sub    $0x8,%esp
801025f0:	68 f9 86 10 80       	push   $0x801086f9
801025f5:	68 00 b6 10 80       	push   $0x8010b600
801025fa:	e8 d2 29 00 00       	call   80104fd1 <initlock>
801025ff:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102602:	83 ec 0c             	sub    $0xc,%esp
80102605:	6a 0e                	push   $0xe
80102607:	e8 8b 18 00 00       	call   80103e97 <picenable>
8010260c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010260f:	a1 40 29 11 80       	mov    0x80112940,%eax
80102614:	83 e8 01             	sub    $0x1,%eax
80102617:	83 ec 08             	sub    $0x8,%esp
8010261a:	50                   	push   %eax
8010261b:	6a 0e                	push   $0xe
8010261d:	e8 37 04 00 00       	call   80102a59 <ioapicenable>
80102622:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102625:	83 ec 0c             	sub    $0xc,%esp
80102628:	6a 00                	push   $0x0
8010262a:	e8 73 ff ff ff       	call   801025a2 <idewait>
8010262f:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102632:	83 ec 08             	sub    $0x8,%esp
80102635:	68 f0 00 00 00       	push   $0xf0
8010263a:	68 f6 01 00 00       	push   $0x1f6
8010263f:	e8 19 ff ff ff       	call   8010255d <outb>
80102644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102647:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010264e:	eb 24                	jmp    80102674 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102650:	83 ec 0c             	sub    $0xc,%esp
80102653:	68 f7 01 00 00       	push   $0x1f7
80102658:	e8 bd fe ff ff       	call   8010251a <inb>
8010265d:	83 c4 10             	add    $0x10,%esp
80102660:	84 c0                	test   %al,%al
80102662:	74 0c                	je     80102670 <ideinit+0x89>
      havedisk1 = 1;
80102664:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
8010266b:	00 00 00 
      break;
8010266e:	eb 0d                	jmp    8010267d <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102670:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102674:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010267b:	7e d3                	jle    80102650 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010267d:	83 ec 08             	sub    $0x8,%esp
80102680:	68 e0 00 00 00       	push   $0xe0
80102685:	68 f6 01 00 00       	push   $0x1f6
8010268a:	e8 ce fe ff ff       	call   8010255d <outb>
8010268f:	83 c4 10             	add    $0x10,%esp
}
80102692:	90                   	nop
80102693:	c9                   	leave  
80102694:	c3                   	ret    

80102695 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102695:	55                   	push   %ebp
80102696:	89 e5                	mov    %esp,%ebp
80102698:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
8010269b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010269f:	75 0d                	jne    801026ae <idestart+0x19>
    panic("idestart");
801026a1:	83 ec 0c             	sub    $0xc,%esp
801026a4:	68 fd 86 10 80       	push   $0x801086fd
801026a9:	e8 b8 de ff ff       	call   80100566 <panic>

  idewait(0);
801026ae:	83 ec 0c             	sub    $0xc,%esp
801026b1:	6a 00                	push   $0x0
801026b3:	e8 ea fe ff ff       	call   801025a2 <idewait>
801026b8:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801026bb:	83 ec 08             	sub    $0x8,%esp
801026be:	6a 00                	push   $0x0
801026c0:	68 f6 03 00 00       	push   $0x3f6
801026c5:	e8 93 fe ff ff       	call   8010255d <outb>
801026ca:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
801026cd:	83 ec 08             	sub    $0x8,%esp
801026d0:	6a 01                	push   $0x1
801026d2:	68 f2 01 00 00       	push   $0x1f2
801026d7:	e8 81 fe ff ff       	call   8010255d <outb>
801026dc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801026df:	8b 45 08             	mov    0x8(%ebp),%eax
801026e2:	8b 40 08             	mov    0x8(%eax),%eax
801026e5:	0f b6 c0             	movzbl %al,%eax
801026e8:	83 ec 08             	sub    $0x8,%esp
801026eb:	50                   	push   %eax
801026ec:	68 f3 01 00 00       	push   $0x1f3
801026f1:	e8 67 fe ff ff       	call   8010255d <outb>
801026f6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801026f9:	8b 45 08             	mov    0x8(%ebp),%eax
801026fc:	8b 40 08             	mov    0x8(%eax),%eax
801026ff:	c1 e8 08             	shr    $0x8,%eax
80102702:	0f b6 c0             	movzbl %al,%eax
80102705:	83 ec 08             	sub    $0x8,%esp
80102708:	50                   	push   %eax
80102709:	68 f4 01 00 00       	push   $0x1f4
8010270e:	e8 4a fe ff ff       	call   8010255d <outb>
80102713:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102716:	8b 45 08             	mov    0x8(%ebp),%eax
80102719:	8b 40 08             	mov    0x8(%eax),%eax
8010271c:	c1 e8 10             	shr    $0x10,%eax
8010271f:	0f b6 c0             	movzbl %al,%eax
80102722:	83 ec 08             	sub    $0x8,%esp
80102725:	50                   	push   %eax
80102726:	68 f5 01 00 00       	push   $0x1f5
8010272b:	e8 2d fe ff ff       	call   8010255d <outb>
80102730:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102733:	8b 45 08             	mov    0x8(%ebp),%eax
80102736:	8b 40 04             	mov    0x4(%eax),%eax
80102739:	83 e0 01             	and    $0x1,%eax
8010273c:	c1 e0 04             	shl    $0x4,%eax
8010273f:	89 c2                	mov    %eax,%edx
80102741:	8b 45 08             	mov    0x8(%ebp),%eax
80102744:	8b 40 08             	mov    0x8(%eax),%eax
80102747:	c1 e8 18             	shr    $0x18,%eax
8010274a:	83 e0 0f             	and    $0xf,%eax
8010274d:	09 d0                	or     %edx,%eax
8010274f:	83 c8 e0             	or     $0xffffffe0,%eax
80102752:	0f b6 c0             	movzbl %al,%eax
80102755:	83 ec 08             	sub    $0x8,%esp
80102758:	50                   	push   %eax
80102759:	68 f6 01 00 00       	push   $0x1f6
8010275e:	e8 fa fd ff ff       	call   8010255d <outb>
80102763:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102766:	8b 45 08             	mov    0x8(%ebp),%eax
80102769:	8b 00                	mov    (%eax),%eax
8010276b:	83 e0 04             	and    $0x4,%eax
8010276e:	85 c0                	test   %eax,%eax
80102770:	74 30                	je     801027a2 <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
80102772:	83 ec 08             	sub    $0x8,%esp
80102775:	6a 30                	push   $0x30
80102777:	68 f7 01 00 00       	push   $0x1f7
8010277c:	e8 dc fd ff ff       	call   8010255d <outb>
80102781:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
80102784:	8b 45 08             	mov    0x8(%ebp),%eax
80102787:	83 c0 18             	add    $0x18,%eax
8010278a:	83 ec 04             	sub    $0x4,%esp
8010278d:	68 80 00 00 00       	push   $0x80
80102792:	50                   	push   %eax
80102793:	68 f0 01 00 00       	push   $0x1f0
80102798:	e8 df fd ff ff       	call   8010257c <outsl>
8010279d:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
801027a0:	eb 12                	jmp    801027b4 <idestart+0x11f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
801027a2:	83 ec 08             	sub    $0x8,%esp
801027a5:	6a 20                	push   $0x20
801027a7:	68 f7 01 00 00       	push   $0x1f7
801027ac:	e8 ac fd ff ff       	call   8010255d <outb>
801027b1:	83 c4 10             	add    $0x10,%esp
  }
}
801027b4:	90                   	nop
801027b5:	c9                   	leave  
801027b6:	c3                   	ret    

801027b7 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801027b7:	55                   	push   %ebp
801027b8:	89 e5                	mov    %esp,%ebp
801027ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801027bd:	83 ec 0c             	sub    $0xc,%esp
801027c0:	68 00 b6 10 80       	push   $0x8010b600
801027c5:	e8 29 28 00 00       	call   80104ff3 <acquire>
801027ca:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801027cd:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d9:	75 15                	jne    801027f0 <ideintr+0x39>
    release(&idelock);
801027db:	83 ec 0c             	sub    $0xc,%esp
801027de:	68 00 b6 10 80       	push   $0x8010b600
801027e3:	e8 72 28 00 00       	call   8010505a <release>
801027e8:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801027eb:	e9 9a 00 00 00       	jmp    8010288a <ideintr+0xd3>
  }
  idequeue = b->qnext;
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f3:	8b 40 14             	mov    0x14(%eax),%eax
801027f6:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027fe:	8b 00                	mov    (%eax),%eax
80102800:	83 e0 04             	and    $0x4,%eax
80102803:	85 c0                	test   %eax,%eax
80102805:	75 2d                	jne    80102834 <ideintr+0x7d>
80102807:	83 ec 0c             	sub    $0xc,%esp
8010280a:	6a 01                	push   $0x1
8010280c:	e8 91 fd ff ff       	call   801025a2 <idewait>
80102811:	83 c4 10             	add    $0x10,%esp
80102814:	85 c0                	test   %eax,%eax
80102816:	78 1c                	js     80102834 <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
80102818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281b:	83 c0 18             	add    $0x18,%eax
8010281e:	83 ec 04             	sub    $0x4,%esp
80102821:	68 80 00 00 00       	push   $0x80
80102826:	50                   	push   %eax
80102827:	68 f0 01 00 00       	push   $0x1f0
8010282c:	e8 06 fd ff ff       	call   80102537 <insl>
80102831:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102837:	8b 00                	mov    (%eax),%eax
80102839:	83 c8 02             	or     $0x2,%eax
8010283c:	89 c2                	mov    %eax,%edx
8010283e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102841:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102846:	8b 00                	mov    (%eax),%eax
80102848:	83 e0 fb             	and    $0xfffffffb,%eax
8010284b:	89 c2                	mov    %eax,%edx
8010284d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102850:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102852:	83 ec 0c             	sub    $0xc,%esp
80102855:	ff 75 f4             	pushl  -0xc(%ebp)
80102858:	e8 88 25 00 00       	call   80104de5 <wakeup>
8010285d:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102860:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102865:	85 c0                	test   %eax,%eax
80102867:	74 11                	je     8010287a <ideintr+0xc3>
    idestart(idequeue);
80102869:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010286e:	83 ec 0c             	sub    $0xc,%esp
80102871:	50                   	push   %eax
80102872:	e8 1e fe ff ff       	call   80102695 <idestart>
80102877:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 00 b6 10 80       	push   $0x8010b600
80102882:	e8 d3 27 00 00       	call   8010505a <release>
80102887:	83 c4 10             	add    $0x10,%esp
}
8010288a:	c9                   	leave  
8010288b:	c3                   	ret    

8010288c <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010288c:	55                   	push   %ebp
8010288d:	89 e5                	mov    %esp,%ebp
8010288f:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102892:	8b 45 08             	mov    0x8(%ebp),%eax
80102895:	8b 00                	mov    (%eax),%eax
80102897:	83 e0 01             	and    $0x1,%eax
8010289a:	85 c0                	test   %eax,%eax
8010289c:	75 0d                	jne    801028ab <iderw+0x1f>
    panic("iderw: buf not busy");
8010289e:	83 ec 0c             	sub    $0xc,%esp
801028a1:	68 06 87 10 80       	push   $0x80108706
801028a6:	e8 bb dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801028ab:	8b 45 08             	mov    0x8(%ebp),%eax
801028ae:	8b 00                	mov    (%eax),%eax
801028b0:	83 e0 06             	and    $0x6,%eax
801028b3:	83 f8 02             	cmp    $0x2,%eax
801028b6:	75 0d                	jne    801028c5 <iderw+0x39>
    panic("iderw: nothing to do");
801028b8:	83 ec 0c             	sub    $0xc,%esp
801028bb:	68 1a 87 10 80       	push   $0x8010871a
801028c0:	e8 a1 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801028c5:	8b 45 08             	mov    0x8(%ebp),%eax
801028c8:	8b 40 04             	mov    0x4(%eax),%eax
801028cb:	85 c0                	test   %eax,%eax
801028cd:	74 16                	je     801028e5 <iderw+0x59>
801028cf:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801028d4:	85 c0                	test   %eax,%eax
801028d6:	75 0d                	jne    801028e5 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801028d8:	83 ec 0c             	sub    $0xc,%esp
801028db:	68 2f 87 10 80       	push   $0x8010872f
801028e0:	e8 81 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028e5:	83 ec 0c             	sub    $0xc,%esp
801028e8:	68 00 b6 10 80       	push   $0x8010b600
801028ed:	e8 01 27 00 00       	call   80104ff3 <acquire>
801028f2:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801028f5:	8b 45 08             	mov    0x8(%ebp),%eax
801028f8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028ff:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102906:	eb 0b                	jmp    80102913 <iderw+0x87>
80102908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290b:	8b 00                	mov    (%eax),%eax
8010290d:	83 c0 14             	add    $0x14,%eax
80102910:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102916:	8b 00                	mov    (%eax),%eax
80102918:	85 c0                	test   %eax,%eax
8010291a:	75 ec                	jne    80102908 <iderw+0x7c>
    ;
  *pp = b;
8010291c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291f:	8b 55 08             	mov    0x8(%ebp),%edx
80102922:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102924:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102929:	3b 45 08             	cmp    0x8(%ebp),%eax
8010292c:	75 23                	jne    80102951 <iderw+0xc5>
    idestart(b);
8010292e:	83 ec 0c             	sub    $0xc,%esp
80102931:	ff 75 08             	pushl  0x8(%ebp)
80102934:	e8 5c fd ff ff       	call   80102695 <idestart>
80102939:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010293c:	eb 13                	jmp    80102951 <iderw+0xc5>
    sleep(b, &idelock);
8010293e:	83 ec 08             	sub    $0x8,%esp
80102941:	68 00 b6 10 80       	push   $0x8010b600
80102946:	ff 75 08             	pushl  0x8(%ebp)
80102949:	e8 ac 23 00 00       	call   80104cfa <sleep>
8010294e:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102951:	8b 45 08             	mov    0x8(%ebp),%eax
80102954:	8b 00                	mov    (%eax),%eax
80102956:	83 e0 06             	and    $0x6,%eax
80102959:	83 f8 02             	cmp    $0x2,%eax
8010295c:	75 e0                	jne    8010293e <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
8010295e:	83 ec 0c             	sub    $0xc,%esp
80102961:	68 00 b6 10 80       	push   $0x8010b600
80102966:	e8 ef 26 00 00       	call   8010505a <release>
8010296b:	83 c4 10             	add    $0x10,%esp
}
8010296e:	90                   	nop
8010296f:	c9                   	leave  
80102970:	c3                   	ret    

80102971 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102971:	55                   	push   %ebp
80102972:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102974:	a1 14 22 11 80       	mov    0x80112214,%eax
80102979:	8b 55 08             	mov    0x8(%ebp),%edx
8010297c:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010297e:	a1 14 22 11 80       	mov    0x80112214,%eax
80102983:	8b 40 10             	mov    0x10(%eax),%eax
}
80102986:	5d                   	pop    %ebp
80102987:	c3                   	ret    

80102988 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102988:	55                   	push   %ebp
80102989:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010298b:	a1 14 22 11 80       	mov    0x80112214,%eax
80102990:	8b 55 08             	mov    0x8(%ebp),%edx
80102993:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102995:	a1 14 22 11 80       	mov    0x80112214,%eax
8010299a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010299d:	89 50 10             	mov    %edx,0x10(%eax)
}
801029a0:	90                   	nop
801029a1:	5d                   	pop    %ebp
801029a2:	c3                   	ret    

801029a3 <ioapicinit>:

void
ioapicinit(void)
{
801029a3:	55                   	push   %ebp
801029a4:	89 e5                	mov    %esp,%ebp
801029a6:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
801029a9:	a1 44 23 11 80       	mov    0x80112344,%eax
801029ae:	85 c0                	test   %eax,%eax
801029b0:	0f 84 a0 00 00 00    	je     80102a56 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801029b6:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
801029bd:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801029c0:	6a 01                	push   $0x1
801029c2:	e8 aa ff ff ff       	call   80102971 <ioapicread>
801029c7:	83 c4 04             	add    $0x4,%esp
801029ca:	c1 e8 10             	shr    $0x10,%eax
801029cd:	25 ff 00 00 00       	and    $0xff,%eax
801029d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029d5:	6a 00                	push   $0x0
801029d7:	e8 95 ff ff ff       	call   80102971 <ioapicread>
801029dc:	83 c4 04             	add    $0x4,%esp
801029df:	c1 e8 18             	shr    $0x18,%eax
801029e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029e5:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
801029ec:	0f b6 c0             	movzbl %al,%eax
801029ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029f2:	74 10                	je     80102a04 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029f4:	83 ec 0c             	sub    $0xc,%esp
801029f7:	68 50 87 10 80       	push   $0x80108750
801029fc:	e8 c5 d9 ff ff       	call   801003c6 <cprintf>
80102a01:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a0b:	eb 3f                	jmp    80102a4c <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a10:	83 c0 20             	add    $0x20,%eax
80102a13:	0d 00 00 01 00       	or     $0x10000,%eax
80102a18:	89 c2                	mov    %eax,%edx
80102a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1d:	83 c0 08             	add    $0x8,%eax
80102a20:	01 c0                	add    %eax,%eax
80102a22:	83 ec 08             	sub    $0x8,%esp
80102a25:	52                   	push   %edx
80102a26:	50                   	push   %eax
80102a27:	e8 5c ff ff ff       	call   80102988 <ioapicwrite>
80102a2c:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a32:	83 c0 08             	add    $0x8,%eax
80102a35:	01 c0                	add    %eax,%eax
80102a37:	83 c0 01             	add    $0x1,%eax
80102a3a:	83 ec 08             	sub    $0x8,%esp
80102a3d:	6a 00                	push   $0x0
80102a3f:	50                   	push   %eax
80102a40:	e8 43 ff ff ff       	call   80102988 <ioapicwrite>
80102a45:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a52:	7e b9                	jle    80102a0d <ioapicinit+0x6a>
80102a54:	eb 01                	jmp    80102a57 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102a56:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a57:	c9                   	leave  
80102a58:	c3                   	ret    

80102a59 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a59:	55                   	push   %ebp
80102a5a:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a5c:	a1 44 23 11 80       	mov    0x80112344,%eax
80102a61:	85 c0                	test   %eax,%eax
80102a63:	74 39                	je     80102a9e <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a65:	8b 45 08             	mov    0x8(%ebp),%eax
80102a68:	83 c0 20             	add    $0x20,%eax
80102a6b:	89 c2                	mov    %eax,%edx
80102a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a70:	83 c0 08             	add    $0x8,%eax
80102a73:	01 c0                	add    %eax,%eax
80102a75:	52                   	push   %edx
80102a76:	50                   	push   %eax
80102a77:	e8 0c ff ff ff       	call   80102988 <ioapicwrite>
80102a7c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a82:	c1 e0 18             	shl    $0x18,%eax
80102a85:	89 c2                	mov    %eax,%edx
80102a87:	8b 45 08             	mov    0x8(%ebp),%eax
80102a8a:	83 c0 08             	add    $0x8,%eax
80102a8d:	01 c0                	add    %eax,%eax
80102a8f:	83 c0 01             	add    $0x1,%eax
80102a92:	52                   	push   %edx
80102a93:	50                   	push   %eax
80102a94:	e8 ef fe ff ff       	call   80102988 <ioapicwrite>
80102a99:	83 c4 08             	add    $0x8,%esp
80102a9c:	eb 01                	jmp    80102a9f <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102a9e:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102a9f:	c9                   	leave  
80102aa0:	c3                   	ret    

80102aa1 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102aa1:	55                   	push   %ebp
80102aa2:	89 e5                	mov    %esp,%ebp
80102aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa7:	05 00 00 00 80       	add    $0x80000000,%eax
80102aac:	5d                   	pop    %ebp
80102aad:	c3                   	ret    

80102aae <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102aae:	55                   	push   %ebp
80102aaf:	89 e5                	mov    %esp,%ebp
80102ab1:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102ab4:	83 ec 08             	sub    $0x8,%esp
80102ab7:	68 82 87 10 80       	push   $0x80108782
80102abc:	68 20 22 11 80       	push   $0x80112220
80102ac1:	e8 0b 25 00 00       	call   80104fd1 <initlock>
80102ac6:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102ac9:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
80102ad0:	00 00 00 
  freerange(vstart, vend);
80102ad3:	83 ec 08             	sub    $0x8,%esp
80102ad6:	ff 75 0c             	pushl  0xc(%ebp)
80102ad9:	ff 75 08             	pushl  0x8(%ebp)
80102adc:	e8 2a 00 00 00       	call   80102b0b <freerange>
80102ae1:	83 c4 10             	add    $0x10,%esp
}
80102ae4:	90                   	nop
80102ae5:	c9                   	leave  
80102ae6:	c3                   	ret    

80102ae7 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ae7:	55                   	push   %ebp
80102ae8:	89 e5                	mov    %esp,%ebp
80102aea:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102aed:	83 ec 08             	sub    $0x8,%esp
80102af0:	ff 75 0c             	pushl  0xc(%ebp)
80102af3:	ff 75 08             	pushl  0x8(%ebp)
80102af6:	e8 10 00 00 00       	call   80102b0b <freerange>
80102afb:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102afe:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102b05:	00 00 00 
}
80102b08:	90                   	nop
80102b09:	c9                   	leave  
80102b0a:	c3                   	ret    

80102b0b <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b0b:	55                   	push   %ebp
80102b0c:	89 e5                	mov    %esp,%ebp
80102b0e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b11:	8b 45 08             	mov    0x8(%ebp),%eax
80102b14:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b21:	eb 15                	jmp    80102b38 <freerange+0x2d>
    kfree(p);
80102b23:	83 ec 0c             	sub    $0xc,%esp
80102b26:	ff 75 f4             	pushl  -0xc(%ebp)
80102b29:	e8 1a 00 00 00       	call   80102b48 <kfree>
80102b2e:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b31:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3b:	05 00 10 00 00       	add    $0x1000,%eax
80102b40:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b43:	76 de                	jbe    80102b23 <freerange+0x18>
    kfree(p);
}
80102b45:	90                   	nop
80102b46:	c9                   	leave  
80102b47:	c3                   	ret    

80102b48 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b48:	55                   	push   %ebp
80102b49:	89 e5                	mov    %esp,%ebp
80102b4b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b51:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b56:	85 c0                	test   %eax,%eax
80102b58:	75 1b                	jne    80102b75 <kfree+0x2d>
80102b5a:	81 7d 08 3c 51 11 80 	cmpl   $0x8011513c,0x8(%ebp)
80102b61:	72 12                	jb     80102b75 <kfree+0x2d>
80102b63:	ff 75 08             	pushl  0x8(%ebp)
80102b66:	e8 36 ff ff ff       	call   80102aa1 <v2p>
80102b6b:	83 c4 04             	add    $0x4,%esp
80102b6e:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b73:	76 0d                	jbe    80102b82 <kfree+0x3a>
    panic("kfree");
80102b75:	83 ec 0c             	sub    $0xc,%esp
80102b78:	68 87 87 10 80       	push   $0x80108787
80102b7d:	e8 e4 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b82:	83 ec 04             	sub    $0x4,%esp
80102b85:	68 00 10 00 00       	push   $0x1000
80102b8a:	6a 01                	push   $0x1
80102b8c:	ff 75 08             	pushl  0x8(%ebp)
80102b8f:	e8 c2 26 00 00       	call   80105256 <memset>
80102b94:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102b97:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b9c:	85 c0                	test   %eax,%eax
80102b9e:	74 10                	je     80102bb0 <kfree+0x68>
    acquire(&kmem.lock);
80102ba0:	83 ec 0c             	sub    $0xc,%esp
80102ba3:	68 20 22 11 80       	push   $0x80112220
80102ba8:	e8 46 24 00 00       	call   80104ff3 <acquire>
80102bad:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102bb6:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbf:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc4:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102bc9:	a1 54 22 11 80       	mov    0x80112254,%eax
80102bce:	85 c0                	test   %eax,%eax
80102bd0:	74 10                	je     80102be2 <kfree+0x9a>
    release(&kmem.lock);
80102bd2:	83 ec 0c             	sub    $0xc,%esp
80102bd5:	68 20 22 11 80       	push   $0x80112220
80102bda:	e8 7b 24 00 00       	call   8010505a <release>
80102bdf:	83 c4 10             	add    $0x10,%esp
}
80102be2:	90                   	nop
80102be3:	c9                   	leave  
80102be4:	c3                   	ret    

80102be5 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102be5:	55                   	push   %ebp
80102be6:	89 e5                	mov    %esp,%ebp
80102be8:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102beb:	a1 54 22 11 80       	mov    0x80112254,%eax
80102bf0:	85 c0                	test   %eax,%eax
80102bf2:	74 10                	je     80102c04 <kalloc+0x1f>
    acquire(&kmem.lock);
80102bf4:	83 ec 0c             	sub    $0xc,%esp
80102bf7:	68 20 22 11 80       	push   $0x80112220
80102bfc:	e8 f2 23 00 00       	call   80104ff3 <acquire>
80102c01:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c04:	a1 58 22 11 80       	mov    0x80112258,%eax
80102c09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c10:	74 0a                	je     80102c1c <kalloc+0x37>
    kmem.freelist = r->next;
80102c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c15:	8b 00                	mov    (%eax),%eax
80102c17:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102c1c:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c21:	85 c0                	test   %eax,%eax
80102c23:	74 10                	je     80102c35 <kalloc+0x50>
    release(&kmem.lock);
80102c25:	83 ec 0c             	sub    $0xc,%esp
80102c28:	68 20 22 11 80       	push   $0x80112220
80102c2d:	e8 28 24 00 00       	call   8010505a <release>
80102c32:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c38:	c9                   	leave  
80102c39:	c3                   	ret    

80102c3a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c3a:	55                   	push   %ebp
80102c3b:	89 e5                	mov    %esp,%ebp
80102c3d:	83 ec 14             	sub    $0x14,%esp
80102c40:	8b 45 08             	mov    0x8(%ebp),%eax
80102c43:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c47:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c4b:	89 c2                	mov    %eax,%edx
80102c4d:	ec                   	in     (%dx),%al
80102c4e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c51:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c55:	c9                   	leave  
80102c56:	c3                   	ret    

80102c57 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c57:	55                   	push   %ebp
80102c58:	89 e5                	mov    %esp,%ebp
80102c5a:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c5d:	6a 64                	push   $0x64
80102c5f:	e8 d6 ff ff ff       	call   80102c3a <inb>
80102c64:	83 c4 04             	add    $0x4,%esp
80102c67:	0f b6 c0             	movzbl %al,%eax
80102c6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c70:	83 e0 01             	and    $0x1,%eax
80102c73:	85 c0                	test   %eax,%eax
80102c75:	75 0a                	jne    80102c81 <kbdgetc+0x2a>
    return -1;
80102c77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c7c:	e9 23 01 00 00       	jmp    80102da4 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102c81:	6a 60                	push   $0x60
80102c83:	e8 b2 ff ff ff       	call   80102c3a <inb>
80102c88:	83 c4 04             	add    $0x4,%esp
80102c8b:	0f b6 c0             	movzbl %al,%eax
80102c8e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c91:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c98:	75 17                	jne    80102cb1 <kbdgetc+0x5a>
    shift |= E0ESC;
80102c9a:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c9f:	83 c8 40             	or     $0x40,%eax
80102ca2:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ca7:	b8 00 00 00 00       	mov    $0x0,%eax
80102cac:	e9 f3 00 00 00       	jmp    80102da4 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cb4:	25 80 00 00 00       	and    $0x80,%eax
80102cb9:	85 c0                	test   %eax,%eax
80102cbb:	74 45                	je     80102d02 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102cbd:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cc2:	83 e0 40             	and    $0x40,%eax
80102cc5:	85 c0                	test   %eax,%eax
80102cc7:	75 08                	jne    80102cd1 <kbdgetc+0x7a>
80102cc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ccc:	83 e0 7f             	and    $0x7f,%eax
80102ccf:	eb 03                	jmp    80102cd4 <kbdgetc+0x7d>
80102cd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102cd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cda:	05 20 90 10 80       	add    $0x80109020,%eax
80102cdf:	0f b6 00             	movzbl (%eax),%eax
80102ce2:	83 c8 40             	or     $0x40,%eax
80102ce5:	0f b6 c0             	movzbl %al,%eax
80102ce8:	f7 d0                	not    %eax
80102cea:	89 c2                	mov    %eax,%edx
80102cec:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cf1:	21 d0                	and    %edx,%eax
80102cf3:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102cf8:	b8 00 00 00 00       	mov    $0x0,%eax
80102cfd:	e9 a2 00 00 00       	jmp    80102da4 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d02:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d07:	83 e0 40             	and    $0x40,%eax
80102d0a:	85 c0                	test   %eax,%eax
80102d0c:	74 14                	je     80102d22 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d0e:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d15:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d1a:	83 e0 bf             	and    $0xffffffbf,%eax
80102d1d:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102d22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d25:	05 20 90 10 80       	add    $0x80109020,%eax
80102d2a:	0f b6 00             	movzbl (%eax),%eax
80102d2d:	0f b6 d0             	movzbl %al,%edx
80102d30:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d35:	09 d0                	or     %edx,%eax
80102d37:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102d3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d3f:	05 20 91 10 80       	add    $0x80109120,%eax
80102d44:	0f b6 00             	movzbl (%eax),%eax
80102d47:	0f b6 d0             	movzbl %al,%edx
80102d4a:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d4f:	31 d0                	xor    %edx,%eax
80102d51:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d56:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d5b:	83 e0 03             	and    $0x3,%eax
80102d5e:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d68:	01 d0                	add    %edx,%eax
80102d6a:	0f b6 00             	movzbl (%eax),%eax
80102d6d:	0f b6 c0             	movzbl %al,%eax
80102d70:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d73:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d78:	83 e0 08             	and    $0x8,%eax
80102d7b:	85 c0                	test   %eax,%eax
80102d7d:	74 22                	je     80102da1 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d7f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d83:	76 0c                	jbe    80102d91 <kbdgetc+0x13a>
80102d85:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d89:	77 06                	ja     80102d91 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102d8b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d8f:	eb 10                	jmp    80102da1 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d91:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d95:	76 0a                	jbe    80102da1 <kbdgetc+0x14a>
80102d97:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d9b:	77 04                	ja     80102da1 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d9d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102da1:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102da4:	c9                   	leave  
80102da5:	c3                   	ret    

80102da6 <kbdintr>:

void
kbdintr(void)
{
80102da6:	55                   	push   %ebp
80102da7:	89 e5                	mov    %esp,%ebp
80102da9:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102dac:	83 ec 0c             	sub    $0xc,%esp
80102daf:	68 57 2c 10 80       	push   $0x80102c57
80102db4:	e8 24 da ff ff       	call   801007dd <consoleintr>
80102db9:	83 c4 10             	add    $0x10,%esp
}
80102dbc:	90                   	nop
80102dbd:	c9                   	leave  
80102dbe:	c3                   	ret    

80102dbf <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102dbf:	55                   	push   %ebp
80102dc0:	89 e5                	mov    %esp,%ebp
80102dc2:	83 ec 14             	sub    $0x14,%esp
80102dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dcc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102dd0:	89 c2                	mov    %eax,%edx
80102dd2:	ec                   	in     (%dx),%al
80102dd3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dd6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102dda:	c9                   	leave  
80102ddb:	c3                   	ret    

80102ddc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102ddc:	55                   	push   %ebp
80102ddd:	89 e5                	mov    %esp,%ebp
80102ddf:	83 ec 08             	sub    $0x8,%esp
80102de2:	8b 55 08             	mov    0x8(%ebp),%edx
80102de5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102de8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102dec:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102def:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102df3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102df7:	ee                   	out    %al,(%dx)
}
80102df8:	90                   	nop
80102df9:	c9                   	leave  
80102dfa:	c3                   	ret    

80102dfb <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102dfb:	55                   	push   %ebp
80102dfc:	89 e5                	mov    %esp,%ebp
80102dfe:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e01:	9c                   	pushf  
80102e02:	58                   	pop    %eax
80102e03:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e06:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e09:	c9                   	leave  
80102e0a:	c3                   	ret    

80102e0b <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e0b:	55                   	push   %ebp
80102e0c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e0e:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e13:	8b 55 08             	mov    0x8(%ebp),%edx
80102e16:	c1 e2 02             	shl    $0x2,%edx
80102e19:	01 c2                	add    %eax,%edx
80102e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e1e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e20:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e25:	83 c0 20             	add    $0x20,%eax
80102e28:	8b 00                	mov    (%eax),%eax
}
80102e2a:	90                   	nop
80102e2b:	5d                   	pop    %ebp
80102e2c:	c3                   	ret    

80102e2d <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e2d:	55                   	push   %ebp
80102e2e:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102e30:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e35:	85 c0                	test   %eax,%eax
80102e37:	0f 84 0b 01 00 00    	je     80102f48 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e3d:	68 3f 01 00 00       	push   $0x13f
80102e42:	6a 3c                	push   $0x3c
80102e44:	e8 c2 ff ff ff       	call   80102e0b <lapicw>
80102e49:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e4c:	6a 0b                	push   $0xb
80102e4e:	68 f8 00 00 00       	push   $0xf8
80102e53:	e8 b3 ff ff ff       	call   80102e0b <lapicw>
80102e58:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e5b:	68 20 00 02 00       	push   $0x20020
80102e60:	68 c8 00 00 00       	push   $0xc8
80102e65:	e8 a1 ff ff ff       	call   80102e0b <lapicw>
80102e6a:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102e6d:	68 80 96 98 00       	push   $0x989680
80102e72:	68 e0 00 00 00       	push   $0xe0
80102e77:	e8 8f ff ff ff       	call   80102e0b <lapicw>
80102e7c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e7f:	68 00 00 01 00       	push   $0x10000
80102e84:	68 d4 00 00 00       	push   $0xd4
80102e89:	e8 7d ff ff ff       	call   80102e0b <lapicw>
80102e8e:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102e91:	68 00 00 01 00       	push   $0x10000
80102e96:	68 d8 00 00 00       	push   $0xd8
80102e9b:	e8 6b ff ff ff       	call   80102e0b <lapicw>
80102ea0:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102ea3:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ea8:	83 c0 30             	add    $0x30,%eax
80102eab:	8b 00                	mov    (%eax),%eax
80102ead:	c1 e8 10             	shr    $0x10,%eax
80102eb0:	0f b6 c0             	movzbl %al,%eax
80102eb3:	83 f8 03             	cmp    $0x3,%eax
80102eb6:	76 12                	jbe    80102eca <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102eb8:	68 00 00 01 00       	push   $0x10000
80102ebd:	68 d0 00 00 00       	push   $0xd0
80102ec2:	e8 44 ff ff ff       	call   80102e0b <lapicw>
80102ec7:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102eca:	6a 33                	push   $0x33
80102ecc:	68 dc 00 00 00       	push   $0xdc
80102ed1:	e8 35 ff ff ff       	call   80102e0b <lapicw>
80102ed6:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102ed9:	6a 00                	push   $0x0
80102edb:	68 a0 00 00 00       	push   $0xa0
80102ee0:	e8 26 ff ff ff       	call   80102e0b <lapicw>
80102ee5:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102ee8:	6a 00                	push   $0x0
80102eea:	68 a0 00 00 00       	push   $0xa0
80102eef:	e8 17 ff ff ff       	call   80102e0b <lapicw>
80102ef4:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ef7:	6a 00                	push   $0x0
80102ef9:	6a 2c                	push   $0x2c
80102efb:	e8 0b ff ff ff       	call   80102e0b <lapicw>
80102f00:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f03:	6a 00                	push   $0x0
80102f05:	68 c4 00 00 00       	push   $0xc4
80102f0a:	e8 fc fe ff ff       	call   80102e0b <lapicw>
80102f0f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f12:	68 00 85 08 00       	push   $0x88500
80102f17:	68 c0 00 00 00       	push   $0xc0
80102f1c:	e8 ea fe ff ff       	call   80102e0b <lapicw>
80102f21:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102f24:	90                   	nop
80102f25:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f2a:	05 00 03 00 00       	add    $0x300,%eax
80102f2f:	8b 00                	mov    (%eax),%eax
80102f31:	25 00 10 00 00       	and    $0x1000,%eax
80102f36:	85 c0                	test   %eax,%eax
80102f38:	75 eb                	jne    80102f25 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f3a:	6a 00                	push   $0x0
80102f3c:	6a 20                	push   $0x20
80102f3e:	e8 c8 fe ff ff       	call   80102e0b <lapicw>
80102f43:	83 c4 08             	add    $0x8,%esp
80102f46:	eb 01                	jmp    80102f49 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102f48:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102f49:	c9                   	leave  
80102f4a:	c3                   	ret    

80102f4b <cpunum>:

int
cpunum(void)
{
80102f4b:	55                   	push   %ebp
80102f4c:	89 e5                	mov    %esp,%ebp
80102f4e:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f51:	e8 a5 fe ff ff       	call   80102dfb <readeflags>
80102f56:	25 00 02 00 00       	and    $0x200,%eax
80102f5b:	85 c0                	test   %eax,%eax
80102f5d:	74 26                	je     80102f85 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102f5f:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102f64:	8d 50 01             	lea    0x1(%eax),%edx
80102f67:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102f6d:	85 c0                	test   %eax,%eax
80102f6f:	75 14                	jne    80102f85 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f71:	8b 45 04             	mov    0x4(%ebp),%eax
80102f74:	83 ec 08             	sub    $0x8,%esp
80102f77:	50                   	push   %eax
80102f78:	68 90 87 10 80       	push   $0x80108790
80102f7d:	e8 44 d4 ff ff       	call   801003c6 <cprintf>
80102f82:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102f85:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f8a:	85 c0                	test   %eax,%eax
80102f8c:	74 0f                	je     80102f9d <cpunum+0x52>
    return lapic[ID]>>24;
80102f8e:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f93:	83 c0 20             	add    $0x20,%eax
80102f96:	8b 00                	mov    (%eax),%eax
80102f98:	c1 e8 18             	shr    $0x18,%eax
80102f9b:	eb 05                	jmp    80102fa2 <cpunum+0x57>
  return 0;
80102f9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102fa2:	c9                   	leave  
80102fa3:	c3                   	ret    

80102fa4 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102fa4:	55                   	push   %ebp
80102fa5:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102fa7:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102fac:	85 c0                	test   %eax,%eax
80102fae:	74 0c                	je     80102fbc <lapiceoi+0x18>
    lapicw(EOI, 0);
80102fb0:	6a 00                	push   $0x0
80102fb2:	6a 2c                	push   $0x2c
80102fb4:	e8 52 fe ff ff       	call   80102e0b <lapicw>
80102fb9:	83 c4 08             	add    $0x8,%esp
}
80102fbc:	90                   	nop
80102fbd:	c9                   	leave  
80102fbe:	c3                   	ret    

80102fbf <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fbf:	55                   	push   %ebp
80102fc0:	89 e5                	mov    %esp,%ebp
}
80102fc2:	90                   	nop
80102fc3:	5d                   	pop    %ebp
80102fc4:	c3                   	ret    

80102fc5 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fc5:	55                   	push   %ebp
80102fc6:	89 e5                	mov    %esp,%ebp
80102fc8:	83 ec 14             	sub    $0x14,%esp
80102fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80102fce:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fd1:	6a 0f                	push   $0xf
80102fd3:	6a 70                	push   $0x70
80102fd5:	e8 02 fe ff ff       	call   80102ddc <outb>
80102fda:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102fdd:	6a 0a                	push   $0xa
80102fdf:	6a 71                	push   $0x71
80102fe1:	e8 f6 fd ff ff       	call   80102ddc <outb>
80102fe6:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fe9:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102ff0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ff3:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102ff8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ffb:	83 c0 02             	add    $0x2,%eax
80102ffe:	8b 55 0c             	mov    0xc(%ebp),%edx
80103001:	c1 ea 04             	shr    $0x4,%edx
80103004:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103007:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010300b:	c1 e0 18             	shl    $0x18,%eax
8010300e:	50                   	push   %eax
8010300f:	68 c4 00 00 00       	push   $0xc4
80103014:	e8 f2 fd ff ff       	call   80102e0b <lapicw>
80103019:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010301c:	68 00 c5 00 00       	push   $0xc500
80103021:	68 c0 00 00 00       	push   $0xc0
80103026:	e8 e0 fd ff ff       	call   80102e0b <lapicw>
8010302b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010302e:	68 c8 00 00 00       	push   $0xc8
80103033:	e8 87 ff ff ff       	call   80102fbf <microdelay>
80103038:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010303b:	68 00 85 00 00       	push   $0x8500
80103040:	68 c0 00 00 00       	push   $0xc0
80103045:	e8 c1 fd ff ff       	call   80102e0b <lapicw>
8010304a:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010304d:	6a 64                	push   $0x64
8010304f:	e8 6b ff ff ff       	call   80102fbf <microdelay>
80103054:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103057:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010305e:	eb 3d                	jmp    8010309d <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103060:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103064:	c1 e0 18             	shl    $0x18,%eax
80103067:	50                   	push   %eax
80103068:	68 c4 00 00 00       	push   $0xc4
8010306d:	e8 99 fd ff ff       	call   80102e0b <lapicw>
80103072:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103075:	8b 45 0c             	mov    0xc(%ebp),%eax
80103078:	c1 e8 0c             	shr    $0xc,%eax
8010307b:	80 cc 06             	or     $0x6,%ah
8010307e:	50                   	push   %eax
8010307f:	68 c0 00 00 00       	push   $0xc0
80103084:	e8 82 fd ff ff       	call   80102e0b <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010308c:	68 c8 00 00 00       	push   $0xc8
80103091:	e8 29 ff ff ff       	call   80102fbf <microdelay>
80103096:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103099:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010309d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030a1:	7e bd                	jle    80103060 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030a3:	90                   	nop
801030a4:	c9                   	leave  
801030a5:	c3                   	ret    

801030a6 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030a6:	55                   	push   %ebp
801030a7:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801030a9:	8b 45 08             	mov    0x8(%ebp),%eax
801030ac:	0f b6 c0             	movzbl %al,%eax
801030af:	50                   	push   %eax
801030b0:	6a 70                	push   $0x70
801030b2:	e8 25 fd ff ff       	call   80102ddc <outb>
801030b7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030ba:	68 c8 00 00 00       	push   $0xc8
801030bf:	e8 fb fe ff ff       	call   80102fbf <microdelay>
801030c4:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801030c7:	6a 71                	push   $0x71
801030c9:	e8 f1 fc ff ff       	call   80102dbf <inb>
801030ce:	83 c4 04             	add    $0x4,%esp
801030d1:	0f b6 c0             	movzbl %al,%eax
}
801030d4:	c9                   	leave  
801030d5:	c3                   	ret    

801030d6 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030d6:	55                   	push   %ebp
801030d7:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801030d9:	6a 00                	push   $0x0
801030db:	e8 c6 ff ff ff       	call   801030a6 <cmos_read>
801030e0:	83 c4 04             	add    $0x4,%esp
801030e3:	89 c2                	mov    %eax,%edx
801030e5:	8b 45 08             	mov    0x8(%ebp),%eax
801030e8:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801030ea:	6a 02                	push   $0x2
801030ec:	e8 b5 ff ff ff       	call   801030a6 <cmos_read>
801030f1:	83 c4 04             	add    $0x4,%esp
801030f4:	89 c2                	mov    %eax,%edx
801030f6:	8b 45 08             	mov    0x8(%ebp),%eax
801030f9:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801030fc:	6a 04                	push   $0x4
801030fe:	e8 a3 ff ff ff       	call   801030a6 <cmos_read>
80103103:	83 c4 04             	add    $0x4,%esp
80103106:	89 c2                	mov    %eax,%edx
80103108:	8b 45 08             	mov    0x8(%ebp),%eax
8010310b:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010310e:	6a 07                	push   $0x7
80103110:	e8 91 ff ff ff       	call   801030a6 <cmos_read>
80103115:	83 c4 04             	add    $0x4,%esp
80103118:	89 c2                	mov    %eax,%edx
8010311a:	8b 45 08             	mov    0x8(%ebp),%eax
8010311d:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103120:	6a 08                	push   $0x8
80103122:	e8 7f ff ff ff       	call   801030a6 <cmos_read>
80103127:	83 c4 04             	add    $0x4,%esp
8010312a:	89 c2                	mov    %eax,%edx
8010312c:	8b 45 08             	mov    0x8(%ebp),%eax
8010312f:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103132:	6a 09                	push   $0x9
80103134:	e8 6d ff ff ff       	call   801030a6 <cmos_read>
80103139:	83 c4 04             	add    $0x4,%esp
8010313c:	89 c2                	mov    %eax,%edx
8010313e:	8b 45 08             	mov    0x8(%ebp),%eax
80103141:	89 50 14             	mov    %edx,0x14(%eax)
}
80103144:	90                   	nop
80103145:	c9                   	leave  
80103146:	c3                   	ret    

80103147 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103147:	55                   	push   %ebp
80103148:	89 e5                	mov    %esp,%ebp
8010314a:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010314d:	6a 0b                	push   $0xb
8010314f:	e8 52 ff ff ff       	call   801030a6 <cmos_read>
80103154:	83 c4 04             	add    $0x4,%esp
80103157:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010315a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010315d:	83 e0 04             	and    $0x4,%eax
80103160:	85 c0                	test   %eax,%eax
80103162:	0f 94 c0             	sete   %al
80103165:	0f b6 c0             	movzbl %al,%eax
80103168:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010316b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010316e:	50                   	push   %eax
8010316f:	e8 62 ff ff ff       	call   801030d6 <fill_rtcdate>
80103174:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103177:	6a 0a                	push   $0xa
80103179:	e8 28 ff ff ff       	call   801030a6 <cmos_read>
8010317e:	83 c4 04             	add    $0x4,%esp
80103181:	25 80 00 00 00       	and    $0x80,%eax
80103186:	85 c0                	test   %eax,%eax
80103188:	75 27                	jne    801031b1 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010318a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010318d:	50                   	push   %eax
8010318e:	e8 43 ff ff ff       	call   801030d6 <fill_rtcdate>
80103193:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103196:	83 ec 04             	sub    $0x4,%esp
80103199:	6a 18                	push   $0x18
8010319b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010319e:	50                   	push   %eax
8010319f:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031a2:	50                   	push   %eax
801031a3:	e8 15 21 00 00       	call   801052bd <memcmp>
801031a8:	83 c4 10             	add    $0x10,%esp
801031ab:	85 c0                	test   %eax,%eax
801031ad:	74 05                	je     801031b4 <cmostime+0x6d>
801031af:	eb ba                	jmp    8010316b <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801031b1:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031b2:	eb b7                	jmp    8010316b <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801031b4:	90                   	nop
  }

  // convert
  if (bcd) {
801031b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031b9:	0f 84 b4 00 00 00    	je     80103273 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031c2:	c1 e8 04             	shr    $0x4,%eax
801031c5:	89 c2                	mov    %eax,%edx
801031c7:	89 d0                	mov    %edx,%eax
801031c9:	c1 e0 02             	shl    $0x2,%eax
801031cc:	01 d0                	add    %edx,%eax
801031ce:	01 c0                	add    %eax,%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031d5:	83 e0 0f             	and    $0xf,%eax
801031d8:	01 d0                	add    %edx,%eax
801031da:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031e0:	c1 e8 04             	shr    $0x4,%eax
801031e3:	89 c2                	mov    %eax,%edx
801031e5:	89 d0                	mov    %edx,%eax
801031e7:	c1 e0 02             	shl    $0x2,%eax
801031ea:	01 d0                	add    %edx,%eax
801031ec:	01 c0                	add    %eax,%eax
801031ee:	89 c2                	mov    %eax,%edx
801031f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031f3:	83 e0 0f             	and    $0xf,%eax
801031f6:	01 d0                	add    %edx,%eax
801031f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031fe:	c1 e8 04             	shr    $0x4,%eax
80103201:	89 c2                	mov    %eax,%edx
80103203:	89 d0                	mov    %edx,%eax
80103205:	c1 e0 02             	shl    $0x2,%eax
80103208:	01 d0                	add    %edx,%eax
8010320a:	01 c0                	add    %eax,%eax
8010320c:	89 c2                	mov    %eax,%edx
8010320e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103211:	83 e0 0f             	and    $0xf,%eax
80103214:	01 d0                	add    %edx,%eax
80103216:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010321c:	c1 e8 04             	shr    $0x4,%eax
8010321f:	89 c2                	mov    %eax,%edx
80103221:	89 d0                	mov    %edx,%eax
80103223:	c1 e0 02             	shl    $0x2,%eax
80103226:	01 d0                	add    %edx,%eax
80103228:	01 c0                	add    %eax,%eax
8010322a:	89 c2                	mov    %eax,%edx
8010322c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010322f:	83 e0 0f             	and    $0xf,%eax
80103232:	01 d0                	add    %edx,%eax
80103234:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103237:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010323a:	c1 e8 04             	shr    $0x4,%eax
8010323d:	89 c2                	mov    %eax,%edx
8010323f:	89 d0                	mov    %edx,%eax
80103241:	c1 e0 02             	shl    $0x2,%eax
80103244:	01 d0                	add    %edx,%eax
80103246:	01 c0                	add    %eax,%eax
80103248:	89 c2                	mov    %eax,%edx
8010324a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010324d:	83 e0 0f             	and    $0xf,%eax
80103250:	01 d0                	add    %edx,%eax
80103252:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103255:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103258:	c1 e8 04             	shr    $0x4,%eax
8010325b:	89 c2                	mov    %eax,%edx
8010325d:	89 d0                	mov    %edx,%eax
8010325f:	c1 e0 02             	shl    $0x2,%eax
80103262:	01 d0                	add    %edx,%eax
80103264:	01 c0                	add    %eax,%eax
80103266:	89 c2                	mov    %eax,%edx
80103268:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010326b:	83 e0 0f             	and    $0xf,%eax
8010326e:	01 d0                	add    %edx,%eax
80103270:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103273:	8b 45 08             	mov    0x8(%ebp),%eax
80103276:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103279:	89 10                	mov    %edx,(%eax)
8010327b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010327e:	89 50 04             	mov    %edx,0x4(%eax)
80103281:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103284:	89 50 08             	mov    %edx,0x8(%eax)
80103287:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010328a:	89 50 0c             	mov    %edx,0xc(%eax)
8010328d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103290:	89 50 10             	mov    %edx,0x10(%eax)
80103293:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103296:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103299:	8b 45 08             	mov    0x8(%ebp),%eax
8010329c:	8b 40 14             	mov    0x14(%eax),%eax
8010329f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032a5:	8b 45 08             	mov    0x8(%ebp),%eax
801032a8:	89 50 14             	mov    %edx,0x14(%eax)
}
801032ab:	90                   	nop
801032ac:	c9                   	leave  
801032ad:	c3                   	ret    

801032ae <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
801032ae:	55                   	push   %ebp
801032af:	89 e5                	mov    %esp,%ebp
801032b1:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032b4:	83 ec 08             	sub    $0x8,%esp
801032b7:	68 bc 87 10 80       	push   $0x801087bc
801032bc:	68 60 22 11 80       	push   $0x80112260
801032c1:	e8 0b 1d 00 00       	call   80104fd1 <initlock>
801032c6:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
801032c9:	83 ec 08             	sub    $0x8,%esp
801032cc:	8d 45 e8             	lea    -0x18(%ebp),%eax
801032cf:	50                   	push   %eax
801032d0:	6a 01                	push   $0x1
801032d2:	e8 b2 e0 ff ff       	call   80101389 <readsb>
801032d7:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
801032da:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e0:	29 c2                	sub    %eax,%edx
801032e2:	89 d0                	mov    %edx,%eax
801032e4:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
801032e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ec:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = ROOTDEV;
801032f1:	c7 05 a4 22 11 80 01 	movl   $0x1,0x801122a4
801032f8:	00 00 00 
  recover_from_log();
801032fb:	e8 b2 01 00 00       	call   801034b2 <recover_from_log>
}
80103300:	90                   	nop
80103301:	c9                   	leave  
80103302:	c3                   	ret    

80103303 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103303:	55                   	push   %ebp
80103304:	89 e5                	mov    %esp,%ebp
80103306:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103309:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103310:	e9 95 00 00 00       	jmp    801033aa <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103315:	8b 15 94 22 11 80    	mov    0x80112294,%edx
8010331b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331e:	01 d0                	add    %edx,%eax
80103320:	83 c0 01             	add    $0x1,%eax
80103323:	89 c2                	mov    %eax,%edx
80103325:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010332a:	83 ec 08             	sub    $0x8,%esp
8010332d:	52                   	push   %edx
8010332e:	50                   	push   %eax
8010332f:	e8 82 ce ff ff       	call   801001b6 <bread>
80103334:	83 c4 10             	add    $0x10,%esp
80103337:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010333a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010333d:	83 c0 10             	add    $0x10,%eax
80103340:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103347:	89 c2                	mov    %eax,%edx
80103349:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010334e:	83 ec 08             	sub    $0x8,%esp
80103351:	52                   	push   %edx
80103352:	50                   	push   %eax
80103353:	e8 5e ce ff ff       	call   801001b6 <bread>
80103358:	83 c4 10             	add    $0x10,%esp
8010335b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010335e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103361:	8d 50 18             	lea    0x18(%eax),%edx
80103364:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103367:	83 c0 18             	add    $0x18,%eax
8010336a:	83 ec 04             	sub    $0x4,%esp
8010336d:	68 00 02 00 00       	push   $0x200
80103372:	52                   	push   %edx
80103373:	50                   	push   %eax
80103374:	e8 9c 1f 00 00       	call   80105315 <memmove>
80103379:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010337c:	83 ec 0c             	sub    $0xc,%esp
8010337f:	ff 75 ec             	pushl  -0x14(%ebp)
80103382:	e8 68 ce ff ff       	call   801001ef <bwrite>
80103387:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
8010338a:	83 ec 0c             	sub    $0xc,%esp
8010338d:	ff 75 f0             	pushl  -0x10(%ebp)
80103390:	e8 99 ce ff ff       	call   8010022e <brelse>
80103395:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103398:	83 ec 0c             	sub    $0xc,%esp
8010339b:	ff 75 ec             	pushl  -0x14(%ebp)
8010339e:	e8 8b ce ff ff       	call   8010022e <brelse>
801033a3:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033aa:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801033af:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033b2:	0f 8f 5d ff ff ff    	jg     80103315 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033b8:	90                   	nop
801033b9:	c9                   	leave  
801033ba:	c3                   	ret    

801033bb <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033bb:	55                   	push   %ebp
801033bc:	89 e5                	mov    %esp,%ebp
801033be:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801033c1:	a1 94 22 11 80       	mov    0x80112294,%eax
801033c6:	89 c2                	mov    %eax,%edx
801033c8:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033cd:	83 ec 08             	sub    $0x8,%esp
801033d0:	52                   	push   %edx
801033d1:	50                   	push   %eax
801033d2:	e8 df cd ff ff       	call   801001b6 <bread>
801033d7:	83 c4 10             	add    $0x10,%esp
801033da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e0:	83 c0 18             	add    $0x18,%eax
801033e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e9:	8b 00                	mov    (%eax),%eax
801033eb:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
801033f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033f7:	eb 1b                	jmp    80103414 <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801033f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033ff:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103403:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103406:	83 c2 10             	add    $0x10,%edx
80103409:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103410:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103414:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103419:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010341c:	7f db                	jg     801033f9 <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
8010341e:	83 ec 0c             	sub    $0xc,%esp
80103421:	ff 75 f0             	pushl  -0x10(%ebp)
80103424:	e8 05 ce ff ff       	call   8010022e <brelse>
80103429:	83 c4 10             	add    $0x10,%esp
}
8010342c:	90                   	nop
8010342d:	c9                   	leave  
8010342e:	c3                   	ret    

8010342f <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010342f:	55                   	push   %ebp
80103430:	89 e5                	mov    %esp,%ebp
80103432:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103435:	a1 94 22 11 80       	mov    0x80112294,%eax
8010343a:	89 c2                	mov    %eax,%edx
8010343c:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103441:	83 ec 08             	sub    $0x8,%esp
80103444:	52                   	push   %edx
80103445:	50                   	push   %eax
80103446:	e8 6b cd ff ff       	call   801001b6 <bread>
8010344b:	83 c4 10             	add    $0x10,%esp
8010344e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103454:	83 c0 18             	add    $0x18,%eax
80103457:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010345a:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
80103460:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103463:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103465:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010346c:	eb 1b                	jmp    80103489 <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
8010346e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103471:	83 c0 10             	add    $0x10,%eax
80103474:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
8010347b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103481:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103485:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103489:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010348e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103491:	7f db                	jg     8010346e <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103493:	83 ec 0c             	sub    $0xc,%esp
80103496:	ff 75 f0             	pushl  -0x10(%ebp)
80103499:	e8 51 cd ff ff       	call   801001ef <bwrite>
8010349e:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034a1:	83 ec 0c             	sub    $0xc,%esp
801034a4:	ff 75 f0             	pushl  -0x10(%ebp)
801034a7:	e8 82 cd ff ff       	call   8010022e <brelse>
801034ac:	83 c4 10             	add    $0x10,%esp
}
801034af:	90                   	nop
801034b0:	c9                   	leave  
801034b1:	c3                   	ret    

801034b2 <recover_from_log>:

static void
recover_from_log(void)
{
801034b2:	55                   	push   %ebp
801034b3:	89 e5                	mov    %esp,%ebp
801034b5:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034b8:	e8 fe fe ff ff       	call   801033bb <read_head>
  install_trans(); // if committed, copy from log to disk
801034bd:	e8 41 fe ff ff       	call   80103303 <install_trans>
  log.lh.n = 0;
801034c2:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
801034c9:	00 00 00 
  write_head(); // clear the log
801034cc:	e8 5e ff ff ff       	call   8010342f <write_head>
}
801034d1:	90                   	nop
801034d2:	c9                   	leave  
801034d3:	c3                   	ret    

801034d4 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034d4:	55                   	push   %ebp
801034d5:	89 e5                	mov    %esp,%ebp
801034d7:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801034da:	83 ec 0c             	sub    $0xc,%esp
801034dd:	68 60 22 11 80       	push   $0x80112260
801034e2:	e8 0c 1b 00 00       	call   80104ff3 <acquire>
801034e7:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801034ea:	a1 a0 22 11 80       	mov    0x801122a0,%eax
801034ef:	85 c0                	test   %eax,%eax
801034f1:	74 17                	je     8010350a <begin_op+0x36>
      sleep(&log, &log.lock);
801034f3:	83 ec 08             	sub    $0x8,%esp
801034f6:	68 60 22 11 80       	push   $0x80112260
801034fb:	68 60 22 11 80       	push   $0x80112260
80103500:	e8 f5 17 00 00       	call   80104cfa <sleep>
80103505:	83 c4 10             	add    $0x10,%esp
80103508:	eb e0                	jmp    801034ea <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010350a:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103510:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103515:	8d 50 01             	lea    0x1(%eax),%edx
80103518:	89 d0                	mov    %edx,%eax
8010351a:	c1 e0 02             	shl    $0x2,%eax
8010351d:	01 d0                	add    %edx,%eax
8010351f:	01 c0                	add    %eax,%eax
80103521:	01 c8                	add    %ecx,%eax
80103523:	83 f8 1e             	cmp    $0x1e,%eax
80103526:	7e 17                	jle    8010353f <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	68 60 22 11 80       	push   $0x80112260
80103530:	68 60 22 11 80       	push   $0x80112260
80103535:	e8 c0 17 00 00       	call   80104cfa <sleep>
8010353a:	83 c4 10             	add    $0x10,%esp
8010353d:	eb ab                	jmp    801034ea <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010353f:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103544:	83 c0 01             	add    $0x1,%eax
80103547:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
8010354c:	83 ec 0c             	sub    $0xc,%esp
8010354f:	68 60 22 11 80       	push   $0x80112260
80103554:	e8 01 1b 00 00       	call   8010505a <release>
80103559:	83 c4 10             	add    $0x10,%esp
      break;
8010355c:	90                   	nop
    }
  }
}
8010355d:	90                   	nop
8010355e:	c9                   	leave  
8010355f:	c3                   	ret    

80103560 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103560:	55                   	push   %ebp
80103561:	89 e5                	mov    %esp,%ebp
80103563:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103566:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010356d:	83 ec 0c             	sub    $0xc,%esp
80103570:	68 60 22 11 80       	push   $0x80112260
80103575:	e8 79 1a 00 00       	call   80104ff3 <acquire>
8010357a:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010357d:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103582:	83 e8 01             	sub    $0x1,%eax
80103585:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
8010358a:	a1 a0 22 11 80       	mov    0x801122a0,%eax
8010358f:	85 c0                	test   %eax,%eax
80103591:	74 0d                	je     801035a0 <end_op+0x40>
    panic("log.committing");
80103593:	83 ec 0c             	sub    $0xc,%esp
80103596:	68 c0 87 10 80       	push   $0x801087c0
8010359b:	e8 c6 cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801035a0:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801035a5:	85 c0                	test   %eax,%eax
801035a7:	75 13                	jne    801035bc <end_op+0x5c>
    do_commit = 1;
801035a9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035b0:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
801035b7:	00 00 00 
801035ba:	eb 10                	jmp    801035cc <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801035bc:	83 ec 0c             	sub    $0xc,%esp
801035bf:	68 60 22 11 80       	push   $0x80112260
801035c4:	e8 1c 18 00 00       	call   80104de5 <wakeup>
801035c9:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801035cc:	83 ec 0c             	sub    $0xc,%esp
801035cf:	68 60 22 11 80       	push   $0x80112260
801035d4:	e8 81 1a 00 00       	call   8010505a <release>
801035d9:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801035dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035e0:	74 3f                	je     80103621 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035e2:	e8 f5 00 00 00       	call   801036dc <commit>
    acquire(&log.lock);
801035e7:	83 ec 0c             	sub    $0xc,%esp
801035ea:	68 60 22 11 80       	push   $0x80112260
801035ef:	e8 ff 19 00 00       	call   80104ff3 <acquire>
801035f4:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801035f7:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
801035fe:	00 00 00 
    wakeup(&log);
80103601:	83 ec 0c             	sub    $0xc,%esp
80103604:	68 60 22 11 80       	push   $0x80112260
80103609:	e8 d7 17 00 00       	call   80104de5 <wakeup>
8010360e:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103611:	83 ec 0c             	sub    $0xc,%esp
80103614:	68 60 22 11 80       	push   $0x80112260
80103619:	e8 3c 1a 00 00       	call   8010505a <release>
8010361e:	83 c4 10             	add    $0x10,%esp
  }
}
80103621:	90                   	nop
80103622:	c9                   	leave  
80103623:	c3                   	ret    

80103624 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103624:	55                   	push   %ebp
80103625:	89 e5                	mov    %esp,%ebp
80103627:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010362a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103631:	e9 95 00 00 00       	jmp    801036cb <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103636:	8b 15 94 22 11 80    	mov    0x80112294,%edx
8010363c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010363f:	01 d0                	add    %edx,%eax
80103641:	83 c0 01             	add    $0x1,%eax
80103644:	89 c2                	mov    %eax,%edx
80103646:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010364b:	83 ec 08             	sub    $0x8,%esp
8010364e:	52                   	push   %edx
8010364f:	50                   	push   %eax
80103650:	e8 61 cb ff ff       	call   801001b6 <bread>
80103655:	83 c4 10             	add    $0x10,%esp
80103658:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
8010365b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010365e:	83 c0 10             	add    $0x10,%eax
80103661:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103668:	89 c2                	mov    %eax,%edx
8010366a:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010366f:	83 ec 08             	sub    $0x8,%esp
80103672:	52                   	push   %edx
80103673:	50                   	push   %eax
80103674:	e8 3d cb ff ff       	call   801001b6 <bread>
80103679:	83 c4 10             	add    $0x10,%esp
8010367c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010367f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103682:	8d 50 18             	lea    0x18(%eax),%edx
80103685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103688:	83 c0 18             	add    $0x18,%eax
8010368b:	83 ec 04             	sub    $0x4,%esp
8010368e:	68 00 02 00 00       	push   $0x200
80103693:	52                   	push   %edx
80103694:	50                   	push   %eax
80103695:	e8 7b 1c 00 00       	call   80105315 <memmove>
8010369a:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010369d:	83 ec 0c             	sub    $0xc,%esp
801036a0:	ff 75 f0             	pushl  -0x10(%ebp)
801036a3:	e8 47 cb ff ff       	call   801001ef <bwrite>
801036a8:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801036ab:	83 ec 0c             	sub    $0xc,%esp
801036ae:	ff 75 ec             	pushl  -0x14(%ebp)
801036b1:	e8 78 cb ff ff       	call   8010022e <brelse>
801036b6:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801036b9:	83 ec 0c             	sub    $0xc,%esp
801036bc:	ff 75 f0             	pushl  -0x10(%ebp)
801036bf:	e8 6a cb ff ff       	call   8010022e <brelse>
801036c4:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036cb:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036d0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036d3:	0f 8f 5d ff ff ff    	jg     80103636 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801036d9:	90                   	nop
801036da:	c9                   	leave  
801036db:	c3                   	ret    

801036dc <commit>:

static void
commit()
{
801036dc:	55                   	push   %ebp
801036dd:	89 e5                	mov    %esp,%ebp
801036df:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801036e2:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036e7:	85 c0                	test   %eax,%eax
801036e9:	7e 1e                	jle    80103709 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036eb:	e8 34 ff ff ff       	call   80103624 <write_log>
    write_head();    // Write header to disk -- the real commit
801036f0:	e8 3a fd ff ff       	call   8010342f <write_head>
    install_trans(); // Now install writes to home locations
801036f5:	e8 09 fc ff ff       	call   80103303 <install_trans>
    log.lh.n = 0; 
801036fa:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103701:	00 00 00 
    write_head();    // Erase the transaction from the log
80103704:	e8 26 fd ff ff       	call   8010342f <write_head>
  }
}
80103709:	90                   	nop
8010370a:	c9                   	leave  
8010370b:	c3                   	ret    

8010370c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010370c:	55                   	push   %ebp
8010370d:	89 e5                	mov    %esp,%ebp
8010370f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103712:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103717:	83 f8 1d             	cmp    $0x1d,%eax
8010371a:	7f 12                	jg     8010372e <log_write+0x22>
8010371c:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103721:	8b 15 98 22 11 80    	mov    0x80112298,%edx
80103727:	83 ea 01             	sub    $0x1,%edx
8010372a:	39 d0                	cmp    %edx,%eax
8010372c:	7c 0d                	jl     8010373b <log_write+0x2f>
    panic("too big a transaction");
8010372e:	83 ec 0c             	sub    $0xc,%esp
80103731:	68 cf 87 10 80       	push   $0x801087cf
80103736:	e8 2b ce ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
8010373b:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103740:	85 c0                	test   %eax,%eax
80103742:	7f 0d                	jg     80103751 <log_write+0x45>
    panic("log_write outside of trans");
80103744:	83 ec 0c             	sub    $0xc,%esp
80103747:	68 e5 87 10 80       	push   $0x801087e5
8010374c:	e8 15 ce ff ff       	call   80100566 <panic>

  for (i = 0; i < log.lh.n; i++) {
80103751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103758:	eb 1d                	jmp    80103777 <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
8010375a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010375d:	83 c0 10             	add    $0x10,%eax
80103760:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103767:	89 c2                	mov    %eax,%edx
80103769:	8b 45 08             	mov    0x8(%ebp),%eax
8010376c:	8b 40 08             	mov    0x8(%eax),%eax
8010376f:	39 c2                	cmp    %eax,%edx
80103771:	74 10                	je     80103783 <log_write+0x77>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103773:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103777:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010377c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010377f:	7f d9                	jg     8010375a <log_write+0x4e>
80103781:	eb 01                	jmp    80103784 <log_write+0x78>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
80103783:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103784:	8b 45 08             	mov    0x8(%ebp),%eax
80103787:	8b 40 08             	mov    0x8(%eax),%eax
8010378a:	89 c2                	mov    %eax,%edx
8010378c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010378f:	83 c0 10             	add    $0x10,%eax
80103792:	89 14 85 6c 22 11 80 	mov    %edx,-0x7feedd94(,%eax,4)
  if (i == log.lh.n)
80103799:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010379e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037a1:	75 0d                	jne    801037b0 <log_write+0xa4>
    log.lh.n++;
801037a3:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801037a8:	83 c0 01             	add    $0x1,%eax
801037ab:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
801037b0:	8b 45 08             	mov    0x8(%ebp),%eax
801037b3:	8b 00                	mov    (%eax),%eax
801037b5:	83 c8 04             	or     $0x4,%eax
801037b8:	89 c2                	mov    %eax,%edx
801037ba:	8b 45 08             	mov    0x8(%ebp),%eax
801037bd:	89 10                	mov    %edx,(%eax)
}
801037bf:	90                   	nop
801037c0:	c9                   	leave  
801037c1:	c3                   	ret    

801037c2 <v2p>:
801037c2:	55                   	push   %ebp
801037c3:	89 e5                	mov    %esp,%ebp
801037c5:	8b 45 08             	mov    0x8(%ebp),%eax
801037c8:	05 00 00 00 80       	add    $0x80000000,%eax
801037cd:	5d                   	pop    %ebp
801037ce:	c3                   	ret    

801037cf <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801037cf:	55                   	push   %ebp
801037d0:	89 e5                	mov    %esp,%ebp
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	05 00 00 00 80       	add    $0x80000000,%eax
801037da:	5d                   	pop    %ebp
801037db:	c3                   	ret    

801037dc <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037dc:	55                   	push   %ebp
801037dd:	89 e5                	mov    %esp,%ebp
801037df:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037e2:	8b 55 08             	mov    0x8(%ebp),%edx
801037e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801037e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037eb:	f0 87 02             	lock xchg %eax,(%edx)
801037ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037f4:	c9                   	leave  
801037f5:	c3                   	ret    

801037f6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037f6:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801037fa:	83 e4 f0             	and    $0xfffffff0,%esp
801037fd:	ff 71 fc             	pushl  -0x4(%ecx)
80103800:	55                   	push   %ebp
80103801:	89 e5                	mov    %esp,%ebp
80103803:	51                   	push   %ecx
80103804:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103807:	83 ec 08             	sub    $0x8,%esp
8010380a:	68 00 00 40 80       	push   $0x80400000
8010380f:	68 3c 51 11 80       	push   $0x8011513c
80103814:	e8 95 f2 ff ff       	call   80102aae <kinit1>
80103819:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010381c:	e8 24 46 00 00       	call   80107e45 <kvmalloc>
  mpinit();        // collect info about this machine
80103821:	e8 48 04 00 00       	call   80103c6e <mpinit>
  lapicinit();
80103826:	e8 02 f6 ff ff       	call   80102e2d <lapicinit>
  seginit();       // set up segments
8010382b:	e8 be 3f 00 00       	call   801077ee <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103830:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103836:	0f b6 00             	movzbl (%eax),%eax
80103839:	0f b6 c0             	movzbl %al,%eax
8010383c:	83 ec 08             	sub    $0x8,%esp
8010383f:	50                   	push   %eax
80103840:	68 00 88 10 80       	push   $0x80108800
80103845:	e8 7c cb ff ff       	call   801003c6 <cprintf>
8010384a:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010384d:	e8 72 06 00 00       	call   80103ec4 <picinit>
  ioapicinit();    // another interrupt controller
80103852:	e8 4c f1 ff ff       	call   801029a3 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103857:	e8 8d d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
8010385c:	e8 e9 32 00 00       	call   80106b4a <uartinit>
  pinit();         // process table
80103861:	e8 f8 0b 00 00       	call   8010445e <pinit>
  tvinit();        // trap vectors
80103866:	e8 a9 2e 00 00       	call   80106714 <tvinit>
  binit();         // buffer cache
8010386b:	e8 c4 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103870:	e8 e5 d6 ff ff       	call   80100f5a <fileinit>
  iinit();         // inode cache
80103875:	e8 de dd ff ff       	call   80101658 <iinit>
  ideinit();       // disk
8010387a:	e8 68 ed ff ff       	call   801025e7 <ideinit>
  if(!ismp)
8010387f:	a1 44 23 11 80       	mov    0x80112344,%eax
80103884:	85 c0                	test   %eax,%eax
80103886:	75 05                	jne    8010388d <main+0x97>
    timerinit();   // uniprocessor timer
80103888:	e8 e4 2d 00 00       	call   80106671 <timerinit>
  startothers();   // start other processors
8010388d:	e8 7f 00 00 00       	call   80103911 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103892:	83 ec 08             	sub    $0x8,%esp
80103895:	68 00 00 00 8e       	push   $0x8e000000
8010389a:	68 00 00 40 80       	push   $0x80400000
8010389f:	e8 43 f2 ff ff       	call   80102ae7 <kinit2>
801038a4:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038a7:	e8 d6 0c 00 00       	call   80104582 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801038ac:	e8 1a 00 00 00       	call   801038cb <mpmain>

801038b1 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038b1:	55                   	push   %ebp
801038b2:	89 e5                	mov    %esp,%ebp
801038b4:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801038b7:	e8 a1 45 00 00       	call   80107e5d <switchkvm>
  seginit();
801038bc:	e8 2d 3f 00 00       	call   801077ee <seginit>
  lapicinit();
801038c1:	e8 67 f5 ff ff       	call   80102e2d <lapicinit>
  mpmain();
801038c6:	e8 00 00 00 00       	call   801038cb <mpmain>

801038cb <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038cb:	55                   	push   %ebp
801038cc:	89 e5                	mov    %esp,%ebp
801038ce:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801038d1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038d7:	0f b6 00             	movzbl (%eax),%eax
801038da:	0f b6 c0             	movzbl %al,%eax
801038dd:	83 ec 08             	sub    $0x8,%esp
801038e0:	50                   	push   %eax
801038e1:	68 17 88 10 80       	push   $0x80108817
801038e6:	e8 db ca ff ff       	call   801003c6 <cprintf>
801038eb:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801038ee:	e8 97 2f 00 00       	call   8010688a <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801038f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038f9:	05 a8 00 00 00       	add    $0xa8,%eax
801038fe:	83 ec 08             	sub    $0x8,%esp
80103901:	6a 01                	push   $0x1
80103903:	50                   	push   %eax
80103904:	e8 d3 fe ff ff       	call   801037dc <xchg>
80103909:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010390c:	e8 1c 12 00 00       	call   80104b2d <scheduler>

80103911 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103911:	55                   	push   %ebp
80103912:	89 e5                	mov    %esp,%ebp
80103914:	53                   	push   %ebx
80103915:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103918:	68 00 70 00 00       	push   $0x7000
8010391d:	e8 ad fe ff ff       	call   801037cf <p2v>
80103922:	83 c4 04             	add    $0x4,%esp
80103925:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103928:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010392d:	83 ec 04             	sub    $0x4,%esp
80103930:	50                   	push   %eax
80103931:	68 0c b5 10 80       	push   $0x8010b50c
80103936:	ff 75 f0             	pushl  -0x10(%ebp)
80103939:	e8 d7 19 00 00       	call   80105315 <memmove>
8010393e:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103941:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
80103948:	e9 90 00 00 00       	jmp    801039dd <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
8010394d:	e8 f9 f5 ff ff       	call   80102f4b <cpunum>
80103952:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103958:	05 60 23 11 80       	add    $0x80112360,%eax
8010395d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103960:	74 73                	je     801039d5 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103962:	e8 7e f2 ff ff       	call   80102be5 <kalloc>
80103967:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010396a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010396d:	83 e8 04             	sub    $0x4,%eax
80103970:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103973:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103979:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010397b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010397e:	83 e8 08             	sub    $0x8,%eax
80103981:	c7 00 b1 38 10 80    	movl   $0x801038b1,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103987:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010398a:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010398d:	83 ec 0c             	sub    $0xc,%esp
80103990:	68 00 a0 10 80       	push   $0x8010a000
80103995:	e8 28 fe ff ff       	call   801037c2 <v2p>
8010399a:	83 c4 10             	add    $0x10,%esp
8010399d:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010399f:	83 ec 0c             	sub    $0xc,%esp
801039a2:	ff 75 f0             	pushl  -0x10(%ebp)
801039a5:	e8 18 fe ff ff       	call   801037c2 <v2p>
801039aa:	83 c4 10             	add    $0x10,%esp
801039ad:	89 c2                	mov    %eax,%edx
801039af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b2:	0f b6 00             	movzbl (%eax),%eax
801039b5:	0f b6 c0             	movzbl %al,%eax
801039b8:	83 ec 08             	sub    $0x8,%esp
801039bb:	52                   	push   %edx
801039bc:	50                   	push   %eax
801039bd:	e8 03 f6 ff ff       	call   80102fc5 <lapicstartap>
801039c2:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039c5:	90                   	nop
801039c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801039cf:	85 c0                	test   %eax,%eax
801039d1:	74 f3                	je     801039c6 <startothers+0xb5>
801039d3:	eb 01                	jmp    801039d6 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801039d5:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801039d6:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801039dd:	a1 40 29 11 80       	mov    0x80112940,%eax
801039e2:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039e8:	05 60 23 11 80       	add    $0x80112360,%eax
801039ed:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f0:	0f 87 57 ff ff ff    	ja     8010394d <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039f6:	90                   	nop
801039f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039fa:	c9                   	leave  
801039fb:	c3                   	ret    

801039fc <p2v>:
801039fc:	55                   	push   %ebp
801039fd:	89 e5                	mov    %esp,%ebp
801039ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103a02:	05 00 00 00 80       	add    $0x80000000,%eax
80103a07:	5d                   	pop    %ebp
80103a08:	c3                   	ret    

80103a09 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 14             	sub    $0x14,%esp
80103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a12:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a16:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a1a:	89 c2                	mov    %eax,%edx
80103a1c:	ec                   	in     (%dx),%al
80103a1d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a20:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a24:	c9                   	leave  
80103a25:	c3                   	ret    

80103a26 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a26:	55                   	push   %ebp
80103a27:	89 e5                	mov    %esp,%ebp
80103a29:	83 ec 08             	sub    $0x8,%esp
80103a2c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a32:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a36:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a39:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a3d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a41:	ee                   	out    %al,(%dx)
}
80103a42:	90                   	nop
80103a43:	c9                   	leave  
80103a44:	c3                   	ret    

80103a45 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103a45:	55                   	push   %ebp
80103a46:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103a48:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103a4d:	89 c2                	mov    %eax,%edx
80103a4f:	b8 60 23 11 80       	mov    $0x80112360,%eax
80103a54:	29 c2                	sub    %eax,%edx
80103a56:	89 d0                	mov    %edx,%eax
80103a58:	c1 f8 02             	sar    $0x2,%eax
80103a5b:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a61:	5d                   	pop    %ebp
80103a62:	c3                   	ret    

80103a63 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a63:	55                   	push   %ebp
80103a64:	89 e5                	mov    %esp,%ebp
80103a66:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a69:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a70:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a77:	eb 15                	jmp    80103a8e <sum+0x2b>
    sum += addr[i];
80103a79:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7f:	01 d0                	add    %edx,%eax
80103a81:	0f b6 00             	movzbl (%eax),%eax
80103a84:	0f b6 c0             	movzbl %al,%eax
80103a87:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a8a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a91:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a94:	7c e3                	jl     80103a79 <sum+0x16>
    sum += addr[i];
  return sum;
80103a96:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a99:	c9                   	leave  
80103a9a:	c3                   	ret    

80103a9b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a9b:	55                   	push   %ebp
80103a9c:	89 e5                	mov    %esp,%ebp
80103a9e:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103aa1:	ff 75 08             	pushl  0x8(%ebp)
80103aa4:	e8 53 ff ff ff       	call   801039fc <p2v>
80103aa9:	83 c4 04             	add    $0x4,%esp
80103aac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab5:	01 d0                	add    %edx,%eax
80103ab7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ac0:	eb 36                	jmp    80103af8 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ac2:	83 ec 04             	sub    $0x4,%esp
80103ac5:	6a 04                	push   $0x4
80103ac7:	68 28 88 10 80       	push   $0x80108828
80103acc:	ff 75 f4             	pushl  -0xc(%ebp)
80103acf:	e8 e9 17 00 00       	call   801052bd <memcmp>
80103ad4:	83 c4 10             	add    $0x10,%esp
80103ad7:	85 c0                	test   %eax,%eax
80103ad9:	75 19                	jne    80103af4 <mpsearch1+0x59>
80103adb:	83 ec 08             	sub    $0x8,%esp
80103ade:	6a 10                	push   $0x10
80103ae0:	ff 75 f4             	pushl  -0xc(%ebp)
80103ae3:	e8 7b ff ff ff       	call   80103a63 <sum>
80103ae8:	83 c4 10             	add    $0x10,%esp
80103aeb:	84 c0                	test   %al,%al
80103aed:	75 05                	jne    80103af4 <mpsearch1+0x59>
      return (struct mp*)p;
80103aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af2:	eb 11                	jmp    80103b05 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103af4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103afe:	72 c2                	jb     80103ac2 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b05:	c9                   	leave  
80103b06:	c3                   	ret    

80103b07 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b07:	55                   	push   %ebp
80103b08:	89 e5                	mov    %esp,%ebp
80103b0a:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b0d:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b17:	83 c0 0f             	add    $0xf,%eax
80103b1a:	0f b6 00             	movzbl (%eax),%eax
80103b1d:	0f b6 c0             	movzbl %al,%eax
80103b20:	c1 e0 08             	shl    $0x8,%eax
80103b23:	89 c2                	mov    %eax,%edx
80103b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b28:	83 c0 0e             	add    $0xe,%eax
80103b2b:	0f b6 00             	movzbl (%eax),%eax
80103b2e:	0f b6 c0             	movzbl %al,%eax
80103b31:	09 d0                	or     %edx,%eax
80103b33:	c1 e0 04             	shl    $0x4,%eax
80103b36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b3d:	74 21                	je     80103b60 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b3f:	83 ec 08             	sub    $0x8,%esp
80103b42:	68 00 04 00 00       	push   $0x400
80103b47:	ff 75 f0             	pushl  -0x10(%ebp)
80103b4a:	e8 4c ff ff ff       	call   80103a9b <mpsearch1>
80103b4f:	83 c4 10             	add    $0x10,%esp
80103b52:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b55:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b59:	74 51                	je     80103bac <mpsearch+0xa5>
      return mp;
80103b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b5e:	eb 61                	jmp    80103bc1 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b63:	83 c0 14             	add    $0x14,%eax
80103b66:	0f b6 00             	movzbl (%eax),%eax
80103b69:	0f b6 c0             	movzbl %al,%eax
80103b6c:	c1 e0 08             	shl    $0x8,%eax
80103b6f:	89 c2                	mov    %eax,%edx
80103b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b74:	83 c0 13             	add    $0x13,%eax
80103b77:	0f b6 00             	movzbl (%eax),%eax
80103b7a:	0f b6 c0             	movzbl %al,%eax
80103b7d:	09 d0                	or     %edx,%eax
80103b7f:	c1 e0 0a             	shl    $0xa,%eax
80103b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b88:	2d 00 04 00 00       	sub    $0x400,%eax
80103b8d:	83 ec 08             	sub    $0x8,%esp
80103b90:	68 00 04 00 00       	push   $0x400
80103b95:	50                   	push   %eax
80103b96:	e8 00 ff ff ff       	call   80103a9b <mpsearch1>
80103b9b:	83 c4 10             	add    $0x10,%esp
80103b9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ba1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ba5:	74 05                	je     80103bac <mpsearch+0xa5>
      return mp;
80103ba7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103baa:	eb 15                	jmp    80103bc1 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103bac:	83 ec 08             	sub    $0x8,%esp
80103baf:	68 00 00 01 00       	push   $0x10000
80103bb4:	68 00 00 0f 00       	push   $0xf0000
80103bb9:	e8 dd fe ff ff       	call   80103a9b <mpsearch1>
80103bbe:	83 c4 10             	add    $0x10,%esp
}
80103bc1:	c9                   	leave  
80103bc2:	c3                   	ret    

80103bc3 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103bc3:	55                   	push   %ebp
80103bc4:	89 e5                	mov    %esp,%ebp
80103bc6:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103bc9:	e8 39 ff ff ff       	call   80103b07 <mpsearch>
80103bce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103bd5:	74 0a                	je     80103be1 <mpconfig+0x1e>
80103bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bda:	8b 40 04             	mov    0x4(%eax),%eax
80103bdd:	85 c0                	test   %eax,%eax
80103bdf:	75 0a                	jne    80103beb <mpconfig+0x28>
    return 0;
80103be1:	b8 00 00 00 00       	mov    $0x0,%eax
80103be6:	e9 81 00 00 00       	jmp    80103c6c <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bee:	8b 40 04             	mov    0x4(%eax),%eax
80103bf1:	83 ec 0c             	sub    $0xc,%esp
80103bf4:	50                   	push   %eax
80103bf5:	e8 02 fe ff ff       	call   801039fc <p2v>
80103bfa:	83 c4 10             	add    $0x10,%esp
80103bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c00:	83 ec 04             	sub    $0x4,%esp
80103c03:	6a 04                	push   $0x4
80103c05:	68 2d 88 10 80       	push   $0x8010882d
80103c0a:	ff 75 f0             	pushl  -0x10(%ebp)
80103c0d:	e8 ab 16 00 00       	call   801052bd <memcmp>
80103c12:	83 c4 10             	add    $0x10,%esp
80103c15:	85 c0                	test   %eax,%eax
80103c17:	74 07                	je     80103c20 <mpconfig+0x5d>
    return 0;
80103c19:	b8 00 00 00 00       	mov    $0x0,%eax
80103c1e:	eb 4c                	jmp    80103c6c <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c23:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c27:	3c 01                	cmp    $0x1,%al
80103c29:	74 12                	je     80103c3d <mpconfig+0x7a>
80103c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c32:	3c 04                	cmp    $0x4,%al
80103c34:	74 07                	je     80103c3d <mpconfig+0x7a>
    return 0;
80103c36:	b8 00 00 00 00       	mov    $0x0,%eax
80103c3b:	eb 2f                	jmp    80103c6c <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c40:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c44:	0f b7 c0             	movzwl %ax,%eax
80103c47:	83 ec 08             	sub    $0x8,%esp
80103c4a:	50                   	push   %eax
80103c4b:	ff 75 f0             	pushl  -0x10(%ebp)
80103c4e:	e8 10 fe ff ff       	call   80103a63 <sum>
80103c53:	83 c4 10             	add    $0x10,%esp
80103c56:	84 c0                	test   %al,%al
80103c58:	74 07                	je     80103c61 <mpconfig+0x9e>
    return 0;
80103c5a:	b8 00 00 00 00       	mov    $0x0,%eax
80103c5f:	eb 0b                	jmp    80103c6c <mpconfig+0xa9>
  *pmp = mp;
80103c61:	8b 45 08             	mov    0x8(%ebp),%eax
80103c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c67:	89 10                	mov    %edx,(%eax)
  return conf;
80103c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c6c:	c9                   	leave  
80103c6d:	c3                   	ret    

80103c6e <mpinit>:

void
mpinit(void)
{
80103c6e:	55                   	push   %ebp
80103c6f:	89 e5                	mov    %esp,%ebp
80103c71:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c74:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103c7b:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c7e:	83 ec 0c             	sub    $0xc,%esp
80103c81:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c84:	50                   	push   %eax
80103c85:	e8 39 ff ff ff       	call   80103bc3 <mpconfig>
80103c8a:	83 c4 10             	add    $0x10,%esp
80103c8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c94:	0f 84 96 01 00 00    	je     80103e30 <mpinit+0x1c2>
    return;
  ismp = 1;
80103c9a:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103ca1:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca7:	8b 40 24             	mov    0x24(%eax),%eax
80103caa:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb2:	83 c0 2c             	add    $0x2c,%eax
80103cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cbf:	0f b7 d0             	movzwl %ax,%edx
80103cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc5:	01 d0                	add    %edx,%eax
80103cc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cca:	e9 f2 00 00 00       	jmp    80103dc1 <mpinit+0x153>
    switch(*p){
80103ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd2:	0f b6 00             	movzbl (%eax),%eax
80103cd5:	0f b6 c0             	movzbl %al,%eax
80103cd8:	83 f8 04             	cmp    $0x4,%eax
80103cdb:	0f 87 bc 00 00 00    	ja     80103d9d <mpinit+0x12f>
80103ce1:	8b 04 85 70 88 10 80 	mov    -0x7fef7790(,%eax,4),%eax
80103ce8:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ced:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103cf0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cf3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cf7:	0f b6 d0             	movzbl %al,%edx
80103cfa:	a1 40 29 11 80       	mov    0x80112940,%eax
80103cff:	39 c2                	cmp    %eax,%edx
80103d01:	74 2b                	je     80103d2e <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d06:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d0a:	0f b6 d0             	movzbl %al,%edx
80103d0d:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d12:	83 ec 04             	sub    $0x4,%esp
80103d15:	52                   	push   %edx
80103d16:	50                   	push   %eax
80103d17:	68 32 88 10 80       	push   $0x80108832
80103d1c:	e8 a5 c6 ff ff       	call   801003c6 <cprintf>
80103d21:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103d24:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103d2b:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103d2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d31:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103d35:	0f b6 c0             	movzbl %al,%eax
80103d38:	83 e0 02             	and    $0x2,%eax
80103d3b:	85 c0                	test   %eax,%eax
80103d3d:	74 15                	je     80103d54 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103d3f:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d44:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d4a:	05 60 23 11 80       	add    $0x80112360,%eax
80103d4f:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103d54:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d59:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103d5f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d65:	05 60 23 11 80       	add    $0x80112360,%eax
80103d6a:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103d6c:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d71:	83 c0 01             	add    $0x1,%eax
80103d74:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103d79:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d7d:	eb 42                	jmp    80103dc1 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d88:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d8c:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103d91:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d95:	eb 2a                	jmp    80103dc1 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d97:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d9b:	eb 24                	jmp    80103dc1 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da0:	0f b6 00             	movzbl (%eax),%eax
80103da3:	0f b6 c0             	movzbl %al,%eax
80103da6:	83 ec 08             	sub    $0x8,%esp
80103da9:	50                   	push   %eax
80103daa:	68 50 88 10 80       	push   $0x80108850
80103daf:	e8 12 c6 ff ff       	call   801003c6 <cprintf>
80103db4:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103db7:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103dbe:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103dc7:	0f 82 02 ff ff ff    	jb     80103ccf <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103dcd:	a1 44 23 11 80       	mov    0x80112344,%eax
80103dd2:	85 c0                	test   %eax,%eax
80103dd4:	75 1d                	jne    80103df3 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103dd6:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103ddd:	00 00 00 
    lapic = 0;
80103de0:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103de7:	00 00 00 
    ioapicid = 0;
80103dea:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103df1:	eb 3e                	jmp    80103e31 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103df3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103dfa:	84 c0                	test   %al,%al
80103dfc:	74 33                	je     80103e31 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dfe:	83 ec 08             	sub    $0x8,%esp
80103e01:	6a 70                	push   $0x70
80103e03:	6a 22                	push   $0x22
80103e05:	e8 1c fc ff ff       	call   80103a26 <outb>
80103e0a:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e0d:	83 ec 0c             	sub    $0xc,%esp
80103e10:	6a 23                	push   $0x23
80103e12:	e8 f2 fb ff ff       	call   80103a09 <inb>
80103e17:	83 c4 10             	add    $0x10,%esp
80103e1a:	83 c8 01             	or     $0x1,%eax
80103e1d:	0f b6 c0             	movzbl %al,%eax
80103e20:	83 ec 08             	sub    $0x8,%esp
80103e23:	50                   	push   %eax
80103e24:	6a 23                	push   $0x23
80103e26:	e8 fb fb ff ff       	call   80103a26 <outb>
80103e2b:	83 c4 10             	add    $0x10,%esp
80103e2e:	eb 01                	jmp    80103e31 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103e30:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103e31:	c9                   	leave  
80103e32:	c3                   	ret    

80103e33 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e33:	55                   	push   %ebp
80103e34:	89 e5                	mov    %esp,%ebp
80103e36:	83 ec 08             	sub    $0x8,%esp
80103e39:	8b 55 08             	mov    0x8(%ebp),%edx
80103e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e3f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e43:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e46:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e4a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e4e:	ee                   	out    %al,(%dx)
}
80103e4f:	90                   	nop
80103e50:	c9                   	leave  
80103e51:	c3                   	ret    

80103e52 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e52:	55                   	push   %ebp
80103e53:	89 e5                	mov    %esp,%ebp
80103e55:	83 ec 04             	sub    $0x4,%esp
80103e58:	8b 45 08             	mov    0x8(%ebp),%eax
80103e5b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e5f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e63:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103e69:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e6d:	0f b6 c0             	movzbl %al,%eax
80103e70:	50                   	push   %eax
80103e71:	6a 21                	push   $0x21
80103e73:	e8 bb ff ff ff       	call   80103e33 <outb>
80103e78:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103e7b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e7f:	66 c1 e8 08          	shr    $0x8,%ax
80103e83:	0f b6 c0             	movzbl %al,%eax
80103e86:	50                   	push   %eax
80103e87:	68 a1 00 00 00       	push   $0xa1
80103e8c:	e8 a2 ff ff ff       	call   80103e33 <outb>
80103e91:	83 c4 08             	add    $0x8,%esp
}
80103e94:	90                   	nop
80103e95:	c9                   	leave  
80103e96:	c3                   	ret    

80103e97 <picenable>:

void
picenable(int irq)
{
80103e97:	55                   	push   %ebp
80103e98:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9d:	ba 01 00 00 00       	mov    $0x1,%edx
80103ea2:	89 c1                	mov    %eax,%ecx
80103ea4:	d3 e2                	shl    %cl,%edx
80103ea6:	89 d0                	mov    %edx,%eax
80103ea8:	f7 d0                	not    %eax
80103eaa:	89 c2                	mov    %eax,%edx
80103eac:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103eb3:	21 d0                	and    %edx,%eax
80103eb5:	0f b7 c0             	movzwl %ax,%eax
80103eb8:	50                   	push   %eax
80103eb9:	e8 94 ff ff ff       	call   80103e52 <picsetmask>
80103ebe:	83 c4 04             	add    $0x4,%esp
}
80103ec1:	90                   	nop
80103ec2:	c9                   	leave  
80103ec3:	c3                   	ret    

80103ec4 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ec4:	55                   	push   %ebp
80103ec5:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ec7:	68 ff 00 00 00       	push   $0xff
80103ecc:	6a 21                	push   $0x21
80103ece:	e8 60 ff ff ff       	call   80103e33 <outb>
80103ed3:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103ed6:	68 ff 00 00 00       	push   $0xff
80103edb:	68 a1 00 00 00       	push   $0xa1
80103ee0:	e8 4e ff ff ff       	call   80103e33 <outb>
80103ee5:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103ee8:	6a 11                	push   $0x11
80103eea:	6a 20                	push   $0x20
80103eec:	e8 42 ff ff ff       	call   80103e33 <outb>
80103ef1:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ef4:	6a 20                	push   $0x20
80103ef6:	6a 21                	push   $0x21
80103ef8:	e8 36 ff ff ff       	call   80103e33 <outb>
80103efd:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f00:	6a 04                	push   $0x4
80103f02:	6a 21                	push   $0x21
80103f04:	e8 2a ff ff ff       	call   80103e33 <outb>
80103f09:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103f0c:	6a 03                	push   $0x3
80103f0e:	6a 21                	push   $0x21
80103f10:	e8 1e ff ff ff       	call   80103e33 <outb>
80103f15:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f18:	6a 11                	push   $0x11
80103f1a:	68 a0 00 00 00       	push   $0xa0
80103f1f:	e8 0f ff ff ff       	call   80103e33 <outb>
80103f24:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f27:	6a 28                	push   $0x28
80103f29:	68 a1 00 00 00       	push   $0xa1
80103f2e:	e8 00 ff ff ff       	call   80103e33 <outb>
80103f33:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f36:	6a 02                	push   $0x2
80103f38:	68 a1 00 00 00       	push   $0xa1
80103f3d:	e8 f1 fe ff ff       	call   80103e33 <outb>
80103f42:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f45:	6a 03                	push   $0x3
80103f47:	68 a1 00 00 00       	push   $0xa1
80103f4c:	e8 e2 fe ff ff       	call   80103e33 <outb>
80103f51:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f54:	6a 68                	push   $0x68
80103f56:	6a 20                	push   $0x20
80103f58:	e8 d6 fe ff ff       	call   80103e33 <outb>
80103f5d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f60:	6a 0a                	push   $0xa
80103f62:	6a 20                	push   $0x20
80103f64:	e8 ca fe ff ff       	call   80103e33 <outb>
80103f69:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103f6c:	6a 68                	push   $0x68
80103f6e:	68 a0 00 00 00       	push   $0xa0
80103f73:	e8 bb fe ff ff       	call   80103e33 <outb>
80103f78:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103f7b:	6a 0a                	push   $0xa
80103f7d:	68 a0 00 00 00       	push   $0xa0
80103f82:	e8 ac fe ff ff       	call   80103e33 <outb>
80103f87:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80103f8a:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f91:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f95:	74 13                	je     80103faa <picinit+0xe6>
    picsetmask(irqmask);
80103f97:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f9e:	0f b7 c0             	movzwl %ax,%eax
80103fa1:	50                   	push   %eax
80103fa2:	e8 ab fe ff ff       	call   80103e52 <picsetmask>
80103fa7:	83 c4 04             	add    $0x4,%esp
}
80103faa:	90                   	nop
80103fab:	c9                   	leave  
80103fac:	c3                   	ret    

80103fad <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fad:	55                   	push   %ebp
80103fae:	89 e5                	mov    %esp,%ebp
80103fb0:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fba:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fbd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc6:	8b 10                	mov    (%eax),%edx
80103fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcb:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fcd:	e8 a6 cf ff ff       	call   80100f78 <filealloc>
80103fd2:	89 c2                	mov    %eax,%edx
80103fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd7:	89 10                	mov    %edx,(%eax)
80103fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdc:	8b 00                	mov    (%eax),%eax
80103fde:	85 c0                	test   %eax,%eax
80103fe0:	0f 84 cb 00 00 00    	je     801040b1 <pipealloc+0x104>
80103fe6:	e8 8d cf ff ff       	call   80100f78 <filealloc>
80103feb:	89 c2                	mov    %eax,%edx
80103fed:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff0:	89 10                	mov    %edx,(%eax)
80103ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff5:	8b 00                	mov    (%eax),%eax
80103ff7:	85 c0                	test   %eax,%eax
80103ff9:	0f 84 b2 00 00 00    	je     801040b1 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fff:	e8 e1 eb ff ff       	call   80102be5 <kalloc>
80104004:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104007:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010400b:	0f 84 9f 00 00 00    	je     801040b0 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104014:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010401b:	00 00 00 
  p->writeopen = 1;
8010401e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104021:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104028:	00 00 00 
  p->nwrite = 0;
8010402b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402e:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104035:	00 00 00 
  p->nread = 0;
80104038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403b:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104042:	00 00 00 
  initlock(&p->lock, "pipe");
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	83 ec 08             	sub    $0x8,%esp
8010404b:	68 84 88 10 80       	push   $0x80108884
80104050:	50                   	push   %eax
80104051:	e8 7b 0f 00 00       	call   80104fd1 <initlock>
80104056:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104059:	8b 45 08             	mov    0x8(%ebp),%eax
8010405c:	8b 00                	mov    (%eax),%eax
8010405e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104064:	8b 45 08             	mov    0x8(%ebp),%eax
80104067:	8b 00                	mov    (%eax),%eax
80104069:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 00                	mov    (%eax),%eax
80104072:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104076:	8b 45 08             	mov    0x8(%ebp),%eax
80104079:	8b 00                	mov    (%eax),%eax
8010407b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010407e:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104081:	8b 45 0c             	mov    0xc(%ebp),%eax
80104084:	8b 00                	mov    (%eax),%eax
80104086:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010408c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408f:	8b 00                	mov    (%eax),%eax
80104091:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104095:	8b 45 0c             	mov    0xc(%ebp),%eax
80104098:	8b 00                	mov    (%eax),%eax
8010409a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010409e:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a1:	8b 00                	mov    (%eax),%eax
801040a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040a6:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040a9:	b8 00 00 00 00       	mov    $0x0,%eax
801040ae:	eb 4e                	jmp    801040fe <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040b0:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040b5:	74 0e                	je     801040c5 <pipealloc+0x118>
    kfree((char*)p);
801040b7:	83 ec 0c             	sub    $0xc,%esp
801040ba:	ff 75 f4             	pushl  -0xc(%ebp)
801040bd:	e8 86 ea ff ff       	call   80102b48 <kfree>
801040c2:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040c5:	8b 45 08             	mov    0x8(%ebp),%eax
801040c8:	8b 00                	mov    (%eax),%eax
801040ca:	85 c0                	test   %eax,%eax
801040cc:	74 11                	je     801040df <pipealloc+0x132>
    fileclose(*f0);
801040ce:	8b 45 08             	mov    0x8(%ebp),%eax
801040d1:	8b 00                	mov    (%eax),%eax
801040d3:	83 ec 0c             	sub    $0xc,%esp
801040d6:	50                   	push   %eax
801040d7:	e8 70 cf ff ff       	call   8010104c <fileclose>
801040dc:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801040df:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e2:	8b 00                	mov    (%eax),%eax
801040e4:	85 c0                	test   %eax,%eax
801040e6:	74 11                	je     801040f9 <pipealloc+0x14c>
    fileclose(*f1);
801040e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801040eb:	8b 00                	mov    (%eax),%eax
801040ed:	83 ec 0c             	sub    $0xc,%esp
801040f0:	50                   	push   %eax
801040f1:	e8 56 cf ff ff       	call   8010104c <fileclose>
801040f6:	83 c4 10             	add    $0x10,%esp
  return -1;
801040f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040fe:	c9                   	leave  
801040ff:	c3                   	ret    

80104100 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104100:	55                   	push   %ebp
80104101:	89 e5                	mov    %esp,%ebp
80104103:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104106:	8b 45 08             	mov    0x8(%ebp),%eax
80104109:	83 ec 0c             	sub    $0xc,%esp
8010410c:	50                   	push   %eax
8010410d:	e8 e1 0e 00 00       	call   80104ff3 <acquire>
80104112:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104115:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104119:	74 23                	je     8010413e <pipeclose+0x3e>
    p->writeopen = 0;
8010411b:	8b 45 08             	mov    0x8(%ebp),%eax
8010411e:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104125:	00 00 00 
    wakeup(&p->nread);
80104128:	8b 45 08             	mov    0x8(%ebp),%eax
8010412b:	05 34 02 00 00       	add    $0x234,%eax
80104130:	83 ec 0c             	sub    $0xc,%esp
80104133:	50                   	push   %eax
80104134:	e8 ac 0c 00 00       	call   80104de5 <wakeup>
80104139:	83 c4 10             	add    $0x10,%esp
8010413c:	eb 21                	jmp    8010415f <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010413e:	8b 45 08             	mov    0x8(%ebp),%eax
80104141:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104148:	00 00 00 
    wakeup(&p->nwrite);
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	05 38 02 00 00       	add    $0x238,%eax
80104153:	83 ec 0c             	sub    $0xc,%esp
80104156:	50                   	push   %eax
80104157:	e8 89 0c 00 00       	call   80104de5 <wakeup>
8010415c:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010415f:	8b 45 08             	mov    0x8(%ebp),%eax
80104162:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104168:	85 c0                	test   %eax,%eax
8010416a:	75 2c                	jne    80104198 <pipeclose+0x98>
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104175:	85 c0                	test   %eax,%eax
80104177:	75 1f                	jne    80104198 <pipeclose+0x98>
    release(&p->lock);
80104179:	8b 45 08             	mov    0x8(%ebp),%eax
8010417c:	83 ec 0c             	sub    $0xc,%esp
8010417f:	50                   	push   %eax
80104180:	e8 d5 0e 00 00       	call   8010505a <release>
80104185:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104188:	83 ec 0c             	sub    $0xc,%esp
8010418b:	ff 75 08             	pushl  0x8(%ebp)
8010418e:	e8 b5 e9 ff ff       	call   80102b48 <kfree>
80104193:	83 c4 10             	add    $0x10,%esp
80104196:	eb 0f                	jmp    801041a7 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104198:	8b 45 08             	mov    0x8(%ebp),%eax
8010419b:	83 ec 0c             	sub    $0xc,%esp
8010419e:	50                   	push   %eax
8010419f:	e8 b6 0e 00 00       	call   8010505a <release>
801041a4:	83 c4 10             	add    $0x10,%esp
}
801041a7:	90                   	nop
801041a8:	c9                   	leave  
801041a9:	c3                   	ret    

801041aa <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041aa:	55                   	push   %ebp
801041ab:	89 e5                	mov    %esp,%ebp
801041ad:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801041b0:	8b 45 08             	mov    0x8(%ebp),%eax
801041b3:	83 ec 0c             	sub    $0xc,%esp
801041b6:	50                   	push   %eax
801041b7:	e8 37 0e 00 00       	call   80104ff3 <acquire>
801041bc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041c6:	e9 ad 00 00 00       	jmp    80104278 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801041cb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ce:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041d4:	85 c0                	test   %eax,%eax
801041d6:	74 0d                	je     801041e5 <pipewrite+0x3b>
801041d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041de:	8b 40 24             	mov    0x24(%eax),%eax
801041e1:	85 c0                	test   %eax,%eax
801041e3:	74 19                	je     801041fe <pipewrite+0x54>
        release(&p->lock);
801041e5:	8b 45 08             	mov    0x8(%ebp),%eax
801041e8:	83 ec 0c             	sub    $0xc,%esp
801041eb:	50                   	push   %eax
801041ec:	e8 69 0e 00 00       	call   8010505a <release>
801041f1:	83 c4 10             	add    $0x10,%esp
        return -1;
801041f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f9:	e9 a8 00 00 00       	jmp    801042a6 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801041fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104201:	05 34 02 00 00       	add    $0x234,%eax
80104206:	83 ec 0c             	sub    $0xc,%esp
80104209:	50                   	push   %eax
8010420a:	e8 d6 0b 00 00       	call   80104de5 <wakeup>
8010420f:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104212:	8b 45 08             	mov    0x8(%ebp),%eax
80104215:	8b 55 08             	mov    0x8(%ebp),%edx
80104218:	81 c2 38 02 00 00    	add    $0x238,%edx
8010421e:	83 ec 08             	sub    $0x8,%esp
80104221:	50                   	push   %eax
80104222:	52                   	push   %edx
80104223:	e8 d2 0a 00 00       	call   80104cfa <sleep>
80104228:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010422b:	8b 45 08             	mov    0x8(%ebp),%eax
8010422e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104234:	8b 45 08             	mov    0x8(%ebp),%eax
80104237:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010423d:	05 00 02 00 00       	add    $0x200,%eax
80104242:	39 c2                	cmp    %eax,%edx
80104244:	74 85                	je     801041cb <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104246:	8b 45 08             	mov    0x8(%ebp),%eax
80104249:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010424f:	8d 48 01             	lea    0x1(%eax),%ecx
80104252:	8b 55 08             	mov    0x8(%ebp),%edx
80104255:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010425b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104260:	89 c1                	mov    %eax,%ecx
80104262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104265:	8b 45 0c             	mov    0xc(%ebp),%eax
80104268:	01 d0                	add    %edx,%eax
8010426a:	0f b6 10             	movzbl (%eax),%edx
8010426d:	8b 45 08             	mov    0x8(%ebp),%eax
80104270:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104274:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010427e:	7c ab                	jl     8010422b <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104280:	8b 45 08             	mov    0x8(%ebp),%eax
80104283:	05 34 02 00 00       	add    $0x234,%eax
80104288:	83 ec 0c             	sub    $0xc,%esp
8010428b:	50                   	push   %eax
8010428c:	e8 54 0b 00 00       	call   80104de5 <wakeup>
80104291:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104294:	8b 45 08             	mov    0x8(%ebp),%eax
80104297:	83 ec 0c             	sub    $0xc,%esp
8010429a:	50                   	push   %eax
8010429b:	e8 ba 0d 00 00       	call   8010505a <release>
801042a0:	83 c4 10             	add    $0x10,%esp
  return n;
801042a3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042a6:	c9                   	leave  
801042a7:	c3                   	ret    

801042a8 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042a8:	55                   	push   %ebp
801042a9:	89 e5                	mov    %esp,%ebp
801042ab:	53                   	push   %ebx
801042ac:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801042af:	8b 45 08             	mov    0x8(%ebp),%eax
801042b2:	83 ec 0c             	sub    $0xc,%esp
801042b5:	50                   	push   %eax
801042b6:	e8 38 0d 00 00       	call   80104ff3 <acquire>
801042bb:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042be:	eb 3f                	jmp    801042ff <piperead+0x57>
    if(proc->killed){
801042c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042c6:	8b 40 24             	mov    0x24(%eax),%eax
801042c9:	85 c0                	test   %eax,%eax
801042cb:	74 19                	je     801042e6 <piperead+0x3e>
      release(&p->lock);
801042cd:	8b 45 08             	mov    0x8(%ebp),%eax
801042d0:	83 ec 0c             	sub    $0xc,%esp
801042d3:	50                   	push   %eax
801042d4:	e8 81 0d 00 00       	call   8010505a <release>
801042d9:	83 c4 10             	add    $0x10,%esp
      return -1;
801042dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e1:	e9 bf 00 00 00       	jmp    801043a5 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042e6:	8b 45 08             	mov    0x8(%ebp),%eax
801042e9:	8b 55 08             	mov    0x8(%ebp),%edx
801042ec:	81 c2 34 02 00 00    	add    $0x234,%edx
801042f2:	83 ec 08             	sub    $0x8,%esp
801042f5:	50                   	push   %eax
801042f6:	52                   	push   %edx
801042f7:	e8 fe 09 00 00       	call   80104cfa <sleep>
801042fc:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104302:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104308:	8b 45 08             	mov    0x8(%ebp),%eax
8010430b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104311:	39 c2                	cmp    %eax,%edx
80104313:	75 0d                	jne    80104322 <piperead+0x7a>
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010431e:	85 c0                	test   %eax,%eax
80104320:	75 9e                	jne    801042c0 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104322:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104329:	eb 49                	jmp    80104374 <piperead+0xcc>
    if(p->nread == p->nwrite)
8010432b:	8b 45 08             	mov    0x8(%ebp),%eax
8010432e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104334:	8b 45 08             	mov    0x8(%ebp),%eax
80104337:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010433d:	39 c2                	cmp    %eax,%edx
8010433f:	74 3d                	je     8010437e <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104341:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104344:	8b 45 0c             	mov    0xc(%ebp),%eax
80104347:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010434a:	8b 45 08             	mov    0x8(%ebp),%eax
8010434d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104353:	8d 48 01             	lea    0x1(%eax),%ecx
80104356:	8b 55 08             	mov    0x8(%ebp),%edx
80104359:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010435f:	25 ff 01 00 00       	and    $0x1ff,%eax
80104364:	89 c2                	mov    %eax,%edx
80104366:	8b 45 08             	mov    0x8(%ebp),%eax
80104369:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010436e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104377:	3b 45 10             	cmp    0x10(%ebp),%eax
8010437a:	7c af                	jl     8010432b <piperead+0x83>
8010437c:	eb 01                	jmp    8010437f <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
8010437e:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010437f:	8b 45 08             	mov    0x8(%ebp),%eax
80104382:	05 38 02 00 00       	add    $0x238,%eax
80104387:	83 ec 0c             	sub    $0xc,%esp
8010438a:	50                   	push   %eax
8010438b:	e8 55 0a 00 00       	call   80104de5 <wakeup>
80104390:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104393:	8b 45 08             	mov    0x8(%ebp),%eax
80104396:	83 ec 0c             	sub    $0xc,%esp
80104399:	50                   	push   %eax
8010439a:	e8 bb 0c 00 00       	call   8010505a <release>
8010439f:	83 c4 10             	add    $0x10,%esp
  return i;
801043a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043a8:	c9                   	leave  
801043a9:	c3                   	ret    

801043aa <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801043aa:	55                   	push   %ebp
801043ab:	89 e5                	mov    %esp,%ebp
801043ad:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043b0:	9c                   	pushf  
801043b1:	58                   	pop    %eax
801043b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043b8:	c9                   	leave  
801043b9:	c3                   	ret    

801043ba <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801043ba:	55                   	push   %ebp
801043bb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043bd:	fb                   	sti    
}
801043be:	90                   	nop
801043bf:	5d                   	pop    %ebp
801043c0:	c3                   	ret    

801043c1 <numprocs>:

static void wakeup1(void *chan);

int  
numprocs(struct uproc *up)
{
801043c1:	55                   	push   %ebp
801043c2:	89 e5                	mov    %esp,%ebp
801043c4:	83 ec 18             	sub    $0x18,%esp

struct proc *p;
int i=0;
801043c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
acquire(&ptable.lock);
801043ce:	83 ec 0c             	sub    $0xc,%esp
801043d1:	68 60 29 11 80       	push   $0x80112960
801043d6:	e8 18 0c 00 00       	call   80104ff3 <acquire>
801043db:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043de:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801043e5:	eb 59                	jmp    80104440 <numprocs+0x7f>
   {    
   if(p->state == UNUSED) p++;
801043e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ea:	8b 40 0c             	mov    0xc(%eax),%eax
801043ed:	85 c0                	test   %eax,%eax
801043ef:	75 06                	jne    801043f7 <numprocs+0x36>
801043f1:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801043f5:	eb 45                	jmp    8010443c <numprocs+0x7b>
   else{


    up->sz=p->sz;
801043f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fa:	8b 10                	mov    (%eax),%edx
801043fc:	8b 45 08             	mov    0x8(%ebp),%eax
801043ff:	89 50 14             	mov    %edx,0x14(%eax)
    up->state=p->state;
80104402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104405:	8b 40 0c             	mov    0xc(%eax),%eax
80104408:	89 c2                	mov    %eax,%edx
8010440a:	8b 45 08             	mov    0x8(%ebp),%eax
8010440d:	89 50 18             	mov    %edx,0x18(%eax)
    up->pid=p->pid;
80104410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104413:	8b 50 10             	mov    0x10(%eax),%edx
80104416:	8b 45 08             	mov    0x8(%ebp),%eax
80104419:	89 50 10             	mov    %edx,0x10(%eax)

    safestrcpy(up->name,p->name, 16);
8010441c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104422:	8b 45 08             	mov    0x8(%ebp),%eax
80104425:	83 ec 04             	sub    $0x4,%esp
80104428:	6a 10                	push   $0x10
8010442a:	52                   	push   %edx
8010442b:	50                   	push   %eax
8010442c:	e8 28 10 00 00       	call   80105459 <safestrcpy>
80104431:	83 c4 10             	add    $0x10,%esp
    i++;
80104434:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    up++;
80104438:	83 45 08 1c          	addl   $0x1c,0x8(%ebp)
{

struct proc *p;
int i=0;
acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010443c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104440:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104447:	72 9e                	jb     801043e7 <numprocs+0x26>
    i++;
    up++;

    }
   }
release(&ptable.lock);
80104449:	83 ec 0c             	sub    $0xc,%esp
8010444c:	68 60 29 11 80       	push   $0x80112960
80104451:	e8 04 0c 00 00       	call   8010505a <release>
80104456:	83 c4 10             	add    $0x10,%esp
return i;
80104459:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010445c:	c9                   	leave  
8010445d:	c3                   	ret    

8010445e <pinit>:

void
pinit(void)
{
8010445e:	55                   	push   %ebp
8010445f:	89 e5                	mov    %esp,%ebp
80104461:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104464:	83 ec 08             	sub    $0x8,%esp
80104467:	68 89 88 10 80       	push   $0x80108889
8010446c:	68 60 29 11 80       	push   $0x80112960
80104471:	e8 5b 0b 00 00       	call   80104fd1 <initlock>
80104476:	83 c4 10             	add    $0x10,%esp
}
80104479:	90                   	nop
8010447a:	c9                   	leave  
8010447b:	c3                   	ret    

8010447c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010447c:	55                   	push   %ebp
8010447d:	89 e5                	mov    %esp,%ebp
8010447f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104482:	83 ec 0c             	sub    $0xc,%esp
80104485:	68 60 29 11 80       	push   $0x80112960
8010448a:	e8 64 0b 00 00       	call   80104ff3 <acquire>
8010448f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104492:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104499:	eb 0e                	jmp    801044a9 <allocproc+0x2d>
    if(p->state == UNUSED)
8010449b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449e:	8b 40 0c             	mov    0xc(%eax),%eax
801044a1:	85 c0                	test   %eax,%eax
801044a3:	74 27                	je     801044cc <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044a5:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044a9:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
801044b0:	72 e9                	jb     8010449b <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801044b2:	83 ec 0c             	sub    $0xc,%esp
801044b5:	68 60 29 11 80       	push   $0x80112960
801044ba:	e8 9b 0b 00 00       	call   8010505a <release>
801044bf:	83 c4 10             	add    $0x10,%esp
  return 0;
801044c2:	b8 00 00 00 00       	mov    $0x0,%eax
801044c7:	e9 b4 00 00 00       	jmp    80104580 <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801044cc:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044d7:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044dc:	8d 50 01             	lea    0x1(%eax),%edx
801044df:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801044e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e8:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801044eb:	83 ec 0c             	sub    $0xc,%esp
801044ee:	68 60 29 11 80       	push   $0x80112960
801044f3:	e8 62 0b 00 00       	call   8010505a <release>
801044f8:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801044fb:	e8 e5 e6 ff ff       	call   80102be5 <kalloc>
80104500:	89 c2                	mov    %eax,%edx
80104502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104505:	89 50 08             	mov    %edx,0x8(%eax)
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	8b 40 08             	mov    0x8(%eax),%eax
8010450e:	85 c0                	test   %eax,%eax
80104510:	75 11                	jne    80104523 <allocproc+0xa7>
    p->state = UNUSED;
80104512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104515:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010451c:	b8 00 00 00 00       	mov    $0x0,%eax
80104521:	eb 5d                	jmp    80104580 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80104523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104526:	8b 40 08             	mov    0x8(%eax),%eax
80104529:	05 00 10 00 00       	add    $0x1000,%eax
8010452e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104531:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104538:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010453b:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010453e:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104542:	ba ce 66 10 80       	mov    $0x801066ce,%edx
80104547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010454a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010454c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104553:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104556:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010455f:	83 ec 04             	sub    $0x4,%esp
80104562:	6a 14                	push   $0x14
80104564:	6a 00                	push   $0x0
80104566:	50                   	push   %eax
80104567:	e8 ea 0c 00 00       	call   80105256 <memset>
8010456c:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010456f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104572:	8b 40 1c             	mov    0x1c(%eax),%eax
80104575:	ba c9 4c 10 80       	mov    $0x80104cc9,%edx
8010457a:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104580:	c9                   	leave  
80104581:	c3                   	ret    

80104582 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104582:	55                   	push   %ebp
80104583:	89 e5                	mov    %esp,%ebp
80104585:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104588:	e8 ef fe ff ff       	call   8010447c <allocproc>
8010458d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104593:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
80104598:	e8 f6 37 00 00       	call   80107d93 <setupkvm>
8010459d:	89 c2                	mov    %eax,%edx
8010459f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a2:	89 50 04             	mov    %edx,0x4(%eax)
801045a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a8:	8b 40 04             	mov    0x4(%eax),%eax
801045ab:	85 c0                	test   %eax,%eax
801045ad:	75 0d                	jne    801045bc <userinit+0x3a>
    panic("userinit: out of memory?");
801045af:	83 ec 0c             	sub    $0xc,%esp
801045b2:	68 90 88 10 80       	push   $0x80108890
801045b7:	e8 aa bf ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045bc:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c4:	8b 40 04             	mov    0x4(%eax),%eax
801045c7:	83 ec 04             	sub    $0x4,%esp
801045ca:	52                   	push   %edx
801045cb:	68 e0 b4 10 80       	push   $0x8010b4e0
801045d0:	50                   	push   %eax
801045d1:	e8 17 3a 00 00       	call   80107fed <inituvm>
801045d6:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dc:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e5:	8b 40 18             	mov    0x18(%eax),%eax
801045e8:	83 ec 04             	sub    $0x4,%esp
801045eb:	6a 4c                	push   $0x4c
801045ed:	6a 00                	push   $0x0
801045ef:	50                   	push   %eax
801045f0:	e8 61 0c 00 00       	call   80105256 <memset>
801045f5:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801045f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fb:	8b 40 18             	mov    0x18(%eax),%eax
801045fe:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104607:	8b 40 18             	mov    0x18(%eax),%eax
8010460a:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	8b 40 18             	mov    0x18(%eax),%eax
80104616:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104619:	8b 52 18             	mov    0x18(%edx),%edx
8010461c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104620:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	8b 40 18             	mov    0x18(%eax),%eax
8010462a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010462d:	8b 52 18             	mov    0x18(%edx),%edx
80104630:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104634:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463b:	8b 40 18             	mov    0x18(%eax),%eax
8010463e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104648:	8b 40 18             	mov    0x18(%eax),%eax
8010464b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104655:	8b 40 18             	mov    0x18(%eax),%eax
80104658:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010465f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104662:	83 c0 6c             	add    $0x6c,%eax
80104665:	83 ec 04             	sub    $0x4,%esp
80104668:	6a 10                	push   $0x10
8010466a:	68 a9 88 10 80       	push   $0x801088a9
8010466f:	50                   	push   %eax
80104670:	e8 e4 0d 00 00       	call   80105459 <safestrcpy>
80104675:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104678:	83 ec 0c             	sub    $0xc,%esp
8010467b:	68 b2 88 10 80       	push   $0x801088b2
80104680:	e8 5e de ff ff       	call   801024e3 <namei>
80104685:	83 c4 10             	add    $0x10,%esp
80104688:	89 c2                	mov    %eax,%edx
8010468a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468d:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104693:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010469a:	90                   	nop
8010469b:	c9                   	leave  
8010469c:	c3                   	ret    

8010469d <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010469d:	55                   	push   %ebp
8010469e:	89 e5                	mov    %esp,%ebp
801046a0:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a9:	8b 00                	mov    (%eax),%eax
801046ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046b2:	7e 31                	jle    801046e5 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046b4:	8b 55 08             	mov    0x8(%ebp),%edx
801046b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ba:	01 c2                	add    %eax,%edx
801046bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c2:	8b 40 04             	mov    0x4(%eax),%eax
801046c5:	83 ec 04             	sub    $0x4,%esp
801046c8:	52                   	push   %edx
801046c9:	ff 75 f4             	pushl  -0xc(%ebp)
801046cc:	50                   	push   %eax
801046cd:	e8 68 3a 00 00       	call   8010813a <allocuvm>
801046d2:	83 c4 10             	add    $0x10,%esp
801046d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046dc:	75 3e                	jne    8010471c <growproc+0x7f>
      return -1;
801046de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e3:	eb 59                	jmp    8010473e <growproc+0xa1>
  } else if(n < 0){
801046e5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046e9:	79 31                	jns    8010471c <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801046eb:	8b 55 08             	mov    0x8(%ebp),%edx
801046ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f1:	01 c2                	add    %eax,%edx
801046f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f9:	8b 40 04             	mov    0x4(%eax),%eax
801046fc:	83 ec 04             	sub    $0x4,%esp
801046ff:	52                   	push   %edx
80104700:	ff 75 f4             	pushl  -0xc(%ebp)
80104703:	50                   	push   %eax
80104704:	e8 fa 3a 00 00       	call   80108203 <deallocuvm>
80104709:	83 c4 10             	add    $0x10,%esp
8010470c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010470f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104713:	75 07                	jne    8010471c <growproc+0x7f>
      return -1;
80104715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471a:	eb 22                	jmp    8010473e <growproc+0xa1>
  }
  proc->sz = sz;
8010471c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104722:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104725:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104727:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472d:	83 ec 0c             	sub    $0xc,%esp
80104730:	50                   	push   %eax
80104731:	e8 44 37 00 00       	call   80107e7a <switchuvm>
80104736:	83 c4 10             	add    $0x10,%esp
  return 0;
80104739:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010473e:	c9                   	leave  
8010473f:	c3                   	ret    

80104740 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104740:	55                   	push   %ebp
80104741:	89 e5                	mov    %esp,%ebp
80104743:	57                   	push   %edi
80104744:	56                   	push   %esi
80104745:	53                   	push   %ebx
80104746:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104749:	e8 2e fd ff ff       	call   8010447c <allocproc>
8010474e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104751:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104755:	75 0a                	jne    80104761 <fork+0x21>
    return -1;
80104757:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010475c:	e9 68 01 00 00       	jmp    801048c9 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104761:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104767:	8b 10                	mov    (%eax),%edx
80104769:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476f:	8b 40 04             	mov    0x4(%eax),%eax
80104772:	83 ec 08             	sub    $0x8,%esp
80104775:	52                   	push   %edx
80104776:	50                   	push   %eax
80104777:	e8 25 3c 00 00       	call   801083a1 <copyuvm>
8010477c:	83 c4 10             	add    $0x10,%esp
8010477f:	89 c2                	mov    %eax,%edx
80104781:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104784:	89 50 04             	mov    %edx,0x4(%eax)
80104787:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478a:	8b 40 04             	mov    0x4(%eax),%eax
8010478d:	85 c0                	test   %eax,%eax
8010478f:	75 30                	jne    801047c1 <fork+0x81>
    kfree(np->kstack);
80104791:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104794:	8b 40 08             	mov    0x8(%eax),%eax
80104797:	83 ec 0c             	sub    $0xc,%esp
8010479a:	50                   	push   %eax
8010479b:	e8 a8 e3 ff ff       	call   80102b48 <kfree>
801047a0:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047bc:	e9 08 01 00 00       	jmp    801048c9 <fork+0x189>
  }
  np->sz = proc->sz;
801047c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c7:	8b 10                	mov    (%eax),%edx
801047c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cc:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801047ce:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d8:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801047db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047de:	8b 50 18             	mov    0x18(%eax),%edx
801047e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e7:	8b 40 18             	mov    0x18(%eax),%eax
801047ea:	89 c3                	mov    %eax,%ebx
801047ec:	b8 13 00 00 00       	mov    $0x13,%eax
801047f1:	89 d7                	mov    %edx,%edi
801047f3:	89 de                	mov    %ebx,%esi
801047f5:	89 c1                	mov    %eax,%ecx
801047f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801047f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047fc:	8b 40 18             	mov    0x18(%eax),%eax
801047ff:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104806:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010480d:	eb 43                	jmp    80104852 <fork+0x112>
    if(proc->ofile[i])
8010480f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104815:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104818:	83 c2 08             	add    $0x8,%edx
8010481b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010481f:	85 c0                	test   %eax,%eax
80104821:	74 2b                	je     8010484e <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104823:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104829:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010482c:	83 c2 08             	add    $0x8,%edx
8010482f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104833:	83 ec 0c             	sub    $0xc,%esp
80104836:	50                   	push   %eax
80104837:	e8 b7 c7 ff ff       	call   80100ff3 <filedup>
8010483c:	83 c4 10             	add    $0x10,%esp
8010483f:	89 c1                	mov    %eax,%ecx
80104841:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104844:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104847:	83 c2 08             	add    $0x8,%edx
8010484a:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010484e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104852:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104856:	7e b7                	jle    8010480f <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104858:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485e:	8b 40 68             	mov    0x68(%eax),%eax
80104861:	83 ec 0c             	sub    $0xc,%esp
80104864:	50                   	push   %eax
80104865:	e8 87 d0 ff ff       	call   801018f1 <idup>
8010486a:	83 c4 10             	add    $0x10,%esp
8010486d:	89 c2                	mov    %eax,%edx
8010486f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104872:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104875:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010487e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104881:	83 c0 6c             	add    $0x6c,%eax
80104884:	83 ec 04             	sub    $0x4,%esp
80104887:	6a 10                	push   $0x10
80104889:	52                   	push   %edx
8010488a:	50                   	push   %eax
8010488b:	e8 c9 0b 00 00       	call   80105459 <safestrcpy>
80104890:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104893:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104896:	8b 40 10             	mov    0x10(%eax),%eax
80104899:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
8010489c:	83 ec 0c             	sub    $0xc,%esp
8010489f:	68 60 29 11 80       	push   $0x80112960
801048a4:	e8 4a 07 00 00       	call   80104ff3 <acquire>
801048a9:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048af:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048b6:	83 ec 0c             	sub    $0xc,%esp
801048b9:	68 60 29 11 80       	push   $0x80112960
801048be:	e8 97 07 00 00       	call   8010505a <release>
801048c3:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048cc:	5b                   	pop    %ebx
801048cd:	5e                   	pop    %esi
801048ce:	5f                   	pop    %edi
801048cf:	5d                   	pop    %ebp
801048d0:	c3                   	ret    

801048d1 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048d1:	55                   	push   %ebp
801048d2:	89 e5                	mov    %esp,%ebp
801048d4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801048d7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048de:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048e3:	39 c2                	cmp    %eax,%edx
801048e5:	75 0d                	jne    801048f4 <exit+0x23>
    panic("init exiting");
801048e7:	83 ec 0c             	sub    $0xc,%esp
801048ea:	68 b4 88 10 80       	push   $0x801088b4
801048ef:	e8 72 bc ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801048f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801048fb:	eb 48                	jmp    80104945 <exit+0x74>
    if(proc->ofile[fd]){
801048fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104903:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104906:	83 c2 08             	add    $0x8,%edx
80104909:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010490d:	85 c0                	test   %eax,%eax
8010490f:	74 30                	je     80104941 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104911:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104917:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010491a:	83 c2 08             	add    $0x8,%edx
8010491d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104921:	83 ec 0c             	sub    $0xc,%esp
80104924:	50                   	push   %eax
80104925:	e8 22 c7 ff ff       	call   8010104c <fileclose>
8010492a:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010492d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104933:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104936:	83 c2 08             	add    $0x8,%edx
80104939:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104940:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104941:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104945:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104949:	7e b2                	jle    801048fd <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010494b:	e8 84 eb ff ff       	call   801034d4 <begin_op>
  iput(proc->cwd);
80104950:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104956:	8b 40 68             	mov    0x68(%eax),%eax
80104959:	83 ec 0c             	sub    $0xc,%esp
8010495c:	50                   	push   %eax
8010495d:	e8 93 d1 ff ff       	call   80101af5 <iput>
80104962:	83 c4 10             	add    $0x10,%esp
  end_op();
80104965:	e8 f6 eb ff ff       	call   80103560 <end_op>
  proc->cwd = 0;
8010496a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104970:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104977:	83 ec 0c             	sub    $0xc,%esp
8010497a:	68 60 29 11 80       	push   $0x80112960
8010497f:	e8 6f 06 00 00       	call   80104ff3 <acquire>
80104984:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104987:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010498d:	8b 40 14             	mov    0x14(%eax),%eax
80104990:	83 ec 0c             	sub    $0xc,%esp
80104993:	50                   	push   %eax
80104994:	e8 0d 04 00 00       	call   80104da6 <wakeup1>
80104999:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010499c:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801049a3:	eb 3c                	jmp    801049e1 <exit+0x110>
    if(p->parent == proc){
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	8b 50 14             	mov    0x14(%eax),%edx
801049ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b1:	39 c2                	cmp    %eax,%edx
801049b3:	75 28                	jne    801049dd <exit+0x10c>
      p->parent = initproc;
801049b5:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c4:	8b 40 0c             	mov    0xc(%eax),%eax
801049c7:	83 f8 05             	cmp    $0x5,%eax
801049ca:	75 11                	jne    801049dd <exit+0x10c>
        wakeup1(initproc);
801049cc:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801049d1:	83 ec 0c             	sub    $0xc,%esp
801049d4:	50                   	push   %eax
801049d5:	e8 cc 03 00 00       	call   80104da6 <wakeup1>
801049da:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049dd:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801049e1:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
801049e8:	72 bb                	jb     801049a5 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801049ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f0:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801049f7:	e8 d6 01 00 00       	call   80104bd2 <sched>
  panic("zombie exit");
801049fc:	83 ec 0c             	sub    $0xc,%esp
801049ff:	68 c1 88 10 80       	push   $0x801088c1
80104a04:	e8 5d bb ff ff       	call   80100566 <panic>

80104a09 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a09:	55                   	push   %ebp
80104a0a:	89 e5                	mov    %esp,%ebp
80104a0c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a0f:	83 ec 0c             	sub    $0xc,%esp
80104a12:	68 60 29 11 80       	push   $0x80112960
80104a17:	e8 d7 05 00 00       	call   80104ff3 <acquire>
80104a1c:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a1f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a26:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a2d:	e9 a6 00 00 00       	jmp    80104ad8 <wait+0xcf>
      if(p->parent != proc)
80104a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a35:	8b 50 14             	mov    0x14(%eax),%edx
80104a38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3e:	39 c2                	cmp    %eax,%edx
80104a40:	0f 85 8d 00 00 00    	jne    80104ad3 <wait+0xca>
        continue;
      havekids = 1;
80104a46:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a50:	8b 40 0c             	mov    0xc(%eax),%eax
80104a53:	83 f8 05             	cmp    $0x5,%eax
80104a56:	75 7c                	jne    80104ad4 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5b:	8b 40 10             	mov    0x10(%eax),%eax
80104a5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a64:	8b 40 08             	mov    0x8(%eax),%eax
80104a67:	83 ec 0c             	sub    $0xc,%esp
80104a6a:	50                   	push   %eax
80104a6b:	e8 d8 e0 ff ff       	call   80102b48 <kfree>
80104a70:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a80:	8b 40 04             	mov    0x4(%eax),%eax
80104a83:	83 ec 0c             	sub    $0xc,%esp
80104a86:	50                   	push   %eax
80104a87:	e8 34 38 00 00       	call   801082c0 <freevm>
80104a8c:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a92:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab0:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab7:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104abe:	83 ec 0c             	sub    $0xc,%esp
80104ac1:	68 60 29 11 80       	push   $0x80112960
80104ac6:	e8 8f 05 00 00       	call   8010505a <release>
80104acb:	83 c4 10             	add    $0x10,%esp
        return pid;
80104ace:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad1:	eb 58                	jmp    80104b2b <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104ad3:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ad8:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104adf:	0f 82 4d ff ff ff    	jb     80104a32 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104ae5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ae9:	74 0d                	je     80104af8 <wait+0xef>
80104aeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af1:	8b 40 24             	mov    0x24(%eax),%eax
80104af4:	85 c0                	test   %eax,%eax
80104af6:	74 17                	je     80104b0f <wait+0x106>
      release(&ptable.lock);
80104af8:	83 ec 0c             	sub    $0xc,%esp
80104afb:	68 60 29 11 80       	push   $0x80112960
80104b00:	e8 55 05 00 00       	call   8010505a <release>
80104b05:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b0d:	eb 1c                	jmp    80104b2b <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b15:	83 ec 08             	sub    $0x8,%esp
80104b18:	68 60 29 11 80       	push   $0x80112960
80104b1d:	50                   	push   %eax
80104b1e:	e8 d7 01 00 00       	call   80104cfa <sleep>
80104b23:	83 c4 10             	add    $0x10,%esp
  }
80104b26:	e9 f4 fe ff ff       	jmp    80104a1f <wait+0x16>
}
80104b2b:	c9                   	leave  
80104b2c:	c3                   	ret    

80104b2d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b2d:	55                   	push   %ebp
80104b2e:	89 e5                	mov    %esp,%ebp
80104b30:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b33:	e8 82 f8 ff ff       	call   801043ba <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b38:	83 ec 0c             	sub    $0xc,%esp
80104b3b:	68 60 29 11 80       	push   $0x80112960
80104b40:	e8 ae 04 00 00       	call   80104ff3 <acquire>
80104b45:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b48:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104b4f:	eb 63                	jmp    80104bb4 <scheduler+0x87>
      if(p->state != RUNNABLE)
80104b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b54:	8b 40 0c             	mov    0xc(%eax),%eax
80104b57:	83 f8 03             	cmp    $0x3,%eax
80104b5a:	75 53                	jne    80104baf <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5f:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b65:	83 ec 0c             	sub    $0xc,%esp
80104b68:	ff 75 f4             	pushl  -0xc(%ebp)
80104b6b:	e8 0a 33 00 00       	call   80107e7a <switchuvm>
80104b70:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b76:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104b7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b83:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b86:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b8d:	83 c2 04             	add    $0x4,%edx
80104b90:	83 ec 08             	sub    $0x8,%esp
80104b93:	50                   	push   %eax
80104b94:	52                   	push   %edx
80104b95:	e8 30 09 00 00       	call   801054ca <swtch>
80104b9a:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104b9d:	e8 bb 32 00 00       	call   80107e5d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104ba2:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104ba9:	00 00 00 00 
80104bad:	eb 01                	jmp    80104bb0 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104baf:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bb0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104bb4:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104bbb:	72 94                	jb     80104b51 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104bbd:	83 ec 0c             	sub    $0xc,%esp
80104bc0:	68 60 29 11 80       	push   $0x80112960
80104bc5:	e8 90 04 00 00       	call   8010505a <release>
80104bca:	83 c4 10             	add    $0x10,%esp

  }
80104bcd:	e9 61 ff ff ff       	jmp    80104b33 <scheduler+0x6>

80104bd2 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104bd2:	55                   	push   %ebp
80104bd3:	89 e5                	mov    %esp,%ebp
80104bd5:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104bd8:	83 ec 0c             	sub    $0xc,%esp
80104bdb:	68 60 29 11 80       	push   $0x80112960
80104be0:	e8 41 05 00 00       	call   80105126 <holding>
80104be5:	83 c4 10             	add    $0x10,%esp
80104be8:	85 c0                	test   %eax,%eax
80104bea:	75 0d                	jne    80104bf9 <sched+0x27>
    panic("sched ptable.lock");
80104bec:	83 ec 0c             	sub    $0xc,%esp
80104bef:	68 cd 88 10 80       	push   $0x801088cd
80104bf4:	e8 6d b9 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104bf9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bff:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c05:	83 f8 01             	cmp    $0x1,%eax
80104c08:	74 0d                	je     80104c17 <sched+0x45>
    panic("sched locks");
80104c0a:	83 ec 0c             	sub    $0xc,%esp
80104c0d:	68 df 88 10 80       	push   $0x801088df
80104c12:	e8 4f b9 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104c17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c1d:	8b 40 0c             	mov    0xc(%eax),%eax
80104c20:	83 f8 04             	cmp    $0x4,%eax
80104c23:	75 0d                	jne    80104c32 <sched+0x60>
    panic("sched running");
80104c25:	83 ec 0c             	sub    $0xc,%esp
80104c28:	68 eb 88 10 80       	push   $0x801088eb
80104c2d:	e8 34 b9 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104c32:	e8 73 f7 ff ff       	call   801043aa <readeflags>
80104c37:	25 00 02 00 00       	and    $0x200,%eax
80104c3c:	85 c0                	test   %eax,%eax
80104c3e:	74 0d                	je     80104c4d <sched+0x7b>
    panic("sched interruptible");
80104c40:	83 ec 0c             	sub    $0xc,%esp
80104c43:	68 f9 88 10 80       	push   $0x801088f9
80104c48:	e8 19 b9 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104c4d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c53:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104c5c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c62:	8b 40 04             	mov    0x4(%eax),%eax
80104c65:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c6c:	83 c2 1c             	add    $0x1c,%edx
80104c6f:	83 ec 08             	sub    $0x8,%esp
80104c72:	50                   	push   %eax
80104c73:	52                   	push   %edx
80104c74:	e8 51 08 00 00       	call   801054ca <swtch>
80104c79:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104c7c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c85:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104c8b:	90                   	nop
80104c8c:	c9                   	leave  
80104c8d:	c3                   	ret    

80104c8e <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104c8e:	55                   	push   %ebp
80104c8f:	89 e5                	mov    %esp,%ebp
80104c91:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104c94:	83 ec 0c             	sub    $0xc,%esp
80104c97:	68 60 29 11 80       	push   $0x80112960
80104c9c:	e8 52 03 00 00       	call   80104ff3 <acquire>
80104ca1:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104ca4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104caa:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104cb1:	e8 1c ff ff ff       	call   80104bd2 <sched>
  release(&ptable.lock);
80104cb6:	83 ec 0c             	sub    $0xc,%esp
80104cb9:	68 60 29 11 80       	push   $0x80112960
80104cbe:	e8 97 03 00 00       	call   8010505a <release>
80104cc3:	83 c4 10             	add    $0x10,%esp
}
80104cc6:	90                   	nop
80104cc7:	c9                   	leave  
80104cc8:	c3                   	ret    

80104cc9 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104cc9:	55                   	push   %ebp
80104cca:	89 e5                	mov    %esp,%ebp
80104ccc:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ccf:	83 ec 0c             	sub    $0xc,%esp
80104cd2:	68 60 29 11 80       	push   $0x80112960
80104cd7:	e8 7e 03 00 00       	call   8010505a <release>
80104cdc:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104cdf:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104ce4:	85 c0                	test   %eax,%eax
80104ce6:	74 0f                	je     80104cf7 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104ce8:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104cef:	00 00 00 
    initlog();
80104cf2:	e8 b7 e5 ff ff       	call   801032ae <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104cf7:	90                   	nop
80104cf8:	c9                   	leave  
80104cf9:	c3                   	ret    

80104cfa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104cfa:	55                   	push   %ebp
80104cfb:	89 e5                	mov    %esp,%ebp
80104cfd:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d06:	85 c0                	test   %eax,%eax
80104d08:	75 0d                	jne    80104d17 <sleep+0x1d>
    panic("sleep");
80104d0a:	83 ec 0c             	sub    $0xc,%esp
80104d0d:	68 0d 89 10 80       	push   $0x8010890d
80104d12:	e8 4f b8 ff ff       	call   80100566 <panic>

  if(lk == 0)
80104d17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d1b:	75 0d                	jne    80104d2a <sleep+0x30>
    panic("sleep without lk");
80104d1d:	83 ec 0c             	sub    $0xc,%esp
80104d20:	68 13 89 10 80       	push   $0x80108913
80104d25:	e8 3c b8 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d2a:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104d31:	74 1e                	je     80104d51 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d33:	83 ec 0c             	sub    $0xc,%esp
80104d36:	68 60 29 11 80       	push   $0x80112960
80104d3b:	e8 b3 02 00 00       	call   80104ff3 <acquire>
80104d40:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104d43:	83 ec 0c             	sub    $0xc,%esp
80104d46:	ff 75 0c             	pushl  0xc(%ebp)
80104d49:	e8 0c 03 00 00       	call   8010505a <release>
80104d4e:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104d51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d57:	8b 55 08             	mov    0x8(%ebp),%edx
80104d5a:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104d5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d63:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104d6a:	e8 63 fe ff ff       	call   80104bd2 <sched>

  // Tidy up.
  proc->chan = 0;
80104d6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d75:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104d7c:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104d83:	74 1e                	je     80104da3 <sleep+0xa9>
    release(&ptable.lock);
80104d85:	83 ec 0c             	sub    $0xc,%esp
80104d88:	68 60 29 11 80       	push   $0x80112960
80104d8d:	e8 c8 02 00 00       	call   8010505a <release>
80104d92:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104d95:	83 ec 0c             	sub    $0xc,%esp
80104d98:	ff 75 0c             	pushl  0xc(%ebp)
80104d9b:	e8 53 02 00 00       	call   80104ff3 <acquire>
80104da0:	83 c4 10             	add    $0x10,%esp
  }
}
80104da3:	90                   	nop
80104da4:	c9                   	leave  
80104da5:	c3                   	ret    

80104da6 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104da6:	55                   	push   %ebp
80104da7:	89 e5                	mov    %esp,%ebp
80104da9:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104dac:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104db3:	eb 24                	jmp    80104dd9 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104db5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104db8:	8b 40 0c             	mov    0xc(%eax),%eax
80104dbb:	83 f8 02             	cmp    $0x2,%eax
80104dbe:	75 15                	jne    80104dd5 <wakeup1+0x2f>
80104dc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dc3:	8b 40 20             	mov    0x20(%eax),%eax
80104dc6:	3b 45 08             	cmp    0x8(%ebp),%eax
80104dc9:	75 0a                	jne    80104dd5 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104dcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dce:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104dd5:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104dd9:	81 7d fc 94 48 11 80 	cmpl   $0x80114894,-0x4(%ebp)
80104de0:	72 d3                	jb     80104db5 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104de2:	90                   	nop
80104de3:	c9                   	leave  
80104de4:	c3                   	ret    

80104de5 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104de5:	55                   	push   %ebp
80104de6:	89 e5                	mov    %esp,%ebp
80104de8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104deb:	83 ec 0c             	sub    $0xc,%esp
80104dee:	68 60 29 11 80       	push   $0x80112960
80104df3:	e8 fb 01 00 00       	call   80104ff3 <acquire>
80104df8:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104dfb:	83 ec 0c             	sub    $0xc,%esp
80104dfe:	ff 75 08             	pushl  0x8(%ebp)
80104e01:	e8 a0 ff ff ff       	call   80104da6 <wakeup1>
80104e06:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e09:	83 ec 0c             	sub    $0xc,%esp
80104e0c:	68 60 29 11 80       	push   $0x80112960
80104e11:	e8 44 02 00 00       	call   8010505a <release>
80104e16:	83 c4 10             	add    $0x10,%esp
}
80104e19:	90                   	nop
80104e1a:	c9                   	leave  
80104e1b:	c3                   	ret    

80104e1c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e1c:	55                   	push   %ebp
80104e1d:	89 e5                	mov    %esp,%ebp
80104e1f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e22:	83 ec 0c             	sub    $0xc,%esp
80104e25:	68 60 29 11 80       	push   $0x80112960
80104e2a:	e8 c4 01 00 00       	call   80104ff3 <acquire>
80104e2f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e32:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104e39:	eb 45                	jmp    80104e80 <kill+0x64>
    if(p->pid == pid){
80104e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3e:	8b 40 10             	mov    0x10(%eax),%eax
80104e41:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e44:	75 36                	jne    80104e7c <kill+0x60>
      p->killed = 1;
80104e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e49:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e53:	8b 40 0c             	mov    0xc(%eax),%eax
80104e56:	83 f8 02             	cmp    $0x2,%eax
80104e59:	75 0a                	jne    80104e65 <kill+0x49>
        p->state = RUNNABLE;
80104e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e65:	83 ec 0c             	sub    $0xc,%esp
80104e68:	68 60 29 11 80       	push   $0x80112960
80104e6d:	e8 e8 01 00 00       	call   8010505a <release>
80104e72:	83 c4 10             	add    $0x10,%esp
      return 0;
80104e75:	b8 00 00 00 00       	mov    $0x0,%eax
80104e7a:	eb 22                	jmp    80104e9e <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e7c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104e80:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104e87:	72 b2                	jb     80104e3b <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104e89:	83 ec 0c             	sub    $0xc,%esp
80104e8c:	68 60 29 11 80       	push   $0x80112960
80104e91:	e8 c4 01 00 00       	call   8010505a <release>
80104e96:	83 c4 10             	add    $0x10,%esp
  return -1;
80104e99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e9e:	c9                   	leave  
80104e9f:	c3                   	ret    

80104ea0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ea0:	55                   	push   %ebp
80104ea1:	89 e5                	mov    %esp,%ebp
80104ea3:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea6:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104ead:	e9 d7 00 00 00       	jmp    80104f89 <procdump+0xe9>
    if(p->state == UNUSED)
80104eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb5:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb8:	85 c0                	test   %eax,%eax
80104eba:	0f 84 c4 00 00 00    	je     80104f84 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec3:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec6:	83 f8 05             	cmp    $0x5,%eax
80104ec9:	77 23                	ja     80104eee <procdump+0x4e>
80104ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ece:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed1:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104ed8:	85 c0                	test   %eax,%eax
80104eda:	74 12                	je     80104eee <procdump+0x4e>
      state = states[p->state];
80104edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edf:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee2:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104ee9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104eec:	eb 07                	jmp    80104ef5 <procdump+0x55>
    else
      state = "???";
80104eee:	c7 45 ec 24 89 10 80 	movl   $0x80108924,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef8:	8d 50 6c             	lea    0x6c(%eax),%edx
80104efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104efe:	8b 40 10             	mov    0x10(%eax),%eax
80104f01:	52                   	push   %edx
80104f02:	ff 75 ec             	pushl  -0x14(%ebp)
80104f05:	50                   	push   %eax
80104f06:	68 28 89 10 80       	push   $0x80108928
80104f0b:	e8 b6 b4 ff ff       	call   801003c6 <cprintf>
80104f10:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f16:	8b 40 0c             	mov    0xc(%eax),%eax
80104f19:	83 f8 02             	cmp    $0x2,%eax
80104f1c:	75 54                	jne    80104f72 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f21:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f24:	8b 40 0c             	mov    0xc(%eax),%eax
80104f27:	83 c0 08             	add    $0x8,%eax
80104f2a:	89 c2                	mov    %eax,%edx
80104f2c:	83 ec 08             	sub    $0x8,%esp
80104f2f:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104f32:	50                   	push   %eax
80104f33:	52                   	push   %edx
80104f34:	e8 73 01 00 00       	call   801050ac <getcallerpcs>
80104f39:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104f3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f43:	eb 1c                	jmp    80104f61 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f48:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f4c:	83 ec 08             	sub    $0x8,%esp
80104f4f:	50                   	push   %eax
80104f50:	68 31 89 10 80       	push   $0x80108931
80104f55:	e8 6c b4 ff ff       	call   801003c6 <cprintf>
80104f5a:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f61:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f65:	7f 0b                	jg     80104f72 <procdump+0xd2>
80104f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f6e:	85 c0                	test   %eax,%eax
80104f70:	75 d3                	jne    80104f45 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f72:	83 ec 0c             	sub    $0xc,%esp
80104f75:	68 35 89 10 80       	push   $0x80108935
80104f7a:	e8 47 b4 ff ff       	call   801003c6 <cprintf>
80104f7f:	83 c4 10             	add    $0x10,%esp
80104f82:	eb 01                	jmp    80104f85 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104f84:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f85:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104f89:	81 7d f0 94 48 11 80 	cmpl   $0x80114894,-0x10(%ebp)
80104f90:	0f 82 1c ff ff ff    	jb     80104eb2 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104f96:	90                   	nop
80104f97:	c9                   	leave  
80104f98:	c3                   	ret    

80104f99 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f99:	55                   	push   %ebp
80104f9a:	89 e5                	mov    %esp,%ebp
80104f9c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f9f:	9c                   	pushf  
80104fa0:	58                   	pop    %eax
80104fa1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104fa4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fa7:	c9                   	leave  
80104fa8:	c3                   	ret    

80104fa9 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104fa9:	55                   	push   %ebp
80104faa:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104fac:	fa                   	cli    
}
80104fad:	90                   	nop
80104fae:	5d                   	pop    %ebp
80104faf:	c3                   	ret    

80104fb0 <sti>:

static inline void
sti(void)
{
80104fb0:	55                   	push   %ebp
80104fb1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fb3:	fb                   	sti    
}
80104fb4:	90                   	nop
80104fb5:	5d                   	pop    %ebp
80104fb6:	c3                   	ret    

80104fb7 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104fb7:	55                   	push   %ebp
80104fb8:	89 e5                	mov    %esp,%ebp
80104fba:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104fbd:	8b 55 08             	mov    0x8(%ebp),%edx
80104fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fc6:	f0 87 02             	lock xchg %eax,(%edx)
80104fc9:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104fcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fcf:	c9                   	leave  
80104fd0:	c3                   	ret    

80104fd1 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104fd1:	55                   	push   %ebp
80104fd2:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fda:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ff0:	90                   	nop
80104ff1:	5d                   	pop    %ebp
80104ff2:	c3                   	ret    

80104ff3 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104ff3:	55                   	push   %ebp
80104ff4:	89 e5                	mov    %esp,%ebp
80104ff6:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ff9:	e8 52 01 00 00       	call   80105150 <pushcli>
  if(holding(lk))
80104ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80105001:	83 ec 0c             	sub    $0xc,%esp
80105004:	50                   	push   %eax
80105005:	e8 1c 01 00 00       	call   80105126 <holding>
8010500a:	83 c4 10             	add    $0x10,%esp
8010500d:	85 c0                	test   %eax,%eax
8010500f:	74 0d                	je     8010501e <acquire+0x2b>
    panic("acquire");
80105011:	83 ec 0c             	sub    $0xc,%esp
80105014:	68 61 89 10 80       	push   $0x80108961
80105019:	e8 48 b5 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010501e:	90                   	nop
8010501f:	8b 45 08             	mov    0x8(%ebp),%eax
80105022:	83 ec 08             	sub    $0x8,%esp
80105025:	6a 01                	push   $0x1
80105027:	50                   	push   %eax
80105028:	e8 8a ff ff ff       	call   80104fb7 <xchg>
8010502d:	83 c4 10             	add    $0x10,%esp
80105030:	85 c0                	test   %eax,%eax
80105032:	75 eb                	jne    8010501f <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105034:	8b 45 08             	mov    0x8(%ebp),%eax
80105037:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010503e:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105041:	8b 45 08             	mov    0x8(%ebp),%eax
80105044:	83 c0 0c             	add    $0xc,%eax
80105047:	83 ec 08             	sub    $0x8,%esp
8010504a:	50                   	push   %eax
8010504b:	8d 45 08             	lea    0x8(%ebp),%eax
8010504e:	50                   	push   %eax
8010504f:	e8 58 00 00 00       	call   801050ac <getcallerpcs>
80105054:	83 c4 10             	add    $0x10,%esp
}
80105057:	90                   	nop
80105058:	c9                   	leave  
80105059:	c3                   	ret    

8010505a <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010505a:	55                   	push   %ebp
8010505b:	89 e5                	mov    %esp,%ebp
8010505d:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105060:	83 ec 0c             	sub    $0xc,%esp
80105063:	ff 75 08             	pushl  0x8(%ebp)
80105066:	e8 bb 00 00 00       	call   80105126 <holding>
8010506b:	83 c4 10             	add    $0x10,%esp
8010506e:	85 c0                	test   %eax,%eax
80105070:	75 0d                	jne    8010507f <release+0x25>
    panic("release");
80105072:	83 ec 0c             	sub    $0xc,%esp
80105075:	68 69 89 10 80       	push   $0x80108969
8010507a:	e8 e7 b4 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
8010507f:	8b 45 08             	mov    0x8(%ebp),%eax
80105082:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105089:	8b 45 08             	mov    0x8(%ebp),%eax
8010508c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105093:	8b 45 08             	mov    0x8(%ebp),%eax
80105096:	83 ec 08             	sub    $0x8,%esp
80105099:	6a 00                	push   $0x0
8010509b:	50                   	push   %eax
8010509c:	e8 16 ff ff ff       	call   80104fb7 <xchg>
801050a1:	83 c4 10             	add    $0x10,%esp

  popcli();
801050a4:	e8 ec 00 00 00       	call   80105195 <popcli>
}
801050a9:	90                   	nop
801050aa:	c9                   	leave  
801050ab:	c3                   	ret    

801050ac <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050ac:	55                   	push   %ebp
801050ad:	89 e5                	mov    %esp,%ebp
801050af:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801050b2:	8b 45 08             	mov    0x8(%ebp),%eax
801050b5:	83 e8 08             	sub    $0x8,%eax
801050b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050bb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050c2:	eb 38                	jmp    801050fc <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050c4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050c8:	74 53                	je     8010511d <getcallerpcs+0x71>
801050ca:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801050d1:	76 4a                	jbe    8010511d <getcallerpcs+0x71>
801050d3:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050d7:	74 44                	je     8010511d <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801050e6:	01 c2                	add    %eax,%edx
801050e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050eb:	8b 40 04             	mov    0x4(%eax),%eax
801050ee:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801050f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050f3:	8b 00                	mov    (%eax),%eax
801050f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801050f8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801050fc:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105100:	7e c2                	jle    801050c4 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105102:	eb 19                	jmp    8010511d <getcallerpcs+0x71>
    pcs[i] = 0;
80105104:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105107:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010510e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105111:	01 d0                	add    %edx,%eax
80105113:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105119:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010511d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105121:	7e e1                	jle    80105104 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105123:	90                   	nop
80105124:	c9                   	leave  
80105125:	c3                   	ret    

80105126 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105126:	55                   	push   %ebp
80105127:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105129:	8b 45 08             	mov    0x8(%ebp),%eax
8010512c:	8b 00                	mov    (%eax),%eax
8010512e:	85 c0                	test   %eax,%eax
80105130:	74 17                	je     80105149 <holding+0x23>
80105132:	8b 45 08             	mov    0x8(%ebp),%eax
80105135:	8b 50 08             	mov    0x8(%eax),%edx
80105138:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010513e:	39 c2                	cmp    %eax,%edx
80105140:	75 07                	jne    80105149 <holding+0x23>
80105142:	b8 01 00 00 00       	mov    $0x1,%eax
80105147:	eb 05                	jmp    8010514e <holding+0x28>
80105149:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010514e:	5d                   	pop    %ebp
8010514f:	c3                   	ret    

80105150 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105150:	55                   	push   %ebp
80105151:	89 e5                	mov    %esp,%ebp
80105153:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105156:	e8 3e fe ff ff       	call   80104f99 <readeflags>
8010515b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010515e:	e8 46 fe ff ff       	call   80104fa9 <cli>
  if(cpu->ncli++ == 0)
80105163:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010516a:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105170:	8d 48 01             	lea    0x1(%eax),%ecx
80105173:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105179:	85 c0                	test   %eax,%eax
8010517b:	75 15                	jne    80105192 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010517d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105183:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105186:	81 e2 00 02 00 00    	and    $0x200,%edx
8010518c:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105192:	90                   	nop
80105193:	c9                   	leave  
80105194:	c3                   	ret    

80105195 <popcli>:

void
popcli(void)
{
80105195:	55                   	push   %ebp
80105196:	89 e5                	mov    %esp,%ebp
80105198:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010519b:	e8 f9 fd ff ff       	call   80104f99 <readeflags>
801051a0:	25 00 02 00 00       	and    $0x200,%eax
801051a5:	85 c0                	test   %eax,%eax
801051a7:	74 0d                	je     801051b6 <popcli+0x21>
    panic("popcli - interruptible");
801051a9:	83 ec 0c             	sub    $0xc,%esp
801051ac:	68 71 89 10 80       	push   $0x80108971
801051b1:	e8 b0 b3 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
801051b6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051bc:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801051c2:	83 ea 01             	sub    $0x1,%edx
801051c5:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801051cb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801051d1:	85 c0                	test   %eax,%eax
801051d3:	79 0d                	jns    801051e2 <popcli+0x4d>
    panic("popcli");
801051d5:	83 ec 0c             	sub    $0xc,%esp
801051d8:	68 88 89 10 80       	push   $0x80108988
801051dd:	e8 84 b3 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801051e2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051e8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801051ee:	85 c0                	test   %eax,%eax
801051f0:	75 15                	jne    80105207 <popcli+0x72>
801051f2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051f8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801051fe:	85 c0                	test   %eax,%eax
80105200:	74 05                	je     80105207 <popcli+0x72>
    sti();
80105202:	e8 a9 fd ff ff       	call   80104fb0 <sti>
}
80105207:	90                   	nop
80105208:	c9                   	leave  
80105209:	c3                   	ret    

8010520a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010520a:	55                   	push   %ebp
8010520b:	89 e5                	mov    %esp,%ebp
8010520d:	57                   	push   %edi
8010520e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010520f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105212:	8b 55 10             	mov    0x10(%ebp),%edx
80105215:	8b 45 0c             	mov    0xc(%ebp),%eax
80105218:	89 cb                	mov    %ecx,%ebx
8010521a:	89 df                	mov    %ebx,%edi
8010521c:	89 d1                	mov    %edx,%ecx
8010521e:	fc                   	cld    
8010521f:	f3 aa                	rep stos %al,%es:(%edi)
80105221:	89 ca                	mov    %ecx,%edx
80105223:	89 fb                	mov    %edi,%ebx
80105225:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105228:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010522b:	90                   	nop
8010522c:	5b                   	pop    %ebx
8010522d:	5f                   	pop    %edi
8010522e:	5d                   	pop    %ebp
8010522f:	c3                   	ret    

80105230 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105230:	55                   	push   %ebp
80105231:	89 e5                	mov    %esp,%ebp
80105233:	57                   	push   %edi
80105234:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105235:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105238:	8b 55 10             	mov    0x10(%ebp),%edx
8010523b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010523e:	89 cb                	mov    %ecx,%ebx
80105240:	89 df                	mov    %ebx,%edi
80105242:	89 d1                	mov    %edx,%ecx
80105244:	fc                   	cld    
80105245:	f3 ab                	rep stos %eax,%es:(%edi)
80105247:	89 ca                	mov    %ecx,%edx
80105249:	89 fb                	mov    %edi,%ebx
8010524b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010524e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105251:	90                   	nop
80105252:	5b                   	pop    %ebx
80105253:	5f                   	pop    %edi
80105254:	5d                   	pop    %ebp
80105255:	c3                   	ret    

80105256 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105256:	55                   	push   %ebp
80105257:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105259:	8b 45 08             	mov    0x8(%ebp),%eax
8010525c:	83 e0 03             	and    $0x3,%eax
8010525f:	85 c0                	test   %eax,%eax
80105261:	75 43                	jne    801052a6 <memset+0x50>
80105263:	8b 45 10             	mov    0x10(%ebp),%eax
80105266:	83 e0 03             	and    $0x3,%eax
80105269:	85 c0                	test   %eax,%eax
8010526b:	75 39                	jne    801052a6 <memset+0x50>
    c &= 0xFF;
8010526d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105274:	8b 45 10             	mov    0x10(%ebp),%eax
80105277:	c1 e8 02             	shr    $0x2,%eax
8010527a:	89 c1                	mov    %eax,%ecx
8010527c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010527f:	c1 e0 18             	shl    $0x18,%eax
80105282:	89 c2                	mov    %eax,%edx
80105284:	8b 45 0c             	mov    0xc(%ebp),%eax
80105287:	c1 e0 10             	shl    $0x10,%eax
8010528a:	09 c2                	or     %eax,%edx
8010528c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010528f:	c1 e0 08             	shl    $0x8,%eax
80105292:	09 d0                	or     %edx,%eax
80105294:	0b 45 0c             	or     0xc(%ebp),%eax
80105297:	51                   	push   %ecx
80105298:	50                   	push   %eax
80105299:	ff 75 08             	pushl  0x8(%ebp)
8010529c:	e8 8f ff ff ff       	call   80105230 <stosl>
801052a1:	83 c4 0c             	add    $0xc,%esp
801052a4:	eb 12                	jmp    801052b8 <memset+0x62>
  } else
    stosb(dst, c, n);
801052a6:	8b 45 10             	mov    0x10(%ebp),%eax
801052a9:	50                   	push   %eax
801052aa:	ff 75 0c             	pushl  0xc(%ebp)
801052ad:	ff 75 08             	pushl  0x8(%ebp)
801052b0:	e8 55 ff ff ff       	call   8010520a <stosb>
801052b5:	83 c4 0c             	add    $0xc,%esp
  return dst;
801052b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052bb:	c9                   	leave  
801052bc:	c3                   	ret    

801052bd <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052bd:	55                   	push   %ebp
801052be:	89 e5                	mov    %esp,%ebp
801052c0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801052c3:	8b 45 08             	mov    0x8(%ebp),%eax
801052c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052cf:	eb 30                	jmp    80105301 <memcmp+0x44>
    if(*s1 != *s2)
801052d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052d4:	0f b6 10             	movzbl (%eax),%edx
801052d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052da:	0f b6 00             	movzbl (%eax),%eax
801052dd:	38 c2                	cmp    %al,%dl
801052df:	74 18                	je     801052f9 <memcmp+0x3c>
      return *s1 - *s2;
801052e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e4:	0f b6 00             	movzbl (%eax),%eax
801052e7:	0f b6 d0             	movzbl %al,%edx
801052ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052ed:	0f b6 00             	movzbl (%eax),%eax
801052f0:	0f b6 c0             	movzbl %al,%eax
801052f3:	29 c2                	sub    %eax,%edx
801052f5:	89 d0                	mov    %edx,%eax
801052f7:	eb 1a                	jmp    80105313 <memcmp+0x56>
    s1++, s2++;
801052f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105301:	8b 45 10             	mov    0x10(%ebp),%eax
80105304:	8d 50 ff             	lea    -0x1(%eax),%edx
80105307:	89 55 10             	mov    %edx,0x10(%ebp)
8010530a:	85 c0                	test   %eax,%eax
8010530c:	75 c3                	jne    801052d1 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010530e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105313:	c9                   	leave  
80105314:	c3                   	ret    

80105315 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105315:	55                   	push   %ebp
80105316:	89 e5                	mov    %esp,%ebp
80105318:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010531b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105321:	8b 45 08             	mov    0x8(%ebp),%eax
80105324:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105327:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010532a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010532d:	73 54                	jae    80105383 <memmove+0x6e>
8010532f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105332:	8b 45 10             	mov    0x10(%ebp),%eax
80105335:	01 d0                	add    %edx,%eax
80105337:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010533a:	76 47                	jbe    80105383 <memmove+0x6e>
    s += n;
8010533c:	8b 45 10             	mov    0x10(%ebp),%eax
8010533f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105342:	8b 45 10             	mov    0x10(%ebp),%eax
80105345:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105348:	eb 13                	jmp    8010535d <memmove+0x48>
      *--d = *--s;
8010534a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010534e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105352:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105355:	0f b6 10             	movzbl (%eax),%edx
80105358:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010535b:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010535d:	8b 45 10             	mov    0x10(%ebp),%eax
80105360:	8d 50 ff             	lea    -0x1(%eax),%edx
80105363:	89 55 10             	mov    %edx,0x10(%ebp)
80105366:	85 c0                	test   %eax,%eax
80105368:	75 e0                	jne    8010534a <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010536a:	eb 24                	jmp    80105390 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010536c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010536f:	8d 50 01             	lea    0x1(%eax),%edx
80105372:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105375:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105378:	8d 4a 01             	lea    0x1(%edx),%ecx
8010537b:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010537e:	0f b6 12             	movzbl (%edx),%edx
80105381:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105383:	8b 45 10             	mov    0x10(%ebp),%eax
80105386:	8d 50 ff             	lea    -0x1(%eax),%edx
80105389:	89 55 10             	mov    %edx,0x10(%ebp)
8010538c:	85 c0                	test   %eax,%eax
8010538e:	75 dc                	jne    8010536c <memmove+0x57>
      *d++ = *s++;

  return dst;
80105390:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105393:	c9                   	leave  
80105394:	c3                   	ret    

80105395 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105395:	55                   	push   %ebp
80105396:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105398:	ff 75 10             	pushl  0x10(%ebp)
8010539b:	ff 75 0c             	pushl  0xc(%ebp)
8010539e:	ff 75 08             	pushl  0x8(%ebp)
801053a1:	e8 6f ff ff ff       	call   80105315 <memmove>
801053a6:	83 c4 0c             	add    $0xc,%esp
}
801053a9:	c9                   	leave  
801053aa:	c3                   	ret    

801053ab <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053ab:	55                   	push   %ebp
801053ac:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801053ae:	eb 0c                	jmp    801053bc <strncmp+0x11>
    n--, p++, q++;
801053b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053b8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801053bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053c0:	74 1a                	je     801053dc <strncmp+0x31>
801053c2:	8b 45 08             	mov    0x8(%ebp),%eax
801053c5:	0f b6 00             	movzbl (%eax),%eax
801053c8:	84 c0                	test   %al,%al
801053ca:	74 10                	je     801053dc <strncmp+0x31>
801053cc:	8b 45 08             	mov    0x8(%ebp),%eax
801053cf:	0f b6 10             	movzbl (%eax),%edx
801053d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d5:	0f b6 00             	movzbl (%eax),%eax
801053d8:	38 c2                	cmp    %al,%dl
801053da:	74 d4                	je     801053b0 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801053dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053e0:	75 07                	jne    801053e9 <strncmp+0x3e>
    return 0;
801053e2:	b8 00 00 00 00       	mov    $0x0,%eax
801053e7:	eb 16                	jmp    801053ff <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801053e9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ec:	0f b6 00             	movzbl (%eax),%eax
801053ef:	0f b6 d0             	movzbl %al,%edx
801053f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f5:	0f b6 00             	movzbl (%eax),%eax
801053f8:	0f b6 c0             	movzbl %al,%eax
801053fb:	29 c2                	sub    %eax,%edx
801053fd:	89 d0                	mov    %edx,%eax
}
801053ff:	5d                   	pop    %ebp
80105400:	c3                   	ret    

80105401 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105401:	55                   	push   %ebp
80105402:	89 e5                	mov    %esp,%ebp
80105404:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105407:	8b 45 08             	mov    0x8(%ebp),%eax
8010540a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010540d:	90                   	nop
8010540e:	8b 45 10             	mov    0x10(%ebp),%eax
80105411:	8d 50 ff             	lea    -0x1(%eax),%edx
80105414:	89 55 10             	mov    %edx,0x10(%ebp)
80105417:	85 c0                	test   %eax,%eax
80105419:	7e 2c                	jle    80105447 <strncpy+0x46>
8010541b:	8b 45 08             	mov    0x8(%ebp),%eax
8010541e:	8d 50 01             	lea    0x1(%eax),%edx
80105421:	89 55 08             	mov    %edx,0x8(%ebp)
80105424:	8b 55 0c             	mov    0xc(%ebp),%edx
80105427:	8d 4a 01             	lea    0x1(%edx),%ecx
8010542a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010542d:	0f b6 12             	movzbl (%edx),%edx
80105430:	88 10                	mov    %dl,(%eax)
80105432:	0f b6 00             	movzbl (%eax),%eax
80105435:	84 c0                	test   %al,%al
80105437:	75 d5                	jne    8010540e <strncpy+0xd>
    ;
  while(n-- > 0)
80105439:	eb 0c                	jmp    80105447 <strncpy+0x46>
    *s++ = 0;
8010543b:	8b 45 08             	mov    0x8(%ebp),%eax
8010543e:	8d 50 01             	lea    0x1(%eax),%edx
80105441:	89 55 08             	mov    %edx,0x8(%ebp)
80105444:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105447:	8b 45 10             	mov    0x10(%ebp),%eax
8010544a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010544d:	89 55 10             	mov    %edx,0x10(%ebp)
80105450:	85 c0                	test   %eax,%eax
80105452:	7f e7                	jg     8010543b <strncpy+0x3a>
    *s++ = 0;
  return os;
80105454:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105457:	c9                   	leave  
80105458:	c3                   	ret    

80105459 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105459:	55                   	push   %ebp
8010545a:	89 e5                	mov    %esp,%ebp
8010545c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010545f:	8b 45 08             	mov    0x8(%ebp),%eax
80105462:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105465:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105469:	7f 05                	jg     80105470 <safestrcpy+0x17>
    return os;
8010546b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010546e:	eb 31                	jmp    801054a1 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105470:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105474:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105478:	7e 1e                	jle    80105498 <safestrcpy+0x3f>
8010547a:	8b 45 08             	mov    0x8(%ebp),%eax
8010547d:	8d 50 01             	lea    0x1(%eax),%edx
80105480:	89 55 08             	mov    %edx,0x8(%ebp)
80105483:	8b 55 0c             	mov    0xc(%ebp),%edx
80105486:	8d 4a 01             	lea    0x1(%edx),%ecx
80105489:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010548c:	0f b6 12             	movzbl (%edx),%edx
8010548f:	88 10                	mov    %dl,(%eax)
80105491:	0f b6 00             	movzbl (%eax),%eax
80105494:	84 c0                	test   %al,%al
80105496:	75 d8                	jne    80105470 <safestrcpy+0x17>
    ;
  *s = 0;
80105498:	8b 45 08             	mov    0x8(%ebp),%eax
8010549b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010549e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054a1:	c9                   	leave  
801054a2:	c3                   	ret    

801054a3 <strlen>:

int
strlen(const char *s)
{
801054a3:	55                   	push   %ebp
801054a4:	89 e5                	mov    %esp,%ebp
801054a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054b0:	eb 04                	jmp    801054b6 <strlen+0x13>
801054b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054b9:	8b 45 08             	mov    0x8(%ebp),%eax
801054bc:	01 d0                	add    %edx,%eax
801054be:	0f b6 00             	movzbl (%eax),%eax
801054c1:	84 c0                	test   %al,%al
801054c3:	75 ed                	jne    801054b2 <strlen+0xf>
    ;
  return n;
801054c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054c8:	c9                   	leave  
801054c9:	c3                   	ret    

801054ca <swtch>:
801054ca:	8b 44 24 04          	mov    0x4(%esp),%eax
801054ce:	8b 54 24 08          	mov    0x8(%esp),%edx
801054d2:	55                   	push   %ebp
801054d3:	53                   	push   %ebx
801054d4:	56                   	push   %esi
801054d5:	57                   	push   %edi
801054d6:	89 20                	mov    %esp,(%eax)
801054d8:	89 d4                	mov    %edx,%esp
801054da:	5f                   	pop    %edi
801054db:	5e                   	pop    %esi
801054dc:	5b                   	pop    %ebx
801054dd:	5d                   	pop    %ebp
801054de:	c3                   	ret    

801054df <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801054df:	55                   	push   %ebp
801054e0:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801054e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e8:	8b 00                	mov    (%eax),%eax
801054ea:	3b 45 08             	cmp    0x8(%ebp),%eax
801054ed:	76 12                	jbe    80105501 <fetchint+0x22>
801054ef:	8b 45 08             	mov    0x8(%ebp),%eax
801054f2:	8d 50 04             	lea    0x4(%eax),%edx
801054f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054fb:	8b 00                	mov    (%eax),%eax
801054fd:	39 c2                	cmp    %eax,%edx
801054ff:	76 07                	jbe    80105508 <fetchint+0x29>
    return -1;
80105501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105506:	eb 0f                	jmp    80105517 <fetchint+0x38>
  *ip = *(int*)(addr);
80105508:	8b 45 08             	mov    0x8(%ebp),%eax
8010550b:	8b 10                	mov    (%eax),%edx
8010550d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105510:	89 10                	mov    %edx,(%eax)
  return 0;
80105512:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105517:	5d                   	pop    %ebp
80105518:	c3                   	ret    

80105519 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105519:	55                   	push   %ebp
8010551a:	89 e5                	mov    %esp,%ebp
8010551c:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010551f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105525:	8b 00                	mov    (%eax),%eax
80105527:	3b 45 08             	cmp    0x8(%ebp),%eax
8010552a:	77 07                	ja     80105533 <fetchstr+0x1a>
    return -1;
8010552c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105531:	eb 46                	jmp    80105579 <fetchstr+0x60>
  *pp = (char*)addr;
80105533:	8b 55 08             	mov    0x8(%ebp),%edx
80105536:	8b 45 0c             	mov    0xc(%ebp),%eax
80105539:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010553b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105541:	8b 00                	mov    (%eax),%eax
80105543:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105546:	8b 45 0c             	mov    0xc(%ebp),%eax
80105549:	8b 00                	mov    (%eax),%eax
8010554b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010554e:	eb 1c                	jmp    8010556c <fetchstr+0x53>
    if(*s == 0)
80105550:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105553:	0f b6 00             	movzbl (%eax),%eax
80105556:	84 c0                	test   %al,%al
80105558:	75 0e                	jne    80105568 <fetchstr+0x4f>
      return s - *pp;
8010555a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010555d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105560:	8b 00                	mov    (%eax),%eax
80105562:	29 c2                	sub    %eax,%edx
80105564:	89 d0                	mov    %edx,%eax
80105566:	eb 11                	jmp    80105579 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105568:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010556c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010556f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105572:	72 dc                	jb     80105550 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105574:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105579:	c9                   	leave  
8010557a:	c3                   	ret    

8010557b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010557b:	55                   	push   %ebp
8010557c:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010557e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105584:	8b 40 18             	mov    0x18(%eax),%eax
80105587:	8b 40 44             	mov    0x44(%eax),%eax
8010558a:	8b 55 08             	mov    0x8(%ebp),%edx
8010558d:	c1 e2 02             	shl    $0x2,%edx
80105590:	01 d0                	add    %edx,%eax
80105592:	83 c0 04             	add    $0x4,%eax
80105595:	ff 75 0c             	pushl  0xc(%ebp)
80105598:	50                   	push   %eax
80105599:	e8 41 ff ff ff       	call   801054df <fetchint>
8010559e:	83 c4 08             	add    $0x8,%esp
}
801055a1:	c9                   	leave  
801055a2:	c3                   	ret    

801055a3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801055a3:	55                   	push   %ebp
801055a4:	89 e5                	mov    %esp,%ebp
801055a6:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801055a9:	8d 45 fc             	lea    -0x4(%ebp),%eax
801055ac:	50                   	push   %eax
801055ad:	ff 75 08             	pushl  0x8(%ebp)
801055b0:	e8 c6 ff ff ff       	call   8010557b <argint>
801055b5:	83 c4 08             	add    $0x8,%esp
801055b8:	85 c0                	test   %eax,%eax
801055ba:	79 07                	jns    801055c3 <argptr+0x20>
    return -1;
801055bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c1:	eb 3b                	jmp    801055fe <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801055c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055c9:	8b 00                	mov    (%eax),%eax
801055cb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055ce:	39 d0                	cmp    %edx,%eax
801055d0:	76 16                	jbe    801055e8 <argptr+0x45>
801055d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d5:	89 c2                	mov    %eax,%edx
801055d7:	8b 45 10             	mov    0x10(%ebp),%eax
801055da:	01 c2                	add    %eax,%edx
801055dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e2:	8b 00                	mov    (%eax),%eax
801055e4:	39 c2                	cmp    %eax,%edx
801055e6:	76 07                	jbe    801055ef <argptr+0x4c>
    return -1;
801055e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ed:	eb 0f                	jmp    801055fe <argptr+0x5b>
  *pp = (char*)i;
801055ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f2:	89 c2                	mov    %eax,%edx
801055f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f7:	89 10                	mov    %edx,(%eax)
  return 0;
801055f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055fe:	c9                   	leave  
801055ff:	c3                   	ret    

80105600 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105600:	55                   	push   %ebp
80105601:	89 e5                	mov    %esp,%ebp
80105603:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105606:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105609:	50                   	push   %eax
8010560a:	ff 75 08             	pushl  0x8(%ebp)
8010560d:	e8 69 ff ff ff       	call   8010557b <argint>
80105612:	83 c4 08             	add    $0x8,%esp
80105615:	85 c0                	test   %eax,%eax
80105617:	79 07                	jns    80105620 <argstr+0x20>
    return -1;
80105619:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010561e:	eb 0f                	jmp    8010562f <argstr+0x2f>
  return fetchstr(addr, pp);
80105620:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105623:	ff 75 0c             	pushl  0xc(%ebp)
80105626:	50                   	push   %eax
80105627:	e8 ed fe ff ff       	call   80105519 <fetchstr>
8010562c:	83 c4 08             	add    $0x8,%esp
}
8010562f:	c9                   	leave  
80105630:	c3                   	ret    

80105631 <syscall>:
[SYS_getprocs]	sys_getprocs,
};

void
syscall(void)
{
80105631:	55                   	push   %ebp
80105632:	89 e5                	mov    %esp,%ebp
80105634:	53                   	push   %ebx
80105635:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105638:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010563e:	8b 40 18             	mov    0x18(%eax),%eax
80105641:	8b 40 1c             	mov    0x1c(%eax),%eax
80105644:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105647:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010564b:	7e 30                	jle    8010567d <syscall+0x4c>
8010564d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105650:	83 f8 16             	cmp    $0x16,%eax
80105653:	77 28                	ja     8010567d <syscall+0x4c>
80105655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105658:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010565f:	85 c0                	test   %eax,%eax
80105661:	74 1a                	je     8010567d <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105663:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105669:	8b 58 18             	mov    0x18(%eax),%ebx
8010566c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566f:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105676:	ff d0                	call   *%eax
80105678:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010567b:	eb 34                	jmp    801056b1 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010567d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105683:	8d 50 6c             	lea    0x6c(%eax),%edx
80105686:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010568c:	8b 40 10             	mov    0x10(%eax),%eax
8010568f:	ff 75 f4             	pushl  -0xc(%ebp)
80105692:	52                   	push   %edx
80105693:	50                   	push   %eax
80105694:	68 8f 89 10 80       	push   $0x8010898f
80105699:	e8 28 ad ff ff       	call   801003c6 <cprintf>
8010569e:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801056a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056a7:	8b 40 18             	mov    0x18(%eax),%eax
801056aa:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801056b1:	90                   	nop
801056b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056b5:	c9                   	leave  
801056b6:	c3                   	ret    

801056b7 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
801056ba:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801056bd:	83 ec 08             	sub    $0x8,%esp
801056c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056c3:	50                   	push   %eax
801056c4:	ff 75 08             	pushl  0x8(%ebp)
801056c7:	e8 af fe ff ff       	call   8010557b <argint>
801056cc:	83 c4 10             	add    $0x10,%esp
801056cf:	85 c0                	test   %eax,%eax
801056d1:	79 07                	jns    801056da <argfd+0x23>
    return -1;
801056d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d8:	eb 50                	jmp    8010572a <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801056da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056dd:	85 c0                	test   %eax,%eax
801056df:	78 21                	js     80105702 <argfd+0x4b>
801056e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e4:	83 f8 0f             	cmp    $0xf,%eax
801056e7:	7f 19                	jg     80105702 <argfd+0x4b>
801056e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056f2:	83 c2 08             	add    $0x8,%edx
801056f5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105700:	75 07                	jne    80105709 <argfd+0x52>
    return -1;
80105702:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105707:	eb 21                	jmp    8010572a <argfd+0x73>
  if(pfd)
80105709:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010570d:	74 08                	je     80105717 <argfd+0x60>
    *pfd = fd;
8010570f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105712:	8b 45 0c             	mov    0xc(%ebp),%eax
80105715:	89 10                	mov    %edx,(%eax)
  if(pf)
80105717:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010571b:	74 08                	je     80105725 <argfd+0x6e>
    *pf = f;
8010571d:	8b 45 10             	mov    0x10(%ebp),%eax
80105720:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105723:	89 10                	mov    %edx,(%eax)
  return 0;
80105725:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010572a:	c9                   	leave  
8010572b:	c3                   	ret    

8010572c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010572c:	55                   	push   %ebp
8010572d:	89 e5                	mov    %esp,%ebp
8010572f:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105732:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105739:	eb 30                	jmp    8010576b <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010573b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105741:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105744:	83 c2 08             	add    $0x8,%edx
80105747:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010574b:	85 c0                	test   %eax,%eax
8010574d:	75 18                	jne    80105767 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010574f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105755:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105758:	8d 4a 08             	lea    0x8(%edx),%ecx
8010575b:	8b 55 08             	mov    0x8(%ebp),%edx
8010575e:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105762:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105765:	eb 0f                	jmp    80105776 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105767:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010576b:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010576f:	7e ca                	jle    8010573b <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105771:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105776:	c9                   	leave  
80105777:	c3                   	ret    

80105778 <sys_dup>:

int
sys_dup(void)
{
80105778:	55                   	push   %ebp
80105779:	89 e5                	mov    %esp,%ebp
8010577b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010577e:	83 ec 04             	sub    $0x4,%esp
80105781:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105784:	50                   	push   %eax
80105785:	6a 00                	push   $0x0
80105787:	6a 00                	push   $0x0
80105789:	e8 29 ff ff ff       	call   801056b7 <argfd>
8010578e:	83 c4 10             	add    $0x10,%esp
80105791:	85 c0                	test   %eax,%eax
80105793:	79 07                	jns    8010579c <sys_dup+0x24>
    return -1;
80105795:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579a:	eb 31                	jmp    801057cd <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010579c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010579f:	83 ec 0c             	sub    $0xc,%esp
801057a2:	50                   	push   %eax
801057a3:	e8 84 ff ff ff       	call   8010572c <fdalloc>
801057a8:	83 c4 10             	add    $0x10,%esp
801057ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b2:	79 07                	jns    801057bb <sys_dup+0x43>
    return -1;
801057b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b9:	eb 12                	jmp    801057cd <sys_dup+0x55>
  filedup(f);
801057bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057be:	83 ec 0c             	sub    $0xc,%esp
801057c1:	50                   	push   %eax
801057c2:	e8 2c b8 ff ff       	call   80100ff3 <filedup>
801057c7:	83 c4 10             	add    $0x10,%esp
  return fd;
801057ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801057cd:	c9                   	leave  
801057ce:	c3                   	ret    

801057cf <sys_read>:

int
sys_read(void)
{
801057cf:	55                   	push   %ebp
801057d0:	89 e5                	mov    %esp,%ebp
801057d2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057d5:	83 ec 04             	sub    $0x4,%esp
801057d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057db:	50                   	push   %eax
801057dc:	6a 00                	push   $0x0
801057de:	6a 00                	push   $0x0
801057e0:	e8 d2 fe ff ff       	call   801056b7 <argfd>
801057e5:	83 c4 10             	add    $0x10,%esp
801057e8:	85 c0                	test   %eax,%eax
801057ea:	78 2e                	js     8010581a <sys_read+0x4b>
801057ec:	83 ec 08             	sub    $0x8,%esp
801057ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f2:	50                   	push   %eax
801057f3:	6a 02                	push   $0x2
801057f5:	e8 81 fd ff ff       	call   8010557b <argint>
801057fa:	83 c4 10             	add    $0x10,%esp
801057fd:	85 c0                	test   %eax,%eax
801057ff:	78 19                	js     8010581a <sys_read+0x4b>
80105801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105804:	83 ec 04             	sub    $0x4,%esp
80105807:	50                   	push   %eax
80105808:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010580b:	50                   	push   %eax
8010580c:	6a 01                	push   $0x1
8010580e:	e8 90 fd ff ff       	call   801055a3 <argptr>
80105813:	83 c4 10             	add    $0x10,%esp
80105816:	85 c0                	test   %eax,%eax
80105818:	79 07                	jns    80105821 <sys_read+0x52>
    return -1;
8010581a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010581f:	eb 17                	jmp    80105838 <sys_read+0x69>
  return fileread(f, p, n);
80105821:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105824:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582a:	83 ec 04             	sub    $0x4,%esp
8010582d:	51                   	push   %ecx
8010582e:	52                   	push   %edx
8010582f:	50                   	push   %eax
80105830:	e8 56 b9 ff ff       	call   8010118b <fileread>
80105835:	83 c4 10             	add    $0x10,%esp
}
80105838:	c9                   	leave  
80105839:	c3                   	ret    

8010583a <sys_write>:

int
sys_write(void)
{
8010583a:	55                   	push   %ebp
8010583b:	89 e5                	mov    %esp,%ebp
8010583d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105840:	83 ec 04             	sub    $0x4,%esp
80105843:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105846:	50                   	push   %eax
80105847:	6a 00                	push   $0x0
80105849:	6a 00                	push   $0x0
8010584b:	e8 67 fe ff ff       	call   801056b7 <argfd>
80105850:	83 c4 10             	add    $0x10,%esp
80105853:	85 c0                	test   %eax,%eax
80105855:	78 2e                	js     80105885 <sys_write+0x4b>
80105857:	83 ec 08             	sub    $0x8,%esp
8010585a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010585d:	50                   	push   %eax
8010585e:	6a 02                	push   $0x2
80105860:	e8 16 fd ff ff       	call   8010557b <argint>
80105865:	83 c4 10             	add    $0x10,%esp
80105868:	85 c0                	test   %eax,%eax
8010586a:	78 19                	js     80105885 <sys_write+0x4b>
8010586c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586f:	83 ec 04             	sub    $0x4,%esp
80105872:	50                   	push   %eax
80105873:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105876:	50                   	push   %eax
80105877:	6a 01                	push   $0x1
80105879:	e8 25 fd ff ff       	call   801055a3 <argptr>
8010587e:	83 c4 10             	add    $0x10,%esp
80105881:	85 c0                	test   %eax,%eax
80105883:	79 07                	jns    8010588c <sys_write+0x52>
    return -1;
80105885:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588a:	eb 17                	jmp    801058a3 <sys_write+0x69>
  return filewrite(f, p, n);
8010588c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010588f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105895:	83 ec 04             	sub    $0x4,%esp
80105898:	51                   	push   %ecx
80105899:	52                   	push   %edx
8010589a:	50                   	push   %eax
8010589b:	e8 a3 b9 ff ff       	call   80101243 <filewrite>
801058a0:	83 c4 10             	add    $0x10,%esp
}
801058a3:	c9                   	leave  
801058a4:	c3                   	ret    

801058a5 <sys_close>:

int
sys_close(void)
{
801058a5:	55                   	push   %ebp
801058a6:	89 e5                	mov    %esp,%ebp
801058a8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801058ab:	83 ec 04             	sub    $0x4,%esp
801058ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058b1:	50                   	push   %eax
801058b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058b5:	50                   	push   %eax
801058b6:	6a 00                	push   $0x0
801058b8:	e8 fa fd ff ff       	call   801056b7 <argfd>
801058bd:	83 c4 10             	add    $0x10,%esp
801058c0:	85 c0                	test   %eax,%eax
801058c2:	79 07                	jns    801058cb <sys_close+0x26>
    return -1;
801058c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c9:	eb 28                	jmp    801058f3 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801058cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058d4:	83 c2 08             	add    $0x8,%edx
801058d7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801058de:	00 
  fileclose(f);
801058df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e2:	83 ec 0c             	sub    $0xc,%esp
801058e5:	50                   	push   %eax
801058e6:	e8 61 b7 ff ff       	call   8010104c <fileclose>
801058eb:	83 c4 10             	add    $0x10,%esp
  return 0;
801058ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058f3:	c9                   	leave  
801058f4:	c3                   	ret    

801058f5 <sys_fstat>:

int
sys_fstat(void)
{
801058f5:	55                   	push   %ebp
801058f6:	89 e5                	mov    %esp,%ebp
801058f8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801058fb:	83 ec 04             	sub    $0x4,%esp
801058fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105901:	50                   	push   %eax
80105902:	6a 00                	push   $0x0
80105904:	6a 00                	push   $0x0
80105906:	e8 ac fd ff ff       	call   801056b7 <argfd>
8010590b:	83 c4 10             	add    $0x10,%esp
8010590e:	85 c0                	test   %eax,%eax
80105910:	78 17                	js     80105929 <sys_fstat+0x34>
80105912:	83 ec 04             	sub    $0x4,%esp
80105915:	6a 14                	push   $0x14
80105917:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010591a:	50                   	push   %eax
8010591b:	6a 01                	push   $0x1
8010591d:	e8 81 fc ff ff       	call   801055a3 <argptr>
80105922:	83 c4 10             	add    $0x10,%esp
80105925:	85 c0                	test   %eax,%eax
80105927:	79 07                	jns    80105930 <sys_fstat+0x3b>
    return -1;
80105929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592e:	eb 13                	jmp    80105943 <sys_fstat+0x4e>
  return filestat(f, st);
80105930:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105936:	83 ec 08             	sub    $0x8,%esp
80105939:	52                   	push   %edx
8010593a:	50                   	push   %eax
8010593b:	e8 f4 b7 ff ff       	call   80101134 <filestat>
80105940:	83 c4 10             	add    $0x10,%esp
}
80105943:	c9                   	leave  
80105944:	c3                   	ret    

80105945 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105945:	55                   	push   %ebp
80105946:	89 e5                	mov    %esp,%ebp
80105948:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010594b:	83 ec 08             	sub    $0x8,%esp
8010594e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105951:	50                   	push   %eax
80105952:	6a 00                	push   $0x0
80105954:	e8 a7 fc ff ff       	call   80105600 <argstr>
80105959:	83 c4 10             	add    $0x10,%esp
8010595c:	85 c0                	test   %eax,%eax
8010595e:	78 15                	js     80105975 <sys_link+0x30>
80105960:	83 ec 08             	sub    $0x8,%esp
80105963:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105966:	50                   	push   %eax
80105967:	6a 01                	push   $0x1
80105969:	e8 92 fc ff ff       	call   80105600 <argstr>
8010596e:	83 c4 10             	add    $0x10,%esp
80105971:	85 c0                	test   %eax,%eax
80105973:	79 0a                	jns    8010597f <sys_link+0x3a>
    return -1;
80105975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597a:	e9 68 01 00 00       	jmp    80105ae7 <sys_link+0x1a2>

  begin_op();
8010597f:	e8 50 db ff ff       	call   801034d4 <begin_op>
  if((ip = namei(old)) == 0){
80105984:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105987:	83 ec 0c             	sub    $0xc,%esp
8010598a:	50                   	push   %eax
8010598b:	e8 53 cb ff ff       	call   801024e3 <namei>
80105990:	83 c4 10             	add    $0x10,%esp
80105993:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105996:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010599a:	75 0f                	jne    801059ab <sys_link+0x66>
    end_op();
8010599c:	e8 bf db ff ff       	call   80103560 <end_op>
    return -1;
801059a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a6:	e9 3c 01 00 00       	jmp    80105ae7 <sys_link+0x1a2>
  }

  ilock(ip);
801059ab:	83 ec 0c             	sub    $0xc,%esp
801059ae:	ff 75 f4             	pushl  -0xc(%ebp)
801059b1:	e8 75 bf ff ff       	call   8010192b <ilock>
801059b6:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801059b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801059c0:	66 83 f8 01          	cmp    $0x1,%ax
801059c4:	75 1d                	jne    801059e3 <sys_link+0x9e>
    iunlockput(ip);
801059c6:	83 ec 0c             	sub    $0xc,%esp
801059c9:	ff 75 f4             	pushl  -0xc(%ebp)
801059cc:	e8 14 c2 ff ff       	call   80101be5 <iunlockput>
801059d1:	83 c4 10             	add    $0x10,%esp
    end_op();
801059d4:	e8 87 db ff ff       	call   80103560 <end_op>
    return -1;
801059d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059de:	e9 04 01 00 00       	jmp    80105ae7 <sys_link+0x1a2>
  }

  ip->nlink++;
801059e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059ea:	83 c0 01             	add    $0x1,%eax
801059ed:	89 c2                	mov    %eax,%edx
801059ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f2:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801059f6:	83 ec 0c             	sub    $0xc,%esp
801059f9:	ff 75 f4             	pushl  -0xc(%ebp)
801059fc:	e8 56 bd ff ff       	call   80101757 <iupdate>
80105a01:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a04:	83 ec 0c             	sub    $0xc,%esp
80105a07:	ff 75 f4             	pushl  -0xc(%ebp)
80105a0a:	e8 74 c0 ff ff       	call   80101a83 <iunlock>
80105a0f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a15:	83 ec 08             	sub    $0x8,%esp
80105a18:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a1b:	52                   	push   %edx
80105a1c:	50                   	push   %eax
80105a1d:	e8 dd ca ff ff       	call   801024ff <nameiparent>
80105a22:	83 c4 10             	add    $0x10,%esp
80105a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a2c:	74 71                	je     80105a9f <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a2e:	83 ec 0c             	sub    $0xc,%esp
80105a31:	ff 75 f0             	pushl  -0x10(%ebp)
80105a34:	e8 f2 be ff ff       	call   8010192b <ilock>
80105a39:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3f:	8b 10                	mov    (%eax),%edx
80105a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a44:	8b 00                	mov    (%eax),%eax
80105a46:	39 c2                	cmp    %eax,%edx
80105a48:	75 1d                	jne    80105a67 <sys_link+0x122>
80105a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4d:	8b 40 04             	mov    0x4(%eax),%eax
80105a50:	83 ec 04             	sub    $0x4,%esp
80105a53:	50                   	push   %eax
80105a54:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105a57:	50                   	push   %eax
80105a58:	ff 75 f0             	pushl  -0x10(%ebp)
80105a5b:	e8 e7 c7 ff ff       	call   80102247 <dirlink>
80105a60:	83 c4 10             	add    $0x10,%esp
80105a63:	85 c0                	test   %eax,%eax
80105a65:	79 10                	jns    80105a77 <sys_link+0x132>
    iunlockput(dp);
80105a67:	83 ec 0c             	sub    $0xc,%esp
80105a6a:	ff 75 f0             	pushl  -0x10(%ebp)
80105a6d:	e8 73 c1 ff ff       	call   80101be5 <iunlockput>
80105a72:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105a75:	eb 29                	jmp    80105aa0 <sys_link+0x15b>
  }
  iunlockput(dp);
80105a77:	83 ec 0c             	sub    $0xc,%esp
80105a7a:	ff 75 f0             	pushl  -0x10(%ebp)
80105a7d:	e8 63 c1 ff ff       	call   80101be5 <iunlockput>
80105a82:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105a85:	83 ec 0c             	sub    $0xc,%esp
80105a88:	ff 75 f4             	pushl  -0xc(%ebp)
80105a8b:	e8 65 c0 ff ff       	call   80101af5 <iput>
80105a90:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a93:	e8 c8 da ff ff       	call   80103560 <end_op>

  return 0;
80105a98:	b8 00 00 00 00       	mov    $0x0,%eax
80105a9d:	eb 48                	jmp    80105ae7 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105a9f:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105aa0:	83 ec 0c             	sub    $0xc,%esp
80105aa3:	ff 75 f4             	pushl  -0xc(%ebp)
80105aa6:	e8 80 be ff ff       	call   8010192b <ilock>
80105aab:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ab5:	83 e8 01             	sub    $0x1,%eax
80105ab8:	89 c2                	mov    %eax,%edx
80105aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abd:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ac1:	83 ec 0c             	sub    $0xc,%esp
80105ac4:	ff 75 f4             	pushl  -0xc(%ebp)
80105ac7:	e8 8b bc ff ff       	call   80101757 <iupdate>
80105acc:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105acf:	83 ec 0c             	sub    $0xc,%esp
80105ad2:	ff 75 f4             	pushl  -0xc(%ebp)
80105ad5:	e8 0b c1 ff ff       	call   80101be5 <iunlockput>
80105ada:	83 c4 10             	add    $0x10,%esp
  end_op();
80105add:	e8 7e da ff ff       	call   80103560 <end_op>
  return -1;
80105ae2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ae7:	c9                   	leave  
80105ae8:	c3                   	ret    

80105ae9 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105ae9:	55                   	push   %ebp
80105aea:	89 e5                	mov    %esp,%ebp
80105aec:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105aef:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105af6:	eb 40                	jmp    80105b38 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afb:	6a 10                	push   $0x10
80105afd:	50                   	push   %eax
80105afe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b01:	50                   	push   %eax
80105b02:	ff 75 08             	pushl  0x8(%ebp)
80105b05:	e8 89 c3 ff ff       	call   80101e93 <readi>
80105b0a:	83 c4 10             	add    $0x10,%esp
80105b0d:	83 f8 10             	cmp    $0x10,%eax
80105b10:	74 0d                	je     80105b1f <isdirempty+0x36>
      panic("isdirempty: readi");
80105b12:	83 ec 0c             	sub    $0xc,%esp
80105b15:	68 ab 89 10 80       	push   $0x801089ab
80105b1a:	e8 47 aa ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105b1f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b23:	66 85 c0             	test   %ax,%ax
80105b26:	74 07                	je     80105b2f <isdirempty+0x46>
      return 0;
80105b28:	b8 00 00 00 00       	mov    $0x0,%eax
80105b2d:	eb 1b                	jmp    80105b4a <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b32:	83 c0 10             	add    $0x10,%eax
80105b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b38:	8b 45 08             	mov    0x8(%ebp),%eax
80105b3b:	8b 50 18             	mov    0x18(%eax),%edx
80105b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b41:	39 c2                	cmp    %eax,%edx
80105b43:	77 b3                	ja     80105af8 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105b45:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105b4a:	c9                   	leave  
80105b4b:	c3                   	ret    

80105b4c <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105b4c:	55                   	push   %ebp
80105b4d:	89 e5                	mov    %esp,%ebp
80105b4f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105b52:	83 ec 08             	sub    $0x8,%esp
80105b55:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105b58:	50                   	push   %eax
80105b59:	6a 00                	push   $0x0
80105b5b:	e8 a0 fa ff ff       	call   80105600 <argstr>
80105b60:	83 c4 10             	add    $0x10,%esp
80105b63:	85 c0                	test   %eax,%eax
80105b65:	79 0a                	jns    80105b71 <sys_unlink+0x25>
    return -1;
80105b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6c:	e9 bc 01 00 00       	jmp    80105d2d <sys_unlink+0x1e1>

  begin_op();
80105b71:	e8 5e d9 ff ff       	call   801034d4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105b76:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105b79:	83 ec 08             	sub    $0x8,%esp
80105b7c:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105b7f:	52                   	push   %edx
80105b80:	50                   	push   %eax
80105b81:	e8 79 c9 ff ff       	call   801024ff <nameiparent>
80105b86:	83 c4 10             	add    $0x10,%esp
80105b89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b90:	75 0f                	jne    80105ba1 <sys_unlink+0x55>
    end_op();
80105b92:	e8 c9 d9 ff ff       	call   80103560 <end_op>
    return -1;
80105b97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9c:	e9 8c 01 00 00       	jmp    80105d2d <sys_unlink+0x1e1>
  }

  ilock(dp);
80105ba1:	83 ec 0c             	sub    $0xc,%esp
80105ba4:	ff 75 f4             	pushl  -0xc(%ebp)
80105ba7:	e8 7f bd ff ff       	call   8010192b <ilock>
80105bac:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105baf:	83 ec 08             	sub    $0x8,%esp
80105bb2:	68 bd 89 10 80       	push   $0x801089bd
80105bb7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bba:	50                   	push   %eax
80105bbb:	e8 b2 c5 ff ff       	call   80102172 <namecmp>
80105bc0:	83 c4 10             	add    $0x10,%esp
80105bc3:	85 c0                	test   %eax,%eax
80105bc5:	0f 84 4a 01 00 00    	je     80105d15 <sys_unlink+0x1c9>
80105bcb:	83 ec 08             	sub    $0x8,%esp
80105bce:	68 bf 89 10 80       	push   $0x801089bf
80105bd3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bd6:	50                   	push   %eax
80105bd7:	e8 96 c5 ff ff       	call   80102172 <namecmp>
80105bdc:	83 c4 10             	add    $0x10,%esp
80105bdf:	85 c0                	test   %eax,%eax
80105be1:	0f 84 2e 01 00 00    	je     80105d15 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105be7:	83 ec 04             	sub    $0x4,%esp
80105bea:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105bed:	50                   	push   %eax
80105bee:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bf1:	50                   	push   %eax
80105bf2:	ff 75 f4             	pushl  -0xc(%ebp)
80105bf5:	e8 93 c5 ff ff       	call   8010218d <dirlookup>
80105bfa:	83 c4 10             	add    $0x10,%esp
80105bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c04:	0f 84 0a 01 00 00    	je     80105d14 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105c0a:	83 ec 0c             	sub    $0xc,%esp
80105c0d:	ff 75 f0             	pushl  -0x10(%ebp)
80105c10:	e8 16 bd ff ff       	call   8010192b <ilock>
80105c15:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c1f:	66 85 c0             	test   %ax,%ax
80105c22:	7f 0d                	jg     80105c31 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c24:	83 ec 0c             	sub    $0xc,%esp
80105c27:	68 c2 89 10 80       	push   $0x801089c2
80105c2c:	e8 35 a9 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c34:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c38:	66 83 f8 01          	cmp    $0x1,%ax
80105c3c:	75 25                	jne    80105c63 <sys_unlink+0x117>
80105c3e:	83 ec 0c             	sub    $0xc,%esp
80105c41:	ff 75 f0             	pushl  -0x10(%ebp)
80105c44:	e8 a0 fe ff ff       	call   80105ae9 <isdirempty>
80105c49:	83 c4 10             	add    $0x10,%esp
80105c4c:	85 c0                	test   %eax,%eax
80105c4e:	75 13                	jne    80105c63 <sys_unlink+0x117>
    iunlockput(ip);
80105c50:	83 ec 0c             	sub    $0xc,%esp
80105c53:	ff 75 f0             	pushl  -0x10(%ebp)
80105c56:	e8 8a bf ff ff       	call   80101be5 <iunlockput>
80105c5b:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c5e:	e9 b2 00 00 00       	jmp    80105d15 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105c63:	83 ec 04             	sub    $0x4,%esp
80105c66:	6a 10                	push   $0x10
80105c68:	6a 00                	push   $0x0
80105c6a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c6d:	50                   	push   %eax
80105c6e:	e8 e3 f5 ff ff       	call   80105256 <memset>
80105c73:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c76:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105c79:	6a 10                	push   $0x10
80105c7b:	50                   	push   %eax
80105c7c:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c7f:	50                   	push   %eax
80105c80:	ff 75 f4             	pushl  -0xc(%ebp)
80105c83:	e8 62 c3 ff ff       	call   80101fea <writei>
80105c88:	83 c4 10             	add    $0x10,%esp
80105c8b:	83 f8 10             	cmp    $0x10,%eax
80105c8e:	74 0d                	je     80105c9d <sys_unlink+0x151>
    panic("unlink: writei");
80105c90:	83 ec 0c             	sub    $0xc,%esp
80105c93:	68 d4 89 10 80       	push   $0x801089d4
80105c98:	e8 c9 a8 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80105c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ca4:	66 83 f8 01          	cmp    $0x1,%ax
80105ca8:	75 21                	jne    80105ccb <sys_unlink+0x17f>
    dp->nlink--;
80105caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cad:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cb1:	83 e8 01             	sub    $0x1,%eax
80105cb4:	89 c2                	mov    %eax,%edx
80105cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb9:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105cbd:	83 ec 0c             	sub    $0xc,%esp
80105cc0:	ff 75 f4             	pushl  -0xc(%ebp)
80105cc3:	e8 8f ba ff ff       	call   80101757 <iupdate>
80105cc8:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105ccb:	83 ec 0c             	sub    $0xc,%esp
80105cce:	ff 75 f4             	pushl  -0xc(%ebp)
80105cd1:	e8 0f bf ff ff       	call   80101be5 <iunlockput>
80105cd6:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cdc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ce0:	83 e8 01             	sub    $0x1,%eax
80105ce3:	89 c2                	mov    %eax,%edx
80105ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce8:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105cec:	83 ec 0c             	sub    $0xc,%esp
80105cef:	ff 75 f0             	pushl  -0x10(%ebp)
80105cf2:	e8 60 ba ff ff       	call   80101757 <iupdate>
80105cf7:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105cfa:	83 ec 0c             	sub    $0xc,%esp
80105cfd:	ff 75 f0             	pushl  -0x10(%ebp)
80105d00:	e8 e0 be ff ff       	call   80101be5 <iunlockput>
80105d05:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d08:	e8 53 d8 ff ff       	call   80103560 <end_op>

  return 0;
80105d0d:	b8 00 00 00 00       	mov    $0x0,%eax
80105d12:	eb 19                	jmp    80105d2d <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105d14:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105d15:	83 ec 0c             	sub    $0xc,%esp
80105d18:	ff 75 f4             	pushl  -0xc(%ebp)
80105d1b:	e8 c5 be ff ff       	call   80101be5 <iunlockput>
80105d20:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d23:	e8 38 d8 ff ff       	call   80103560 <end_op>
  return -1;
80105d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d2d:	c9                   	leave  
80105d2e:	c3                   	ret    

80105d2f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d2f:	55                   	push   %ebp
80105d30:	89 e5                	mov    %esp,%ebp
80105d32:	83 ec 38             	sub    $0x38,%esp
80105d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d38:	8b 55 10             	mov    0x10(%ebp),%edx
80105d3b:	8b 45 14             	mov    0x14(%ebp),%eax
80105d3e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d42:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d46:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105d4a:	83 ec 08             	sub    $0x8,%esp
80105d4d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d50:	50                   	push   %eax
80105d51:	ff 75 08             	pushl  0x8(%ebp)
80105d54:	e8 a6 c7 ff ff       	call   801024ff <nameiparent>
80105d59:	83 c4 10             	add    $0x10,%esp
80105d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d63:	75 0a                	jne    80105d6f <create+0x40>
    return 0;
80105d65:	b8 00 00 00 00       	mov    $0x0,%eax
80105d6a:	e9 90 01 00 00       	jmp    80105eff <create+0x1d0>
  ilock(dp);
80105d6f:	83 ec 0c             	sub    $0xc,%esp
80105d72:	ff 75 f4             	pushl  -0xc(%ebp)
80105d75:	e8 b1 bb ff ff       	call   8010192b <ilock>
80105d7a:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105d7d:	83 ec 04             	sub    $0x4,%esp
80105d80:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d83:	50                   	push   %eax
80105d84:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d87:	50                   	push   %eax
80105d88:	ff 75 f4             	pushl  -0xc(%ebp)
80105d8b:	e8 fd c3 ff ff       	call   8010218d <dirlookup>
80105d90:	83 c4 10             	add    $0x10,%esp
80105d93:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d9a:	74 50                	je     80105dec <create+0xbd>
    iunlockput(dp);
80105d9c:	83 ec 0c             	sub    $0xc,%esp
80105d9f:	ff 75 f4             	pushl  -0xc(%ebp)
80105da2:	e8 3e be ff ff       	call   80101be5 <iunlockput>
80105da7:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105daa:	83 ec 0c             	sub    $0xc,%esp
80105dad:	ff 75 f0             	pushl  -0x10(%ebp)
80105db0:	e8 76 bb ff ff       	call   8010192b <ilock>
80105db5:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105db8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105dbd:	75 15                	jne    80105dd4 <create+0xa5>
80105dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105dc6:	66 83 f8 02          	cmp    $0x2,%ax
80105dca:	75 08                	jne    80105dd4 <create+0xa5>
      return ip;
80105dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcf:	e9 2b 01 00 00       	jmp    80105eff <create+0x1d0>
    iunlockput(ip);
80105dd4:	83 ec 0c             	sub    $0xc,%esp
80105dd7:	ff 75 f0             	pushl  -0x10(%ebp)
80105dda:	e8 06 be ff ff       	call   80101be5 <iunlockput>
80105ddf:	83 c4 10             	add    $0x10,%esp
    return 0;
80105de2:	b8 00 00 00 00       	mov    $0x0,%eax
80105de7:	e9 13 01 00 00       	jmp    80105eff <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105dec:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df3:	8b 00                	mov    (%eax),%eax
80105df5:	83 ec 08             	sub    $0x8,%esp
80105df8:	52                   	push   %edx
80105df9:	50                   	push   %eax
80105dfa:	e8 77 b8 ff ff       	call   80101676 <ialloc>
80105dff:	83 c4 10             	add    $0x10,%esp
80105e02:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e09:	75 0d                	jne    80105e18 <create+0xe9>
    panic("create: ialloc");
80105e0b:	83 ec 0c             	sub    $0xc,%esp
80105e0e:	68 e3 89 10 80       	push   $0x801089e3
80105e13:	e8 4e a7 ff ff       	call   80100566 <panic>

  ilock(ip);
80105e18:	83 ec 0c             	sub    $0xc,%esp
80105e1b:	ff 75 f0             	pushl  -0x10(%ebp)
80105e1e:	e8 08 bb ff ff       	call   8010192b <ilock>
80105e23:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e29:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e2d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e34:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e38:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105e45:	83 ec 0c             	sub    $0xc,%esp
80105e48:	ff 75 f0             	pushl  -0x10(%ebp)
80105e4b:	e8 07 b9 ff ff       	call   80101757 <iupdate>
80105e50:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105e53:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105e58:	75 6a                	jne    80105ec4 <create+0x195>
    dp->nlink++;  // for ".."
80105e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e61:	83 c0 01             	add    $0x1,%eax
80105e64:	89 c2                	mov    %eax,%edx
80105e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e69:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105e6d:	83 ec 0c             	sub    $0xc,%esp
80105e70:	ff 75 f4             	pushl  -0xc(%ebp)
80105e73:	e8 df b8 ff ff       	call   80101757 <iupdate>
80105e78:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7e:	8b 40 04             	mov    0x4(%eax),%eax
80105e81:	83 ec 04             	sub    $0x4,%esp
80105e84:	50                   	push   %eax
80105e85:	68 bd 89 10 80       	push   $0x801089bd
80105e8a:	ff 75 f0             	pushl  -0x10(%ebp)
80105e8d:	e8 b5 c3 ff ff       	call   80102247 <dirlink>
80105e92:	83 c4 10             	add    $0x10,%esp
80105e95:	85 c0                	test   %eax,%eax
80105e97:	78 1e                	js     80105eb7 <create+0x188>
80105e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9c:	8b 40 04             	mov    0x4(%eax),%eax
80105e9f:	83 ec 04             	sub    $0x4,%esp
80105ea2:	50                   	push   %eax
80105ea3:	68 bf 89 10 80       	push   $0x801089bf
80105ea8:	ff 75 f0             	pushl  -0x10(%ebp)
80105eab:	e8 97 c3 ff ff       	call   80102247 <dirlink>
80105eb0:	83 c4 10             	add    $0x10,%esp
80105eb3:	85 c0                	test   %eax,%eax
80105eb5:	79 0d                	jns    80105ec4 <create+0x195>
      panic("create dots");
80105eb7:	83 ec 0c             	sub    $0xc,%esp
80105eba:	68 f2 89 10 80       	push   $0x801089f2
80105ebf:	e8 a2 a6 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec7:	8b 40 04             	mov    0x4(%eax),%eax
80105eca:	83 ec 04             	sub    $0x4,%esp
80105ecd:	50                   	push   %eax
80105ece:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ed1:	50                   	push   %eax
80105ed2:	ff 75 f4             	pushl  -0xc(%ebp)
80105ed5:	e8 6d c3 ff ff       	call   80102247 <dirlink>
80105eda:	83 c4 10             	add    $0x10,%esp
80105edd:	85 c0                	test   %eax,%eax
80105edf:	79 0d                	jns    80105eee <create+0x1bf>
    panic("create: dirlink");
80105ee1:	83 ec 0c             	sub    $0xc,%esp
80105ee4:	68 fe 89 10 80       	push   $0x801089fe
80105ee9:	e8 78 a6 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80105eee:	83 ec 0c             	sub    $0xc,%esp
80105ef1:	ff 75 f4             	pushl  -0xc(%ebp)
80105ef4:	e8 ec bc ff ff       	call   80101be5 <iunlockput>
80105ef9:	83 c4 10             	add    $0x10,%esp

  return ip;
80105efc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105eff:	c9                   	leave  
80105f00:	c3                   	ret    

80105f01 <sys_open>:

int
sys_open(void)
{
80105f01:	55                   	push   %ebp
80105f02:	89 e5                	mov    %esp,%ebp
80105f04:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f07:	83 ec 08             	sub    $0x8,%esp
80105f0a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f0d:	50                   	push   %eax
80105f0e:	6a 00                	push   $0x0
80105f10:	e8 eb f6 ff ff       	call   80105600 <argstr>
80105f15:	83 c4 10             	add    $0x10,%esp
80105f18:	85 c0                	test   %eax,%eax
80105f1a:	78 15                	js     80105f31 <sys_open+0x30>
80105f1c:	83 ec 08             	sub    $0x8,%esp
80105f1f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f22:	50                   	push   %eax
80105f23:	6a 01                	push   $0x1
80105f25:	e8 51 f6 ff ff       	call   8010557b <argint>
80105f2a:	83 c4 10             	add    $0x10,%esp
80105f2d:	85 c0                	test   %eax,%eax
80105f2f:	79 0a                	jns    80105f3b <sys_open+0x3a>
    return -1;
80105f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f36:	e9 61 01 00 00       	jmp    8010609c <sys_open+0x19b>

  begin_op();
80105f3b:	e8 94 d5 ff ff       	call   801034d4 <begin_op>

  if(omode & O_CREATE){
80105f40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f43:	25 00 02 00 00       	and    $0x200,%eax
80105f48:	85 c0                	test   %eax,%eax
80105f4a:	74 2a                	je     80105f76 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105f4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f4f:	6a 00                	push   $0x0
80105f51:	6a 00                	push   $0x0
80105f53:	6a 02                	push   $0x2
80105f55:	50                   	push   %eax
80105f56:	e8 d4 fd ff ff       	call   80105d2f <create>
80105f5b:	83 c4 10             	add    $0x10,%esp
80105f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105f61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f65:	75 75                	jne    80105fdc <sys_open+0xdb>
      end_op();
80105f67:	e8 f4 d5 ff ff       	call   80103560 <end_op>
      return -1;
80105f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f71:	e9 26 01 00 00       	jmp    8010609c <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105f76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f79:	83 ec 0c             	sub    $0xc,%esp
80105f7c:	50                   	push   %eax
80105f7d:	e8 61 c5 ff ff       	call   801024e3 <namei>
80105f82:	83 c4 10             	add    $0x10,%esp
80105f85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f8c:	75 0f                	jne    80105f9d <sys_open+0x9c>
      end_op();
80105f8e:	e8 cd d5 ff ff       	call   80103560 <end_op>
      return -1;
80105f93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f98:	e9 ff 00 00 00       	jmp    8010609c <sys_open+0x19b>
    }
    ilock(ip);
80105f9d:	83 ec 0c             	sub    $0xc,%esp
80105fa0:	ff 75 f4             	pushl  -0xc(%ebp)
80105fa3:	e8 83 b9 ff ff       	call   8010192b <ilock>
80105fa8:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fb2:	66 83 f8 01          	cmp    $0x1,%ax
80105fb6:	75 24                	jne    80105fdc <sys_open+0xdb>
80105fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fbb:	85 c0                	test   %eax,%eax
80105fbd:	74 1d                	je     80105fdc <sys_open+0xdb>
      iunlockput(ip);
80105fbf:	83 ec 0c             	sub    $0xc,%esp
80105fc2:	ff 75 f4             	pushl  -0xc(%ebp)
80105fc5:	e8 1b bc ff ff       	call   80101be5 <iunlockput>
80105fca:	83 c4 10             	add    $0x10,%esp
      end_op();
80105fcd:	e8 8e d5 ff ff       	call   80103560 <end_op>
      return -1;
80105fd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd7:	e9 c0 00 00 00       	jmp    8010609c <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105fdc:	e8 97 af ff ff       	call   80100f78 <filealloc>
80105fe1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fe4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fe8:	74 17                	je     80106001 <sys_open+0x100>
80105fea:	83 ec 0c             	sub    $0xc,%esp
80105fed:	ff 75 f0             	pushl  -0x10(%ebp)
80105ff0:	e8 37 f7 ff ff       	call   8010572c <fdalloc>
80105ff5:	83 c4 10             	add    $0x10,%esp
80105ff8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ffb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105fff:	79 2e                	jns    8010602f <sys_open+0x12e>
    if(f)
80106001:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106005:	74 0e                	je     80106015 <sys_open+0x114>
      fileclose(f);
80106007:	83 ec 0c             	sub    $0xc,%esp
8010600a:	ff 75 f0             	pushl  -0x10(%ebp)
8010600d:	e8 3a b0 ff ff       	call   8010104c <fileclose>
80106012:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106015:	83 ec 0c             	sub    $0xc,%esp
80106018:	ff 75 f4             	pushl  -0xc(%ebp)
8010601b:	e8 c5 bb ff ff       	call   80101be5 <iunlockput>
80106020:	83 c4 10             	add    $0x10,%esp
    end_op();
80106023:	e8 38 d5 ff ff       	call   80103560 <end_op>
    return -1;
80106028:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602d:	eb 6d                	jmp    8010609c <sys_open+0x19b>
  }
  iunlock(ip);
8010602f:	83 ec 0c             	sub    $0xc,%esp
80106032:	ff 75 f4             	pushl  -0xc(%ebp)
80106035:	e8 49 ba ff ff       	call   80101a83 <iunlock>
8010603a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010603d:	e8 1e d5 ff ff       	call   80103560 <end_op>

  f->type = FD_INODE;
80106042:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106045:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010604b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010604e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106051:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106054:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106057:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010605e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106061:	83 e0 01             	and    $0x1,%eax
80106064:	85 c0                	test   %eax,%eax
80106066:	0f 94 c0             	sete   %al
80106069:	89 c2                	mov    %eax,%edx
8010606b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606e:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106071:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106074:	83 e0 01             	and    $0x1,%eax
80106077:	85 c0                	test   %eax,%eax
80106079:	75 0a                	jne    80106085 <sys_open+0x184>
8010607b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010607e:	83 e0 02             	and    $0x2,%eax
80106081:	85 c0                	test   %eax,%eax
80106083:	74 07                	je     8010608c <sys_open+0x18b>
80106085:	b8 01 00 00 00       	mov    $0x1,%eax
8010608a:	eb 05                	jmp    80106091 <sys_open+0x190>
8010608c:	b8 00 00 00 00       	mov    $0x0,%eax
80106091:	89 c2                	mov    %eax,%edx
80106093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106096:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106099:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010609c:	c9                   	leave  
8010609d:	c3                   	ret    

8010609e <sys_mkdir>:

int
sys_mkdir(void)
{
8010609e:	55                   	push   %ebp
8010609f:	89 e5                	mov    %esp,%ebp
801060a1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060a4:	e8 2b d4 ff ff       	call   801034d4 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801060a9:	83 ec 08             	sub    $0x8,%esp
801060ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060af:	50                   	push   %eax
801060b0:	6a 00                	push   $0x0
801060b2:	e8 49 f5 ff ff       	call   80105600 <argstr>
801060b7:	83 c4 10             	add    $0x10,%esp
801060ba:	85 c0                	test   %eax,%eax
801060bc:	78 1b                	js     801060d9 <sys_mkdir+0x3b>
801060be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c1:	6a 00                	push   $0x0
801060c3:	6a 00                	push   $0x0
801060c5:	6a 01                	push   $0x1
801060c7:	50                   	push   %eax
801060c8:	e8 62 fc ff ff       	call   80105d2f <create>
801060cd:	83 c4 10             	add    $0x10,%esp
801060d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060d7:	75 0c                	jne    801060e5 <sys_mkdir+0x47>
    end_op();
801060d9:	e8 82 d4 ff ff       	call   80103560 <end_op>
    return -1;
801060de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e3:	eb 18                	jmp    801060fd <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801060e5:	83 ec 0c             	sub    $0xc,%esp
801060e8:	ff 75 f4             	pushl  -0xc(%ebp)
801060eb:	e8 f5 ba ff ff       	call   80101be5 <iunlockput>
801060f0:	83 c4 10             	add    $0x10,%esp
  end_op();
801060f3:	e8 68 d4 ff ff       	call   80103560 <end_op>
  return 0;
801060f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060fd:	c9                   	leave  
801060fe:	c3                   	ret    

801060ff <sys_mknod>:

int
sys_mknod(void)
{
801060ff:	55                   	push   %ebp
80106100:	89 e5                	mov    %esp,%ebp
80106102:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106105:	e8 ca d3 ff ff       	call   801034d4 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010610a:	83 ec 08             	sub    $0x8,%esp
8010610d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106110:	50                   	push   %eax
80106111:	6a 00                	push   $0x0
80106113:	e8 e8 f4 ff ff       	call   80105600 <argstr>
80106118:	83 c4 10             	add    $0x10,%esp
8010611b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010611e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106122:	78 4f                	js     80106173 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106124:	83 ec 08             	sub    $0x8,%esp
80106127:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010612a:	50                   	push   %eax
8010612b:	6a 01                	push   $0x1
8010612d:	e8 49 f4 ff ff       	call   8010557b <argint>
80106132:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106135:	85 c0                	test   %eax,%eax
80106137:	78 3a                	js     80106173 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106139:	83 ec 08             	sub    $0x8,%esp
8010613c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010613f:	50                   	push   %eax
80106140:	6a 02                	push   $0x2
80106142:	e8 34 f4 ff ff       	call   8010557b <argint>
80106147:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010614a:	85 c0                	test   %eax,%eax
8010614c:	78 25                	js     80106173 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010614e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106151:	0f bf c8             	movswl %ax,%ecx
80106154:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106157:	0f bf d0             	movswl %ax,%edx
8010615a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010615d:	51                   	push   %ecx
8010615e:	52                   	push   %edx
8010615f:	6a 03                	push   $0x3
80106161:	50                   	push   %eax
80106162:	e8 c8 fb ff ff       	call   80105d2f <create>
80106167:	83 c4 10             	add    $0x10,%esp
8010616a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010616d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106171:	75 0c                	jne    8010617f <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106173:	e8 e8 d3 ff ff       	call   80103560 <end_op>
    return -1;
80106178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617d:	eb 18                	jmp    80106197 <sys_mknod+0x98>
  }
  iunlockput(ip);
8010617f:	83 ec 0c             	sub    $0xc,%esp
80106182:	ff 75 f0             	pushl  -0x10(%ebp)
80106185:	e8 5b ba ff ff       	call   80101be5 <iunlockput>
8010618a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010618d:	e8 ce d3 ff ff       	call   80103560 <end_op>
  return 0;
80106192:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106197:	c9                   	leave  
80106198:	c3                   	ret    

80106199 <sys_chdir>:

int
sys_chdir(void)
{
80106199:	55                   	push   %ebp
8010619a:	89 e5                	mov    %esp,%ebp
8010619c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010619f:	e8 30 d3 ff ff       	call   801034d4 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801061a4:	83 ec 08             	sub    $0x8,%esp
801061a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061aa:	50                   	push   %eax
801061ab:	6a 00                	push   $0x0
801061ad:	e8 4e f4 ff ff       	call   80105600 <argstr>
801061b2:	83 c4 10             	add    $0x10,%esp
801061b5:	85 c0                	test   %eax,%eax
801061b7:	78 18                	js     801061d1 <sys_chdir+0x38>
801061b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061bc:	83 ec 0c             	sub    $0xc,%esp
801061bf:	50                   	push   %eax
801061c0:	e8 1e c3 ff ff       	call   801024e3 <namei>
801061c5:	83 c4 10             	add    $0x10,%esp
801061c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061cf:	75 0c                	jne    801061dd <sys_chdir+0x44>
    end_op();
801061d1:	e8 8a d3 ff ff       	call   80103560 <end_op>
    return -1;
801061d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061db:	eb 6e                	jmp    8010624b <sys_chdir+0xb2>
  }
  ilock(ip);
801061dd:	83 ec 0c             	sub    $0xc,%esp
801061e0:	ff 75 f4             	pushl  -0xc(%ebp)
801061e3:	e8 43 b7 ff ff       	call   8010192b <ilock>
801061e8:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801061eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ee:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061f2:	66 83 f8 01          	cmp    $0x1,%ax
801061f6:	74 1a                	je     80106212 <sys_chdir+0x79>
    iunlockput(ip);
801061f8:	83 ec 0c             	sub    $0xc,%esp
801061fb:	ff 75 f4             	pushl  -0xc(%ebp)
801061fe:	e8 e2 b9 ff ff       	call   80101be5 <iunlockput>
80106203:	83 c4 10             	add    $0x10,%esp
    end_op();
80106206:	e8 55 d3 ff ff       	call   80103560 <end_op>
    return -1;
8010620b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106210:	eb 39                	jmp    8010624b <sys_chdir+0xb2>
  }
  iunlock(ip);
80106212:	83 ec 0c             	sub    $0xc,%esp
80106215:	ff 75 f4             	pushl  -0xc(%ebp)
80106218:	e8 66 b8 ff ff       	call   80101a83 <iunlock>
8010621d:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106220:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106226:	8b 40 68             	mov    0x68(%eax),%eax
80106229:	83 ec 0c             	sub    $0xc,%esp
8010622c:	50                   	push   %eax
8010622d:	e8 c3 b8 ff ff       	call   80101af5 <iput>
80106232:	83 c4 10             	add    $0x10,%esp
  end_op();
80106235:	e8 26 d3 ff ff       	call   80103560 <end_op>
  proc->cwd = ip;
8010623a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106240:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106243:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106246:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010624b:	c9                   	leave  
8010624c:	c3                   	ret    

8010624d <sys_exec>:

int
sys_exec(void)
{
8010624d:	55                   	push   %ebp
8010624e:	89 e5                	mov    %esp,%ebp
80106250:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106256:	83 ec 08             	sub    $0x8,%esp
80106259:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010625c:	50                   	push   %eax
8010625d:	6a 00                	push   $0x0
8010625f:	e8 9c f3 ff ff       	call   80105600 <argstr>
80106264:	83 c4 10             	add    $0x10,%esp
80106267:	85 c0                	test   %eax,%eax
80106269:	78 18                	js     80106283 <sys_exec+0x36>
8010626b:	83 ec 08             	sub    $0x8,%esp
8010626e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106274:	50                   	push   %eax
80106275:	6a 01                	push   $0x1
80106277:	e8 ff f2 ff ff       	call   8010557b <argint>
8010627c:	83 c4 10             	add    $0x10,%esp
8010627f:	85 c0                	test   %eax,%eax
80106281:	79 0a                	jns    8010628d <sys_exec+0x40>
    return -1;
80106283:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106288:	e9 c6 00 00 00       	jmp    80106353 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010628d:	83 ec 04             	sub    $0x4,%esp
80106290:	68 80 00 00 00       	push   $0x80
80106295:	6a 00                	push   $0x0
80106297:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010629d:	50                   	push   %eax
8010629e:	e8 b3 ef ff ff       	call   80105256 <memset>
801062a3:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801062a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801062ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b0:	83 f8 1f             	cmp    $0x1f,%eax
801062b3:	76 0a                	jbe    801062bf <sys_exec+0x72>
      return -1;
801062b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ba:	e9 94 00 00 00       	jmp    80106353 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801062bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c2:	c1 e0 02             	shl    $0x2,%eax
801062c5:	89 c2                	mov    %eax,%edx
801062c7:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801062cd:	01 c2                	add    %eax,%edx
801062cf:	83 ec 08             	sub    $0x8,%esp
801062d2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801062d8:	50                   	push   %eax
801062d9:	52                   	push   %edx
801062da:	e8 00 f2 ff ff       	call   801054df <fetchint>
801062df:	83 c4 10             	add    $0x10,%esp
801062e2:	85 c0                	test   %eax,%eax
801062e4:	79 07                	jns    801062ed <sys_exec+0xa0>
      return -1;
801062e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062eb:	eb 66                	jmp    80106353 <sys_exec+0x106>
    if(uarg == 0){
801062ed:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801062f3:	85 c0                	test   %eax,%eax
801062f5:	75 27                	jne    8010631e <sys_exec+0xd1>
      argv[i] = 0;
801062f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fa:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106301:	00 00 00 00 
      break;
80106305:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106306:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106309:	83 ec 08             	sub    $0x8,%esp
8010630c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106312:	52                   	push   %edx
80106313:	50                   	push   %eax
80106314:	e8 3d a8 ff ff       	call   80100b56 <exec>
80106319:	83 c4 10             	add    $0x10,%esp
8010631c:	eb 35                	jmp    80106353 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010631e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106324:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106327:	c1 e2 02             	shl    $0x2,%edx
8010632a:	01 c2                	add    %eax,%edx
8010632c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106332:	83 ec 08             	sub    $0x8,%esp
80106335:	52                   	push   %edx
80106336:	50                   	push   %eax
80106337:	e8 dd f1 ff ff       	call   80105519 <fetchstr>
8010633c:	83 c4 10             	add    $0x10,%esp
8010633f:	85 c0                	test   %eax,%eax
80106341:	79 07                	jns    8010634a <sys_exec+0xfd>
      return -1;
80106343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106348:	eb 09                	jmp    80106353 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010634a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010634e:	e9 5a ff ff ff       	jmp    801062ad <sys_exec+0x60>
  return exec(path, argv);
}
80106353:	c9                   	leave  
80106354:	c3                   	ret    

80106355 <sys_pipe>:

int
sys_pipe(void)
{
80106355:	55                   	push   %ebp
80106356:	89 e5                	mov    %esp,%ebp
80106358:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010635b:	83 ec 04             	sub    $0x4,%esp
8010635e:	6a 08                	push   $0x8
80106360:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106363:	50                   	push   %eax
80106364:	6a 00                	push   $0x0
80106366:	e8 38 f2 ff ff       	call   801055a3 <argptr>
8010636b:	83 c4 10             	add    $0x10,%esp
8010636e:	85 c0                	test   %eax,%eax
80106370:	79 0a                	jns    8010637c <sys_pipe+0x27>
    return -1;
80106372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106377:	e9 af 00 00 00       	jmp    8010642b <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
8010637c:	83 ec 08             	sub    $0x8,%esp
8010637f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106382:	50                   	push   %eax
80106383:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106386:	50                   	push   %eax
80106387:	e8 21 dc ff ff       	call   80103fad <pipealloc>
8010638c:	83 c4 10             	add    $0x10,%esp
8010638f:	85 c0                	test   %eax,%eax
80106391:	79 0a                	jns    8010639d <sys_pipe+0x48>
    return -1;
80106393:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106398:	e9 8e 00 00 00       	jmp    8010642b <sys_pipe+0xd6>
  fd0 = -1;
8010639d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801063a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063a7:	83 ec 0c             	sub    $0xc,%esp
801063aa:	50                   	push   %eax
801063ab:	e8 7c f3 ff ff       	call   8010572c <fdalloc>
801063b0:	83 c4 10             	add    $0x10,%esp
801063b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063ba:	78 18                	js     801063d4 <sys_pipe+0x7f>
801063bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063bf:	83 ec 0c             	sub    $0xc,%esp
801063c2:	50                   	push   %eax
801063c3:	e8 64 f3 ff ff       	call   8010572c <fdalloc>
801063c8:	83 c4 10             	add    $0x10,%esp
801063cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063d2:	79 3f                	jns    80106413 <sys_pipe+0xbe>
    if(fd0 >= 0)
801063d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063d8:	78 14                	js     801063ee <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
801063da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063e3:	83 c2 08             	add    $0x8,%edx
801063e6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801063ed:	00 
    fileclose(rf);
801063ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063f1:	83 ec 0c             	sub    $0xc,%esp
801063f4:	50                   	push   %eax
801063f5:	e8 52 ac ff ff       	call   8010104c <fileclose>
801063fa:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801063fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106400:	83 ec 0c             	sub    $0xc,%esp
80106403:	50                   	push   %eax
80106404:	e8 43 ac ff ff       	call   8010104c <fileclose>
80106409:	83 c4 10             	add    $0x10,%esp
    return -1;
8010640c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106411:	eb 18                	jmp    8010642b <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106413:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106416:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106419:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010641b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010641e:	8d 50 04             	lea    0x4(%eax),%edx
80106421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106424:	89 02                	mov    %eax,(%edx)
  return 0;
80106426:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010642b:	c9                   	leave  
8010642c:	c3                   	ret    

8010642d <sys_getprocs>:
#include "proc.h"
#include "uproc.h"

int 
sys_getprocs(void)
{
8010642d:	55                   	push   %ebp
8010642e:	89 e5                	mov    %esp,%ebp
80106430:	53                   	push   %ebx
80106431:	83 ec 24             	sub    $0x24,%esp
80106434:	89 e0                	mov    %esp,%eax
80106436:	89 c3                	mov    %eax,%ebx
int limit;
int val=0;
80106438:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
int pass =1;
8010643f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)


argint(val, &limit);
80106446:	83 ec 08             	sub    $0x8,%esp
80106449:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010644c:	50                   	push   %eax
8010644d:	ff 75 f4             	pushl  -0xc(%ebp)
80106450:	e8 26 f1 ff ff       	call   8010557b <argint>
80106455:	83 c4 10             	add    $0x10,%esp
struct uproc *table[limit];
80106458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010645b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010645e:	89 55 ec             	mov    %edx,-0x14(%ebp)
80106461:	c1 e0 02             	shl    $0x2,%eax
80106464:	8d 50 03             	lea    0x3(%eax),%edx
80106467:	b8 10 00 00 00       	mov    $0x10,%eax
8010646c:	83 e8 01             	sub    $0x1,%eax
8010646f:	01 d0                	add    %edx,%eax
80106471:	b9 10 00 00 00       	mov    $0x10,%ecx
80106476:	ba 00 00 00 00       	mov    $0x0,%edx
8010647b:	f7 f1                	div    %ecx
8010647d:	6b c0 10             	imul   $0x10,%eax,%eax
80106480:	29 c4                	sub    %eax,%esp
80106482:	89 e0                	mov    %esp,%eax
80106484:	83 c0 03             	add    $0x3,%eax
80106487:	c1 e8 02             	shr    $0x2,%eax
8010648a:	c1 e0 02             	shl    $0x2,%eax
8010648d:	89 45 e8             	mov    %eax,-0x18(%ebp)
argptr(pass,(void*)&table,sizeof(*table));
80106490:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106493:	83 ec 04             	sub    $0x4,%esp
80106496:	6a 04                	push   $0x4
80106498:	50                   	push   %eax
80106499:	ff 75 f0             	pushl  -0x10(%ebp)
8010649c:	e8 02 f1 ff ff       	call   801055a3 <argptr>
801064a1:	83 c4 10             	add    $0x10,%esp
val= numprocs(*table);
801064a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064a7:	8b 00                	mov    (%eax),%eax
801064a9:	83 ec 0c             	sub    $0xc,%esp
801064ac:	50                   	push   %eax
801064ad:	e8 0f df ff ff       	call   801043c1 <numprocs>
801064b2:	83 c4 10             	add    $0x10,%esp
801064b5:	89 45 f4             	mov    %eax,-0xc(%ebp)

return (val);
801064b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bb:	89 dc                	mov    %ebx,%esp
}
801064bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801064c0:	c9                   	leave  
801064c1:	c3                   	ret    

801064c2 <sys_fork>:


int
sys_fork(void)
{
801064c2:	55                   	push   %ebp
801064c3:	89 e5                	mov    %esp,%ebp
801064c5:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064c8:	e8 73 e2 ff ff       	call   80104740 <fork>
}
801064cd:	c9                   	leave  
801064ce:	c3                   	ret    

801064cf <sys_exit>:

int
sys_exit(void)
{
801064cf:	55                   	push   %ebp
801064d0:	89 e5                	mov    %esp,%ebp
801064d2:	83 ec 08             	sub    $0x8,%esp
  exit();
801064d5:	e8 f7 e3 ff ff       	call   801048d1 <exit>
  return 0;  
801064da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064df:	c9                   	leave  
801064e0:	c3                   	ret    

801064e1 <sys_wait>:

int
sys_wait(void)
{
801064e1:	55                   	push   %ebp
801064e2:	89 e5                	mov    %esp,%ebp
801064e4:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064e7:	e8 1d e5 ff ff       	call   80104a09 <wait>
}
801064ec:	c9                   	leave  
801064ed:	c3                   	ret    

801064ee <sys_kill>:

int
sys_kill(void)
{
801064ee:	55                   	push   %ebp
801064ef:	89 e5                	mov    %esp,%ebp
801064f1:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064f4:	83 ec 08             	sub    $0x8,%esp
801064f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064fa:	50                   	push   %eax
801064fb:	6a 00                	push   $0x0
801064fd:	e8 79 f0 ff ff       	call   8010557b <argint>
80106502:	83 c4 10             	add    $0x10,%esp
80106505:	85 c0                	test   %eax,%eax
80106507:	79 07                	jns    80106510 <sys_kill+0x22>
    return -1;
80106509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650e:	eb 0f                	jmp    8010651f <sys_kill+0x31>
  return kill(pid);
80106510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106513:	83 ec 0c             	sub    $0xc,%esp
80106516:	50                   	push   %eax
80106517:	e8 00 e9 ff ff       	call   80104e1c <kill>
8010651c:	83 c4 10             	add    $0x10,%esp
}
8010651f:	c9                   	leave  
80106520:	c3                   	ret    

80106521 <sys_getpid>:

int
sys_getpid(void)
{
80106521:	55                   	push   %ebp
80106522:	89 e5                	mov    %esp,%ebp
80106524:	83 ec 10             	sub    $0x10,%esp
    int val = proc->pid;
80106527:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652d:	8b 40 10             	mov    0x10(%eax),%eax
80106530:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return  val;
80106533:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106536:	c9                   	leave  
80106537:	c3                   	ret    

80106538 <sys_sbrk>:

int
sys_sbrk(void)
{
80106538:	55                   	push   %ebp
80106539:	89 e5                	mov    %esp,%ebp
8010653b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010653e:	83 ec 08             	sub    $0x8,%esp
80106541:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106544:	50                   	push   %eax
80106545:	6a 00                	push   $0x0
80106547:	e8 2f f0 ff ff       	call   8010557b <argint>
8010654c:	83 c4 10             	add    $0x10,%esp
8010654f:	85 c0                	test   %eax,%eax
80106551:	79 07                	jns    8010655a <sys_sbrk+0x22>
    return -1;
80106553:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106558:	eb 28                	jmp    80106582 <sys_sbrk+0x4a>
  addr = proc->sz;
8010655a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106560:	8b 00                	mov    (%eax),%eax
80106562:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106565:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106568:	83 ec 0c             	sub    $0xc,%esp
8010656b:	50                   	push   %eax
8010656c:	e8 2c e1 ff ff       	call   8010469d <growproc>
80106571:	83 c4 10             	add    $0x10,%esp
80106574:	85 c0                	test   %eax,%eax
80106576:	79 07                	jns    8010657f <sys_sbrk+0x47>
    return -1;
80106578:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010657d:	eb 03                	jmp    80106582 <sys_sbrk+0x4a>
  return addr;
8010657f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106582:	c9                   	leave  
80106583:	c3                   	ret    

80106584 <sys_sleep>:

int
sys_sleep(void)
{
80106584:	55                   	push   %ebp
80106585:	89 e5                	mov    %esp,%ebp
80106587:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010658a:	83 ec 08             	sub    $0x8,%esp
8010658d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106590:	50                   	push   %eax
80106591:	6a 00                	push   $0x0
80106593:	e8 e3 ef ff ff       	call   8010557b <argint>
80106598:	83 c4 10             	add    $0x10,%esp
8010659b:	85 c0                	test   %eax,%eax
8010659d:	79 07                	jns    801065a6 <sys_sleep+0x22>
    return -1;
8010659f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a4:	eb 77                	jmp    8010661d <sys_sleep+0x99>
  acquire(&tickslock);
801065a6:	83 ec 0c             	sub    $0xc,%esp
801065a9:	68 a0 48 11 80       	push   $0x801148a0
801065ae:	e8 40 ea ff ff       	call   80104ff3 <acquire>
801065b3:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065b6:	a1 e0 50 11 80       	mov    0x801150e0,%eax
801065bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065be:	eb 39                	jmp    801065f9 <sys_sleep+0x75>
    if(proc->killed){
801065c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065c6:	8b 40 24             	mov    0x24(%eax),%eax
801065c9:	85 c0                	test   %eax,%eax
801065cb:	74 17                	je     801065e4 <sys_sleep+0x60>
      release(&tickslock);
801065cd:	83 ec 0c             	sub    $0xc,%esp
801065d0:	68 a0 48 11 80       	push   $0x801148a0
801065d5:	e8 80 ea ff ff       	call   8010505a <release>
801065da:	83 c4 10             	add    $0x10,%esp
      return -1;
801065dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e2:	eb 39                	jmp    8010661d <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801065e4:	83 ec 08             	sub    $0x8,%esp
801065e7:	68 a0 48 11 80       	push   $0x801148a0
801065ec:	68 e0 50 11 80       	push   $0x801150e0
801065f1:	e8 04 e7 ff ff       	call   80104cfa <sleep>
801065f6:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801065f9:	a1 e0 50 11 80       	mov    0x801150e0,%eax
801065fe:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106601:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106604:	39 d0                	cmp    %edx,%eax
80106606:	72 b8                	jb     801065c0 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106608:	83 ec 0c             	sub    $0xc,%esp
8010660b:	68 a0 48 11 80       	push   $0x801148a0
80106610:	e8 45 ea ff ff       	call   8010505a <release>
80106615:	83 c4 10             	add    $0x10,%esp
  return 0;
80106618:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010661d:	c9                   	leave  
8010661e:	c3                   	ret    

8010661f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010661f:	55                   	push   %ebp
80106620:	89 e5                	mov    %esp,%ebp
80106622:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106625:	83 ec 0c             	sub    $0xc,%esp
80106628:	68 a0 48 11 80       	push   $0x801148a0
8010662d:	e8 c1 e9 ff ff       	call   80104ff3 <acquire>
80106632:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106635:	a1 e0 50 11 80       	mov    0x801150e0,%eax
8010663a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010663d:	83 ec 0c             	sub    $0xc,%esp
80106640:	68 a0 48 11 80       	push   $0x801148a0
80106645:	e8 10 ea ff ff       	call   8010505a <release>
8010664a:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010664d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106650:	c9                   	leave  
80106651:	c3                   	ret    

80106652 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106652:	55                   	push   %ebp
80106653:	89 e5                	mov    %esp,%ebp
80106655:	83 ec 08             	sub    $0x8,%esp
80106658:	8b 55 08             	mov    0x8(%ebp),%edx
8010665b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010665e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106662:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106665:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106669:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010666d:	ee                   	out    %al,(%dx)
}
8010666e:	90                   	nop
8010666f:	c9                   	leave  
80106670:	c3                   	ret    

80106671 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106671:	55                   	push   %ebp
80106672:	89 e5                	mov    %esp,%ebp
80106674:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106677:	6a 34                	push   $0x34
80106679:	6a 43                	push   $0x43
8010667b:	e8 d2 ff ff ff       	call   80106652 <outb>
80106680:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106683:	68 9c 00 00 00       	push   $0x9c
80106688:	6a 40                	push   $0x40
8010668a:	e8 c3 ff ff ff       	call   80106652 <outb>
8010668f:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106692:	6a 2e                	push   $0x2e
80106694:	6a 40                	push   $0x40
80106696:	e8 b7 ff ff ff       	call   80106652 <outb>
8010669b:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
8010669e:	83 ec 0c             	sub    $0xc,%esp
801066a1:	6a 00                	push   $0x0
801066a3:	e8 ef d7 ff ff       	call   80103e97 <picenable>
801066a8:	83 c4 10             	add    $0x10,%esp
}
801066ab:	90                   	nop
801066ac:	c9                   	leave  
801066ad:	c3                   	ret    

801066ae <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801066ae:	1e                   	push   %ds
  pushl %es
801066af:	06                   	push   %es
  pushl %fs
801066b0:	0f a0                	push   %fs
  pushl %gs
801066b2:	0f a8                	push   %gs
  pushal
801066b4:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801066b5:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801066b9:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801066bb:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801066bd:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801066c1:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801066c3:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801066c5:	54                   	push   %esp
  call trap
801066c6:	e8 d7 01 00 00       	call   801068a2 <trap>
  addl $4, %esp
801066cb:	83 c4 04             	add    $0x4,%esp

801066ce <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801066ce:	61                   	popa   
  popl %gs
801066cf:	0f a9                	pop    %gs
  popl %fs
801066d1:	0f a1                	pop    %fs
  popl %es
801066d3:	07                   	pop    %es
  popl %ds
801066d4:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801066d5:	83 c4 08             	add    $0x8,%esp
  iret
801066d8:	cf                   	iret   

801066d9 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801066d9:	55                   	push   %ebp
801066da:	89 e5                	mov    %esp,%ebp
801066dc:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801066df:	8b 45 0c             	mov    0xc(%ebp),%eax
801066e2:	83 e8 01             	sub    $0x1,%eax
801066e5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801066e9:	8b 45 08             	mov    0x8(%ebp),%eax
801066ec:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066f0:	8b 45 08             	mov    0x8(%ebp),%eax
801066f3:	c1 e8 10             	shr    $0x10,%eax
801066f6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801066fa:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066fd:	0f 01 18             	lidtl  (%eax)
}
80106700:	90                   	nop
80106701:	c9                   	leave  
80106702:	c3                   	ret    

80106703 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106703:	55                   	push   %ebp
80106704:	89 e5                	mov    %esp,%ebp
80106706:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106709:	0f 20 d0             	mov    %cr2,%eax
8010670c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010670f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106712:	c9                   	leave  
80106713:	c3                   	ret    

80106714 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106714:	55                   	push   %ebp
80106715:	89 e5                	mov    %esp,%ebp
80106717:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010671a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106721:	e9 c3 00 00 00       	jmp    801067e9 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106729:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106730:	89 c2                	mov    %eax,%edx
80106732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106735:	66 89 14 c5 e0 48 11 	mov    %dx,-0x7feeb720(,%eax,8)
8010673c:	80 
8010673d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106740:	66 c7 04 c5 e2 48 11 	movw   $0x8,-0x7feeb71e(,%eax,8)
80106747:	80 08 00 
8010674a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674d:	0f b6 14 c5 e4 48 11 	movzbl -0x7feeb71c(,%eax,8),%edx
80106754:	80 
80106755:	83 e2 e0             	and    $0xffffffe0,%edx
80106758:	88 14 c5 e4 48 11 80 	mov    %dl,-0x7feeb71c(,%eax,8)
8010675f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106762:	0f b6 14 c5 e4 48 11 	movzbl -0x7feeb71c(,%eax,8),%edx
80106769:	80 
8010676a:	83 e2 1f             	and    $0x1f,%edx
8010676d:	88 14 c5 e4 48 11 80 	mov    %dl,-0x7feeb71c(,%eax,8)
80106774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106777:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
8010677e:	80 
8010677f:	83 e2 f0             	and    $0xfffffff0,%edx
80106782:	83 ca 0e             	or     $0xe,%edx
80106785:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
8010678c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678f:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
80106796:	80 
80106797:	83 e2 ef             	and    $0xffffffef,%edx
8010679a:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801067a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a4:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801067ab:	80 
801067ac:	83 e2 9f             	and    $0xffffff9f,%edx
801067af:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801067b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b9:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801067c0:	80 
801067c1:	83 ca 80             	or     $0xffffff80,%edx
801067c4:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801067cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ce:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
801067d5:	c1 e8 10             	shr    $0x10,%eax
801067d8:	89 c2                	mov    %eax,%edx
801067da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067dd:	66 89 14 c5 e6 48 11 	mov    %dx,-0x7feeb71a(,%eax,8)
801067e4:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801067e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067e9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067f0:	0f 8e 30 ff ff ff    	jle    80106726 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067f6:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801067fb:	66 a3 e0 4a 11 80    	mov    %ax,0x80114ae0
80106801:	66 c7 05 e2 4a 11 80 	movw   $0x8,0x80114ae2
80106808:	08 00 
8010680a:	0f b6 05 e4 4a 11 80 	movzbl 0x80114ae4,%eax
80106811:	83 e0 e0             	and    $0xffffffe0,%eax
80106814:	a2 e4 4a 11 80       	mov    %al,0x80114ae4
80106819:	0f b6 05 e4 4a 11 80 	movzbl 0x80114ae4,%eax
80106820:	83 e0 1f             	and    $0x1f,%eax
80106823:	a2 e4 4a 11 80       	mov    %al,0x80114ae4
80106828:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
8010682f:	83 c8 0f             	or     $0xf,%eax
80106832:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106837:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
8010683e:	83 e0 ef             	and    $0xffffffef,%eax
80106841:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106846:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
8010684d:	83 c8 60             	or     $0x60,%eax
80106850:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106855:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
8010685c:	83 c8 80             	or     $0xffffff80,%eax
8010685f:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106864:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106869:	c1 e8 10             	shr    $0x10,%eax
8010686c:	66 a3 e6 4a 11 80    	mov    %ax,0x80114ae6
  
  initlock(&tickslock, "time");
80106872:	83 ec 08             	sub    $0x8,%esp
80106875:	68 10 8a 10 80       	push   $0x80108a10
8010687a:	68 a0 48 11 80       	push   $0x801148a0
8010687f:	e8 4d e7 ff ff       	call   80104fd1 <initlock>
80106884:	83 c4 10             	add    $0x10,%esp
}
80106887:	90                   	nop
80106888:	c9                   	leave  
80106889:	c3                   	ret    

8010688a <idtinit>:

void
idtinit(void)
{
8010688a:	55                   	push   %ebp
8010688b:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010688d:	68 00 08 00 00       	push   $0x800
80106892:	68 e0 48 11 80       	push   $0x801148e0
80106897:	e8 3d fe ff ff       	call   801066d9 <lidt>
8010689c:	83 c4 08             	add    $0x8,%esp
}
8010689f:	90                   	nop
801068a0:	c9                   	leave  
801068a1:	c3                   	ret    

801068a2 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801068a2:	55                   	push   %ebp
801068a3:	89 e5                	mov    %esp,%ebp
801068a5:	57                   	push   %edi
801068a6:	56                   	push   %esi
801068a7:	53                   	push   %ebx
801068a8:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801068ab:	8b 45 08             	mov    0x8(%ebp),%eax
801068ae:	8b 40 30             	mov    0x30(%eax),%eax
801068b1:	83 f8 40             	cmp    $0x40,%eax
801068b4:	75 3e                	jne    801068f4 <trap+0x52>
    if(proc->killed)
801068b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068bc:	8b 40 24             	mov    0x24(%eax),%eax
801068bf:	85 c0                	test   %eax,%eax
801068c1:	74 05                	je     801068c8 <trap+0x26>
      exit();
801068c3:	e8 09 e0 ff ff       	call   801048d1 <exit>
    proc->tf = tf;
801068c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068ce:	8b 55 08             	mov    0x8(%ebp),%edx
801068d1:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801068d4:	e8 58 ed ff ff       	call   80105631 <syscall>
    if(proc->killed)
801068d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068df:	8b 40 24             	mov    0x24(%eax),%eax
801068e2:	85 c0                	test   %eax,%eax
801068e4:	0f 84 1b 02 00 00    	je     80106b05 <trap+0x263>
      exit();
801068ea:	e8 e2 df ff ff       	call   801048d1 <exit>
    return;
801068ef:	e9 11 02 00 00       	jmp    80106b05 <trap+0x263>
  }

  switch(tf->trapno){
801068f4:	8b 45 08             	mov    0x8(%ebp),%eax
801068f7:	8b 40 30             	mov    0x30(%eax),%eax
801068fa:	83 e8 20             	sub    $0x20,%eax
801068fd:	83 f8 1f             	cmp    $0x1f,%eax
80106900:	0f 87 c0 00 00 00    	ja     801069c6 <trap+0x124>
80106906:	8b 04 85 b8 8a 10 80 	mov    -0x7fef7548(,%eax,4),%eax
8010690d:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010690f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106915:	0f b6 00             	movzbl (%eax),%eax
80106918:	84 c0                	test   %al,%al
8010691a:	75 3d                	jne    80106959 <trap+0xb7>
      acquire(&tickslock);
8010691c:	83 ec 0c             	sub    $0xc,%esp
8010691f:	68 a0 48 11 80       	push   $0x801148a0
80106924:	e8 ca e6 ff ff       	call   80104ff3 <acquire>
80106929:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010692c:	a1 e0 50 11 80       	mov    0x801150e0,%eax
80106931:	83 c0 01             	add    $0x1,%eax
80106934:	a3 e0 50 11 80       	mov    %eax,0x801150e0
      wakeup(&ticks);
80106939:	83 ec 0c             	sub    $0xc,%esp
8010693c:	68 e0 50 11 80       	push   $0x801150e0
80106941:	e8 9f e4 ff ff       	call   80104de5 <wakeup>
80106946:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106949:	83 ec 0c             	sub    $0xc,%esp
8010694c:	68 a0 48 11 80       	push   $0x801148a0
80106951:	e8 04 e7 ff ff       	call   8010505a <release>
80106956:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106959:	e8 46 c6 ff ff       	call   80102fa4 <lapiceoi>
    break;
8010695e:	e9 1c 01 00 00       	jmp    80106a7f <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106963:	e8 4f be ff ff       	call   801027b7 <ideintr>
    lapiceoi();
80106968:	e8 37 c6 ff ff       	call   80102fa4 <lapiceoi>
    break;
8010696d:	e9 0d 01 00 00       	jmp    80106a7f <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106972:	e8 2f c4 ff ff       	call   80102da6 <kbdintr>
    lapiceoi();
80106977:	e8 28 c6 ff ff       	call   80102fa4 <lapiceoi>
    break;
8010697c:	e9 fe 00 00 00       	jmp    80106a7f <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106981:	e8 60 03 00 00       	call   80106ce6 <uartintr>
    lapiceoi();
80106986:	e8 19 c6 ff ff       	call   80102fa4 <lapiceoi>
    break;
8010698b:	e9 ef 00 00 00       	jmp    80106a7f <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106990:	8b 45 08             	mov    0x8(%ebp),%eax
80106993:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106996:	8b 45 08             	mov    0x8(%ebp),%eax
80106999:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010699d:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801069a0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069a6:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069a9:	0f b6 c0             	movzbl %al,%eax
801069ac:	51                   	push   %ecx
801069ad:	52                   	push   %edx
801069ae:	50                   	push   %eax
801069af:	68 18 8a 10 80       	push   $0x80108a18
801069b4:	e8 0d 9a ff ff       	call   801003c6 <cprintf>
801069b9:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801069bc:	e8 e3 c5 ff ff       	call   80102fa4 <lapiceoi>
    break;
801069c1:	e9 b9 00 00 00       	jmp    80106a7f <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801069c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069cc:	85 c0                	test   %eax,%eax
801069ce:	74 11                	je     801069e1 <trap+0x13f>
801069d0:	8b 45 08             	mov    0x8(%ebp),%eax
801069d3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069d7:	0f b7 c0             	movzwl %ax,%eax
801069da:	83 e0 03             	and    $0x3,%eax
801069dd:	85 c0                	test   %eax,%eax
801069df:	75 40                	jne    80106a21 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069e1:	e8 1d fd ff ff       	call   80106703 <rcr2>
801069e6:	89 c3                	mov    %eax,%ebx
801069e8:	8b 45 08             	mov    0x8(%ebp),%eax
801069eb:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801069ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069f4:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069f7:	0f b6 d0             	movzbl %al,%edx
801069fa:	8b 45 08             	mov    0x8(%ebp),%eax
801069fd:	8b 40 30             	mov    0x30(%eax),%eax
80106a00:	83 ec 0c             	sub    $0xc,%esp
80106a03:	53                   	push   %ebx
80106a04:	51                   	push   %ecx
80106a05:	52                   	push   %edx
80106a06:	50                   	push   %eax
80106a07:	68 3c 8a 10 80       	push   $0x80108a3c
80106a0c:	e8 b5 99 ff ff       	call   801003c6 <cprintf>
80106a11:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106a14:	83 ec 0c             	sub    $0xc,%esp
80106a17:	68 6e 8a 10 80       	push   $0x80108a6e
80106a1c:	e8 45 9b ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a21:	e8 dd fc ff ff       	call   80106703 <rcr2>
80106a26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a29:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2c:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a2f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a35:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a38:	0f b6 d8             	movzbl %al,%ebx
80106a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a3e:	8b 48 34             	mov    0x34(%eax),%ecx
80106a41:	8b 45 08             	mov    0x8(%ebp),%eax
80106a44:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a4d:	8d 78 6c             	lea    0x6c(%eax),%edi
80106a50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a56:	8b 40 10             	mov    0x10(%eax),%eax
80106a59:	ff 75 e4             	pushl  -0x1c(%ebp)
80106a5c:	56                   	push   %esi
80106a5d:	53                   	push   %ebx
80106a5e:	51                   	push   %ecx
80106a5f:	52                   	push   %edx
80106a60:	57                   	push   %edi
80106a61:	50                   	push   %eax
80106a62:	68 74 8a 10 80       	push   $0x80108a74
80106a67:	e8 5a 99 ff ff       	call   801003c6 <cprintf>
80106a6c:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106a6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a75:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a7c:	eb 01                	jmp    80106a7f <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a7e:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a85:	85 c0                	test   %eax,%eax
80106a87:	74 24                	je     80106aad <trap+0x20b>
80106a89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a8f:	8b 40 24             	mov    0x24(%eax),%eax
80106a92:	85 c0                	test   %eax,%eax
80106a94:	74 17                	je     80106aad <trap+0x20b>
80106a96:	8b 45 08             	mov    0x8(%ebp),%eax
80106a99:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a9d:	0f b7 c0             	movzwl %ax,%eax
80106aa0:	83 e0 03             	and    $0x3,%eax
80106aa3:	83 f8 03             	cmp    $0x3,%eax
80106aa6:	75 05                	jne    80106aad <trap+0x20b>
    exit();
80106aa8:	e8 24 de ff ff       	call   801048d1 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106aad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab3:	85 c0                	test   %eax,%eax
80106ab5:	74 1e                	je     80106ad5 <trap+0x233>
80106ab7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106abd:	8b 40 0c             	mov    0xc(%eax),%eax
80106ac0:	83 f8 04             	cmp    $0x4,%eax
80106ac3:	75 10                	jne    80106ad5 <trap+0x233>
80106ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac8:	8b 40 30             	mov    0x30(%eax),%eax
80106acb:	83 f8 20             	cmp    $0x20,%eax
80106ace:	75 05                	jne    80106ad5 <trap+0x233>
    yield();
80106ad0:	e8 b9 e1 ff ff       	call   80104c8e <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ad5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106adb:	85 c0                	test   %eax,%eax
80106add:	74 27                	je     80106b06 <trap+0x264>
80106adf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ae5:	8b 40 24             	mov    0x24(%eax),%eax
80106ae8:	85 c0                	test   %eax,%eax
80106aea:	74 1a                	je     80106b06 <trap+0x264>
80106aec:	8b 45 08             	mov    0x8(%ebp),%eax
80106aef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106af3:	0f b7 c0             	movzwl %ax,%eax
80106af6:	83 e0 03             	and    $0x3,%eax
80106af9:	83 f8 03             	cmp    $0x3,%eax
80106afc:	75 08                	jne    80106b06 <trap+0x264>
    exit();
80106afe:	e8 ce dd ff ff       	call   801048d1 <exit>
80106b03:	eb 01                	jmp    80106b06 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106b05:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b09:	5b                   	pop    %ebx
80106b0a:	5e                   	pop    %esi
80106b0b:	5f                   	pop    %edi
80106b0c:	5d                   	pop    %ebp
80106b0d:	c3                   	ret    

80106b0e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106b0e:	55                   	push   %ebp
80106b0f:	89 e5                	mov    %esp,%ebp
80106b11:	83 ec 14             	sub    $0x14,%esp
80106b14:	8b 45 08             	mov    0x8(%ebp),%eax
80106b17:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b1b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b1f:	89 c2                	mov    %eax,%edx
80106b21:	ec                   	in     (%dx),%al
80106b22:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b25:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b29:	c9                   	leave  
80106b2a:	c3                   	ret    

80106b2b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b2b:	55                   	push   %ebp
80106b2c:	89 e5                	mov    %esp,%ebp
80106b2e:	83 ec 08             	sub    $0x8,%esp
80106b31:	8b 55 08             	mov    0x8(%ebp),%edx
80106b34:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b37:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b3b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b3e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b42:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b46:	ee                   	out    %al,(%dx)
}
80106b47:	90                   	nop
80106b48:	c9                   	leave  
80106b49:	c3                   	ret    

80106b4a <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b4a:	55                   	push   %ebp
80106b4b:	89 e5                	mov    %esp,%ebp
80106b4d:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b50:	6a 00                	push   $0x0
80106b52:	68 fa 03 00 00       	push   $0x3fa
80106b57:	e8 cf ff ff ff       	call   80106b2b <outb>
80106b5c:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b5f:	68 80 00 00 00       	push   $0x80
80106b64:	68 fb 03 00 00       	push   $0x3fb
80106b69:	e8 bd ff ff ff       	call   80106b2b <outb>
80106b6e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106b71:	6a 0c                	push   $0xc
80106b73:	68 f8 03 00 00       	push   $0x3f8
80106b78:	e8 ae ff ff ff       	call   80106b2b <outb>
80106b7d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b80:	6a 00                	push   $0x0
80106b82:	68 f9 03 00 00       	push   $0x3f9
80106b87:	e8 9f ff ff ff       	call   80106b2b <outb>
80106b8c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b8f:	6a 03                	push   $0x3
80106b91:	68 fb 03 00 00       	push   $0x3fb
80106b96:	e8 90 ff ff ff       	call   80106b2b <outb>
80106b9b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106b9e:	6a 00                	push   $0x0
80106ba0:	68 fc 03 00 00       	push   $0x3fc
80106ba5:	e8 81 ff ff ff       	call   80106b2b <outb>
80106baa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106bad:	6a 01                	push   $0x1
80106baf:	68 f9 03 00 00       	push   $0x3f9
80106bb4:	e8 72 ff ff ff       	call   80106b2b <outb>
80106bb9:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bbc:	68 fd 03 00 00       	push   $0x3fd
80106bc1:	e8 48 ff ff ff       	call   80106b0e <inb>
80106bc6:	83 c4 04             	add    $0x4,%esp
80106bc9:	3c ff                	cmp    $0xff,%al
80106bcb:	74 6e                	je     80106c3b <uartinit+0xf1>
    return;
  uart = 1;
80106bcd:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106bd4:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bd7:	68 fa 03 00 00       	push   $0x3fa
80106bdc:	e8 2d ff ff ff       	call   80106b0e <inb>
80106be1:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106be4:	68 f8 03 00 00       	push   $0x3f8
80106be9:	e8 20 ff ff ff       	call   80106b0e <inb>
80106bee:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106bf1:	83 ec 0c             	sub    $0xc,%esp
80106bf4:	6a 04                	push   $0x4
80106bf6:	e8 9c d2 ff ff       	call   80103e97 <picenable>
80106bfb:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106bfe:	83 ec 08             	sub    $0x8,%esp
80106c01:	6a 00                	push   $0x0
80106c03:	6a 04                	push   $0x4
80106c05:	e8 4f be ff ff       	call   80102a59 <ioapicenable>
80106c0a:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c0d:	c7 45 f4 38 8b 10 80 	movl   $0x80108b38,-0xc(%ebp)
80106c14:	eb 19                	jmp    80106c2f <uartinit+0xe5>
    uartputc(*p);
80106c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c19:	0f b6 00             	movzbl (%eax),%eax
80106c1c:	0f be c0             	movsbl %al,%eax
80106c1f:	83 ec 0c             	sub    $0xc,%esp
80106c22:	50                   	push   %eax
80106c23:	e8 16 00 00 00       	call   80106c3e <uartputc>
80106c28:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c32:	0f b6 00             	movzbl (%eax),%eax
80106c35:	84 c0                	test   %al,%al
80106c37:	75 dd                	jne    80106c16 <uartinit+0xcc>
80106c39:	eb 01                	jmp    80106c3c <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106c3b:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106c3c:	c9                   	leave  
80106c3d:	c3                   	ret    

80106c3e <uartputc>:

void
uartputc(int c)
{
80106c3e:	55                   	push   %ebp
80106c3f:	89 e5                	mov    %esp,%ebp
80106c41:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c44:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106c49:	85 c0                	test   %eax,%eax
80106c4b:	74 53                	je     80106ca0 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c54:	eb 11                	jmp    80106c67 <uartputc+0x29>
    microdelay(10);
80106c56:	83 ec 0c             	sub    $0xc,%esp
80106c59:	6a 0a                	push   $0xa
80106c5b:	e8 5f c3 ff ff       	call   80102fbf <microdelay>
80106c60:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c67:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c6b:	7f 1a                	jg     80106c87 <uartputc+0x49>
80106c6d:	83 ec 0c             	sub    $0xc,%esp
80106c70:	68 fd 03 00 00       	push   $0x3fd
80106c75:	e8 94 fe ff ff       	call   80106b0e <inb>
80106c7a:	83 c4 10             	add    $0x10,%esp
80106c7d:	0f b6 c0             	movzbl %al,%eax
80106c80:	83 e0 20             	and    $0x20,%eax
80106c83:	85 c0                	test   %eax,%eax
80106c85:	74 cf                	je     80106c56 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106c87:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8a:	0f b6 c0             	movzbl %al,%eax
80106c8d:	83 ec 08             	sub    $0x8,%esp
80106c90:	50                   	push   %eax
80106c91:	68 f8 03 00 00       	push   $0x3f8
80106c96:	e8 90 fe ff ff       	call   80106b2b <outb>
80106c9b:	83 c4 10             	add    $0x10,%esp
80106c9e:	eb 01                	jmp    80106ca1 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106ca0:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106ca1:	c9                   	leave  
80106ca2:	c3                   	ret    

80106ca3 <uartgetc>:

static int
uartgetc(void)
{
80106ca3:	55                   	push   %ebp
80106ca4:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106ca6:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106cab:	85 c0                	test   %eax,%eax
80106cad:	75 07                	jne    80106cb6 <uartgetc+0x13>
    return -1;
80106caf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cb4:	eb 2e                	jmp    80106ce4 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106cb6:	68 fd 03 00 00       	push   $0x3fd
80106cbb:	e8 4e fe ff ff       	call   80106b0e <inb>
80106cc0:	83 c4 04             	add    $0x4,%esp
80106cc3:	0f b6 c0             	movzbl %al,%eax
80106cc6:	83 e0 01             	and    $0x1,%eax
80106cc9:	85 c0                	test   %eax,%eax
80106ccb:	75 07                	jne    80106cd4 <uartgetc+0x31>
    return -1;
80106ccd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cd2:	eb 10                	jmp    80106ce4 <uartgetc+0x41>
  return inb(COM1+0);
80106cd4:	68 f8 03 00 00       	push   $0x3f8
80106cd9:	e8 30 fe ff ff       	call   80106b0e <inb>
80106cde:	83 c4 04             	add    $0x4,%esp
80106ce1:	0f b6 c0             	movzbl %al,%eax
}
80106ce4:	c9                   	leave  
80106ce5:	c3                   	ret    

80106ce6 <uartintr>:

void
uartintr(void)
{
80106ce6:	55                   	push   %ebp
80106ce7:	89 e5                	mov    %esp,%ebp
80106ce9:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106cec:	83 ec 0c             	sub    $0xc,%esp
80106cef:	68 a3 6c 10 80       	push   $0x80106ca3
80106cf4:	e8 e4 9a ff ff       	call   801007dd <consoleintr>
80106cf9:	83 c4 10             	add    $0x10,%esp
}
80106cfc:	90                   	nop
80106cfd:	c9                   	leave  
80106cfe:	c3                   	ret    

80106cff <vector0>:
80106cff:	6a 00                	push   $0x0
80106d01:	6a 00                	push   $0x0
80106d03:	e9 a6 f9 ff ff       	jmp    801066ae <alltraps>

80106d08 <vector1>:
80106d08:	6a 00                	push   $0x0
80106d0a:	6a 01                	push   $0x1
80106d0c:	e9 9d f9 ff ff       	jmp    801066ae <alltraps>

80106d11 <vector2>:
80106d11:	6a 00                	push   $0x0
80106d13:	6a 02                	push   $0x2
80106d15:	e9 94 f9 ff ff       	jmp    801066ae <alltraps>

80106d1a <vector3>:
80106d1a:	6a 00                	push   $0x0
80106d1c:	6a 03                	push   $0x3
80106d1e:	e9 8b f9 ff ff       	jmp    801066ae <alltraps>

80106d23 <vector4>:
80106d23:	6a 00                	push   $0x0
80106d25:	6a 04                	push   $0x4
80106d27:	e9 82 f9 ff ff       	jmp    801066ae <alltraps>

80106d2c <vector5>:
80106d2c:	6a 00                	push   $0x0
80106d2e:	6a 05                	push   $0x5
80106d30:	e9 79 f9 ff ff       	jmp    801066ae <alltraps>

80106d35 <vector6>:
80106d35:	6a 00                	push   $0x0
80106d37:	6a 06                	push   $0x6
80106d39:	e9 70 f9 ff ff       	jmp    801066ae <alltraps>

80106d3e <vector7>:
80106d3e:	6a 00                	push   $0x0
80106d40:	6a 07                	push   $0x7
80106d42:	e9 67 f9 ff ff       	jmp    801066ae <alltraps>

80106d47 <vector8>:
80106d47:	6a 08                	push   $0x8
80106d49:	e9 60 f9 ff ff       	jmp    801066ae <alltraps>

80106d4e <vector9>:
80106d4e:	6a 00                	push   $0x0
80106d50:	6a 09                	push   $0x9
80106d52:	e9 57 f9 ff ff       	jmp    801066ae <alltraps>

80106d57 <vector10>:
80106d57:	6a 0a                	push   $0xa
80106d59:	e9 50 f9 ff ff       	jmp    801066ae <alltraps>

80106d5e <vector11>:
80106d5e:	6a 0b                	push   $0xb
80106d60:	e9 49 f9 ff ff       	jmp    801066ae <alltraps>

80106d65 <vector12>:
80106d65:	6a 0c                	push   $0xc
80106d67:	e9 42 f9 ff ff       	jmp    801066ae <alltraps>

80106d6c <vector13>:
80106d6c:	6a 0d                	push   $0xd
80106d6e:	e9 3b f9 ff ff       	jmp    801066ae <alltraps>

80106d73 <vector14>:
80106d73:	6a 0e                	push   $0xe
80106d75:	e9 34 f9 ff ff       	jmp    801066ae <alltraps>

80106d7a <vector15>:
80106d7a:	6a 00                	push   $0x0
80106d7c:	6a 0f                	push   $0xf
80106d7e:	e9 2b f9 ff ff       	jmp    801066ae <alltraps>

80106d83 <vector16>:
80106d83:	6a 00                	push   $0x0
80106d85:	6a 10                	push   $0x10
80106d87:	e9 22 f9 ff ff       	jmp    801066ae <alltraps>

80106d8c <vector17>:
80106d8c:	6a 11                	push   $0x11
80106d8e:	e9 1b f9 ff ff       	jmp    801066ae <alltraps>

80106d93 <vector18>:
80106d93:	6a 00                	push   $0x0
80106d95:	6a 12                	push   $0x12
80106d97:	e9 12 f9 ff ff       	jmp    801066ae <alltraps>

80106d9c <vector19>:
80106d9c:	6a 00                	push   $0x0
80106d9e:	6a 13                	push   $0x13
80106da0:	e9 09 f9 ff ff       	jmp    801066ae <alltraps>

80106da5 <vector20>:
80106da5:	6a 00                	push   $0x0
80106da7:	6a 14                	push   $0x14
80106da9:	e9 00 f9 ff ff       	jmp    801066ae <alltraps>

80106dae <vector21>:
80106dae:	6a 00                	push   $0x0
80106db0:	6a 15                	push   $0x15
80106db2:	e9 f7 f8 ff ff       	jmp    801066ae <alltraps>

80106db7 <vector22>:
80106db7:	6a 00                	push   $0x0
80106db9:	6a 16                	push   $0x16
80106dbb:	e9 ee f8 ff ff       	jmp    801066ae <alltraps>

80106dc0 <vector23>:
80106dc0:	6a 00                	push   $0x0
80106dc2:	6a 17                	push   $0x17
80106dc4:	e9 e5 f8 ff ff       	jmp    801066ae <alltraps>

80106dc9 <vector24>:
80106dc9:	6a 00                	push   $0x0
80106dcb:	6a 18                	push   $0x18
80106dcd:	e9 dc f8 ff ff       	jmp    801066ae <alltraps>

80106dd2 <vector25>:
80106dd2:	6a 00                	push   $0x0
80106dd4:	6a 19                	push   $0x19
80106dd6:	e9 d3 f8 ff ff       	jmp    801066ae <alltraps>

80106ddb <vector26>:
80106ddb:	6a 00                	push   $0x0
80106ddd:	6a 1a                	push   $0x1a
80106ddf:	e9 ca f8 ff ff       	jmp    801066ae <alltraps>

80106de4 <vector27>:
80106de4:	6a 00                	push   $0x0
80106de6:	6a 1b                	push   $0x1b
80106de8:	e9 c1 f8 ff ff       	jmp    801066ae <alltraps>

80106ded <vector28>:
80106ded:	6a 00                	push   $0x0
80106def:	6a 1c                	push   $0x1c
80106df1:	e9 b8 f8 ff ff       	jmp    801066ae <alltraps>

80106df6 <vector29>:
80106df6:	6a 00                	push   $0x0
80106df8:	6a 1d                	push   $0x1d
80106dfa:	e9 af f8 ff ff       	jmp    801066ae <alltraps>

80106dff <vector30>:
80106dff:	6a 00                	push   $0x0
80106e01:	6a 1e                	push   $0x1e
80106e03:	e9 a6 f8 ff ff       	jmp    801066ae <alltraps>

80106e08 <vector31>:
80106e08:	6a 00                	push   $0x0
80106e0a:	6a 1f                	push   $0x1f
80106e0c:	e9 9d f8 ff ff       	jmp    801066ae <alltraps>

80106e11 <vector32>:
80106e11:	6a 00                	push   $0x0
80106e13:	6a 20                	push   $0x20
80106e15:	e9 94 f8 ff ff       	jmp    801066ae <alltraps>

80106e1a <vector33>:
80106e1a:	6a 00                	push   $0x0
80106e1c:	6a 21                	push   $0x21
80106e1e:	e9 8b f8 ff ff       	jmp    801066ae <alltraps>

80106e23 <vector34>:
80106e23:	6a 00                	push   $0x0
80106e25:	6a 22                	push   $0x22
80106e27:	e9 82 f8 ff ff       	jmp    801066ae <alltraps>

80106e2c <vector35>:
80106e2c:	6a 00                	push   $0x0
80106e2e:	6a 23                	push   $0x23
80106e30:	e9 79 f8 ff ff       	jmp    801066ae <alltraps>

80106e35 <vector36>:
80106e35:	6a 00                	push   $0x0
80106e37:	6a 24                	push   $0x24
80106e39:	e9 70 f8 ff ff       	jmp    801066ae <alltraps>

80106e3e <vector37>:
80106e3e:	6a 00                	push   $0x0
80106e40:	6a 25                	push   $0x25
80106e42:	e9 67 f8 ff ff       	jmp    801066ae <alltraps>

80106e47 <vector38>:
80106e47:	6a 00                	push   $0x0
80106e49:	6a 26                	push   $0x26
80106e4b:	e9 5e f8 ff ff       	jmp    801066ae <alltraps>

80106e50 <vector39>:
80106e50:	6a 00                	push   $0x0
80106e52:	6a 27                	push   $0x27
80106e54:	e9 55 f8 ff ff       	jmp    801066ae <alltraps>

80106e59 <vector40>:
80106e59:	6a 00                	push   $0x0
80106e5b:	6a 28                	push   $0x28
80106e5d:	e9 4c f8 ff ff       	jmp    801066ae <alltraps>

80106e62 <vector41>:
80106e62:	6a 00                	push   $0x0
80106e64:	6a 29                	push   $0x29
80106e66:	e9 43 f8 ff ff       	jmp    801066ae <alltraps>

80106e6b <vector42>:
80106e6b:	6a 00                	push   $0x0
80106e6d:	6a 2a                	push   $0x2a
80106e6f:	e9 3a f8 ff ff       	jmp    801066ae <alltraps>

80106e74 <vector43>:
80106e74:	6a 00                	push   $0x0
80106e76:	6a 2b                	push   $0x2b
80106e78:	e9 31 f8 ff ff       	jmp    801066ae <alltraps>

80106e7d <vector44>:
80106e7d:	6a 00                	push   $0x0
80106e7f:	6a 2c                	push   $0x2c
80106e81:	e9 28 f8 ff ff       	jmp    801066ae <alltraps>

80106e86 <vector45>:
80106e86:	6a 00                	push   $0x0
80106e88:	6a 2d                	push   $0x2d
80106e8a:	e9 1f f8 ff ff       	jmp    801066ae <alltraps>

80106e8f <vector46>:
80106e8f:	6a 00                	push   $0x0
80106e91:	6a 2e                	push   $0x2e
80106e93:	e9 16 f8 ff ff       	jmp    801066ae <alltraps>

80106e98 <vector47>:
80106e98:	6a 00                	push   $0x0
80106e9a:	6a 2f                	push   $0x2f
80106e9c:	e9 0d f8 ff ff       	jmp    801066ae <alltraps>

80106ea1 <vector48>:
80106ea1:	6a 00                	push   $0x0
80106ea3:	6a 30                	push   $0x30
80106ea5:	e9 04 f8 ff ff       	jmp    801066ae <alltraps>

80106eaa <vector49>:
80106eaa:	6a 00                	push   $0x0
80106eac:	6a 31                	push   $0x31
80106eae:	e9 fb f7 ff ff       	jmp    801066ae <alltraps>

80106eb3 <vector50>:
80106eb3:	6a 00                	push   $0x0
80106eb5:	6a 32                	push   $0x32
80106eb7:	e9 f2 f7 ff ff       	jmp    801066ae <alltraps>

80106ebc <vector51>:
80106ebc:	6a 00                	push   $0x0
80106ebe:	6a 33                	push   $0x33
80106ec0:	e9 e9 f7 ff ff       	jmp    801066ae <alltraps>

80106ec5 <vector52>:
80106ec5:	6a 00                	push   $0x0
80106ec7:	6a 34                	push   $0x34
80106ec9:	e9 e0 f7 ff ff       	jmp    801066ae <alltraps>

80106ece <vector53>:
80106ece:	6a 00                	push   $0x0
80106ed0:	6a 35                	push   $0x35
80106ed2:	e9 d7 f7 ff ff       	jmp    801066ae <alltraps>

80106ed7 <vector54>:
80106ed7:	6a 00                	push   $0x0
80106ed9:	6a 36                	push   $0x36
80106edb:	e9 ce f7 ff ff       	jmp    801066ae <alltraps>

80106ee0 <vector55>:
80106ee0:	6a 00                	push   $0x0
80106ee2:	6a 37                	push   $0x37
80106ee4:	e9 c5 f7 ff ff       	jmp    801066ae <alltraps>

80106ee9 <vector56>:
80106ee9:	6a 00                	push   $0x0
80106eeb:	6a 38                	push   $0x38
80106eed:	e9 bc f7 ff ff       	jmp    801066ae <alltraps>

80106ef2 <vector57>:
80106ef2:	6a 00                	push   $0x0
80106ef4:	6a 39                	push   $0x39
80106ef6:	e9 b3 f7 ff ff       	jmp    801066ae <alltraps>

80106efb <vector58>:
80106efb:	6a 00                	push   $0x0
80106efd:	6a 3a                	push   $0x3a
80106eff:	e9 aa f7 ff ff       	jmp    801066ae <alltraps>

80106f04 <vector59>:
80106f04:	6a 00                	push   $0x0
80106f06:	6a 3b                	push   $0x3b
80106f08:	e9 a1 f7 ff ff       	jmp    801066ae <alltraps>

80106f0d <vector60>:
80106f0d:	6a 00                	push   $0x0
80106f0f:	6a 3c                	push   $0x3c
80106f11:	e9 98 f7 ff ff       	jmp    801066ae <alltraps>

80106f16 <vector61>:
80106f16:	6a 00                	push   $0x0
80106f18:	6a 3d                	push   $0x3d
80106f1a:	e9 8f f7 ff ff       	jmp    801066ae <alltraps>

80106f1f <vector62>:
80106f1f:	6a 00                	push   $0x0
80106f21:	6a 3e                	push   $0x3e
80106f23:	e9 86 f7 ff ff       	jmp    801066ae <alltraps>

80106f28 <vector63>:
80106f28:	6a 00                	push   $0x0
80106f2a:	6a 3f                	push   $0x3f
80106f2c:	e9 7d f7 ff ff       	jmp    801066ae <alltraps>

80106f31 <vector64>:
80106f31:	6a 00                	push   $0x0
80106f33:	6a 40                	push   $0x40
80106f35:	e9 74 f7 ff ff       	jmp    801066ae <alltraps>

80106f3a <vector65>:
80106f3a:	6a 00                	push   $0x0
80106f3c:	6a 41                	push   $0x41
80106f3e:	e9 6b f7 ff ff       	jmp    801066ae <alltraps>

80106f43 <vector66>:
80106f43:	6a 00                	push   $0x0
80106f45:	6a 42                	push   $0x42
80106f47:	e9 62 f7 ff ff       	jmp    801066ae <alltraps>

80106f4c <vector67>:
80106f4c:	6a 00                	push   $0x0
80106f4e:	6a 43                	push   $0x43
80106f50:	e9 59 f7 ff ff       	jmp    801066ae <alltraps>

80106f55 <vector68>:
80106f55:	6a 00                	push   $0x0
80106f57:	6a 44                	push   $0x44
80106f59:	e9 50 f7 ff ff       	jmp    801066ae <alltraps>

80106f5e <vector69>:
80106f5e:	6a 00                	push   $0x0
80106f60:	6a 45                	push   $0x45
80106f62:	e9 47 f7 ff ff       	jmp    801066ae <alltraps>

80106f67 <vector70>:
80106f67:	6a 00                	push   $0x0
80106f69:	6a 46                	push   $0x46
80106f6b:	e9 3e f7 ff ff       	jmp    801066ae <alltraps>

80106f70 <vector71>:
80106f70:	6a 00                	push   $0x0
80106f72:	6a 47                	push   $0x47
80106f74:	e9 35 f7 ff ff       	jmp    801066ae <alltraps>

80106f79 <vector72>:
80106f79:	6a 00                	push   $0x0
80106f7b:	6a 48                	push   $0x48
80106f7d:	e9 2c f7 ff ff       	jmp    801066ae <alltraps>

80106f82 <vector73>:
80106f82:	6a 00                	push   $0x0
80106f84:	6a 49                	push   $0x49
80106f86:	e9 23 f7 ff ff       	jmp    801066ae <alltraps>

80106f8b <vector74>:
80106f8b:	6a 00                	push   $0x0
80106f8d:	6a 4a                	push   $0x4a
80106f8f:	e9 1a f7 ff ff       	jmp    801066ae <alltraps>

80106f94 <vector75>:
80106f94:	6a 00                	push   $0x0
80106f96:	6a 4b                	push   $0x4b
80106f98:	e9 11 f7 ff ff       	jmp    801066ae <alltraps>

80106f9d <vector76>:
80106f9d:	6a 00                	push   $0x0
80106f9f:	6a 4c                	push   $0x4c
80106fa1:	e9 08 f7 ff ff       	jmp    801066ae <alltraps>

80106fa6 <vector77>:
80106fa6:	6a 00                	push   $0x0
80106fa8:	6a 4d                	push   $0x4d
80106faa:	e9 ff f6 ff ff       	jmp    801066ae <alltraps>

80106faf <vector78>:
80106faf:	6a 00                	push   $0x0
80106fb1:	6a 4e                	push   $0x4e
80106fb3:	e9 f6 f6 ff ff       	jmp    801066ae <alltraps>

80106fb8 <vector79>:
80106fb8:	6a 00                	push   $0x0
80106fba:	6a 4f                	push   $0x4f
80106fbc:	e9 ed f6 ff ff       	jmp    801066ae <alltraps>

80106fc1 <vector80>:
80106fc1:	6a 00                	push   $0x0
80106fc3:	6a 50                	push   $0x50
80106fc5:	e9 e4 f6 ff ff       	jmp    801066ae <alltraps>

80106fca <vector81>:
80106fca:	6a 00                	push   $0x0
80106fcc:	6a 51                	push   $0x51
80106fce:	e9 db f6 ff ff       	jmp    801066ae <alltraps>

80106fd3 <vector82>:
80106fd3:	6a 00                	push   $0x0
80106fd5:	6a 52                	push   $0x52
80106fd7:	e9 d2 f6 ff ff       	jmp    801066ae <alltraps>

80106fdc <vector83>:
80106fdc:	6a 00                	push   $0x0
80106fde:	6a 53                	push   $0x53
80106fe0:	e9 c9 f6 ff ff       	jmp    801066ae <alltraps>

80106fe5 <vector84>:
80106fe5:	6a 00                	push   $0x0
80106fe7:	6a 54                	push   $0x54
80106fe9:	e9 c0 f6 ff ff       	jmp    801066ae <alltraps>

80106fee <vector85>:
80106fee:	6a 00                	push   $0x0
80106ff0:	6a 55                	push   $0x55
80106ff2:	e9 b7 f6 ff ff       	jmp    801066ae <alltraps>

80106ff7 <vector86>:
80106ff7:	6a 00                	push   $0x0
80106ff9:	6a 56                	push   $0x56
80106ffb:	e9 ae f6 ff ff       	jmp    801066ae <alltraps>

80107000 <vector87>:
80107000:	6a 00                	push   $0x0
80107002:	6a 57                	push   $0x57
80107004:	e9 a5 f6 ff ff       	jmp    801066ae <alltraps>

80107009 <vector88>:
80107009:	6a 00                	push   $0x0
8010700b:	6a 58                	push   $0x58
8010700d:	e9 9c f6 ff ff       	jmp    801066ae <alltraps>

80107012 <vector89>:
80107012:	6a 00                	push   $0x0
80107014:	6a 59                	push   $0x59
80107016:	e9 93 f6 ff ff       	jmp    801066ae <alltraps>

8010701b <vector90>:
8010701b:	6a 00                	push   $0x0
8010701d:	6a 5a                	push   $0x5a
8010701f:	e9 8a f6 ff ff       	jmp    801066ae <alltraps>

80107024 <vector91>:
80107024:	6a 00                	push   $0x0
80107026:	6a 5b                	push   $0x5b
80107028:	e9 81 f6 ff ff       	jmp    801066ae <alltraps>

8010702d <vector92>:
8010702d:	6a 00                	push   $0x0
8010702f:	6a 5c                	push   $0x5c
80107031:	e9 78 f6 ff ff       	jmp    801066ae <alltraps>

80107036 <vector93>:
80107036:	6a 00                	push   $0x0
80107038:	6a 5d                	push   $0x5d
8010703a:	e9 6f f6 ff ff       	jmp    801066ae <alltraps>

8010703f <vector94>:
8010703f:	6a 00                	push   $0x0
80107041:	6a 5e                	push   $0x5e
80107043:	e9 66 f6 ff ff       	jmp    801066ae <alltraps>

80107048 <vector95>:
80107048:	6a 00                	push   $0x0
8010704a:	6a 5f                	push   $0x5f
8010704c:	e9 5d f6 ff ff       	jmp    801066ae <alltraps>

80107051 <vector96>:
80107051:	6a 00                	push   $0x0
80107053:	6a 60                	push   $0x60
80107055:	e9 54 f6 ff ff       	jmp    801066ae <alltraps>

8010705a <vector97>:
8010705a:	6a 00                	push   $0x0
8010705c:	6a 61                	push   $0x61
8010705e:	e9 4b f6 ff ff       	jmp    801066ae <alltraps>

80107063 <vector98>:
80107063:	6a 00                	push   $0x0
80107065:	6a 62                	push   $0x62
80107067:	e9 42 f6 ff ff       	jmp    801066ae <alltraps>

8010706c <vector99>:
8010706c:	6a 00                	push   $0x0
8010706e:	6a 63                	push   $0x63
80107070:	e9 39 f6 ff ff       	jmp    801066ae <alltraps>

80107075 <vector100>:
80107075:	6a 00                	push   $0x0
80107077:	6a 64                	push   $0x64
80107079:	e9 30 f6 ff ff       	jmp    801066ae <alltraps>

8010707e <vector101>:
8010707e:	6a 00                	push   $0x0
80107080:	6a 65                	push   $0x65
80107082:	e9 27 f6 ff ff       	jmp    801066ae <alltraps>

80107087 <vector102>:
80107087:	6a 00                	push   $0x0
80107089:	6a 66                	push   $0x66
8010708b:	e9 1e f6 ff ff       	jmp    801066ae <alltraps>

80107090 <vector103>:
80107090:	6a 00                	push   $0x0
80107092:	6a 67                	push   $0x67
80107094:	e9 15 f6 ff ff       	jmp    801066ae <alltraps>

80107099 <vector104>:
80107099:	6a 00                	push   $0x0
8010709b:	6a 68                	push   $0x68
8010709d:	e9 0c f6 ff ff       	jmp    801066ae <alltraps>

801070a2 <vector105>:
801070a2:	6a 00                	push   $0x0
801070a4:	6a 69                	push   $0x69
801070a6:	e9 03 f6 ff ff       	jmp    801066ae <alltraps>

801070ab <vector106>:
801070ab:	6a 00                	push   $0x0
801070ad:	6a 6a                	push   $0x6a
801070af:	e9 fa f5 ff ff       	jmp    801066ae <alltraps>

801070b4 <vector107>:
801070b4:	6a 00                	push   $0x0
801070b6:	6a 6b                	push   $0x6b
801070b8:	e9 f1 f5 ff ff       	jmp    801066ae <alltraps>

801070bd <vector108>:
801070bd:	6a 00                	push   $0x0
801070bf:	6a 6c                	push   $0x6c
801070c1:	e9 e8 f5 ff ff       	jmp    801066ae <alltraps>

801070c6 <vector109>:
801070c6:	6a 00                	push   $0x0
801070c8:	6a 6d                	push   $0x6d
801070ca:	e9 df f5 ff ff       	jmp    801066ae <alltraps>

801070cf <vector110>:
801070cf:	6a 00                	push   $0x0
801070d1:	6a 6e                	push   $0x6e
801070d3:	e9 d6 f5 ff ff       	jmp    801066ae <alltraps>

801070d8 <vector111>:
801070d8:	6a 00                	push   $0x0
801070da:	6a 6f                	push   $0x6f
801070dc:	e9 cd f5 ff ff       	jmp    801066ae <alltraps>

801070e1 <vector112>:
801070e1:	6a 00                	push   $0x0
801070e3:	6a 70                	push   $0x70
801070e5:	e9 c4 f5 ff ff       	jmp    801066ae <alltraps>

801070ea <vector113>:
801070ea:	6a 00                	push   $0x0
801070ec:	6a 71                	push   $0x71
801070ee:	e9 bb f5 ff ff       	jmp    801066ae <alltraps>

801070f3 <vector114>:
801070f3:	6a 00                	push   $0x0
801070f5:	6a 72                	push   $0x72
801070f7:	e9 b2 f5 ff ff       	jmp    801066ae <alltraps>

801070fc <vector115>:
801070fc:	6a 00                	push   $0x0
801070fe:	6a 73                	push   $0x73
80107100:	e9 a9 f5 ff ff       	jmp    801066ae <alltraps>

80107105 <vector116>:
80107105:	6a 00                	push   $0x0
80107107:	6a 74                	push   $0x74
80107109:	e9 a0 f5 ff ff       	jmp    801066ae <alltraps>

8010710e <vector117>:
8010710e:	6a 00                	push   $0x0
80107110:	6a 75                	push   $0x75
80107112:	e9 97 f5 ff ff       	jmp    801066ae <alltraps>

80107117 <vector118>:
80107117:	6a 00                	push   $0x0
80107119:	6a 76                	push   $0x76
8010711b:	e9 8e f5 ff ff       	jmp    801066ae <alltraps>

80107120 <vector119>:
80107120:	6a 00                	push   $0x0
80107122:	6a 77                	push   $0x77
80107124:	e9 85 f5 ff ff       	jmp    801066ae <alltraps>

80107129 <vector120>:
80107129:	6a 00                	push   $0x0
8010712b:	6a 78                	push   $0x78
8010712d:	e9 7c f5 ff ff       	jmp    801066ae <alltraps>

80107132 <vector121>:
80107132:	6a 00                	push   $0x0
80107134:	6a 79                	push   $0x79
80107136:	e9 73 f5 ff ff       	jmp    801066ae <alltraps>

8010713b <vector122>:
8010713b:	6a 00                	push   $0x0
8010713d:	6a 7a                	push   $0x7a
8010713f:	e9 6a f5 ff ff       	jmp    801066ae <alltraps>

80107144 <vector123>:
80107144:	6a 00                	push   $0x0
80107146:	6a 7b                	push   $0x7b
80107148:	e9 61 f5 ff ff       	jmp    801066ae <alltraps>

8010714d <vector124>:
8010714d:	6a 00                	push   $0x0
8010714f:	6a 7c                	push   $0x7c
80107151:	e9 58 f5 ff ff       	jmp    801066ae <alltraps>

80107156 <vector125>:
80107156:	6a 00                	push   $0x0
80107158:	6a 7d                	push   $0x7d
8010715a:	e9 4f f5 ff ff       	jmp    801066ae <alltraps>

8010715f <vector126>:
8010715f:	6a 00                	push   $0x0
80107161:	6a 7e                	push   $0x7e
80107163:	e9 46 f5 ff ff       	jmp    801066ae <alltraps>

80107168 <vector127>:
80107168:	6a 00                	push   $0x0
8010716a:	6a 7f                	push   $0x7f
8010716c:	e9 3d f5 ff ff       	jmp    801066ae <alltraps>

80107171 <vector128>:
80107171:	6a 00                	push   $0x0
80107173:	68 80 00 00 00       	push   $0x80
80107178:	e9 31 f5 ff ff       	jmp    801066ae <alltraps>

8010717d <vector129>:
8010717d:	6a 00                	push   $0x0
8010717f:	68 81 00 00 00       	push   $0x81
80107184:	e9 25 f5 ff ff       	jmp    801066ae <alltraps>

80107189 <vector130>:
80107189:	6a 00                	push   $0x0
8010718b:	68 82 00 00 00       	push   $0x82
80107190:	e9 19 f5 ff ff       	jmp    801066ae <alltraps>

80107195 <vector131>:
80107195:	6a 00                	push   $0x0
80107197:	68 83 00 00 00       	push   $0x83
8010719c:	e9 0d f5 ff ff       	jmp    801066ae <alltraps>

801071a1 <vector132>:
801071a1:	6a 00                	push   $0x0
801071a3:	68 84 00 00 00       	push   $0x84
801071a8:	e9 01 f5 ff ff       	jmp    801066ae <alltraps>

801071ad <vector133>:
801071ad:	6a 00                	push   $0x0
801071af:	68 85 00 00 00       	push   $0x85
801071b4:	e9 f5 f4 ff ff       	jmp    801066ae <alltraps>

801071b9 <vector134>:
801071b9:	6a 00                	push   $0x0
801071bb:	68 86 00 00 00       	push   $0x86
801071c0:	e9 e9 f4 ff ff       	jmp    801066ae <alltraps>

801071c5 <vector135>:
801071c5:	6a 00                	push   $0x0
801071c7:	68 87 00 00 00       	push   $0x87
801071cc:	e9 dd f4 ff ff       	jmp    801066ae <alltraps>

801071d1 <vector136>:
801071d1:	6a 00                	push   $0x0
801071d3:	68 88 00 00 00       	push   $0x88
801071d8:	e9 d1 f4 ff ff       	jmp    801066ae <alltraps>

801071dd <vector137>:
801071dd:	6a 00                	push   $0x0
801071df:	68 89 00 00 00       	push   $0x89
801071e4:	e9 c5 f4 ff ff       	jmp    801066ae <alltraps>

801071e9 <vector138>:
801071e9:	6a 00                	push   $0x0
801071eb:	68 8a 00 00 00       	push   $0x8a
801071f0:	e9 b9 f4 ff ff       	jmp    801066ae <alltraps>

801071f5 <vector139>:
801071f5:	6a 00                	push   $0x0
801071f7:	68 8b 00 00 00       	push   $0x8b
801071fc:	e9 ad f4 ff ff       	jmp    801066ae <alltraps>

80107201 <vector140>:
80107201:	6a 00                	push   $0x0
80107203:	68 8c 00 00 00       	push   $0x8c
80107208:	e9 a1 f4 ff ff       	jmp    801066ae <alltraps>

8010720d <vector141>:
8010720d:	6a 00                	push   $0x0
8010720f:	68 8d 00 00 00       	push   $0x8d
80107214:	e9 95 f4 ff ff       	jmp    801066ae <alltraps>

80107219 <vector142>:
80107219:	6a 00                	push   $0x0
8010721b:	68 8e 00 00 00       	push   $0x8e
80107220:	e9 89 f4 ff ff       	jmp    801066ae <alltraps>

80107225 <vector143>:
80107225:	6a 00                	push   $0x0
80107227:	68 8f 00 00 00       	push   $0x8f
8010722c:	e9 7d f4 ff ff       	jmp    801066ae <alltraps>

80107231 <vector144>:
80107231:	6a 00                	push   $0x0
80107233:	68 90 00 00 00       	push   $0x90
80107238:	e9 71 f4 ff ff       	jmp    801066ae <alltraps>

8010723d <vector145>:
8010723d:	6a 00                	push   $0x0
8010723f:	68 91 00 00 00       	push   $0x91
80107244:	e9 65 f4 ff ff       	jmp    801066ae <alltraps>

80107249 <vector146>:
80107249:	6a 00                	push   $0x0
8010724b:	68 92 00 00 00       	push   $0x92
80107250:	e9 59 f4 ff ff       	jmp    801066ae <alltraps>

80107255 <vector147>:
80107255:	6a 00                	push   $0x0
80107257:	68 93 00 00 00       	push   $0x93
8010725c:	e9 4d f4 ff ff       	jmp    801066ae <alltraps>

80107261 <vector148>:
80107261:	6a 00                	push   $0x0
80107263:	68 94 00 00 00       	push   $0x94
80107268:	e9 41 f4 ff ff       	jmp    801066ae <alltraps>

8010726d <vector149>:
8010726d:	6a 00                	push   $0x0
8010726f:	68 95 00 00 00       	push   $0x95
80107274:	e9 35 f4 ff ff       	jmp    801066ae <alltraps>

80107279 <vector150>:
80107279:	6a 00                	push   $0x0
8010727b:	68 96 00 00 00       	push   $0x96
80107280:	e9 29 f4 ff ff       	jmp    801066ae <alltraps>

80107285 <vector151>:
80107285:	6a 00                	push   $0x0
80107287:	68 97 00 00 00       	push   $0x97
8010728c:	e9 1d f4 ff ff       	jmp    801066ae <alltraps>

80107291 <vector152>:
80107291:	6a 00                	push   $0x0
80107293:	68 98 00 00 00       	push   $0x98
80107298:	e9 11 f4 ff ff       	jmp    801066ae <alltraps>

8010729d <vector153>:
8010729d:	6a 00                	push   $0x0
8010729f:	68 99 00 00 00       	push   $0x99
801072a4:	e9 05 f4 ff ff       	jmp    801066ae <alltraps>

801072a9 <vector154>:
801072a9:	6a 00                	push   $0x0
801072ab:	68 9a 00 00 00       	push   $0x9a
801072b0:	e9 f9 f3 ff ff       	jmp    801066ae <alltraps>

801072b5 <vector155>:
801072b5:	6a 00                	push   $0x0
801072b7:	68 9b 00 00 00       	push   $0x9b
801072bc:	e9 ed f3 ff ff       	jmp    801066ae <alltraps>

801072c1 <vector156>:
801072c1:	6a 00                	push   $0x0
801072c3:	68 9c 00 00 00       	push   $0x9c
801072c8:	e9 e1 f3 ff ff       	jmp    801066ae <alltraps>

801072cd <vector157>:
801072cd:	6a 00                	push   $0x0
801072cf:	68 9d 00 00 00       	push   $0x9d
801072d4:	e9 d5 f3 ff ff       	jmp    801066ae <alltraps>

801072d9 <vector158>:
801072d9:	6a 00                	push   $0x0
801072db:	68 9e 00 00 00       	push   $0x9e
801072e0:	e9 c9 f3 ff ff       	jmp    801066ae <alltraps>

801072e5 <vector159>:
801072e5:	6a 00                	push   $0x0
801072e7:	68 9f 00 00 00       	push   $0x9f
801072ec:	e9 bd f3 ff ff       	jmp    801066ae <alltraps>

801072f1 <vector160>:
801072f1:	6a 00                	push   $0x0
801072f3:	68 a0 00 00 00       	push   $0xa0
801072f8:	e9 b1 f3 ff ff       	jmp    801066ae <alltraps>

801072fd <vector161>:
801072fd:	6a 00                	push   $0x0
801072ff:	68 a1 00 00 00       	push   $0xa1
80107304:	e9 a5 f3 ff ff       	jmp    801066ae <alltraps>

80107309 <vector162>:
80107309:	6a 00                	push   $0x0
8010730b:	68 a2 00 00 00       	push   $0xa2
80107310:	e9 99 f3 ff ff       	jmp    801066ae <alltraps>

80107315 <vector163>:
80107315:	6a 00                	push   $0x0
80107317:	68 a3 00 00 00       	push   $0xa3
8010731c:	e9 8d f3 ff ff       	jmp    801066ae <alltraps>

80107321 <vector164>:
80107321:	6a 00                	push   $0x0
80107323:	68 a4 00 00 00       	push   $0xa4
80107328:	e9 81 f3 ff ff       	jmp    801066ae <alltraps>

8010732d <vector165>:
8010732d:	6a 00                	push   $0x0
8010732f:	68 a5 00 00 00       	push   $0xa5
80107334:	e9 75 f3 ff ff       	jmp    801066ae <alltraps>

80107339 <vector166>:
80107339:	6a 00                	push   $0x0
8010733b:	68 a6 00 00 00       	push   $0xa6
80107340:	e9 69 f3 ff ff       	jmp    801066ae <alltraps>

80107345 <vector167>:
80107345:	6a 00                	push   $0x0
80107347:	68 a7 00 00 00       	push   $0xa7
8010734c:	e9 5d f3 ff ff       	jmp    801066ae <alltraps>

80107351 <vector168>:
80107351:	6a 00                	push   $0x0
80107353:	68 a8 00 00 00       	push   $0xa8
80107358:	e9 51 f3 ff ff       	jmp    801066ae <alltraps>

8010735d <vector169>:
8010735d:	6a 00                	push   $0x0
8010735f:	68 a9 00 00 00       	push   $0xa9
80107364:	e9 45 f3 ff ff       	jmp    801066ae <alltraps>

80107369 <vector170>:
80107369:	6a 00                	push   $0x0
8010736b:	68 aa 00 00 00       	push   $0xaa
80107370:	e9 39 f3 ff ff       	jmp    801066ae <alltraps>

80107375 <vector171>:
80107375:	6a 00                	push   $0x0
80107377:	68 ab 00 00 00       	push   $0xab
8010737c:	e9 2d f3 ff ff       	jmp    801066ae <alltraps>

80107381 <vector172>:
80107381:	6a 00                	push   $0x0
80107383:	68 ac 00 00 00       	push   $0xac
80107388:	e9 21 f3 ff ff       	jmp    801066ae <alltraps>

8010738d <vector173>:
8010738d:	6a 00                	push   $0x0
8010738f:	68 ad 00 00 00       	push   $0xad
80107394:	e9 15 f3 ff ff       	jmp    801066ae <alltraps>

80107399 <vector174>:
80107399:	6a 00                	push   $0x0
8010739b:	68 ae 00 00 00       	push   $0xae
801073a0:	e9 09 f3 ff ff       	jmp    801066ae <alltraps>

801073a5 <vector175>:
801073a5:	6a 00                	push   $0x0
801073a7:	68 af 00 00 00       	push   $0xaf
801073ac:	e9 fd f2 ff ff       	jmp    801066ae <alltraps>

801073b1 <vector176>:
801073b1:	6a 00                	push   $0x0
801073b3:	68 b0 00 00 00       	push   $0xb0
801073b8:	e9 f1 f2 ff ff       	jmp    801066ae <alltraps>

801073bd <vector177>:
801073bd:	6a 00                	push   $0x0
801073bf:	68 b1 00 00 00       	push   $0xb1
801073c4:	e9 e5 f2 ff ff       	jmp    801066ae <alltraps>

801073c9 <vector178>:
801073c9:	6a 00                	push   $0x0
801073cb:	68 b2 00 00 00       	push   $0xb2
801073d0:	e9 d9 f2 ff ff       	jmp    801066ae <alltraps>

801073d5 <vector179>:
801073d5:	6a 00                	push   $0x0
801073d7:	68 b3 00 00 00       	push   $0xb3
801073dc:	e9 cd f2 ff ff       	jmp    801066ae <alltraps>

801073e1 <vector180>:
801073e1:	6a 00                	push   $0x0
801073e3:	68 b4 00 00 00       	push   $0xb4
801073e8:	e9 c1 f2 ff ff       	jmp    801066ae <alltraps>

801073ed <vector181>:
801073ed:	6a 00                	push   $0x0
801073ef:	68 b5 00 00 00       	push   $0xb5
801073f4:	e9 b5 f2 ff ff       	jmp    801066ae <alltraps>

801073f9 <vector182>:
801073f9:	6a 00                	push   $0x0
801073fb:	68 b6 00 00 00       	push   $0xb6
80107400:	e9 a9 f2 ff ff       	jmp    801066ae <alltraps>

80107405 <vector183>:
80107405:	6a 00                	push   $0x0
80107407:	68 b7 00 00 00       	push   $0xb7
8010740c:	e9 9d f2 ff ff       	jmp    801066ae <alltraps>

80107411 <vector184>:
80107411:	6a 00                	push   $0x0
80107413:	68 b8 00 00 00       	push   $0xb8
80107418:	e9 91 f2 ff ff       	jmp    801066ae <alltraps>

8010741d <vector185>:
8010741d:	6a 00                	push   $0x0
8010741f:	68 b9 00 00 00       	push   $0xb9
80107424:	e9 85 f2 ff ff       	jmp    801066ae <alltraps>

80107429 <vector186>:
80107429:	6a 00                	push   $0x0
8010742b:	68 ba 00 00 00       	push   $0xba
80107430:	e9 79 f2 ff ff       	jmp    801066ae <alltraps>

80107435 <vector187>:
80107435:	6a 00                	push   $0x0
80107437:	68 bb 00 00 00       	push   $0xbb
8010743c:	e9 6d f2 ff ff       	jmp    801066ae <alltraps>

80107441 <vector188>:
80107441:	6a 00                	push   $0x0
80107443:	68 bc 00 00 00       	push   $0xbc
80107448:	e9 61 f2 ff ff       	jmp    801066ae <alltraps>

8010744d <vector189>:
8010744d:	6a 00                	push   $0x0
8010744f:	68 bd 00 00 00       	push   $0xbd
80107454:	e9 55 f2 ff ff       	jmp    801066ae <alltraps>

80107459 <vector190>:
80107459:	6a 00                	push   $0x0
8010745b:	68 be 00 00 00       	push   $0xbe
80107460:	e9 49 f2 ff ff       	jmp    801066ae <alltraps>

80107465 <vector191>:
80107465:	6a 00                	push   $0x0
80107467:	68 bf 00 00 00       	push   $0xbf
8010746c:	e9 3d f2 ff ff       	jmp    801066ae <alltraps>

80107471 <vector192>:
80107471:	6a 00                	push   $0x0
80107473:	68 c0 00 00 00       	push   $0xc0
80107478:	e9 31 f2 ff ff       	jmp    801066ae <alltraps>

8010747d <vector193>:
8010747d:	6a 00                	push   $0x0
8010747f:	68 c1 00 00 00       	push   $0xc1
80107484:	e9 25 f2 ff ff       	jmp    801066ae <alltraps>

80107489 <vector194>:
80107489:	6a 00                	push   $0x0
8010748b:	68 c2 00 00 00       	push   $0xc2
80107490:	e9 19 f2 ff ff       	jmp    801066ae <alltraps>

80107495 <vector195>:
80107495:	6a 00                	push   $0x0
80107497:	68 c3 00 00 00       	push   $0xc3
8010749c:	e9 0d f2 ff ff       	jmp    801066ae <alltraps>

801074a1 <vector196>:
801074a1:	6a 00                	push   $0x0
801074a3:	68 c4 00 00 00       	push   $0xc4
801074a8:	e9 01 f2 ff ff       	jmp    801066ae <alltraps>

801074ad <vector197>:
801074ad:	6a 00                	push   $0x0
801074af:	68 c5 00 00 00       	push   $0xc5
801074b4:	e9 f5 f1 ff ff       	jmp    801066ae <alltraps>

801074b9 <vector198>:
801074b9:	6a 00                	push   $0x0
801074bb:	68 c6 00 00 00       	push   $0xc6
801074c0:	e9 e9 f1 ff ff       	jmp    801066ae <alltraps>

801074c5 <vector199>:
801074c5:	6a 00                	push   $0x0
801074c7:	68 c7 00 00 00       	push   $0xc7
801074cc:	e9 dd f1 ff ff       	jmp    801066ae <alltraps>

801074d1 <vector200>:
801074d1:	6a 00                	push   $0x0
801074d3:	68 c8 00 00 00       	push   $0xc8
801074d8:	e9 d1 f1 ff ff       	jmp    801066ae <alltraps>

801074dd <vector201>:
801074dd:	6a 00                	push   $0x0
801074df:	68 c9 00 00 00       	push   $0xc9
801074e4:	e9 c5 f1 ff ff       	jmp    801066ae <alltraps>

801074e9 <vector202>:
801074e9:	6a 00                	push   $0x0
801074eb:	68 ca 00 00 00       	push   $0xca
801074f0:	e9 b9 f1 ff ff       	jmp    801066ae <alltraps>

801074f5 <vector203>:
801074f5:	6a 00                	push   $0x0
801074f7:	68 cb 00 00 00       	push   $0xcb
801074fc:	e9 ad f1 ff ff       	jmp    801066ae <alltraps>

80107501 <vector204>:
80107501:	6a 00                	push   $0x0
80107503:	68 cc 00 00 00       	push   $0xcc
80107508:	e9 a1 f1 ff ff       	jmp    801066ae <alltraps>

8010750d <vector205>:
8010750d:	6a 00                	push   $0x0
8010750f:	68 cd 00 00 00       	push   $0xcd
80107514:	e9 95 f1 ff ff       	jmp    801066ae <alltraps>

80107519 <vector206>:
80107519:	6a 00                	push   $0x0
8010751b:	68 ce 00 00 00       	push   $0xce
80107520:	e9 89 f1 ff ff       	jmp    801066ae <alltraps>

80107525 <vector207>:
80107525:	6a 00                	push   $0x0
80107527:	68 cf 00 00 00       	push   $0xcf
8010752c:	e9 7d f1 ff ff       	jmp    801066ae <alltraps>

80107531 <vector208>:
80107531:	6a 00                	push   $0x0
80107533:	68 d0 00 00 00       	push   $0xd0
80107538:	e9 71 f1 ff ff       	jmp    801066ae <alltraps>

8010753d <vector209>:
8010753d:	6a 00                	push   $0x0
8010753f:	68 d1 00 00 00       	push   $0xd1
80107544:	e9 65 f1 ff ff       	jmp    801066ae <alltraps>

80107549 <vector210>:
80107549:	6a 00                	push   $0x0
8010754b:	68 d2 00 00 00       	push   $0xd2
80107550:	e9 59 f1 ff ff       	jmp    801066ae <alltraps>

80107555 <vector211>:
80107555:	6a 00                	push   $0x0
80107557:	68 d3 00 00 00       	push   $0xd3
8010755c:	e9 4d f1 ff ff       	jmp    801066ae <alltraps>

80107561 <vector212>:
80107561:	6a 00                	push   $0x0
80107563:	68 d4 00 00 00       	push   $0xd4
80107568:	e9 41 f1 ff ff       	jmp    801066ae <alltraps>

8010756d <vector213>:
8010756d:	6a 00                	push   $0x0
8010756f:	68 d5 00 00 00       	push   $0xd5
80107574:	e9 35 f1 ff ff       	jmp    801066ae <alltraps>

80107579 <vector214>:
80107579:	6a 00                	push   $0x0
8010757b:	68 d6 00 00 00       	push   $0xd6
80107580:	e9 29 f1 ff ff       	jmp    801066ae <alltraps>

80107585 <vector215>:
80107585:	6a 00                	push   $0x0
80107587:	68 d7 00 00 00       	push   $0xd7
8010758c:	e9 1d f1 ff ff       	jmp    801066ae <alltraps>

80107591 <vector216>:
80107591:	6a 00                	push   $0x0
80107593:	68 d8 00 00 00       	push   $0xd8
80107598:	e9 11 f1 ff ff       	jmp    801066ae <alltraps>

8010759d <vector217>:
8010759d:	6a 00                	push   $0x0
8010759f:	68 d9 00 00 00       	push   $0xd9
801075a4:	e9 05 f1 ff ff       	jmp    801066ae <alltraps>

801075a9 <vector218>:
801075a9:	6a 00                	push   $0x0
801075ab:	68 da 00 00 00       	push   $0xda
801075b0:	e9 f9 f0 ff ff       	jmp    801066ae <alltraps>

801075b5 <vector219>:
801075b5:	6a 00                	push   $0x0
801075b7:	68 db 00 00 00       	push   $0xdb
801075bc:	e9 ed f0 ff ff       	jmp    801066ae <alltraps>

801075c1 <vector220>:
801075c1:	6a 00                	push   $0x0
801075c3:	68 dc 00 00 00       	push   $0xdc
801075c8:	e9 e1 f0 ff ff       	jmp    801066ae <alltraps>

801075cd <vector221>:
801075cd:	6a 00                	push   $0x0
801075cf:	68 dd 00 00 00       	push   $0xdd
801075d4:	e9 d5 f0 ff ff       	jmp    801066ae <alltraps>

801075d9 <vector222>:
801075d9:	6a 00                	push   $0x0
801075db:	68 de 00 00 00       	push   $0xde
801075e0:	e9 c9 f0 ff ff       	jmp    801066ae <alltraps>

801075e5 <vector223>:
801075e5:	6a 00                	push   $0x0
801075e7:	68 df 00 00 00       	push   $0xdf
801075ec:	e9 bd f0 ff ff       	jmp    801066ae <alltraps>

801075f1 <vector224>:
801075f1:	6a 00                	push   $0x0
801075f3:	68 e0 00 00 00       	push   $0xe0
801075f8:	e9 b1 f0 ff ff       	jmp    801066ae <alltraps>

801075fd <vector225>:
801075fd:	6a 00                	push   $0x0
801075ff:	68 e1 00 00 00       	push   $0xe1
80107604:	e9 a5 f0 ff ff       	jmp    801066ae <alltraps>

80107609 <vector226>:
80107609:	6a 00                	push   $0x0
8010760b:	68 e2 00 00 00       	push   $0xe2
80107610:	e9 99 f0 ff ff       	jmp    801066ae <alltraps>

80107615 <vector227>:
80107615:	6a 00                	push   $0x0
80107617:	68 e3 00 00 00       	push   $0xe3
8010761c:	e9 8d f0 ff ff       	jmp    801066ae <alltraps>

80107621 <vector228>:
80107621:	6a 00                	push   $0x0
80107623:	68 e4 00 00 00       	push   $0xe4
80107628:	e9 81 f0 ff ff       	jmp    801066ae <alltraps>

8010762d <vector229>:
8010762d:	6a 00                	push   $0x0
8010762f:	68 e5 00 00 00       	push   $0xe5
80107634:	e9 75 f0 ff ff       	jmp    801066ae <alltraps>

80107639 <vector230>:
80107639:	6a 00                	push   $0x0
8010763b:	68 e6 00 00 00       	push   $0xe6
80107640:	e9 69 f0 ff ff       	jmp    801066ae <alltraps>

80107645 <vector231>:
80107645:	6a 00                	push   $0x0
80107647:	68 e7 00 00 00       	push   $0xe7
8010764c:	e9 5d f0 ff ff       	jmp    801066ae <alltraps>

80107651 <vector232>:
80107651:	6a 00                	push   $0x0
80107653:	68 e8 00 00 00       	push   $0xe8
80107658:	e9 51 f0 ff ff       	jmp    801066ae <alltraps>

8010765d <vector233>:
8010765d:	6a 00                	push   $0x0
8010765f:	68 e9 00 00 00       	push   $0xe9
80107664:	e9 45 f0 ff ff       	jmp    801066ae <alltraps>

80107669 <vector234>:
80107669:	6a 00                	push   $0x0
8010766b:	68 ea 00 00 00       	push   $0xea
80107670:	e9 39 f0 ff ff       	jmp    801066ae <alltraps>

80107675 <vector235>:
80107675:	6a 00                	push   $0x0
80107677:	68 eb 00 00 00       	push   $0xeb
8010767c:	e9 2d f0 ff ff       	jmp    801066ae <alltraps>

80107681 <vector236>:
80107681:	6a 00                	push   $0x0
80107683:	68 ec 00 00 00       	push   $0xec
80107688:	e9 21 f0 ff ff       	jmp    801066ae <alltraps>

8010768d <vector237>:
8010768d:	6a 00                	push   $0x0
8010768f:	68 ed 00 00 00       	push   $0xed
80107694:	e9 15 f0 ff ff       	jmp    801066ae <alltraps>

80107699 <vector238>:
80107699:	6a 00                	push   $0x0
8010769b:	68 ee 00 00 00       	push   $0xee
801076a0:	e9 09 f0 ff ff       	jmp    801066ae <alltraps>

801076a5 <vector239>:
801076a5:	6a 00                	push   $0x0
801076a7:	68 ef 00 00 00       	push   $0xef
801076ac:	e9 fd ef ff ff       	jmp    801066ae <alltraps>

801076b1 <vector240>:
801076b1:	6a 00                	push   $0x0
801076b3:	68 f0 00 00 00       	push   $0xf0
801076b8:	e9 f1 ef ff ff       	jmp    801066ae <alltraps>

801076bd <vector241>:
801076bd:	6a 00                	push   $0x0
801076bf:	68 f1 00 00 00       	push   $0xf1
801076c4:	e9 e5 ef ff ff       	jmp    801066ae <alltraps>

801076c9 <vector242>:
801076c9:	6a 00                	push   $0x0
801076cb:	68 f2 00 00 00       	push   $0xf2
801076d0:	e9 d9 ef ff ff       	jmp    801066ae <alltraps>

801076d5 <vector243>:
801076d5:	6a 00                	push   $0x0
801076d7:	68 f3 00 00 00       	push   $0xf3
801076dc:	e9 cd ef ff ff       	jmp    801066ae <alltraps>

801076e1 <vector244>:
801076e1:	6a 00                	push   $0x0
801076e3:	68 f4 00 00 00       	push   $0xf4
801076e8:	e9 c1 ef ff ff       	jmp    801066ae <alltraps>

801076ed <vector245>:
801076ed:	6a 00                	push   $0x0
801076ef:	68 f5 00 00 00       	push   $0xf5
801076f4:	e9 b5 ef ff ff       	jmp    801066ae <alltraps>

801076f9 <vector246>:
801076f9:	6a 00                	push   $0x0
801076fb:	68 f6 00 00 00       	push   $0xf6
80107700:	e9 a9 ef ff ff       	jmp    801066ae <alltraps>

80107705 <vector247>:
80107705:	6a 00                	push   $0x0
80107707:	68 f7 00 00 00       	push   $0xf7
8010770c:	e9 9d ef ff ff       	jmp    801066ae <alltraps>

80107711 <vector248>:
80107711:	6a 00                	push   $0x0
80107713:	68 f8 00 00 00       	push   $0xf8
80107718:	e9 91 ef ff ff       	jmp    801066ae <alltraps>

8010771d <vector249>:
8010771d:	6a 00                	push   $0x0
8010771f:	68 f9 00 00 00       	push   $0xf9
80107724:	e9 85 ef ff ff       	jmp    801066ae <alltraps>

80107729 <vector250>:
80107729:	6a 00                	push   $0x0
8010772b:	68 fa 00 00 00       	push   $0xfa
80107730:	e9 79 ef ff ff       	jmp    801066ae <alltraps>

80107735 <vector251>:
80107735:	6a 00                	push   $0x0
80107737:	68 fb 00 00 00       	push   $0xfb
8010773c:	e9 6d ef ff ff       	jmp    801066ae <alltraps>

80107741 <vector252>:
80107741:	6a 00                	push   $0x0
80107743:	68 fc 00 00 00       	push   $0xfc
80107748:	e9 61 ef ff ff       	jmp    801066ae <alltraps>

8010774d <vector253>:
8010774d:	6a 00                	push   $0x0
8010774f:	68 fd 00 00 00       	push   $0xfd
80107754:	e9 55 ef ff ff       	jmp    801066ae <alltraps>

80107759 <vector254>:
80107759:	6a 00                	push   $0x0
8010775b:	68 fe 00 00 00       	push   $0xfe
80107760:	e9 49 ef ff ff       	jmp    801066ae <alltraps>

80107765 <vector255>:
80107765:	6a 00                	push   $0x0
80107767:	68 ff 00 00 00       	push   $0xff
8010776c:	e9 3d ef ff ff       	jmp    801066ae <alltraps>

80107771 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107771:	55                   	push   %ebp
80107772:	89 e5                	mov    %esp,%ebp
80107774:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107777:	8b 45 0c             	mov    0xc(%ebp),%eax
8010777a:	83 e8 01             	sub    $0x1,%eax
8010777d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107781:	8b 45 08             	mov    0x8(%ebp),%eax
80107784:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107788:	8b 45 08             	mov    0x8(%ebp),%eax
8010778b:	c1 e8 10             	shr    $0x10,%eax
8010778e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107792:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107795:	0f 01 10             	lgdtl  (%eax)
}
80107798:	90                   	nop
80107799:	c9                   	leave  
8010779a:	c3                   	ret    

8010779b <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010779b:	55                   	push   %ebp
8010779c:	89 e5                	mov    %esp,%ebp
8010779e:	83 ec 04             	sub    $0x4,%esp
801077a1:	8b 45 08             	mov    0x8(%ebp),%eax
801077a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801077a8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077ac:	0f 00 d8             	ltr    %ax
}
801077af:	90                   	nop
801077b0:	c9                   	leave  
801077b1:	c3                   	ret    

801077b2 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801077b2:	55                   	push   %ebp
801077b3:	89 e5                	mov    %esp,%ebp
801077b5:	83 ec 04             	sub    $0x4,%esp
801077b8:	8b 45 08             	mov    0x8(%ebp),%eax
801077bb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801077bf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077c3:	8e e8                	mov    %eax,%gs
}
801077c5:	90                   	nop
801077c6:	c9                   	leave  
801077c7:	c3                   	ret    

801077c8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801077c8:	55                   	push   %ebp
801077c9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077cb:	8b 45 08             	mov    0x8(%ebp),%eax
801077ce:	0f 22 d8             	mov    %eax,%cr3
}
801077d1:	90                   	nop
801077d2:	5d                   	pop    %ebp
801077d3:	c3                   	ret    

801077d4 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801077d4:	55                   	push   %ebp
801077d5:	89 e5                	mov    %esp,%ebp
801077d7:	8b 45 08             	mov    0x8(%ebp),%eax
801077da:	05 00 00 00 80       	add    $0x80000000,%eax
801077df:	5d                   	pop    %ebp
801077e0:	c3                   	ret    

801077e1 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801077e1:	55                   	push   %ebp
801077e2:	89 e5                	mov    %esp,%ebp
801077e4:	8b 45 08             	mov    0x8(%ebp),%eax
801077e7:	05 00 00 00 80       	add    $0x80000000,%eax
801077ec:	5d                   	pop    %ebp
801077ed:	c3                   	ret    

801077ee <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077ee:	55                   	push   %ebp
801077ef:	89 e5                	mov    %esp,%ebp
801077f1:	53                   	push   %ebx
801077f2:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801077f5:	e8 51 b7 ff ff       	call   80102f4b <cpunum>
801077fa:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107800:	05 60 23 11 80       	add    $0x80112360,%eax
80107805:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107814:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010781a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107824:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107828:	83 e2 f0             	and    $0xfffffff0,%edx
8010782b:	83 ca 0a             	or     $0xa,%edx
8010782e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107834:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107838:	83 ca 10             	or     $0x10,%edx
8010783b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010783e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107841:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107845:	83 e2 9f             	and    $0xffffff9f,%edx
80107848:	88 50 7d             	mov    %dl,0x7d(%eax)
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107852:	83 ca 80             	or     $0xffffff80,%edx
80107855:	88 50 7d             	mov    %dl,0x7d(%eax)
80107858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010785f:	83 ca 0f             	or     $0xf,%edx
80107862:	88 50 7e             	mov    %dl,0x7e(%eax)
80107865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107868:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010786c:	83 e2 ef             	and    $0xffffffef,%edx
8010786f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107875:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107879:	83 e2 df             	and    $0xffffffdf,%edx
8010787c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107886:	83 ca 40             	or     $0x40,%edx
80107889:	88 50 7e             	mov    %dl,0x7e(%eax)
8010788c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107893:	83 ca 80             	or     $0xffffff80,%edx
80107896:	88 50 7e             	mov    %dl,0x7e(%eax)
80107899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a3:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801078aa:	ff ff 
801078ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078af:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801078b6:	00 00 
801078b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bb:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801078c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078cc:	83 e2 f0             	and    $0xfffffff0,%edx
801078cf:	83 ca 02             	or     $0x2,%edx
801078d2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078db:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078e2:	83 ca 10             	or     $0x10,%edx
801078e5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ee:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078f5:	83 e2 9f             	and    $0xffffff9f,%edx
801078f8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107901:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107908:	83 ca 80             	or     $0xffffff80,%edx
8010790b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107914:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010791b:	83 ca 0f             	or     $0xf,%edx
8010791e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107927:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010792e:	83 e2 ef             	and    $0xffffffef,%edx
80107931:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107941:	83 e2 df             	and    $0xffffffdf,%edx
80107944:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010794a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107954:	83 ca 40             	or     $0x40,%edx
80107957:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010795d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107960:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107967:	83 ca 80             	or     $0xffffff80,%edx
8010796a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107973:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797d:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107984:	ff ff 
80107986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107989:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107990:	00 00 
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010799c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079a6:	83 e2 f0             	and    $0xfffffff0,%edx
801079a9:	83 ca 0a             	or     $0xa,%edx
801079ac:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079bc:	83 ca 10             	or     $0x10,%edx
801079bf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079cf:	83 ca 60             	or     $0x60,%edx
801079d2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079db:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079e2:	83 ca 80             	or     $0xffffff80,%edx
801079e5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ee:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079f5:	83 ca 0f             	or     $0xf,%edx
801079f8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a01:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a08:	83 e2 ef             	and    $0xffffffef,%edx
80107a0b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a14:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a1b:	83 e2 df             	and    $0xffffffdf,%edx
80107a1e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a27:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a2e:	83 ca 40             	or     $0x40,%edx
80107a31:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a41:	83 ca 80             	or     $0xffffff80,%edx
80107a44:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a57:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107a5e:	ff ff 
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107a6a:	00 00 
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a79:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a80:	83 e2 f0             	and    $0xfffffff0,%edx
80107a83:	83 ca 02             	or     $0x2,%edx
80107a86:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a96:	83 ca 10             	or     $0x10,%edx
80107a99:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107aa9:	83 ca 60             	or     $0x60,%edx
80107aac:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107abc:	83 ca 80             	or     $0xffffff80,%edx
80107abf:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107acf:	83 ca 0f             	or     $0xf,%edx
80107ad2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ae2:	83 e2 ef             	and    $0xffffffef,%edx
80107ae5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aee:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107af5:	83 e2 df             	and    $0xffffffdf,%edx
80107af8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b08:	83 ca 40             	or     $0x40,%edx
80107b0b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b14:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b1b:	83 ca 80             	or     $0xffffff80,%edx
80107b1e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b27:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b31:	05 b4 00 00 00       	add    $0xb4,%eax
80107b36:	89 c3                	mov    %eax,%ebx
80107b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3b:	05 b4 00 00 00       	add    $0xb4,%eax
80107b40:	c1 e8 10             	shr    $0x10,%eax
80107b43:	89 c2                	mov    %eax,%edx
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	05 b4 00 00 00       	add    $0xb4,%eax
80107b4d:	c1 e8 18             	shr    $0x18,%eax
80107b50:	89 c1                	mov    %eax,%ecx
80107b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b55:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107b5c:	00 00 
80107b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b61:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6b:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b74:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b7b:	83 e2 f0             	and    $0xfffffff0,%edx
80107b7e:	83 ca 02             	or     $0x2,%edx
80107b81:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b91:	83 ca 10             	or     $0x10,%edx
80107b94:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ba4:	83 e2 9f             	and    $0xffffff9f,%edx
80107ba7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bb7:	83 ca 80             	or     $0xffffff80,%edx
80107bba:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bca:	83 e2 f0             	and    $0xfffffff0,%edx
80107bcd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bdd:	83 e2 ef             	and    $0xffffffef,%edx
80107be0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bf0:	83 e2 df             	and    $0xffffffdf,%edx
80107bf3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c03:	83 ca 40             	or     $0x40,%edx
80107c06:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c16:	83 ca 80             	or     $0xffffff80,%edx
80107c19:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c22:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2b:	83 c0 70             	add    $0x70,%eax
80107c2e:	83 ec 08             	sub    $0x8,%esp
80107c31:	6a 38                	push   $0x38
80107c33:	50                   	push   %eax
80107c34:	e8 38 fb ff ff       	call   80107771 <lgdt>
80107c39:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107c3c:	83 ec 0c             	sub    $0xc,%esp
80107c3f:	6a 18                	push   $0x18
80107c41:	e8 6c fb ff ff       	call   801077b2 <loadgs>
80107c46:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4c:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107c52:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107c59:	00 00 00 00 
}
80107c5d:	90                   	nop
80107c5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c61:	c9                   	leave  
80107c62:	c3                   	ret    

80107c63 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c63:	55                   	push   %ebp
80107c64:	89 e5                	mov    %esp,%ebp
80107c66:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c69:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c6c:	c1 e8 16             	shr    $0x16,%eax
80107c6f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c76:	8b 45 08             	mov    0x8(%ebp),%eax
80107c79:	01 d0                	add    %edx,%eax
80107c7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c81:	8b 00                	mov    (%eax),%eax
80107c83:	83 e0 01             	and    $0x1,%eax
80107c86:	85 c0                	test   %eax,%eax
80107c88:	74 18                	je     80107ca2 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c8d:	8b 00                	mov    (%eax),%eax
80107c8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c94:	50                   	push   %eax
80107c95:	e8 47 fb ff ff       	call   801077e1 <p2v>
80107c9a:	83 c4 04             	add    $0x4,%esp
80107c9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ca0:	eb 48                	jmp    80107cea <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ca2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ca6:	74 0e                	je     80107cb6 <walkpgdir+0x53>
80107ca8:	e8 38 af ff ff       	call   80102be5 <kalloc>
80107cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cb4:	75 07                	jne    80107cbd <walkpgdir+0x5a>
      return 0;
80107cb6:	b8 00 00 00 00       	mov    $0x0,%eax
80107cbb:	eb 44                	jmp    80107d01 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107cbd:	83 ec 04             	sub    $0x4,%esp
80107cc0:	68 00 10 00 00       	push   $0x1000
80107cc5:	6a 00                	push   $0x0
80107cc7:	ff 75 f4             	pushl  -0xc(%ebp)
80107cca:	e8 87 d5 ff ff       	call   80105256 <memset>
80107ccf:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107cd2:	83 ec 0c             	sub    $0xc,%esp
80107cd5:	ff 75 f4             	pushl  -0xc(%ebp)
80107cd8:	e8 f7 fa ff ff       	call   801077d4 <v2p>
80107cdd:	83 c4 10             	add    $0x10,%esp
80107ce0:	83 c8 07             	or     $0x7,%eax
80107ce3:	89 c2                	mov    %eax,%edx
80107ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ce8:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107cea:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ced:	c1 e8 0c             	shr    $0xc,%eax
80107cf0:	25 ff 03 00 00       	and    $0x3ff,%eax
80107cf5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cff:	01 d0                	add    %edx,%eax
}
80107d01:	c9                   	leave  
80107d02:	c3                   	ret    

80107d03 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d03:	55                   	push   %ebp
80107d04:	89 e5                	mov    %esp,%ebp
80107d06:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107d09:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d0c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d14:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d17:	8b 45 10             	mov    0x10(%ebp),%eax
80107d1a:	01 d0                	add    %edx,%eax
80107d1c:	83 e8 01             	sub    $0x1,%eax
80107d1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d27:	83 ec 04             	sub    $0x4,%esp
80107d2a:	6a 01                	push   $0x1
80107d2c:	ff 75 f4             	pushl  -0xc(%ebp)
80107d2f:	ff 75 08             	pushl  0x8(%ebp)
80107d32:	e8 2c ff ff ff       	call   80107c63 <walkpgdir>
80107d37:	83 c4 10             	add    $0x10,%esp
80107d3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d3d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d41:	75 07                	jne    80107d4a <mappages+0x47>
      return -1;
80107d43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d48:	eb 47                	jmp    80107d91 <mappages+0x8e>
    if(*pte & PTE_P)
80107d4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d4d:	8b 00                	mov    (%eax),%eax
80107d4f:	83 e0 01             	and    $0x1,%eax
80107d52:	85 c0                	test   %eax,%eax
80107d54:	74 0d                	je     80107d63 <mappages+0x60>
      panic("remap");
80107d56:	83 ec 0c             	sub    $0xc,%esp
80107d59:	68 40 8b 10 80       	push   $0x80108b40
80107d5e:	e8 03 88 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80107d63:	8b 45 18             	mov    0x18(%ebp),%eax
80107d66:	0b 45 14             	or     0x14(%ebp),%eax
80107d69:	83 c8 01             	or     $0x1,%eax
80107d6c:	89 c2                	mov    %eax,%edx
80107d6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d71:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d79:	74 10                	je     80107d8b <mappages+0x88>
      break;
    a += PGSIZE;
80107d7b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d82:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107d89:	eb 9c                	jmp    80107d27 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107d8b:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107d8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d91:	c9                   	leave  
80107d92:	c3                   	ret    

80107d93 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107d93:	55                   	push   %ebp
80107d94:	89 e5                	mov    %esp,%ebp
80107d96:	53                   	push   %ebx
80107d97:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107d9a:	e8 46 ae ff ff       	call   80102be5 <kalloc>
80107d9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107da2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107da6:	75 0a                	jne    80107db2 <setupkvm+0x1f>
    return 0;
80107da8:	b8 00 00 00 00       	mov    $0x0,%eax
80107dad:	e9 8e 00 00 00       	jmp    80107e40 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107db2:	83 ec 04             	sub    $0x4,%esp
80107db5:	68 00 10 00 00       	push   $0x1000
80107dba:	6a 00                	push   $0x0
80107dbc:	ff 75 f0             	pushl  -0x10(%ebp)
80107dbf:	e8 92 d4 ff ff       	call   80105256 <memset>
80107dc4:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107dc7:	83 ec 0c             	sub    $0xc,%esp
80107dca:	68 00 00 00 0e       	push   $0xe000000
80107dcf:	e8 0d fa ff ff       	call   801077e1 <p2v>
80107dd4:	83 c4 10             	add    $0x10,%esp
80107dd7:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107ddc:	76 0d                	jbe    80107deb <setupkvm+0x58>
    panic("PHYSTOP too high");
80107dde:	83 ec 0c             	sub    $0xc,%esp
80107de1:	68 46 8b 10 80       	push   $0x80108b46
80107de6:	e8 7b 87 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107deb:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107df2:	eb 40                	jmp    80107e34 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df7:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfd:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e03:	8b 58 08             	mov    0x8(%eax),%ebx
80107e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e09:	8b 40 04             	mov    0x4(%eax),%eax
80107e0c:	29 c3                	sub    %eax,%ebx
80107e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e11:	8b 00                	mov    (%eax),%eax
80107e13:	83 ec 0c             	sub    $0xc,%esp
80107e16:	51                   	push   %ecx
80107e17:	52                   	push   %edx
80107e18:	53                   	push   %ebx
80107e19:	50                   	push   %eax
80107e1a:	ff 75 f0             	pushl  -0x10(%ebp)
80107e1d:	e8 e1 fe ff ff       	call   80107d03 <mappages>
80107e22:	83 c4 20             	add    $0x20,%esp
80107e25:	85 c0                	test   %eax,%eax
80107e27:	79 07                	jns    80107e30 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107e29:	b8 00 00 00 00       	mov    $0x0,%eax
80107e2e:	eb 10                	jmp    80107e40 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e30:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e34:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107e3b:	72 b7                	jb     80107df4 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e43:	c9                   	leave  
80107e44:	c3                   	ret    

80107e45 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e45:	55                   	push   %ebp
80107e46:	89 e5                	mov    %esp,%ebp
80107e48:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e4b:	e8 43 ff ff ff       	call   80107d93 <setupkvm>
80107e50:	a3 38 51 11 80       	mov    %eax,0x80115138
  switchkvm();
80107e55:	e8 03 00 00 00       	call   80107e5d <switchkvm>
}
80107e5a:	90                   	nop
80107e5b:	c9                   	leave  
80107e5c:	c3                   	ret    

80107e5d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e5d:	55                   	push   %ebp
80107e5e:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107e60:	a1 38 51 11 80       	mov    0x80115138,%eax
80107e65:	50                   	push   %eax
80107e66:	e8 69 f9 ff ff       	call   801077d4 <v2p>
80107e6b:	83 c4 04             	add    $0x4,%esp
80107e6e:	50                   	push   %eax
80107e6f:	e8 54 f9 ff ff       	call   801077c8 <lcr3>
80107e74:	83 c4 04             	add    $0x4,%esp
}
80107e77:	90                   	nop
80107e78:	c9                   	leave  
80107e79:	c3                   	ret    

80107e7a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e7a:	55                   	push   %ebp
80107e7b:	89 e5                	mov    %esp,%ebp
80107e7d:	56                   	push   %esi
80107e7e:	53                   	push   %ebx
  pushcli();
80107e7f:	e8 cc d2 ff ff       	call   80105150 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107e84:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e8a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e91:	83 c2 08             	add    $0x8,%edx
80107e94:	89 d6                	mov    %edx,%esi
80107e96:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e9d:	83 c2 08             	add    $0x8,%edx
80107ea0:	c1 ea 10             	shr    $0x10,%edx
80107ea3:	89 d3                	mov    %edx,%ebx
80107ea5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107eac:	83 c2 08             	add    $0x8,%edx
80107eaf:	c1 ea 18             	shr    $0x18,%edx
80107eb2:	89 d1                	mov    %edx,%ecx
80107eb4:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107ebb:	67 00 
80107ebd:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107ec4:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107eca:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ed1:	83 e2 f0             	and    $0xfffffff0,%edx
80107ed4:	83 ca 09             	or     $0x9,%edx
80107ed7:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107edd:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ee4:	83 ca 10             	or     $0x10,%edx
80107ee7:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107eed:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ef4:	83 e2 9f             	and    $0xffffff9f,%edx
80107ef7:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107efd:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f04:	83 ca 80             	or     $0xffffff80,%edx
80107f07:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f0d:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f14:	83 e2 f0             	and    $0xfffffff0,%edx
80107f17:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f1d:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f24:	83 e2 ef             	and    $0xffffffef,%edx
80107f27:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f2d:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f34:	83 e2 df             	and    $0xffffffdf,%edx
80107f37:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f3d:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f44:	83 ca 40             	or     $0x40,%edx
80107f47:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f4d:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f54:	83 e2 7f             	and    $0x7f,%edx
80107f57:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f5d:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107f63:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f69:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f70:	83 e2 ef             	and    $0xffffffef,%edx
80107f73:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107f79:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f7f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107f85:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f8b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107f92:	8b 52 08             	mov    0x8(%edx),%edx
80107f95:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107f9b:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107f9e:	83 ec 0c             	sub    $0xc,%esp
80107fa1:	6a 30                	push   $0x30
80107fa3:	e8 f3 f7 ff ff       	call   8010779b <ltr>
80107fa8:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107fab:	8b 45 08             	mov    0x8(%ebp),%eax
80107fae:	8b 40 04             	mov    0x4(%eax),%eax
80107fb1:	85 c0                	test   %eax,%eax
80107fb3:	75 0d                	jne    80107fc2 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80107fb5:	83 ec 0c             	sub    $0xc,%esp
80107fb8:	68 57 8b 10 80       	push   $0x80108b57
80107fbd:	e8 a4 85 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc5:	8b 40 04             	mov    0x4(%eax),%eax
80107fc8:	83 ec 0c             	sub    $0xc,%esp
80107fcb:	50                   	push   %eax
80107fcc:	e8 03 f8 ff ff       	call   801077d4 <v2p>
80107fd1:	83 c4 10             	add    $0x10,%esp
80107fd4:	83 ec 0c             	sub    $0xc,%esp
80107fd7:	50                   	push   %eax
80107fd8:	e8 eb f7 ff ff       	call   801077c8 <lcr3>
80107fdd:	83 c4 10             	add    $0x10,%esp
  popcli();
80107fe0:	e8 b0 d1 ff ff       	call   80105195 <popcli>
}
80107fe5:	90                   	nop
80107fe6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107fe9:	5b                   	pop    %ebx
80107fea:	5e                   	pop    %esi
80107feb:	5d                   	pop    %ebp
80107fec:	c3                   	ret    

80107fed <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107fed:	55                   	push   %ebp
80107fee:	89 e5                	mov    %esp,%ebp
80107ff0:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107ff3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107ffa:	76 0d                	jbe    80108009 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107ffc:	83 ec 0c             	sub    $0xc,%esp
80107fff:	68 6b 8b 10 80       	push   $0x80108b6b
80108004:	e8 5d 85 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108009:	e8 d7 ab ff ff       	call   80102be5 <kalloc>
8010800e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108011:	83 ec 04             	sub    $0x4,%esp
80108014:	68 00 10 00 00       	push   $0x1000
80108019:	6a 00                	push   $0x0
8010801b:	ff 75 f4             	pushl  -0xc(%ebp)
8010801e:	e8 33 d2 ff ff       	call   80105256 <memset>
80108023:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108026:	83 ec 0c             	sub    $0xc,%esp
80108029:	ff 75 f4             	pushl  -0xc(%ebp)
8010802c:	e8 a3 f7 ff ff       	call   801077d4 <v2p>
80108031:	83 c4 10             	add    $0x10,%esp
80108034:	83 ec 0c             	sub    $0xc,%esp
80108037:	6a 06                	push   $0x6
80108039:	50                   	push   %eax
8010803a:	68 00 10 00 00       	push   $0x1000
8010803f:	6a 00                	push   $0x0
80108041:	ff 75 08             	pushl  0x8(%ebp)
80108044:	e8 ba fc ff ff       	call   80107d03 <mappages>
80108049:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010804c:	83 ec 04             	sub    $0x4,%esp
8010804f:	ff 75 10             	pushl  0x10(%ebp)
80108052:	ff 75 0c             	pushl  0xc(%ebp)
80108055:	ff 75 f4             	pushl  -0xc(%ebp)
80108058:	e8 b8 d2 ff ff       	call   80105315 <memmove>
8010805d:	83 c4 10             	add    $0x10,%esp
}
80108060:	90                   	nop
80108061:	c9                   	leave  
80108062:	c3                   	ret    

80108063 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108063:	55                   	push   %ebp
80108064:	89 e5                	mov    %esp,%ebp
80108066:	53                   	push   %ebx
80108067:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010806a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806d:	25 ff 0f 00 00       	and    $0xfff,%eax
80108072:	85 c0                	test   %eax,%eax
80108074:	74 0d                	je     80108083 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108076:	83 ec 0c             	sub    $0xc,%esp
80108079:	68 88 8b 10 80       	push   $0x80108b88
8010807e:	e8 e3 84 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108083:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010808a:	e9 95 00 00 00       	jmp    80108124 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010808f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108095:	01 d0                	add    %edx,%eax
80108097:	83 ec 04             	sub    $0x4,%esp
8010809a:	6a 00                	push   $0x0
8010809c:	50                   	push   %eax
8010809d:	ff 75 08             	pushl  0x8(%ebp)
801080a0:	e8 be fb ff ff       	call   80107c63 <walkpgdir>
801080a5:	83 c4 10             	add    $0x10,%esp
801080a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080af:	75 0d                	jne    801080be <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801080b1:	83 ec 0c             	sub    $0xc,%esp
801080b4:	68 ab 8b 10 80       	push   $0x80108bab
801080b9:	e8 a8 84 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801080be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080c1:	8b 00                	mov    (%eax),%eax
801080c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801080cb:	8b 45 18             	mov    0x18(%ebp),%eax
801080ce:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080d1:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801080d6:	77 0b                	ja     801080e3 <loaduvm+0x80>
      n = sz - i;
801080d8:	8b 45 18             	mov    0x18(%ebp),%eax
801080db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080de:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080e1:	eb 07                	jmp    801080ea <loaduvm+0x87>
    else
      n = PGSIZE;
801080e3:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801080ea:	8b 55 14             	mov    0x14(%ebp),%edx
801080ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801080f3:	83 ec 0c             	sub    $0xc,%esp
801080f6:	ff 75 e8             	pushl  -0x18(%ebp)
801080f9:	e8 e3 f6 ff ff       	call   801077e1 <p2v>
801080fe:	83 c4 10             	add    $0x10,%esp
80108101:	ff 75 f0             	pushl  -0x10(%ebp)
80108104:	53                   	push   %ebx
80108105:	50                   	push   %eax
80108106:	ff 75 10             	pushl  0x10(%ebp)
80108109:	e8 85 9d ff ff       	call   80101e93 <readi>
8010810e:	83 c4 10             	add    $0x10,%esp
80108111:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108114:	74 07                	je     8010811d <loaduvm+0xba>
      return -1;
80108116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010811b:	eb 18                	jmp    80108135 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010811d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108127:	3b 45 18             	cmp    0x18(%ebp),%eax
8010812a:	0f 82 5f ff ff ff    	jb     8010808f <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108130:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108135:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108138:	c9                   	leave  
80108139:	c3                   	ret    

8010813a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010813a:	55                   	push   %ebp
8010813b:	89 e5                	mov    %esp,%ebp
8010813d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108140:	8b 45 10             	mov    0x10(%ebp),%eax
80108143:	85 c0                	test   %eax,%eax
80108145:	79 0a                	jns    80108151 <allocuvm+0x17>
    return 0;
80108147:	b8 00 00 00 00       	mov    $0x0,%eax
8010814c:	e9 b0 00 00 00       	jmp    80108201 <allocuvm+0xc7>
  if(newsz < oldsz)
80108151:	8b 45 10             	mov    0x10(%ebp),%eax
80108154:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108157:	73 08                	jae    80108161 <allocuvm+0x27>
    return oldsz;
80108159:	8b 45 0c             	mov    0xc(%ebp),%eax
8010815c:	e9 a0 00 00 00       	jmp    80108201 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108161:	8b 45 0c             	mov    0xc(%ebp),%eax
80108164:	05 ff 0f 00 00       	add    $0xfff,%eax
80108169:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010816e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108171:	eb 7f                	jmp    801081f2 <allocuvm+0xb8>
    mem = kalloc();
80108173:	e8 6d aa ff ff       	call   80102be5 <kalloc>
80108178:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010817b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010817f:	75 2b                	jne    801081ac <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108181:	83 ec 0c             	sub    $0xc,%esp
80108184:	68 c9 8b 10 80       	push   $0x80108bc9
80108189:	e8 38 82 ff ff       	call   801003c6 <cprintf>
8010818e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108191:	83 ec 04             	sub    $0x4,%esp
80108194:	ff 75 0c             	pushl  0xc(%ebp)
80108197:	ff 75 10             	pushl  0x10(%ebp)
8010819a:	ff 75 08             	pushl  0x8(%ebp)
8010819d:	e8 61 00 00 00       	call   80108203 <deallocuvm>
801081a2:	83 c4 10             	add    $0x10,%esp
      return 0;
801081a5:	b8 00 00 00 00       	mov    $0x0,%eax
801081aa:	eb 55                	jmp    80108201 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801081ac:	83 ec 04             	sub    $0x4,%esp
801081af:	68 00 10 00 00       	push   $0x1000
801081b4:	6a 00                	push   $0x0
801081b6:	ff 75 f0             	pushl  -0x10(%ebp)
801081b9:	e8 98 d0 ff ff       	call   80105256 <memset>
801081be:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801081c1:	83 ec 0c             	sub    $0xc,%esp
801081c4:	ff 75 f0             	pushl  -0x10(%ebp)
801081c7:	e8 08 f6 ff ff       	call   801077d4 <v2p>
801081cc:	83 c4 10             	add    $0x10,%esp
801081cf:	89 c2                	mov    %eax,%edx
801081d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d4:	83 ec 0c             	sub    $0xc,%esp
801081d7:	6a 06                	push   $0x6
801081d9:	52                   	push   %edx
801081da:	68 00 10 00 00       	push   $0x1000
801081df:	50                   	push   %eax
801081e0:	ff 75 08             	pushl  0x8(%ebp)
801081e3:	e8 1b fb ff ff       	call   80107d03 <mappages>
801081e8:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801081eb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801081f8:	0f 82 75 ff ff ff    	jb     80108173 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801081fe:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108201:	c9                   	leave  
80108202:	c3                   	ret    

80108203 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108203:	55                   	push   %ebp
80108204:	89 e5                	mov    %esp,%ebp
80108206:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108209:	8b 45 10             	mov    0x10(%ebp),%eax
8010820c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010820f:	72 08                	jb     80108219 <deallocuvm+0x16>
    return oldsz;
80108211:	8b 45 0c             	mov    0xc(%ebp),%eax
80108214:	e9 a5 00 00 00       	jmp    801082be <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108219:	8b 45 10             	mov    0x10(%ebp),%eax
8010821c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108221:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108226:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108229:	e9 81 00 00 00       	jmp    801082af <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010822e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108231:	83 ec 04             	sub    $0x4,%esp
80108234:	6a 00                	push   $0x0
80108236:	50                   	push   %eax
80108237:	ff 75 08             	pushl  0x8(%ebp)
8010823a:	e8 24 fa ff ff       	call   80107c63 <walkpgdir>
8010823f:	83 c4 10             	add    $0x10,%esp
80108242:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108245:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108249:	75 09                	jne    80108254 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010824b:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108252:	eb 54                	jmp    801082a8 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108254:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108257:	8b 00                	mov    (%eax),%eax
80108259:	83 e0 01             	and    $0x1,%eax
8010825c:	85 c0                	test   %eax,%eax
8010825e:	74 48                	je     801082a8 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108260:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108263:	8b 00                	mov    (%eax),%eax
80108265:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010826a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010826d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108271:	75 0d                	jne    80108280 <deallocuvm+0x7d>
        panic("kfree");
80108273:	83 ec 0c             	sub    $0xc,%esp
80108276:	68 e1 8b 10 80       	push   $0x80108be1
8010827b:	e8 e6 82 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108280:	83 ec 0c             	sub    $0xc,%esp
80108283:	ff 75 ec             	pushl  -0x14(%ebp)
80108286:	e8 56 f5 ff ff       	call   801077e1 <p2v>
8010828b:	83 c4 10             	add    $0x10,%esp
8010828e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108291:	83 ec 0c             	sub    $0xc,%esp
80108294:	ff 75 e8             	pushl  -0x18(%ebp)
80108297:	e8 ac a8 ff ff       	call   80102b48 <kfree>
8010829c:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010829f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801082a8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082b5:	0f 82 73 ff ff ff    	jb     8010822e <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801082bb:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082be:	c9                   	leave  
801082bf:	c3                   	ret    

801082c0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801082c0:	55                   	push   %ebp
801082c1:	89 e5                	mov    %esp,%ebp
801082c3:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801082c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801082ca:	75 0d                	jne    801082d9 <freevm+0x19>
    panic("freevm: no pgdir");
801082cc:	83 ec 0c             	sub    $0xc,%esp
801082cf:	68 e7 8b 10 80       	push   $0x80108be7
801082d4:	e8 8d 82 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801082d9:	83 ec 04             	sub    $0x4,%esp
801082dc:	6a 00                	push   $0x0
801082de:	68 00 00 00 80       	push   $0x80000000
801082e3:	ff 75 08             	pushl  0x8(%ebp)
801082e6:	e8 18 ff ff ff       	call   80108203 <deallocuvm>
801082eb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082f5:	eb 4f                	jmp    80108346 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801082f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108301:	8b 45 08             	mov    0x8(%ebp),%eax
80108304:	01 d0                	add    %edx,%eax
80108306:	8b 00                	mov    (%eax),%eax
80108308:	83 e0 01             	and    $0x1,%eax
8010830b:	85 c0                	test   %eax,%eax
8010830d:	74 33                	je     80108342 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010830f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108312:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108319:	8b 45 08             	mov    0x8(%ebp),%eax
8010831c:	01 d0                	add    %edx,%eax
8010831e:	8b 00                	mov    (%eax),%eax
80108320:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108325:	83 ec 0c             	sub    $0xc,%esp
80108328:	50                   	push   %eax
80108329:	e8 b3 f4 ff ff       	call   801077e1 <p2v>
8010832e:	83 c4 10             	add    $0x10,%esp
80108331:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108334:	83 ec 0c             	sub    $0xc,%esp
80108337:	ff 75 f0             	pushl  -0x10(%ebp)
8010833a:	e8 09 a8 ff ff       	call   80102b48 <kfree>
8010833f:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108342:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108346:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010834d:	76 a8                	jbe    801082f7 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010834f:	83 ec 0c             	sub    $0xc,%esp
80108352:	ff 75 08             	pushl  0x8(%ebp)
80108355:	e8 ee a7 ff ff       	call   80102b48 <kfree>
8010835a:	83 c4 10             	add    $0x10,%esp
}
8010835d:	90                   	nop
8010835e:	c9                   	leave  
8010835f:	c3                   	ret    

80108360 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108360:	55                   	push   %ebp
80108361:	89 e5                	mov    %esp,%ebp
80108363:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108366:	83 ec 04             	sub    $0x4,%esp
80108369:	6a 00                	push   $0x0
8010836b:	ff 75 0c             	pushl  0xc(%ebp)
8010836e:	ff 75 08             	pushl  0x8(%ebp)
80108371:	e8 ed f8 ff ff       	call   80107c63 <walkpgdir>
80108376:	83 c4 10             	add    $0x10,%esp
80108379:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010837c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108380:	75 0d                	jne    8010838f <clearpteu+0x2f>
    panic("clearpteu");
80108382:	83 ec 0c             	sub    $0xc,%esp
80108385:	68 f8 8b 10 80       	push   $0x80108bf8
8010838a:	e8 d7 81 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010838f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108392:	8b 00                	mov    (%eax),%eax
80108394:	83 e0 fb             	and    $0xfffffffb,%eax
80108397:	89 c2                	mov    %eax,%edx
80108399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839c:	89 10                	mov    %edx,(%eax)
}
8010839e:	90                   	nop
8010839f:	c9                   	leave  
801083a0:	c3                   	ret    

801083a1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801083a1:	55                   	push   %ebp
801083a2:	89 e5                	mov    %esp,%ebp
801083a4:	53                   	push   %ebx
801083a5:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801083a8:	e8 e6 f9 ff ff       	call   80107d93 <setupkvm>
801083ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083b4:	75 0a                	jne    801083c0 <copyuvm+0x1f>
    return 0;
801083b6:	b8 00 00 00 00       	mov    $0x0,%eax
801083bb:	e9 f8 00 00 00       	jmp    801084b8 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801083c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083c7:	e9 c4 00 00 00       	jmp    80108490 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801083cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cf:	83 ec 04             	sub    $0x4,%esp
801083d2:	6a 00                	push   $0x0
801083d4:	50                   	push   %eax
801083d5:	ff 75 08             	pushl  0x8(%ebp)
801083d8:	e8 86 f8 ff ff       	call   80107c63 <walkpgdir>
801083dd:	83 c4 10             	add    $0x10,%esp
801083e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083e7:	75 0d                	jne    801083f6 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801083e9:	83 ec 0c             	sub    $0xc,%esp
801083ec:	68 02 8c 10 80       	push   $0x80108c02
801083f1:	e8 70 81 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801083f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f9:	8b 00                	mov    (%eax),%eax
801083fb:	83 e0 01             	and    $0x1,%eax
801083fe:	85 c0                	test   %eax,%eax
80108400:	75 0d                	jne    8010840f <copyuvm+0x6e>
      panic("copyuvm: page not present");
80108402:	83 ec 0c             	sub    $0xc,%esp
80108405:	68 1c 8c 10 80       	push   $0x80108c1c
8010840a:	e8 57 81 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010840f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108412:	8b 00                	mov    (%eax),%eax
80108414:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108419:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010841c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010841f:	8b 00                	mov    (%eax),%eax
80108421:	25 ff 0f 00 00       	and    $0xfff,%eax
80108426:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108429:	e8 b7 a7 ff ff       	call   80102be5 <kalloc>
8010842e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108435:	74 6a                	je     801084a1 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108437:	83 ec 0c             	sub    $0xc,%esp
8010843a:	ff 75 e8             	pushl  -0x18(%ebp)
8010843d:	e8 9f f3 ff ff       	call   801077e1 <p2v>
80108442:	83 c4 10             	add    $0x10,%esp
80108445:	83 ec 04             	sub    $0x4,%esp
80108448:	68 00 10 00 00       	push   $0x1000
8010844d:	50                   	push   %eax
8010844e:	ff 75 e0             	pushl  -0x20(%ebp)
80108451:	e8 bf ce ff ff       	call   80105315 <memmove>
80108456:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108459:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010845c:	83 ec 0c             	sub    $0xc,%esp
8010845f:	ff 75 e0             	pushl  -0x20(%ebp)
80108462:	e8 6d f3 ff ff       	call   801077d4 <v2p>
80108467:	83 c4 10             	add    $0x10,%esp
8010846a:	89 c2                	mov    %eax,%edx
8010846c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846f:	83 ec 0c             	sub    $0xc,%esp
80108472:	53                   	push   %ebx
80108473:	52                   	push   %edx
80108474:	68 00 10 00 00       	push   $0x1000
80108479:	50                   	push   %eax
8010847a:	ff 75 f0             	pushl  -0x10(%ebp)
8010847d:	e8 81 f8 ff ff       	call   80107d03 <mappages>
80108482:	83 c4 20             	add    $0x20,%esp
80108485:	85 c0                	test   %eax,%eax
80108487:	78 1b                	js     801084a4 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108489:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108493:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108496:	0f 82 30 ff ff ff    	jb     801083cc <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010849c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010849f:	eb 17                	jmp    801084b8 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801084a1:	90                   	nop
801084a2:	eb 01                	jmp    801084a5 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801084a4:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801084a5:	83 ec 0c             	sub    $0xc,%esp
801084a8:	ff 75 f0             	pushl  -0x10(%ebp)
801084ab:	e8 10 fe ff ff       	call   801082c0 <freevm>
801084b0:	83 c4 10             	add    $0x10,%esp
  return 0;
801084b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084bb:	c9                   	leave  
801084bc:	c3                   	ret    

801084bd <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801084bd:	55                   	push   %ebp
801084be:	89 e5                	mov    %esp,%ebp
801084c0:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084c3:	83 ec 04             	sub    $0x4,%esp
801084c6:	6a 00                	push   $0x0
801084c8:	ff 75 0c             	pushl  0xc(%ebp)
801084cb:	ff 75 08             	pushl  0x8(%ebp)
801084ce:	e8 90 f7 ff ff       	call   80107c63 <walkpgdir>
801084d3:	83 c4 10             	add    $0x10,%esp
801084d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801084d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dc:	8b 00                	mov    (%eax),%eax
801084de:	83 e0 01             	and    $0x1,%eax
801084e1:	85 c0                	test   %eax,%eax
801084e3:	75 07                	jne    801084ec <uva2ka+0x2f>
    return 0;
801084e5:	b8 00 00 00 00       	mov    $0x0,%eax
801084ea:	eb 29                	jmp    80108515 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801084ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ef:	8b 00                	mov    (%eax),%eax
801084f1:	83 e0 04             	and    $0x4,%eax
801084f4:	85 c0                	test   %eax,%eax
801084f6:	75 07                	jne    801084ff <uva2ka+0x42>
    return 0;
801084f8:	b8 00 00 00 00       	mov    $0x0,%eax
801084fd:	eb 16                	jmp    80108515 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801084ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108502:	8b 00                	mov    (%eax),%eax
80108504:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108509:	83 ec 0c             	sub    $0xc,%esp
8010850c:	50                   	push   %eax
8010850d:	e8 cf f2 ff ff       	call   801077e1 <p2v>
80108512:	83 c4 10             	add    $0x10,%esp
}
80108515:	c9                   	leave  
80108516:	c3                   	ret    

80108517 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108517:	55                   	push   %ebp
80108518:	89 e5                	mov    %esp,%ebp
8010851a:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010851d:	8b 45 10             	mov    0x10(%ebp),%eax
80108520:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108523:	eb 7f                	jmp    801085a4 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108525:	8b 45 0c             	mov    0xc(%ebp),%eax
80108528:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010852d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108530:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108533:	83 ec 08             	sub    $0x8,%esp
80108536:	50                   	push   %eax
80108537:	ff 75 08             	pushl  0x8(%ebp)
8010853a:	e8 7e ff ff ff       	call   801084bd <uva2ka>
8010853f:	83 c4 10             	add    $0x10,%esp
80108542:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108545:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108549:	75 07                	jne    80108552 <copyout+0x3b>
      return -1;
8010854b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108550:	eb 61                	jmp    801085b3 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108552:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108555:	2b 45 0c             	sub    0xc(%ebp),%eax
80108558:	05 00 10 00 00       	add    $0x1000,%eax
8010855d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108560:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108563:	3b 45 14             	cmp    0x14(%ebp),%eax
80108566:	76 06                	jbe    8010856e <copyout+0x57>
      n = len;
80108568:	8b 45 14             	mov    0x14(%ebp),%eax
8010856b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010856e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108571:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108574:	89 c2                	mov    %eax,%edx
80108576:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108579:	01 d0                	add    %edx,%eax
8010857b:	83 ec 04             	sub    $0x4,%esp
8010857e:	ff 75 f0             	pushl  -0x10(%ebp)
80108581:	ff 75 f4             	pushl  -0xc(%ebp)
80108584:	50                   	push   %eax
80108585:	e8 8b cd ff ff       	call   80105315 <memmove>
8010858a:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010858d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108590:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108596:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108599:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010859c:	05 00 10 00 00       	add    $0x1000,%eax
801085a1:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801085a4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801085a8:	0f 85 77 ff ff ff    	jne    80108525 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801085ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085b3:	c9                   	leave  
801085b4:	c3                   	ret    
