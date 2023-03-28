component CExtractSig (in active uint iRandom    /*$ Default */,
				out passive byte oRandomByte    /*$ Default */,
				out passive bit oRandomBit    /*$ Default */)
{
    Extract(0) on iRandom
    {
        oRandomByte = (byte)bits(iRandom, 31ub, 24ub);
        oRandomBit  = bit(iRandom, 31ub);
    }
};