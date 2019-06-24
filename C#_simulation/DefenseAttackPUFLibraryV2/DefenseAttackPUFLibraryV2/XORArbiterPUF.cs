using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    [Serializable]
    class XORArbiterPUF : PhysicallyUncloneableFunction, ICloneable
    {
        private int NumPUF;
        private double MeanForAPUF;
        private double VarianceForAPUF;
        private double NoiseMeanForAPUF;
        private double NoiseVarianceForAPUF;
        private ArbiterPUF[] ArbiterPUFArray;

        //Default constructor 
        public XORArbiterPUF(int numPUFIN, int bitNum, double aPUFMean, double aPUFVar)
        {
            //set the input variables 
            BitNumber = bitNum;
            NumPUF = numPUFIN;
            MeanForAPUF = aPUFMean;
            VarianceForAPUF = aPUFVar;
            ArbiterPUFArray = new ArbiterPUF[NumPUF];
            //Initialize the arbiter PUF array
            for (int i = 0; i < NumPUF; i++)
            {
                ArbiterPUFArray[i] = new ArbiterPUF(bitNumber, MeanForAPUF, VarianceForAPUF);
            }
        }

        //Noisy constructor 
        public XORArbiterPUF(int numPUFIN, int bitNum, double aPUFMean, double aPUFVar, double noiseMeanAPUFIN, double noiseVarianceAPUFIN)
        {
            //set the input variables 
            BitNumber = bitNum;
            NumPUF = numPUFIN;
            MeanForAPUF = aPUFMean;
            VarianceForAPUF = aPUFVar;
            NoiseMeanForAPUF = noiseMeanAPUFIN;
            NoiseVarianceForAPUF = noiseVarianceAPUFIN;
            ArbiterPUFArray = new ArbiterPUF[NumPUF];
            //Initialize the arbiter PUF array
            for (int i = 0; i < NumPUF; i++)
            {
                ArbiterPUFArray[i] = new ArbiterPUF(bitNumber, MeanForAPUF, VarianceForAPUF, NoiseMeanForAPUF, NoiseVarianceForAPUF);
            }
        }

        //Copy constructor 
        public XORArbiterPUF(int numPUFIN, int bitNum, double[][] weightsIN, double aPUFMean, double aPUFVar, double noiseMeanAPUFIN, double noiseVarianceAPUFIN)
        {
            //set the input variables 
            BitNumber = bitNum;
            NumPUF = numPUFIN;
            MeanForAPUF = aPUFMean;
            VarianceForAPUF = aPUFVar;
            NoiseMeanForAPUF = noiseMeanAPUFIN;
            NoiseVarianceForAPUF = noiseVarianceAPUFIN;
            ArbiterPUFArray = new ArbiterPUF[NumPUF];
            //Initialize the arbiter PUF array
            for (int i = 0; i < NumPUF; i++)
            {
                ArbiterPUFArray[i] = new ArbiterPUF(weightsIN[i], NoiseMeanForAPUF, NoiseVarianceForAPUF);
            }
        }

        //Constructor used for cloning 
        public XORArbiterPUF(int numPUFIN)
        {
            NumPUF = numPUFIN;
            //initalize the array but do not fill it in
            ArbiterPUFArray = new ArbiterPUF[NumPUF];
        }

        //Constructor that only takes a 1D double 
        public XORArbiterPUF(int bitNum, double[] allAPUFWeights)
        {
            //set the input variables 
            BitNumber = bitNum;
            NumPUF = (int)Math.Floor((double)allAPUFWeights.Length / ((double)bitNumber + 1)); //find the number of APUFs
            ArbiterPUFArray = new ArbiterPUF[NumPUF];
            //Fill in the APUF array 
            for (int i = 0; i < NumPUF; i++)
            {
                //Extract the weights from the double array
                double[] currentAPUFWeights = new double[BitNumber + 1];
                int indexer = i * (bitNumber + 1);
                for (int j = 0; j < currentAPUFWeights.Length; j++)
                {
                    currentAPUFWeights[j] = allAPUFWeights[indexer];
                    indexer++;
                }
                ArbiterPUFArray[i] = new ArbiterPUF(currentAPUFWeights);
            }
        }

        //Takes a phi challenge as input, each arbiter PUF converts the response to a phi vector and computes a binary output
        public override sbyte ComputeResponse(sbyte[] phiChallenge)
        {
            int finalResult = 0;
            for (int i = 0; i < NumPUF; i++)
            {
                int currentResult = ArbiterPUFArray[i].ComputeResponse(phiChallenge);
                finalResult = finalResult ^ currentResult;
            }
            sbyte finalResultSByte = (sbyte)finalResult; //typecase the final result to Sbyte (since XOR operation can only be done on ints)
            return finalResultSByte;
        }

        public override sbyte ComputeNoisyResponse(sbyte[] phiChallenge)
        {
            int finalResult = 0;
            for (int i = 0; i < NumPUF; i++)
            {
                int currentResult = ArbiterPUFArray[i].ComputeNoisyResponse(phiChallenge);
                finalResult = finalResult ^ currentResult;
            }
            sbyte finalResultSByte = (sbyte)finalResult;
            return finalResultSByte;
        }

        //Gets the APUF at a certain index 
        public ArbiterPUF GetAPUFAtIndex(int index)
        {
            return ArbiterPUFArray[index];
        }

        //Gets the ground truth weights, should only be used for copying or error checking 
        public double[][] GetAllGroundTruthWeights()
        {
            double[][] allWeights = new double[NumPUF][];
            for (int i = 0; i < NumPUF; i++)
            {
                allWeights[i] = ArbiterPUFArray[i].GetGroundTruthWeight(); //already does clone in the original method so no need to clone here 
            }
            return allWeights;
        }

        public int GetPUFNum()
        {
            return NumPUF;
        }

        public object Clone()
        {
            XORArbiterPUF xCopy = new XORArbiterPUF(NumPUF);
            //Copy over the shallow variables (can improve this using shallow method copy later)
            xCopy.BitNumber = BitNumber;
            xCopy.MeanForAPUF = MeanForAPUF;
            xCopy.VarianceForAPUF = VarianceForAPUF;
            xCopy.NoiseMeanForAPUF = NoiseMeanForAPUF;
            xCopy.NoiseVarianceForAPUF = NoiseVarianceForAPUF;
            //Copy each individual APUF into the array 
            for (int i = 0; i < NumPUF; i++)
            {
                xCopy.ArbiterPUFArray[i] = (ArbiterPUF)ArbiterPUFArray[i].Clone();
            }
            return xCopy;
        }
    }
}
