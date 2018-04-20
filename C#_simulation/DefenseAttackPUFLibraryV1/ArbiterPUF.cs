using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class ArbiterPUF : PhysicallyUncloneableFunction
    {
        private double WeightMean; //Varaible for randomly initalizing the weights 
        private double WeightVariance; //Variable for randomly initalizing the weights 
        private double[] Weight; //Weight vector of the Arbiter PUF 
        private double NoiseMean; //if PUF is noisy generates terms for noise each time 
        private double NoiseVariance;
        private Random RandomGenerator;
        private int MajorityVoteCount = 1; //Can create different noise rates using majority voting

        //default constructor
        public ArbiterPUF(int bitNum, double meanW, double varianceW)
        {
            RandomGenerator = new Random((int)DateTime.Now.Ticks);
            System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same 
            BitNumber = bitNum;
            WeightMean = meanW;
            WeightVariance = varianceW;
            Weight = new double[bitNumber + 1]; //initalize the weight array, in this model for an n stage arbiter PUF, there are n+1 weights
            for (int i = 0; i < Weight.Length; i++)
            {
                Weight[i] = GenerateRandomNormalVariable(WeightMean, WeightVariance);
            }
        }

        //Secondary constructor for PSO and CMAES
        public ArbiterPUF(double[] weightIN)
        {
            RandomGenerator = new Random((int)DateTime.Now.Ticks);
            System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same 
            BitNumber = weightIN.Length - 1;
            WeightMean = -1.0;
            WeightVariance = -1.0; //-1.0 means we did NOT randomly initalize this APUF
            Weight = (double[])weightIN.Clone(); //initalize the weight array, in this model for an n stage arbiter PUF, there are n+1 weights
        }

        //Noisy constructor 
        public ArbiterPUF(int bitNum, double meanW, double varianceW, double noiseMeanIN, double noiseVarianceIN)
        {
            RandomGenerator = new Random((int)DateTime.Now.Ticks);
            System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same 
            BitNumber = bitNum;
            WeightMean = meanW;
            WeightVariance = varianceW;
            NoiseMean = noiseMeanIN;
            NoiseVariance = noiseVarianceIN;
            Weight = new double[bitNumber + 1]; //initalize the weight array, in this model for an n stage arbiter PUF, there are n+1 weights
            for (int i = 0; i < Weight.Length; i++)
            {
                Weight[i] = GenerateRandomNormalVariable(WeightMean, WeightVariance);
            }
        }

        //Secondary noisy constructor for PSO and CMAES
        public ArbiterPUF(double[] weightIN, double noiseMeanIN, double noiseVarianceIN)
        {
            RandomGenerator = new Random((int)DateTime.Now.Ticks);
            System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same 
            BitNumber = weightIN.Length - 1;
            NoiseMean = noiseMeanIN; //copy the noisy parameters 
            NoiseVariance = noiseVarianceIN; //-1.0 means we did NOT randomly initalize this APUF
            Weight = (double[])weightIN.Clone(); //initalize the weight array, in this model for an n stage arbiter PUF, there are n+1 weights
        }

        //debugging method to let you see the weights. SHOULD NOT CALL NORMALLY
        public double[] GetGroundTruthWeight()
        {
            return (double[])Weight.Clone();
        }

        //Takes a phi vector and computes the response of the arbiter PUF
        public override int ComputeResponse(double[] phiChallenge)
        {
            //error checking
            if (phiChallenge.Length != (bitNumber + 1))
            {
                throw new Exception("The number of bits in the challenge phi do not match the number of weights in the Arbiter PUF.");
            }
            double sum = 0;
            int response = 0;

            //Compute the response of the PUF, sum>0 return 0, sum<0 return 1
            for (int i = 0; i < Weight.Length; i++)
            {
                sum = sum + (Weight[i] * phiChallenge[i]);
            }
            if (sum < 0)
            {
                response = 1;
            }
            return response;
        }

        //Takes a phi vector and computes the response of the arbiter PUF (noisy)
        public override int ComputeNoisyResponse(double[] phiChallenge)
        {
            int response;
            if (MajorityVoteCount == 1)//only use phi once so do not do majority voting
            {
                response = ComputeNoisyResponseStandard(phiChallenge);
            }
            else
            {
                response = ComputeNoisyResponseMajorityVoting(phiChallenge); //do majority voting to get response
            }
            return response;
        }

        //Takes a phi vector and computes the response of the arbiter PUF (noisy)
        public int ComputeNoisyResponseStandard(double[] phiChallenge)
        {
            //error checking
            if (phiChallenge.Length != (bitNumber + 1))
            {
                throw new Exception("The number of bits in the challenge phi do not match the number of weights in the Arbiter PUF.");
            }
            double sum = 0;
            int response = 0;
            //Compute the response of the PUF, sum>0 return 0, sum<0 return 1
            for (int i = 0; i < Weight.Length; i++)
            {
                double noiseTerm = GenerateRandomNormalVariable(NoiseMean, NoiseVariance);
                sum = sum + (Weight[i] + noiseTerm) * phiChallenge[i];
            }
            if (sum < 0)
            {
                response = 1;
            }
            return response;
        }

        //Takes a phi vector and computes the response of the arbiter PUF multiple times
        public int ComputeNoisyResponseMajorityVoting(double[] phiChallenge)
        {
            int finalResponse;
            int zerosCount = 0;
            int onesCount = 0;
            //evaluate the challenge multiple times
            for (int i = 0; i < MajorityVoteCount; i++)
            {
                int currentResponse = ComputeNoisyResponseStandard(phiChallenge);
                if (currentResponse == 0)
                {
                    zerosCount++;
                }
                else
                {
                    onesCount++;
                }
            }
            if (zerosCount >= onesCount)
            {
                finalResponse = 0;
            }
            else
            {
                finalResponse = 1;
            }
            return finalResponse;
        }

        //Set the majority voting to change the reliability
        public void SetMajorityVoteCount(int voteCount)
        {
            if (voteCount <= 0)
            {
                throw new Exception("The majority vote count must be 1 or greater");
            }
            MajorityVoteCount = voteCount;
        }

        //Used to generate the weights randomly for the Arbiter PUF
        public double GenerateRandomNormalVariable(double mean, double variance)
        {
            //generate normal random variable, code borrowed from Stack Overflow
            double u1 = 1.0 - RandomGenerator.NextDouble(); //uniform(0,1] random doubles
            double u2 = 1.0 - RandomGenerator.NextDouble();
            double randStdNormal = Math.Sqrt(-2.0 * Math.Log(u1)) * Math.Sin(2.0 * Math.PI * u2); //random normal(0,1)
            double randNormal = mean + Math.Sqrt(variance) * randStdNormal; //random normal(mean,stdDev^2)
            return randNormal;
        }

        public object Clone()
        {
            ArbiterPUF aPUFCopy = new ArbiterPUF(Weight); //Automatically clones the weights in the constructor
            //Other variables must be set manually 
            aPUFCopy.BitNumber = BitNumber;
            aPUFCopy.WeightMean = WeightMean;
            aPUFCopy.WeightVariance = WeightVariance;
            aPUFCopy.NoiseMean = NoiseMean;
            aPUFCopy.NoiseVariance = NoiseVariance;
            aPUFCopy.MajorityVoteCount = MajorityVoteCount;
            return aPUFCopy;
        }
    }
}
