<%@ Page Title="Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DateTime dt = DateTime.Now.AddHours(-1);
            SqlDataSource1.SelectCommand = "SELECT pumprunning, AVG(watertop) AS watertop, AVG(waterbase) AS waterbase, AVG(waterpanel) AS waterpanel, AVG(hometemp1) AS hometemp, AVG(hometemp2) AS hometemp2, AVG(hometemp3) AS hometemp3, eDate FROM dbo.HomeLogGeneral   WHERE  eDate >= '" + dt.ToString("s") + "' GROUP BY eDate, pumprunning order by eDate DESC";
            System.Data.DataView dv;
            dv = (System.Data.DataView)SqlDataSource1.Select(DataSourceSelectArguments.Empty);
            dv.Sort = "eDate ASC";
            Repeater1.DataSource = dv;
            Repeater1.DataBind();
            dv.Dispose();


            System.Data.DataSet dsTax = new System.Data.DataSet();
            System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
            objConn.Open();
            System.Data.SqlClient.SqlDataAdapter daTax = new System.Data.SqlClient.SqlDataAdapter("SELECT MAX(waterbase) as waterbase, MAX(batteryv) AS batteryv,MAX(watertop) AS watertop, MAX(waterpanel) AS waterpanel, MAX(hometemp1) AS hometemp1, MAX(solarc) AS solarc, MAX(offgridc) AS offgridc  FROM dbo.HomeLogGeneral  WHERE  eDate >= '" + dt.ToString("s") + "'", objConn);
            daTax.FillSchema(dsTax, System.Data.SchemaType.Source, "HomeLogGeneral");
            daTax.Fill(dsTax, "HomeLogGeneral");
            daTax.Dispose();
            objConn.Close();
            try
            {
                if (dsTax.Tables[0].Rows.Count > 0)
                {
                    LitHome.Text = dsTax.Tables[0].Rows[0]["hometemp1"].ToString() + "<span> &deg;C<span>";
                    LitCollector.Text = dsTax.Tables[0].Rows[0]["waterpanel"].ToString() + "<span> &deg;C<span>";
                    LitCylinder.Text = dsTax.Tables[0].Rows[0]["watertop"].ToString() + "<span> &deg;C<span>";
                    // LitReturn.Text = dsTax.Tables[0].Rows[0]["waterbase"].ToString() + "<span> &deg;C<span>";

                    double solarcwatts = Double.Parse(dsTax.Tables[0].Rows[0]["batteryv"].ToString()) * Double.Parse(dsTax.Tables[0].Rows[0]["solarc"].ToString());
                    LitPV.Text = formatKW(solarcwatts);
                    LitPVAmps.Text = dsTax.Tables[0].Rows[0]["solarc"].ToString() + " amp<span>";
                    
                   
                    double offgridcwatts = Double.Parse(dsTax.Tables[0].Rows[0]["batteryv"].ToString()) * Double.Parse(dsTax.Tables[0].Rows[0]["offgridc"].ToString());

                    LitGeneral.Text = formatKW(offgridcwatts);
                    LitGeneralAmps.Text = dsTax.Tables[0].Rows[0]["offgridc"].ToString() + " amp<span>";
                }
            }
            catch { }
            dsTax.Dispose();




            dsTax.Dispose();

            // pv data
            SqlDataSourcePV.SelectCommand = "SELECT AVG(solarc) AS solarc, AVG(offgridc) AS offgridc ,eDate FROM dbo.HomeLogGeneral   WHERE  eDate >= '" + dt.ToString("s") + "' GROUP BY eDate order by eDate DESC";
            System.Data.DataView dvPV;
            dvPV = (System.Data.DataView)SqlDataSourcePV.Select(DataSourceSelectArguments.Empty);
            dvPV.Sort = "eDate ASC";
            RepeaterPV.DataSource = dvPV;
            RepeaterPV.DataBind();
            dvPV.Dispose();


            // battery data
            SqlDataSourceBattery.SelectCommand = "SELECT AVG(batteryv) AS batteryv ,eDate FROM dbo.HomeLogGeneral   WHERE  eDate >= '" + dt.ToString("s") + "' GROUP BY eDate order by eDate DESC";

            System.Data.DataView dvBattery;
            dvBattery = (System.Data.DataView)SqlDataSourceBattery.Select(DataSourceSelectArguments.Empty);
            dvBattery.Sort = "eDate ASC";
            RepeaterBattery.DataSource = dvBattery;
            RepeaterBattery.DataBind();
            dvBattery.Dispose();






        }
    }
    public string formatKW(double watts)
    {
        if (watts > 1000)
        {
            return (watts / 1000).ToString("0.0") + "<span> Kw";
        }
        else
        {
            return watts.ToString("0.") + "<span> watts";
        }
    }
    public string CheckPump(string inval)
    {
        if (inval.Equals("0"))
        {
            return "0";
        }
        else
        {
            return "10";
        }
    }
    public string FormatDate(string inval)
    {
        return DateTime.Parse(inval).ToString("HH:mm");

    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">

          
          
 
 <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <asp:Panel id="panel" runat="server">
    <script type="text/javascript">
        google.load("visualization", "1", { packages: ["corechart", 'gauge'] });
        google.setOnLoadCallback(drawChart);
        function drawChart() {
            var data = google.visualization.arrayToDataTable([
         ['Hour', 'Cylinder Top','Cylinder Base', 'Solar Collector', 'Living Room','Andrew BR','Brian BR', 'Pump Running'],
         <asp:Repeater ID="Repeater1" runat="server" >
  <ItemTemplate>
     
      ['<%# FormatDate(DataBinder.Eval(Container.DataItem, "eDate").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "watertop") %>, <%# DataBinder.Eval(Container.DataItem, "waterbase") %>,<%# DataBinder.Eval(Container.DataItem, "waterpanel") %>, <%# DataBinder.Eval(Container.DataItem, "hometemp") %>, <%# DataBinder.Eval(Container.DataItem, "hometemp2") %>,<%# DataBinder.Eval(Container.DataItem, "hometemp3") %>,<%# CheckPump(DataBinder.Eval(Container.DataItem, "pumprunning").ToString()) %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var options = {
               
                chartArea:{left:40,top:10,width:"80%",height:"70%"}
            };

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
            chart.draw(data, options);

            // pv chart

            var dataPV = google.visualization.arrayToDataTable([
         ['Hour', 'Panel Current',  '12 Out Current'],
         <asp:Repeater ID="RepeaterPV" runat="server">
  <ItemTemplate>
     
      ['<%# FormatDate(DataBinder.Eval(Container.DataItem, "eDate").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "solarc") %>, <%# DataBinder.Eval(Container.DataItem, "offgridc") %>],
  </ItemTemplate>
</asp:Repeater>
        ]);

            var optionsPV = {
               
                chartArea:{left:40,top:10,width:"80%",height:"70%"}
            };

            var chartPV = new google.visualization.LineChart(document.getElementById('chart_divPV'));
            chartPV.draw(dataPV, optionsPV);

            // voltage 

            var datavoltage = google.visualization.arrayToDataTable([
         ['Hour', 'Volts'],
         <asp:Repeater ID="RepeaterBattery" runat="server">
  <ItemTemplate>
     
      ['<%# FormatDate(DataBinder.Eval(Container.DataItem, "eDate").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "batteryv") %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var optionsvoltage = {
              
                chartArea:{left:40,top:10,width:"80%",height:"70%"}
            };

            var chartvoltage = new google.visualization.LineChart(document.getElementById('chart_divVoltage'));
            chartvoltage.draw(datavoltage, optionsvoltage);

            


        }
    </script>
</asp:Panel>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:MainConn %>" >
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDataSourcePV" runat="server" 
        ConnectionString="<%$ ConnectionStrings:MainConn %>" >
    </asp:SqlDataSource>
     <asp:SqlDataSource ID="SqlDataSourceBattery" runat="server" 
        ConnectionString="<%$ ConnectionStrings:MainConn %>" >
    </asp:SqlDataSource>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <h1>Last Hour</h1>

    <asp:Literal ID="litError" runat="server"></asp:Literal>
    <table width="100%">
        <tr>
            <td valign="top" style="width:  80%;">
                <h2>Temperature Sensors</h2>
 <div id="chart_div" style="width: 100%; height: 250px;"></div>
                <h2>Current Usage</h2>
    <div id="chart_divPV" style="width: 100%; height:250px; "></div>
                <h2>Battery Voltage</h2>
    <div id="chart_divVoltage" style="width: 100%; height: 250px; "></div>
               
            </td>
            <td valign="top">
                <h2>Max Values</h2>
                <table class="boxes side" width="160">
                <tr>
                    <td class="greenbox">
                        <h1>Home</h1>
                        <h3><asp:Literal ID="LitHome" runat="server"></asp:Literal></h3>
                    </td>
                    </tr>
                    <tr>
                    <td class="greenbox">
                        <h1>Collector</h1>
                        <h3><asp:Literal ID="LitCollector" runat="server"></asp:Literal></h3>
                    </td>
                        </tr>
                    <tr>
                    <td class="greenbox">
                        <h1>Water Cylinder</h1>
                        <h3><asp:Literal ID="LitCylinder" runat="server"></asp:Literal></h3>
                    </td>
                        </tr>
                    <tr>
                   
 </tr>
                    <tr>
                        <td class="darkbluebox">
                       <h1>PV Input</h1>
                        <h3><asp:Literal ID="LitPV" runat="server"></asp:Literal></h3>
                       <h4><asp:Literal ID="LitPVAmps" runat="server"></asp:Literal></h4>
                   </td>
                         </tr>
              
                  
                    <tr>
                   <td class="darkbluebox">
                       <h1>General 12v</h1>
                        <h3><asp:Literal ID="LitGeneral" runat="server"></asp:Literal></h3>
                       <h4><asp:Literal ID="LitGeneralAmps" runat="server"></asp:Literal></h4>
                   </td>
                </tr>
</table>
            </td>

        </tr>
    </table>
   
</asp:Content>

