using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV1
{
    abstract class PUFObjectiveFunction
    {
        abstract public double ObjFunValue(double[] features, double[][] inputs, double[][] targets); //give the value based on features  
    }
}
