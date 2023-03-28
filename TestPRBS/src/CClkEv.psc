component CClkEv (out active bit oClkEv)
{
    always()
    {
        // An event is sent at every step
        oClkEv:;
    }
};