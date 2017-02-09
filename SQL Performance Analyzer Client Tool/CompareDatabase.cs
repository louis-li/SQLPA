using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.IO;

namespace SQL_PTO_Report
{
    public partial class CompareDatabase : Form
    {
        public CompareDatabase()
        {
            InitializeComponent();
        }
        public DataSet Databases = new DataSet();
        
        private void CompareDatabase_Load(object sender, EventArgs e)
        {
            cbBeforeDb.DataSource = Databases.Tables[0];
            cbBeforeDb.DisplayMember = "Name";
            cbBeforeDb.BindingContext = this.BindingContext;
            cbAfterDb.DataSource = Databases.Tables[0].Copy();
            cbAfterDb.DisplayMember = "Name";
            cbAfterDb.BindingContext = this.BindingContext;
        }

        private void btnCompare_Click(object sender, EventArgs e)
        {
            btnCompare.Enabled = false;
            string beforeDb = ((DataTable)cbBeforeDb.DataSource).Rows[cbBeforeDb.SelectedIndex].ItemArray[0].ToString();
            string afterDb = ((DataTable)cbAfterDb.DataSource).Rows[cbAfterDb.SelectedIndex].ItemArray[0].ToString();

            string psScript;
            string strLocation = System.Reflection.Assembly.GetExecutingAssembly().Location;
            // Open the file to read from.
            using (StreamReader sr = new StreamReader(System.IO.Path.Combine(System.IO.Path.GetDirectoryName(strLocation), "Generate-PTOSumReport.ps1")))
            {
                // Read the stream to a string, and write the string to the console.
                psScript = sr.ReadToEnd();
            }


            using (PowerShell PowerShellInstance = PowerShell.Create())
            {
                // use "AddScript" to add the contents of a script file to the end of the execution pipeline.
                // use "AddCommand" to add individual commands/cmdlets to the end of the execution pipeline.
                PowerShellInstance.AddScript(psScript);

                // use "AddParameter" to add a single parameter to the last command/script on the pipeline.
                PowerShellInstance.AddParameter("InstanceName", "localhost");
                PowerShellInstance.AddParameter("Database", "SQLPTOSummary");
                PowerShellInstance.AddParameter("BeforeDatabase", beforeDb);
                PowerShellInstance.AddParameter("AfterDatabase", afterDb);
                PowerShellInstance.AddParameter("CurrentLocation", System.IO.Path.GetDirectoryName(strLocation));
                //PowerShellInstance.AddParameter("DropExisting", Boolean.TrueString);

                this.Cursor = Cursors.WaitCursor;
                // invoke execution on the pipeline (collecting output)
                Collection<PSObject> PSOutput = PowerShellInstance.Invoke();
                this.Cursor = Cursors.Default;

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

            this.Close();
        }
    }
}
