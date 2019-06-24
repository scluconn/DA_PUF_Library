using MathNet.Numerics.LinearAlgebra;
using MathNet.Numerics.LinearAlgebra.Factorization;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    class CMAESMethods
    {
        //Copy of python's tile function 
        public static Matrix<double> Tile(int repeatNum, Matrix<double> originalVector)
        {
            Matrix<double> tileMatrix = Matrix<double>.Build.Dense(repeatNum, originalVector.RowCount);
            for (int rowIndex = 0; rowIndex < repeatNum; rowIndex++)
            {
                for (int colIndex = 0; colIndex < originalVector.RowCount; colIndex++)
                {
                    tileMatrix[rowIndex, colIndex] = originalVector[colIndex, 0];
                }
            }
            tileMatrix = tileMatrix.Transpose(); //quick fix
            return tileMatrix;
        }

        //copy of the single input version of the Matlab diag function 
        //input vector of size n, returns matrix of size nxn with the diagonals filled in 
        public static Matrix<double> Diagonalize1DMatrix(Matrix<double> inputMatrix)
        {
            Matrix<double> diagSolution = Matrix<double>.Build.Dense(inputMatrix.RowCount, inputMatrix.RowCount);
            int indexer = 0;
            for (int i = 0; i < inputMatrix.RowCount; i++)
            {
                for (int j = 0; j < inputMatrix.RowCount; j++)
                {
                    if (i == j)
                    {
                        diagSolution[i, j] = inputMatrix[indexer, 0];
                        indexer++;
                    }
                }
            }
            return diagSolution;
        }

        //Used to generate random numbers   
        public static double GenerateRandomNormalVariableForCMAES(Random randomGenerator, double mean, double variance)
        {
            //generate normal random variable, code borrowed from Stack Overflow
            double u1 = 1.0 - randomGenerator.NextDouble(); //uniform(0,1] random doubles
            double u2 = 1.0 - randomGenerator.NextDouble();
            double randStdNormal = Math.Sqrt(-2.0 * Math.Log(u1)) * Math.Sin(2.0 * Math.PI * u2); //random normal(0,1)
            double randNormal = mean + Math.Sqrt(variance) * randStdNormal; //random normal(mean,stdDev^2)
            return randNormal;
        }

        public static CMAESCandidate ComputeCMAES(int dimensionNumber, PUFObjectiveFunction pFunction, sbyte[][] trainingData, sbyte[] targets, double[] initialWeightVector, Random randomGenerator)
        {
            int n = dimensionNumber; //number of weights + epsilon 
            Matrix<double> xMean = Matrix<double>.Build.Dense(n, 1);
            CMAESCandidate c11 = new CMAESCandidate(initialWeightVector, trainingData, targets, pFunction);
            Console.Out.WriteLine("Starting Point Accuracy");
            Console.Out.WriteLine(c11.GetObjectiveFunctionValue().ToString());

            CMAESCandidate globalBestCandidate = null;

            double sigma = 0.5;
            //double stopfitness = 1e-10;
            double stopFitness = 0.98;
            int stopeval = AppConstants.MaxIterationNumberCMAES;
            //double stopeval = AppConstants.MaxEvaluations
            //Strategy parameter setting: Selection  
            int lambdaVal = (int)(4.0 + Math.Floor(3.0 * Math.Log(n)));  //population size, note lambda keyword reserved by python so lambda->lambdaVal
            //lambdaVal = AppConstants.PopulationSizeCMAES #change by KRM cause I think we need more sampling
            double mu = lambdaVal / 2.0;
            Matrix<double> weights = Matrix<double>.Build.Dense((int)mu, 1);  //weights = numpy.matrix(weightsPrime, dtype = float).reshape(mu, 1)
            for (int i = 0; i < (int)mu; i++)
            {
                weights[i, 0] = Math.Log(mu + 0.5) - Math.Log(i + 1); //weights[i, 0] = math.log(mu + 0.5) - math.log((i + 1))#use i+1 instead of i in this case to match matlab indexing
            }
            mu = Math.Floor(mu);
            double sumWeights = 0.0;
            for (int i = 0; i < weights.RowCount; i++)
            {
                sumWeights = sumWeights + weights[i, 0];

            }
            //Divide by the sum
            for (int i = 0; i < weights.RowCount; i++)
            {
                weights[i, 0] = weights[i, 0] / sumWeights;
            }
            //Computation for the mueff variable
            double mueffNum = 0.0;
            double mueffDem = 0.0;
            for (int i = 0; i < weights.RowCount; i++)
            {
                mueffNum = weights[i, 0] + mueffNum;
                mueffDem = weights[i, 0] * weights[i, 0] + mueffDem;
            }
            mueffNum = mueffNum * mueffNum;
            double mueff = mueffNum / mueffDem;

            // Strategy parameter setting: Adaptation
            double cc = (4.0 + mueff / n) / (n + 4.0 + 2.0 * mueff / n); //#time constant for cumulation for C
            double cs = (mueff + 2.0) / (n + mueff + 5.0);  //#t-const for cumulation for sigma control
            double c1 = 2.0 / ((n + 1.3) * (n + 1.3) + mueff);    //#learning rate for rank-one update of C
            double cmu = Math.Min(1.0 - c1, 2.0 * (mueff - 2.0 + 1.0 / mueff) / ((n + 2) * (n + 2) + mueff)); //# and for rank-mu update
            double damps = 1.0 + 2.0 * Math.Max(0, Math.Sqrt((mueff - 1) / (n + 1)) - 1) + cs; //# damping for sigma 

            //Initialize dynamic (internal) strategy parameters and constants
            //evolution paths for C and sigma
            Matrix<double> pc = Matrix<double>.Build.Dense(n, 1);
            Matrix<double> ps = Matrix<double>.Build.Dense(n, 1);
            Matrix<double> D = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                pc[i, 0] = 0;
                ps[i, 0] = 0;
                D[i, 0] = 1.0;
            }
            //Create B Matrix
            Matrix<double> B = Matrix<double>.Build.Dense(n, n);
            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    if (i == j)
                    {
                        B[i, j] = 1.0;
                    }
                    else
                    {
                        B[i, j] = 0.0;
                    }
                }
            }
            //Create C Matrix
            Matrix<double> dSquare = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                dSquare[i, 0] = D[i, 0] * D[i, 0];
            }
            Matrix<double> C = B * Diagonalize1DMatrix(dSquare) * B.Transpose(); //C = B * self.diag(DSquare) * numpy.transpose(B)
            //Create invertsqrtC Matrix
            Matrix<double> oneOverD = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                oneOverD[i, 0] = 1.0 / D[i, 0];
            }
            Matrix<double> invsqrtC = B * Diagonalize1DMatrix(oneOverD) * B.Transpose();
            double eigeneval = 0; //track update of B and D
            double chiN = Math.Pow(n, 0.5) * (1.0 - 1.0 / (4.0 * n) + 1.0 / (21.0 * Math.Pow(n, 2.0)));
            int counteval = 0;

            //the next 40 lines contain the 20 lines of interesting code 
            //CMAESCandidate[] candidateArray = new CMAESCandidate[lambdaVal];
            List<CMAESCandidate> candidateArray = new List<CMAESCandidate>();
            for (int i = 0; i < lambdaVal; i++)
            {
                candidateArray.Add(new CMAESCandidate());
            }

            while (counteval < stopeval)
            {
                Matrix<double> arx = Matrix<double>.Build.Dense(n, lambdaVal);

                //fill in the initial solutions 
                for (int i = 0; i < lambdaVal; i++)
                {
                    Matrix<double> randD = Matrix<double>.Build.Dense(n, 1);
                    for (int j = 0; j < n; j++)
                    {
                        randD[j, 0] = D[j, 0] * GenerateRandomNormalVariableForCMAES(randomGenerator, 0, 1.0);
                    }
                    Matrix<double> inputVector = xMean + sigma * B * randD;
                    double[] tempWeightVector = new double[inputVector.RowCount];
                    for (int k = 0; k < inputVector.RowCount; k++)
                    {
                        tempWeightVector[k] = inputVector[k, 0];
                    }
                    candidateArray[i] = new CMAESCandidate(tempWeightVector, trainingData, targets, pFunction);
                    counteval = counteval + 1;
                }
                candidateArray.Sort(); //This maybe problematic, not sure about sorting in C#
                candidateArray.Reverse();
                Matrix<double> xOld = xMean.Clone();
                //Get the new mean value 
                Matrix<double> arxSubset = Matrix<double>.Build.Dense(n, (int)mu); //in Maltab this variable would be "arx(:,arindex(1:mu))

                //This replaces line  arxSubset[:, i] = CandidateList[i].InputVector
                for (int i = 0; i < mu; i++)
                {
                    for (int j = 0; j < n; j++)
                    {
                        arxSubset[j, i] = candidateArray[i].GetWeightVector()[j];
                    }
                }
                xMean = arxSubset * weights; //Line 76 Matlab
                //Cumulation: Update evolution paths
                ps = (1 - cs) * ps + Math.Sqrt(cs * (2.0 - cs) * mueff) * invsqrtC * (xMean - xOld) / sigma;
                //Compute ps.^2 equivalent
                double psSquare = 0;
                for (int i = 0; i < ps.RowCount; i++)
                {
                    psSquare = psSquare + ps[i, 0] * ps[i, 0];
                }

                //Compute hsig 
                double hSig = 0.0;
                double term1ForHsig = psSquare / (1.0 - Math.Pow(1.0 - cs, 2.0 * counteval / lambdaVal)) / n;
                double term2ForHsig = 2.0 + 4.0 / (n + 1.0);
                if (term1ForHsig < term2ForHsig)
                {
                    hSig = 1.0;
                }
                //Compute pc, Line 82 Matlab
                pc = (1.0 - cc) * pc + hSig * Math.Sqrt(cc * (2.0 - cc) * mueff) * (xMean - xOld) / sigma;
                //Adapt covariance matrix C
                Matrix<double> repmatMatrix = Tile((int)mu, xOld); //NOT SURE IF THIS IS RIGHT IN C# FIX repmatMatrix = numpy.tile(xold, mu)
                Matrix<double> artmp = (1.0 / sigma) * (arxSubset - repmatMatrix);
                // C = (1-c1-cmu) * C  + c1 * (pc * pc' + (1-hsig) * cc*(2-cc) * C) + cmu * artmp * diag(weights) * artmp' #This is the original Matlab line for reference
                C = (1.0 - c1 - cmu) * C + c1 * (pc * pc.Transpose() + (1 - hSig) * cc * (2.0 - cc) * C) + cmu * artmp * Diagonalize1DMatrix(weights) * artmp.Transpose();
                //Adapt step size sigma
                //sigma = sigma * Math.Exp((cs / damps) * (numpy.linalg.norm(ps) / chiN - 1))
                sigma = sigma * Math.Exp((cs / damps) * (ps.L2Norm() / chiN - 1)); //NOT SURE IF THIS IS RIGHT FIX IN C#
                //Update B and D from C
                if ((counteval - eigeneval) > (lambdaVal / (c1 + cmu) / n / 10.0))
                {
                    eigeneval = counteval;
                    //C = numpy.triu(C) + numpy.transpose(numpy.triu(C, 1)) #enforce symmetry
                    C = C.UpperTriangle() + C.StrictlyUpperTriangle().Transpose(); //NOT SURE IF THIS IS RIGHT FIX IN C#

                    //eigen decomposition 
                    Evd<double> eigen = C.Evd();
                    B = eigen.EigenVectors;
                    Vector<System.Numerics.Complex> vectorEigenValues = eigen.EigenValues;
                    for (int i = 0; i < vectorEigenValues.Count; i++)
                    {
                        D[i, 0] = vectorEigenValues[i].Real;
                    }
                    //take sqrt of D
                    for (int i = 0; i < vectorEigenValues.Count; i++)
                    {
                        D[i, 0] = Math.Sqrt(D[i, 0]);
                    }

                    for (int i = 0; i < n; i++)
                    {
                        oneOverD[i, 0] = 1.0 / D[i, 0];
                    }
                    Matrix<double> middleTerm = Diagonalize1DMatrix(oneOverD); //#Built in Numpy function doesn't create the right size matrix in this case (ex: Numpy gives 1x1 but should be 5x5)
                    invsqrtC = B * middleTerm * B.Transpose();
                }

                globalBestCandidate = candidateArray[0];
                //Stopping condition
                if (globalBestCandidate.GetObjectiveFunctionValue() > stopFitness)
                {
                    return globalBestCandidate;
                }
                Console.Out.WriteLine("Iteration #" + counteval.ToString());
                Console.Out.WriteLine("Current Value=" + (candidateArray[candidateArray.Count - 1].GetObjectiveFunctionValue()).ToString());
            }//end while loop
            return globalBestCandidate; //just in case everything terminates 
        }

        //standard CMA-ES with periodic saving 
        public static CMAESCandidate ComputeCMAESRecoverable(int dimensionNumber, PUFObjectiveFunction pFunction, sbyte[][] trainingData, sbyte[] targets, double[] initialWeightVector, Random randomGenerator, int coreNumberForSaving)
        {
            int n = dimensionNumber; //number of weights + epsilon 
            Matrix<double> xMean = Matrix<double>.Build.Dense(n, 1);
            CMAESCandidate c11 = new CMAESCandidate(initialWeightVector, trainingData, targets, pFunction);
            Console.Out.WriteLine("Starting Point Accuracy");
            Console.Out.WriteLine(c11.GetObjectiveFunctionValue().ToString());

            CMAESCandidate globalBestCandidate = null;

            double sigma = 0.5;
            //double stopfitness = 1e-10;
            double stopFitness = 0.98;
            int stopeval = AppConstants.MaxIterationNumberCMAES;
            //double stopeval = AppConstants.MaxEvaluations
            //Strategy parameter setting: Selection  
            int lambdaVal = (int)(4.0 + Math.Floor(3.0 * Math.Log(n)));  //population size, note lambda keyword reserved by python so lambda->lambdaVal
            //lambdaVal = AppConstants.PopulationSizeCMAES #change by KRM cause I think we need more sampling
            double mu = lambdaVal / 2.0;
            Matrix<double> weights = Matrix<double>.Build.Dense((int)mu, 1);  //weights = numpy.matrix(weightsPrime, dtype = float).reshape(mu, 1)
            for (int i = 0; i < (int)mu; i++)
            {
                weights[i, 0] = Math.Log(mu + 0.5) - Math.Log(i + 1); //weights[i, 0] = math.log(mu + 0.5) - math.log((i + 1))#use i+1 instead of i in this case to match matlab indexing
            }
            mu = Math.Floor(mu);
            double sumWeights = 0.0;
            for (int i = 0; i < weights.RowCount; i++)
            {
                sumWeights = sumWeights + weights[i, 0];

            }
            //Divide by the sum
            for (int i = 0; i < weights.RowCount; i++)
            {
                weights[i, 0] = weights[i, 0] / sumWeights;
            }
            //Computation for the mueff variable
            double mueffNum = 0.0;
            double mueffDem = 0.0;
            for (int i = 0; i < weights.RowCount; i++)
            {
                mueffNum = weights[i, 0] + mueffNum;
                mueffDem = weights[i, 0] * weights[i, 0] + mueffDem;
            }
            mueffNum = mueffNum * mueffNum;
            double mueff = mueffNum / mueffDem;

            // Strategy parameter setting: Adaptation
            double cc = (4.0 + mueff / n) / (n + 4.0 + 2.0 * mueff / n); //#time constant for cumulation for C
            double cs = (mueff + 2.0) / (n + mueff + 5.0);  //#t-const for cumulation for sigma control
            double c1 = 2.0 / ((n + 1.3) * (n + 1.3) + mueff);    //#learning rate for rank-one update of C
            double cmu = Math.Min(1.0 - c1, 2.0 * (mueff - 2.0 + 1.0 / mueff) / ((n + 2) * (n + 2) + mueff)); //# and for rank-mu update
            double damps = 1.0 + 2.0 * Math.Max(0, Math.Sqrt((mueff - 1) / (n + 1)) - 1) + cs; //# damping for sigma 

            //Initialize dynamic (internal) strategy parameters and constants
            //evolution paths for C and sigma
            Matrix<double> pc = Matrix<double>.Build.Dense(n, 1);
            Matrix<double> ps = Matrix<double>.Build.Dense(n, 1);
            Matrix<double> D = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                pc[i, 0] = 0;
                ps[i, 0] = 0;
                D[i, 0] = 1.0;
            }
            //Create B Matrix
            Matrix<double> B = Matrix<double>.Build.Dense(n, n);
            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    if (i == j)
                    {
                        B[i, j] = 1.0;
                    }
                    else
                    {
                        B[i, j] = 0.0;
                    }
                }
            }
            //Create C Matrix
            Matrix<double> dSquare = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                dSquare[i, 0] = D[i, 0] * D[i, 0];
            }
            Matrix<double> C = B * Diagonalize1DMatrix(dSquare) * B.Transpose(); //C = B * self.diag(DSquare) * numpy.transpose(B)
            //Create invertsqrtC Matrix
            Matrix<double> oneOverD = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                oneOverD[i, 0] = 1.0 / D[i, 0];
            }
            Matrix<double> invsqrtC = B * Diagonalize1DMatrix(oneOverD) * B.Transpose();
            double eigeneval = 0; //track update of B and D
            double chiN = Math.Pow(n, 0.5) * (1.0 - 1.0 / (4.0 * n) + 1.0 / (21.0 * Math.Pow(n, 2.0)));
            int counteval = 0;

            //the next 40 lines contain the 20 lines of interesting code 
            //CMAESCandidate[] candidateArray = new CMAESCandidate[lambdaVal];
            List<CMAESCandidate> candidateArray = new List<CMAESCandidate>();
            for (int i = 0; i < lambdaVal; i++)
            {
                candidateArray.Add(new CMAESCandidate());
            }

            while (counteval < stopeval)
            {
                Matrix<double> arx = Matrix<double>.Build.Dense(n, lambdaVal);

                //fill in the initial solutions 
                for (int i = 0; i < lambdaVal; i++)
                {
                    Matrix<double> randD = Matrix<double>.Build.Dense(n, 1);
                    for (int j = 0; j < n; j++)
                    {
                        randD[j, 0] = D[j, 0] * GenerateRandomNormalVariableForCMAES(randomGenerator, 0, 1.0);
                    }
                    Matrix<double> inputVector = xMean + sigma * B * randD;
                    double[] tempWeightVector = new double[inputVector.RowCount];
                    for (int k = 0; k < inputVector.RowCount; k++)
                    {
                        tempWeightVector[k] = inputVector[k, 0];
                    }
                    candidateArray[i] = new CMAESCandidate(tempWeightVector, trainingData, targets, pFunction);
                    counteval = counteval + 1;
                }
                candidateArray.Sort(); //This maybe problematic, not sure about sorting in C#
                candidateArray.Reverse();
                Matrix<double> xOld = xMean.Clone();
                //Get the new mean value 
                Matrix<double> arxSubset = Matrix<double>.Build.Dense(n, (int)mu); //in Maltab this variable would be "arx(:,arindex(1:mu))

                //This replaces line  arxSubset[:, i] = CandidateList[i].InputVector
                for (int i = 0; i < mu; i++)
                {
                    for (int j = 0; j < n; j++)
                    {
                        arxSubset[j, i] = candidateArray[i].GetWeightVector()[j];
                    }
                }
                xMean = arxSubset * weights; //Line 76 Matlab
                //Cumulation: Update evolution paths
                ps = (1 - cs) * ps + Math.Sqrt(cs * (2.0 - cs) * mueff) * invsqrtC * (xMean - xOld) / sigma;
                //Compute ps.^2 equivalent
                double psSquare = 0;
                for (int i = 0; i < ps.RowCount; i++)
                {
                    psSquare = psSquare + ps[i, 0] * ps[i, 0];
                }

                //Compute hsig 
                double hSig = 0.0;
                double term1ForHsig = psSquare / (1.0 - Math.Pow(1.0 - cs, 2.0 * counteval / lambdaVal)) / n;
                double term2ForHsig = 2.0 + 4.0 / (n + 1.0);
                if (term1ForHsig < term2ForHsig)
                {
                    hSig = 1.0;
                }
                //Compute pc, Line 82 Matlab
                pc = (1.0 - cc) * pc + hSig * Math.Sqrt(cc * (2.0 - cc) * mueff) * (xMean - xOld) / sigma;
                //Adapt covariance matrix C
                Matrix<double> repmatMatrix = Tile((int)mu, xOld); //NOT SURE IF THIS IS RIGHT IN C# FIX repmatMatrix = numpy.tile(xold, mu)
                Matrix<double> artmp = (1.0 / sigma) * (arxSubset - repmatMatrix);
                // C = (1-c1-cmu) * C  + c1 * (pc * pc' + (1-hsig) * cc*(2-cc) * C) + cmu * artmp * diag(weights) * artmp' #This is the original Matlab line for reference
                C = (1.0 - c1 - cmu) * C + c1 * (pc * pc.Transpose() + (1 - hSig) * cc * (2.0 - cc) * C) + cmu * artmp * Diagonalize1DMatrix(weights) * artmp.Transpose();
                //Adapt step size sigma
                //sigma = sigma * Math.Exp((cs / damps) * (numpy.linalg.norm(ps) / chiN - 1))
                sigma = sigma * Math.Exp((cs / damps) * (ps.L2Norm() / chiN - 1)); //NOT SURE IF THIS IS RIGHT FIX IN C#
                //Update B and D from C
                if ((counteval - eigeneval) > (lambdaVal / (c1 + cmu) / n / 10.0))
                {
                    eigeneval = counteval;
                    //C = numpy.triu(C) + numpy.transpose(numpy.triu(C, 1)) #enforce symmetry
                    C = C.UpperTriangle() + C.StrictlyUpperTriangle().Transpose(); //NOT SURE IF THIS IS RIGHT FIX IN C#

                    //eigen decomposition 
                    Evd<double> eigen = C.Evd();
                    B = eigen.EigenVectors;
                    Vector<System.Numerics.Complex> vectorEigenValues = eigen.EigenValues;
                    for (int i = 0; i < vectorEigenValues.Count; i++)
                    {
                        D[i, 0] = vectorEigenValues[i].Real;
                    }
                    //take sqrt of D
                    for (int i = 0; i < vectorEigenValues.Count; i++)
                    {
                        D[i, 0] = Math.Sqrt(D[i, 0]);
                    }

                    for (int i = 0; i < n; i++)
                    {
                        oneOverD[i, 0] = 1.0 / D[i, 0];
                    }
                    Matrix<double> middleTerm = Diagonalize1DMatrix(oneOverD); //#Built in Numpy function doesn't create the right size matrix in this case (ex: Numpy gives 1x1 but should be 5x5)
                    invsqrtC = B * middleTerm * B.Transpose();
                }

                globalBestCandidate = candidateArray[0];
                //Stopping condition
                if (globalBestCandidate.GetObjectiveFunctionValue() > stopFitness)
                {
                    return globalBestCandidate;
                }

                //Time to save the state
                VariantData varData = new VariantData(coreNumberForSaving, counteval, dimensionNumber, lambdaVal, xMean, D, B, sigma, weights, ps, cs, mueff, cc, invsqrtC, C, mu, pc, c1, cmu, damps, chiN, eigeneval, globalBestCandidate);
                string fname = AppConstants.SaveDir + counteval.ToString() + "VariantData" + coreNumberForSaving.ToString();
                FileInfo fi = new FileInfo(fname);
                Stream str = fi.Open(FileMode.OpenOrCreate, FileAccess.Write);
                BinaryFormatter bf = new BinaryFormatter();
                bf.Serialize(str, varData);
                str.Close();

                Console.Out.WriteLine("Iteration #" + counteval.ToString());
                Console.Out.WriteLine("Current Value=" + (candidateArray[candidateArray.Count - 1].GetObjectiveFunctionValue()).ToString());

            }//end while loop
            return globalBestCandidate; //just in case everything terminates 
        }

        //Run the CMA-ES from a recovered file 
        public static CMAESCandidate RecoveredCMAES(Random randomGenerator, int coreNumberForSaving, PUFObjectiveFunction pFunction, InvariantData invData, VariantData varData)
        {
            double stopFitness = 0.98;
            //non-specific variables (used by each core)
            int stopeval = invData.GetMaxEval();
            sbyte[][] trainingData = invData.GetTrainingData();
            sbyte[] targets = invData.GetTrainingResponseForPUF(coreNumberForSaving);

            //core specific variables (specific to each run of CMA-ES)
            int counteval = varData.GetCurrentEval();
            int n = varData.GetDimensionNum();
            int lambdaVal = varData.GetLambda();
            Matrix<double> xMean = varData.GetXMean();
            Matrix<double> D = varData.GetD();
            Matrix<double> B = varData.GetB();
            double sigma = varData.GetSigma();
            Matrix<double> weights = varData.GetWeights();
            Matrix<double> ps = varData.GetPS();
            double cs = varData.GetCS();
            double mueff = varData.GetMueff();
            double cc = varData.GetCC();
            Matrix<double> pc = varData.GetPC();
            Matrix<double> invsqrtC = varData.GetInvSqrtC();
            Matrix<double> C = varData.GetMatrixC();
            double mu = varData.GetMu();
            double c1 = varData.GetC1();
            double cmu = varData.GetCmu();
            double damps = varData.GetDamps();
            double chiN = varData.GetChiN();
            double eigeneval = varData.GetEigenVal();
            CMAESCandidate globalBestCandidate = varData.GetGlobalBest();

            Matrix<double> oneOverD = Matrix<double>.Build.Dense(n, 1); //Don't need to copy this because we get it from D

            //just a sanity check 
            if (varData.coreNumber != coreNumberForSaving)
            {
                throw new Exception("The saved core number and current core number don't match.");
            }

            //the next 40 lines contain the 20 lines of interesting code 
            //CMAESCandidate[] candidateArray = new CMAESCandidate[lambdaVal];
            List<CMAESCandidate> candidateArray = new List<CMAESCandidate>();
            for (int i = 0; i < lambdaVal; i++)
            {
                candidateArray.Add(new CMAESCandidate());
            }

            while (counteval < stopeval)
            {
                Matrix<double> arx = Matrix<double>.Build.Dense(n, lambdaVal);

                //fill in the initial solutions 
                for (int i = 0; i < lambdaVal; i++)
                {
                    Matrix<double> randD = Matrix<double>.Build.Dense(n, 1);
                    for (int j = 0; j < n; j++)
                    {
                        randD[j, 0] = D[j, 0] * GenerateRandomNormalVariableForCMAES(randomGenerator, 0, 1.0);
                    }
                    Matrix<double> inputVector = xMean + sigma * B * randD;
                    double[] tempWeightVector = new double[inputVector.RowCount];
                    for (int k = 0; k < inputVector.RowCount; k++)
                    {
                        tempWeightVector[k] = inputVector[k, 0];
                    }
                    candidateArray[i] = new CMAESCandidate(tempWeightVector, trainingData, targets, pFunction);
                    counteval = counteval + 1;
                }
                candidateArray.Sort(); //This maybe problematic, not sure about sorting in C#
                candidateArray.Reverse();
                Matrix<double> xOld = xMean.Clone();
                //Get the new mean value 
                Matrix<double> arxSubset = Matrix<double>.Build.Dense(n, (int)mu); //in Maltab this variable would be "arx(:,arindex(1:mu))

                //This replaces line  arxSubset[:, i] = CandidateList[i].InputVector
                for (int i = 0; i < mu; i++)
                {
                    for (int j = 0; j < n; j++)
                    {
                        arxSubset[j, i] = candidateArray[i].GetWeightVector()[j];
                    }
                }
                xMean = arxSubset * weights; //Line 76 Matlab
                //Cumulation: Update evolution paths
                ps = (1 - cs) * ps + Math.Sqrt(cs * (2.0 - cs) * mueff) * invsqrtC * (xMean - xOld) / sigma;
                //Compute ps.^2 equivalent
                double psSquare = 0;
                for (int i = 0; i < ps.RowCount; i++)
                {
                    psSquare = psSquare + ps[i, 0] * ps[i, 0];
                }

                //Compute hsig 
                double hSig = 0.0;
                double term1ForHsig = psSquare / (1.0 - Math.Pow(1.0 - cs, 2.0 * counteval / lambdaVal)) / n;
                double term2ForHsig = 2.0 + 4.0 / (n + 1.0);
                if (term1ForHsig < term2ForHsig)
                {
                    hSig = 1.0;
                }
                //Compute pc, Line 82 Matlab
                pc = (1.0 - cc) * pc + hSig * Math.Sqrt(cc * (2.0 - cc) * mueff) * (xMean - xOld) / sigma;
                //Adapt covariance matrix C
                Matrix<double> repmatMatrix = Tile((int)mu, xOld); //NOT SURE IF THIS IS RIGHT IN C# FIX repmatMatrix = numpy.tile(xold, mu)
                Matrix<double> artmp = (1.0 / sigma) * (arxSubset - repmatMatrix);
                // C = (1-c1-cmu) * C  + c1 * (pc * pc' + (1-hsig) * cc*(2-cc) * C) + cmu * artmp * diag(weights) * artmp' #This is the original Matlab line for reference
                C = (1.0 - c1 - cmu) * C + c1 * (pc * pc.Transpose() + (1 - hSig) * cc * (2.0 - cc) * C) + cmu * artmp * Diagonalize1DMatrix(weights) * artmp.Transpose();
                //Adapt step size sigma
                //sigma = sigma * Math.Exp((cs / damps) * (numpy.linalg.norm(ps) / chiN - 1))
                sigma = sigma * Math.Exp((cs / damps) * (ps.L2Norm() / chiN - 1)); //NOT SURE IF THIS IS RIGHT FIX IN C#
                //Update B and D from C
                if ((counteval - eigeneval) > (lambdaVal / (c1 + cmu) / n / 10.0))
                {
                    eigeneval = counteval;
                    //C = numpy.triu(C) + numpy.transpose(numpy.triu(C, 1)) #enforce symmetry
                    C = C.UpperTriangle() + C.StrictlyUpperTriangle().Transpose(); //NOT SURE IF THIS IS RIGHT FIX IN C#

                    //eigen decomposition 
                    Evd<double> eigen = C.Evd();
                    B = eigen.EigenVectors;
                    Vector<System.Numerics.Complex> vectorEigenValues = eigen.EigenValues;
                    for (int i = 0; i < vectorEigenValues.Count; i++)
                    {
                        D[i, 0] = vectorEigenValues[i].Real;
                    }
                    //take sqrt of D
                    for (int i = 0; i < vectorEigenValues.Count; i++)
                    {
                        D[i, 0] = Math.Sqrt(D[i, 0]);
                    }

                    for (int i = 0; i < n; i++)
                    {
                        oneOverD[i, 0] = 1.0 / D[i, 0];
                    }
                    Matrix<double> middleTerm = Diagonalize1DMatrix(oneOverD); //#Built in Numpy function doesn't create the right size matrix in this case (ex: Numpy gives 1x1 but should be 5x5)
                    invsqrtC = B * middleTerm * B.Transpose();
                }

                globalBestCandidate = candidateArray[0];
                //Stopping condition
                if (globalBestCandidate.GetObjectiveFunctionValue() > stopFitness)
                {
                    return globalBestCandidate;
                }

                //Time to save the state
                VariantData varDataUpdated = new VariantData(coreNumberForSaving, counteval, n, lambdaVal, xMean, D, B, sigma, weights, ps, cs, mueff, cc, invsqrtC, C, mu, pc, c1, cmu, damps, chiN, eigeneval, globalBestCandidate);
                string fname = AppConstants.SaveDir + counteval.ToString() + "VariantData" + coreNumberForSaving.ToString();
                FileInfo fi = new FileInfo(fname);
                Stream str = fi.Open(FileMode.OpenOrCreate, FileAccess.Write);
                BinaryFormatter bf = new BinaryFormatter();
                bf.Serialize(str, varDataUpdated);
                str.Close();

                Console.Out.WriteLine("Iteration #" + counteval.ToString());
                Console.Out.WriteLine("Current Value=" + (candidateArray[candidateArray.Count - 1].GetObjectiveFunctionValue()).ToString());

            }//end while loop
            return globalBestCandidate; //just in case everything terminates 
        }

        //standard CMA-ES with maximum parallelization

        public static CMAESCandidate ComputeCMAESBecker(int dimensionNumber, PUFObjectiveFunction pFunction, sbyte[][] trainingData, sbyte[] targets, double[] initialWeightVector, Random randomGenerator)
        {
            int n = dimensionNumber + 1; //number of weights + epsilon 
            Matrix<double> xMean = Matrix<double>.Build.Dense(n, 1);
            CMAESCandidate c11 = new CMAESCandidate(initialWeightVector, trainingData, targets, pFunction);
            Console.Out.WriteLine("Starting Point Accuracy");
            Console.Out.WriteLine(c11.GetObjectiveFunctionValue().ToString());

            CMAESCandidate globalBestCandidate = null;

            double sigma = 0.5;
            //double stopfitness = 1e-10;
            //double stopfitness = 0.99;
            double stopfitness = double.MaxValue;
            int stopeval = AppConstants.MaxIterationNumberCMAES;
            //double stopeval = AppConstants.MaxEvaluations
            //Strategy parameter setting: Selection  
            int lambdaVal = (int)(4.0 + Math.Floor(3.0 * Math.Log(n)));  //population size, note lambda keyword reserved by python so lambda->lambdaVal
            //lambdaVal = AppConstants.PopulationSizeCMAES #change by KRM cause I think we need more sampling
            double mu = lambdaVal / 2.0;
            Matrix<double> weights = Matrix<double>.Build.Dense((int)mu, 1);  //weights = numpy.matrix(weightsPrime, dtype = float).reshape(mu, 1)
            for (int i = 0; i < (int)mu; i++)
            {
                weights[i, 0] = Math.Log(mu + 0.5) - Math.Log(i + 1); //weights[i, 0] = math.log(mu + 0.5) - math.log((i + 1))#use i+1 instead of i in this case to match matlab indexing
            }
            mu = Math.Floor(mu);
            double sumWeights = 0.0;
            for (int i = 0; i < weights.RowCount; i++)
            {
                sumWeights = sumWeights + weights[i, 0];

            }
            //Divide by the sum
            for (int i = 0; i < weights.RowCount; i++)
            {
                weights[i, 0] = weights[i, 0] / sumWeights;
            }
            //Computation for the mueff variable
            double mueffNum = 0.0;
            double mueffDem = 0.0;
            for (int i = 0; i < weights.RowCount; i++)
            {
                mueffNum = weights[i, 0] + mueffNum;
                mueffDem = weights[i, 0] * weights[i, 0] + mueffDem;
            }
            mueffNum = mueffNum * mueffNum;
            double mueff = mueffNum / mueffDem;

            // Strategy parameter setting: Adaptation
            double cc = (4.0 + mueff / n) / (n + 4.0 + 2.0 * mueff / n); //#time constant for cumulation for C
            double cs = (mueff + 2.0) / (n + mueff + 5.0);  //#t-const for cumulation for sigma control
            double c1 = 2.0 / ((n + 1.3) * (n + 1.3) + mueff);    //#learning rate for rank-one update of C
            double cmu = Math.Min(1.0 - c1, 2.0 * (mueff - 2.0 + 1.0 / mueff) / ((n + 2) * (n + 2) + mueff)); //# and for rank-mu update
            double damps = 1.0 + 2.0 * Math.Max(0, Math.Sqrt((mueff - 1) / (n + 1)) - 1) + cs; //# damping for sigma 

            //Initialize dynamic (internal) strategy parameters and constants
            //evolution paths for C and sigma
            Matrix<double> pc = Matrix<double>.Build.Dense(n, 1);
            Matrix<double> ps = Matrix<double>.Build.Dense(n, 1);
            Matrix<double> D = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                pc[i, 0] = 0;
                ps[i, 0] = 0;
                D[i, 0] = 1.0;
            }
            //Create B Matrix
            Matrix<double> B = Matrix<double>.Build.Dense(n, n);
            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    if (i == j)
                    {
                        B[i, j] = 1.0;
                    }
                    else
                    {
                        B[i, j] = 0.0;
                    }
                }
            }
            //Create C Matrix
            Matrix<double> dSquare = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                dSquare[i, 0] = D[i, 0] * D[i, 0];
            }
            Matrix<double> C = B * Diagonalize1DMatrix(dSquare) * B.Transpose(); //C = B * self.diag(DSquare) * numpy.transpose(B)
            //Create invertsqrtC Matrix
            Matrix<double> oneOverD = Matrix<double>.Build.Dense(n, 1);
            for (int i = 0; i < n; i++)
            {
                oneOverD[i, 0] = 1.0 / D[i, 0];
            }
            Matrix<double> invsqrtC = B * Diagonalize1DMatrix(oneOverD) * B.Transpose();
            double eigeneval = 0; //track update of B and D
            double chiN = Math.Pow(n, 0.5) * (1.0 - 1.0 / (4.0 * n) + 1.0 / (21.0 * Math.Pow(n, 2.0)));
            int counteval = 0;

            //the next 40 lines contain the 20 lines of interesting code 
            //CMAESCandidate[] candidateArray = new CMAESCandidate[lambdaVal];
            List<CMAESCandidate> candidateArray = new List<CMAESCandidate>();
            for (int i = 0; i < lambdaVal; i++)
            {
                candidateArray.Add(new CMAESCandidate());
            }

            while (counteval < stopeval)
            {
                Matrix<double> arx = Matrix<double>.Build.Dense(n, lambdaVal);

                //fill in the initial solutions 
                for (int i = 0; i < lambdaVal; i++)
                {
                    Matrix<double> randD = Matrix<double>.Build.Dense(n, 1);
                    for (int j = 0; j < n; j++)
                    {
                        randD[j, 0] = D[j, 0] * GenerateRandomNormalVariableForCMAES(randomGenerator, 0, 1.0);
                    }
                    Matrix<double> inputVector = xMean + sigma * B * randD;
                    double[] tempWeightVector = new double[inputVector.RowCount];
                    for (int k = 0; k < inputVector.RowCount; k++)
                    {
                        tempWeightVector[k] = inputVector[k, 0];
                    }
                    candidateArray[i] = new CMAESCandidate(tempWeightVector, trainingData, targets, pFunction);
                    counteval = counteval + 1;
                }
                candidateArray.Sort(); //This maybe problematic, not sure about sorting in C#
                candidateArray.Reverse();
                Matrix<double> xOld = xMean.Clone();
                //Get the new mean value 
                Matrix<double> arxSubset = Matrix<double>.Build.Dense(n, (int)mu); //in Maltab this variable would be "arx(:,arindex(1:mu))

                //This replaces line  arxSubset[:, i] = CandidateList[i].InputVector
                for (int i = 0; i < mu; i++)
                {
                    for (int j = 0; j < n; j++)
                    {
                        arxSubset[j, i] = candidateArray[i].GetWeightVector()[j];
                    }
                }
                xMean = arxSubset * weights; //Line 76 Matlab
                //Cumulation: Update evolution paths
                ps = (1 - cs) * ps + Math.Sqrt(cs * (2.0 - cs) * mueff) * invsqrtC * (xMean - xOld) / sigma;
                //Compute ps.^2 equivalent
                double psSquare = 0;
                for (int i = 0; i < ps.RowCount; i++)
                {
                    psSquare = psSquare + ps[i, 0] * ps[i, 0];
                }

                //Compute hsig 
                double hSig = 0.0;
                double term1ForHsig = psSquare / (1.0 - Math.Pow(1.0 - cs, 2.0 * counteval / lambdaVal)) / n;
                double term2ForHsig = 2.0 + 4.0 / (n + 1.0);
                if (term1ForHsig < term2ForHsig)
                {
                    hSig = 1.0;
                }
                //Compute pc, Line 82 Matlab
                pc = (1.0 - cc) * pc + hSig * Math.Sqrt(cc * (2.0 - cc) * mueff) * (xMean - xOld) / sigma;
                //Adapt covariance matrix C
                Matrix<double> repmatMatrix = Tile((int)mu, xOld); //NOT SURE IF THIS IS RIGHT IN C# FIX repmatMatrix = numpy.tile(xold, mu)
                Matrix<double> artmp = (1.0 / sigma) * (arxSubset - repmatMatrix);
                // C = (1-c1-cmu) * C  + c1 * (pc * pc' + (1-hsig) * cc*(2-cc) * C) + cmu * artmp * diag(weights) * artmp' #This is the original Matlab line for reference
                C = (1.0 - c1 - cmu) * C + c1 * (pc * pc.Transpose() + (1 - hSig) * cc * (2.0 - cc) * C) + cmu * artmp * Diagonalize1DMatrix(weights) * artmp.Transpose();
                //Adapt step size sigma
                //sigma = sigma * Math.Exp((cs / damps) * (numpy.linalg.norm(ps) / chiN - 1))
                sigma = sigma * Math.Exp((cs / damps) * (ps.L2Norm() / chiN - 1)); //NOT SURE IF THIS IS RIGHT FIX IN C#
                //Update B and D from C
                if ((counteval - eigeneval) > (lambdaVal / (c1 + cmu) / n / 10.0))
                {
                    eigeneval = counteval;
                    //C = numpy.triu(C) + numpy.transpose(numpy.triu(C, 1)) #enforce symmetry
                    C = C.UpperTriangle() + C.StrictlyUpperTriangle().Transpose(); //NOT SURE IF THIS IS RIGHT FIX IN C#

                    //eigen decomposition 
                    Evd<double> eigen = C.Evd();
                    B = eigen.EigenVectors;
                    Vector<System.Numerics.Complex> vectorEigenValues = eigen.EigenValues;
                    for (int i = 0; i < vectorEigenValues.Count; i++)
                    {
                        D[i, 0] = vectorEigenValues[i].Real;
                    }
                    //take sqrt of D
                    for (int i = 0; i < vectorEigenValues.Count; i++)
                    {
                        D[i, 0] = Math.Sqrt(D[i, 0]);
                    }

                    for (int i = 0; i < n; i++)
                    {
                        oneOverD[i, 0] = 1.0 / D[i, 0];
                    }
                    Matrix<double> middleTerm = Diagonalize1DMatrix(oneOverD); //#Built in Numpy function doesn't create the right size matrix in this case (ex: Numpy gives 1x1 but should be 5x5)
                    invsqrtC = B * middleTerm * B.Transpose();
                }

                globalBestCandidate = candidateArray[0];
                //Termination Conditions 
                //bestCandidate = candidateArray[0]; //Array index 0 has the smallest objective function value 
                //if (bestCandidate.GetObjectiveFunctionValue() < currentBestValue)
                //{
                //    currentBestValue = bestCandidate.GetObjectiveFunctionValue();
                //    globalBestCandidate = (CMAESCandidate)bestCandidate.Clone();
                //}
                //if (bestCandidate.GetObjectiveFunctionValue() >= stopfitness)
                //{
                //    return globalBestCandidate;
                //}

                //Add in extra termination conditions 
                //if (bestCandidate.GetObjectiveFunctionValue() == currentBestValue)
                //{
                //    repeatCount = repeatCount + 1;

                //}
                //else
                //{
                //    repeatCount = 0;
                //}
                ////we have repeated too many times 
                //if (repeatCount > 10)
                //{
                //    Console.Out.WriteLine("CMA-ES terminated to due to repeated best.");
                //    return globalBestCandidate;
                //}
                Console.Out.WriteLine("Iteration #" + counteval.ToString());
                //Console.Out.WriteLine("Best Value=" + (1.0 - currentBestValue).ToString());
                Console.Out.WriteLine("Current Value=" + (candidateArray[candidateArray.Count - 1].GetObjectiveFunctionValue()).ToString());

            }//end while loop
            return globalBestCandidate; //just in case everything terminates 
        }
    }
}
