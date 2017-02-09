namespace SQLDiagConfigurationManager
{
    partial class frmConfiguration
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmConfiguration));
            this.gbSQLVersion = new System.Windows.Forms.GroupBox();
            this.cbVersion = new System.Windows.Forms.ComboBox();
            this.gbOptions = new System.Windows.Forms.GroupBox();
            this.chkStatement = new System.Windows.Forms.CheckBox();
            this.chkWaitInfo = new System.Windows.Forms.CheckBox();
            this.nPlanRatio = new System.Windows.Forms.NumericUpDown();
            this.gbPlanCaptureRatio = new System.Windows.Forms.GroupBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.btnGenerate = new System.Windows.Forms.Button();
            this.gbSchedule = new System.Windows.Forms.GroupBox();
            this.chkSchedule = new System.Windows.Forms.CheckBox();
            this.lblEnd = new System.Windows.Forms.Label();
            this.dtpEnd = new System.Windows.Forms.DateTimePicker();
            this.lblBegin = new System.Windows.Forms.Label();
            this.dtpBegin = new System.Windows.Forms.DateTimePicker();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tVersion = new System.Windows.Forms.TabPage();
            this.tPlan = new System.Windows.Forms.TabPage();
            this.tXE = new System.Windows.Forms.TabPage();
            this.tSnapshot = new System.Windows.Forms.TabPage();
            this.tSchedule = new System.Windows.Forms.TabPage();
            this.btnCancel = new System.Windows.Forms.Button();
            this.gbFrequency = new System.Windows.Forms.GroupBox();
            this.tbSnapshotInterval = new System.Windows.Forms.TrackBar();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.gbStorage = new System.Windows.Forms.GroupBox();
            this.nNumberOfFiles = new System.Windows.Forms.NumericUpDown();
            this.tbSize = new System.Windows.Forms.TrackBar();
            this.lblFilesize = new System.Windows.Forms.Label();
            this.lblNumberOfFiles = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.gbSQLVersion.SuspendLayout();
            this.gbOptions.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nPlanRatio)).BeginInit();
            this.gbPlanCaptureRatio.SuspendLayout();
            this.gbSchedule.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tVersion.SuspendLayout();
            this.tPlan.SuspendLayout();
            this.tXE.SuspendLayout();
            this.tSnapshot.SuspendLayout();
            this.tSchedule.SuspendLayout();
            this.gbFrequency.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.tbSnapshotInterval)).BeginInit();
            this.gbStorage.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nNumberOfFiles)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.tbSize)).BeginInit();
            this.SuspendLayout();
            // 
            // gbSQLVersion
            // 
            this.gbSQLVersion.Controls.Add(this.cbVersion);
            this.gbSQLVersion.Location = new System.Drawing.Point(20, 20);
            this.gbSQLVersion.Name = "gbSQLVersion";
            this.gbSQLVersion.Size = new System.Drawing.Size(312, 92);
            this.gbSQLVersion.TabIndex = 5;
            this.gbSQLVersion.TabStop = false;
            this.gbSQLVersion.Text = "Select SQL version";
            // 
            // cbVersion
            // 
            this.cbVersion.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbVersion.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cbVersion.FormattingEnabled = true;
            this.cbVersion.Items.AddRange(new object[] {
            "2012",
            "2014",
            "2016"});
            this.cbVersion.Location = new System.Drawing.Point(45, 30);
            this.cbVersion.Name = "cbVersion";
            this.cbVersion.Size = new System.Drawing.Size(151, 28);
            this.cbVersion.TabIndex = 11;
            // 
            // gbOptions
            // 
            this.gbOptions.Controls.Add(this.chkStatement);
            this.gbOptions.Controls.Add(this.chkWaitInfo);
            this.gbOptions.Location = new System.Drawing.Point(8, 5);
            this.gbOptions.Name = "gbOptions";
            this.gbOptions.Size = new System.Drawing.Size(349, 52);
            this.gbOptions.TabIndex = 6;
            this.gbOptions.TabStop = false;
            this.gbOptions.Text = "Extended Events Options";
            // 
            // chkStatement
            // 
            this.chkStatement.AutoSize = true;
            this.chkStatement.Location = new System.Drawing.Point(173, 19);
            this.chkStatement.Name = "chkStatement";
            this.chkStatement.Size = new System.Drawing.Size(151, 17);
            this.chkStatement.TabIndex = 1;
            this.chkStatement.Text = "Statement Level SQL Test";
            this.chkStatement.UseVisualStyleBackColor = true;
            // 
            // chkWaitInfo
            // 
            this.chkWaitInfo.AutoSize = true;
            this.chkWaitInfo.Checked = true;
            this.chkWaitInfo.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkWaitInfo.Location = new System.Drawing.Point(7, 20);
            this.chkWaitInfo.Name = "chkWaitInfo";
            this.chkWaitInfo.Size = new System.Drawing.Size(69, 17);
            this.chkWaitInfo.TabIndex = 0;
            this.chkWaitInfo.Text = "Wait Info";
            this.chkWaitInfo.UseVisualStyleBackColor = true;
            // 
            // nPlanRatio
            // 
            this.nPlanRatio.Location = new System.Drawing.Point(163, 28);
            this.nPlanRatio.Name = "nPlanRatio";
            this.nPlanRatio.Size = new System.Drawing.Size(72, 20);
            this.nPlanRatio.TabIndex = 7;
            this.nPlanRatio.Value = new decimal(new int[] {
            100,
            0,
            0,
            0});
            // 
            // gbPlanCaptureRatio
            // 
            this.gbPlanCaptureRatio.Controls.Add(this.label2);
            this.gbPlanCaptureRatio.Controls.Add(this.label1);
            this.gbPlanCaptureRatio.Controls.Add(this.nPlanRatio);
            this.gbPlanCaptureRatio.Location = new System.Drawing.Point(20, 20);
            this.gbPlanCaptureRatio.Name = "gbPlanCaptureRatio";
            this.gbPlanCaptureRatio.Size = new System.Drawing.Size(302, 74);
            this.gbPlanCaptureRatio.TabIndex = 8;
            this.gbPlanCaptureRatio.TabStop = false;
            this.gbPlanCaptureRatio.Text = "Execution Plan Capture Ratio";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(241, 30);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(44, 13);
            this.label2.TabIndex = 9;
            this.label2.Text = "queries.";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(9, 30);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(148, 13);
            this.label1.TabIndex = 8;
            this.label1.Text = "Capture execution plan every ";
            // 
            // btnGenerate
            // 
            this.btnGenerate.Location = new System.Drawing.Point(213, 218);
            this.btnGenerate.Name = "btnGenerate";
            this.btnGenerate.Size = new System.Drawing.Size(75, 23);
            this.btnGenerate.TabIndex = 9;
            this.btnGenerate.Text = "Generate";
            this.btnGenerate.UseVisualStyleBackColor = true;
            this.btnGenerate.Click += new System.EventHandler(this.btnGenerate_Click);
            // 
            // gbSchedule
            // 
            this.gbSchedule.Controls.Add(this.chkSchedule);
            this.gbSchedule.Controls.Add(this.lblEnd);
            this.gbSchedule.Controls.Add(this.dtpEnd);
            this.gbSchedule.Controls.Add(this.lblBegin);
            this.gbSchedule.Controls.Add(this.dtpBegin);
            this.gbSchedule.Location = new System.Drawing.Point(20, 20);
            this.gbSchedule.Name = "gbSchedule";
            this.gbSchedule.Size = new System.Drawing.Size(302, 122);
            this.gbSchedule.TabIndex = 10;
            this.gbSchedule.TabStop = false;
            this.gbSchedule.Text = "Schedule";
            // 
            // chkSchedule
            // 
            this.chkSchedule.AutoSize = true;
            this.chkSchedule.Location = new System.Drawing.Point(12, 19);
            this.chkSchedule.Name = "chkSchedule";
            this.chkSchedule.Size = new System.Drawing.Size(71, 17);
            this.chkSchedule.TabIndex = 4;
            this.chkSchedule.Text = "Schedule";
            this.chkSchedule.UseVisualStyleBackColor = true;
            this.chkSchedule.CheckedChanged += new System.EventHandler(this.chkSchedule_CheckedChanged);
            // 
            // lblEnd
            // 
            this.lblEnd.AutoSize = true;
            this.lblEnd.Location = new System.Drawing.Point(17, 85);
            this.lblEnd.Name = "lblEnd";
            this.lblEnd.Size = new System.Drawing.Size(52, 13);
            this.lblEnd.TabIndex = 3;
            this.lblEnd.Text = "End Time";
            // 
            // dtpEnd
            // 
            this.dtpEnd.CustomFormat = "hh:mm";
            this.dtpEnd.Enabled = false;
            this.dtpEnd.Format = System.Windows.Forms.DateTimePickerFormat.Time;
            this.dtpEnd.Location = new System.Drawing.Point(85, 79);
            this.dtpEnd.Name = "dtpEnd";
            this.dtpEnd.ShowUpDown = true;
            this.dtpEnd.Size = new System.Drawing.Size(200, 20);
            this.dtpEnd.TabIndex = 1;
            // 
            // lblBegin
            // 
            this.lblBegin.AutoSize = true;
            this.lblBegin.Location = new System.Drawing.Point(9, 49);
            this.lblBegin.Name = "lblBegin";
            this.lblBegin.Size = new System.Drawing.Size(60, 13);
            this.lblBegin.TabIndex = 1;
            this.lblBegin.Text = "Begin Time";
            // 
            // dtpBegin
            // 
            this.dtpBegin.CustomFormat = "HH:mm:ss tt";
            this.dtpBegin.Enabled = false;
            this.dtpBegin.Format = System.Windows.Forms.DateTimePickerFormat.Time;
            this.dtpBegin.Location = new System.Drawing.Point(85, 43);
            this.dtpBegin.Name = "dtpBegin";
            this.dtpBegin.ShowUpDown = true;
            this.dtpBegin.Size = new System.Drawing.Size(200, 20);
            this.dtpBegin.TabIndex = 0;
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tVersion);
            this.tabControl1.Controls.Add(this.tPlan);
            this.tabControl1.Controls.Add(this.tXE);
            this.tabControl1.Controls.Add(this.tSnapshot);
            this.tabControl1.Controls.Add(this.tSchedule);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Top;
            this.tabControl1.Location = new System.Drawing.Point(0, 0);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(373, 208);
            this.tabControl1.TabIndex = 11;
            // 
            // tVersion
            // 
            this.tVersion.Controls.Add(this.gbSQLVersion);
            this.tVersion.Location = new System.Drawing.Point(4, 22);
            this.tVersion.Name = "tVersion";
            this.tVersion.Padding = new System.Windows.Forms.Padding(3);
            this.tVersion.Size = new System.Drawing.Size(365, 182);
            this.tVersion.TabIndex = 0;
            this.tVersion.Text = "Version";
            this.tVersion.UseVisualStyleBackColor = true;
            // 
            // tPlan
            // 
            this.tPlan.Controls.Add(this.gbPlanCaptureRatio);
            this.tPlan.Location = new System.Drawing.Point(4, 22);
            this.tPlan.Name = "tPlan";
            this.tPlan.Padding = new System.Windows.Forms.Padding(3);
            this.tPlan.Size = new System.Drawing.Size(365, 182);
            this.tPlan.TabIndex = 1;
            this.tPlan.Text = "Execution Plan";
            this.tPlan.UseVisualStyleBackColor = true;
            // 
            // tXE
            // 
            this.tXE.Controls.Add(this.gbStorage);
            this.tXE.Controls.Add(this.gbOptions);
            this.tXE.Location = new System.Drawing.Point(4, 22);
            this.tXE.Name = "tXE";
            this.tXE.Size = new System.Drawing.Size(365, 182);
            this.tXE.TabIndex = 2;
            this.tXE.Text = "xEvent";
            this.tXE.UseVisualStyleBackColor = true;
            // 
            // tSnapshot
            // 
            this.tSnapshot.Controls.Add(this.gbFrequency);
            this.tSnapshot.Location = new System.Drawing.Point(4, 22);
            this.tSnapshot.Name = "tSnapshot";
            this.tSnapshot.Size = new System.Drawing.Size(365, 182);
            this.tSnapshot.TabIndex = 3;
            this.tSnapshot.Text = "Snapshot";
            this.tSnapshot.UseVisualStyleBackColor = true;
            // 
            // tSchedule
            // 
            this.tSchedule.Controls.Add(this.gbSchedule);
            this.tSchedule.Location = new System.Drawing.Point(4, 22);
            this.tSchedule.Name = "tSchedule";
            this.tSchedule.Size = new System.Drawing.Size(365, 182);
            this.tSchedule.TabIndex = 4;
            this.tSchedule.Text = "Schedule";
            this.tSchedule.UseVisualStyleBackColor = true;
            // 
            // btnCancel
            // 
            this.btnCancel.Location = new System.Drawing.Point(294, 218);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 12;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // gbFrequency
            // 
            this.gbFrequency.Controls.Add(this.label5);
            this.gbFrequency.Controls.Add(this.label4);
            this.gbFrequency.Controls.Add(this.label3);
            this.gbFrequency.Controls.Add(this.tbSnapshotInterval);
            this.gbFrequency.Location = new System.Drawing.Point(20, 20);
            this.gbFrequency.Name = "gbFrequency";
            this.gbFrequency.Size = new System.Drawing.Size(312, 133);
            this.gbFrequency.TabIndex = 0;
            this.gbFrequency.TabStop = false;
            this.gbFrequency.Text = "Snapshot Interval";
            // 
            // tbSnapshotInterval
            // 
            this.tbSnapshotInterval.LargeChange = 3;
            this.tbSnapshotInterval.Location = new System.Drawing.Point(21, 61);
            this.tbSnapshotInterval.Minimum = 1;
            this.tbSnapshotInterval.Name = "tbSnapshotInterval";
            this.tbSnapshotInterval.Size = new System.Drawing.Size(268, 45);
            this.tbSnapshotInterval.TabIndex = 0;
            this.tbSnapshotInterval.TickStyle = System.Windows.Forms.TickStyle.TopLeft;
            this.tbSnapshotInterval.Value = 5;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(18, 45);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(33, 13);
            this.label3.TabIndex = 1;
            this.label3.Text = "1 Min";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(127, 45);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(33, 13);
            this.label4.TabIndex = 2;
            this.label4.Text = "5 Min";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(267, 45);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(39, 13);
            this.label5.TabIndex = 3;
            this.label5.Text = "10 Min";
            // 
            // gbStorage
            // 
            this.gbStorage.Controls.Add(this.label7);
            this.gbStorage.Controls.Add(this.label6);
            this.gbStorage.Controls.Add(this.nNumberOfFiles);
            this.gbStorage.Controls.Add(this.lblNumberOfFiles);
            this.gbStorage.Controls.Add(this.lblFilesize);
            this.gbStorage.Controls.Add(this.tbSize);
            this.gbStorage.Location = new System.Drawing.Point(8, 63);
            this.gbStorage.Name = "gbStorage";
            this.gbStorage.Size = new System.Drawing.Size(349, 116);
            this.gbStorage.TabIndex = 7;
            this.gbStorage.TabStop = false;
            this.gbStorage.Text = "Storage";
            // 
            // nNumberOfFiles
            // 
            this.nNumberOfFiles.Location = new System.Drawing.Point(92, 85);
            this.nNumberOfFiles.Name = "nNumberOfFiles";
            this.nNumberOfFiles.Size = new System.Drawing.Size(61, 20);
            this.nNumberOfFiles.TabIndex = 0;
            this.nNumberOfFiles.Value = new decimal(new int[] {
            5,
            0,
            0,
            0});
            // 
            // tbSize
            // 
            this.tbSize.LargeChange = 256;
            this.tbSize.Location = new System.Drawing.Point(59, 39);
            this.tbSize.Maximum = 1024;
            this.tbSize.Minimum = 256;
            this.tbSize.Name = "tbSize";
            this.tbSize.Size = new System.Drawing.Size(264, 45);
            this.tbSize.SmallChange = 256;
            this.tbSize.TabIndex = 1;
            this.tbSize.TickFrequency = 256;
            this.tbSize.TickStyle = System.Windows.Forms.TickStyle.TopLeft;
            this.tbSize.Value = 512;
            // 
            // lblFilesize
            // 
            this.lblFilesize.AutoSize = true;
            this.lblFilesize.Location = new System.Drawing.Point(6, 37);
            this.lblFilesize.Name = "lblFilesize";
            this.lblFilesize.Size = new System.Drawing.Size(47, 13);
            this.lblFilesize.TabIndex = 2;
            this.lblFilesize.Text = "File size:";
            // 
            // lblNumberOfFiles
            // 
            this.lblNumberOfFiles.AutoSize = true;
            this.lblNumberOfFiles.Location = new System.Drawing.Point(6, 87);
            this.lblNumberOfFiles.Name = "lblNumberOfFiles";
            this.lblNumberOfFiles.Size = new System.Drawing.Size(80, 13);
            this.lblNumberOfFiles.TabIndex = 3;
            this.lblNumberOfFiles.Text = "Number of files:";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(56, 24);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(41, 13);
            this.label6.TabIndex = 4;
            this.label6.Text = "256MB";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(289, 24);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(47, 13);
            this.label7.TabIndex = 5;
            this.label7.Text = "1024MB";
            // 
            // frmConfiguration
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(373, 253);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.btnGenerate);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmConfiguration";
            this.Text = "PACMAN - SQL PA Configuration Manager";
            this.Load += new System.EventHandler(this.frmConfiguration_Load);
            this.gbSQLVersion.ResumeLayout(false);
            this.gbOptions.ResumeLayout(false);
            this.gbOptions.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nPlanRatio)).EndInit();
            this.gbPlanCaptureRatio.ResumeLayout(false);
            this.gbPlanCaptureRatio.PerformLayout();
            this.gbSchedule.ResumeLayout(false);
            this.gbSchedule.PerformLayout();
            this.tabControl1.ResumeLayout(false);
            this.tVersion.ResumeLayout(false);
            this.tPlan.ResumeLayout(false);
            this.tXE.ResumeLayout(false);
            this.tSnapshot.ResumeLayout(false);
            this.tSchedule.ResumeLayout(false);
            this.gbFrequency.ResumeLayout(false);
            this.gbFrequency.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.tbSnapshotInterval)).EndInit();
            this.gbStorage.ResumeLayout(false);
            this.gbStorage.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nNumberOfFiles)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.tbSize)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.GroupBox gbSQLVersion;
        private System.Windows.Forms.GroupBox gbOptions;
        private System.Windows.Forms.NumericUpDown nPlanRatio;
        private System.Windows.Forms.GroupBox gbPlanCaptureRatio;
        private System.Windows.Forms.Button btnGenerate;
        private System.Windows.Forms.GroupBox gbSchedule;
        private System.Windows.Forms.CheckBox chkSchedule;
        private System.Windows.Forms.Label lblEnd;
        private System.Windows.Forms.DateTimePicker dtpEnd;
        private System.Windows.Forms.Label lblBegin;
        private System.Windows.Forms.DateTimePicker dtpBegin;
        private System.Windows.Forms.ComboBox cbVersion;
        private System.Windows.Forms.CheckBox chkStatement;
        private System.Windows.Forms.CheckBox chkWaitInfo;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tVersion;
        private System.Windows.Forms.TabPage tPlan;
        private System.Windows.Forms.TabPage tXE;
        private System.Windows.Forms.TabPage tSnapshot;
        private System.Windows.Forms.GroupBox gbFrequency;
        private System.Windows.Forms.TabPage tSchedule;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TrackBar tbSnapshotInterval;
        private System.Windows.Forms.GroupBox gbStorage;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.NumericUpDown nNumberOfFiles;
        private System.Windows.Forms.Label lblNumberOfFiles;
        private System.Windows.Forms.Label lblFilesize;
        private System.Windows.Forms.TrackBar tbSize;
    }
}

