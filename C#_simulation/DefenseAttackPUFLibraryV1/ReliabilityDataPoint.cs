using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    class ReliabilityDataPoint
    {
        private Boolean IsNoisyChallenge = false;
        private List<ArbiterPUF> NoisyAPUFList = new List<ArbiterPUF>(); //contains all the noisy arbiter PUFs that made the challenge
        private double[] Phi;
        private double ReliabilityMeasure;

        //standard constructor 
        public ReliabilityDataPoint(double[] phiIN, double reliabilityIN, Boolean isNoisyIN)
        {
            ReliabilityMeasure = reliabilityIN;
            IsNoisyChallenge = isNoisyIN;
            Phi = (double[])phiIN.Clone();
        }

        public ReliabilityDataPoint(double[] phiIN, double reliabilityIN, Boolean isNoisyIN, List<ArbiterPUF> aPUFListIN)
        {
            ReliabilityMeasure = reliabilityIN;
            NoisyAPUFList = aPUFListIN;
            IsNoisyChallenge = isNoisyIN;
            Phi = (double[])phiIN.Clone();
        }

        //Add a noisy APUF to the contributing list 
        public void AddNoisyAPUF(ArbiterPUF aPUFIN)
        {
            NoisyAPUFList.Add(aPUFIN);
        }

        public Boolean IsNoisy()
        {
            return IsNoisyChallenge;
        }

        public double[] GetPhi()
        {
            return Phi;
        }

        public Boolean ContainsAPUF(ArbiterPUF aPUFModel)
        {
            Boolean containsPUFInstance = false;
            if (NoisyAPUFList.Contains(aPUFModel) == true)
            {
                containsPUFInstance = true;
            }
            return containsPUFInstance;
        }

        public double GetReliability()
        {
            return ReliabilityMeasure;
        }

        public void SetReliability(double updatedReliability)
        {
            ReliabilityMeasure = updatedReliability;
        }
    }
}
