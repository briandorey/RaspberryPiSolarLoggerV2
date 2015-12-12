<%@ Page Title="Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/MasterPage.master" enableViewState="false"  Debug="false" %>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
		Response.AppendHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
Response.AppendHeader("Pragma", "no-cache"); // HTTP 1.0.
Response.AppendHeader("Expires", "0"); // Proxies.
        if (!IsPostBack)
        {

           
            

            System.Data.DataSet dsTax = new System.Data.DataSet();
            System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
            objConn.Open();
            System.Data.SqlClient.SqlDataAdapter daTax = new System.Data.SqlClient.SqlDataAdapter("SELECT TOP 1 * FROM dbo.HomeLogGeneral order by eDate DESC", objConn);
            daTax.FillSchema(dsTax, System.Data.SchemaType.Source, "HomeLogGeneral");
            daTax.Fill(dsTax, "HomeLogGeneral");
            daTax.Dispose();
            objConn.Close();

            LitDate.Text = DateTime.Parse(dsTax.Tables[0].Rows[0]["eDate"].ToString()).ToString("dddd dd MMM yyyy   HH:mm:ss"); ;

            LitHome.Text = dsTax.Tables[0].Rows[0]["hometemp1"].ToString();
            LitHome2.Text = dsTax.Tables[0].Rows[0]["hometemp2"].ToString();
            LitHome3.Text = dsTax.Tables[0].Rows[0]["hometemp3"].ToString();
            LitCollector.Text = dsTax.Tables[0].Rows[0]["waterpanel"].ToString();
          	LitCylinder.Text =  dsTax.Tables[0].Rows[0]["watertop"].ToString();
            LitCylinderBase.Text = dsTax.Tables[0].Rows[0]["waterbase"].ToString();
            
            if (dsTax.Tables[0].Rows[0]["pumprunning"].ToString().Equals("1"))
            {
                LitPump.Text = "Pump Running";
            }
            else
            {
                LitPump.Text = "Pump Stopped";
            }

           // LitBattery.Text = dsTax.Tables[0].Rows[0]["batteryv"].ToString() + "<span> volts</span>";
			LitBattery.Text = dsTax.Tables[0].Rows[0]["batteryv"].ToString();
			

            double solarcwatts = Double.Parse(dsTax.Tables[0].Rows[0]["batteryv"].ToString()) * Double.Parse(dsTax.Tables[0].Rows[0]["solarc"].ToString());
            LitPV.Text = formatKW(solarcwatts);
            LitPVAmps.Text = dsTax.Tables[0].Rows[0]["solarc"].ToString();
            
        
            double offgridcwatts = Double.Parse(dsTax.Tables[0].Rows[0]["batteryv"].ToString()) * Double.Parse(dsTax.Tables[0].Rows[0]["offgridc"].ToString());
            
            LitGeneral.Text =  formatKW(offgridcwatts);
            LitGeneralAmps.Text =  dsTax.Tables[0].Rows[0]["offgridc"].ToString();

          //  LitPVUsage.Text = formatKW(invertercwatts + offgridcwatts);
           // dsTax.Dispose();


                
        }
    }
	
	public string getcolour(double tempvalue, double maxval) {
		// 91c8a0 green
	//efad50 orange
	// f5332f red
		double lowcuttoff = (maxval / 100) * 40;
		double midcuttoff = (maxval / 100) * 60; 
		if (tempvalue <= lowcuttoff) {
			return "8ded80";
		}
		if (tempvalue <= midcuttoff) {
			return "efad50";
		}
		if (tempvalue > midcuttoff) {
			return "f82b15";
		}
		return "ccc";
	}
    public string formatKW(double watts)
    {
       // if (watts > 1000)
        //{
        //    return (watts / 1000).ToString("0.0") + "<span> Kw";
        //}
       // else
       // {
            return watts.ToString("0.");
        //}
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
<meta http-equiv="refresh" content="120" /> 

<asp:Panel id="panel" runat="server">
   
</asp:Panel>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:MainConn %>" >
    </asp:SqlDataSource>
    <style type="text/css">
   
.box h2 {color: #fff; position: absolute; bottom: 0; left: 10px;}
     .blue {background: #0094d9;}
     .green {background: #90bf02;}
     .box  span {font-size: 12pt; margin-left: 10px;}
     .box p.smaller {font-size: 12pt; padding: 0; margin: 10px 0 0 0; }
     
     .box p { font-size: 30pt; margin: 30px 0 0 0; padding: 0; font-weight: 300;}
	 .box p.running { font-size: 12pt; padding: 25px 0 0 0; padding: 0;}
     .box p.first { margin: 20px 0 0 0;}
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <h1><asp:Literal ID="LitDate" runat="server"></asp:Literal></h1>
  <div class="box green"><h2>Battery</h2>
                        <p class="first"><asp:Literal ID="LitBattery" runat="server"></asp:Literal><span>V</span></p>
                  <p><asp:Literal ID="LitGeneral" runat="server"></asp:Literal><span>watts</span></p>
                  <p><asp:Literal ID="LitGeneralAmps" runat="server"></asp:Literal><span>amps</span></p></div>
                      
   
                      
    <div class="box blue"><h2>Thermal</h2>
                    
                 <p class="first"><asp:Literal ID="LitCylinder" runat="server"></asp:Literal>&deg;<span>cyl top</span></p>
                     <p><asp:Literal ID="LitCylinderBase" runat="server"></asp:Literal>&deg;<span>cyl base</span></p>
                <p><asp:Literal ID="LitCollector" runat="server"></asp:Literal>&deg;<span>panel</span></p>
                <p class="smaller"><asp:Literal ID="LitPump" runat="server"></asp:Literal></p>


                </div>

           <div class="box green"><h2>Offgrid PV</h2>
                  <p class="first"><asp:Literal ID="LitPV" runat="server"></asp:Literal><span>watts</span></p>
                  <p><asp:Literal ID="LitPVAmps" runat="server"></asp:Literal><span>amps</span></p></div>
                     
                    <div class="box blue"><h2>Home</h2>
                    <p class="first"><asp:Literal ID="LitHome" runat="server"></asp:Literal>&deg;<span>Living Room</span></p>
                        <p><asp:Literal ID="LitHome2" runat="server"></asp:Literal>&deg;<span>Andrew Bedroom</span></p>
               <p><asp:Literal ID="LitHome3" runat="server"></asp:Literal>&deg;<span>Brian Bedroom</span></p>
          
           </div>
          <div style="clear: both;"></div>
</asp:Content>

