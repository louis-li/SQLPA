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

namespace SQL_PTO_Report
{
    public partial class Log : Form
    {
        public Log()
        {
            InitializeComponent();
        }

        private void Log_Load(object sender, EventArgs e)
        {
            try
            {   // Open the text file using a stream reader.
                using (StreamReader sr = new StreamReader("DataLoading.log"))
                {
                    // Read the stream to a string, and write the string to the console.
                    String line = sr.ReadToEnd();
                    textBox1.Text = line;
                    textBox1.SelectionStart = textBox1.Text.Length + 1;
                    textBox1.ReadOnly = true;
                    textBox1.SelectionLength = 0;
                    textBox1.ScrollToCaret();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
