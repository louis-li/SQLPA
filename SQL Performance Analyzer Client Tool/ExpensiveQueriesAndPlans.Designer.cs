namespace SQL_PTO_Report
{
    partial class ExpensiveQueriesAndPlans
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ExpensiveQueriesAndPlans));
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            this.toolStrip1 = new System.Windows.Forms.ToolStrip();
            this.btnQueryType = new System.Windows.Forms.ToolStripDropDownButton();
            this.cPUToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.durationToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.physicalReadsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.logicalReadsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.rowsReturnedToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.writesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.btnExportPlan = new System.Windows.Forms.ToolStripButton();
            this.btnShowPlanOnly = new System.Windows.Forms.ToolStripButton();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.dgvQuery = new System.Windows.Forms.DataGridView();
            this.splitContainer2 = new System.Windows.Forms.SplitContainer();
            this.dgvActivities = new System.Windows.Forms.DataGridView();
            this.dgvEvents = new System.Windows.Forms.DataGridView();
            this.toolStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvQuery)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).BeginInit();
            this.splitContainer2.Panel1.SuspendLayout();
            this.splitContainer2.Panel2.SuspendLayout();
            this.splitContainer2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvActivities)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvEvents)).BeginInit();
            this.SuspendLayout();
            // 
            // toolStrip1
            // 
            this.toolStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.btnQueryType,
            this.btnExportPlan,
            this.btnShowPlanOnly});
            this.toolStrip1.Location = new System.Drawing.Point(0, 0);
            this.toolStrip1.Name = "toolStrip1";
            this.toolStrip1.Size = new System.Drawing.Size(828, 25);
            this.toolStrip1.TabIndex = 0;
            this.toolStrip1.Text = "toolStrip1";
            // 
            // btnQueryType
            // 
            this.btnQueryType.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.cPUToolStripMenuItem,
            this.durationToolStripMenuItem,
            this.physicalReadsToolStripMenuItem,
            this.logicalReadsToolStripMenuItem,
            this.rowsReturnedToolStripMenuItem,
            this.writesToolStripMenuItem});
            this.btnQueryType.Image = ((System.Drawing.Image)(resources.GetObject("btnQueryType.Image")));
            this.btnQueryType.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnQueryType.Name = "btnQueryType";
            this.btnQueryType.Size = new System.Drawing.Size(125, 22);
            this.btnQueryType.Text = "Query Type: CPU";
            // 
            // cPUToolStripMenuItem
            // 
            this.cPUToolStripMenuItem.Name = "cPUToolStripMenuItem";
            this.cPUToolStripMenuItem.Size = new System.Drawing.Size(151, 22);
            this.cPUToolStripMenuItem.Text = "CPU";
            this.cPUToolStripMenuItem.Click += new System.EventHandler(this.cPUToolStripMenuItem_Click);
            // 
            // durationToolStripMenuItem
            // 
            this.durationToolStripMenuItem.Name = "durationToolStripMenuItem";
            this.durationToolStripMenuItem.Size = new System.Drawing.Size(151, 22);
            this.durationToolStripMenuItem.Text = "Duration";
            this.durationToolStripMenuItem.Click += new System.EventHandler(this.durationToolStripMenuItem_Click);
            // 
            // physicalReadsToolStripMenuItem
            // 
            this.physicalReadsToolStripMenuItem.Name = "physicalReadsToolStripMenuItem";
            this.physicalReadsToolStripMenuItem.Size = new System.Drawing.Size(151, 22);
            this.physicalReadsToolStripMenuItem.Text = "Physical Reads";
            this.physicalReadsToolStripMenuItem.Click += new System.EventHandler(this.physicalReadsToolStripMenuItem_Click);
            // 
            // logicalReadsToolStripMenuItem
            // 
            this.logicalReadsToolStripMenuItem.Name = "logicalReadsToolStripMenuItem";
            this.logicalReadsToolStripMenuItem.Size = new System.Drawing.Size(151, 22);
            this.logicalReadsToolStripMenuItem.Text = "Logical Reads";
            this.logicalReadsToolStripMenuItem.Click += new System.EventHandler(this.logicalReadsToolStripMenuItem_Click);
            // 
            // rowsReturnedToolStripMenuItem
            // 
            this.rowsReturnedToolStripMenuItem.Name = "rowsReturnedToolStripMenuItem";
            this.rowsReturnedToolStripMenuItem.Size = new System.Drawing.Size(151, 22);
            this.rowsReturnedToolStripMenuItem.Text = "Row Count";
            this.rowsReturnedToolStripMenuItem.Click += new System.EventHandler(this.rowsReturnedToolStripMenuItem_Click);
            // 
            // writesToolStripMenuItem
            // 
            this.writesToolStripMenuItem.Name = "writesToolStripMenuItem";
            this.writesToolStripMenuItem.Size = new System.Drawing.Size(151, 22);
            this.writesToolStripMenuItem.Text = "Writes";
            this.writesToolStripMenuItem.Click += new System.EventHandler(this.writesToolStripMenuItem_Click);
            // 
            // btnExportPlan
            // 
            this.btnExportPlan.Image = ((System.Drawing.Image)(resources.GetObject("btnExportPlan.Image")));
            this.btnExportPlan.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnExportPlan.Name = "btnExportPlan";
            this.btnExportPlan.Size = new System.Drawing.Size(121, 22);
            this.btnExportPlan.Text = "Export Query Plan";
            this.btnExportPlan.Click += new System.EventHandler(this.btnExportPlan_Click);
            // 
            // btnShowPlanOnly
            // 
            this.btnShowPlanOnly.Checked = true;
            this.btnShowPlanOnly.CheckOnClick = true;
            this.btnShowPlanOnly.CheckState = System.Windows.Forms.CheckState.Checked;
            this.btnShowPlanOnly.Image = ((System.Drawing.Image)(resources.GetObject("btnShowPlanOnly.Image")));
            this.btnShowPlanOnly.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnShowPlanOnly.Name = "btnShowPlanOnly";
            this.btnShowPlanOnly.Size = new System.Drawing.Size(115, 22);
            this.btnShowPlanOnly.Text = "Only Show Plans";
            this.btnShowPlanOnly.CheckedChanged += new System.EventHandler(this.btnShowPlanOnly_CheckedChanged);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 25);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.dgvQuery);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.splitContainer2);
            this.splitContainer1.Size = new System.Drawing.Size(828, 526);
            this.splitContainer1.SplitterDistance = 118;
            this.splitContainer1.TabIndex = 1;
            // 
            // dgvQuery
            // 
            this.dgvQuery.AllowUserToAddRows = false;
            this.dgvQuery.AllowUserToDeleteRows = false;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.dgvQuery.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvQuery.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvQuery.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvQuery.Location = new System.Drawing.Point(0, 0);
            this.dgvQuery.Name = "dgvQuery";
            this.dgvQuery.ReadOnly = true;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.ActiveCaption;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvQuery.RowHeadersDefaultCellStyle = dataGridViewCellStyle2;
            this.dgvQuery.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvQuery.Size = new System.Drawing.Size(828, 118);
            this.dgvQuery.TabIndex = 0;
            this.dgvQuery.SelectionChanged += new System.EventHandler(this.dgvQuery_SelectionChanged);
            // 
            // splitContainer2
            // 
            this.splitContainer2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer2.Location = new System.Drawing.Point(0, 0);
            this.splitContainer2.Name = "splitContainer2";
            this.splitContainer2.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer2.Panel1
            // 
            this.splitContainer2.Panel1.Controls.Add(this.dgvActivities);
            // 
            // splitContainer2.Panel2
            // 
            this.splitContainer2.Panel2.Controls.Add(this.dgvEvents);
            this.splitContainer2.Size = new System.Drawing.Size(828, 404);
            this.splitContainer2.SplitterDistance = 79;
            this.splitContainer2.TabIndex = 0;
            // 
            // dgvActivities
            // 
            this.dgvActivities.AllowUserToAddRows = false;
            this.dgvActivities.AllowUserToDeleteRows = false;
            dataGridViewCellStyle3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.dgvActivities.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle3;
            this.dgvActivities.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvActivities.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvActivities.Location = new System.Drawing.Point(0, 0);
            this.dgvActivities.Name = "dgvActivities";
            this.dgvActivities.ReadOnly = true;
            this.dgvActivities.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvActivities.Size = new System.Drawing.Size(828, 79);
            this.dgvActivities.TabIndex = 0;
            this.dgvActivities.SelectionChanged += new System.EventHandler(this.dgvActivities_SelectionChanged);
            // 
            // dgvEvents
            // 
            this.dgvEvents.AllowUserToAddRows = false;
            this.dgvEvents.AllowUserToDeleteRows = false;
            dataGridViewCellStyle4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.dgvEvents.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle4;
            this.dgvEvents.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvEvents.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvEvents.Location = new System.Drawing.Point(0, 0);
            this.dgvEvents.Name = "dgvEvents";
            this.dgvEvents.ReadOnly = true;
            this.dgvEvents.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvEvents.Size = new System.Drawing.Size(828, 321);
            this.dgvEvents.TabIndex = 0;
            this.dgvEvents.DoubleClick += new System.EventHandler(this.dgvEvents_DoubleClick);
            // 
            // ExpensiveQueriesAndPlans
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(828, 551);
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.toolStrip1);
            this.Name = "ExpensiveQueriesAndPlans";
            this.Text = "Queries and Plans";
            this.Load += new System.EventHandler(this.ExpensiveQueriesAndPlans_Load);
            this.toolStrip1.ResumeLayout(false);
            this.toolStrip1.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvQuery)).EndInit();
            this.splitContainer2.Panel1.ResumeLayout(false);
            this.splitContainer2.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).EndInit();
            this.splitContainer2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvActivities)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvEvents)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ToolStrip toolStrip1;
        private System.Windows.Forms.ToolStripDropDownButton btnQueryType;
        private System.Windows.Forms.ToolStripMenuItem cPUToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem durationToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem physicalReadsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem logicalReadsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem rowsReturnedToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem writesToolStripMenuItem;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.DataGridView dgvQuery;
        private System.Windows.Forms.SplitContainer splitContainer2;
        private System.Windows.Forms.DataGridView dgvActivities;
        private System.Windows.Forms.DataGridView dgvEvents;
        private System.Windows.Forms.ToolStripButton btnExportPlan;
        private System.Windows.Forms.ToolStripButton btnShowPlanOnly;
    }
}