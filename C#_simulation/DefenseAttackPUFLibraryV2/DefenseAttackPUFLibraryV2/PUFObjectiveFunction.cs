using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DefenseAttackPUFLibraryV2
{
    [Serializable]
    abstract class PUFObjectiveFunction
    {
        abstract public double ObjFunValue(double[] features, sbyte[][] inputs, sbyte[] targets); //give the value based on features
    }
}
