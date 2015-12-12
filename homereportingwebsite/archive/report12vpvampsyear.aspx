<%@ Page Title="Daily Home Solar PV and Water Current Report" Language="C#" MasterPageFile="~/archive/MasterPage.master" %>

<script runat="server">
    System.Data.DataSet ds = new System.Data.DataSet();
    protected void Page_Load(object sender, EventArgs e)
    {
         
            System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
            objConn.Open();
            System.Data.SqlClient.SqlDataAdapter daTax = new System.Data.SqlClient.SqlDataAdapter("SELECT MAX(maxsolarc) as MAXTemp, CONVERT(date, EntryDate) as EntryDate FROM FullArchive GROUP BY CONVERT(date, EntryDate) order by CONVERT(date, EntryDate)", objConn);
            daTax.FillSchema(ds, System.Data.SchemaType.Source, "FullArchive");
            daTax.Fill(ds, "FullArchive");
            daTax.Dispose();
            objConn.Close();
        
        
        if (!IsPostBack)
        {
            DateTime startdate = new DateTime(2014,1, 1);
            maketable(startdate);
        }
    
       
    }

    public void maketable(DateTime dt)
    {
        StringBuilder sb = new StringBuilder();
   
        DateTime target = new DateTime(DateTime.Now.AddMonths(1).Year, DateTime.Now.AddMonths(1).Month, 1);
        sb.Append("<table>" + Environment.NewLine);


        sb.Append("<tr>" + Environment.NewLine);
        sb.Append("<th>&nbsp;" + Environment.NewLine);

        sb.Append("</th>" + Environment.NewLine);
        for (int i = 1; i <= 31; i++)
        {
            if (DateTime.Now.Day == i)
            {
                sb.Append("<th class=\"today\">" + i + "</th>" + Environment.NewLine);
            }
            else
            {
                sb.Append("<th>" + i + "</th>" + Environment.NewLine);  
            }
            
        }
       
        sb.Append("</tr>" + Environment.NewLine);
        
        while (dt < target)
        {
            
           
            
            
            sb.Append("<tr>" + Environment.NewLine);
            MakeMonth(dt, sb);
            sb.Append("</tr>" + Environment.NewLine);
            dt = dt.AddMonths(1);
        }
        sb.Append("</table>" + Environment.NewLine);
        Literal1.Text = sb.ToString();
    }

    public StringBuilder MakeMonth(DateTime dt, StringBuilder sb)
    {
        int daysInMonth = System.DateTime.DaysInMonth(dt.Year, dt.Month);
        if (DateTime.Now.Month == dt.Month && DateTime.Now.Year == dt.Year)
        {
            sb.Append("<td class=\"monthtitle today\">" + dt.ToString("MMM yyyy") + "</td>" + Environment.NewLine);
        }
        else
        {
            sb.Append("<td class=\"monthtitle\">" + dt.ToString("MMM yyyy") + "</td>" + Environment.NewLine);

        }
        
        
        
        for (int i = 0; i < daysInMonth; i++)
        {
            sb.Append(getDayMax(dt.AddDays(i)) + Environment.NewLine);
        }
        for (int i = daysInMonth; i < 31; i++)
        {
            sb.Append("<td>&nbsp;</td>" + Environment.NewLine);
        }
        return sb;
    }
    public string getDayMax(DateTime dt){

        //return dt.ToString("yyyy/MM/dd");
        string returnval = "<td>-</td>";
        System.Data.DataView dv = new System.Data.DataView(ds.Tables[0]);
        dv.RowFilter = "EntryDate = '" + dt.ToString("yyyy/MM/dd") + "'";
        if (dv.Count > 0)
        {
            returnval = "<td class=\"temp\" style=\"background: rgba(" + BlueColorvalue(dv[0]["MAXTemp"].ToString()) + ", " + RedColorvalue(dv[0]["MAXTemp"].ToString()) + ", 0 ,1);\">" + dv[0]["MAXTemp"].ToString() + "</td>";
            // returnval = "<td class=\"temp" + Math.Round(Double.Parse(dv[0]["MAXTemp"].ToString())).ToString().Substring(0, 1) + "\"><span style=\"background: rgba(255, 0, 0, " + bgvalue(dv[0]["MAXTemp"].ToString()) + ");\">" + Math.Round(Double.Parse(dv[0]["MAXTemp"].ToString())).ToString() + "</span></td>";
            
        }
      
        dv.Dispose();

        return returnval;
  
    }

    string bgvalue(string inval)
    {
       double outdbl =  Math.Round(Double.Parse(inval));
       outdbl = outdbl / 100;
       return outdbl.ToString("#.##");
    }
    string RedColorvalue(string inval)
    {
        double outdbl = Math.Round(Double.Parse(inval));
        outdbl = Math.Round(outdbl * 21);
        return outdbl.ToString();
    }
    string BlueColorvalue(string inval)
    {
        double outdbl = Math.Round(Double.Parse(inval));
        outdbl = Math.Round(255 - (outdbl * 21));
        return outdbl.ToString();
    }
    
  
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style>
        table {border-spacing: 1px; width: 100%;}
        th {background: #666; color: #fff; padding: 3px; font-weight: normal; text-align: center; font-size: 8pt;}
        td {  text-align: center; background: #eeeeee; font-size: 8pt; padding: 8px; width: 2.8%;}
        tr { }
        .monthtitle { text-align: right; padding: 3px 8px 3px 0; width: 100px;}
        .today {background:  #b0cf00;}
       .temp {color: #fff;}
       
  
    </style>

     
    

   

  
   
   
</asp:Content>

<asp:Content ID="ContentBar" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

             
                <h2>12V PV Charging Max Current</h2>
    
    <asp:Literal ID="Literal1" runat="server" EnableViewState="false"></asp:Literal>
 
</asp:Content>

