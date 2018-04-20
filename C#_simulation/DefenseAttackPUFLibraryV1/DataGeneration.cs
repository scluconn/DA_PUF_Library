using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class DataGeneration
    {
        //Generates the response training data 
        public static void GenerateTrainingData(PhysicallyUncloneableFunction aPUF, double[][] trainingData, double[][] trainingResponse, Random randomGenerator)
        {
            int trainingSize = trainingData.Length;
            int bitNum = aPUF.BitNumber;
            for (int i = 0; i < trainingSize; i++)
            {
                trainingData[i] = GenerateRandomPhiVector(bitNum, randomGenerator);
                trainingResponse[i] = new double[1];
                trainingResponse[i][0] = aPUF.ComputeResponse(trainingData[i]);
            }
        }




        //Generates the reliability training data as done in Becker's paper, does m/2 - sum(r) calculation  
        public static void GenerateReliabilityTrainingData(PhysicallyUncloneableFunction aPUF, int numberOfMeasurements, double[][] trainingData, double[][] trainingReliability, Random randomGenerator)
        {
            int trainingSize = trainingData.Length;
            int bitNum = aPUF.BitNumber;
            for (int i = 0; i < trainingSize; i++)
            {
                double sumOfResponses = 0;
                //trainingData[i] = GenerateRandomPhiVector(bitNum);
                trainingData[i] = GenerateRandomPhiVector(bitNum, randomGenerator);
                for (int m = 0; m < numberOfMeasurements; m++)
                {
                    sumOfResponses = sumOfResponses + aPUF.ComputeNoisyResponse(trainingData[i]); //sum the measurements
                }
                trainingReliability[i] = new double[1];
                //trainingReliability[i][0] = sumOfResponses / (double)numberOfMeasurements;
                //trainingReliability[i][0] = Math.Abs(numberOfMeasurements / 2.0 - (sumOfResponses / (double)numberOfMeasurements));
                trainingReliability[i][0] = Math.Abs(numberOfMeasurements / 2.0 - sumOfResponses);

            }
        }

        //This is a version to match Ha's noise, not sure if right 
        public static void GenerateReliabilityTrainingDataHaWay(XORArbiterPUF xPUF, int numberOfMeasurements, double[][] trainingData, double[][] trainingReliability, Random randomGenerator)
        {
            int trainingSize = trainingData.Length;
            int bitNum = xPUF.BitNumber;
            //pregenerate training data inputs 
            double[] noisyAPUFWeight1 = new double[bitNum + 1];
            double[] noisyAPUFWeight2 = new double[bitNum + 1];
            double[] sumOfResponses = new double[trainingSize];
            for (int i = 0; i < trainingSize; i++)
            {
                trainingData[i] = GenerateRandomPhiVector(bitNum, randomGenerator);
            }

            for (int m = 0; m < numberOfMeasurements; m++) //Ha's way is flipped 
            {
                double[] noiseAPUF1 = new double[bitNum + 1];
                double[] noiseAPUF2 = new double[bitNum + 1];
                for (int i = 0; i < noiseAPUF1.Length; i++)
                {
                    noiseAPUF1[i] = GenerateRandomNormalVariable(0, 0.1, randomGenerator);
                    noiseAPUF2[i] = GenerateRandomNormalVariable(0, 0.1, randomGenerator);
                }
                double[] originalAPUFWeight1 = xPUF.GetAllGroundTruthWeights()[0];
                double[] originalAPUFWeight2 = xPUF.GetAllGroundTruthWeights()[1];
                //Combine the noisy and original weights
                for (int i = 0; i < noisyAPUFWeight1.Length; i++)
                {
                    noisyAPUFWeight1[i] = originalAPUFWeight1[i] + noiseAPUF1[i];
                    noisyAPUFWeight2[i] = originalAPUFWeight2[i] + noiseAPUF2[i];
                }
                ArbiterPUF aNoisy1 = new ArbiterPUF(noisyAPUFWeight1);
                ArbiterPUF aNoisy2 = new ArbiterPUF(noisyAPUFWeight2);

                //Compute for each sample 
                for (int i = 0; i < trainingSize; i++)
                {
                    int cc = aNoisy1.ComputeResponse(trainingData[i]);
                    int ccc = aNoisy2.ComputeResponse(trainingData[i]);
                    int result = aNoisy1.ComputeResponse(trainingData[i]) ^ aNoisy2.ComputeResponse(trainingData[i]);
                    sumOfResponses[i] = sumOfResponses[i] + result;
                }
            }

            //Last compute the reliability 
            for (int i = 0; i < trainingSize; i++)
            {
                trainingReliability[i] = new double[1];
                //trainingReliability[i][0]= Math.Abs(numberOfMeasurements / 2.0 - (sumOfResponses[i] / (double)numberOfMeasurements));
                trainingReliability[i][0] = Math.Abs(numberOfMeasurements / 2.0 - (sumOfResponses[i]));

            }

            //for (int i = 0; i < trainingSize; i++)
            //{
            //    double sumOfResponses = 0;
            //    //trainingData[i] = GenerateRandomPhiVector(bitNum);
            //    trainingData[i] = GenerateRandomPhiVector(bitNum, randomGenerator);
            //    for (int m = 0; m < numberOfMeasurements; m++)
            //    {
            //        double randomNoise
            //        sumOfResponses = sumOfResponses + aPUF.ComputeNoisyResponse(trainingData[i]); //sum the measurements
            //    }
            //    trainingReliability[i] = new double[1];
            //    //trainingReliability[i][0] = sumOfResponses / (double)numberOfMeasurements;
            //    trainingReliability[i][0] = Math.Abs(numberOfMeasurements / 2.0 - (sumOfResponses / (double)numberOfMeasurements));

            //}
        }

        //Generates the reliability training data for ONION attack only  
        public static List<ReliabilityDataPoint> GenerateReliabilityTrainingDataOnion(XORArbiterPUF xPUF, int numberOfMeasurements, double[][] trainingData, double[][] trainingReliability, Random randomGenerator)
        {
            List<ReliabilityDataPoint> ReliabilityDataPointList = new List<ReliabilityDataPoint>(); //This stores all the noisy and non noisy data points with appropriate APUF labels
            int trainingSize = trainingData.Length;
            int bitNum = xPUF.BitNumber;
            for (int i = 0; i < trainingSize; i++)
            {
                double sumOfResponses = 0;
                trainingData[i] = GenerateRandomPhiVector(bitNum, randomGenerator);
                int[] previousAPUFResponses = new int[xPUF.GetPUFNum()]; //this stores all previous PUF responses to see if flip occured
                List<ArbiterPUF> currentNoisyAPUFList = new List<ArbiterPUF>(); //this stores all the APUFs making the challenge noisy 
                for (int m = 0; m < numberOfMeasurements; m++)
                {
                    int finalResult = 0;
                    for (int p = 0; p < xPUF.GetPUFNum(); p++)
                    {
                        int currentResult = xPUF.GetAPUFAtIndex(p).ComputeNoisyResponse(trainingData[i]);
                        finalResult = finalResult ^ currentResult;

                        //this is the extra part for the onion attack
                        if (m == 0) //this is the first time measurement being done so record responses 
                        {
                            previousAPUFResponses[p] = currentResult;
                        }
                        else //compare to see if flipping occured 
                        {
                            if (previousAPUFResponses[p] == currentResult)
                            {
                                //This APUF is reliable for this challenge, do nothing 
                            }
                            else //This APUF is noisy for this phi
                            {
                                previousAPUFResponses[p] = currentResult; //store the new flip 
                                if (currentNoisyAPUFList.Contains(xPUF.GetAPUFAtIndex(p)) == false) //make sure the APUF hasn't been duplicated 
                                {
                                    currentNoisyAPUFList.Add(xPUF.GetAPUFAtIndex(p)); //note this does NOT copy, only puts pointer in memory
                                }
                            }
                        }
                    }
                    //sumOfResponses = sumOfResponses + xPUF.ComputeNoisyResponse(trainingData[i]); //sum the measurements
                    sumOfResponses = sumOfResponses + finalResult;
                }
                trainingReliability[i] = new double[1];
                trainingReliability[i][0] = Math.Abs(numberOfMeasurements / 2.0 - sumOfResponses);

                //All measurements have been done, time to store the data point for onion analysis 
                if (!currentNoisyAPUFList.Any() == true) //this means no APUFs made this challenge noisy so it is reliable 
                {
                    ReliabilityDataPointList.Add(new ReliabilityDataPoint(trainingData[i], trainingReliability[i][0], false));
                }
                else
                {
                    ReliabilityDataPointList.Add(new ReliabilityDataPoint(trainingData[i], trainingReliability[i][0], true, currentNoisyAPUFList));
                }

            }
            return ReliabilityDataPointList;
        }

        //Converts a binary challenge (0/1) valued to a phi challenge (-1/+1) valued 
        public static double[] ConvertBinaryChallengeToPhi(double[] binaryChallenge)
        {
            int bitNumber = binaryChallenge.Length;
            double[] challengePrime = new double[bitNumber]; //This is the +1,-1 representation of the challenge vector 
            double[] phiChallenge = new double[bitNumber + 1]; //length of phi is the length of the binary challenge + 1

            //first convert the challenge to +1, -1 using 0==>+1 and 1==>-1
            for (int i = 0; i < bitNumber; i++)
            {
                if (binaryChallenge[i] == 0)
                {
                    challengePrime[i] = 1.0;
                }
                else
                {
                    challengePrime[i] = -1.0;
                }
            }

            //Convert the +1,-1 representation to the phi vector 
            for (int i = 0; i < bitNumber; i++)
            {
                phiChallenge[i] = 1.0; //initially set to a dummy value 
                for (int j = i; j < bitNumber; j++)
                {
                    phiChallenge[i] = phiChallenge[i] * challengePrime[j];
                }
            }
            //the last element of phi must be a 1 
            phiChallenge[bitNumber] = 1.0;
            return phiChallenge;
        }

        //generate a random binary challenge 
        public static double[] GenerateRandomChallenge(int bitNum, Random randomGenerator)
        {
            double[] binaryChallenge = new double[bitNum];
            for (int i = 0; i < bitNum; i++)
            {
                //double determiner = AppConstants.rx.NextDouble();
                double determiner = randomGenerator.NextDouble();
                if (determiner > 0.5)
                {
                    binaryChallenge[i] = 1.0;
                }
                else
                {
                    binaryChallenge[i] = 0.0;
                }
            }
            return binaryChallenge;
        }

        //Generates a random phi challenge (with the last index always being 1)
        public static double[] GenerateRandomPhiVector(int bitNum, Random randomGenerator)
        {
            //First generate a random binary challenge 
            //double[] binaryChallenge = GenerateRandomChallenge(bitNum);
            double[] binaryChallenge = GenerateRandomChallenge(bitNum, randomGenerator);
            //Convert the challenge to the phi space
            double[] phi = ConvertBinaryChallengeToPhi(binaryChallenge);
            return phi;
        }

        //For use in the original reliability attack 
        public static double PearsonCorrelationCoefficient(double[] vectorA, double[] vectorB)
        {
            double pearsonCoeff;
            //compute the average of vector A
            double averageVectorA = 0;
            for (int i = 0; i < vectorA.Length; i++)
            {
                averageVectorA = averageVectorA + vectorA[i];
            }
            averageVectorA = averageVectorA / (double)vectorA.Length;

            //compute the average of vector B
            double averageVectorB = 0;
            for (int i = 0; i < vectorB.Length; i++)
            {
                averageVectorB = averageVectorB + vectorB[i];
            }
            averageVectorB = averageVectorB / (double)vectorB.Length;

            //Compute numerator 
            double numerator = 0;
            for (int i = 0; i < vectorA.Length; i++)
            {
                numerator = numerator + (vectorA[i] - averageVectorA) * (vectorB[i] - averageVectorB);
            }

            //Compute denominator 
            double denominatorA = 0;
            double denominatorB = 0;
            for (int i = 0; i < vectorA.Length; i++)
            {
                denominatorA = denominatorA + (vectorA[i] - averageVectorA) * (vectorA[i] - averageVectorA);
                denominatorB = denominatorB + (vectorB[i] - averageVectorB) * (vectorB[i] - averageVectorB);
            }
            denominatorA = Math.Sqrt(denominatorA);
            denominatorB = Math.Sqrt(denominatorB);

            pearsonCoeff = numerator / (denominatorA * denominatorB);

            //Error handling, just seeing if this makes a difference in the code 
            //if (numerator != 0 && denominatorA * denominatorB == 0)
            //{
            //    throw new Exception("Divide by zero error caught!");
            //}
            //if (numerator == 0 && denominatorA * denominatorB == 0) //Avoid dividing by zero
            //{
            //    pearsonCoeff = 0.0;
            //}

            return pearsonCoeff;
        }

        //Used to generate the weights randomly for the Arbiter PUF
        public static double GenerateRandomNormalVariable(double mean, double variance, Random RandomGenerator)
        {
            //generate normal random variable, code borrowed from Stack Overflow
            double u1 = 1.0 - RandomGenerator.NextDouble(); //uniform(0,1] random doubles
            double u2 = 1.0 - RandomGenerator.NextDouble();
            double randStdNormal = Math.Sqrt(-2.0 * Math.Log(u1)) * Math.Sin(2.0 * Math.PI * u2); //random normal(0,1)
            double randNormal = mean + Math.Sqrt(variance) * randStdNormal; //random normal(mean,stdDev^2)
            return randNormal;
        }
    }
}
