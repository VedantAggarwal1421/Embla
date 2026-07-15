package csr_pkg;

    typedef enum logic [1:0] {
        PRIV_U = 2'b00,
        PRIV_S = 2'b01,
        PRIV_M = 2'b11
    } priv_lvl_t;

    typedef enum logic [2:0] {
        CSRRW  = 3'b001,
        CSRRS  = 3'b010,
        CSRRC  = 3'b011,
        CSRRWI = 3'b101,
        CSRRSI = 3'b110,
        CSRRCI = 3'b111
    } csr_instr_t;


    typedef enum logic [11:0] {
        //MACHINE LEVEL CSRS
        //MACHINE INFORMATION REGISTERS (RO)
        MVENDORID = 12'hF11,
        MARCHID   = 12'hF12,
        MIMPID    = 12'hF13,
        MHARTID   = 12'hF14,
        //MACHINE TRAP SETUP (RW)
        MSTATUS   = 12'h300,
        MISA      = 12'h301,
        MIE       = 12'h304,
        MTVEC     = 12'h305,
        MSTATUSH  = 12'h310,
        //MACHINE TRAP HANDLING
        MSCRATCH  = 12'h340,
        MEPC      = 12'h341,
        MCAUSE    = 12'h342,
        MTVAL     = 12'h343,
        MIP       = 12'h344,
        //MACHINE COUNTER
        MCYCLE    = 12'hB00,
        MINSTRET  = 12'hB02,
        MCYCLEH   = 12'hB80,
        MINSTRETH = 12'hB82
    } csr_t;
endpackage
