namespace SQL_PTO_Report
{
    partial class Reports
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components;

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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Reports));
            this.reportViewer1 = new Microsoft.Reporting.WinForms.ReportViewer();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripSplitButton3 = new System.Windows.Forms.ToolStripSplitButton();
            this.sbDbNames = new System.Windows.Forms.ToolStripSplitButton();
            this.cbDbNames = new System.Windows.Forms.ToolStripComboBox();
            this.toolStripSplitButton1 = new System.Windows.Forms.ToolStripSplitButton();
            this.toolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSplitButton2 = new System.Windows.Forms.ToolStripSplitButton();
            this.tssbLoadData = new System.Windows.Forms.ToolStripSplitButton();
            this.miCollectedData = new System.Windows.Forms.ToolStripMenuItem();
            this.importReportsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.clearDataImportLogToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.viewDataImportLogToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openFolderToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.fixScriptsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.allQueryPlansToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.dMVPlansToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.tsslStatus = new System.Windows.Forms.ToolStripStatusLabel();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.timer2 = new System.Windows.Forms.Timer(this.components);
            this.panel1 = new System.Windows.Forms.Panel();
            this.btnAboutOK = new System.Windows.Forms.Button();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.linkLabel1 = new System.Windows.Forms.LinkLabel();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.statusStrip1.SuspendLayout();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // reportViewer1
            // 
            this.reportViewer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.reportViewer1.DocumentMapWidth = 150;
            this.reportViewer1.Location = new System.Drawing.Point(0, 0);
            this.reportViewer1.Name = "reportViewer1";
            this.reportViewer1.ProcessingMode = Microsoft.Reporting.WinForms.ProcessingMode.Remote;
            this.reportViewer1.ServerReport.ReportPath = "/SQLPTOReports/Dashboard";
            this.reportViewer1.Size = new System.Drawing.Size(1158, 868);
            this.reportViewer1.TabIndex = 0;
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripSplitButton3,
            this.sbDbNames,
            this.toolStripSplitButton1,
            this.toolStripSplitButton2,
            this.tssbLoadData,
            this.tsslStatus});
            this.statusStrip1.Location = new System.Drawing.Point(0, 868);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(1158, 22);
            this.statusStrip1.TabIndex = 3;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripSplitButton3
            // 
            this.toolStripSplitButton3.DropDownButtonWidth = 0;
            this.toolStripSplitButton3.Image = ((System.Drawing.Image)(resources.GetObject("toolStripSplitButton3.Image")));
            this.toolStripSplitButton3.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.toolStripSplitButton3.Name = "toolStripSplitButton3";
            this.toolStripSplitButton3.Size = new System.Drawing.Size(61, 20);
            this.toolStripSplitButton3.Text = "About";
            this.toolStripSplitButton3.ButtonClick += new System.EventHandler(this.toolStripSplitButton3_ButtonClick);
            // 
            // sbDbNames
            // 
            this.sbDbNames.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.cbDbNames});
            this.sbDbNames.Image = ((System.Drawing.Image)(resources.GetObject("sbDbNames.Image")));
            this.sbDbNames.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.sbDbNames.Name = "sbDbNames";
            this.sbDbNames.Size = new System.Drawing.Size(83, 20);
            this.sbDbNames.Text = "SQLPTO";
            this.sbDbNames.ButtonClick += new System.EventHandler(this.sbDbNames_ButtonClick);
            // 
            // cbDbNames
            // 
            this.cbDbNames.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbDbNames.Name = "cbDbNames";
            this.cbDbNames.Size = new System.Drawing.Size(121, 23);
            this.cbDbNames.SelectedIndexChanged += new System.EventHandler(this.cbDbNames_SelectedIndexChanged);
            // 
            // toolStripSplitButton1
            // 
            this.toolStripSplitButton1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItem1});
            this.toolStripSplitButton1.Image = ((System.Drawing.Image)(resources.GetObject("toolStripSplitButton1.Image")));
            this.toolStripSplitButton1.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.toolStripSplitButton1.Name = "toolStripSplitButton1";
            this.toolStripSplitButton1.Size = new System.Drawing.Size(156, 20);
            this.toolStripSplitButton1.Text = "View Summary Report";
            this.toolStripSplitButton1.ButtonClick += new System.EventHandler(this.toolStripSplitButton1_ButtonClick);
            // 
            // toolStripMenuItem1
            // 
            this.toolStripMenuItem1.Name = "toolStripMenuItem1";
            this.toolStripMenuItem1.Size = new System.Drawing.Size(207, 22);
            this.toolStripMenuItem1.Text = "Compare Data Collection";
            this.toolStripMenuItem1.Click += new System.EventHandler(this.toolStripMenuItem1_Click);
            // 
            // toolStripSplitButton2
            // 
            this.toolStripSplitButton2.DropDownButtonWidth = 0;
            this.toolStripSplitButton2.Image = ((System.Drawing.Image)(resources.GetObject("toolStripSplitButton2.Image")));
            this.toolStripSplitButton2.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.toolStripSplitButton2.Name = "toolStripSplitButton2";
            this.toolStripSplitButton2.Size = new System.Drawing.Size(81, 20);
            this.toolStripSplitButton2.Text = "PerfQuery";
            this.toolStripSplitButton2.ButtonClick += new System.EventHandler(this.toolStripSplitButton2_ButtonClick);
            // 
            // tssbLoadData
            // 
            this.tssbLoadData.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.miCollectedData,
            this.importReportsToolStripMenuItem,
            this.clearDataImportLogToolStripMenuItem,
            this.viewDataImportLogToolStripMenuItem,
            this.openFolderToolStripMenuItem});
            this.tssbLoadData.Image = ((System.Drawing.Image)(resources.GetObject("tssbLoadData.Image")));
            this.tssbLoadData.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tssbLoadData.Name = "tssbLoadData";
            this.tssbLoadData.Size = new System.Drawing.Size(92, 20);
            this.tssbLoadData.Text = "Load Data";
            this.tssbLoadData.ButtonClick += new System.EventHandler(this.tssbLoadData_ButtonClick);
            // 
            // miCollectedData
            // 
            this.miCollectedData.Name = "miCollectedData";
            this.miCollectedData.Size = new System.Drawing.Size(190, 22);
            this.miCollectedData.Text = "Collected Data Folder";
            this.miCollectedData.Click += new System.EventHandler(this.miCollectedData_Click);
            // 
            // importReportsToolStripMenuItem
            // 
            this.importReportsToolStripMenuItem.Name = "importReportsToolStripMenuItem";
            this.importReportsToolStripMenuItem.Size = new System.Drawing.Size(190, 22);
            this.importReportsToolStripMenuItem.Text = "Import Reports";
            this.importReportsToolStripMenuItem.Click += new System.EventHandler(this.importReportsToolStripMenuItem_Click);
            // 
            // clearDataImportLogToolStripMenuItem
            // 
            this.clearDataImportLogToolStripMenuItem.Name = "clearDataImportLogToolStripMenuItem";
            this.clearDataImportLogToolStripMenuItem.Size = new System.Drawing.Size(190, 22);
            this.clearDataImportLogToolStripMenuItem.Text = "Clear Data Import Log";
            this.clearDataImportLogToolStripMenuItem.Click += new System.EventHandler(this.clearDataImportLogToolStripMenuItem_Click);
            // 
            // viewDataImportLogToolStripMenuItem
            // 
            this.viewDataImportLogToolStripMenuItem.Name = "viewDataImportLogToolStripMenuItem";
            this.viewDataImportLogToolStripMenuItem.Size = new System.Drawing.Size(190, 22);
            this.viewDataImportLogToolStripMenuItem.Text = "View Data Import Log";
            this.viewDataImportLogToolStripMenuItem.Click += new System.EventHandler(this.viewDataImportLogToolStripMenuItem_Click);
            // 
            // openFolderToolStripMenuItem
            // 
            this.openFolderToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fixScriptsToolStripMenuItem,
            this.allQueryPlansToolStripMenuItem,
            this.dMVPlansToolStripMenuItem});
            this.openFolderToolStripMenuItem.Name = "openFolderToolStripMenuItem";
            this.openFolderToolStripMenuItem.Size = new System.Drawing.Size(190, 22);
            this.openFolderToolStripMenuItem.Text = "Open Folder";
            // 
            // fixScriptsToolStripMenuItem
            // 
            this.fixScriptsToolStripMenuItem.Name = "fixScriptsToolStripMenuItem";
            this.fixScriptsToolStripMenuItem.Size = new System.Drawing.Size(154, 22);
            this.fixScriptsToolStripMenuItem.Text = "Fix Scripts";
            this.fixScriptsToolStripMenuItem.Click += new System.EventHandler(this.fixScriptsToolStripMenuItem_Click);
            // 
            // allQueryPlansToolStripMenuItem
            // 
            this.allQueryPlansToolStripMenuItem.Name = "allQueryPlansToolStripMenuItem";
            this.allQueryPlansToolStripMenuItem.Size = new System.Drawing.Size(154, 22);
            this.allQueryPlansToolStripMenuItem.Text = "All Query Plans";
            this.allQueryPlansToolStripMenuItem.Click += new System.EventHandler(this.allQueryPlansToolStripMenuItem_Click);
            // 
            // dMVPlansToolStripMenuItem
            // 
            this.dMVPlansToolStripMenuItem.Name = "dMVPlansToolStripMenuItem";
            this.dMVPlansToolStripMenuItem.Size = new System.Drawing.Size(154, 22);
            this.dMVPlansToolStripMenuItem.Text = "DMV Plans";
            this.dMVPlansToolStripMenuItem.Click += new System.EventHandler(this.dMVPlansToolStripMenuItem_Click);
            // 
            // tsslStatus
            // 
            this.tsslStatus.Name = "tsslStatus";
            this.tsslStatus.Size = new System.Drawing.Size(26, 17);
            this.tsslStatus.Text = "Idle";
            this.tsslStatus.Click += new System.EventHandler(this.tsslStatus_Click);
            // 
            // timer1
            // 
            this.timer1.Interval = 5000;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // timer2
            // 
            this.timer2.Interval = 5000;
            this.timer2.Tick += new System.EventHandler(this.timer2_Tick);
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel1.Controls.Add(this.btnAboutOK);
            this.panel1.Controls.Add(this.label7);
            this.panel1.Controls.Add(this.label6);
            this.panel1.Controls.Add(this.label5);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Controls.Add(this.label3);
            this.panel1.Controls.Add(this.label4);
            this.panel1.Controls.Add(this.label2);
            this.panel1.Controls.Add(this.linkLabel1);
            this.panel1.Controls.Add(this.pictureBox1);
            this.panel1.Location = new System.Drawing.Point(260, 258);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(704, 246);
            this.panel1.TabIndex = 4;
            this.panel1.Visible = false;
            // 
            // btnAboutOK
            // 
            this.btnAboutOK.Location = new System.Drawing.Point(611, 213);
            this.btnAboutOK.Name = "btnAboutOK";
            this.btnAboutOK.Size = new System.Drawing.Size(75, 23);
            this.btnAboutOK.TabIndex = 25;
            this.btnAboutOK.Text = "OK";
            this.btnAboutOK.UseVisualStyleBackColor = true;
            this.btnAboutOK.Click += new System.EventHandler(this.btnAboutOK_Click);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label7.Location = new System.Drawing.Point(100, 220);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(306, 16);
            this.label7.TabIndex = 24;
            this.label7.Text = "Pedro Lopez; Suresh B.Kandoth; Mohamed Sharaf";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label6.Location = new System.Drawing.Point(21, 220);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(82, 16);
            this.label6.TabIndex = 23;
            this.label6.Text = "Contributors:";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(521, 29);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(94, 13);
            this.label5.TabIndex = 22;
            this.label5.Text = "2017 Feb Release";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 24F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(8, 11);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(507, 37);
            this.label1.TabIndex = 21;
            this.label1.Text = "SQL Server Performance Analyzer";
            // 
            // label3
            // 
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(12, 155);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(475, 43);
            this.label3.TabIndex = 20;
            this.label3.Text = "This software is licensed \"as-is\". You bear the risk of using it. The author and " +
    "contributors give no express warranties, guarantees or conditions.";
            // 
            // label4
            // 
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(12, 81);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(484, 59);
            this.label4.TabIndex = 19;
            this.label4.Text = "This tool is authored by Louis Li (Louisli@microsoft.com) and various other contr" +
    "ibutors. If you have any questions or feedback with this tool, please contact au" +
    "thor. ";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(579, 155);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(107, 17);
            this.label2.TabIndex = 18;
            this.label2.Text = "Author: Louis Li";
            // 
            // linkLabel1
            // 
            this.linkLabel1.AutoSize = true;
            this.linkLabel1.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.linkLabel1.Location = new System.Drawing.Point(500, 172);
            this.linkLabel1.Name = "linkLabel1";
            this.linkLabel1.Size = new System.Drawing.Size(186, 17);
            this.linkLabel1.TabIndex = 17;
            this.linkLabel1.TabStop = true;
            this.linkLabel1.Text = "Email: louisli@microsoft.com";
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::SQL_PTO_Report.Properties.Resources.Louis_2;
            this.pictureBox1.Location = new System.Drawing.Point(621, 82);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(65, 66);
            this.pictureBox1.TabIndex = 16;
            this.pictureBox1.TabStop = false;
            // 
            // Reports
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1158, 890);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.reportViewer1);
            this.Controls.Add(this.statusStrip1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Reports";
            this.Text = "SQL Server Performance Analyzer Client Tool";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Microsoft.Reporting.WinForms.ReportViewer reportViewer1;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripSplitButton sbDbNames;
        private System.Windows.Forms.ToolStripComboBox cbDbNames;
        private System.Windows.Forms.ToolStripSplitButton toolStripSplitButton1;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem1;
        private System.Windows.Forms.ToolStripSplitButton tssbLoadData;
        private System.Windows.Forms.ToolStripMenuItem miCollectedData;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.ToolStripStatusLabel tsslStatus;
        private System.Windows.Forms.Timer timer2;
        private System.Windows.Forms.ToolStripSplitButton toolStripSplitButton3;
        private System.Windows.Forms.ToolStripMenuItem importReportsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem openFolderToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem fixScriptsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem allQueryPlansToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem dMVPlansToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem viewDataImportLogToolStripMenuItem;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.LinkLabel linkLabel1;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Button btnAboutOK;
        private System.Windows.Forms.ToolStripMenuItem clearDataImportLogToolStripMenuItem;
        private System.Windows.Forms.ToolStripSplitButton toolStripSplitButton2;
    }
}

