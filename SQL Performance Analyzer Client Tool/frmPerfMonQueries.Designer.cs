namespace SQL_PTO_Report
{
    partial class frmPerfMonQueries
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
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea1 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            System.Windows.Forms.DataVisualization.Charting.Legend legend1 = new System.Windows.Forms.DataVisualization.Charting.Legend();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmPerfMonQueries));
            this.dgvQuery = new System.Windows.Forms.DataGridView();
            this.cmsQuery = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.showEventsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.mapPerformanceCounterToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.spQueryGrid = new System.Windows.Forms.Splitter();
            this.chart1 = new System.Windows.Forms.DataVisualization.Charting.Chart();
            this.cmdChartMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.cPUQueryChartToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.durationQueryChatToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.physicalQueryChartToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.logicalQueryChartToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.writeQueryChartToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.rowCounterChartToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.mnShowDataLabel = new System.Windows.Forms.ToolStripMenuItem();
            this.pnlCounterSection = new System.Windows.Forms.Panel();
            this.splitter1 = new System.Windows.Forms.Splitter();
            this.pnlButton = new System.Windows.Forms.Panel();
            this.btnAdd = new System.Windows.Forms.Button();
            this.btnRemove = new System.Windows.Forms.Button();
            this.pnlCounterList = new System.Windows.Forms.Panel();
            this.lbCounters = new System.Windows.Forms.ListBox();
            this.txtCounterSearch = new System.Windows.Forms.TextBox();
            this.spSelectedCounters = new System.Windows.Forms.Splitter();
            this.dgvSelectedCounters = new System.Windows.Forms.DataGridView();
            this.CounterName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Scale = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.MaxValue = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.MinValue = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.spChart = new System.Windows.Forms.Splitter();
            ((System.ComponentModel.ISupportInitialize)(this.dgvQuery)).BeginInit();
            this.cmsQuery.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).BeginInit();
            this.cmdChartMenu.SuspendLayout();
            this.pnlCounterSection.SuspendLayout();
            this.pnlButton.SuspendLayout();
            this.pnlCounterList.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSelectedCounters)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvQuery
            // 
            this.dgvQuery.AllowUserToAddRows = false;
            this.dgvQuery.AllowUserToDeleteRows = false;
            this.dgvQuery.AllowUserToResizeRows = false;
            this.dgvQuery.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvQuery.ContextMenuStrip = this.cmsQuery;
            this.dgvQuery.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.dgvQuery.Location = new System.Drawing.Point(0, 395);
            this.dgvQuery.Name = "dgvQuery";
            this.dgvQuery.ReadOnly = true;
            this.dgvQuery.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvQuery.Size = new System.Drawing.Size(868, 210);
            this.dgvQuery.TabIndex = 0;
            this.dgvQuery.CellMouseDoubleClick += new System.Windows.Forms.DataGridViewCellMouseEventHandler(this.dgvQuery_CellMouseDoubleClick);
            this.dgvQuery.CellMouseEnter += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvQuery_CellMouseEnter);
            // 
            // cmsQuery
            // 
            this.cmsQuery.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.showEventsToolStripMenuItem,
            this.mapPerformanceCounterToolStripMenuItem});
            this.cmsQuery.Name = "cmsQuery";
            this.cmsQuery.Size = new System.Drawing.Size(265, 48);
            // 
            // showEventsToolStripMenuItem
            // 
            this.showEventsToolStripMenuItem.Name = "showEventsToolStripMenuItem";
            this.showEventsToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.E)));
            this.showEventsToolStripMenuItem.Size = new System.Drawing.Size(264, 22);
            this.showEventsToolStripMenuItem.Text = "Show Events";
            this.showEventsToolStripMenuItem.Click += new System.EventHandler(this.showEventsToolStripMenuItem_Click);
            // 
            // mapPerformanceCounterToolStripMenuItem
            // 
            this.mapPerformanceCounterToolStripMenuItem.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
            this.mapPerformanceCounterToolStripMenuItem.Name = "mapPerformanceCounterToolStripMenuItem";
            this.mapPerformanceCounterToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)));
            this.mapPerformanceCounterToolStripMenuItem.Size = new System.Drawing.Size(264, 22);
            this.mapPerformanceCounterToolStripMenuItem.Text = "Map Performance Counter";
            this.mapPerformanceCounterToolStripMenuItem.Click += new System.EventHandler(this.mapPerformanceCounterToolStripMenuItem_Click);
            // 
            // spQueryGrid
            // 
            this.spQueryGrid.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.spQueryGrid.Location = new System.Drawing.Point(0, 392);
            this.spQueryGrid.Name = "spQueryGrid";
            this.spQueryGrid.Size = new System.Drawing.Size(868, 3);
            this.spQueryGrid.TabIndex = 3;
            this.spQueryGrid.TabStop = false;
            // 
            // chart1
            // 
            chartArea1.Name = "Default";
            this.chart1.ChartAreas.Add(chartArea1);
            this.chart1.ContextMenuStrip = this.cmdChartMenu;
            this.chart1.Dock = System.Windows.Forms.DockStyle.Fill;
            legend1.Name = "Legend1";
            this.chart1.Legends.Add(legend1);
            this.chart1.Location = new System.Drawing.Point(0, 0);
            this.chart1.Name = "chart1";
            this.chart1.Palette = System.Windows.Forms.DataVisualization.Charting.ChartColorPalette.Pastel;
            this.chart1.Size = new System.Drawing.Size(868, 140);
            this.chart1.TabIndex = 5;
            this.chart1.Text = "chart1";
            this.chart1.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.chart1_MouseDoubleClick);
            this.chart1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.chart1_MouseMove);
            // 
            // cmdChartMenu
            // 
            this.cmdChartMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.cPUQueryChartToolStripMenuItem,
            this.durationQueryChatToolStripMenuItem,
            this.physicalQueryChartToolStripMenuItem,
            this.logicalQueryChartToolStripMenuItem,
            this.writeQueryChartToolStripMenuItem,
            this.rowCounterChartToolStripMenuItem,
            this.toolStripSeparator1,
            this.mnShowDataLabel});
            this.cmdChartMenu.Name = "cmdChartMenu";
            this.cmdChartMenu.Size = new System.Drawing.Size(185, 164);
            // 
            // cPUQueryChartToolStripMenuItem
            // 
            this.cPUQueryChartToolStripMenuItem.CheckOnClick = true;
            this.cPUQueryChartToolStripMenuItem.Name = "cPUQueryChartToolStripMenuItem";
            this.cPUQueryChartToolStripMenuItem.Size = new System.Drawing.Size(184, 22);
            this.cPUQueryChartToolStripMenuItem.Text = "CPU Query Chart";
            this.cPUQueryChartToolStripMenuItem.CheckStateChanged += new System.EventHandler(this.cPUQueryChartToolStripMenuItem_CheckStateChanged);
            // 
            // durationQueryChatToolStripMenuItem
            // 
            this.durationQueryChatToolStripMenuItem.CheckOnClick = true;
            this.durationQueryChatToolStripMenuItem.Name = "durationQueryChatToolStripMenuItem";
            this.durationQueryChatToolStripMenuItem.Size = new System.Drawing.Size(184, 22);
            this.durationQueryChatToolStripMenuItem.Text = "Duration Query Chat";
            this.durationQueryChatToolStripMenuItem.CheckStateChanged += new System.EventHandler(this.durationQueryChatToolStripMenuItem_CheckStateChanged);
            // 
            // physicalQueryChartToolStripMenuItem
            // 
            this.physicalQueryChartToolStripMenuItem.CheckOnClick = true;
            this.physicalQueryChartToolStripMenuItem.Name = "physicalQueryChartToolStripMenuItem";
            this.physicalQueryChartToolStripMenuItem.Size = new System.Drawing.Size(184, 22);
            this.physicalQueryChartToolStripMenuItem.Text = "Physical Query Chart";
            this.physicalQueryChartToolStripMenuItem.CheckStateChanged += new System.EventHandler(this.physicalQueryChartToolStripMenuItem_CheckStateChanged);
            // 
            // logicalQueryChartToolStripMenuItem
            // 
            this.logicalQueryChartToolStripMenuItem.CheckOnClick = true;
            this.logicalQueryChartToolStripMenuItem.Name = "logicalQueryChartToolStripMenuItem";
            this.logicalQueryChartToolStripMenuItem.Size = new System.Drawing.Size(184, 22);
            this.logicalQueryChartToolStripMenuItem.Text = "Logical Query Chart";
            this.logicalQueryChartToolStripMenuItem.CheckStateChanged += new System.EventHandler(this.logicalQueryChartToolStripMenuItem_CheckStateChanged);
            // 
            // writeQueryChartToolStripMenuItem
            // 
            this.writeQueryChartToolStripMenuItem.CheckOnClick = true;
            this.writeQueryChartToolStripMenuItem.Name = "writeQueryChartToolStripMenuItem";
            this.writeQueryChartToolStripMenuItem.Size = new System.Drawing.Size(184, 22);
            this.writeQueryChartToolStripMenuItem.Text = "Write Query Chart";
            this.writeQueryChartToolStripMenuItem.CheckStateChanged += new System.EventHandler(this.writeQueryChartToolStripMenuItem_CheckStateChanged);
            // 
            // rowCounterChartToolStripMenuItem
            // 
            this.rowCounterChartToolStripMenuItem.CheckOnClick = true;
            this.rowCounterChartToolStripMenuItem.Name = "rowCounterChartToolStripMenuItem";
            this.rowCounterChartToolStripMenuItem.Size = new System.Drawing.Size(184, 22);
            this.rowCounterChartToolStripMenuItem.Text = "Row Counter Chart";
            this.rowCounterChartToolStripMenuItem.CheckStateChanged += new System.EventHandler(this.rowCounterChartToolStripMenuItem_CheckStateChanged);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(181, 6);
            // 
            // mnShowDataLabel
            // 
            this.mnShowDataLabel.CheckOnClick = true;
            this.mnShowDataLabel.Name = "mnShowDataLabel";
            this.mnShowDataLabel.Size = new System.Drawing.Size(184, 22);
            this.mnShowDataLabel.Text = "Show Data Label";
            // 
            // pnlCounterSection
            // 
            this.pnlCounterSection.Controls.Add(this.splitter1);
            this.pnlCounterSection.Controls.Add(this.pnlButton);
            this.pnlCounterSection.Controls.Add(this.pnlCounterList);
            this.pnlCounterSection.Controls.Add(this.spSelectedCounters);
            this.pnlCounterSection.Controls.Add(this.dgvSelectedCounters);
            this.pnlCounterSection.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlCounterSection.Location = new System.Drawing.Point(0, 143);
            this.pnlCounterSection.Name = "pnlCounterSection";
            this.pnlCounterSection.Size = new System.Drawing.Size(868, 249);
            this.pnlCounterSection.TabIndex = 6;
            // 
            // splitter1
            // 
            this.splitter1.Location = new System.Drawing.Point(217, 0);
            this.splitter1.Name = "splitter1";
            this.splitter1.Size = new System.Drawing.Size(3, 249);
            this.splitter1.TabIndex = 7;
            this.splitter1.TabStop = false;
            // 
            // pnlButton
            // 
            this.pnlButton.Controls.Add(this.btnAdd);
            this.pnlButton.Controls.Add(this.btnRemove);
            this.pnlButton.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlButton.Location = new System.Drawing.Point(217, 0);
            this.pnlButton.Name = "pnlButton";
            this.pnlButton.Size = new System.Drawing.Size(91, 249);
            this.pnlButton.TabIndex = 6;
            // 
            // btnAdd
            // 
            this.btnAdd.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnAdd.Location = new System.Drawing.Point(9, 3);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Size = new System.Drawing.Size(75, 38);
            this.btnAdd.TabIndex = 4;
            this.btnAdd.Text = ">";
            this.btnAdd.UseVisualStyleBackColor = true;
            this.btnAdd.Click += new System.EventHandler(this.btnAdd_Click);
            // 
            // btnRemove
            // 
            this.btnRemove.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnRemove.Location = new System.Drawing.Point(9, 47);
            this.btnRemove.Name = "btnRemove";
            this.btnRemove.Size = new System.Drawing.Size(75, 38);
            this.btnRemove.TabIndex = 5;
            this.btnRemove.Text = "<";
            this.btnRemove.UseVisualStyleBackColor = true;
            this.btnRemove.Click += new System.EventHandler(this.btnRemove_Click);
            // 
            // pnlCounterList
            // 
            this.pnlCounterList.Controls.Add(this.lbCounters);
            this.pnlCounterList.Controls.Add(this.txtCounterSearch);
            this.pnlCounterList.Dock = System.Windows.Forms.DockStyle.Left;
            this.pnlCounterList.Location = new System.Drawing.Point(0, 0);
            this.pnlCounterList.Name = "pnlCounterList";
            this.pnlCounterList.Size = new System.Drawing.Size(217, 249);
            this.pnlCounterList.TabIndex = 6;
            // 
            // lbCounters
            // 
            this.lbCounters.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lbCounters.FormattingEnabled = true;
            this.lbCounters.Location = new System.Drawing.Point(0, 20);
            this.lbCounters.Name = "lbCounters";
            this.lbCounters.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
            this.lbCounters.Size = new System.Drawing.Size(217, 229);
            this.lbCounters.TabIndex = 7;
            this.lbCounters.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.lbCounters_MouseDoubleClick);
            // 
            // txtCounterSearch
            // 
            this.txtCounterSearch.Dock = System.Windows.Forms.DockStyle.Top;
            this.txtCounterSearch.Location = new System.Drawing.Point(0, 0);
            this.txtCounterSearch.Name = "txtCounterSearch";
            this.txtCounterSearch.Size = new System.Drawing.Size(217, 20);
            this.txtCounterSearch.TabIndex = 8;
            this.txtCounterSearch.TextChanged += new System.EventHandler(this.txtCounterSearch_TextChanged);
            // 
            // spSelectedCounters
            // 
            this.spSelectedCounters.Dock = System.Windows.Forms.DockStyle.Right;
            this.spSelectedCounters.Location = new System.Drawing.Point(308, 0);
            this.spSelectedCounters.Name = "spSelectedCounters";
            this.spSelectedCounters.Size = new System.Drawing.Size(3, 249);
            this.spSelectedCounters.TabIndex = 2;
            this.spSelectedCounters.TabStop = false;
            // 
            // dgvSelectedCounters
            // 
            this.dgvSelectedCounters.AllowUserToAddRows = false;
            this.dgvSelectedCounters.AllowUserToDeleteRows = false;
            this.dgvSelectedCounters.AllowUserToResizeRows = false;
            this.dgvSelectedCounters.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSelectedCounters.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.CounterName,
            this.Scale,
            this.MaxValue,
            this.MinValue});
            this.dgvSelectedCounters.Dock = System.Windows.Forms.DockStyle.Right;
            this.dgvSelectedCounters.Location = new System.Drawing.Point(311, 0);
            this.dgvSelectedCounters.Name = "dgvSelectedCounters";
            this.dgvSelectedCounters.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvSelectedCounters.Size = new System.Drawing.Size(557, 249);
            this.dgvSelectedCounters.TabIndex = 1;
            this.dgvSelectedCounters.SelectionChanged += new System.EventHandler(this.dgvSelectedCounters_SelectionChanged);
            // 
            // CounterName
            // 
            this.CounterName.HeaderText = "CounterName";
            this.CounterName.MinimumWidth = 200;
            this.CounterName.Name = "CounterName";
            this.CounterName.Width = 250;
            // 
            // Scale
            // 
            this.Scale.HeaderText = "Scale";
            this.Scale.Name = "Scale";
            // 
            // MaxValue
            // 
            this.MaxValue.HeaderText = "Max Value";
            this.MaxValue.Name = "MaxValue";
            // 
            // MinValue
            // 
            this.MinValue.HeaderText = "Min Value";
            this.MinValue.Name = "MinValue";
            // 
            // spChart
            // 
            this.spChart.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.spChart.Location = new System.Drawing.Point(0, 140);
            this.spChart.Name = "spChart";
            this.spChart.Size = new System.Drawing.Size(868, 3);
            this.spChart.TabIndex = 7;
            this.spChart.TabStop = false;
            // 
            // frmPerfMonQueries
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(868, 605);
            this.Controls.Add(this.chart1);
            this.Controls.Add(this.spChart);
            this.Controls.Add(this.pnlCounterSection);
            this.Controls.Add(this.spQueryGrid);
            this.Controls.Add(this.dgvQuery);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "frmPerfMonQueries";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Performance Counters and Queries";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.frmPerfMonQueries_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dgvQuery)).EndInit();
            this.cmsQuery.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).EndInit();
            this.cmdChartMenu.ResumeLayout(false);
            this.pnlCounterSection.ResumeLayout(false);
            this.pnlButton.ResumeLayout(false);
            this.pnlCounterList.ResumeLayout(false);
            this.pnlCounterList.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSelectedCounters)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.DataGridView dgvQuery;
        private System.Windows.Forms.Splitter spQueryGrid;
        private System.Windows.Forms.DataVisualization.Charting.Chart chart1;
        private System.Windows.Forms.Panel pnlCounterSection;
        private System.Windows.Forms.Splitter spChart;
        private System.Windows.Forms.Splitter spSelectedCounters;
        private System.Windows.Forms.DataGridView dgvSelectedCounters;
        private System.Windows.Forms.Button btnRemove;
        private System.Windows.Forms.Button btnAdd;
        private System.Windows.Forms.Panel pnlButton;
        private System.Windows.Forms.ListBox lbCounters;
        private System.Windows.Forms.DataGridViewTextBoxColumn CounterName;
        private System.Windows.Forms.DataGridViewTextBoxColumn Scale;
        private System.Windows.Forms.DataGridViewTextBoxColumn MaxValue;
        private System.Windows.Forms.DataGridViewTextBoxColumn MinValue;
        private System.Windows.Forms.ContextMenuStrip cmsQuery;
        private System.Windows.Forms.ToolStripMenuItem showEventsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem mapPerformanceCounterToolStripMenuItem;
        private System.Windows.Forms.ContextMenuStrip cmdChartMenu;
        private System.Windows.Forms.ToolStripMenuItem cPUQueryChartToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem durationQueryChatToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem physicalQueryChartToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem logicalQueryChartToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem writeQueryChartToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem rowCounterChartToolStripMenuItem;
        private System.Windows.Forms.Panel pnlCounterList;
        private System.Windows.Forms.TextBox txtCounterSearch;
        private System.Windows.Forms.Splitter splitter1;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem mnShowDataLabel;
    }
}