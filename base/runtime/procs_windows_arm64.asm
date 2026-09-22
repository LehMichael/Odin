TEB_STACK_LIMIT EQU 0x10
PAGE_SIZE       EQU 0x1000

        AREA |.text|, CODE, READONLY
        EXPORT __chkstk [FUNC]

__chkstk PROC
        ; Windows ARM64 passes the requested allocation size, divided by 16,
        ; in x15. x16 and x17 are volatile intra-procedure-call registers.
        ldr     x17, [x18, #TEB_STACK_LIMIT]
        subs    x16, sp, x15, LSL #4

        ; Saturate an unsigned subtraction underflow to address zero.
        csel    x16, xzr, x16, cc

        ; Nothing needs probing when the target is already within the
        ; committed stack. Otherwise, probe one page at a time below the
        ; current TEB StackLimit.
        cmp     x16, x17
        b.hs    chkstk_done

        and     x16, x16, #-PAGE_SIZE
chkstk_loop
        sub     x17, x17, #1, LSL #12
        ldr     xzr, [x17]
        cmp     x17, x16
        b.ne    chkstk_loop

chkstk_done
        ret
        ENDP

        END
