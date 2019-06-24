using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    [Serializable]
    class ObjectiveFunctionResponseXOR : PUFObjectiveFunction
    {
        //Takes in weights, phi challenges and target response bits, gives average error of APUF model  
        public override double ObjFunValue(double[] weightVector, sbyte[][] phiChallenges, sbyte[] targets)
        {
            double error = 0;
            if (AppConstants.UseParallelismOnSingleCMAES == true)
            {
                int bitNum = phiChallenges[0].Length - 1;
                double[] errorArray = new double[AppConstants.CoreNumber]; //Array for storing errors in parallel
                XORArbiterPUF xModel = new XORArbiterPUF(bitNum, weightVector);
                int sampleNumber = phiChallenges.Length; //Number of challenge-response pairs (number of training samples)

                int blockSize = AppConstants.TrainingSize / AppConstants.CoreNumber;
                Parallel.For(0, AppConstants.CoreNumber, coreIndex =>
                //for (int coreIndex = 0; coreIndex < AppConstants.CoreNumber; coreIndex++)
                {
                    for (int sampleIndex = coreIndex * blockSize; sampleIndex < (coreIndex + 1) * blockSize; sampleIndex++)
                    {
                        sbyte currentTarget = targets[sampleIndex];
                        sbyte modelOutput = xModel.ComputeResponse(phiChallenges[sampleIndex]);
                        if (modelOutput != currentTarget)
                        {
                            errorArray[coreIndex]++;
                        }
                        //Console.Out.WriteLine(sampleIndex.ToString());
                    }
                });
                //Time to sum the errors together 
                for (int i = 0; i < AppConstants.CoreNumber; i++)
                {
                    error = error + errorArray[i];
                }
                error = error / (double)sampleNumber; //Give the average error 
            }
            else if (AppConstants.UseParallelismOnSingleCMAES == false)
            {
                int bitNum = phiChallenges[0].Length - 1;
                XORArbiterPUF xModel = new XORArbiterPUF(bitNum, weightVector);
                int sampleNumber = phiChallenges.Length; //Number of challenge-response pairs (number of training samples)
                for (int currentSample = 0; currentSample < sampleNumber; currentSample++)
                {
                    sbyte currentTarget = targets[currentSample];
                    sbyte modelOutput = xModel.ComputeResponse(phiChallenges[currentSample]);
                    if (modelOutput != currentTarget)
                    {
                        error++;
                    }
                }
                error = error / (double)sampleNumber; //Give the average error 
            }
            return error;
        }
    }
}
