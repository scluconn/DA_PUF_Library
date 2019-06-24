using MathNet.Numerics.LinearAlgebra;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    //this class contains the variable for CMA-ES running on each core 
    [Serializable]
    class VariantData
    {
        public int coreNumber; //the most important variable 
        private int currentEval;
        private int dimensionNumber;
        private int lambdaVal;
        private Matrix<double> xMean;
        private Matrix<double> dMatrix;
        private Matrix<double> bMatrix;
        private double sigma;
        private Matrix<double> weights;
        private double cs, mueff, cc;
        Matrix<double> ps;
        Matrix<double> pc;
        private Matrix<double> invSqrtC;
        private Matrix<double> C;
        private double mu;
        private double c1, cmu, damps, chiN, eigenVal;
        private CMAESCandidate globalBest;

        public VariantData(int coreNumIN, int currentEvalIN, int dimensionNumberIN, int lambdaValIN, Matrix<double> xMeanIN, Matrix<double> dMatrixIN, Matrix<double> bMatrixIN, double sigmaIN, Matrix<double> weightsIN, Matrix<double> psIN, double csIN, double mueffIN, double ccIN, Matrix<double> invSqrtCIN, Matrix<double> matrixCIN, double muIN, Matrix<double> pcIN, double c1IN, double cmuIN, double dampsIN, double chiNIN, double eigenValIN, CMAESCandidate globalBestIN)
        {
            coreNumber = coreNumIN;
            currentEval = currentEvalIN;
            dimensionNumber = dimensionNumberIN;
            lambdaVal = lambdaValIN;
            xMean = xMeanIN;
            dMatrix = dMatrixIN;
            bMatrix = bMatrixIN;
            weights = weightsIN;
            ps = psIN;
            cs = csIN;
            mueff = mueffIN;
            cc = ccIN;
            pc = pcIN;
            invSqrtC = invSqrtCIN;
            C = matrixCIN;
            mu = muIN;
            c1 = c1IN;
            cmu = cmuIN;
            damps = dampsIN;
            chiN = chiNIN;
            eigenVal = eigenValIN;
            globalBest = globalBestIN;
            sigma = sigmaIN;
        }

        public int GetCurrentEval()
        {
            return currentEval;
        }

        public int GetDimensionNum()
        {
            return dimensionNumber;
        }

        public int GetLambda()
        {
            return lambdaVal;
        }

        public Matrix<double> GetXMean()
        {
            return xMean;
        }

        public Matrix<double> GetD()
        {
            return dMatrix;
        }

        public Matrix<double> GetB()
        {
            return bMatrix;
        }

        public double GetSigma()
        {
            return sigma;
        }

        public Matrix<double> GetWeights()
        {
            return weights;
        }

        public Matrix<double> GetPS()
        {
            return ps;
        }

        public double GetCS()
        {
            return cs;
        }

        public double GetMueff()
        {
            return mueff;
        }

        public double GetCC()
        {
            return cc;
        }

        public Matrix<double> GetPC()
        {
            return pc;
        }

        public Matrix<double> GetInvSqrtC()
        {
            return invSqrtC;
        }

        public Matrix<double> GetMatrixC()
        {
            return C;
        }

        public double GetMu()
        {
            return mu;
        }

        public double GetC1()
        {
            return c1;
        }

        public double GetCmu()
        {
            return cmu;
        }

        public double GetDamps()
        {
            return damps;
        }

        public double GetChiN()
        {
            return chiN;
        }

        public double GetEigenVal()
        {
            return eigenVal;
        }

        public CMAESCandidate GetGlobalBest()
        {
            return globalBest;
        }
    }
}
