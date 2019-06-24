using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    class DataGeneration
    {
        //Generates the response training data 
        public static void GenerateTrainingData(PhysicallyUncloneableFunction aPUF, sbyte[][] trainingData, sbyte[] trainingResponse, Random randomGenerator)
        {
            int trainingSize = trainingData.Length;
            int bitNum = aPUF.BitNumber;
            for (int i = 0; i < trainingSize; i++)
            {
                trainingData[i] = GenerateRandomPhiVector(bitNum, randomGenerator);
                //trainingResponse[i] = new sbyte[1];
                trainingResponse[i] = aPUF.ComputeResponse(trainingData[i]);
            }
        }

        //Generates the response training data for multiple PUF models (given an array of PUFs) with parallelization
        public static void GenerateTrainingDataParallel(PhysicallyUncloneableFunction[] aPUFs, sbyte[][] trainingData, sbyte[][] trainingResponse, Random[] randomGenerator)
        {
            int trainingSize = trainingData.Length;
            int pufNumber = aPUFs.Length; //number of PUFs to create training data for
            int coreNumberForThisMethodOnly = AppConstants.CoreNumber;
            //error checking 
            //double roundCheck = trainingSize / (double)AppConstants.CoreNumber;
            double roundCheck = trainingSize / (double)coreNumberForThisMethodOnly;
            //double hello = (int)roundCheck;
            if (roundCheck != (int)roundCheck)
            {
                //throw new Exception("The training size is not integer divisible by the number of CPU cores. Resize training data or avoid parallelization.");
                coreNumberForThisMethodOnly = AppConstants.CoreNumber - 3; //try reducing the core number to make the parallelization work

                //do another double check just to be safe
                roundCheck = trainingSize / (double)coreNumberForThisMethodOnly;
                if (roundCheck != (int)roundCheck)
                {
                    throw new Exception("The training size is not integer divisible by the number of CPU cores. Resize training data or avoid parallelization.");
                }

            }
            if (aPUFs.Length != trainingResponse.Length)
            {
                throw new Exception("The size of the response array is not equal to the number of PUFs generating responses");
            }

            int trainingBlock = trainingSize / coreNumberForThisMethodOnly;
            int bitNum = aPUFs[0].BitNumber; //assume all PUFs have the same number of bits 
            Parallel.For(0, coreNumberForThisMethodOnly, i =>
            //for(int i=0;i<coreNumberForThisMethodOnly;i++)
            {
                //for (int i = 0; i < AppConstants.CoreNumber; i++)
                //{ 
                for (int j = trainingBlock * i; j < (trainingBlock * (i + 1)); j++)
                {
                    trainingData[j] = GenerateRandomPhiVector(bitNum, randomGenerator[i]);
                    for (int k = 0; k < pufNumber; k++)
                    {
                        //trainingResponse[k][j] = new sbyte[1];
                        trainingResponse[k][j] = aPUFs[k].ComputeResponse(trainingData[j]);
                    }

                }
                Console.Out.WriteLine(i.ToString());
                // }
            });
            //int l = 0;
        }

        //Generates the response training data for a single PUF model in parallel
        public static void GenerateTrainingDataParallel(PhysicallyUncloneableFunction aPUF, sbyte[][] trainingData, sbyte[][] trainingResponse, Random[] randomGenerator)
        {
            int trainingSize = trainingData.Length;
            int coreNumberForThisMethodOnly = AppConstants.CoreNumber;
            //error checking 
            double roundCheck = trainingSize / (double)coreNumberForThisMethodOnly;
            if (roundCheck != (int)roundCheck)
            {
                coreNumberForThisMethodOnly = AppConstants.CoreNumber - 3; //try reducing the core number to make the parallelization work

                //do another double check just to be safe
                roundCheck = trainingSize / (double)coreNumberForThisMethodOnly;
                if (roundCheck != (int)roundCheck)
                {
                    throw new Exception("The training size is not integer divisible by the number of CPU cores. Resize training data or avoid parallelization.");
                }

            }

            int trainingBlock = trainingSize / coreNumberForThisMethodOnly;
            int bitNum = aPUF.BitNumber;
            Parallel.For(0, coreNumberForThisMethodOnly, i =>
            //for(int i=0;i<coreNumberForThisMethodOnly;i++)
            {
                //for (int i = 0; i < AppConstants.CoreNumber; i++)
                //{ 
                for (int j = trainingBlock * i; j < (trainingBlock * (i + 1)); j++)
                {
                    trainingData[j] = GenerateRandomPhiVector(bitNum, randomGenerator[i]);
                    trainingResponse[0][j] = aPUF.ComputeResponse(trainingData[j]);
                }
                Console.Out.WriteLine(i.ToString());
                // }
            });
            //int l = 0;
        }

        //Converts a binary challenge (0/1) valued to a phi challenge (-1/+1) valued 
        public static sbyte[] ConvertBinaryChallengeToPhi(sbyte[] binaryChallenge)
        {
            int bitNumber = binaryChallenge.Length;
            sbyte[] challengePrime = new sbyte[bitNumber]; //This is the +1,-1 representation of the challenge vector 
            sbyte[] phiChallenge = new sbyte[bitNumber + 1]; //length of phi is the length of the binary challenge + 1

            //first convert the challenge to +1, -1 using 0==>+1 and 1==>-1
            for (int i = 0; i < bitNumber; i++)
            {
                if (binaryChallenge[i] == 0)
                {
                    challengePrime[i] = 1;
                }
                else
                {
                    challengePrime[i] = -1;
                }
            }

            //Convert the +1,-1 representation to the phi vector 
            for (int i = 0; i < bitNumber; i++)
            {
                phiChallenge[i] = 1; //initially set to a dummy value 
                for (int j = i; j < bitNumber; j++)
                {
                    phiChallenge[i] = (sbyte)(phiChallenge[i] * challengePrime[j]); //must do typecasting because byte*byte=int
                }
            }
            //the last element of phi must be a 1 
            phiChallenge[bitNumber] = 1;
            return phiChallenge;
        }

        public static sbyte[] ConvertPhiToBinaryChallenge(sbyte[] phi)
        {
            int bitNumber = phi.Length - 1;
            sbyte[] binaryChallenge = new sbyte[bitNumber];
            binaryChallenge[bitNumber - 1] = (sbyte)((-phi[bitNumber - 1] + 1) / 2); //operations create int, must typecast back to sbyte
            int denominator = 1 - 2 * binaryChallenge[bitNumber - 1];
            //already did the last bit of the binary challenge, now can compute backwards 
            for (int i = bitNumber - 2; i >= 0; i--)
            {
                binaryChallenge[i] = (sbyte)(((-phi[i] / denominator) + 1) / 2);
                denominator = denominator * (1 - 2 * binaryChallenge[i]);
            }
            return binaryChallenge;
        }

        //della
        public static void TestConversion()
        {
            int bitN = 64;
            Random rGen = new Random();
            for (int i = 0; i < 10000; i++)
            {
                sbyte[] binaryChallenge = GenerateRandomChallenge(bitN, rGen);
                sbyte[] phi = ConvertBinaryChallengeToPhi(binaryChallenge);
                sbyte[] binaryChallenge2 = ConvertPhiToBinaryChallenge(phi);
                for (int j = 0; j < bitN; j++)
                {
                    if (binaryChallenge[j] != binaryChallenge2[j])
                    {
                        throw new Exception("The conversion didn't work");
                    }
                }
            }
        }

        //generate a random binary challenge 
        public static sbyte[] GenerateRandomChallenge(int bitNum, Random randomGenerator)
        {
            sbyte[] binaryChallenge = new sbyte[bitNum];
            for (int i = 0; i < bitNum; i++)
            {
                //double determiner = AppConstants.rx.NextDouble();
                double determiner = randomGenerator.NextDouble();
                if (determiner > 0.5)
                {
                    binaryChallenge[i] = 1;
                }
                else
                {
                    binaryChallenge[i] = 0;
                }
            }
            return binaryChallenge;
        }

        //Generates a random phi challenge (with the last index always being 1)
        public static sbyte[] GenerateRandomPhiVector(int bitNum, Random randomGenerator)
        {
            //First generate a random binary challenge 
            //double[] binaryChallenge = GenerateRandomChallenge(bitNum);
            sbyte[] binaryChallenge = GenerateRandomChallenge(bitNum, randomGenerator);
            //Convert the challenge to the phi space
            sbyte[] phi = ConvertBinaryChallengeToPhi(binaryChallenge);
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

        //Generates textfiles for loading IPUF training data into Keras
        public static void GenerateIPUFDataForKeras(PhysicallyUncloneableFunction iPUF, int trainingSize, string trainDirectory)
        {
            int indexer = 0;
            sbyte[][] trainingData = new sbyte[trainingSize][];
            sbyte[][] trainingResponse = new sbyte[1][]; //first index corresponds to the number of different PUFs (in this case 1) second index is sample number
            trainingResponse[0] = new sbyte[trainingSize];
            Random[] rGen = new Random[AppConstants.CoreNumber];
            PhysicallyUncloneableFunction[] iPUFHolder = new PhysicallyUncloneableFunction[] { iPUF }; //only need a single IPUF for this type of data generation

            //Data is generated in parallel so we need a random number generator for each core
            for (int i = 0; i < AppConstants.CoreNumber; i++)
            {
                rGen[i] = new Random((int)DateTime.Now.Ticks);
                System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same
            }
            //Generate all the training data and responses in blocks (in parallel)
            GenerateTrainingDataParallel(iPUFHolder, trainingData, trainingResponse, rGen);

            //Now have the training data and responses filled in, time to write to textfiles
            string[] lines = new string[trainingSize];
            string[] phiLine = new string[1]; //this is to write phi information into the text file
            for (int i = 0; i < trainingSize; i++)
            {
                //lines[i] = trainingResponse[0][i].ToString();
                lines[i] = "";
                for (int j = 0; j < iPUF.BitNumber + 1; j++) //length of phi 
                {
                    if (trainingData[i][j] == 1)
                    {
                        lines[i] = lines[i] + trainingData[i][j];
                    }
                    else
                    {
                        lines[i] = lines[i] + "m"; //m means -1 
                    }
                }
                phiLine[0] = lines[i];
                string currentFileName = trainingResponse[0][i].ToString() + indexer.ToString();
                File.WriteAllLines(trainDirectory + "\\" + currentFileName + ".txt", phiLine);
                indexer++;
            }
            //Write the training text file that contains all the examples
            //string[] trainingFileLines = new string[trainingSize];
            //for (int i = 0; i < trainingSize; i++)
            //{
            //    trainingFileLines[i] = lines[i] + ".txt" + "\t" + trainingResponse[0][i].ToString();
            //}
            //File.WriteAllLines(trainDirectory + "\\TrainingClassList.txt", trainingFileLines);
        }
    }
}
