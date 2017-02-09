using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using SQL_PTO_Report.localhost;
using System.Text.RegularExpressions;
using System.IO;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Diagnostics;
using Microsoft.Reporting.WinForms;

namespace SQL_PTO_Report
{
    public partial class Reports : Form
    {
        private DataSet dsDatabases ;
        private IAsyncResult asyncResult;
        PowerShell PowerShellInstance;
        frmPerfMonQueries frmPerfQuery = null;
        private string SSRSWS = ConfigurationManager.AppSettings["ReportingServiceWS"];

        public void ShowQueryEvents(string ActivityID)
        {
            this.reportViewer1.Reset();
            this.reportViewer1.ServerReport.ReportPath = "/SQLPTOReports/xEvents_QueryEventListByActivityID";
            ReportParameter activityId = new ReportParameter();
            activityId.Name = "ActivityID";
            activityId.Values.Add(ActivityID);

            // Set the report parameters for the report  
            reportViewer1.ServerReport.SetParameters(
                new ReportParameter[] { activityId });

            this.reportViewer1.RefreshReport();
            string strCurrentPlanFolder;

            //Get plan folder
            string strFolder = ConfigurationManager.AppSettings["CollectedDataFolder"];
            using (DataSet dsFolder = new DataSet())
            {
                SelectRows(dsFolder, "select * from " + sbDbNames.Text + ".dbo.SourceFileName");
                strCurrentPlanFolder = Path.Combine(strFolder, dsFolder.Tables[0].Rows[0][0].ToString());
                strCurrentPlanFolder = Path.Combine(strCurrentPlanFolder, ActivityID.Substring(0, 36));
            }

            //Prepare folder
            if (Directory.Exists(strCurrentPlanFolder))
            {
                try
                {
                    Directory.Delete(strCurrentPlanFolder, true);
                }
                catch (Exception ex)
                { MessageBox.Show(ex.Message); }
            }

            //Someetimes creating directory fails without error. Retry 3 times.
            int retryCount = 3;
            do
            {
                Directory.CreateDirectory(strCurrentPlanFolder);
                retryCount--;
                if (!Directory.Exists(strCurrentPlanFolder)) { System.Threading.Thread.Sleep(2000); }
            }
            while (!Directory.Exists(strCurrentPlanFolder) || retryCount >0);

            if (Directory.Exists(strCurrentPlanFolder))
            {
                using (DataSet plans = new DataSet())
                {
                    string planQuery = @"Select CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as Activity_ID
                    , c_object_type, c_showplan_xml from " + sbDbNames.Text + @".
                    xel.query_post_execution_showplan
                    where left(a_attach_activity_id,36) = '" + ActivityID.Substring(0, 36) + "'";
                    SelectRows(plans, planQuery);
                    StreamWriter outputFile;
                    foreach (DataRow row in plans.Tables[0].Rows)
                    {
                        using (outputFile = new StreamWriter(Path.Combine(strCurrentPlanFolder, row[0].ToString()) + @".sqlplan"))
                        {
                            outputFile.Write(row[2].ToString());
                        }
                    }

                    if (plans.Tables[0].Rows.Count > 0)
                    {
                        OpenFolder(ActivityID.Substring(0, 36));
                    }
                }
            }
            else
            {
                MessageBox.Show("Creating folder failed. ActivityID is " + ActivityID.Substring(0, 36) + ". Query xel.query_post_execution_showplan table for query plans.");
            }
            
        }
        public Reports()
        {
            InitializeComponent();
        }
        private static DataSet SelectRows(DataSet dataset,  string queryString)
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

