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
using System.IO;
using System.Diagnostics;

namespace SQL_PTO_Report
{
    public partial class ExpensiveQueriesAndPlans : Form
    {
        public ExpensiveQueriesAndPlans()
        {
            InitializeComponent();
        }

        public string DatabaseName;
        string strQueryType = "CPU";
        string queryId;
        string activityId;
        string strCurrentPlanFolder;


        private void ExpensiveQueriesAndPlans_Load(object sender, EventArgs e)
        {
            strQueryType = "CPU";
            LoadQueries();

        }

        private void cPUToolStripMenuItem_Click(object sender, EventArgs e)
        {
            strQueryType = "CPU";
            LoadQueries();
        }

        private void LoadQueries()
        {
            btnQueryType.Text = "Query Type: " + strQueryType;
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
            {
                con.Open();
                con.ChangeDatabase(DatabaseName);
                using (SqlCommand cmd = con.CreateCommand())
                {
                    switch  (strQueryType)
                    {
                        case "CPU":
                            cmd.CommandText = @"select * from xel.expensive_query_stats_cpu where query_id <11 order by query_id";
                            break;
                        case "Duration":
                            cmd.CommandText = @"select * from xel.expensive_query_stats_duration where rate <11 order by rate";
                            break;
                        case "Physical Reads":
                            cmd.CommandText = @"select * from xel.expensive_query_stats_physical_reads where rate <11 order by rate";
                            break;
                        case "Logical Reads":
                            cmd.CommandText = @"select * from xel.expensive_query_stats_logical_reads where rate <11 order by rate";
                            break;
                        case "Row Count":
                            cmd.CommandText = @"select * from xel.expensive_query_stats_row_count where rate <11 order by rate";
                            break;
                        case "Writes":
                            cmd.CommandText = @"select * from xel.expensive_query_stats_writes where rate <11 order by rate";
                            break;
                    }
                    SqlDataReader reader = cmd.ExecuteReader();
                    DataTable dtQuery = new DataTable();
                    dtQuery.Load(reader);
                    dgvQuery.DataSource = dtQuery;
                    dgvQuery.Refresh();
                }
            }
        }

        private void durationToolStripMenuItem_Click(object sender, EventArgs e)
        {
            strQueryType = "Duration";
            LoadQueries();
        }

        private void physicalReadsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            strQueryType = "Physical Reads";
            LoadQueries();
        }

