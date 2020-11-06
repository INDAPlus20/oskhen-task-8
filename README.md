# oskhen-task-8
Some MIPS assembly


## Multiplication
For comparison, here's the x86_64 dump of the two functions:
```
000000000000113f <multiply>:
    113f:	f3 0f 1e fa          	endbr64 
    1143:	55                   	push   rbp
    1144:	48 89 e5             	mov    rbp,rsp
    1147:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    114a:	89 75 e8             	mov    DWORD PTR [rbp-0x18],esi
    114d:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
    1154:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
    115b:	eb 0a                	jmp    1167 <multiply+0x28>
    115d:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    1160:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1163:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1
    1167:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
    116a:	3b 45 ec             	cmp    eax,DWORD PTR [rbp-0x14]
    116d:	7c ee                	jl     115d <multiply+0x1e>
    116f:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1172:	5d                   	pop    rbp
    1173:	c3                   	ret    
```
```
0000000000001174 <faculty>:
    1174:	f3 0f 1e fa          	endbr64 
    1178:	55                   	push   rbp
    1179:	48 89 e5             	mov    rbp,rsp
    117c:	48 83 ec 18          	sub    rsp,0x18
    1180:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    1183:	c7 45 fc 01 00 00 00 	mov    DWORD PTR [rbp-0x4],0x1
    118a:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    118d:	89 45 f8             	mov    DWORD PTR [rbp-0x8],eax
    1190:	eb 16                	jmp    11a8 <faculty+0x34>
    1192:	8b 55 f8             	mov    edx,DWORD PTR [rbp-0x8]
    1195:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1198:	89 d6                	mov    esi,edx
    119a:	89 c7                	mov    edi,eax
    119c:	e8 9e ff ff ff       	call   113f <multiply>
    11a1:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    11a4:	83 6d f8 01          	sub    DWORD PTR [rbp-0x8],0x1
    11a8:	83 7d f8 01          	cmp    DWORD PTR [rbp-0x8],0x1
    11ac:	7f e4                	jg     1192 <faculty+0x1e>
    11ae:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11b1:	c9                   	leave  
    11b2:	c3                   	ret    
    11b3:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
    11ba:	00 00 00 
    11bd:	0f 1f 00             	nop    DWORD PTR [rax]
```
The two nop instructions at the end of faculty after the return instruction seem really out of place, especially since they take arguments? Feels like random bits, or something that goes way above my head.

After writing multiplication.asm, the two aren't really comparable since x86_64 seemingly does everything on the stack.

My own written takes in an integer and inputs faculty(n) using syscalls for input/output. Had some trouble debugging since the registers kept overwriting themselves, not sure what the calling/register conventions are so my solution is probably not following those. Especially the $ra with `jal` was troublesome, since I had the calling chain of `main -> faculty -> multiplication`, and using `jal` the $ra got overwritten when trying to jump back from faculty -> main. Other than conventions, nothing strange, not having scopes was annoying but everything worked without any problems.


## Sieve
Spent so much time coding I can't be bothered to document it.. Implemented a sieve as expected, nothing fancy. Played around with a dynamic version afterwards, implemented a ceil(SQRT(n)) macro to improve runtime and disabled printing because MARS couldn't handle printing primes up to `2**16`. Lightningfast, dynamic allocation wasn't much more difficult at all. Wondering about hardware limitations, should be possible to do primes up to `2**32 - 1`, *in theory*, but not much room for the processor to move around so maybe `2**30` could work?

Edit: 2**30 gave the error ```Runtime exception at 0x0040005c: request (1073741823) exceeds available heap storage (syscall 9)```. `2**20` worked but not `2**25`. All of those I got working were still ~1s runtime.

### Bitmap
Realised that instead of flipping bytes to 0 or 1, we could be flipping bits, since the condition "isprime" is binary. Started doing some bitmap(bitarray) testing, managed in theory but in practice the complexity and loop depth in assembly gets complicated when you want to implement this for a sieve.

Edit: Done with the implementation! Flipping a bit was done from the principle `A := A | (1 << (B & 00000111))`, where A is the correct byte and B mod 8 is the bitindex in that byte.

#### `A := A | (1 << (B & 00000111))` Explanation
B is global "i" counter, i.e how many bits from starting address.

A is `B >> 3`, or `B // 8`, which is the correct byte offset
(A isn't actually the offset but the byte at that offset, so address + offset).


`(B & 00000111)` is `B mod 8`, which gives us the correct "local" bitcounter given the global bitcounter, that is to say the bitindex in the relevant byte. 


`1 << (B mod 8)` gives us the correct bit to flip (In this case "make" 1), since we shift the 1 `B mod 8` times, with `B mod 8` being the index.

Then doing `A | (1 << (B & 00000111))` forces the bit to 1.