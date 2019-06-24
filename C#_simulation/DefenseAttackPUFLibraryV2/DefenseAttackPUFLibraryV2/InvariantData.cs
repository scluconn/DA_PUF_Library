using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    [Serializable]
    class InvariantData
    {
        //private sbyte[][] trainingData;
        private sbyte[][] trainingDataAfterSave = null; //this is the reconstructed training data after being saved in list form 
        private sbyte[][] trainingResponse;
        private PhysicallyUncloneableFunction[] aPUF;
        private int maxCMAESIterationNum;
        private int coreNumber;
        private int trainingSize;
        private int testingSize;
        private List<sbyte[][]> trainingData = new List<sbyte[][]>();

        //First constructor created when saving the data 
        public InvariantData(sbyte[][] trainingIN, sbyte[][] trainingResponseIN, PhysicallyUncloneableFunction[] aPUFIN)
        {
            //trainingData = trainingIN;
            trainingResponse = trainingResponseIN;
            aPUF = new PhysicallyUncloneableFunction[aPUFIN.Length];
            for (int a = 0; a < aPUFIN.Length; a++)
            {
                aPUF[a] = aPUFIN[a];
            }
            //rest can be taken from the App constants class
            maxCMAESIterationNum = AppConstants.MaxIterationNumberCMAES;
            coreNumber = AppConstants.CoreNumber;
            trainingSize = AppConstants.TrainingSize;
            testingSize = AppConstants.TestingSize;

            //time to see how saving needs to be done 
            double maxTrainingIndex = trainingIN.Length * trainingIN[0].Length;
            double maxIntIndex = Int32.MaxValue;
            //if (maxTrainingIndex > maxIntIndex) //just try dividing the data by 100, very arbitrary 
            //{
            int tempSize = trainingSize / 100;
            int indexer = 0;
            for (int i = 0; i < 100; i++)
            {
                sbyte[][] tempTrainingData = new sbyte[tempSize][];
                for (int j = 0; j < tempSize; j++)
                {
                    tempTrainingData[j] = trainingIN[indexer];
                    indexer++;
                }
                trainingData.Add(tempTrainingData);
            }
            //}
            //else //in this case array dimensions are within the bounds of Int32 so can seralize normally 
            //{
            //    trainingData.Add(trainingIN);
            //}
        }

        //Constructor when re-loading the data  
        public InvariantData(int maxIt, int coreIN, int trainSizeIN, int testSizeIN, sbyte[][] trainingIN, sbyte[][] trainingResponseIN, PhysicallyUncloneableFunction[] aPUFIN)
        {
            trainingDataAfterSave = trainingIN;
            trainingResponse = trainingResponseIN;
            aPUF = new PhysicallyUncloneableFunction[aPUFIN.Length];
            for (int a = 0; a < aPUFIN.Length; a++)
            {
                aPUF[a] = aPUFIN[a];
            }
            //rest can be taken from the App constants class
            maxCMAESIterationNum = maxIt;
            coreNumber = coreIN;
            trainingSize = trainSizeIN;
            testingSize = testSizeIN;

            //save the training array as a list as well so it can be saved again
            int tempSize = trainingSize / 100;
            int indexer = 0;
            for (int i = 0; i < 100; i++)
            {
                sbyte[][] tempTrainingData = new sbyte[tempSize][];
                for (int j = 0; j < tempSize; j++)
                {
                    tempTrainingData[j] = trainingIN[indexer];
                    indexer++;
                }
                trainingData.Add(tempTrainingData);
            }
        }

        public int GetMaxEval()
        {
            return maxCMAESIterationNum;
        }

        public sbyte[][] GetTrainingData()
        {
            return trainingDataAfterSave;
        }

        public sbyte[] GetTrainingResponseForPUF(int pufIndex)
        {
            return trainingResponse[pufIndex];
        }

        public sbyte[][] GetTrainingResponseAll()
        {
            return trainingResponse;
        }


        public PhysicallyUncloneableFunction GetPUFatIndex(int index)
        {
            return aPUF[index];
        }

        public void Serialize(BinaryFormatter bf, Stream sr)
        {
            bf.Serialize(sr, aPUF);
            bf.Serialize(sr, maxCMAESIterationNum);
            bf.Serialize(sr, coreNumber);
            bf.Serialize(sr, trainingSize);
            bf.Serialize(sr, testingSize);
            bf.Serialize(sr, trainingResponse);
            for (int i = 0; i < trainingData.Count; i++)
            {
                bf.Serialize(sr, trainingData[i]);

            }
        }
    }
}
