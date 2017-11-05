code		segment
		org	100h
		assume	cs:code
start:		jmp	tsr

		even

OldInt21	dd	0
Count		dw	0

NewInt21	proc	far
		cmp	ah,05ch
		je	Sharing
		cmp	ah,3dh
		jne	jOldInt
		and	al,8fh
jOldInt:	jmp	OldInt21

Sharing:
		mov	ax,Count
		inc	ax
		jz	Oflow
		mov	Count,ax
Oflow:
		xor	ax,ax
		sti
		ret	2
NewInt21	endp

LastRes		label	near


IsInWin		proc	near
		push	es
		push	bx
		mov	ax,352fh
		int	21h
		mov	ax,es
		or	ax,bx
		jz	WinTestEnd		; if no Int2F
		mov	ax,4680h
		int	2fh
		or	ax,ax
		mov	al,1
		jz	WinTestEnd
		mov	ax,1600h
		int	2fh
		test	al,7fh
		mov	al,2
		jnz	WinTestEnd
		xor	al,al
WinTestEnd:
		or	al,al
		pop	bx
		pop	es
		ret
IsInWin		endp


WrNoLead	proc	near
		or	ax,ax
		jz	NoLeadRet
		xor	dx,dx
		mov	cx,10
		div	cx
		push	dx
		call	WrNoLead
		pop	dx
		add	dl,'0'
		mov	ah,2
		int	21h
NoLeadRet:
		ret
WrNoLead	endp


WrDecimal	proc	near
		or	ax,ax
		jnz	WrNoLead
		mov	dl,'0'
		mov	ah,2
		int	21h
		ret
WrDecimal	endp

tsr:
		xor	bx,bx
		mov	cx,bx
		mov	dx,bx
		mov	si,bx
		dec	si
		mov	di,si
		mov	ax,05c00h
		int	21h
		push	ax
		pushf
		xor	bx,bx
		mov	cx,bx
		mov	dx,bx
		mov	si,bx
		dec	si
		mov	di,si
		mov	ax,05c01h
		int	21h
		popf
		pop	ax
		jc	NotInst

		or	ax,ax
		jnz	NotInst
		mov	ax,3521h
		int	21h
		cmp	bx,offset NewInt21
		jne	InstMsg
		mov	dx,offset HeadMsg
		mov	ah,9
		int	21h
		mov	ax,es:Count
		call	WrDecimal
		mov	dx,offset TailMsg
		mov	ah,9
		int	21h
		call	IsInWin
		jz	DoUninst
		mov	dx,offset NoUninst
		jmp	short ExitMsg

DoUnInst:
		lds	dx,es:OldInt21
		mov	ax,2521h
		int	21h
		mov	ah,49h
		int	21h
		mov	ax,cs
		mov	ds,ax
		mov	dx,offset Uninst
		jmp	short ExitMsg

InstMsg:
		mov	dx,offset HasShare
ExitMsg:
		mov	ah,9
		int	21h
		int	20h

NotInst:
		cmp	ax,1
		jne	InstMsg
		mov	es,cs:[2ch]
		mov	ah,49h
		int	21h
		mov	ax,3521h
		int	21h
		mov	word ptr [OldInt21+0],bx
		mov	word ptr [OldInt21+2],es
		mov	dx,offset InsShare
		mov	ah,9
		int	21h

		; at public request :
		; close all file handles before going resident
		xor	bx,bx
@@closeall:
		mov	ah,3eh
		int	21h
		inc	bx
		cmp	bx,20
		jb	@@closeall

		mov	dx,offset NewInt21
		mov	ax,2521h
		int	21h
		mov	dx,offset LastRes
		int	27h

HasShare	db	'SHARE utility is already installed.',13,10,'$'

InsShare	db	'SHARE emulator v1.1',13,10,'$'

UnInst		db	'SHARE emulator uninstalled.',13,10,'$'

NoUnInst	db	'Cannot uninstall emulator from Windows.',13,10,'$'

HeadMsg		db	'Resident emulator has been called $'

TailMsg		db	' times',13,10,'$'

code		ends
		end	start
