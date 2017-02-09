using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Diagnostics;
using System.IO.Compression;

namespace SQLDiagConfigurationManager
{
    public partial class frmConfiguration : Form
    {
        private string strWaitInfo = 
            @"ADD EVENT sqlos.wait_info(
                ACTION(package0.callstack, sqlserver.session_id, sqlserver.sql_text)
                WHERE([duration]>(15000) AND([wait_type]>=N'LATCH_NL' AND ([wait_type]>=N'PAGELATCH_NL' AND[wait_type]<=N'PAGELATCH_DT' OR[wait_type]<=N'LATCH_DT' OR[wait_type]>=N'PAGEIOLATCH_NL' AND[wait_type]<=N'PAGEIOLATCH_DT' OR[wait_type]>=N'IO_COMPLETION' AND[wait_type]<=N'NETWORK_IO' OR[wait_type]= N'RESOURCE_SEMAPHORE' OR[wait_type]= N'SOS_WORKER' OR[wait_type]>=N'FCB_REPLICA_WRITE' AND[wait_type]<=N'WRITELOG' OR[wait_type]= N'CMEMTHREAD' OR[wait_type]= N'TRACEWRITE' OR[wait_type]= N'RESOURCE_SEMAPHORE_MUTEX') OR[duration]>(30000) AND[wait_type]<=N'LCK_M_RX_X'))),
            ADD EVENT sqlos.wait_info_external(
                ACTION(package0.callstack, sqlserver.session_id, sqlserver.sql_text)
                WHERE([duration]>(5000) AND([wait_type]>=N'PREEMPTIVE_OS_GENERICOPS' AND[wait_type]<=N'PREEMPTIVE_OS_ENCRYPTMESSAGE' OR[wait_type]>=N'PREEMPTIVE_OS_INITIALIZESECURITYCONTEXT' AND[wait_type]<=N'PREEMPTIVE_OS_QUERYSECURITYCONTEXTTOKEN' OR[wait_type]>=N'PREEMPTIVE_OS_AUTHZGETINFORMATIONFROMCONTEXT' AND[wait_type]<=N'PREEMPTIVE_OS_REVERTTOSELF' OR[wait_type]>=N'PREEMPTIVE_OS_CRYPTACQUIRECONTEXT' AND[wait_type]<=N'PREEMPTIVE_OS_DEVICEOPS' OR[wait_type]>=N'PREEMPTIVE_OS_NETGROUPGETUSERS' AND[wait_type]<=N'PREEMPTIVE_OS_NETUSERMODALSGET' OR[wait_type]>=N'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICYFREE' AND[wait_type]<=N'PREEMPTIVE_OS_DOMAINSERVICESOPS' OR[wait_type]= N'PREEMPTIVE_OS_VERIFYSIGNATURE' OR[duration]>(45000) AND([wait_type]>=N'PREEMPTIVE_OS_SETNAMEDSECURITYINFO' AND[wait_type]<=N'PREEMPTIVE_CLUSAPI_CLUSTERRESOURCECONTROL' OR[wait_type]>=N'PREEMPTIVE_OS_RSFXDEVICEOPS' AND[wait_type]<=N'PREEMPTIVE_OS_DSGETDCNAME' OR[wait_type]>=N'PREEMPTIVE_OS_DTCOPS' AND[wait_type]<=N'PREEMPTIVE_DTC_ABORT' OR[wait_type]>=N'PREEMPTIVE_OS_CLOSEHANDLE' AND[wait_type]<=N'PREEMPTIVE_OS_FINDFILE' OR[wait_type]>=N'PREEMPTIVE_OS_GETCOMPRESSEDFILESIZE' AND[wait_type]<=N'PREEMPTIVE_ODBCOPS' OR[wait_type]>=N'PREEMPTIVE_OS_DISCONNECTNAMEDPIPE' AND[wait_type]<=N'PREEMPTIVE_CLOSEBACKUPMEDIA' OR[wait_type]= N'PREEMPTIVE_OS_AUTHENTICATIONOPS' OR[wait_type]= N'PREEMPTIVE_OS_FREECREDENTIALSHANDLE' OR[wait_type]= N'PREEMPTIVE_OS_AUTHORIZATIONOPS' OR[wait_type]= N'PREEMPTIVE_COM_COCREATEINSTANCE' OR[wait_type]= N'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICY' OR[wait_type]= N'PREEMPTIVE_VSS_CREATESNAPSHOT')))),";
        private string strStatement =
            @"ADD EVENT sqlserver.sp_statement_completed(
                WHERE ([sqlserver].[is_system]=(0))),
            ADD EVENT sqlserver.sql_statement_completed(
                WHERE ([sqlserver].[is_system]=(0))),";
        private string strWaitInfo_2012 =
            @"ADD EVENT sqlos.wait_info(
                ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text)
                WHERE ([duration]>(15000) AND ([wait_type]>(31) AND ([wait_type]>(47) AND [wait_type]<(54) OR [wait_type]<(38) OR [wait_type]>(63) AND [wait_type]<(70) OR [wait_type]>(96) AND [wait_type]<(100) OR [wait_type]=(111) OR [wait_type]=(117) OR [wait_type]>(178) AND [wait_type]<(183) OR [wait_type]=(190) OR [wait_type]=(214) OR [wait_type]=(276)) OR [duration]>(30000) AND [wait_type]<(22)))),
            ADD EVENT sqlos.wait_info_external(
                ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text)
                WHERE ([duration]>(5000) AND ([wait_type]>(410) AND [wait_type]<(419) OR [wait_type]>(419) AND [wait_type]<(423) OR [wait_type]>(425) AND [wait_type]<(431) OR [wait_type]>(468) AND [wait_type]<(472) OR [wait_type]>(474) AND [wait_type]<(480) OR [wait_type]>(480) AND [wait_type]<(483) OR [wait_type]=(424) OR [duration]>(45000) AND ([wait_type]>(430) AND [wait_type]<(434) OR [wait_type]>(471) AND [wait_type]<(475) OR [wait_type]>(482) AND [wait_type]<(485) OR [wait_type]>(490) AND [wait_type]<(498) OR [wait_type]>(499) AND [wait_type]<(521) OR [wait_type]>(532) AND [wait_type]<(547) OR [wait_type]=(412) OR [wait_type]=(419) OR [wait_type]=(425) OR [wait_type]=(435) OR [wait_type]=(480) OR [wait_type]=(550))))),";
        public frmConfiguration()
        {
            InitializeComponent();
        }

        private static void DirectoryCopy(string sourceDirName, string destDirName, bool copySubDirs)
        {
            // Get the subdirectories for the specified directory.
            DirectoryInfo dir = new DirectoryInfo(sourceDirName);

            if (!dir.Exists)
            {
                throw new DirectoryNotFoundException(
                    "Source directory does not exist or could not be found: "
                    + sourceDirName);
            }

            DirectoryInfo[] dirs = dir.GetDirectories();
            // If the destination directory doesn't exist, create it.
            if (!Directory.Exists(destDirName))
            {
                Directory.CreateDirectory(destDirName);
            }

            // Get the files in the directory and copy them to the new location.
            FileInfo[] files = dir.GetFiles();
            foreach (FileInfo file in files)
            {
                string temppath = Path.Combine(destDirName, file.Name);
                file.CopyTo(temppath, false);
            }

            // If copying subdirectories, copy them and their contents to new location.
            if (copySubDirs)
            {
                foreach (DirectoryInfo subdir in dirs)
                {
                    string temppath = Path.Combine(destDirName, subdir.Name);
                    DirectoryCopy(subdir.FullName, temppath, copySubDirs);
                }
            }
        }

        private void ReplaceText(string FileName,string Pattern, string NewText)
        {
            string text = File.ReadAllText(FileName);
            text = text.Replace(Pattern, NewText);
            File.WriteAllText(FileName, text);
        }


        private void btnGenerate_Click(object sender, EventArgs e)
        {
            string path = Directory.GetCurrentDirectory();
            string strSource = Path.Combine(path, "Source");
            string strDest = Path.Combine(path, "SQLDIAG_"+DateTime.Now.ToString("yyyyMMdd_hhmmss"));
            string strExecFile = string.Empty;

            Directory.CreateDirectory(strDest);
            DirectoryCopy(Path.Combine(strSource, "SqlDiagWorkFolder"), Path.Combine(strDest, "SqlDiagWorkFolder"), true);

            //version
            string strVersion = cbVersion.SelectedItem.ToString();

            if (!chkSchedule.Checked)
            {
                switch (strVersion)
                {
                    case "2012":
                        File.Copy(Path.Combine(strSource, "Exec_SQLDiag - 2012.cmd"), Path.Combine(strDest, "Exec_SQLDiag - 2012.cmd"));
                        File.Copy(Path.Combine(strSource, "SQLDiagPTO2012.xml"), Path.Combine(strDest, @"SqlDiagWorkFolder\SQLDiagPTO2012.xml"));
                        strWaitInfo = strWaitInfo_2012;
                        break;
                    case "2014":
                        File.Copy(Path.Combine(strSource, "Exec_SQLDiag - 2014.cmd"), Path.Combine(strDest, "Exec_SQLDiag - 2014.cmd"));
                        File.Copy(Path.Combine(strSource, "SQLDiagPTO2014.xml"), Path.Combine(strDest, @"SqlDiagWorkFolder\SQLDiagPTO2014.xml"));
                        break;
                    case "2016":
                        File.Copy(Path.Combine(strSource, "Exec_SQLDiag - 2016.cmd"), Path.Combine(strDest, "Exec_SQLDiag - 2016.cmd"));
                        File.Copy(Path.Combine(strSource, "SQLDiagPTO2016.xml"), Path.Combine(strDest, @"SqlDiagWorkFolder\SQLDiagPTO2016.xml"));
                        break;
                    default:
                        MessageBox.Show("Error", "Must select a version.");
                        break;
                }
            }
            else
            {
                //Schedule
                switch (strVersion)
                {
                    case "2012":
                        strExecFile = Path.Combine(strDest, "Exec_SQLDiag - 2012 - Schedule.cmd");
                        File.Copy(Path.Combine(strSource, "Exec_SQLDiag - 2012 - Schedule.cmd"), strExecFile);
                        File.Copy(Path.Combine(strSource, "SQLDiagPTO2012.xml"), Path.Combine(strDest, @"SqlDiagWorkFolder\SQLDiagPTO2012.xml"));
                        strWaitInfo = strWaitInfo_2012;
                        break;
                    case "2014":
                        strExecFile = Path.Combine(strDest, "Exec_SQLDiag - 2014 - Schedule.cmd");
                        File.Copy(Path.Combine(strSource, "Exec_SQLDiag - 2014 - Schedule.cmd"), strExecFile);
                        File.Copy(Path.Combine(strSource, "SQLDiagPTO2014.xml"), Path.Combine(strDest, @"SqlDiagWorkFolder\SQLDiagPTO2014.xml"));
                        break;
                    case "2016":
                        strExecFile = Path.Combine(strDest, "Exec_SQLDiag - 2016 - Schedule.cmd");
                        File.Copy(Path.Combine(strSource, "Exec_SQLDiag - 2016 - Schedule.cmd"), strExecFile);
                        File.Copy(Path.Combine(strSource, "SQLDiagPTO2016.xml"), Path.Combine(strDest, @"SqlDiagWorkFolder\SQLDiagPTO2016.xml"));
                        break;
                    default:
                        MessageBox.Show("Error", "Must select a version.");
                        break;
                }
                ReplaceText(strExecFile, "_BeginTime_", dtpBegin.Value.ToString("HH:mm:ss"));
                ReplaceText(strExecFile, "_EndTime_", dtpEnd.Value.ToString("HH:mm:ss"));

            }

            //Wait Info
            string strExtendedEventFile = Path.Combine(strDest, @"SqlDiagWorkFolder\XEventSQLDiag.ps1");
            if (chkWaitInfo.Checked)
            {
                ReplaceText(strExtendedEventFile, "_WaitInfo_", strWaitInfo);
            }
            else
            {
                ReplaceText(strExtendedEventFile, "_WaitInfo_", string.Empty);
            }
            //Statement Level SQL Test
            if (chkStatement.Checked)
            {
                ReplaceText(strExtendedEventFile, "_Statement_", strStatement);
            }
            else
            {
                ReplaceText(strExtendedEventFile, "_Statement_", string.Empty);
            }

            //Execution Plan Ratio
            ReplaceText(strExtendedEventFile, "_ExecutionPlanRatio_", nPlanRatio.Value.ToString());

            //XE File Size
            ReplaceText(strExtendedEventFile, "_MaxFileSize_", tbSize.Value.ToString());

            //XE Number of files
            ReplaceText(strExtendedEventFile, "_MaxRolloverFiles_", nNumberOfFiles.Value.ToString());

            //Snapshot interval
            string strSnapshotCmdFile = Path.Combine(strDest, @"SqlDiagWorkFolder\PTO_Snapshot.cmd");
            ReplaceText(strSnapshotCmdFile, "_Interval_", tbSnapshotInterval.Value.ToString());


            //Zip
            ZipFile.CreateFromDirectory(strDest, strDest + ".zip");
            //Delete the folder
            Directory.Delete(strDest, true);

            //Open the folder
            Process.Start(path);

        }

        private void chkSchedule_CheckedChanged(object sender, EventArgs e)
        {
            if (chkSchedule.Checked)
            {
                dtpBegin.Enabled = true;
                dtpEnd.Enabled = true;
            }
            else
            {
                dtpBegin.Enabled = false;
                dtpEnd.Enabled = false;
            }
        }

        private void frmConfiguration_Load(object sender, EventArgs e)
        {
            cbVersion.SelectedIndex = 0;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
