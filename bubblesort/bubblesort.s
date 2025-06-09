
bubblesort:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
       0:	00000013          	nop
       4:	00001137          	lui	sp,0x1
       8:	40010113          	addi	sp,sp,1024 # 1400 <_etext+0x400>
       c:	0040006f          	j	10 <main>

00000010 <main>:
      10:	bb010113          	addi	sp,sp,-1104
      14:	44112623          	sw	ra,1100(sp)
      18:	44812423          	sw	s0,1096(sp)
      1c:	45010413          	addi	s0,sp,1104
      20:	000017b7          	lui	a5,0x1
      24:	bbc40713          	addi	a4,s0,-1092
      28:	00078793          	mv	a5,a5
      2c:	42600693          	li	a3,1062
      30:	00068613          	mv	a2,a3
      34:	00078593          	mv	a1,a5
      38:	00070513          	mv	a0,a4
      3c:	134000ef          	jal	ra,170 <memcpy>
      40:	42600793          	li	a5,1062
      44:	fef42223          	sw	a5,-28(s0)
      48:	fe442783          	lw	a5,-28(s0)
      4c:	fff78793          	addi	a5,a5,-1 # fff <memcpy+0xe8f>
      50:	fef42423          	sw	a5,-24(s0)
      54:	1100006f          	j	164 <main+0x154>
      58:	fe042623          	sw	zero,-20(s0)
      5c:	0f00006f          	j	14c <main+0x13c>
      60:	fec42783          	lw	a5,-20(s0)
      64:	ff040713          	addi	a4,s0,-16
      68:	00f707b3          	add	a5,a4,a5
      6c:	bcc7c703          	lbu	a4,-1076(a5)
      70:	fec42783          	lw	a5,-20(s0)
      74:	00178793          	addi	a5,a5,1
      78:	ff040693          	addi	a3,s0,-16
      7c:	00f687b3          	add	a5,a3,a5
      80:	bcc7c783          	lbu	a5,-1076(a5)
      84:	0ae7fe63          	bleu	a4,a5,140 <main+0x130>
      88:	fec42783          	lw	a5,-20(s0)
      8c:	ff040713          	addi	a4,s0,-16
      90:	00f707b3          	add	a5,a4,a5
      94:	bcc7c703          	lbu	a4,-1076(a5)
      98:	fec42783          	lw	a5,-20(s0)
      9c:	00178793          	addi	a5,a5,1
      a0:	ff040693          	addi	a3,s0,-16
      a4:	00f687b3          	add	a5,a3,a5
      a8:	bcc7c783          	lbu	a5,-1076(a5)
      ac:	00f747b3          	xor	a5,a4,a5
      b0:	0ff7f713          	andi	a4,a5,255
      b4:	fec42783          	lw	a5,-20(s0)
      b8:	ff040693          	addi	a3,s0,-16
      bc:	00f687b3          	add	a5,a3,a5
      c0:	bce78623          	sb	a4,-1076(a5)
      c4:	fec42783          	lw	a5,-20(s0)
      c8:	00178793          	addi	a5,a5,1
      cc:	ff040713          	addi	a4,s0,-16
      d0:	00f707b3          	add	a5,a4,a5
      d4:	bcc7c683          	lbu	a3,-1076(a5)
      d8:	fec42783          	lw	a5,-20(s0)
      dc:	ff040713          	addi	a4,s0,-16
      e0:	00f707b3          	add	a5,a4,a5
      e4:	bcc7c703          	lbu	a4,-1076(a5)
      e8:	fec42783          	lw	a5,-20(s0)
      ec:	00178793          	addi	a5,a5,1
      f0:	00e6c733          	xor	a4,a3,a4
      f4:	0ff77713          	andi	a4,a4,255
      f8:	ff040693          	addi	a3,s0,-16
      fc:	00f687b3          	add	a5,a3,a5
     100:	bce78623          	sb	a4,-1076(a5)
     104:	fec42783          	lw	a5,-20(s0)
     108:	ff040713          	addi	a4,s0,-16
     10c:	00f707b3          	add	a5,a4,a5
     110:	bcc7c703          	lbu	a4,-1076(a5)
     114:	fec42783          	lw	a5,-20(s0)
     118:	00178793          	addi	a5,a5,1
     11c:	ff040693          	addi	a3,s0,-16
     120:	00f687b3          	add	a5,a3,a5
     124:	bcc7c783          	lbu	a5,-1076(a5)
     128:	00f747b3          	xor	a5,a4,a5
     12c:	0ff7f713          	andi	a4,a5,255
     130:	fec42783          	lw	a5,-20(s0)
     134:	ff040693          	addi	a3,s0,-16
     138:	00f687b3          	add	a5,a3,a5
     13c:	bce78623          	sb	a4,-1076(a5)
     140:	fec42783          	lw	a5,-20(s0)
     144:	00178793          	addi	a5,a5,1
     148:	fef42623          	sw	a5,-20(s0)
     14c:	fec42703          	lw	a4,-20(s0)
     150:	fe842783          	lw	a5,-24(s0)
     154:	f0f746e3          	blt	a4,a5,60 <main+0x50>
     158:	fe842783          	lw	a5,-24(s0)
     15c:	fff78793          	addi	a5,a5,-1
     160:	fef42423          	sw	a5,-24(s0)
     164:	fe842783          	lw	a5,-24(s0)
     168:	eef048e3          	bgtz	a5,58 <main+0x48>
     16c:	0000006f          	j	16c <main+0x15c>

