using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class ObjectiveFunctionResponseXOR : PUFObjectiveFunction
    {
        //Takes in weights, phi challenges and target response bits, gives average error of APUF model  
        public override double ObjFunValue(double[] weightVector, double[][] phiChallenges, double[][] targets)
        {
            int bitNum = phiChallenges[0].Length - 1;
            XORArbiterPUF xModel = new XORArbiterPUF(bitNum, weightVector);
            int sampleNumber = phiChallenges.Length; //Number of challenge-response pairs (number of training samples)
            double error = 0;
            for (int currentSample = 0; currentSample < sampleNumber; currentSample++)
            {
                double currentTarget = targets[currentSample][0];
                double modelOutput = xModel.ComputeResponse(phiChallenges[currentSample]);
                if (modelOutput != currentTarget)
                {
                    error++;
                }
            }
            error = error / (double)sampleNumber; //Give the average error 
            return error;
        }
    }
}
