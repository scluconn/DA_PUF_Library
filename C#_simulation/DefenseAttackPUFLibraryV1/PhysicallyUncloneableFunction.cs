using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    abstract class PhysicallyUncloneableFunction
    {
        protected int bitNumber; //number of input bits for the PUF
        abstract public int ComputeResponse(double[] phiChallenge); //give a response 
        abstract public int ComputeNoisyResponse(double[] phiChallenge); //give a response if the PUF is noisy 
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
