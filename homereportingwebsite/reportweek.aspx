<%@ Page Title="Seven Day Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<script runat="server">
   
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            setdata(DateTime.Now);
        }
    }
    
    protected void Calendar1_SelectionChanged(object sender, EventArgs e)
    {
       
        setdata(Calendar1.SelectedDate.Date);
    }
    
    public void setdata(DateTime dt){


        DateTime dtEnd = dt.AddDays(7);
        Literal1.Text = dt.ToShortDateString() + " to " + dtEnd.ToShortDateString();


        SqlDataSource1.SelectCommand = "SELECT TOP (100) PERCENT AVG(watertop) AS watertop, AVG(waterbase) AS waterbase, AVG(waterpanel) AS waterpanel, AVG(hometemp1) AS hometemp1, DATEPART(dd, eDate) AS DateDay, DATEPART(hour, dateadd(hour,(datediff(hour,0,eDate)/6)*6,0)) AS DateHour, pumprunning  FROM dbo.HomeLogGeneral WHERE eDate > '" + dt.AddDays(-7).ToString("yyyy-MM-dd") + "' AND eDate < '" + dtEnd.ToString("yyyy-MM-dd") + "'  GROUP BY dateadd(hour,(datediff(hour,0,eDate)/6)*6,0), DATEPART(dd, eDate), pumprunning order by DATEPART(dd, eDate) asc";
            Repeater1.DataBind();
            
            

            System.Data.DataSet dsTax = new System.Data.DataSet();
            System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
            objConn.Open();
            System.Data.SqlClient.SqlDataAdapter daTax = new System.Data.SqlClient.SqlDataAdapter("SELECT TOP (100) PERCENT  MAX(waterbase) as waterbase, AVG(batteryv) AS batteryv,   MAX(watertop) AS watertop, MAX(waterpanel) AS waterpanel, MAX(hometemp1) AS hometemp1,  MAX(solarc) AS solarc, MAX(offgridc) AS offgridc  FROM dbo.HomeLogGeneral  WHERE eDate > '" + dt.AddDays(-7).ToString("yyyy-MM-dd") + "' AND eDate < '" + dtEnd.ToString("yyyy-MM-dd") + "'", objConn);
            daTax.FillSchema(dsTax, System.Data.SchemaType.Source, "HomeLog");
            daTax.Fill(dsTax, "HomeLog");
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

            // pv data
            SqlDataSourcePV.SelectCommand = "SELECT TOP (100) PERCENT AVG(solarc) AS solarc, AVG(offgridc) AS offgridc ,DATEPART(dd, eDate) AS DateDay, DATEPART(hour, dateadd(hour,(datediff(hour,0,eDate)/6)*6,0)) AS DateHour FROM dbo.HomeLogGeneral  WHERE eDate > '" + dt.AddDays(-7).ToString("yyyy-MM-dd") + "' AND eDate < '" + dtEnd.ToString("yyyy-MM-dd") + "' GROUP BY dateadd(hour,(datediff(hour,0,eDate)/6)*6,0),  DATEPART(dd, eDate)";
            Repeater2.DataBind();

            // battery data
            SqlDataSourceBattery.SelectCommand = "SELECT TOP (100) PERCENT AVG(batteryv) AS batteryv , DATEPART(dd, eDate) AS DateDay, DATEPART(hour, dateadd(hour,(datediff(hour,0,eDate)/6)*6,0)) AS DateHour FROM dbo.HomeLogGeneral   WHERE eDate > '" + dt.AddDays(-7).ToString("yyyy-MM-dd") + "' AND eDate < '" + dtEnd.ToString("yyyy-MM-dd") + "' GROUP BY dateadd(hour,(datediff(hour,0,eDate)/6)*6,0),  DATEPART(dd, eDate)";
            Repeater2.DataBind();
        
  
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
    public string CheckLen(string inval)
    {
        if (inval.Length <= 1)
        {
            return "0" + inval;
        }
        else
        {
            return inval;
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
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">

          
          
 
 <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <asp:Panel id="panel" runat="server">
    <script type="text/javascript">
        google.load("visualization", "1", { packages: ["corechart", 'gauge'] });
        google.setOnLoadCallback(drawChart);
        function drawChart() {
            var data = google.visualization.arrayToDataTable([
         ['Hour', 'Cylinder Top',  'Solar Collector', 'Home Temp', 'Pump Running'],
         <asp:Repeater ID="Repeater1" runat="server" DataSourceID="SqlDataSource1">
  <ItemTemplate>
     
      ['<%# CheckLen(DataBinder.Eval(Container.DataItem, "DateDay").ToString()) %>:<%# CheckLen(DataBinder.Eval(Container.DataItem, "DateHour").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "watertop") %>, <%# DataBinder.Eval(Container.DataItem, "waterpanel") %>, <%# DataBinder.Eval(Container.DataItem, "hometemp1") %>, <%# CheckPump(DataBinder.Eval(Container.DataItem, "pumprunning").ToString()) %>],

      
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
         ['Hour',  'Panel Current', '12 Out Current'],
         <asp:Repeater ID="Repeater2" runat="server" DataSourceID="SqlDataSourcePV">
  <ItemTemplate>
     
      ['<%# CheckLen(DataBinder.Eval(Container.DataItem, "DateDay").ToString()) %>:<%# CheckLen(DataBinder.Eval(Container.DataItem, "DateHour").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "solarc") %>, <%# DataBinder.Eval(Container.DataItem, "offgridc") %>],
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
         <asp:Repeater ID="RepeaterBattery" runat="server" DataSourceID="SqlDataSourceBattery">
  <ItemTemplate>
     
      ['<%# CheckLen(DataBinder.Eval(Container.DataItem, "DateDay").ToString()) %>:<%# CheckLen(DataBinder.Eval(Container.DataItem, "DateHour").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "batteryv") %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var optionsvoltage = {
              
                chartArea:{left:40,top:10,width:"80%",height:"70%"}
            };

            var chartvoltage = new google.visualization.LineChart(document.getElementById('chart_divVoltage'));
            chartvoltage.draw(datavoltage, optionsvoltage);

            

            // temps gauge chart
            <asp:Literal runat="server" id="gaugedata"></asp:Literal>
            
            var gaugechart = new google.visualization.Gauge(document.getElementById('gaugechart_div'));
            gaugechart.draw(gaugedata, gaugeoptions);
            // current gauge chart
            <asp:Literal runat="server" id="gaugecurrentdata"></asp:Literal>
            

            var gaugeCurrentchart = new google.visualization.Gauge(document.getElementById('gaugechart_current'));
            gaugeCurrentchart.draw(gaugecurrentdata, gaugecurrentoptions);
            

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
<asp:Content ID="ContentBar" ContentPlaceHolderID="ContentSide" Runat="Server">
<asp:Calendar ID="Calendar1" runat="server"  NextPrevFormat="ShortMonth" TitleStyle-BackColor="Transparent"
            OnSelectionChanged="Calendar1_SelectionChanged" CssClass="calendar1" NextPrevStyle-CssClass="calheader">
        </asp:Calendar>
    </asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <h1>Data for <asp:Literal ID="Literal1" runat="server"></asp:Literal></h1>
    <asp:Literal ID="Literal2" runat="server"></asp:Literal>
    <asp:Literal ID="litError" runat="server"></asp:Literal>
  <table width="100%">
        <tr>
            <td valign="top" style="width:80%;">
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

