using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    class AppConstants
    {
        public static readonly int MaxIterationNumberCMAES = 700; //Number of iterations each CMA-ES attack is allowed to run for 
        public static readonly int CoreNumber = 25; //Number of CPU cores for parallelization 
        public static int TrainingSize = 12000; //size of training data for CMA-ES
        public static int TestingSize = 1000; //size of testing data
        public static string SaveDir = @"C:\Users\kaleel\Desktop\backup\";
        public static Boolean UseParallelismOnSingleCMAES = false; //Only used if want to do ONE run of CMA-ES classical with maximum parallelism
    }
}
