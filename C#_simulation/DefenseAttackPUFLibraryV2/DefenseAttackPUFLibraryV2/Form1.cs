using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DefenseAttackPUFLibraryV2
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        //Generate the PUF training data for Keras 
        private void kerasGenBtn_Click(object sender, EventArgs e)
        {
            int bitNumber = 32;
            int xorNumber = 2;
            AttackTest.ClassicalAttackXORAPUFSingle(bitNumber, xorNumber);
        }

        //This attacks a single XOR APUF with parallelization done on a single run 
        //Note we DO NOT have recovery for this type of attack
        private void xorAttackBtn_Click(object sender, EventArgs e)
        {
            string mainDirectory = "C:\\Users\\Windows\\Desktop\\Kaleel\\PUF Work\\Data64-4XOR";

            string trainDir = mainDirectory + "\\Training";
            string testDir = mainDirectory + "\\Testing";
            int bitNumber = 64;
            int NumPUFX = 3;
            int NumPUFY = 3;
            int numXORs = 4;
            double MeanForAPUF = 0.0;
            double VarianceForAPUF = 1.0;

            //IPUF iPUF = new IPUF(NumPUFX, NumPUFY, bitNumber, MeanForAPUF, VarianceForAPUF);
            XORArbiterPUF xPUF = new XORArbiterPUF(numXORs, bitNumber, MeanForAPUF, VarianceForAPUF);
            DataGeneration.GenerateIPUFDataForKeras(xPUF, AppConstants.TrainingSize, trainDir);
            DataGeneration.GenerateIPUFDataForKeras(xPUF, AppConstants.TestingSize, testDir);
            MessageBox.Show("Data has been generated and saved successfully.");
        }
    }
}