        private void logicalReadsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            strQueryType = "Logical Reads";
            LoadQueries();
        }

        private void rowsReturnedToolStripMenuItem_Click(object sender, EventArgs e)
        {
            strQueryType = "Row Count";
            LoadQueries();
        }

        private void writesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            strQueryType = "Writes";
            LoadQueries();
        }

        private void dgvQuery_SelectionChanged(object sender, EventArgs e)
        {
            if (dgvQuery.Rows.Count > 0)
            {
                queryId = dgvQuery.CurrentRow.Cells["query_id"].Value.ToString();

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"select query_id, left(a.attach_activity_id,36) as attach_activity_id 
                            INTO #1
                            from xel.expensive_query_attach_activity_id a 
                            WHERE query_id = " + queryId + @" ;

                            Select left(p.a_attach_activity_id,36) AS a_attach_activity_id,COUNT(*) as num_of_plans
                            INTO #2
                            FROM [xel].[query_post_execution_showplan] p 
                            GROUP BY p.a_attach_activity_id;

                            select query_id, attach_activity_id 
                            , p.num_of_plans
                            from #1 a INNER HASH JOIN #2 p ON a.attach_activity_id = p.a_attach_activity_id  
                            Order by num_of_plans DESC;";
                        cmd.CommandTimeout = 0;
                        SqlDataReader reader = cmd.ExecuteReader();
                        DataTable dtActivities = new DataTable();
                        dtActivities.Load(reader);
                        dgvActivities.DataSource = dtActivities;
                        dgvActivities.Refresh();
                    }
                }
            }
        }

        private void ListPlanEvents()
        {
            if (dgvActivities.Rows.Count > 0)
            {
                activityId = dgvActivities.CurrentRow.Cells["attach_activity_id"].Value.ToString();

                string strSelectQuery = @"select * from xel.expensive_query_detailed_events where attach_id = '" + activityId + "' Order BY cast(activity_id as bigint)";

                if (btnShowPlanOnly.Checked)
                {
                    strSelectQuery = @"select * from xel.expensive_query_detailed_events where attach_id = '" + activityId + "' and event ='query_post_execution_showplan' Order BY cast(activity_id as bigint)";
                }

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString))
                {
                    con.Open();
                    con.ChangeDatabase(DatabaseName);
                    using (SqlCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = strSelectQuery;
                        SqlDataReader reader = cmd.ExecuteReader();
                        DataTable dtEvent = new DataTable();
                        dtEvent.Load(reader);

                        if (dtEvent.Rows.Count == 0)
                        {
                            cmd.CommandText = @"insert into xel.expensive_query_detailed_events
                                    select " + queryId + " , activity_id, event,EventData,attach_id,duration from dbo.ufn_ListQueryActivity('" + activityId + "[1]')";
                            cmd.CommandTimeout = 0;
                            this.UseWaitCursor = true;
                            cmd.ExecuteNonQuery();
                            cmd.CommandText = strSelectQuery;
                            reader = cmd.ExecuteReader();
                            dtEvent = new DataTable();
                            dtEvent.Load(reader);
                            this.UseWaitCursor = false;

                        }
                        dgvEvents.DataSource = dtEvent;
                        dgvEvents.Refresh();
                    }
                }
            }
        }

        private void dgvActivities_SelectionChanged(object sender, EventArgs e)
        {
            ListPlanEvents();
        }

        private static DataSet SelectRows(DataSet dataset, string queryString)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString;
            using (SqlConnection connection =
                new SqlConnection(connectionString))
            {
                SqlDataAdapter adapter = new SqlDataAdapter();
                adapter.SelectCommand = new SqlCommand(queryString, connection);
                adapter.Fill(dataset);
                return dataset;
            }
        }

        private void ExportPlans(bool showFolder)
        {
            //Get plan folder
            string strFolder = ConfigurationManager.AppSettings["CollectedDataFolder"];
            using (DataSet dsFolder = new DataSet())
            {
                SelectRows(dsFolder, "select * from " + DatabaseName + ".dbo.SourceFileName");
                strCurrentPlanFolder = Path.Combine(strFolder, dsFolder.Tables[0].Rows[0][0].ToString() + "\\ExpensiveQueries\\" + queryId);
                strCurrentPlanFolder = Path.Combine(strCurrentPlanFolder, activityId);
            }

            //Prepare folder
            if (!Directory.Exists(strCurrentPlanFolder))
            {
                //Someetimes creating directory fails without error. Retry 3 times.
                int retryCount = 3;
                do
                {
                    Directory.CreateDirectory(strCurrentPlanFolder);
                    retryCount--;
                    if (!Directory.Exists(strCurrentPlanFolder)) { System.Threading.Thread.Sleep(2000); }
                }
                while (!Directory.Exists(strCurrentPlanFolder) || retryCount > 0);

                if (Directory.Exists(strCurrentPlanFolder))
                {
                    using (DataSet plans = new DataSet())
                    {
                        string planQuery = @"Select CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as Activity_ID
                    , c_object_type, c_showplan_xml from " + DatabaseName + @".
                    xel.query_post_execution_showplan
                    where left(a_attach_activity_id,36) = '" + activityId + "'";
                        SelectRows(plans, planQuery);
                        StreamWriter outputFile;
                        foreach (DataRow row in plans.Tables[0].Rows)
                        {
                            using (outputFile = new StreamWriter(Path.Combine(strCurrentPlanFolder, row[0].ToString()) + @".sqlplan"))
                            {
                                outputFile.Write(row[2].ToString());
                            }
                        }

                        if (plans.Tables[0].Rows.Count > 0 && showFolder)
                        {
                            Process.Start(strCurrentPlanFolder);
                        }
                    }
                }
                else
                {
                    MessageBox.Show("Creating folder failed. ActivityID is " + activityId + ". Query xel.query_post_execution_showplan table for query plans.");
                }
            }
        }


        private void btnExportPlan_Click(object sender, EventArgs e)
        {

            ExportPlans(true);


        }

        private void btnShowPlanOnly_CheckedChanged(object sender, EventArgs e)
        {
            ListPlanEvents();
        }

        private void dgvEvents_DoubleClick(object sender, EventArgs e)
        {
            if (dgvQuery.Rows.Count > 0)
            {
                if (dgvEvents.CurrentRow.Cells["event"].Value.ToString() == "query_post_execution_showplan")
                {
                    ExportPlans(false); //Generate plans without showing the folder
                    string activityId = dgvEvents.CurrentRow.Cells["activity_id"].Value.ToString();
                    Process.Start(Path.Combine(strCurrentPlanFolder, activityId + ".sqlplan"));
                }

            }
        }
    }
}
