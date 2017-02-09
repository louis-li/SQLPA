using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Configuration;
using System.Windows.Forms.DataVisualization.Charting;

namespace SQL_PTO_Report
{
    public partial class frmPerfMonQueries : Form
    {
        public string DatabaseName;
        private string selectedCounter = null;
        private Color selectedCounterColor;
        DataGridViewCellEventArgs mouseLocation;
        public Reports ReportForm;
        private DataTable dtCounterList;
        private DataPoint currentDP = null;
        public frmPerfMonQueries()
        {
            InitializeComponent();
        }
        private void LoadCounterData()
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
            {
                con.Open();
                con.ChangeDatabase(DatabaseName);
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"select distinct ObjectName + ':' + CounterName + '(' + ISNULL(InstanceName,'null') + ')' as CounterName from dbo.counterdetails ";
                    SqlDataReader reader = cmd.ExecuteReader();
                    dtCounterList = new DataTable();
                    dtCounterList.Load(reader);

                    lbCounters.DataSource = dtCounterList;
                    lbCounters.DisplayMember = "CounterName";
                    lbCounters.ValueMember = "CounterName";
                }
            }
        }

        private void LoadQueryData()
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
            {
                con.Open();
                con.ChangeDatabase(DatabaseName);
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
                    select * From xel.QueryHist
                    order by [Completed Time]  ";
                    SqlDataReader reader = cmd.ExecuteReader();
                    DataTable dt = new DataTable();
                    dt.Load(reader);
                    this.dgvQuery.DataSource = dt;
                    this.dgvQuery.Columns[0].Width = 120;
                    this.dgvQuery.Columns[1].Width = 120;
                    this.dgvQuery.Columns[2].Width = 500;
                    this.dgvQuery.Columns[9].Visible = false;
                    this.dgvQuery.Refresh();
                }
            }
        }
        private void frmPerfMonQueries_Load(object sender, EventArgs e)
        {
            //// Zoom into the X axis
            //chart1.ChartAreas[0].AxisX.ScaleView.Zoom(2, 3);

            //// Enable range selection and zooming end user interface
            chart1.ChartAreas[0].CursorX.IsUserEnabled = true;
            chart1.ChartAreas[0].CursorX.IsUserSelectionEnabled = true;
            chart1.ChartAreas[0].AxisX.ScaleView.Zoomable = true;
            chart1.ChartAreas[0].AxisX.ScrollBar.IsPositionedInside = true;
            //Cursor
            chart1.ChartAreas[0].CursorX.LineColor = Color.LightCoral;
            chart1.ChartAreas[0].CursorX.LineDashStyle = ChartDashStyle.Solid;
            chart1.ChartAreas[0].CursorX.LineWidth = 2;
            //Use minor gridline
            // Enable all elements
            chart1.ChartAreas[0].AxisX.MinorGrid.Enabled = true;
            chart1.ChartAreas[0].AxisX.MajorGrid.Enabled = true;
            chart1.ChartAreas[0].AxisX.MinorGrid.LineDashStyle = ChartDashStyle.Dash;
            chart1.ChartAreas[0].AxisX.MinorTickMark.Enabled = true;
            chart1.ChartAreas[0].AxisX.MajorGrid.LineColor = Color.DarkGray;
            chart1.ChartAreas[0].AxisX.MinorGrid.LineColor = Color.LightGray;
            chart1.ChartAreas[0].AxisX.LabelAutoFitMaxFontSize = 8;

            //Set Axis Y
            chart1.ChartAreas[0].AxisY.MajorGrid.LineColor = Color.DarkGray;
            chart1.ChartAreas[0].AxisY.MajorGrid.LineDashStyle = ChartDashStyle.Dash;
            //Set max Y to 100
            chart1.ChartAreas[0].AxisY.Maximum = 100;

            //
            chart1.ChartAreas[0].AxisY.LineDashStyle = ChartDashStyle.NotSet;

            // Set Back Color
            chart1.ChartAreas[0].BackColor = Color.LightGray;
            chart1.ChartAreas[0].BackSecondaryColor = Color.White;
            chart1.ChartAreas[0].BackGradientStyle = GradientStyle.TopBottom;

            // Set Border Color
            chart1.BorderColor = Color.DarkCyan;
            chart1.BorderlineDashStyle = ChartDashStyle.Solid;
            chart1.BorderWidth = 2;

            // Initialize Perf Counter List
            LoadCounterData();
            LoadQueryData();

            //lbCounters.Height = this.Height / 5;
            pnlButton.Height = this.Height / 5;
            pnlCounterList.Height = this.Height / 5;
            dgvSelectedCounters.Height = this.Height / 5;
            pnlCounterSection.Height = this.Height / 5;
            dgvQuery.Height = this.Height / 3;
            pnlCounterList.Width = 400;

            //Reposition grid
            dgvSelectedCounters.Width = this.Width - pnlCounterList.Width - btnAdd.Width -35;

            //Init tmp table for PerfQuery
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
            {
                con.Open();
                con.ChangeDatabase(DatabaseName);

                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
                        if exists (select * from sys.tables where name = 'tmpPerfQueryData')
                        Begin
	                        Truncate table dbo.tmpPerfQueryData
                        end
                        else
                        begin
	                        create table dbo.tmpPerfQueryData
	                        (CounterDateTime datetime2(7) not null,
	                        CounterValue float not null,
	                        CounterName varchar(500) not null
	                        )
                        end
                        ";
                    cmd.ExecuteNonQuery();
                }
            }

        }

        private void Add_PerfQuery_Data(string counterName,string scale)
        {
            //Init report
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
            {
                con.Open();
                con.ChangeDatabase(DatabaseName);

                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
                    Insert into dbo.tmpPerfQueryData
                    select left(counterdatetime,23) , countervalue * " + scale.ToString() + @" ,ObjectName + ':' + CounterName + '(' + ISNULL(InstanceName,'null') + ')' as [counter]
                    from 
	                    dbo.counterdetails cd inner join dbo.counterdata d
		                    on cd.counterid = d.counterId
                    where ObjectName + ':' + CounterName + '(' + ISNULL(InstanceName,'null') + ')' = '" + counterName + @"' 
                    order by counterdatetime";
                    cmd.ExecuteNonQuery();

                }
                ShowChart();
            }

        }

        private void ShowChart()
        {
            //Init report
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
            {
                con.Open();
                con.ChangeDatabase(DatabaseName);

                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"select cast(CounterDateTime as varchar(19)) as CounterDateTime
                        , CounterValue 
                        , CounterName
                        , CounterName + '\n' + cast(CounterDateTime as varchar(23)) +'(' + Cast(CounterValue as varchar(20)) +')' as tooltip
                        from dbo.tmpPerfQueryData
                        Order by CounterDateTime";

                    SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.CloseConnection);

                    //Clear Series before binding
                    string[] counters = new string[chart1.Series.Count];
                    int counterCnt = -1;
                    foreach (Series series in chart1.Series)
                    {
                        if (series.ChartArea == "Default")
                        {
                            counterCnt++;
                            counters[counterCnt] = series.Name;
                        }
                    }
                    //Clear series
                    for (int i = 0; i <= counterCnt; i++)
                    {
                        chart1.Series.Remove(chart1.Series.FindByName(counters[i]));
                    }

                    //Bind data
                    chart1.DataBindCrossTable(reader, "CounterName", "CounterDateTime", "CounterValue", "Tooltip=tooltip, Lable=CounterDateTime");
                    foreach (Series series in chart1.Series)
                    {
                        if (series.ChartArea == "Default")
                        {
                            series.ChartType = System.Windows.Forms.DataVisualization.Charting.SeriesChartType.Line;
                            series.BorderWidth = 2;
                        }
                    }
                    
                    //this.chart1.Refresh();
                }
            }
        }

        private void AddSelectedItemtoChart()
        {
            string counterName;
            string scaleString;
            string maxString;
            string minString;
            try
            {
                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    foreach (var item in lbCounters.SelectedItems)
                    {
                        counterName = (item as DataRowView)[0].ToString();
                        using (SqlCommand cmd = con.CreateCommand())
                        {
                            cmd.CommandText = @";With cteMaxCounterValue as
                            (Select max(countervalue) as MaxCounterValue
                            from dbo.CounterDetails cd inner join dbo.CounterData d on cd.CounterID = d.CounterID
                            where ObjectName + ':' + CounterName + '(' + ISNULL(InstanceName,'null') + ')' IN ( '" + counterName + @"')
                            ), cteCounterLen  as
                            (Select MaxCounterValue
                             , Case When MaxCounterValue >=1 Then cast(cast(MaxCounterValue/100 as bigint) as varchar(20))
                             ELSE  cast(cast(MaxCounterValue * 1000000 as bigint) / 100 as varchar(20))
                             End  as Length
                            from cteMaxCounterValue
                            )
                            Select Cast (Case 
                             When MaxCounterValue >=1 AND Length > 0 Then 1.0/Power(10,len(length) ) 
                             When MaxCounterValue >=1 AND Length = 0 Then 1
                             When MaxCounterValue <1 Then Power(10,6-len(length))
                             End as varchar(30)) as Scale
                            From cteCounterLen";


                            scaleString = cmd.ExecuteScalar().ToString();

                            //Show MAX
                            cmd.CommandText = @"Select max(countervalue) as MaxCounterValue
                            from dbo.CounterDetails cd inner join dbo.CounterData d on cd.CounterID = d.CounterID
                            where ObjectName + ':' + CounterName + '(' + ISNULL(InstanceName,'null') + ')' IN ( '" + counterName + @"')";
                            maxString = cmd.ExecuteScalar().ToString();

                            //Show MIN
                            cmd.CommandText = @"Select min(countervalue) as MaxCounterValue
                            from dbo.CounterDetails cd inner join dbo.CounterData d on cd.CounterID = d.CounterID
                            where ObjectName + ':' + CounterName + '(' + ISNULL(InstanceName,'null') + ')' IN ( '" + counterName + @"')";
                            minString = cmd.ExecuteScalar().ToString();

                            dgvSelectedCounters.Rows.Add(counterName, scaleString, maxString, minString);

                            Add_PerfQuery_Data(counterName, scaleString);
                        }

                        //construct a table as data source
                    }

                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error");
            }
        }
        private void btnAdd_Click(object sender, EventArgs e)
        {
            AddSelectedItemtoChart();
        }

        private void btnRemove_Click(object sender, EventArgs e)
        {
            string counterName;

            DataGridViewSelectedRowCollection selectedRows = dgvSelectedCounters.SelectedRows;
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
            {
                con.Open();
                con.ChangeDatabase(DatabaseName);
                foreach (DataGridViewRow row in selectedRows)
                {
                    counterName = row.Cells[0].Value.ToString();
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                        Delete from dbo.tmpPerfQueryData                        
	                    where CounterName = '" + counterName + "'";
                        cmd.ExecuteNonQuery();

                    }

                    dgvSelectedCounters.Rows.Remove(row);
                }

                ShowChart();
            }
        }

        private void dgvSelectedCounters_SelectionChanged(object sender, EventArgs e)
        {
            if (dgvSelectedCounters.Rows.Count > 0)
            {
                string counterName = dgvSelectedCounters.CurrentRow.Cells["CounterName"].Value.ToString();

                if (chart1.Series.Count > 0)
                {
                    if (selectedCounter != null)
                    {
                        try
                        {
                            chart1.Series[selectedCounter].BorderWidth = 1;
                            foreach (System.Windows.Forms.DataVisualization.Charting.DataPoint dp in chart1.Series[selectedCounter].Points)
                            {
                                dp.MarkerStyle = MarkerStyle.None;
                                dp.Label = string.Empty;
                            }
                            dgvQuery.Refresh();
                        }
                        catch
                        {
                        }
                        //chart1.Series[counterName].Color = selectedCounterColor;

                    }
                    selectedCounter = counterName;
                    try
                    {
                        selectedCounterColor = chart1.Series[counterName].Color;
                    }
                    catch
                    {
                        DataGridViewRow deletedRow = null;
                        foreach (DataGridViewRow row in dgvSelectedCounters.Rows)
                        {
                            if (counterName == row.Cells[0].Value.ToString()) { deletedRow = row; }
                        }

                        if (deletedRow != null) { dgvSelectedCounters.Rows.Remove(deletedRow); }
                    }

                    try
                    {
                        chart1.Series[counterName].BorderWidth = 5;
                    }
                    catch { }
                }
            }
        }

        private void chart1_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            this.Cursor = Cursors.WaitCursor;
            // Call HitTest
            HitTestResult result = chart1.HitTest(e.X, e.Y);
            try
            {
                if (result.ChartArea.Name == "Default")
                {
                    //Look for a time point in query list
                    foreach (DataGridViewRow row in dgvQuery.Rows)
                    {
                        //
                        if (Convert.ToDateTime(row.Cells[1].Value.ToString()) > Convert.ToDateTime(((DataPoint)result.Object).AxisLabel))
                        {
                            dgvQuery.ClearSelection();
                            row.Selected = true;
                            dgvQuery.CurrentCell = row.Cells[0];
                            break;
                        }
                    }
                }
                else
                {
                    //DateTime.FromOADate(dp.YValues[0]).ToString()
                    foreach (DataGridViewRow row in dgvQuery.Rows)
                    {
                        if (string.Compare(row.Cells[9].Value.ToString(), ((DataPoint)result.Object).Tag.ToString(),true) == 0)
                        {
                            dgvQuery.ClearSelection();
                            row.Selected = true;
                            dgvQuery.CurrentCell = row.Cells[0];
                            break;
                        }
                    }
                }
            }
            catch
            { }
            finally
            {
                this.Cursor = Cursors.Default;
            }
        }

        private void MapPerformanceCounter(int rid)
        {
            if (rid >= 0)
            {
                DataGridViewRow row = dgvQuery.Rows[rid];
                //Get start and end time
                DateTime startTime = Convert.ToDateTime(row.Cells[0].Value);
                DateTime endTime = Convert.ToDateTime(row.Cells[1].Value);
                DateTime pointTime;
                foreach (DataPoint dp in chart1.Series[dgvSelectedCounters.SelectedRows[0].Cells[0].Value.ToString()].Points)
                {
                    pointTime = Convert.ToDateTime(dp.AxisLabel);
                    if (pointTime >= startTime && pointTime <= endTime)
                    {
                        double grey = 0.2 * dp.Color.R + 0.6 * dp.Color.G + 0.2 * dp.Color.B;
                        if (grey > 128)
                        {
                            dp.MarkerColor = Color.Yellow;
                        }
                        else { dp.MarkerColor = Color.Red; }

                        dp.MarkerStyle = MarkerStyle.Circle;
                        dp.MarkerBorderColor = Color.Black;
                        dp.MarkerBorderWidth = 2;
                        dp.MarkerSize = 10;
                        dp.Label = dp.AxisLabel.Substring(11, 8) + "(" + dp.YValues[0].ToString() + ")";
                    }
                    if (pointTime > endTime || pointTime < startTime)
                    {
                        dp.MarkerStyle = MarkerStyle.None;
                        dp.Label = string.Empty;
                    }
                }
            }
        }

        private void dgvQuery_CellMouseDoubleClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            MapPerformanceCounter(e.RowIndex);

        }

        private void mapPerformanceCounterToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MapPerformanceCounter(mouseLocation.RowIndex); 

        }

        private void dgvQuery_CellMouseEnter(object sender, DataGridViewCellEventArgs e)
        {
            mouseLocation = e;
        }

        private void showEventsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            
            ReportForm.ShowQueryEvents(dgvQuery.Rows[mouseLocation.RowIndex].Cells[9].Value.ToString());
            ReportForm.BringToFront();
        }
        private void addQueryChart(string name)
        {   //Add CPU queries
            if (chart1.ChartAreas.FindByName("Query") == null)
            {
                chart1.ChartAreas.Add("Query");
                //chart1.ChartAreas["Query"].AxisX.IsMarginVisible = false;
                chart1.ChartAreas["Query"].AxisY.IsMarginVisible = false;
                chart1.ChartAreas["Query"].AlignWithChartArea = "Default";
                chart1.ChartAreas["Query"].AlignmentOrientation = AreaAlignmentOrientations.Vertical;

                chart1.ChartAreas["Query"].AlignmentStyle = AreaAlignmentStyles.PlotPosition;
                chart1.ChartAreas["Query"].AxisY.LabelAutoFitMaxFontSize = 8;

                //chart1.ChartAreas["Query"].AxisY.MinorGrid.Enabled = true;
                chart1.ChartAreas["Query"].AxisY.MajorGrid.Enabled = true;
                chart1.ChartAreas["Query"].AxisY.MinorGrid.LineDashStyle = ChartDashStyle.Dash;
                //chart1.ChartAreas["Query"].AxisY.MinorTickMark.Enabled = true;
                chart1.ChartAreas["Query"].AxisY.MajorGrid.LineColor = Color.DarkGray;
                //chart1.ChartAreas["Query"].AxisY.MinorGrid.LineColor = Color.LightGray;
                chart1.ChartAreas["Query"].AxisY.LabelAutoFitMaxFontSize = 8;

                //Set Axis Y
                chart1.ChartAreas["Query"].AxisX.MajorGrid.LineColor = Color.DarkGray;
                chart1.ChartAreas["Query"].AxisX.MajorGrid.LineDashStyle = ChartDashStyle.Dash;
                //chart1.ChartAreas["Query"].AxisY.LabelStyle.IntervalType = DateTimeIntervalType.Minutes;
                chart1.ChartAreas["Query"].AxisY.IntervalType = DateTimeIntervalType.Minutes;
                chart1.ChartAreas["Query"].AxisY.IntervalAutoMode = IntervalAutoMode.VariableCount;
                chart1.ChartAreas["Query"].AxisY.Interval = 0;
                chart1.ChartAreas["Query"].AxisY.LabelStyle.Format = "HH:mm";

            }
            chart1.Series.Add(name);
            chart1.Series[name].ChartType = SeriesChartType.RangeBar;
            chart1.Series[name].ChartArea = "Query";
        }

        private void removeQueryChart(string name)
        {
            //Remove queries
            try
            {
                chart1.Series.Remove(chart1.Series[name]);
                if (chart1.Series.FindByName("CPU") == null &&
                    chart1.Series.FindByName("Duration") == null &&
                    chart1.Series.FindByName("Physical Read") == null &&
                    chart1.Series.FindByName("Logical Read") == null &&
                    chart1.Series.FindByName("Write") == null &&
                    chart1.Series.FindByName("Row Count") == null)
                chart1.ChartAreas.Remove(chart1.ChartAreas["Query"]);
            }
            catch { }
        }

        private void cPUQueryChartToolStripMenuItem_CheckStateChanged(object sender, EventArgs e)
        {
            string name = "CPU";
            if (cPUQueryChartToolStripMenuItem.Checked)
            {
                if (chart1.Series.FindByName("Query") == null)
                { addQueryChart(name); }

                DataTable dt = new DataTable();

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"select q.query_id, i.attach_activity_id, a.[Start Time], a.[Completed Time]
                                from xel.expensive_query_stats_cpu q
	                                inner join xel.expensive_query_attach_activity_id i on q.query_id = i.query_id
	                                inner join xel.QueryHist a on left(i.attach_activity_id,36) = left(a.a_attach_activity_id, 36)
                                order by query_id, [Start Time]";
                        SqlDataReader reader = cmd.ExecuteReader();
                        dt.Load(reader);
                    }
                }

                chart1.ChartAreas["Query"].AxisY.IsStartedFromZero = false;

                DataPoint dp = null;
                foreach (DataRow row in dt.Rows)
                {
                    dp = new DataPoint();
                    dp.SetValueXY(row["query_id"], row["Start Time"], row["Completed Time"]);
                    dp.ToolTip = Convert.ToDouble(row["query_id"]).ToString() + ":" + DateTime.FromOADate(dp.YValues[0]).ToString() + '-' + DateTime.FromOADate(dp.YValues[1]).ToString();
                    dp.Tag = row["attach_activity_id"];
                    chart1.Series[name].Points.Add(dp);
                }

            }
            else
            { removeQueryChart(name); }
        }

        private void durationQueryChatToolStripMenuItem_CheckStateChanged(object sender, EventArgs e)
        {
            string name = "Duration";
            if (durationQueryChatToolStripMenuItem.Checked)
            {
                if (chart1.Series.FindByName("Query") == null)
                { addQueryChart(name); }

                DataTable dt = new DataTable();

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"select q.rate,q.query_id, i.attach_activity_id, a.[Start Time], a.[Completed Time]
                                from xel.expensive_query_stats_duration q
	                                inner join xel.expensive_query_attach_activity_id i on q.query_id = i.query_id
	                                inner join xel.QueryHist a on left(i.attach_activity_id,36) = left(a.a_attach_activity_id, 36)
                                order by q.rate, [Start Time]";
                        SqlDataReader reader = cmd.ExecuteReader();
                        dt.Load(reader);

                    }
                }

                chart1.ChartAreas["Query"].AxisY.IsStartedFromZero = false;

                DataPoint dp = null;
                foreach (DataRow row in dt.Rows)
                {
                    dp = new DataPoint();
                    dp.SetValueXY(row["rate"], row["Start Time"], row["Completed Time"]);
                    dp.ToolTip = Convert.ToDouble(row["query_id"]).ToString() + ":" + DateTime.FromOADate(dp.YValues[0]).ToString() + '-' + DateTime.FromOADate(dp.YValues[1]).ToString();
                    dp.Tag = row["attach_activity_id"];
                    chart1.Series[name].Points.Add(dp);
                }

            }
            else
            { removeQueryChart(name); }
        }

        private void physicalQueryChartToolStripMenuItem_CheckStateChanged(object sender, EventArgs e)
        {
            string name = "Physical Read";
            if (physicalQueryChartToolStripMenuItem.Checked)
            {
                if (chart1.Series.FindByName("Query") == null)
                { addQueryChart(name); }

                DataTable dt = new DataTable();

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"Select q.rate,q.query_id, i.attach_activity_id, a.[Start Time], a.[Completed Time]
                                from xel.expensive_query_stats_physical_reads q
	                                inner join xel.expensive_query_attach_activity_id i on q.query_id = i.query_id
	                                inner join xel.QueryHist a on left(i.attach_activity_id,36) = left(a.a_attach_activity_id, 36)
                                order by q.rate, [Start Time]";
                        SqlDataReader reader = cmd.ExecuteReader();
                        dt.Load(reader);

                    }
                }

                chart1.ChartAreas["Query"].AxisY.IsStartedFromZero = false;

                DataPoint dp = null;
                foreach (DataRow row in dt.Rows)
                {
                    dp = new DataPoint();
                    dp.SetValueXY(row["rate"], row["Start Time"], row["Completed Time"]);
                    dp.ToolTip = Convert.ToDouble(row["query_id"]).ToString() + ":" + DateTime.FromOADate(dp.YValues[0]).ToString() + '-' + DateTime.FromOADate(dp.YValues[1]).ToString();
                    dp.Tag = row["attach_activity_id"];
                    chart1.Series[name].Points.Add(dp);
                }
            }
            else
            { removeQueryChart(name); }
        }

        private void logicalQueryChartToolStripMenuItem_CheckStateChanged(object sender, EventArgs e)
        {
            string name = "Logical Read";
            if (logicalQueryChartToolStripMenuItem.Checked)
            {
                if (chart1.Series.FindByName("Query") == null)
                { addQueryChart(name); }

                DataTable dt = new DataTable();

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"Select q.rate,q.query_id, i.attach_activity_id, a.[Start Time], a.[Completed Time]
                                from xel.expensive_query_stats_logical_reads q
	                                inner join xel.expensive_query_attach_activity_id i on q.query_id = i.query_id
	                                inner join xel.QueryHist a on left(i.attach_activity_id,36) = left(a.a_attach_activity_id, 36)
                                order by q.rate, [Start Time]";
                        SqlDataReader reader = cmd.ExecuteReader();
                        dt.Load(reader);

                    }
                }

                chart1.ChartAreas["Query"].AxisY.IsStartedFromZero = false;

                DataPoint dp = null;
                foreach (DataRow row in dt.Rows)
                {
                    dp = new DataPoint();
                    dp.SetValueXY(row["rate"], row["Start Time"], row["Completed Time"]);
                    dp.ToolTip = Convert.ToDouble(row["query_id"]).ToString() + ":" + DateTime.FromOADate(dp.YValues[0]).ToString() + '-' + DateTime.FromOADate(dp.YValues[1]).ToString();
                    dp.Tag = row["attach_activity_id"];
                    chart1.Series[name].Points.Add(dp);
                }
            }
            else
            { removeQueryChart(name); }
        }

        private void writeQueryChartToolStripMenuItem_CheckStateChanged(object sender, EventArgs e)
        {
            string name = "Write";
            if (writeQueryChartToolStripMenuItem.Checked)
            {
                if (chart1.Series.FindByName("Query") == null)
                { addQueryChart(name); }

                DataTable dt = new DataTable();

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"Select q.rate,q.query_id, i.attach_activity_id, a.[Start Time], a.[Completed Time]
                                from xel.expensive_query_stats_writes q
	                                inner join xel.expensive_query_attach_activity_id i on q.query_id = i.query_id
	                                inner join xel.QueryHist a on left(i.attach_activity_id,36) = left(a.a_attach_activity_id, 36)
                                order by q.rate, [Start Time]";
                        SqlDataReader reader = cmd.ExecuteReader();
                        dt.Load(reader);

                    }
                }

                chart1.ChartAreas["Query"].AxisY.IsStartedFromZero = false;

                DataPoint dp = null;
                foreach (DataRow row in dt.Rows)
                {
                    dp = new DataPoint();
                    dp.SetValueXY(row["rate"], row["Start Time"], row["Completed Time"]);
                    dp.ToolTip = Convert.ToDouble(row["query_id"]).ToString() + ":" + DateTime.FromOADate(dp.YValues[0]).ToString() + '-' + DateTime.FromOADate(dp.YValues[1]).ToString();
                    dp.Tag = row["attach_activity_id"];
                    chart1.Series[name].Points.Add(dp);
                }
            }
            else
            { removeQueryChart(name); }
        }

        private void rowCounterChartToolStripMenuItem_CheckStateChanged(object sender, EventArgs e)
        {
            string name = "Row Count";
            if (rowCounterChartToolStripMenuItem.Checked)
            {
                if (chart1.Series.FindByName("Query") == null)
                { addQueryChart(name); }

                DataTable dt = new DataTable();

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"Select q.rate,q.query_id, i.attach_activity_id, a.[Start Time], a.[Completed Time]
                                from xel.expensive_query_stats_row_count q
	                                inner join xel.expensive_query_attach_activity_id i on q.query_id = i.query_id
	                                inner join xel.QueryHist a on left(i.attach_activity_id,36) = left(a.a_attach_activity_id, 36)
                                order by q.rate, [Start Time]";
                        SqlDataReader reader = cmd.ExecuteReader();
                        dt.Load(reader);

                    }
                }

                chart1.ChartAreas["Query"].AxisY.IsStartedFromZero = false;

                DataPoint dp = null;
                foreach (DataRow row in dt.Rows)
                {
                    dp = new DataPoint();
                    dp.SetValueXY(row["rate"], row["Start Time"], row["Completed Time"]);
                    dp.ToolTip = Convert.ToDouble(row["query_id"]).ToString() + ":" + DateTime.FromOADate(dp.YValues[0]).ToString() + '-' + DateTime.FromOADate(dp.YValues[1]).ToString();
                    dp.Tag = row["attach_activity_id"];
                    chart1.Series[name].Points.Add(dp);
                }
            }
            else
            { removeQueryChart(name); }
        }

        private void txtCounterSearch_TextChanged(object sender, EventArgs e)
        {
            string filter = "CounterName like '%" + txtCounterSearch.Text + "%'";
            lbCounters.DataSource = dtCounterList.Select(filter);
            lbCounters.DataSource = new DataView(dtCounterList, filter, "CounterName", DataViewRowState.CurrentRows);
            lbCounters.DisplayMember = "CounterName";

        }

        private void lbCounters_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            AddSelectedItemtoChart();
        }

        private void chart1_MouseMove(object sender, MouseEventArgs e)
        {
            // Call Hit Test Method
            HitTestResult result = chart1.HitTest(e.X, e.Y);

            if (result.ChartElementType == ChartElementType.DataPoint && mnShowDataLabel.Checked)
            {
                DataPoint dp = (DataPoint)result.Object;

                if (dp != null)
                {
                    dp.MarkerStyle = MarkerStyle.Triangle;
                    dp.MarkerBorderColor = Color.DarkBlue;
                    dp.MarkerColor = Color.Yellow;
                    dp.MarkerBorderWidth = 2;
                    dp.MarkerSize = 10;
                    dp.Label = dp.ToolTip;
                    //dp.AxisLabel.Substring(11, 8) + "(" + dp.YValues[0].ToString() + ")";

                    if (currentDP != null && currentDP != dp)
                    {
                        currentDP.MarkerStyle = MarkerStyle.None;
                        currentDP.Label = string.Empty;
                        currentDP.Dispose();
                        currentDP = null;
                    }
                    currentDP = dp;
                }
            }

        }
    }
}
