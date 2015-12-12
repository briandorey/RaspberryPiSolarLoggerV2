<%@ Page Title="Annual Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/archive/MasterPage.master" %>

<script runat="server">
  
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {

            SqlDataSource1.SelectCommand = "SELECT AVG(avgwatertop) AS avgwatertop, AVG(avgwaterbase) AS avgwaterbase, AVG(avgwaterpanel) AS avgwaterpanel, AVG(avgwhometemp) AS avgwhometemp, AVG(avgmainsc) AS avgmainsc, AVG(avgsolarc) AS avgsolarc, AVG(avggeneralc) AS avggeneralc , AVG(avgbatteryv) AS avgbatteryv, DATEPART(yyyy, EntryDate) AS DateYear FROM dbo.FullArchive GROUP BY  DATEPART(yyyy, EntryDate) order by DATEPART(yyyy, EntryDate) asc";
            Repeater1.DataBind();
            
        
            // pv data
         
            Repeater2.DataBind();

            // battery data
          
            Repeater2.DataBind();

         
            
                
                
                
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
         ['Hour', 'Cylinder Top', 'Solar Collector', 'Home Temp'],
         <asp:Repeater ID="Repeater1" runat="server" DataSourceID="SqlDataSource1">
  <ItemTemplate>
     
      ['<%# DataBinder.Eval(Container.DataItem, "Dateyear") %>', <%# DataBinder.Eval(Container.DataItem, "avgwatertop") %>, <%# DataBinder.Eval(Container.DataItem, "avgwaterpanel") %>, <%# DataBinder.Eval(Container.DataItem, "avgwhometemp") %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var options = {
               vAxis: { title: "Dec C" },
                hAxis: { title: "Year" },
                seriesType: "bars",
                series: { 5: { type: "line" } },
                chartArea:{left:60,top:10,width:"70%",height:"70%"}
            };
            

            var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));
            chart.draw(data, options);

            // pv chart

            var dataPV = google.visualization.arrayToDataTable([
         ['Hour', 'Panel Current', '12 Out Current','Mains Current'],
         <asp:Repeater ID="Repeater2" runat="server" DataSourceID="SqlDataSource1">
  <ItemTemplate>
     
      ['<%# DataBinder.Eval(Container.DataItem, "Dateyear") %>', <%# DataBinder.Eval(Container.DataItem, "avgsolarc") %>,  <%# DataBinder.Eval(Container.DataItem, "avggeneralc") %>, <%# DataBinder.Eval(Container.DataItem, "avgmainsc") %>],
  </ItemTemplate>
</asp:Repeater>
        ]);

            var optionsPV = {
               
                vAxis: { title: "Amps" },
                hAxis: { title: "Year" },
                seriesType: "bars",
                series: { 5: { type: "line" } },
                chartArea:{left:60,top:10,width:"70%",height:"70%"}
            };

            var chartPV = new google.visualization.ComboChart(document.getElementById('chart_divPV'));
            chartPV.draw(dataPV, optionsPV);

            // voltage 

            var datavoltage = google.visualization.arrayToDataTable([
         ['Hour', 'Volts'],
         <asp:Repeater ID="RepeaterBattery" runat="server" DataSourceID="SqlDataSource1">
  <ItemTemplate>
     
      ['<%# DataBinder.Eval(Container.DataItem, "Dateyear") %>', <%# DataBinder.Eval(Container.DataItem, "avgbatteryv") %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var optionsvoltage = {
              
                vAxis: { title: "Voltage" },
                hAxis: { title: "Year" },
                seriesType: "bars",
                series: { 5: { type: "line" } },
                chartArea:{left:60,top:10,width:"70%",height:"70%"}
            };

            var chartvoltage = new google.visualization.ComboChart(document.getElementById('chart_divVoltage'));
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
    <h1>Annual Average Data Report</h1>

    <asp:Literal ID="litError" runat="server"></asp:Literal>
                <h2>Temperature Sensors</h2>
 <div id="chart_div" style="width: 100%; height: 400px;"></div>
                <h2>Current Usage</h2>
    <div id="chart_divPV" style="width: 100%; height:400px; "></div>
                <h2>Battery Voltage</h2>
    <div id="chart_divVoltage" style="width: 100%; height: 400px; "></div>
         
</asp:Content>

