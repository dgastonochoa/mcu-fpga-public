Several of this apps. are highly coupled with soc/board-dependant code, i.e. the
fw_updater uses the tiva SDK directly, and the led_blink uses the simpleriscv periphs.
directly. These should be abstracted to drivers. The same goes for assembly code used
in this apps, it should be in a separated dir. or something.