
cordic:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
       0:	00000013          	nop
       4:	00005137          	lui	sp,0x5
       8:	1400006f          	j	148 <main>

0000000c <cordic>:
       c:	fc010113          	addi	sp,sp,-64 # 4fc0 <_etext+0x3fc0>
      10:	02812e23          	sw	s0,60(sp)
      14:	04010413          	addi	s0,sp,64
      18:	fca42623          	sw	a0,-52(s0)
      1c:	fcb42423          	sw	a1,-56(s0)
      20:	fcc42223          	sw	a2,-60(s0)
      24:	26dd47b7          	lui	a5,0x26dd4
      28:	b6a78793          	addi	a5,a5,-1174 # 26dd3b6a <_etext+0x26dd2b6a>
      2c:	fef42623          	sw	a5,-20(s0)
      30:	fe042423          	sw	zero,-24(s0)
      34:	fcc42783          	lw	a5,-52(s0)
      38:	fef42223          	sw	a5,-28(s0)
      3c:	fe042023          	sw	zero,-32(s0)
      40:	0d40006f          	j	114 <cordic+0x108>
      44:	fe042783          	lw	a5,-32(s0)
      48:	fe842703          	lw	a4,-24(s0)
      4c:	40f757b3          	sra	a5,a4,a5
      50:	fcf42e23          	sw	a5,-36(s0)
      54:	fe042783          	lw	a5,-32(s0)
      58:	fec42703          	lw	a4,-20(s0)
      5c:	40f757b3          	sra	a5,a4,a5
      60:	fcf42c23          	sw	a5,-40(s0)
      64:	fe442783          	lw	a5,-28(s0)
      68:	0407ca63          	bltz	a5,bc <cordic+0xb0>
      6c:	fec42783          	lw	a5,-20(s0)
      70:	fcf42a23          	sw	a5,-44(s0)
      74:	fec42703          	lw	a4,-20(s0)
      78:	fdc42783          	lw	a5,-36(s0)
      7c:	40f707b3          	sub	a5,a4,a5
      80:	fef42623          	sw	a5,-20(s0)
      84:	fe842703          	lw	a4,-24(s0)
      88:	fd842783          	lw	a5,-40(s0)
      8c:	00f707b3          	add	a5,a4,a5
      90:	fef42423          	sw	a5,-24(s0)
      94:	000017b7          	lui	a5,0x1
      98:	fe042703          	lw	a4,-32(s0)
      9c:	00271713          	slli	a4,a4,0x2
      a0:	00078793          	mv	a5,a5
      a4:	00f707b3          	add	a5,a4,a5
      a8:	0007a783          	lw	a5,0(a5) # 1000 <_etext>
      ac:	fe442703          	lw	a4,-28(s0)
      b0:	40f707b3          	sub	a5,a4,a5
      b4:	fef42223          	sw	a5,-28(s0)
      b8:	0500006f          	j	108 <cordic+0xfc>
      bc:	fec42783          	lw	a5,-20(s0)
      c0:	fcf42823          	sw	a5,-48(s0)
      c4:	fec42703          	lw	a4,-20(s0)
      c8:	fdc42783          	lw	a5,-36(s0)
      cc:	00f707b3          	add	a5,a4,a5
      d0:	fef42623          	sw	a5,-20(s0)
      d4:	fe842703          	lw	a4,-24(s0)
      d8:	fd842783          	lw	a5,-40(s0)
      dc:	40f707b3          	sub	a5,a4,a5
      e0:	fef42423          	sw	a5,-24(s0)
      e4:	000017b7          	lui	a5,0x1
      e8:	fe042703          	lw	a4,-32(s0)
      ec:	00271713          	slli	a4,a4,0x2
      f0:	00078793          	mv	a5,a5
      f4:	00f707b3          	add	a5,a4,a5
      f8:	0007a783          	lw	a5,0(a5) # 1000 <_etext>
      fc:	fe442703          	lw	a4,-28(s0)
     100:	00f707b3          	add	a5,a4,a5
     104:	fef42223          	sw	a5,-28(s0)
     108:	fe042783          	lw	a5,-32(s0)
     10c:	00178793          	addi	a5,a5,1
     110:	fef42023          	sw	a5,-32(s0)
     114:	fe042703          	lw	a4,-32(s0)
     118:	01e00793          	li	a5,30
     11c:	f2e7d4e3          	ble	a4,a5,44 <cordic+0x38>
     120:	fc442783          	lw	a5,-60(s0)
     124:	fec42703          	lw	a4,-20(s0)
     128:	00e7a023          	sw	a4,0(a5)
     12c:	fc842783          	lw	a5,-56(s0)
     130:	fe842703          	lw	a4,-24(s0)
     134:	00e7a023          	sw	a4,0(a5)
     138:	00000013          	nop
     13c:	03c12403          	lw	s0,60(sp)
     140:	04010113          	addi	sp,sp,64
     144:	00008067          	ret

00000148 <main>:
     148:	fe010113          	addi	sp,sp,-32
     14c:	00112e23          	sw	ra,28(sp)
     150:	00812c23          	sw	s0,24(sp)
     154:	02010413          	addi	s0,sp,32
     158:	000027b7          	lui	a5,0x2
     15c:	fef42623          	sw	a5,-20(s0)
     160:	100007b7          	lui	a5,0x10000
     164:	fef42423          	sw	a5,-24(s0)
     168:	fe040713          	addi	a4,s0,-32
     16c:	fe440793          	addi	a5,s0,-28
     170:	00070613          	mv	a2,a4
     174:	00078593          	mv	a1,a5
     178:	fe842503          	lw	a0,-24(s0)
     17c:	e91ff0ef          	jal	ra,c <cordic>
     180:	fec42783          	lw	a5,-20(s0)
     184:	0ff00713          	li	a4,255
     188:	00e7a023          	sw	a4,0(a5) # 10000000 <_etext+0xffff000>
     18c:	00000793          	li	a5,0
     190:	00078513          	mv	a0,a5
     194:	01c12083          	lw	ra,28(sp)
     198:	01812403          	lw	s0,24(sp)
     19c:	02010113          	addi	sp,sp,32
     1a0:	00008067          	ret
	...