        private void BindDbNames()
        {
            dsDatabases = new DataSet();
            //Load database name into ComboBox
            SelectRows(dsDatabases, "Select name from sys.databases where name like 'SQLPTO_%' AND name <> 'SQLPTOSummary' Order By name");
            //toolStripDropDownButton1.da
            cbDbNames.ComboBox.Width = 170;
            cbDbNames.ComboBox.DataSource = dsDatabases.Tables[0];
            cbDbNames.ComboBox.DisplayMember = "name";
            cbDbNames.ComboBox.BindingContext = this.BindingContext;

        }
        private void Form1_Load(object sender, EventArgs e)
        {
            try
            {
                //Maximum Form
                this.WindowState = FormWindowState.Maximized;

                //Show Splash screen
                panel1.Left = (this.Size.Width - panel1.Size.Width) / 2;
                panel1.Top = (this.Size.Height - panel1.Size.Height) / 2;
                panel1.Visible = true;
                timer2.Enabled = true;

                BindDbNames();

                //Get current database name
                sbDbNames.Text = GetPTODataSource();

                if (string.IsNullOrEmpty(sbDbNames.Text))
                {
                    DialogResult result = MessageBox.Show("SQLPTO data source has not been detected. A ReportServer database restore could help. Do you want to continue? ",
                        "ReportServer Restore", MessageBoxButtons.YesNo);
                    if (result == DialogResult.Yes)
                    {
                        ImportReports();

                    }

                    //Get SQLPTO Data Source again
                    sbDbNames.Text = GetPTODataSource();

                }

                //Load default report
                RefreshReport();

                //Set ComboBox Value
                //int index = 0;
                //foreach (DataRow dr in dsDatabases.Tables[0].Rows)
                //{
                //    if (dr.ItemArray[0].ToString() == sbDbNames.Text)
                //    {
                //        cbDbNames.SelectedIndex = index;
                //        break;
                //    }
                //    else { index++; }
                //}
                UpdateDataFolder();

                timer1.Enabled = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), "Error Initializing");
            }

        }

        private void UpdateDataFolder()
        {
            string strFolder = ConfigurationManager.AppSettings["CollectedDataFolder"];
            miCollectedData.Text = "Data Folder: " + strFolder + " (Click to change)";
            tssbLoadData.Text = "Load Data - " + strFolder;

        }

        private void cbDbNames_SelectedIndexChanged(object sender, EventArgs e)
        {
            sbDbNames.Text = ((DataTable)cbDbNames.ComboBox.DataSource).Rows[cbDbNames.SelectedIndex].ItemArray[0].ToString();
            SetPTODataSource(sbDbNames.Text);

            //Workaround to refresh report
            this.reportViewer1.Reset();
            this.reportViewer1.ServerReport.ReportPath = "/SQLPTOReports/SystemInfo";
            this.reportViewer1.RefreshReport();
            RefreshReport();

            //Close PerfQuery window if it's open
            if (frmPerfQuery != null )
            {
                frmPerfQuery.Close();
                frmPerfQuery.Dispose();
                frmPerfQuery = null;
            }

            //cbDbNames.ComboBox.Hide();
            reportViewer1.Focus();
        }

        private string GetPTODataSource()
        {
            ReportingService2010 rs = new ReportingService2010();
            rs.Url = "http://localhost/ReportServer/ReportService2010.asmx";
            rs.Credentials = System.Net.CredentialCache.DefaultCredentials;

            DataSourceDefinition definition = null;

            try
            {
                definition = rs.GetDataSourceContents("/Data Sources/SQLPTO");
                //Data Source=localhost;Initial Catalog=SQLPTO_08222016_163532
                Match m = Regex.Match(definition.ConnectString, "Catalog=(.+)", RegexOptions.CultureInvariant);
                return m.Groups[1].Value;

            }
            catch 
            {
                //Console.WriteLine(e.Detail.InnerXml.ToString());
                return string.Empty;
            }
        }

        private void SetPTODataSource(string DbName)
        {
            ReportingService2010 rs = new ReportingService2010();
            rs.Url = SSRSWS;
            rs.Credentials = System.Net.CredentialCache.DefaultCredentials;

            DataSourceDefinition definition = new DataSourceDefinition();
            definition.CredentialRetrieval = CredentialRetrievalEnum.Integrated;
            definition.ConnectString = "Data Source=(local);Initial Catalog=" + DbName;
            definition.Enabled = true;
            definition.EnabledSpecified = true;
            definition.Extension = "SQL";
            definition.ImpersonateUser = false;
            definition.ImpersonateUserSpecified = true;
            definition.Prompt = null;
            definition.WindowsCredentials = false;

            try
            {
                rs.SetDataSourceContents("/Data Sources/SQLPTO", definition);
            }
            catch
            {
                //Console.WriteLine(e.Detail.OuterXml);
            }

        }

        private void sbDbNames_ButtonClick(object sender, EventArgs e)
        {
            RefreshReport();
        }

        private void RefreshReport()
        {
            this.reportViewer1.Reset();
            this.reportViewer1.ServerReport.ReportPath = "/SQLPTOReports/Dashboard";
            this.reportViewer1.RefreshReport();
        }

        private void showSummaryReport()
        {
            this.reportViewer1.Reset();
            this.reportViewer1.ServerReport.ReportPath = "/SQLPTOSummaryReports/_Dashboard";
            this.reportViewer1.RefreshReport();

        }
        private void toolStripSplitButton1_ButtonClick(object sender, EventArgs e)
        {
            showSummaryReport();
        }

        private void toolStripMenuItem1_Click(object sender, EventArgs e)
        {
            using (CompareDatabase frmCompare = new CompareDatabase())
            {
                frmCompare.Databases = dsDatabases;
                
                frmCompare.ShowDialog();
            }
            showSummaryReport();
        }

        private void miCollectedData_Click(object sender, EventArgs e)
        {
            using (Configuration frmConfig = new Configuration())
            {
                frmConfig.Folder = ConfigurationManager.AppSettings["CollectedDataFolder"];

                frmConfig.ShowDialog();
            }
            UpdateDataFolder();
        }

        private void tssbLoadData_ButtonClick(object sender, EventArgs e)
        {
            //Scan data and load
            string psScript;
            string strLocation = System.Reflection.Assembly.GetExecutingAssembly().Location;
            // Open the file to read from.
            using (StreamReader sr = new StreamReader(System.IO.Path.Combine(System.IO.Path.GetDirectoryName(strLocation), "PTO_DataImport.ps1")))
            {
                // Read the stream to a string, and write the string to the console.
                psScript = sr.ReadToEnd();
            }


            if (PowerShellInstance == null) { PowerShellInstance = PowerShell.Create(); };
            // use "AddScript" to add the contents of a script file to the end of the execution pipeline.
            // use "AddCommand" to add individual commands/cmdlets to the end of the execution pipeline.
            PowerShellInstance.AddScript(psScript);

            // use "AddParameter" to add a single parameter to the last command/script on the pipeline.
            PowerShellInstance.AddParameter("InstanceName", "localhost");
            PowerShellInstance.AddParameter("Database", "SQLPTO");
            PowerShellInstance.AddParameter("CollectedDataFolder", ConfigurationManager.AppSettings["CollectedDataFolder"]);
            PowerShellInstance.AddParameter("CurrentLocation", System.IO.Path.GetDirectoryName(strLocation));
            //PowerShellInstance.AddParameter("DropExisting", Boolean.TrueString);

            // invoke execution on the pipeline (collecting output)
            asyncResult = PowerShellInstance.BeginInvoke();
            timer1.Enabled = true;
            tssbLoadData.Enabled = false;
            tsslStatus.Text = "Data Loading...";

            // loop through each output object item
            //foreach (PSObject outputItem in PSOutput)
            //{
            //    // if null object was dumped to the pipeline during the script then a null
            //    // object may be present here. check for null to prevent potential NRE.
            //    if (outputItem != null)
            //    {
            //        //TODO: do something with the output item 
            //        // outputItem.BaseOBject
            //    }
            //}

        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (asyncResult != null & asyncResult.IsCompleted == true)
            {
                tssbLoadData.Enabled = true;
                timer1.Enabled = false;
                PowerShellInstance.Dispose();
                PowerShellInstance = null;
                tsslStatus.Text = "Data Loading Completed.";

                //Bind DB names
                BindDbNames();
            }
        }

        private void ImportReports()
        {
            this.Cursor = Cursors.WaitCursor;
            string connectionString = ConfigurationManager.ConnectionStrings["SQL_PTO_Report.Properties.Settings.SQLPTOConnectionString"].ConnectionString;

            //Create SQLPTO Data Source
            ReportingService2010 rs = new ReportingService2010();
            rs.Url = SSRSWS;
            rs.Credentials = System.Net.CredentialCache.DefaultCredentials;

            try
            {
                rs.CreateFolder("Data Sources", @"/", null);
            }
            catch { }

            try
            {
                rs.CreateFolder("SQLPTOReports", @"/", null);
            }
            catch { }

            try
            {
                rs.CreateFolder("SQLPTOSummaryReports", @"/", null);
            }
            catch { }

            DataSourceDefinition definition = new DataSourceDefinition();
            definition.CredentialRetrieval = CredentialRetrievalEnum.Integrated;
            definition.ConnectString = "Data Source=(local);Initial Catalog=SQLPTO";
            definition.Enabled = true;
            definition.EnabledSpecified = true;
            definition.Extension = "SQL";
            definition.ImpersonateUser = false;
            definition.ImpersonateUserSpecified = true;
            definition.Prompt = null;
            definition.WindowsCredentials = false;

            rs.CreateDataSource("SQLPTO", @"/Data Sources", true, definition,null);

            //Create SQLPTOSummary Data Source

            DataSourceDefinition definitionsum = new DataSourceDefinition();
            definitionsum.CredentialRetrieval = CredentialRetrievalEnum.Integrated;
            definitionsum.ConnectString = "Data Source=(local);Initial Catalog=SQLPTOSummary";
            definitionsum.Enabled = true;
            definitionsum.EnabledSpecified = true;
            definitionsum.Extension = "SQL";
            definitionsum.ImpersonateUser = false;
            definitionsum.ImpersonateUserSpecified = true;
            definitionsum.Prompt = null;
            definitionsum.WindowsCredentials = false;

            rs.CreateDataSource("SQLPTOsummary", @"/Data Sources", true, definitionsum, null);


            //Create reports
            // Open the report (rdl) file and
            // read the data into the stream.
            DeployReportItems(@".\Reports\SQLPTOSummaryReports",@"/SQLPTOSummaryReports", @"/Data Sources/SQLPTOSummary");
            DeployReportItems(@".\Reports\SQLPTOReports", @"/SQLPTOReports", @"/Data Sources/SQLPTO");
            rs.Dispose();

            MessageBox.Show("Reports imported successfully!");

            this.Cursor = Cursors.Default;

        }
        private void DeployReportItems(string Path, string DestinationFolder, string DataSource)
        {
            ReportingService2010 rs = new ReportingService2010();
            rs.Url = SSRSWS;
            rs.Credentials = System.Net.CredentialCache.DefaultCredentials;

            byte[] _reportDefinition;
            SQL_PTO_Report.localhost.Warning[] _warnings;
            string strReportPath;
            FileStream _stream;
            DataSourceReference reference;
            DataSource ds;
            DataSource[] dsarray;
            string strReportName;

            System.IO.DirectoryInfo dir = new System.IO.DirectoryInfo(Path);
            foreach (System.IO.FileInfo f in dir.GetFiles("*.rdl"))
            {
                strReportPath = f.FullName;
                _stream = File.OpenRead(strReportPath);
                _reportDefinition = new Byte[_stream.Length];
                _stream.Read(_reportDefinition, 0, (int)_stream.Length);
                _stream.Close();

                strReportName = f.Name.Split('.')[0];

                // Create the report into the server.
                rs.CreateCatalogItem("Report", strReportName, DestinationFolder, true, _reportDefinition, null, out _warnings);

                dsarray = rs.GetItemDataSources(DestinationFolder + @"/"+ strReportName);
                if (dsarray.Length > 0)
                {
                    reference = new DataSourceReference();
                    ds = new DataSource();
                    reference.Reference = DataSource;
                    ds = dsarray[0];
                    ds.Item = (DataSourceReference)reference;
                    rs.SetItemDataSources(DestinationFolder + @"/" + strReportName, dsarray);
                }

            }

            rs.Dispose();
        }

        private void timer2_Tick(object sender, EventArgs e)
        {
            timer2.Enabled = false;
            panel1.Visible = false;
        }

        private void toolStripSplitButton3_ButtonClick(object sender, EventArgs e)
        {
            panel1.Visible = !panel1.Visible;
        }

        private void tsslStatus_Click(object sender, EventArgs e)
        {
            using (Log logWindows = new Log())
            {
                logWindows.ShowDialog();
            }
        }

        private void importReportsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("Are you sure you want to import reports? This will overwrite existing reports and data sources.",
                "ReportServer Restore", MessageBoxButtons.YesNo);
            if (result == DialogResult.Yes)
            {
                ImportReports();

            }
        }

        private void OpenFolder(string strFoldername)
        {
            string strFolder = ConfigurationManager.AppSettings["CollectedDataFolder"];
            using (DataSet dsFolder = new DataSet())
            {
                SelectRows(dsFolder, "select * from " + sbDbNames.Text + ".dbo.SourceFileName");
                string strCurrentDataFolder = Path.Combine(strFolder, dsFolder.Tables[0].Rows[0][0].ToString());
                strCurrentDataFolder = Path.Combine(strCurrentDataFolder, strFoldername);

                //Open folder
                Process.Start(strCurrentDataFolder);
            }
        }

        private void fixScriptsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFolder("FixScripts");
        }

        private void allQueryPlansToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFolder("AllQueryPlans");

        }

        private void dMVPlansToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFolder("DmvQueryPlans");

        }

        private void viewDataImportLogToolStripMenuItem_Click(object sender, EventArgs e)
        {
            using (Log logWindows = new Log())
            {
                logWindows.ShowDialog();
            }
        }

        private void btnAboutOK_Click(object sender, EventArgs e)
        {
            panel1.Visible = false;
        }

        private void clearDataImportLogToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("Clear the data import log?","Clear Log", MessageBoxButtons.YesNo);
            if (result == DialogResult.Yes)
            {
                //Delete Log file
                File.Delete("DataLoading.log");
            }
        }

        private void toolStripSplitButton2_ButtonClick(object sender, EventArgs e)
        {
            if (frmPerfQuery == null || frmPerfQuery.IsDisposed)
            {
                frmPerfQuery = new frmPerfMonQueries();
            }
            frmPerfQuery.DatabaseName = sbDbNames.Text;
            frmPerfQuery.ReportForm = this;
            //frmPerfQuery.Width = Screen.PrimaryScreen.Bounds.Width;
            //frmPerfQuery.Height = Screen.
            frmPerfQuery.WindowState = FormWindowState.Maximized;
            frmPerfQuery.Show();
            frmPerfQuery.BringToFront();
        }
    }
}