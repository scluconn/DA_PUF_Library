using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    class AttackTest
    {
        //Attack different XOR APUFs (same type) in parallel 
        //public static void RepeatAttackOnePUFType()
        //{
        //    int attackNumber = 40;

        //    double[] currentAccuracies = ClassicalAttackXORAPUFMulti(bitNumber, xorNumber, AppConstants.CoreNumber);
        //}

        //int bitNumber = 128;
        //int xorNumber = 4;
        //Runs attack multiple times, each time it is on a DIFFERENT XOR APUF
        public static double[] ClassicalAttackXORAPUFMulti(int bitNumber, int numXOR, int attackRepeatNumber)
        {
            //Generate a PUF 
            double aPUFMean = 0.0;
            double aPUFVar = 1.0;
            double aPUFMeanNoise = 0.0;
            double aPUFNoiseVar = 0.0;

            //Create the XOR APUF for parallel runs 
            XORArbiterPUF xPUF = new XORArbiterPUF(numXOR, bitNumber, aPUFMean, aPUFVar, aPUFMeanNoise, aPUFNoiseVar);
            XORArbiterPUF[] xArray = new XORArbiterPUF[attackRepeatNumber];
            for (int i = 0; i < xArray.Length; i++)
            {
                xArray[i] = new XORArbiterPUF(numXOR, bitNumber, aPUFMean, aPUFVar, aPUFMeanNoise, aPUFNoiseVar);
            }

            sbyte[][] trainingData = new sbyte[AppConstants.TrainingSize][]; //these will be phi vectors 
            sbyte[][] allTrainingResponses = new sbyte[attackRepeatNumber][]; //first index PUF, second index sample

            for (int i = 0; i < attackRepeatNumber; i++)
            {
                allTrainingResponses[i] = new sbyte[AppConstants.TrainingSize];
            }
            Random[] rGenArray = new Random[AppConstants.CoreNumber];
            for (int i = 0; i < AppConstants.CoreNumber; i++)
            {
                rGenArray[i] = new Random((int)DateTime.Now.Ticks);
                System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same 
            }
            DataGeneration.GenerateTrainingDataParallel(xArray, trainingData, allTrainingResponses, rGenArray);
            Console.Out.WriteLine("Data Generation Complete.");

            //create the objective function for parallel runs 
            ObjectiveFunctionResponseXOR[] rObjArray = new ObjectiveFunctionResponseXOR[attackRepeatNumber];
            for (int i = 0; i < rObjArray.Length; i++)
            {
                rObjArray[i] = new ObjectiveFunctionResponseXOR();
            }
            double[][] solutionList = new double[attackRepeatNumber][];

            Random[] randomGeneratorArray = new Random[attackRepeatNumber];
            for (int r = 0; r < attackRepeatNumber; r++)
            {
                randomGeneratorArray[r] = new Random((int)DateTime.Now.Ticks);
                System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same 
            }

            //time to save the invariant data 
            //if (AppConstants.IsLargeData == false)
            //{
            InvariantData invD = new InvariantData(trainingData, allTrainingResponses, xArray);
            string dayString = System.DateTime.Today.ToString();
            dayString = dayString.Replace(@"/", "-");
            dayString = dayString.Replace(" ", string.Empty);
            dayString = dayString.Replace(":", string.Empty);
            string invariantDataFileName = "InvariantData" + dayString;
            string fName = AppConstants.SaveDir + invariantDataFileName;
            FileInfo fi = new FileInfo(fName);
            Stream str = fi.Open(FileMode.OpenOrCreate, FileAccess.Write);
            BinaryFormatter bf = new BinaryFormatter();
            invD.Serialize(bf, str);
            str.Close();
      
            var watch = System.Diagnostics.Stopwatch.StartNew();
            Parallel.For(0, attackRepeatNumber, a =>
            {
                Random randomGenerator = randomGeneratorArray[a]; //remove the dependences for parallelization 
                int dimensionNumber = (bitNumber + 1) * xArray[a].GetPUFNum(); //the weights of all the XOR APUFs 
                sbyte[] trainingResponse = allTrainingResponses[a];
                //Generate the first solution randomly for CMA-ES 
                double[] firstSolution = new double[dimensionNumber];
                for (int i = 0; i < firstSolution.Length; i++)
                {
                    firstSolution[i] = randomGenerator.NextDouble();
                }
                Console.Out.WriteLine("Beginning CMA-ES run # " + a.ToString());
                //CMAESCandidate solutionCMAES = CMAESMethods.ComputeCMAES(dimensionNumber, rObjArray[a], trainingData, trainingResponse, firstSolution, randomGenerator);
                CMAESCandidate solutionCMAES = CMAESMethods.ComputeCMAESRecoverable(dimensionNumber, rObjArray[a], trainingData, trainingResponse, firstSolution, randomGenerator, a);
                double solutionVal = solutionCMAES.GetObjectiveFunctionValue();
                solutionList[a] = solutionCMAES.GetWeightVector(); //store the solution in independent memory 
                Console.Out.WriteLine("CMA-ES on core " + a.ToString() + " finished.");

            });
            watch.Stop();
            Console.Out.WriteLine("Elapsed Time is " + watch.ElapsedMilliseconds.ToString());

            //measure the accuracy
            Random randomGenerator2 = new Random((int)DateTime.Now.Ticks);
            double averageAccuracy = 0;
            double[] solutionAccuracies = new double[attackRepeatNumber];
            for (int a = 0; a < solutionList.Length; a++)
            {
                sbyte[][] testingData = new sbyte[AppConstants.TestingSize][]; //these will be phi vectors 
                sbyte[] testingResponse = new sbyte[AppConstants.TestingSize];
                DataGeneration.GenerateTrainingData(xArray[a], testingData, testingResponse, randomGenerator2);
                double accMeasures = rObjArray[0].ObjFunValue(solutionList[a], testingData, testingResponse);
                solutionAccuracies[a] = accMeasures;
                averageAccuracy = averageAccuracy + accMeasures;
            }
            averageAccuracy = averageAccuracy / (double)attackRepeatNumber;
            Console.Out.WriteLine("The average accuracy for the XOR APUF is " + averageAccuracy.ToString());
            return solutionAccuracies;
        }

        public static double[] ClassicalAttackXORAPUFMultiRecovered(int bitNumber, int attackRepeatNumber, InvariantData invData, VariantData[] variantDataArray)
        {
            //Create the XOR APUF for parallel runs 
            XORArbiterPUF[] xArray = new XORArbiterPUF[attackRepeatNumber];
            for (int i = 0; i < xArray.Length; i++)
            {
                xArray[i] = (XORArbiterPUF)invData.GetPUFatIndex(i);
            }

            sbyte[][] trainingData = invData.GetTrainingData(); //these will be phi vectors 
            sbyte[][] allTrainingResponses = invData.GetTrainingResponseAll(); //first index PUF, second index sample

            //create the objective function for parallel runs 
            ObjectiveFunctionResponseXOR[] rObjArray = new ObjectiveFunctionResponseXOR[attackRepeatNumber];
            for (int i = 0; i < rObjArray.Length; i++)
            {
                rObjArray[i] = new ObjectiveFunctionResponseXOR();
            }
            double[][] solutionList = new double[attackRepeatNumber][];

            Random[] randomGeneratorArray = new Random[attackRepeatNumber];
            for (int r = 0; r < attackRepeatNumber; r++)
            {
                randomGeneratorArray[r] = new Random((int)DateTime.Now.Ticks);
                System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same 
            }
      
            var watch = System.Diagnostics.Stopwatch.StartNew();
            Parallel.For(0, attackRepeatNumber, a =>
            {
                Random randomGenerator = randomGeneratorArray[a]; //remove the dependences for parallelization 
                int dimensionNumber = (bitNumber + 1) * xArray[a].GetPUFNum(); //the weights of all the XOR APUFs 
                sbyte[] trainingResponse = allTrainingResponses[a];
                //Generate the first solution randomly for CMA-ES 
                double[] firstSolution = new double[dimensionNumber];
                for (int i = 0; i < firstSolution.Length; i++)
                {
                    firstSolution[i] = randomGenerator.NextDouble();
                }
                Console.Out.WriteLine("Beginning CMA-ES run # " + a.ToString());
                //CMAESCandidate solutionCMAES = CMAESMethods.ComputeCMAES(dimensionNumber, rObjArray[a], trainingData, trainingResponse, firstSolution, randomGenerator);
                CMAESCandidate solutionCMAES = CMAESMethods.RecoveredCMAES(randomGenerator, a, rObjArray[a], invData, variantDataArray[a]);
                double solutionVal = solutionCMAES.GetObjectiveFunctionValue();
                solutionList[a] = solutionCMAES.GetWeightVector(); //store the solution in independent memory 
                Console.Out.WriteLine("CMA-ES on core " + a.ToString() + " finished.");
                //Console.Out.WriteLine("Final training value is "+solutionVal.ToString());
                //}
            });
            watch.Stop();
            Console.Out.WriteLine("Elapsed Time is " + watch.ElapsedMilliseconds.ToString());

            //measure the accuracy
            Random randomGenerator2 = new Random((int)DateTime.Now.Ticks);
            double averageAccuracy = 0;
            double[] solutionAccuracies = new double[attackRepeatNumber];
            for (int a = 0; a < solutionList.Length; a++)
            {
                sbyte[][] testingData = new sbyte[AppConstants.TestingSize][]; //these will be phi vectors 
                sbyte[] testingResponse = new sbyte[AppConstants.TestingSize];
                DataGeneration.GenerateTrainingData(xArray[a], testingData, testingResponse, randomGenerator2);
                double accMeasures = rObjArray[0].ObjFunValue(solutionList[a], testingData, testingResponse);
                solutionAccuracies[a] = accMeasures;
                averageAccuracy = averageAccuracy + accMeasures;
            }
            averageAccuracy = averageAccuracy / (double)attackRepeatNumber;
            Console.Out.WriteLine("The average accuracy for the XOR APUF is " + averageAccuracy.ToString());
            return solutionAccuracies;
        }

        //Runs the attack on one PUF model, the cores are used to evaluate the CRPs of one model (in parallel) so the method will run as fast as possible
        public static double ClassicalAttackXORAPUFSingle(int bitNumber, int numXOR)
        {
            //Generate a PUF 
            double aPUFMean = 0.0;
            double aPUFVar = 1.0;
            double aPUFMeanNoise = 0.0;
            double aPUFNoiseVar = 0.0;

            //Create the XOR APUF
            XORArbiterPUF xPUF = new XORArbiterPUF(numXOR, bitNumber, aPUFMean, aPUFVar, aPUFMeanNoise, aPUFNoiseVar);

            //Arrays for storing the training data 
            sbyte[][] trainingData = new sbyte[AppConstants.TrainingSize][]; //these will be phi vectors 
            sbyte[][] allTrainingResponses = new sbyte[1][]; //first index PUF, second index sample
            allTrainingResponses[0] = new sbyte[AppConstants.TrainingSize];

            Random[] rGenArray = new Random[AppConstants.CoreNumber];
            for (int i = 0; i < AppConstants.CoreNumber; i++)
            {
                rGenArray[i] = new Random((int)DateTime.Now.Ticks);
                System.Threading.Thread.Sleep(10); //prevent the random number generators from being the same 
            }
            DataGeneration.GenerateTrainingDataParallel(xPUF, trainingData, allTrainingResponses, rGenArray);
            Console.Out.WriteLine("Data Generation Complete.");

            //create the objective function for parallel runs 
            ObjectiveFunctionResponseXOR rObj = new ObjectiveFunctionResponseXOR();
    
            //Start the attack run 
            var watch = System.Diagnostics.Stopwatch.StartNew();
            Random randomGenerator = new Random((int)DateTime.Now.Ticks); ;
            int dimensionNumber = (bitNumber + 1) * xPUF.GetPUFNum(); //the weights of all the XOR APUFs 
            sbyte[] trainingResponse = allTrainingResponses[0];
            //Generate the first solution randomly for CMA-ES 
            double[] firstSolution = new double[dimensionNumber];
            for (int i = 0; i < firstSolution.Length; i++)
            {
                firstSolution[i] = randomGenerator.NextDouble();
            }
            Console.Out.WriteLine("Beginning CMA-ES");
            //The next line uses maximum parallelism on a single run 
            CMAESCandidate solutionCMAES = CMAESMethods.ComputeCMAES(dimensionNumber, rObj, trainingData, trainingResponse, firstSolution, randomGenerator);
            double solutionVal = solutionCMAES.GetObjectiveFunctionValue();
            double[] computedSolution = solutionCMAES.GetWeightVector(); //store the solution in independent memory 
            Console.Out.WriteLine("CMA-ES finished.");
            watch.Stop();
            Console.Out.WriteLine("Elapsed Time is " + watch.ElapsedMilliseconds.ToString());

            //turn off parallelism
            AppConstants.UseParallelismOnSingleCMAES = false;

            //measure the accuracy
            Random randomGenerator2 = new Random((int)DateTime.Now.Ticks);
            sbyte[][] testingData = new sbyte[AppConstants.TestingSize][]; //these will be phi vectors 
            sbyte[] testingResponse = new sbyte[AppConstants.TestingSize];
            DataGeneration.GenerateTrainingData(xPUF, testingData, testingResponse, randomGenerator2);
            double accMeasure = rObj.ObjFunValue(computedSolution, testingData, testingResponse);
            Console.Out.WriteLine("The accuracy for the XOR APUF is " + accMeasure.ToString());
            return accMeasure;
        }
    }
}
