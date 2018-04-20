using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class ObjectiveFunctionResponse : PUFObjectiveFunction
    {
        //Takes in weights, phi challenges and target response bits, gives average error of APUF model  
        public override double ObjFunValue(double[] weightVector, double[][] phiChallenges, double[][] targets)
        {
            int sampleNumber = phiChallenges.Length; //Number of challenge-response pairs (number of training samples)
            ArbiterPUF aPUFModel = new ArbiterPUF(weightVector);
            double error = 0;
            for (int currentSample = 0; currentSample < sampleNumber; currentSample++)
            {
                double currentTarget = targets[currentSample][0];
                double modelOutput = aPUFModel.ComputeResponse(phiChallenges[currentSample]);
                if (modelOutput != currentTarget)
                {
                    error++;
                }
            }
            error = error / (double)sampleNumber; //Give the average error 
            return error;
        }

        //Takes in weights, phi challenges and target response bits, gives average error of APUF model  
        public double ObjFunValueOfInverseModel(double[] weightVector, double[][] phiChallenges, double[][] targets)
        {
            int sampleNumber = phiChallenges.Length; //Number of challenge-response pairs (number of training samples)
            ArbiterPUF aPUFModel = new ArbiterPUF(weightVector);
            double error = 0;
            for (int currentSample = 0; currentSample < sampleNumber; currentSample++)
            {
                double currentTarget = targets[currentSample][0];
                double modelOutput = aPUFModel.ComputeResponse(phiChallenges[currentSample]);
                if (modelOutput == currentTarget)
                {
                    error++;
                }
            }
            error = error / (double)sampleNumber; //Give the average error 
            return error;
        }
    }
}
