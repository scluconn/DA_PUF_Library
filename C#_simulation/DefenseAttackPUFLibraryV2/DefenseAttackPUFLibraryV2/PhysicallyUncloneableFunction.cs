using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    [Serializable]
    abstract class PhysicallyUncloneableFunction
    {
        protected int bitNumber; //number of input bits for the PUF
        abstract public sbyte ComputeResponse(sbyte[] phiChallenge); //give a response 
        abstract public sbyte ComputeNoisyResponse(sbyte[] phiChallenge); //give a response if the PUF is noisy 
        public int BitNumber
        {
            get
            {
                return bitNumber;
            }
            set
            {
                bitNumber = value;
            }
        }
    }
}
