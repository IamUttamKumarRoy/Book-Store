<!-- EditorialRecord -->

<%@ include file="Common.jsp" %>

<%@ page import = "javax.servlet.http.HttpServletRequest" %>
<%@ page import = "javax.servlet.jsp.JspWriter" %>
<%@ page import = "javax.servlet.http.HttpSession"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.util.*"%>
<%@ page import = "javax.servlet.http.HttpServletResponse" %>

<%!	static final String sFileName = "EditorialsRecord.jsp"; %>

<%
	String cSec = checkSecurity(2, session, response, request);
	if("sendRedirect".equals(cSec)) 
		return;
					
	boolean bDebug = false;

	String sAction = getParam( request, "FormAction");
	String sForm = getParam( request, "FormName");
	String seditorialsErr = "";

	Connection conn = null;
	Statement stat = null;
	String sErr = loadDriver();
	
	conn = cn();
	stat = conn.createStatement();
	
	if(!sErr.equals("")){
		try{
			out.println(sErr);
			}
		catch(Exception e) {}
		}
	
	if(sForm.equals("editorials")){
		seditorialsErr = editorialsAction(request, response, session, out, sAction, sForm, conn, stat);
		if("sendRedirect".equals(seditorialsErr)) 
			return;
		}
%>      
      
<html>

	<head>
		<title>Online Book Store</title>
		<meta http-equiv="pragma" content="no-cache"/>
		<meta http-equiv="expires" content="0"/>
		<meta http-equiv="cache-control" content="no-cache"/>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	</head>

	<body style="background-color: #FFFFFF; color: #000000; font-family: Arial, Tahoma, Verdana, Helveticabackground-color: #FFFFFF; color: #000000; font-family: Arial, Tahoma, Verdana, Helvetica">		
		<jsp:include page="Header.jsp" flush="true"/>
		
		<table>
			<tr>   
				<td valign="top">
					<% editorials_Show(request, response, session, out, seditorialsErr, sForm, sAction, conn, stat); %>    
				</td>
			</tr>
		</table>

		<jsp:include page="Footer.jsp" flush="true"/>
	</body>
	
</html>

<%
	if(stat != null) 
		stat.close();
	if(conn != null) 
		conn.close();
%>

