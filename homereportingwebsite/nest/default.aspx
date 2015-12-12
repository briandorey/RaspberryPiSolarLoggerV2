<%@ Page Title="Nest Usage Report" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">	  
        protected void Page_Load(Object Src, EventArgs E)
        {
            
        }
        public string formatTime(string datetime)
        {
            DateTime dt = DateTime.Parse(datetime);
        return "[" + dt.Hour + ", " + dt.Minute + ",0]";
            
            
           

       // decimal dec = Convert.ToDecimal(TimeSpan.Parse(datetime).TotalHours);
      //  return dec.ToString("#.##");
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">

 <script type="text/javascript" src="https://www.google.com/jsapi"></script>
 <script type="text/javascript">
        google.load("visualization", "1", { packages: ["corechart", 'gauge'] });
        google.setOnLoadCallback(drawChart);
        function drawChart() {

            var dataPV = google.visualization.arrayToDataTable([
         ['Date', 'CH', 'HW'],
         <asp:Repeater ID="Repeater2" runat="server" DataSourceID="SqlDataSourcePV">
  <ItemTemplate>
     
      ['<%# DateTime.Parse(DataBinder.Eval(Container.DataItem, "ReadingDate").ToString()).ToShortDateString() %>', <%# formatTime(DataBinder.Eval(Container.DataItem, "CHHours").ToString()) %>, <%# formatTime(DataBinder.Eval(Container.DataItem, "HWHours").ToString()) %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var optionsPV = {
               
                chartArea:{left:40,top:10,width:"80%",height:"70%"}
            };

            var chartPV = new google.visualization.LineChart(document.getElementById('chart_div'));
            chartPV.draw(dataPV, optionsPV);
        }
           
    </script>
      <asp:SqlDataSource ID="SqlDataSourcePV" runat="server" SelectCommand="Select * from Nest ORder By ReadingDate ASC" 
        ConnectionString="<%$ ConnectionStrings:MainConn %>" >
    </asp:SqlDataSource>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  
    <img src="nest_logo.png" />
    <h1>Central Heating & Hot Water Usage</h1>
    <div id="chart_div" style="width: 100%; height: 250px; margin-bottom: 10px;"></div>
  
</asp:Content>