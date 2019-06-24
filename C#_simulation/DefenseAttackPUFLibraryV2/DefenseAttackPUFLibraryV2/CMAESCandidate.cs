using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    [Serializable]
    class CMAESCandidate : IComparable
    {
        private double[] WeightVector;
        private sbyte[][] TrainingData;
        private sbyte[] Targets;
        private PUFObjectiveFunction FunctionP; //objective function for the swarm node 
        private double ObjFunctionValue;

        //blank constructor for the list 
        public CMAESCandidate()
        {

        }

        public CMAESCandidate(double[] weightIN, sbyte[][] trainingDataIN, sbyte[] targetsIN, PUFObjectiveFunction functionIN)
        {
            //WeightVector = (double[])weightIN.Clone();
            //TrainingData = (double[][])trainingDataIN.Clone();
            //Targets = (double[][])targetsIN.Clone();
            WeightVector = weightIN;
            TrainingData = trainingDataIN;
            Targets = targetsIN;
            FunctionP = functionIN;
            ObjFunctionValue = FunctionP.ObjFunValue(WeightVector, TrainingData, Targets);
        }

        public double GetObjectiveFunctionValue()
        {
            return ObjFunctionValue;
        }

        public double[] GetWeightVector()
        {
            return WeightVector;
        }

        public int CompareTo(object obj)
        {
            CMAESCandidate other = (CMAESCandidate)obj;
            return this.ObjFunctionValue.CompareTo(other.ObjFunctionValue); //sorts in acsending, array index of 0 with be highest. 
                                                                            // returns 0 if equal, -1 if less, and 1 if greater.
        }
    }
}
