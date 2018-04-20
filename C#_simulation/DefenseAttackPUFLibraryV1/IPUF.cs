using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class IPUF : PhysicallyUncloneableFunction
    {
        private int NumPUFX;
        private int NumPUFY;
        private double MeanForAPUF;
        private double VarianceForAPUF;
        private ArbiterPUF[] ArbiterPUFArrayX;
        private ArbiterPUF[] ArbiterPUFArrayY;

        public IPUF(int xNumPUFIN, int yNumPUFIN, int bitNum, double aPUFMean, double aPUFVar)
        {
            //set the input variables 
            BitNumber = bitNum;
            NumPUFX = xNumPUFIN;
            NumPUFY = yNumPUFIN;
            MeanForAPUF = aPUFMean;
            VarianceForAPUF = aPUFVar;
            ArbiterPUFArrayX = new ArbiterPUF[xNumPUFIN];
            ArbiterPUFArrayY = new ArbiterPUF[yNumPUFIN];
            //Initialize the X arbiter PUF array
            for (int i = 0; i < NumPUFX; i++)
            {
                ArbiterPUFArrayX[i] = new ArbiterPUF(bitNumber, MeanForAPUF, VarianceForAPUF);
            }
            //Initialize the Y arbiter PUF array
            for (int i = 0; i < NumPUFY; i++)
            {
                ArbiterPUFArrayY[i] = new ArbiterPUF(bitNumber + 1, MeanForAPUF, VarianceForAPUF); //note this has one more bit than the X PUFs
            }
        }

        //Takes a binary challenge as input, each arbiter PUF converts the response to a phi vector and computes a binary output
        public override int ComputeResponse(double[] binaryChallenge)
        {
            int resultX = 0; //this will be the output from the XOR operation on all the outputs from the X PUFs
            double[] phiChallengeForUpperPUFs = DataGeneration.ConvertBinaryChallengeToPhi(binaryChallenge);
            for (int i = 0; i < NumPUFX; i++)
            {
                int currentResult = ArbiterPUFArrayX[i].ComputeResponse(phiChallengeForUpperPUFs);
                resultX = resultX ^ currentResult;
            }
            //create the challenge for the Y PUFs     
            double[] binaryChallengeSupplement = new double[BitNumber + 1];
            int bitInsertIndex = (int)(BitNumber / 2); //choose the index to insert the extra bit 
            int originalIndexer = 0;
            for (int i = 0; i < binaryChallengeSupplement.Length; i++)
            {
                if (i == bitInsertIndex)
                {
                    binaryChallengeSupplement[i] = resultX;
                }
                else
                {
                    binaryChallengeSupplement[i] = binaryChallenge[originalIndexer];
                    originalIndexer++;
                }
            }

            //Give the modified challenge to the lower PUFs
            int resultY = 0; //this will be the output from the XOR operation on all the outputs from the Y PUFs
            double[] phiChallengeForLowerPUFs = DataGeneration.ConvertBinaryChallengeToPhi(binaryChallengeSupplement);
            for (int i = 0; i < NumPUFY; i++)
            {
                int currentResult = ArbiterPUFArrayY[i].ComputeResponse(phiChallengeForLowerPUFs);
                resultY = resultY ^ currentResult;
            }
            return resultY;
        }

        //TODO noisy IPUF will be given in a later code version 
        public override int ComputeNoisyResponse(double[] phiChallenge)
        {
            throw new NotImplementedException();
        }
    }
}
