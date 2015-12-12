<%@ Page Title="Monthly Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<script runat="server">
   
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {

            SqlDataSource1.SelectCommand = "SELECT AVG(watertop) AS watertop, AVG(waterbase) AS waterbase, AVG(waterpanel) AS waterpanel, AVG(hometemp1) AS hometemp, AVG(solarc) AS solarc, AVG(offgridc) AS offgridc, AVG(batteryv) AS batteryv,  DATEPART(mm, eDate) AS DateMonth, DATEPART(yyyy, eDate) AS DateYear FROM   dbo.HomeLogGeneral GROUP BY DATEPART(mm, eDate), DATEPART(yyyy, eDate) order by DateYear asc, DateMonth asc";
            Repeater1.DataBind();
            
        
            Repeater2.DataBind();
            RepeaterBattery.DataBind();
     

         
            
                
                
                
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
         ['Hour', 'Cylinder Top',  'Solar Collector', 'Home Temp'],
         <asp:Repeater ID="Repeater1" runat="server" DataSourceID="SqlDataSource1">
  <ItemTemplate>
     
      ['<%# DataBinder.Eval(Container.DataItem, "DateYear") %>.<%# DataBinder.Eval(Container.DataItem, "DateMonth") %>', <%# DataBinder.Eval(Container.DataItem, "watertop") %>,  <%# DataBinder.Eval(Container.DataItem, "waterpanel") %>, <%# DataBinder.Eval(Container.DataItem, "hometemp") %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var options = {
                vAxis: { title: "Dec C" },
                hAxis: { title: "Month" },
                seriesType: "bars",
                series: { 5: { type: "line" } },
                chartArea:{left:60,top:10,width:"80%",height:"70%"}
            };
            

            var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));
            chart.draw(data, options);

            // pv chart

            var dataPV = google.visualization.arrayToDataTable([
         ['Hour', 'Panel Current', '12 Out Current'],
         <asp:Repeater ID="Repeater2" runat="server" DataSourceID="SqlDataSource1">
  <ItemTemplate>
     
      ['<%# DataBinder.Eval(Container.DataItem, "DateYear") %>.<%# DataBinder.Eval(Container.DataItem, "DateMonth") %>',  <%# DataBinder.Eval(Container.DataItem, "solarc") %>, <%# DataBinder.Eval(Container.DataItem, "offgridc") %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var optionsPV = {
               
                vAxis: { title: "Amps" },
                hAxis: { title: "Month" },
                seriesType: "bars",
                series: { 5: { type: "line" } },
                chartArea:{left:60,top:10,width:"80%",height:"70%"}
            };

            var chartPV = new google.visualization.ComboChart(document.getElementById('chart_divPV'));
            chartPV.draw(dataPV, optionsPV);

            // voltage 

            var datavoltage = google.visualization.arrayToDataTable([
         ['Hour', 'Volts'],
         <asp:Repeater ID="RepeaterBattery" runat="server" DataSourceID="SqlDataSource1">
  <ItemTemplate>
     
      ['<%# DataBinder.Eval(Container.DataItem, "DateYear") %>.<%# DataBinder.Eval(Container.DataItem, "DateMonth") %>', <%# DataBinder.Eval(Container.DataItem, "batteryv") %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var optionsvoltage = {
              
                vAxis: { title: "Voltage" },
                hAxis: { title: "Month" },
                seriesType: "bars",
                series: { 5: { type: "line" } },
                chartArea:{left:60,top:10,width:"80%",height:"70%"}
            };
            var chartvoltage = new google.visualization.ComboChart(document.getElementById('chart_divVoltage'));
            chartvoltage.draw(datavoltage, optionsvoltage);

           

        }
    </script>
</asp:Panel>
   
      <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:MainConn %>" >
    </asp:SqlDataSource>

  
    
    
   
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <h1>Monthly Average Data Report</h1>

    <asp:Literal ID="litError" runat="server"></asp:Literal>
   
                <h2>Temperature Sensors</h2>
 <div id="chart_div" style="width: 100%; height: 250px;"></div>
                <h2>Current Usage</h2>
    <div id="chart_divPV" style="width: 100%; height:250px; "></div>
                <h2>Battery Voltage</h2>
    <div id="chart_divVoltage" style="width: 100%; height: 250px; "></div>

</asp:Content>

