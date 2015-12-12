<%@ Page Title="USB Smart Charger Report" Language="C#" MasterPageFile="~/archive/MasterPage.master" Debug="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
    protected void Page_Load(Object Src, EventArgs E)
    {
        Literal1.Text = GetReading();
    }


    public string GetReading()
    {

        System.Data.DataSet ds = new System.Data.DataSet();
        System.Data.SqlClient.SqlConnection objConn = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["MainConn"].ConnectionString);
        objConn.Open();
        System.Data.SqlClient.SqlDataAdapter daTax = new System.Data.SqlClient.SqlDataAdapter("SELECT * from ChargerData order by DateStamp ASC", objConn);
        daTax.FillSchema(ds, System.Data.SchemaType.Source, "ChargerData");
        daTax.Fill(ds, "ChargerData");
        daTax.Dispose();
        objConn.Close();

        StringBuilder sb = new StringBuilder();

        foreach (DataRow row in ds.Tables[0].Rows)
        {


            sb.Append("<tr>" + Environment.NewLine);
            sb.Append("<td>" + DateTime.Parse(row["DateStamp"].ToString()).ToString() + " </td>" + Environment.NewLine); // date
            sb.Append("<td>" + GetChargerfromID(row["ChargerID"].ToString()) + " </td>" + Environment.NewLine); // date
            sb.Append("<td>" + row["ChargingPower"].ToString() + " </td>" + Environment.NewLine); // date
            sb.Append("<td>" + row["ChargingTotal"].ToString() + " </td>" + Environment.NewLine); // date
            sb.Append("</tr>" + Environment.NewLine);
        }
        ds.Dispose();
        return sb.ToString();
    }

    public string GetChargerfromID(string id)
    {
        switch (id)
        {
            case "001EC025F3A5":
                return "Bedroom 1";
            case "001EC01A6644":
                return "Bedroom 2";
            case "001EC01A663D":
                return "Living Room";
            default:
                return "unknown";      
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
<!--
table.lists { width: 100%;}
table th { text-align: left;}
table td, table th { border-bottom: 1px dashed #ccc;}
-->
</style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <h1>USB Chargers</h1>
     <table border="0" cellspacing="0" cellpadding="0"  class="lists" >
                    <tr>
                        <th>Date</th>
                        <th>Charger</th>
                        <th>Charging W</th>
                        <th>Total Wh</th>
                    </tr>
         <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                </table>
          

</asp:Content>