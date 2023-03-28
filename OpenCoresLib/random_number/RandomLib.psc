// ===================================================================
// This is a library of cores to generate random numbers and bit sequences
// ===================================================================
// The library contains two cores:
//    - PRBS generator (CPrbsGen)
//        The PRBS - Pseudo Random Binary Sequence - is implemented with
//        a LFSR - Linear Feedback Shift Register. An LFSR is a register 
//        where specific bits are XORed and feedback into the register.
//
//    - Random number generator (CRandomGen32)
//        This cores generates 32 bits random numbers. It is an implemenation
//        of the the “xoroshiro128+ 1.0” algorithm.
//
//        Licensing:
//            Initial author statement:
//            Written in 2018 by David Blackman and Sebastiano Vigna 
//            (vigna@acm.org)
//            To the extent possible under law, the author has dedicated all
//            copyright and related and neighboring rights to this 
//            software to the public domain worldwide. 
//            This software is distributed without any warranty.
//
//            See <http://creativecommons.org/publicdomain/zero/1.0/>.
//
// ===================================================================
// Core usage
//    Refer to the test benches.
//
// ===================================================================
// TEST BENCHES:
//    All tests use the signal editor and the signal viewer to
//       actually see the random sequences of bits and numbers.
//
//    - CPrbsGen:     Project in "TestPRBS" folder
//    - CRandomGen32: Project in "TestRandom" folder
// 
// ===================================================================
library RandomLib
{
    // -------------------------------------------------------------------
    // The CPrbsGen core has two inputs and two outputs
    //     - iSeed is an optional seed for the register
    //     - iGenerate is the base clock for the sequence.
    //           Sending an event on iGenerate produces one bit of the sequence
    //     - oPrbs is the actual random binary sequence
    //           There is an event for new a bit.
    //     - oRandomByte is a pseudo-random sequence of bytes
    //           There is an event for new a byte.
    // -------------------------------------------------------------------
    component CPrbsGen (in  active uint iSeed,
                        in  active bit  iGenerate,
                        out active byte oRandomByte,
                        out active bit  oPrbs)
    {
        // Default seed
        const uint cTapSet = 011000000000000000000000000000101ui;

        // The register
        uint Value;
  
        // Equation of the feedback
        temp uint tFeedback = (bit(Value, 0ub) ? (cTapSet) : (0)) ^ bits(Value, 31ub, 1ub);

        start()
        {
            Value = 0x6FA035C3;
        }

        // Change the seed value
        SetSeed(0) on iSeed
        {
            Value = iSeed;
        }

        // Generate a new bit and a new byte
        GeneratePrbsStep(1) on iGenerate
        {
            // Compute next value
            setbits(Value, 30ub, 0ub, tFeedback);
            setbit (Value, 31ub, bit(Value, 0ub));

            // Output signals
            oRandomByte := (byte)bits(Value, 7ub, 0ub);
            oPrbs       := bit(Value, 0ub);
        } 
    };

    // -------------------------------------------------------------------
    // The CRandomGen32 core has one input and one output
    //     - iGetNbr is the base clock for the sequence.
    //           Sending an event on iGetNbr produces a new number.
    //     - oRandom is the actual random numbers sequence.
    // -------------------------------------------------------------------
    component CRandomGen32 (in  active bit  iGetNbr,
                            out active uint oRandom)
    {
        // State variables
        uint S0;
        uint S1;
        uint S2;
        uint S3;

        // Temp variables for intermediate computations
        temp uint tTmp  = S1 << 9ub;
        temp uint tS2_1 = S2 ^ S0;
        temp uint tS3_1 = S3 ^ S1;
        temp uint tS1   = S1 ^ tS2_1;
        temp uint tS0   = S0 ^ tS3_1;
        temp uint tS2_2 = tS2_1 ^ tTmp;
        // Rotate tS3_1 left by 11
        temp uint tS3_2 = (tS3_1 << 11ub) | (tS3_1 >> 21ub);     

        // Initialize seeds
        start()
        {
            S0 = 0x8764000B;
            S1 = 0xF542D2D3;
            S2 = 0x6FA035C3;
            S3 = 0x77F2DB5B;
        }

        GenerateRandomNbr(0) on iGetNbr
        {
            // Resulting number
            oRandom  := S0 + S3;
            // Compute next state
            S0 = tS0;
            S1 = tS1;
            S2 = tS2_2;
            S3 = tS3_2;
        }
    };
};