<%!
	String editorialsAction(HttpServletRequest request, HttpServletResponse response, HttpSession session, JspWriter out, String sAction, String sForm, Connection conn, Statement stat) throws IOException{
		String seditorialsErr ="";
		
		try{
			if(sAction.equals("")) 
				return "";
			String sSQL="";
			String transitParams = "";
			String primaryKeyParams = "";
			String sQueryString = "";
			String sPage = "";
			String sParams = "";
			String sActionFileName = "EditorialsGrid.jsp";
			String sWhere = " ";
			boolean bErr = false;
			long iCount = 0;
  
			String pPKarticle_id = "";
			if(sAction.equalsIgnoreCase("cancel")){
				try{
					if(stat != null) 
						stat.close();
					if(conn != null)
						conn.close();
					}
				catch(SQLException ignore) {}
				
				response.sendRedirect (sActionFileName);
				return "sendRedirect";
				}

			final int iinsertAction = 1;
			final int iupdateAction = 2;
			final int ideleteAction = 3;
			int iAction = 0;

			if(sAction.equalsIgnoreCase("insert")){
				 iAction = iinsertAction; 
				 }
			if(sAction.equalsIgnoreCase("update")){ 
				iAction = iupdateAction; 
				}
			if(sAction.equalsIgnoreCase("delete")){ 
				iAction = ideleteAction; 
				}

			// Create WHERE statement
			if(iAction == iupdateAction || iAction == ideleteAction){ 
				pPKarticle_id = getParam( request, "PK_article_id");
				
				if(isEmpty(pPKarticle_id)) 
					return seditorialsErr;
				
				sWhere = "article_id=" + toSQL(pPKarticle_id, adNumber);
				}

			String fldarticle_desc="";
			String fldarticle_title="";
			String fldeditorial_cat_id="";
			String flditem_id="";
			String fldarticle_id="";

			// Load all form fields into variables
			fldarticle_desc = getParam(request, "article_desc");
			fldarticle_title = getParam(request, "article_title");
			fldeditorial_cat_id = getParam(request, "editorial_cat_id");
			flditem_id = getParam(request, "item_id");
      
			// Validate fields
			if(iAction == iinsertAction || iAction == iupdateAction){
				if(isEmpty(fldeditorial_cat_id)){
					seditorialsErr = seditorialsErr + "The value in field Editorial Category is required.<br>";
					}
				if(!isNumber(fldeditorial_cat_id)){
					seditorialsErr = seditorialsErr + "The value in field Editorial Category is incorrect.<br>";
					}
				if(!isNumber(flditem_id)){
					seditorialsErr = seditorialsErr + "The value in field Item is incorrect.<br>";
					}
				if(seditorialsErr.length() > 0){
					return (seditorialsErr);
					}
				}

			sSQL = "";
			// Create SQL statement
			switch(iAction){
				case iinsertAction :          
					sSQL = "insert into editorials (" + 
							"article_desc," +
							"article_title," +
							"editorial_cat_id," +
							"item_id)" +

							" values (" + 
							toSQL(fldarticle_desc, adText) + "," +
							toSQL(fldarticle_title, adText) + "," +
							toSQL(fldeditorial_cat_id, adNumber) + "," +
							toSQL(flditem_id, adNumber) + ")";
					break;
  
				case iupdateAction:        
					sSQL = "update editorials set " +
							"article_desc=" + toSQL(fldarticle_desc, adText) +
							",article_title=" + toSQL(fldarticle_title, adText) +
							",editorial_cat_id=" + toSQL(fldeditorial_cat_id, adNumber) +
							",item_id=" + toSQL(flditem_id, adNumber);
					sSQL = sSQL + " where " + sWhere;
					break;
      
				case ideleteAction:
					sSQL = "delete from editorials where " + sWhere;			
					break;
				}
				
			if(seditorialsErr.length() > 0) 
				return seditorialsErr;
      
			try{
				// Execute SQL statement
				stat.executeUpdate(sSQL);
				}
			catch(SQLException e){
				seditorialsErr = e.toString(); 
				return (seditorialsErr);
				}
  
			try{
				if(stat != null) 
					stat.close();
				if(conn != null)
					conn.close();
				}
			catch(SQLException ignore) {}
			
			response.sendRedirect (sActionFileName);
			return "sendRedirect";
			}
		catch(Exception e){
			out.println(e.toString()); 
			}
		return (seditorialsErr);
		}


	void editorials_Show(HttpServletRequest request, HttpServletResponse response, HttpSession session, JspWriter out, String seditorialsErr, String sForm, String sAction, Connection conn, Statement stat) throws IOException {
		try{
			String sSQL="";
			String sQueryString = "";
			String sPage = "";
			String sWhere = "";
			String transitParams = "";
			String transitParamsHidden = "";
			String requiredParams = "";
			String primaryKeyParams ="";
			Hashtable rsHash = new Hashtable();
      
			String particle_id = "";
			String fldarticle_id="";
			String fldarticle_desc="";
			String fldarticle_title="";
			String fldeditorial_cat_id="";
			String flditem_id="";
			boolean bPK = true;
	
			if("".equals(seditorialsErr)){
				// Load primary key and form parameters
				fldarticle_id = getParam( request, "article_id");
				particle_id = getParam( request, "article_id");
				}
			else{
				// Load primary key, form parameters and form fields
				fldarticle_id = getParam( request, "article_id");
				fldarticle_desc = getParam( request, "article_desc");
				fldarticle_title = getParam( request, "article_title");
				fldeditorial_cat_id = getParam( request, "editorial_cat_id");
				flditem_id = getParam( request, "item_id");
				particle_id = getParam( request, "PK_article_id");
				}

			if(isEmpty(particle_id)){ 
				bPK = false; 
				}
      
			sWhere += "article_id=" + toSQL(particle_id, adNumber);
			primaryKeyParams += "<input type=\"hidden\" name=\"PK_article_id\" value=\""+particle_id+"\"/>";

			sSQL = "select * from editorials where " + sWhere;

			out.println("<table style=\"\">");
			out.println("<tr>\n <td style=\"background-color: #336699; text-align: Center; border-style: outset; border-width: 1\" colspan=\"2\"><font style=\"font-size: 12pt; color: #FFFFFF; font-weight: bold\">Editorial</font></td>\n </tr>");
      
			if(!seditorialsErr.equals("")){
				out.println("<tr>\n <td style=\"background-color: #FFFFFF; border-width: 1\" colspan=\"2\"><font style=\"font-size: 10pt; color: #000000\">"+seditorialsErr+"</font></td>\n </tr>");
				}
			
			seditorialsErr="";
			out.println("<form method=\"get\" action=\""+sFileName+"\" name=\"editorials\">");

			ResultSet rs = null;

			if(bPK &&  !(sAction.equals("insert") && "editorials".equals(sForm))){
				// Open recordset
				rs = openrs( stat, sSQL);
				rs.next();
				String[] aFields = getFieldsName( rs );
				getRecordToHash( rs, rsHash, aFields );
				rs.close();
				fldarticle_id = (String) rsHash.get("article_id");
				
				if("".equals(seditorialsErr)){
					// Load data from recordset when form displayed first time
					fldarticle_desc = (String) rsHash.get("article_desc");
					fldarticle_title = (String) rsHash.get("article_title");
					fldeditorial_cat_id = (String) rsHash.get("editorial_cat_id");
					flditem_id = (String) rsHash.get("item_id");
					}

				if(sAction.equals("") || !"editorials".equals(sForm)){
					fldarticle_id = (String) rsHash.get("article_id");
					fldarticle_desc = (String) rsHash.get("article_desc");
					fldarticle_title = (String) rsHash.get("article_title");
					fldeditorial_cat_id = (String) rsHash.get("editorial_cat_id");
					flditem_id = (String) rsHash.get("item_id");
					}      
				}
			else{
				if("".equals(seditorialsErr)){
					fldarticle_id = toHTML(getParam(request,"article_id"));
					}
				}

			// Show form field      
			out.print("<tr>\n <td style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 10pt; color: #000000\">Article Description</font></td><td style=\"background-color: #FFFFFF; border-width: 1\">"); out.print("<input type=\"text\"  name=\"article_desc\" maxlength=\"\" value=\""+toHTML(fldarticle_desc)+"\" size=\"\">");
			out.println("</td>\n </tr>");
      
			out.print("<tr>\n <td style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 10pt; color: #000000\">Article Title</font></td><td style=\"background-color: #FFFFFF; border-width: 1\">"); out.print("<input type=\"text\"  name=\"article_title\" maxlength=\"200\" value=\""+toHTML(fldarticle_title)+"\" size=\"50\">");
			out.println("</td>\n </tr>");
      
			out.print("<tr>\n <td style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 10pt; color: #000000\">Editorial Category</font></td><td style=\"background-color: #FFFFFF; border-width: 1\">"); 
			out.print("<select name=\"editorial_cat_id\">"+getOptions( conn, "select editorial_cat_id, editorial_cat_name from editorial_categories order by 2",false,true,fldeditorial_cat_id)+"</select>");      
			out.println("</td>\n </tr>");
      
			out.print("<tr>\n <td style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 10pt; color: #000000\">Item</font></td><td style=\"background-color: #FFFFFF; border-width: 1\">"); 
			out.print("<select name=\"item_id\">"+getOptions( conn, "select item_id, name from items order by 2",false,false,flditem_id)+"</select>");     
			out.println("</td>\n </tr>");
      
			out.print("<tr>\n <td colspan=\"2\" align=\"right\">");

			if(bPK && !(sAction.equals("insert") && "editorials".equals(sForm))){
				out.print("<input type=\"submit\" value=\"Update\" onclick=\"document.editorials.FormAction.value = 'update';\">");
				out.print("<input type=\"submit\" value=\"Delete\" onclick=\"document.editorials.FormAction.value = 'delete';\">");
				out.print("<input type=\"submit\" value=\"Cancel\" onclick=\"document.editorials.FormAction.value = 'cancel';\">");
				out.print("<input type=\"hidden\" name=\"FormName\" value=\"editorials\"><input type=\"hidden\" value=\"update\" name=\"FormAction\">");
				}      
			else{
				out.print("<input type=\"submit\" value=\"Insert\" onclick=\"document.editorials.FormAction.value = 'insert';\">");
				out.print("<input type=\"submit\" value=\"Cancel\" onclick=\"document.editorials.FormAction.value = 'cancel';\">");
				out.print("<input type=\"hidden\" name=\"FormName\" value=\"editorials\"><input type=\"hidden\" value=\"insert\" name=\"FormAction\">");
				}
			
			out.print("<input type=\"hidden\" name=\"article_id\" value=\""+toHTML(fldarticle_id)+"\">");
			out.print(transitParamsHidden+requiredParams+primaryKeyParams);
			out.println("</td>\n </tr>\n </form>\n </table>");      
			}
		catch(Exception e){ 
			out.println(e.toString()); 
			}
		}

%>
