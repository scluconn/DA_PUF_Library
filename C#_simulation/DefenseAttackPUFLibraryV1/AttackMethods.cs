using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class AttackMethods
    {
        //Use Ha's method to attack XOR APUF with the absolute objective function 
        public static void AttackXORAPUFwithAbsoluteMethod()
        {
            //Generate a noisy PUF 
            int bitNum = 64;
            int pufNum = 2;
            int numberOfMeasurements = 5; //I am guessing this, no clue 
            double aPUFMean = 0.0;
            double aPUFVar = 1.0;
            double aPUFMeanNoise = 0.0;
            double aPUFNoiseVar = aPUFVar / 10.0;

            //Create the XOR APUF 
            XORArbiterPUF xPUF = new XORArbiterPUF(pufNum, bitNum, aPUFMean, aPUFVar, aPUFMeanNoise, aPUFNoiseVar);
            //Generate training data (reliability information)
            int trainingSize = 30000; //fix back
            int testingSize = 10000;
            int attackRepeatNum = 15;
            ParallelOptions options = new ParallelOptions { MaxDegreeOfParallelism = 10 };

            //make independent copies in memory 
            XORArbiterPUF[] xArray = new XORArbiterPUF[attackRepeatNum];
            for (int i = 0; i < xArray.Length; i++)
            {
                xArray[i] = (XORArbiterPUF)xPUF.Clone();
            }
            double[][] solutionList = new double[attackRepeatNum][];

            //Two different objective functions, one for CMA-ES, the other to test the final model accuracy 
            ObjectiveFunctionResponse rObj = new ObjectiveFunctionResponse();
            //ObjectiveFunctionReliabilityStandard[] sObjArray = new ObjectiveFunctionReliabilityStandard[attackRepeatNum];
            ObjectiveFunctionReliabilityAbsolute[] sObjArray = new ObjectiveFunctionReliabilityAbsolute[attackRepeatNum];

            for (int i = 0; i < sObjArray.Length; i++)
            {
                sObjArray[i] = new ObjectiveFunctionReliabilityAbsolute();
            }

            Parallel.For(0, attackRepeatNum, a =>
            {
                //for (int a = 0; a < attackRepeatNum; a++)
                //{
                Random randomGenerator = new Random((int)DateTime.Now.Ticks); //remove the dependences for parallelization 
                int dimensionNumber = bitNum + 1;
                double[][] trainingData = new double[trainingSize][]; //these will be phi vectors 
                double[][] trainingReliability = new double[trainingSize][];
                //DataGeneration.GenerateReliabilityTrainingDataHaWay(xArray[a], numberOfMeasurements, trainingData, trainingReliability, randomGenerator);
                DataGeneration.GenerateReliabilityTrainingData(xArray[a], numberOfMeasurements, trainingData, trainingReliability, randomGenerator);

                //Generate the first solution randomly for CMA-ES 
                double[] firstSolution = new double[bitNum + 1];
                for (int i = 0; i < firstSolution.Length; i++)
                {
                    //firstSolution[i] = AppConstants.rx.NextDouble();
                    firstSolution[i] = randomGenerator.NextDouble();
                }
                Console.Out.WriteLine("Data generation for core " + a.ToString() + " complete. Beginning CMA-ES");
                CMAESCandidate solutionCMAES = CMAESMethods.ComputeCMAES(dimensionNumber, sObjArray[a], trainingData, trainingReliability, firstSolution, randomGenerator);
                double[] solution = solutionCMAES.GetWeightVector();
                solutionList[a] = solution; //store the solution in independent memory 
                                            // }
            });

            //Just see if we can recover the 0th APUF
            //ArbiterPUF aPUF = xPUF.GetAPUFAtIndex(0);
            //Testing data can be in form of response because we don't care about the reliability 
            double[][] accMeasures = new double[solutionList.Length][];
            for (int i = 0; i < solutionList.Length; i++)
            {
                accMeasures[i] = new double[pufNum];
            }

            Random randomGenerator2 = new Random((int)DateTime.Now.Ticks);
            for (int j = 0; j < pufNum; j++)
            {
                ArbiterPUF aPUF = xPUF.GetAPUFAtIndex(j);
                double[][] testingData = new double[testingSize][]; //these will be phi vectors 
                double[][] testingResponse = new double[testingSize][];
                DataGeneration.GenerateTrainingData(aPUF, testingData, testingResponse, randomGenerator2);
                for (int i = 0; i < solutionList.Length; i++)
                {
                    accMeasures[i][j] = 1.0 - rObj.ObjFunValue(solutionList[i], testingData, testingResponse);
                    Console.Out.WriteLine("The accuracy for PUF " + j.ToString() + " " + accMeasures[i][j].ToString());
                }
                //Ground truth sanity check 
                double gca = 1.0 - rObj.ObjFunValue(aPUF.GetGroundTruthWeight(), testingData, testingResponse);
                Console.Out.WriteLine("The ground truth accuracy for PUF " + j.ToString() + " " + gca.ToString());
            }
            int k = 0;
        }
    }
}
