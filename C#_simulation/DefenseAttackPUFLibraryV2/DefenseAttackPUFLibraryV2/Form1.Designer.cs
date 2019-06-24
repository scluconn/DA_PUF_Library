namespace DefenseAttackPUFLibraryV2
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.xorAttackBtn = new System.Windows.Forms.Button();
            this.kerasGenBtn = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // xorAttackBtn
            // 
            this.xorAttackBtn.Location = new System.Drawing.Point(12, 12);
            this.xorAttackBtn.Name = "xorAttackBtn";
            this.xorAttackBtn.Size = new System.Drawing.Size(291, 57);
            this.xorAttackBtn.TabIndex = 0;
            this.xorAttackBtn.Text = "Single XOR Attack";
            this.xorAttackBtn.UseVisualStyleBackColor = true;
            this.xorAttackBtn.Click += new System.EventHandler(this.xorAttackBtn_Click);
            // 
            // kerasGenBtn
            // 
            this.kerasGenBtn.Location = new System.Drawing.Point(12, 96);
            this.kerasGenBtn.Name = "kerasGenBtn";
            this.kerasGenBtn.Size = new System.Drawing.Size(291, 53);
            this.kerasGenBtn.TabIndex = 1;
            this.kerasGenBtn.Text = "Generate Data For Keras";
            this.kerasGenBtn.UseVisualStyleBackColor = true;
            this.kerasGenBtn.Click += new System.EventHandler(this.kerasGenBtn_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(318, 506);
            this.Controls.Add(this.kerasGenBtn);
            this.Controls.Add(this.xorAttackBtn);
            this.Name = "Form1";
            this.Text = "Form1";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button xorAttackBtn;
        private System.Windows.Forms.Button kerasGenBtn;
    }
}

