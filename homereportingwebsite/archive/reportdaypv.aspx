<%@ Page Title="Daily Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/archive/MasterPage.master" %>

<script runat="server">
   
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            setdata(DateTime.Now.AddHours(-3));
        }
    }
    
    protected void Calendar1_SelectionChanged(object sender, EventArgs e)
    {
       
        setdata(Calendar1.SelectedDate.Date);
    }
    
    public void setdata(DateTime dt){
       

      

            // pv data
            SqlDataSourcePV.SelectCommand = "SELECT TOP (100) AVG(solarc) AS solarc, DATEPART(hh, eDate) AS Hour , DATEPART(minute, dateadd(minute,(datediff(minute,0,eDate)/15)*15,0)) AS MinVal FROM dbo.HomeLog  WHERE  eDate > '" + dt.ToString("s") + "' GROUP BY dateadd(minute,(datediff(minute,0,eDate)/15)*15,0),  DATEPART(dw, eDate), DATEPART(hh, eDate), DATEPART(dd, eDate), DATEPART(mm, eDate), DATEPART(yyyy, eDate)";
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
           // pv chart

            var dataPV = google.visualization.arrayToDataTable([
         ['Hour', 'Panel Current'],
         <asp:Repeater ID="Repeater2" runat="server" DataSourceID="SqlDataSourcePV">
  <ItemTemplate>
     
      ['<%# CheckLen(DataBinder.Eval(Container.DataItem, "Hour").ToString()) %>:<%# CheckLen(DataBinder.Eval(Container.DataItem, "MinVal").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "solarc") %>],
  </ItemTemplate>
</asp:Repeater>
            ]);

            var optionsPV = {
               
                chartArea:{left:40,top:10,width:"80%",height:"70%"}
            };

            var chartPV = new google.visualization.LineChart(document.getElementById('chart_divPV'));
            chartPV.draw(dataPV, optionsPV);

           

        }
    </script>
</asp:Panel>
   
    

     <asp:SqlDataSource ID="SqlDataSourcePV" runat="server" 
        ConnectionString="<%$ ConnectionStrings:MainConn %>" >
    </asp:SqlDataSource>

  
   
   
</asp:Content>

<asp:Content ID="ContentBar" ContentPlaceHolderID="ContentSide" Runat="Server">
<asp:Calendar ID="Calendar1" runat="server"  NextPrevFormat="ShortMonth" TitleStyle-BackColor="Transparent"
            OnSelectionChanged="Calendar1_SelectionChanged" CssClass="calendar1" NextPrevStyle-CssClass="calheader">
        </asp:Calendar>
    </asp:Content>
    
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <h1>Data for last 3 Hours</h1>
    <asp:Literal ID="Literal2" runat="server"></asp:Literal>
    <asp:Literal ID="litError" runat="server"></asp:Literal>

           
                <h2>PV Current input</h2>
    <div id="chart_divPV" style="width: 100%; height:250px; "></div>
            
               
          
   
</asp:Content>

