using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class ObjectiveFunctionReliabilityStandard : PUFObjectiveFunction
    {
        //Takes in weights, phi challenges and target response bits
        public override double ObjFunValue(double[] weightVectorAndEpsilon, double[][] phiChallenges, double[][] reliabilityTargets)
        {
            int sampleNumber = phiChallenges.Length; //Number of challenge-relability pairs (number of training samples)
            double epsilon = weightVectorAndEpsilon[weightVectorAndEpsilon.Length - 1]; //Epsilon should be the last parameter
            double[] weightVector = new double[weightVectorAndEpsilon.Length - 1];
            for (int i = 0; i < weightVector.Length; i++)
            {
                weightVector[i] = weightVectorAndEpsilon[i]; //make weight vector its own variable 
            }
            double[] modelReliability = new double[sampleNumber];
            double[] trueReliability = new double[sampleNumber];
            for (int currentSample = 0; currentSample < sampleNumber; currentSample++)
            {
                modelReliability[currentSample] = ComputeReliabilityFromModel(epsilon, weightVector, phiChallenges[currentSample]);
                trueReliability[currentSample] = reliabilityTargets[currentSample][0];
                //modelResponses[currentSample] = aPUFModel.ComputeResponse(phiChallenges[currentSample]);
            }
            double acc = DataGeneration.PearsonCorrelationCoefficient(modelReliability, trueReliability);
            //try to turn it into an optimization problem 
            //if (acc < 0)
            //{
            //    acc = acc * -1.0; //fl
            //}

            //if (acc == 0)
            //{
            //    acc = double.MaxValue;
            //}
            //else
            //{
            //    acc = 1.0 / acc;
            //}
            //acc = 1.0 / (acc * acc);
            return acc;
        }

        //Takes a phi vector and computes the reliability of the arbiter PUF
        public int ComputeReliabilityFromModel(double epsilon, double[] weightVector, double[] phiChallenge)
        {
            //error checking
            if (phiChallenge.Length != weightVector.Length)
            {
                throw new Exception("The number of bits in the challenge phi do not match the number of weights in the Arbiter PUF.");
            }
            double sum = 0;
            int relability = 0;

            //Compute whether the challenge is reliable or not 
            for (int i = 0; i < weightVector.Length; i++)
            {
                sum = sum + (weightVector[i] * phiChallenge[i]);
            }
            sum = Math.Abs(sum);
            if (sum >= epsilon)
            {
                relability = 1;
            }
            return relability;
        }
    }
}
