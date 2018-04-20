using MathNet.Numerics.Statistics;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class ObjectiveFunctionReliabilityAbsolute : PUFObjectiveFunction
    {
        //Takes in weights, phi challenges and target response bits
        public override double ObjFunValue(double[] weightVector, double[][] phiChallenges, double[][] reliabilityTargets)
        {
            int sampleNumber = phiChallenges.Length; //Number of challenge-relability pairs (number of training samples)
            double[] modelReliability = new double[sampleNumber];
            double[] trueReliability = new double[sampleNumber];
            for (int currentSample = 0; currentSample < sampleNumber; currentSample++)
            {
                modelReliability[currentSample] = ComputeReliabilityFromModel(weightVector, phiChallenges[currentSample]);
                trueReliability[currentSample] = reliabilityTargets[currentSample][0];
            }
            //double acc = DataGeneration.PearsonCorrelationCoefficient(modelReliability, trueReliability);
            double acc = Correlation.Pearson(trueReliability, modelReliability);
            //try to turn it into an optimization problem 
            //if (acc < 0)
            //{
            //    acc = -1.0 * acc; //fl
            //    //return acc = double.MaxValue;
            //}
            //if (acc == 0)
            //{
            //    return acc;
            //}
            //else
            //{
            //    acc = 1.0 / acc;
            //}
            //acc = 1.0 / (acc * acc);
            //if (acc < 0)
            //{
            //    acc = acc * -1.0;
            //}
            //acc = 1.0 / (acc * acc);
            return acc;
        }

        //Takes a phi vector and computes the reliability of the arbiter PUF
        public double ComputeReliabilityFromModel(double[] weightVector, double[] phiChallenge)
        {
            //error checking
            if (phiChallenge.Length != weightVector.Length)
            {
                throw new Exception("The number of bits in the challenge phi do not match the number of weights in the Arbiter PUF.");
            }
            double sum = 0;
            //Compute whether the challenge is reliable or not 
            for (int i = 0; i < weightVector.Length; i++)
            {
                sum = sum + (weightVector[i] * phiChallenge[i]);
            }
            sum = Math.Abs(sum);
            return sum;
        }
    }
}