00000170 <memcpy>:
     170:	00a5c7b3          	xor	a5,a1,a0
     174:	0037f793          	andi	a5,a5,3
     178:	00c508b3          	add	a7,a0,a2
     17c:	06079263          	bnez	a5,1e0 <memcpy+0x70>
     180:	00300793          	li	a5,3
     184:	04c7fe63          	bleu	a2,a5,1e0 <memcpy+0x70>
     188:	00357793          	andi	a5,a0,3
     18c:	00050713          	mv	a4,a0
     190:	06079863          	bnez	a5,200 <memcpy+0x90>
     194:	ffc8f613          	andi	a2,a7,-4
     198:	fe060793          	addi	a5,a2,-32
     19c:	08f76c63          	bltu	a4,a5,234 <memcpy+0xc4>
     1a0:	02c77c63          	bleu	a2,a4,1d8 <memcpy+0x68>
     1a4:	00058693          	mv	a3,a1
     1a8:	00070793          	mv	a5,a4
     1ac:	0006a803          	lw	a6,0(a3)
     1b0:	00478793          	addi	a5,a5,4
     1b4:	00468693          	addi	a3,a3,4
     1b8:	ff07ae23          	sw	a6,-4(a5)
     1bc:	fec7e8e3          	bltu	a5,a2,1ac <memcpy+0x3c>
     1c0:	fff60793          	addi	a5,a2,-1
     1c4:	40e787b3          	sub	a5,a5,a4
     1c8:	ffc7f793          	andi	a5,a5,-4
     1cc:	00478793          	addi	a5,a5,4
     1d0:	00f70733          	add	a4,a4,a5
     1d4:	00f585b3          	add	a1,a1,a5
     1d8:	01176863          	bltu	a4,a7,1e8 <memcpy+0x78>
     1dc:	00008067          	ret
     1e0:	00050713          	mv	a4,a0
     1e4:	ff157ce3          	bleu	a7,a0,1dc <memcpy+0x6c>
     1e8:	0005c783          	lbu	a5,0(a1)
     1ec:	00170713          	addi	a4,a4,1
     1f0:	00158593          	addi	a1,a1,1
     1f4:	fef70fa3          	sb	a5,-1(a4)
     1f8:	ff1768e3          	bltu	a4,a7,1e8 <memcpy+0x78>
     1fc:	00008067          	ret
     200:	0005c683          	lbu	a3,0(a1)
     204:	00170713          	addi	a4,a4,1
     208:	00377793          	andi	a5,a4,3
     20c:	fed70fa3          	sb	a3,-1(a4)
     210:	00158593          	addi	a1,a1,1
     214:	f80780e3          	beqz	a5,194 <memcpy+0x24>
     218:	0005c683          	lbu	a3,0(a1)
     21c:	00170713          	addi	a4,a4,1
     220:	00377793          	andi	a5,a4,3
     224:	fed70fa3          	sb	a3,-1(a4)
     228:	00158593          	addi	a1,a1,1
     22c:	fc079ae3          	bnez	a5,200 <memcpy+0x90>
     230:	f65ff06f          	j	194 <memcpy+0x24>
     234:	0005a683          	lw	a3,0(a1)
     238:	0045a283          	lw	t0,4(a1)
     23c:	0085af83          	lw	t6,8(a1)
     240:	00c5af03          	lw	t5,12(a1)
     244:	0105ae83          	lw	t4,16(a1)
     248:	0145ae03          	lw	t3,20(a1)
     24c:	0185a303          	lw	t1,24(a1)
     250:	01c5a803          	lw	a6,28(a1)
     254:	02458593          	addi	a1,a1,36
     258:	00d72023          	sw	a3,0(a4)
     25c:	ffc5a683          	lw	a3,-4(a1)
     260:	00572223          	sw	t0,4(a4)
     264:	01f72423          	sw	t6,8(a4)
     268:	01e72623          	sw	t5,12(a4)
     26c:	01d72823          	sw	t4,16(a4)
     270:	01c72a23          	sw	t3,20(a4)
     274:	00672c23          	sw	t1,24(a4)
     278:	01072e23          	sw	a6,28(a4)
     27c:	02470713          	addi	a4,a4,36
     280:	fed72e23          	sw	a3,-4(a4)
     284:	faf768e3          	bltu	a4,a5,234 <memcpy+0xc4>
     288:	f19ff06f          	j	1a0 <memcpy+0x30>
	...
