<%@ Page Title="Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/MasterPage.master" Debug="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
public double Reading = 1;
	public double PreviousReading = 1;
	public DateTime CurrentDate;
	public DateTime PreviousDate = new DateTime(2000,1,1);
	public int Days;
	public double unitsUsed = 0;
	public double PrevunitsUsed = 0;
	public double UnitsPerDay = 0;
	public double PrevUnitsPerDay = 0;
	double PercentageChange = 0;
	public string CssClass = "";
	
	  
	protected void Page_Load(Object Src, EventArgs E)
	{
        
	}
	
	
	public string GetReading(string dbTableVal) 
	{
		// reset vars
		Reading = 0;
		PreviousReading = 0;
		CurrentDate = new DateTime(2000,1,1);
		PreviousDate = new DateTime(2000,1,1);
		Days = 1;
		unitsUsed = 0;
		PrevunitsUsed = 0;
		UnitsPerDay = 0;
		PrevUnitsPerDay = 0;
		PercentageChange = 0;
		CssClass = "";
        
        System.Data.DataSet ds = new System.Data.DataSet();
        System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
        objConn.Open();
        System.Data.SqlClient.SqlDataAdapter daTax = new System.Data.SqlClient.SqlDataAdapter("SELECT ReadingDate, " + dbTableVal + " as MeterReading,  Notes from MeterReadings order by ReadingDate ASC", objConn);
        daTax.FillSchema(ds, System.Data.SchemaType.Source, "MeterReadings");
        daTax.Fill(ds, "MeterReadings");
        daTax.Dispose();
        objConn.Close();

		StringBuilder sb = new StringBuilder();	
		int sendmessagecount = 1;
		foreach (DataRow row in ds.Tables[0].Rows)
			{
				Reading = Double.Parse(row["MeterReading"].ToString());
                CurrentDate = DateTime.Parse(row["ReadingDate"].ToString());
				
				if (Reading <= 0) {
					PreviousReading = Reading;
				}
				if (PreviousDate == new DateTime(2000,1,1)) {
					PreviousDate = CurrentDate;
				}
				
				sb.Append("<tr>" + Environment.NewLine);
                sb.Append("<td class=\"season" + DateTime.Parse(row["ReadingDate"].ToString()).ToString("MM") + "\">" + DateTime.Parse(row["ReadingDate"].ToString()).ToString("d") + " </td>" + Environment.NewLine); // date
				sb.Append("<td>" + row["MeterReading"].ToString() + "</td>" + Environment.NewLine); // meter reading
				if (PreviousReading == 0) {
					PreviousReading = Reading;
				}
				unitsUsed = (Reading - PreviousReading);
				
				sb.Append("<td>" + unitsUsed.ToString() + "</td>" + Environment.NewLine); // units used
				
				System.TimeSpan diffResult = CurrentDate.Subtract(PreviousDate);
				Days = diffResult.Days;
				
				sb.Append("<td>" + Days.ToString() + "</td>" + Environment.NewLine); // days
				
				if (Days > 0) {
				UnitsPerDay = Double.Parse((unitsUsed / Days).ToString());
				} else {
				UnitsPerDay = 0;
				}
				sb.Append("<td>" + UnitsPerDay.ToString("f") + "</td>" + Environment.NewLine); // Units per day
				sb.Append("<td><div class=\"bluebg\" style=\"width:" + Math.Abs((UnitsPerDay / 10)).ToString("#0") + "px;\">&nbsp;</div></td>" + Environment.NewLine); // % units per day graph
				
				if (UnitsPerDay == 0) {
					PercentageChange = 0;
					
				} else {
					PercentageChange = 100.0 * UnitsPerDay / PrevUnitsPerDay - 100.0;				
				}
				
				if (!(PercentageChange.ToString().Equals("Infinity")))  {
					if (PercentageChange <= 0) {
						CssClass = "green";
					} else {
						CssClass = "red";
					}
				} else {
				PercentageChange = 0;
				} 
				sb.Append("<td  class=\"" + CssClass + "\">" + PercentageChange.ToString("f") + "%</td>" + Environment.NewLine); // % change
				sb.Append("</tr>" + Environment.NewLine);
				// check to see if there are notes
				if (row["Notes"].ToString().Trim().Length > 0) {
					sb.Append("<tr>" + Environment.NewLine);
					sb.Append("<td style=\"text-align: center; font-weight: bold;\" colspan=\"7\">" + row["Notes"].ToString() + "&nbsp;</td>" + Environment.NewLine); // notes
					sb.Append("</tr>" + Environment.NewLine);
				}
				
				
				PreviousReading = Reading;
				PreviousDate = CurrentDate;
				PrevunitsUsed = unitsUsed;
				PrevUnitsPerDay = UnitsPerDay;
			}
		ds.Dispose();		
		return sb.ToString();
	}

    public string GetGraph(string dbTableVal) 
	{
		// reset vars
		Reading = 0;
		PreviousReading = 0;
		CurrentDate = new DateTime(2000,1,1);
		PreviousDate = new DateTime(2000,1,1);
		Days = 1;
		unitsUsed = 0;
		PrevunitsUsed = 0;
		UnitsPerDay = 0;
		PrevUnitsPerDay = 0;
		PercentageChange = 0;
		CssClass = "";
	
		StringBuilder sbgraph = new StringBuilder();

        System.Data.DataSet ds = new System.Data.DataSet();
        System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
        objConn.Open();
        System.Data.SqlClient.SqlDataAdapter daTax = new System.Data.SqlClient.SqlDataAdapter("SELECT ReadingDate, " + dbTableVal + " as MeterReading,  Notes from MeterReadings order by ReadingDate ASC", objConn);
        daTax.FillSchema(ds, System.Data.SchemaType.Source, "MeterReadings");
        daTax.Fill(ds, "MeterReadings");
        daTax.Dispose();
        objConn.Close();
		StringBuilder sb = new StringBuilder();	
		int sendmessagecount = 1;
		foreach (DataRow row in ds.Tables[0].Rows)
			{
				Reading = Double.Parse(row["MeterReading"].ToString());
                CurrentDate = DateTime.Parse(row["ReadingDate"].ToString());
				
				if (Reading <= 0) {
					PreviousReading = Reading;
				}
				if (PreviousDate == new DateTime(2000,1,1)) {
					PreviousDate = CurrentDate;
				}
				
				sb.Append("<tr>" + Environment.NewLine);
                sb.Append("<td class=\"season" + DateTime.Parse(row["ReadingDate"].ToString()).ToString("MM") + "\">" + DateTime.Parse(row["ReadingDate"].ToString()).ToString("d") + " </td>" + Environment.NewLine); // date
				sb.Append("<td>" + row["MeterReading"].ToString() + "</td>" + Environment.NewLine); // meter reading
				if (PreviousReading == 0) {
					PreviousReading = Reading;
				}
				unitsUsed = (Reading - PreviousReading);
				
				sb.Append("<td>" + unitsUsed.ToString() + "</td>" + Environment.NewLine); // units used
				
				System.TimeSpan diffResult = CurrentDate.Subtract(PreviousDate);
				Days = diffResult.Days;
				
				sb.Append("<td>" + Days.ToString() + "</td>" + Environment.NewLine); // days
				
				if (Days > 0) {
				UnitsPerDay = Double.Parse((unitsUsed / Days).ToString());
				} else {
				UnitsPerDay = 0;
				}
				sb.Append("<td>" + UnitsPerDay.ToString("f") + "</td>" + Environment.NewLine); // Units per day
				sb.Append("<td><div class=\"bluebg\" style=\"width:" + Math.Abs((UnitsPerDay / 10)).ToString("#0") + "px;\">&nbsp;</div></td>" + Environment.NewLine); // % units per day graph
				
				if (UnitsPerDay == 0) {
					PercentageChange = 0;
					
				} else {
					PercentageChange = 100.0 * UnitsPerDay / PrevUnitsPerDay - 100.0;				
				}
				
				if (!(PercentageChange.ToString().Equals("Infinity")))  {
					if (PercentageChange <= 0) {
						CssClass = "green";
					} else {
						CssClass = "red";
					}
				} else {
				PercentageChange = 0;
				} 
				sb.Append("<td  class=\"" + CssClass + "\">" + PercentageChange.ToString("f") + "%</td>" + Environment.NewLine); // % change
				sb.Append("</tr>" + Environment.NewLine);
				// check to see if there are notes
				if (row["Notes"].ToString().Trim().Length > 0) {
					sb.Append("<tr>" + Environment.NewLine);
					sb.Append("<td style=\"text-align: center; font-weight: bold;\" colspan=\"7\">" + row["Notes"].ToString() + "&nbsp;</td>" + Environment.NewLine); // notes
					sb.Append("</tr>" + Environment.NewLine);
				}
				
				sbgraph.Append("['" + DateTime.Parse(row["ReadingDate"].ToString()).ToString("d") + "', " + Days.ToString() + ", " + UnitsPerDay.ToString("f") + "],	" + Environment.NewLine);
				
				PreviousReading = Reading;
				PreviousDate = CurrentDate;
				PrevunitsUsed = unitsUsed;
				PrevUnitsPerDay = UnitsPerDay;
			}
		ds.Dispose();
		
		
		return sbgraph.ToString();
	}
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
<style type="text/css">
<!--
.red { color:#FF0000;}
.green {color:#009933; }
.redbg { background-color:#FF0000; height: 5px; margin: 0 0 7px 0;}
.greenbg {background-color:#009933;  height: 5px; margin: 0 0 7px 0;}
.bluebg { background-color:#cccccc; height: 5px; margin: 0 0 7px 0; }
.season01, .season02, .season12 { background:#C5CCFC; width: 50px;}
.season03, .season04, .season05 { background:#DDFFCE; width: 50px;}
.season06, .season07, .season08 { background:#FFFF99; width: 50px;}
.season09, .season10, .season11 { background:#FFCC99; width: 50px;}
table.lists { width: 470px; margin-right: 20px;}
-->
</style>

 <script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
        google.load("visualization", "1", { packages: ["corechart", 'gauge'] });
        google.setOnLoadCallback(drawChart);
        function drawChart() {
            var data = google.visualization.arrayToDataTable([
         ['Date', 'Days', 'Units'],
         
     <%= GetGraph("MeterGas")  %>
     
     ]);

            var options = {
               
                chartArea:{left:40,top:10,width:"80%",height:"70%"}
            };

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
            chart.draw(data, options);
			// electric meter
			
			 var data2 = google.visualization.arrayToDataTable([
         ['Date', 'Days', 'Units'],
         
     <%= GetGraph("MeterElectric")  %>
     
     ]);

            var options = {
               
                chartArea:{left:40,top:10,width:"80%",height:"70%"}
            };

            var chart2 = new google.visualization.LineChart(document.getElementById('chart_divelec'));
            chart2.draw(data2, options);

          
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
   
    <h1>Gas Usage</h1>
    <div id="chart_div" style="width: 100%; height: 250px; margin-bottom: 10px;"></div>
    <h1>Electric Usage</h1>
    <div id="chart_divelec" style="width: 100%; height: 250px;"></div>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td valign="top">
                <table border="0" cellspacing="0" cellpadding="0" class="lists" >
                    <tr>
                        <td colspan="7">
                            <h2>Electric Meter</h2>
                        </td>
                    </tr>
                    <tr>
                        <th>Date</th>
                        <th>Reading</th>
                        <th>U/U</th>
                        <th>Days</th>
                        <th>UPD</th>
                        <th>&nbsp;</th>
                        <th>%&nbsp;Dif</th>
                    </tr>
                    <%= GetReading("MeterElectric") %>
                </table>
            </td>
            <td valign="top">
                <table border="0" cellspacing="0" cellpadding="0"  class="lists" >
                    <tr>
                        <td colspan="7">
                            <h2>Gas Meter</h2>
                        </td>
                    </tr>
                    <tr>
                        <th>Date</th>
                        <th>Reading</th>
                        <th>U/U</th>
                        <th>Days</th>
                        <th>UPD</th>
                        <th>&nbsp;</th>
                        <th>%&nbsp;Dif</th>
                    </tr>
                    <%= GetReading("MeterGas") %>
                </table>
            </td>
        </tr>
    </table>
    <p>&nbsp;</p>

</asp:Content>