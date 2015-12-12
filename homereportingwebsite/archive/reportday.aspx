<%@ Page Title="Daily Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/archive/MasterPage.master" Debug="true"  %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            System.Data.DataSet ds = new System.Data.DataSet();
            System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
            objConn.Open();
            System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter("SELECT top 1 EntryDate  FROM FullArchive order by EntryDate desc", objConn);
            da.FillSchema(ds, System.Data.SchemaType.Source, "FullArchive");
            da.Fill(ds, "FullArchive");
            da.Dispose();
            objConn.Close();

            
            setdata(DateTime.Parse(ds.Tables[0].Rows[0]["EntryDate"].ToString()));


            ds.Dispose();
        }
    }

    protected void Calendar1_SelectionChanged(object sender, EventArgs e)
    {

        setdata(Calendar1.SelectedDate.Date);

    }

    public void setdata(DateTime dt){
        Literal1.Text = dt.ToShortDateString();
        
        SqlDataSource1.SelectCommand = "SELECT TOP (100) PERCENT maxwatertop, maxwaterbase, maxwaterpanel, maxhometemp, EntryHour  FROM dbo.FullArchive WHERE EntryDate = '" + dt.ToString("s") + "' Order BY EntryHour ASC";
        Repeater1.DataBind();

       

        System.Data.DataSet dsTax = new System.Data.DataSet();
        System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
        objConn.Open();
        System.Data.SqlClient.SqlDataAdapter daTax = new System.Data.SqlClient.SqlDataAdapter("SELECT MAX(maxwaterbase) as maxwaterbase, MAX(maxbatteryv) AS maxbatteryv,MAX(maxwatertop) AS maxwatertop, MAX(maxwaterpanel) AS maxwaterpanel, MAX(maxhometemp) AS maxhometemp, MAX(maxmainsc) AS maxmainsc, MAX(maxsolarc) AS maxsolarc, MAX(maxgeneralc) AS maxgeneralc  FROM dbo.FullArchive  WHERE  (DATEPART(dd, EntryDate) = " + dt.ToString("dd") + ") AND (DATEPART(mm, EntryDate) = " + dt.ToString("MM") + ") AND (DATEPART(yyyy, EntryDate) = " + dt.ToString("yyyy") + ")", objConn);
        daTax.FillSchema(dsTax, System.Data.SchemaType.Source, "FullArchive");
        daTax.Fill(dsTax, "FullArchive");
        daTax.Dispose();
        objConn.Close();
        try
        {
            if (dsTax.Tables[0].Rows.Count > 0)
            {

                LitHome.Text = dsTax.Tables[0].Rows[0]["maxhometemp"].ToString() + "<span> &deg;C<span>";
                LitCollector.Text = dsTax.Tables[0].Rows[0]["maxwaterpanel"].ToString() + "<span> &deg;C<span>";
                LitCylinder.Text = dsTax.Tables[0].Rows[0]["maxwatertop"].ToString() + "<span> &deg;C<span>";
                // LitReturn.Text = dsTax.Tables[0].Rows[0]["maxwaterbase"].ToString() + "<span> &deg;C<span>";

                double maxsolarcwatts = Double.Parse(dsTax.Tables[0].Rows[0]["maxbatteryv"].ToString()) * Double.Parse(dsTax.Tables[0].Rows[0]["maxsolarc"].ToString());
                LitPV.Text = formatKW(maxsolarcwatts);
                LitPVAmps.Text = dsTax.Tables[0].Rows[0]["maxsolarc"].ToString() + " amp<span>";
               
                double maxgeneralcwatts = Double.Parse(dsTax.Tables[0].Rows[0]["maxbatteryv"].ToString()) * Double.Parse(dsTax.Tables[0].Rows[0]["maxgeneralc"].ToString());

                LitGeneral.Text = formatKW(maxgeneralcwatts);
                LitGeneralAmps.Text = dsTax.Tables[0].Rows[0]["maxgeneralc"].ToString() + " amp<span>";


            }
        }
        catch { }
        dsTax.Dispose();
       
        // pv data
        SqlDataSourcePV.SelectCommand = "SELECT maxmainsc, maxsolarc, maxgeneralc , EntryHour  FROM dbo.FullArchive WHERE EntryDate = '" + dt.ToString("s") + "' Order BY EntryHour ASC";
        Repeater2.DataBind();

        // battery data
        SqlDataSourceBattery.SelectCommand = "SELECT  maxbatteryv , EntryHour  FROM dbo.FullArchive WHERE EntryDate = '" + dt.ToString("s") + "' Order BY EntryHour ASC";
        RepeaterBattery.DataBind();
    

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
         ['Hour', 'Cylinder Top', 'Solar Collector', 'Home Temp'],
         <asp:Repeater ID="Repeater1" runat="server" DataSourceID="SqlDataSource1">
  <ItemTemplate>
     
      ['<%# CheckLen(DataBinder.Eval(Container.DataItem, "EntryHour").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "maxwatertop") %>,  <%# DataBinder.Eval(Container.DataItem, "maxwaterpanel") %>, <%# DataBinder.Eval(Container.DataItem, "maxhometemp") %>],

      
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
         ['Hour', 'Panel Current',  '12 Out Current','Mains Current'],
         <asp:Repeater ID="Repeater2" runat="server" DataSourceID="SqlDataSourcePV">
  <ItemTemplate>
     
      ['<%# CheckLen(DataBinder.Eval(Container.DataItem, "EntryHour").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "maxsolarc") %>, <%# DataBinder.Eval(Container.DataItem, "maxgeneralc") %>, <%# DataBinder.Eval(Container.DataItem, "maxmainsc") %>],
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
     
      ['<%# CheckLen(DataBinder.Eval(Container.DataItem, "EntryHour").ToString()) %>', <%# DataBinder.Eval(Container.DataItem, "maxbatteryv") %>],
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
    <h1>Data for <asp:Literal ID="Literal1" runat="server"></asp:Literal></h1>
    <asp:Literal ID="Literal2" runat="server"></asp:Literal>
    <asp:Literal ID="litError" runat="server"></asp:Literal>
<table width="100%">
        <tr>
            <td valign="top" style="width:  80%;">
                <h2>Temperature Sensors</h2>
 <div id="chart_div" style="width: 100%; height: 250px;"></div>
                <h2>Current Usage</h2>
    <div id="chart_divPV" style="width: 100%; height:250px; "></div>
                <h2>Battery Voltage</h2>
    <div id="chart_divVoltage" style="width:100%; height: 250px; "></div>
               
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
                            <h3><asp:Literal ID="LitPVAhours" runat="server"></asp:Literal></h3>
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
   <asp:Calendar ID="Calendar1" runat="server"  NextPrevFormat="ShortMonth" TitleStyle-BackColor="Transparent"
            OnSelectionChanged="Calendar1_SelectionChanged" CssClass="calendar1" NextPrevStyle-CssClass="calheader">
        </asp:Calendar>
</asp:Content>

