<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
  <xsl:output encoding="UTF-8" indent="yes" method="html" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>
  <xsl:param name="xslt">http://www.sec.gov/include/InstanceReport.xslt</xsl:param>
  <xsl:key name="keyParent" match="Report" use="ParentRole"/>
  <xsl:variable name="majorversion" select="substring-before(/FilingSummary/Version,'.')"/>
  <xsl:variable name="nreports" select="count(/FilingSummary/MyReports/Report)"/>
  <xsl:variable name="nbooks" select="count(/FilingSummary/MyReports/Report[ReportType='Book'])"/>
  <xsl:variable name="isrr" select="0 &lt; count(/FilingSummary/MyReports/Report[contains(Role,'http://xbrl.sec.gov/rr')])"/>
  <xsl:variable name="nlogs">
    <xsl:choose>
      <xsl:when test="count(/FilingSummary/Logs/*) > 0">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:template match="Report" mode="reportarray">
    <xsl:text>
        reports[</xsl:text>
    <xsl:value-of select="position()"/>
    <xsl:text>]="</xsl:text>
    <xsl:choose>
      <xsl:when test="string-length(HtmlFileName) &gt; 0">
        <xsl:value-of select="HtmlFileName"/>
      </xsl:when>
      <xsl:when test="string-length(XmlFileName) &gt; 0">
        <xsl:value-of select="XmlFileName"/>
      </xsl:when>
      <xsl:otherwise>all</xsl:otherwise>
    </xsl:choose>
    <xsl:text>";</xsl:text>
  </xsl:template>
  <xsl:template match="Report" mode="parentreportarray">
    <xsl:text>
        parentreport[</xsl:text>
    <xsl:value-of select="position()"/>
    <xsl:text>]=</xsl:text>
    <xsl:variable name="ParentRole" select="ParentRole"/>
    <xsl:variable name="n">
      <xsl:for-each select="../Report">
        <xsl:if test="$ParentRole = Role">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($n)>0">
        <xsl:value-of select="$n"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>-1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;</xsl:text>
  </xsl:template>
  <xsl:template match="FilingSummary">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <meta http-equiv="Cache-Control" content="no-cache"/>
        <title>View Filing Data</title>
        <script type="text/javascript" src="http://www.sec.gov/include/jquery-1.4.3.min.js"/>
        <script type="text/javascript" src="http://www.sec.gov/include/accordionMenu.js"/>
        <script type="text/javascript" src="Show.js"/>
        <link rel="stylesheet" type="text/css" href="http://www.sec.gov/include/interactive.css"/>
        <link rel="stylesheet" type="text/css" href="report.css"/>
        <link rel="stylesheet" type="text/css" href="http://www.sec.gov/include/print.css" media="print"/>
        <style type="text/css">
          #menu{
            font-family:Helvetica, Arial, sans-serif;
            font-size:11px;
          }
          
          ul#menu {
          list-style-type:none;
          margin:0;
          padding:0;
          width:15em;
          border:1px solid #333;
          background-color:#F5F5EB;
          }
          
          ul#menu ul{
            list-style-type:none;
            margin:0;
            padding:0;
            width:15em;
            background-color:#F5F5EB; 
          }
          
          ul#menu a{
            display:block;
            text-decoration:none;
          }
          
          ul#menu li{
            margin-top:1px;
          }
          
          ul#menu li a{
            background:#F3D673; 
            color:black;
            padding:0.5em;
          }
          
          ul#menu li a:hover{
            background:#aaa;
          }
          
          ul#menu li ul li a{
            background:#F5F5EB;
            color:#BF0023;
            padding-left:20px;
          }
          
          ul#menu li ul li a:hover{
            background:#aaa;
            border-left:5px #000 solid;
            padding-left:15px;
          }</style>

        <style type="text/css">
          li.accordion a{
            display:inline-block;
          }
          li.accordion a{
            display:block;
          }
          li.octave {border-top: 1px solid black;}
        </style>
        <script type="text/javascript">
          <xsl:text>var InstanceReportXslt = "</xsl:text>
          <xsl:value-of select="$xslt"/>
		  <xsl:text>";var renderingLogs = </xsl:text>
          <xsl:value-of select="$nlogs"/>
          <xsl:text>; var InstanceReportXsltDoc = null;
					var url_path = '';
					var filesummaryUrl = url_path+"FilingSummary.xml";
		  </xsl:text>
		  <xsl:text>var reports = new Array();</xsl:text>
          <!--
		  <xsl:apply-templates mode="reportarray" select="MyReports/Report"/>
          <xsl:if test="$nlogs > 0"><xsl:text>
			reports[</xsl:text><xsl:value-of select="$nreports + $nlogs "/>
                        <xsl:text>]="FilingSummary.xml";</xsl:text></xsl:if>
			-->
			<![CDATA[
          var parentreport = new Array();//]]>
                    <xsl:apply-templates mode="parentreportarray" select="MyReports/Report"/>                    
                    <xsl:text disable-output-escaping="yes">
		<![CDATA[

	function findTextForRegex(name,regex) {
       return name.match(regex);
   }

   function Menu(riskFlag) {

          this.prevCategory = -1;
          this.prevLongName;
           	if(riskFlag){
           	    this.coverCategory = 7;
           	}else{
           	    this.coverCategory = 0;
           	}
          this.cats = [];
          this.list = [];

            //initialize static variables
          this.titles = ["Cover", "Financial Statements",
                          "Notes to Financial Statements", "Accounting Policies",
                          "Notes Tables", "Notes Details", "Other", "Risk Return Reports",
                          "Uncategorized","",""];
          this.parentheticalRegex = ".*\\-.+-.*Parenth.+";
          this.policyRegex = ".*\\(.*Polic.*\\).*";
          this.statementRegex = ".*\\s\\-\\sStatement\\s\\-\\s.*";
          this.disclosureRegex = ".*\\s\\-\\sDisclosure\\s\\-\\s.*";
          this.tableRegex = ".*\\(\\s*Table.*\\).*";
          this.uncategorizedRegex = ".*Uncategorized.*";
          this.riskReturnRegex = ".*://xbrl\\.sec\\.gov\\/rr.*";
          this.detailRegex = ".*\\(\\s*Detail.*\\).*";
      }

      Menu.prototype = {

           addToList: function(role,longName,shortName,isInline) {
            var categoryIdx = -1;
            if (role == null) {
                // special case of a file entry.
                // shortName is the filename of the source file in the previewer, since we don't know doctype.
                longName = "~"; // character code 126, sure to be gt any longname.
                categoryIdx = isInline?9:10;
            } else if (findTextForRegex(role,this.uncategorizedRegex) || findTextForRegex(longName,this.uncategorizedRegex)) {
                // Assign to 'Uncategorized' category
                categoryIdx = 8;
            } else if (findTextForRegex(role,this.riskReturnRegex)) {
                // Assign to 'Risk Return Reports' category
                categoryIdx = 7;
            } else if (findTextForRegex(longName,this.detailRegex)) {
                // Assign to 'Detail' category
                categoryIdx = 5;
            } else if (findTextForRegex(longName,this.tableRegex)) {
                // Assign to 'Table' category
                categoryIdx = 4;
            } else if (findTextForRegex(longName,this.statementRegex) || findTextForRegex(longName,this.parentheticalRegex)) {
                // Assign to 'Financial Statements' category
                categoryIdx = 1;
            } else if (findTextForRegex(longName,this.disclosureRegex) && findTextForRegex(longName,this.policyRegex)) {
                // Assign to 'Policy' category
                categoryIdx = 3;
            } else if (this.prevLongName != null
                    && this.prevLongName.toUpperCase()>longName.toUpperCase()) {
                // Assign to 'Cover' category
                categoryIdx = this.coverCategory;
            } else if (this.prevCategory < 0) {
                // Assign to 'Cover' category
                categoryIdx = this.coverCategory;
            } else if (this.prevCategory < 3) {
                // Assign to 'Notes' category
                categoryIdx = 2;
            } else {
                // Assign to 'Other' category
                categoryIdx = 6;
            }
            if (categoryIdx !== this.prevCategory) {
                this.cats.push(categoryIdx);
                this.list.push([]);
            }
            this.list[this.list.length - 1].push(shortName);
            this.prevCategory = categoryIdx;
            this.prevLongName = longName;
        },

        add: function (child) {
            this.children.push(child);
        },

        remove: function (child) {
           var length = this.children.length;
           for (var i = 0; i < length; i++) {
               if (this.children[i] === child) {
                   this.children.splice(i, 1);
                   return;
               }
           }
        },

        get: function (i) {
            return this.children[i];
        },

        hasChildren: function () {
               return this.children.length > 0;
        }
      }

     function buildMenu(filesummaryData){
   	      //Process the xml to create Menu item

   		    var myreports = $(filesummaryData).find("FilingSummary > MyReports > Report");
   	        // Risk Flag
   		    var role = "";
   		    var riskFlag = false;
            var risk = "http://xbrl.sec.gov/rr/";

			if(myreports.length>0){
                // Looking for Risk Return filing
                myreports.each(function(idx,report){
                    var riskText = $(report).find("Role")
					.text().match('^http://xbrl.sec.gov/rr/');

                    if(riskText !== null && riskText.length>0){
                        riskFlag = true;
                        return false;
                    }
                });
            }

            $(myreports[0]).attr("instance");
            var menu = new Menu(riskFlag);
            var xbrlReportNames=[],xbrlReportFiles=[];
            var sourceFile = filesummaryData.getElementsByTagName("File");
            reports.push("");

			var instance='';
			myreports.each(function(idx,report){
				var longName='',shortName='',role='';

				longName = $(report).find("LongName").text();
				role = $(report).find("Role").text()
				shortName = $(report).find("ShortName").text()
				xbrlReportNames[idx] = shortName;

				/* All - <xmlFilename/> and <HtmlFilename/>*/
				if ("All Reports"!==shortName) {
					if (report.getElementsByTagName("XmlFileName").length>0) {
					   xbrlReportFiles[idx]=$(report.getElementsByTagName("XmlFileName")).text();
					}else if (report.getElementsByTagName("HtmlFileName").length>0) {
					   xbrlReportFiles[idx]=$(report.getElementsByTagName("HtmlFileName")).text();
					}
				 }else {
					xbrlReportFiles[idx]="All";
				 }

				if (true && report.hasAttribute("instance")) {
					 var s = report.getAttribute("instance");
					 if (s !== instance) { // we just found a new instance in this list
						 instance = s;
						 var doctype = null,original = null;
						 $(sourceFile).each(function(j,sourceNode){
								var nt = $(sourceNode).text();
							if (nt === instance) {
								$(sourceNode.attributes).each(function(k,attribute){
									if ("doctype" === attribute.name) {
										doctype = attribute.nodeValue;
									} else if ("original" === attribute.name) {
										original = attribute.nodeValue;
									}
								});
								if (doctype !== null && original !== null) {
									 // a link to the inline original file goes here.
									 menu.addToList(null,"",original,instance === original);
								}
							}
						 });
					 }
				};

				if (longName.length > 0 && xbrlReportNames[idx].length > 0) {
					if (xbrlReportNames[idx]!=="All Reports") {
					   if (riskFlag) {
						  menu.addToList(risk, longName, xbrlReportNames[idx],false);
					   }
					   else {
						  menu.addToList(role, longName, xbrlReportNames[idx],false);
					   }
					}
				}

				if ("All"!==xbrlReportFiles[idx]){
					reports.push(url_path+xbrlReportFiles[idx]);
				}
			});

			reports.push("all");
			if(renderingLogs===1){
				reports.push(filesummaryUrl);
			}


   			var menuTag = ' ' ,prevIdx = 0;count = 1
            for(var i=0;i<menu.list.length;i++){
                var tmpList = menu.list[i];
                var idx = menu.cats[i];
                if(tmpList.length>0){
                    if(idx===9){  // top level link to inline file.
                        menuTag = menuTag.concat('<li class="accordion');
                        if(prevIdx !== 0){
                            menuTag = menuTag.concat(' octave');
                        }
                        menuTag = menuTag.concat('" >').concat('<a target="new" href="ix?doc='+ url_path + tmpList[0]+'">'+tmpList[0]+'</a></li>');
                    }else if(idx===10){   // top level link to non-inline file (the previewer never creates these; this is for symmetry with viewer.pl).
                        menuTag = menuTag.concat('<li class="accordion');
                        if(prevIdx !== 0){
                            menuTag = menuTag.concat(' octave');
                        }
                        menuTag = menuTag.concat('" >').concat('<a target="new" href="/'+ url_path + tmpList[0]+'">'+tmpList[0]+'</a></li>');
                    }else{
                        menuTag = menuTag.concat('<li class="accordion');
                        if(idx < prevIdx && prevIdx < 9){
                            menuTag = menuTag.concat(' octave');
                        }
                        menuTag = menuTag.concat('" >').concat('<a id="menu_cat'+idx+'" href="#">'+menu.titles[idx]+'</a><ul>');
                        $(tmpList).each(function(index,item){
                            menuTag = menuTag.concat('<li class="accordion"><a class="xbrlviewer" onClick="javascript:highlight(this);" href="javascript:loadReport('+count+');">')
                                      .concat(item+'</a></li>');
                            count++;
                        });
                        menuTag = menuTag.concat('</ul></li>');

                    }
					prevIdx = idx;
                }
			}

            /* If there was at least one report then show the 'All Reports' item */
            if(count>1){
                menuTag = menuTag.concat('<li class="accordion"><a href="javascript:loadReport('+count+');"><img src="images/reports.gif" border="0" height="12" width="9" alt="Reports" />All Reports</a></li>');
                count++;
            }

            if(renderingLogs===1){
                menuTag = menuTag.concat('<li class="accordion"><a href="javascript:loadReport('+count+');"><img src="images/reports.gif" border="0" height="12" width="9" alt="Logs" />Rendering Log</a></li>');
            }

			$("#menu").empty();
   			$("#menu").append(menuTag)
   			initMenu();
      }

      function loadFilingSummaryDoc(url) {
         $.ajax({
   		type: "GET",
   		url: url,
   		dataType: "xml",
   		async: false,
   		success: function(filesummaryData) {
             if($(filesummaryData).find('Report')){
                buildMenu(filesummaryData);
             }
   		},
   		error: function(msg) {
   			alert("Failed to process XML file:");
			console.log("Failed to process the file:"+msg);
   		}
   		});

    }

   function loadXmlDoc(url) {
      var doc;
      var jqxhr=$.ajax({type: "GET",
                        url: url,
                        async: false});                        
      // code for IE
      if (window.ActiveXObject) {
         doc = new ActiveXObject("Msxml2.FreeThreadedDOMDocument.3.0");
         doc.loadXML(jqxhr.responseText);
      }      
      // code for other browsers
      else if (document.implementation && document.implementation.createDocument) {
         doc=document.implementation.createDocument("","",null);
         doc.async=true;
         doc = jqxhr.responseXML.documentElement;
      }      
      return doc;
   }
   
   function fixSrcAttr(src) {
      var url_path = "";
      var uri = src.substr(0,5);
      // No change is needed if the 'src' attribute contains an embedded image
      if (uri == 'data:') {
         return src;
      }
      // Absolute URL on EDGAR website is unchanged
      var idx = src.lastIndexOf('http://www.sec.gov/Archives/edgar/data/')
      if (idx > -1) {
        return src;
      } // For all other URLs use only basename component
      var idx = src.lastIndexOf('/');
      if (idx > -1) {
         src = src.substring(idx+1,src.length);
      }
      return url_path + src;
   }
   
   function getReport(url, xsl_url) {
      if (xsl_url == null) { xsl_url = InstanceReportXslt; }
      var ext = url.substring(url.lastIndexOf('.')+1, url.length);
      if (ext == 'htm') {
          $.ajax({
          type: "GET",
          url: url,
          dataType: "text",
          async:false,
          success: function (data) { jQuery('#reportDiv').append(data)
                  .find('img').attr('src', function(i, val) { return fixSrcAttr(val);}).end();
              }
          });            
      } else {
          $.ajax({
          type: "GET",
          url: url,
          dataType: "text",
          async: false,
          success: function(data) {
                  data = data.replace(/^\s+|\s+$/g, ''); // leading or trailing whitespace causes problems
                  var path="/" + url.substring(1, url.lastIndexOf('/')+1);
                  
                  // code for IE
                  if (window.ActiveXObject) {                  
                     xsl_doc = loadXmlDoc(xsl_url)
                     var xslt = new ActiveXObject("Msxml2.XSLTemplate.3.0");   
                     xslt.stylesheet = xsl_doc;
                     var xslproc = xslt.createProcessor();
                     var doc = new ActiveXObject("Msxml2.FreeThreadedDOMDocument.3.0");
                   	 doc.loadXML(data);
                     xslproc.input = doc;
                     xslproc.addParameter("source", path );
                     xslproc.transform();
                     // Find all images and prepend the base URL to the src attribute
                     jQuery('#reportDiv').append(jQuery(xslproc.output)
                                         .find('img')
                                         .attr('src', function(i, val) {
                                                         return fixSrcAttr(val);
                                                      }).end());
                  }                  
                  // code for other browsers
                  else if (document.implementation && document.implementation.createDocument) {
                     xsltProcessor=new XSLTProcessor();
                     xsltProcessor.importStylesheet(loadXmlDoc(xsl_url));                     
                     xsltProcessor.setParameter(null,"source",path);
                     parser = new DOMParser();
                     xmlDoc = parser.parseFromString(data, "text/xml");
                     var rpt = xsltProcessor.transformToFragment(xmlDoc, document);
                     document.getElementById("reportDiv").appendChild(rpt);
                     FixNotesForGeckoWebkit( document.getElementById( 'reportDiv' ) );
                     // Find all images and prepend the base URL to the src attribute
                     jQuery('#reportDiv').find('img')
                                         .attr('src', function(i, val) {
                                                         return fixSrcAttr(val);
                                                      });
                  } else {
                     alert('Your browser cannot handle this script');
                  }
                }
            });
               }
   }
   
   function clearReportDiv() {
      // code for IE
      if (window.ActiveXObject) {
         document.getElementById("reportDiv").innerHTML='';
      }
      
      // code for Mozilla, Firefox, Opera, etc.
      else if (document.implementation && document.implementation.createDocument) {
         x = document.getElementById("reportDiv").childNodes;
         for (i=x.length-1;i>-1;i--) {
            node = document.getElementById("reportDiv").childNodes[i];
            if (node) {
               document.getElementById("reportDiv").removeChild(node);
            }
         }
      }
   }
   
   function loadReport(idx) {
      if (window.XMLHttpRequest || window.ActiveXObject) {
         clearReportDiv();
         xsl_url = null;
         if (reports[idx].indexOf('FilingSummary.xml') > -1) {
            unHighlightAllMenuItems();
            xsl_url="RenderingLogs.xslt";
         } 
         if (reports[idx] == 'all') {
            highlightAllMenuItems();
            jQuery.ajaxSetup({async:false});
            for (var i=1; i<reports.length; i++) {
               if (reports[i] != 'all') {
                  getReport(reports[i], xsl_url);
               } else {
               break;
               }
            }
         }
         else { 
            getReport(reports[idx], xsl_url);
         }
         window.scrollTo(0,0);
      }
      
      else {
         alert('Your browser cannot handle this script');
      }
   }
   
   function highlight(link) {
      var parent = document.getElementById( 'menu' );
      var links = parent.getElementsByTagName( 'a' );
      
      for (var i = 0; i < links.length; i++){
         if (links[i].className == 'xbrlviewer') {
            if (links[i] == link) {
               link.style.background = "#C1CDCD";
            } else {
               links[i].style.background = "#F5F5EB";
            }
         }
      }
   }
   
   //the parameter 'div' represents <div id="reportDiv">
   function FixNotesForGeckoWebkit( div ){
      //textContent is only found in "other" browsers
      //if it exists, search it for our table - there should only be one
      if( div.textContent ){
         var tables = div.getElementsByTagName( 'table' );
         if( tables.length ){
            //loop through the tables
           for( var t = 0; t < tables.length; t++ ){
              var cells = tables[t].getElementsByTagName( 'td' );
              //loop through the cells, checking for class="text" which indicates some kind of text content - this includes HTML for notes
              for( var i = 0; i < cells.length; i++ ){
                 var curCell = cells[ i ];
                 if( curCell.className == 'text' ){
                    //<td class="text" found - now check if this HTML had already been rendered - if so, we should not attempt to render it again
                    var nodes = curCell.getElementsByTagName( '*' );
                    if( nodes.length <= 1 ){
                       //no "nodes" found so perform a secondary check that we have text which resembles HTML
                       nodes = curCell.textContent.match( /<\/?[a-zA-Z]{1}\w*[^>]*>/g );
                       if( nodes && nodes.length ){
                          //this text does resemble HTML, use the textContent as HTML and that will convert the text to HTML content.
                          curCell.innerHTML = curCell.textContent;
                        }
                     }        
                  }
               }
            }
         }
      }
   } 
  
   window.onload = function () {
         if (window.location.href.substring(0,5)=='file:') {
          ableToOpenReportFiles = 0;
          try {
			$.ajax({
			       type: "GET",
				   url: filesummaryUrl,
				   dataType: "xml",
				   async:false,
				   success: function (data) {
						if (data != 0){
							buildMenu(data);
							ableToOpenReportFiles = 1;
						}
				   }
			});
          } catch (err) {
			console.log(err);
		  }

		  if (ableToOpenReportFiles == 0) {
				alert("In this browser environment, opening the url\n"
				+window.location.href
				+"\nprevents individual report files such as "
				+reports[1]+" from opening.");
		   }else{
			 //loadFilingSummaryDoc(fileSummaryUrl);
			 loadReport(1);
		   }
		}

	}
]]></xsl:text>
                </script>
      </head>
      <body style="margin: 0">
        <noscript>
          <div style="color:red; font-weight:bold; text-align:center;">This page uses Javascript. Your browser either doesn't support Javascript or you have it turned off. To see this page as it is meant to appear please use a Javascript enabled browser.</div>
        </noscript>
        <div>
          <table>
            <tr>
              <td colspan="2"><a class="xbrlviewer" style="color: black; font-weight: bold;" href="javascript:window.print();">Print Document</a><xsl:if test="not($isrr)">&#160;<a class="xbrlviewer" href="Financial_Report.xlsx">View Excel Document</a></xsl:if></td>
            </tr>
            <tr>
              <td style="vertical-align: top;">
                <div style="width: 170px; margin-right: 5px;">
                  <ul id="menu">
                    <xsl:call-template name="menuGroups">
                      <xsl:with-param name="depth">0</xsl:with-param>
                      <xsl:with-param name="position">1</xsl:with-param>
                      <xsl:with-param name="menucat">0</xsl:with-param>
                    </xsl:call-template>
                  </ul>
                </div>
              </td>
              <td style="vertical-align: top;">
                <div id="reportDiv"/>
              </td>
            </tr>
          </table>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="menuGroups">
    <!-- tail recursive template over myReports, current context FilingSummary -->
    <!-- note that the thing callsed menu_cat0, menu_cat1, refers only to the numerical sequence -->
    <!-- the thing called menu_name refers to the symbolic name such as "Cover", "Notes", etc. -->
    <xsl:param name="depth"/>
    <xsl:param name="position"/>
    <xsl:param name="menucat"/>
    <xsl:param name="prev_instance"/>
    <xsl:variable name="instance">
      <xsl:value-of select="(MyReports/Report[position()=$position]/@instance)" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count(MyReports/*[position() >= $position and Role])=0">
        <!-- we reached the very end of the list -->
        <xsl:if test="$nbooks > 0">
          <li class="accordion">
            <!-- final menu items stand on their own -->
            <a><xsl:attribute name="href">
                <xsl:text>javascript:loadReport(</xsl:text>
                <xsl:value-of select="$nreports"/>
                <xsl:text>)</xsl:text>
              </xsl:attribute><img src="http://www.sec.gov/images/reports.gif" border="0" height="12" width="9" alt="Reports"/>All Reports</a>
          </li>
        </xsl:if>
        <xsl:if test="$nlogs > 0">
          <li class="accordion">
            <a><xsl:attribute name="href">
                <xsl:text>javascript:loadReport(</xsl:text>
                <xsl:value-of select="$nreports + $nlogs "/>
                <xsl:text>)</xsl:text>
              </xsl:attribute><img src="http://www.sec.gov/images/reports.gif" border="0" height="12" width="9" alt="Logs"/>Rendering Log</a>
          </li>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$isrr">
        <li class="accordion">
          <a id="menu_cat0" href="#">Risk Return Reports</a>
          <ul>
            <xsl:for-each select="MyReports/Report[Role]">
              <li class="accordion" style="margin-left:{$depth * 2}em">
                <a class="xbrlviewer" onClick="javascript:highlight(this);">
                  <xsl:attribute name="href">
                    <xsl:text>javascript:loadReport(</xsl:text>
                    <xsl:value-of select="(position()) + ($position - 1)"/>
                    <xsl:text>);</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="ShortName"/>
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </li>
        <xsl:call-template name="menuGroups">
          <xsl:with-param name="depth" select="$depth"/>
          <xsl:with-param name="position" select="1 + count(MyReports/Report)"/>
          <xsl:with-param name="menucat" select="1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="true()">
        <xsl:variable name="this_cat">
          <xsl:for-each select="MyReports/Report[position()=$position]">
            <xsl:call-template name="menu_name">
              <xsl:with-param name="atstart">
                <xsl:value-of select="$menucat = 0 or $instance != $prev_instance"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="next_cat_position">
          <xsl:call-template name="next_cat_position">
            <xsl:with-param name="cat" select="$this_cat"/>
            <xsl:with-param name="pos" select="(1 + $position)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$instance != $prev_instance">
          <xsl:variable name="doctype">
            <xsl:value-of select="(/FilingSummary/InputFiles/File[.=$instance]/@doctype)"/>
          </xsl:variable>
          <xsl:variable name="original">
            <xsl:value-of select="(/FilingSummary/InputFiles/File[.=$instance]/@original)"/>
          </xsl:variable>
          <xsl:variable name="instance_is_inline">
            <xsl:value-of select="translate(substring($instance,string-length($instance)-3),'HTM','htm') = '.htm'"/>
          </xsl:variable>
          <xsl:if test="$original != ''">
              <li class="accordion octave">
                <xsl:choose>
                  <xsl:when test="$instance_is_inline = 'true'">
                    <a href="http://hq-dera-d44941:8080/vf/cbe/index.html?file={$original}&amp;xbrl=true"><xsl:value-of select="$doctype"/></a>
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="http://hq-dera-d44941:8080/vf/documents/{$original}"><xsl:value-of select="$doctype"/></a>
                  </xsl:otherwise>
                </xsl:choose>                
              </li>              
           </xsl:if>
        </xsl:if>        
        <xsl:variable name="octave_divider">
          <xsl:choose>
            <xsl:when test="$menucat = 0 and not($instance)"> octave</xsl:when>
            <xsl:when test="$instance != $prev_instance and not(/FilingSummary/InputFiles/File[.=$instance]/@original)"> octave</xsl:when>
            <xsl:otherwise></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <li class="accordion{$octave_divider}">
          <a id="menu_cat{$menucat}" href="#">
            <xsl:value-of select="$this_cat"/>
          </a>
          <ul>
            <xsl:for-each select="MyReports/Report[Role and position() >= $position and position() &lt; $next_cat_position]">
              <li class="accordion" style="margin-left:{$depth * 2}em">
                <a class="xbrlviewer" onClick="javascript:highlight(this);">
                  <xsl:attribute name="href">
                    <xsl:text>javascript:loadReport(</xsl:text>
                    <xsl:value-of select="(position()) + ($position - 1)"/>
                    <xsl:text>);</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="ShortName"/>
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </li>
        <!-- tail recursion -->
        <xsl:call-template name="menuGroups">
          <xsl:with-param name="depth" select="($depth)"/>
          <xsl:with-param name="position" select="$next_cat_position"/>
          <xsl:with-param name="menucat" select="($menucat + 1)"/>
          <xsl:with-param name="prev_instance" select="$instance"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="MenuItem">
    <!-- Current context is a Report element -->
    <xsl:param name="Pos"/>
    <xsl:param name="Cat"/>
    <xsl:param name="Depth">0</xsl:param>
    <li class="accordion" style="margin-left:{$Depth * 2}em">
      <a class="xbrlviewer" onClick="javascript:highlight(this);">
        <xsl:attribute name="href">
          <xsl:text>javascript:loadReport(</xsl:text>
          <xsl:value-of select="$Pos"/>
          <xsl:text>);</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="ShortName"/>
      </a>
      <xsl:variable name="ThisRole" select="Role"/>
      <xsl:if test="key('keyParent',$ThisRole)">
        <ul>
          <xsl:for-each select="key('keyParent',$ThisRole)">
            <xsl:sort data-type="text" select="LongName"/>
            <xsl:call-template name="MenuItem">
              <xsl:with-param name="Pos" select="Position"/>
              <xsl:with-param name="Cat" select="MenuCategory"/>
              <xsl:with-param name="Depth" select="1 + $Depth"/>
            </xsl:call-template>
          </xsl:for-each>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template name="next_cat_position">
    <!-- current context is FilingSummary -->
    <xsl:param name="pos"/>
    <xsl:param name="cat"/>
    <xsl:variable name="that">
      <xsl:for-each select="MyReports/Report[position() = $pos]">
        <xsl:call-template name="menu_name">
          <xsl:with-param name="atstart">false</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$that != $cat">
        <xsl:value-of select="$pos"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="next_cat_position">
          <xsl:with-param name="pos" select="($pos + 1)"/>
          <xsl:with-param name="cat" select="$cat"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="menu_name">
    <xsl:param name="atstart"/>
    <xsl:variable name="is6">
      <xsl:call-template name="isUncategorized"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$is6='true'">Uncategorized</xsl:when>
      <xsl:otherwise>
        <xsl:variable name="is5">
          <xsl:call-template name="isDetail"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$is5='true'">Notes Details</xsl:when>
          <xsl:otherwise>
            <xsl:variable name="is4">
              <xsl:call-template name="isTable"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$is4='true'">Notes Tables</xsl:when>
              <xsl:otherwise>
                <xsl:variable name="is3">
                  <xsl:call-template name="isPolicy"/>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$is3='true'">Accounting Policies</xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="is2">
                      <xsl:call-template name="isDisclosure"/>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$is2='true'">Notes to Financial Statements</xsl:when>
                      <xsl:otherwise>
                        <xsl:variable name="is1">
                          <xsl:call-template name="isStatement"/>
                        </xsl:variable>
                        <xsl:choose>
                          <xsl:when test="$is1='true'">Financial Statements</xsl:when>
                          <xsl:when test="$atstart='true'">Cover</xsl:when>
                          <xsl:otherwise>Other</xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="isUncategorized">
    <xsl:value-of select="LongName='Uncategorized Items' or Role='http://xbrl.sec.gov/role/uncategorizedFacts'"/>
  </xsl:template>

  <xsl:template name="isStatement">
    <!-- '.* +\- +Statement +\- .*' -->
    <xsl:variable name="p1" select="substring-after(LongName,'- ')"/>
    <xsl:variable name="p2" select="substring-after($p1,'Statement ')"/>
    <xsl:variable name="p3" select="substring-after($p2,'- ')"/>
    <xsl:value-of select="string-length($p3) &gt; 0"/>
  </xsl:template>

  <xsl:template name="isDisclosure">
    <!-- '.* +\- +Disclosure +\- .*' -->
    <xsl:variable name="p1" select="substring-after(LongName,'- ')"/>
    <xsl:variable name="p2" select="substring-after($p1,'Disclosure ')"/>
    <xsl:variable name="p3" select="substring-after($p2,'- ')"/>
    <xsl:value-of select="string-length($p3) &gt; 0"/>
  </xsl:template>

  <xsl:template name="isParenthetical">
    <!-- '.*\-.+-.*Paren.+' -->
    <xsl:variable name="p1" select="substring-after(LongName,'- ')"/>
    <xsl:variable name="p2" select="substring-after($p1,'- ')"/>
    <xsl:variable name="p3" select="substring-after($p2,'Paren')"/>
    <xsl:value-of select="string-length($p3) &gt; 0"/>
  </xsl:template>

  <xsl:template name="isPolicy">
    <!-- '.*\(.*Polic.*\).*' -->
    <xsl:variable name="p1" select="substring-after(LongName,'- ')"/>
    <xsl:variable name="p2" select="substring-after($p1,'- ')"/>
    <xsl:variable name="p3" select="substring-after($p2,'(Polic')"/>
    <xsl:value-of select="string-length($p3) &gt; 0"/>
  </xsl:template>

  <xsl:template name="isTable">
    <!-- '.*\(.*Table.*\).*' -->
    <xsl:variable name="p1" select="substring-after(LongName,'- ')"/>
    <xsl:variable name="p2" select="substring-after($p1,'- ')"/>
    <xsl:variable name="p3" select="substring-after($p2,'(Table')"/>
    <xsl:value-of select="string-length($p3) &gt; 0"/>
  </xsl:template>

  <xsl:template name="isDetail">
    <!-- '.*\(.*Detail.*\).*' -->
    <xsl:variable name="p1" select="substring-after(LongName,'- ')"/>
    <xsl:variable name="p2" select="substring-after($p1,'- ')"/>
    <xsl:variable name="p3" select="substring-after($p2,'(Detail')"/>
    <xsl:value-of select="string-length($p3) &gt; 0"/>
  </xsl:template>
  
  <!--
  <xsl:template name="MenuCategory">
    <xsl:param name="CatNum"/>
    <xsl:param name="CatName"/>
    <xsl:variable name="MenuCategories" select="count(Report[MenuCategory])"/>
    <xsl:choose>
      <xsl:when test="$MenuCategories=0"/>
      <xsl:when test="count(Report[MenuCategory=$CatName and string-length(ParentRole)=0])>0">
        <li class="accordion">
          <a id="menu_cat{$CatNum}" href="#">
            <xsl:value-of select="$CatName"/>
          </a>
          <ul>
            <xsl:for-each select="Report[Role]">
              <xsl:if test="string-length(ParentRole)=0">
                <xsl:call-template name="MenuItem">
                  <xsl:with-param name="Pos" select="position()"/>
                  <xsl:with-param name="Cat" select="$CatName"/>
                </xsl:call-template>
              </xsl:if>
            </xsl:for-each>
          </ul>
        </li>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="DrillUp">
    <xsl:param name="Pos" select="position()"/>
    <a>
      <xsl:attribute name="href">
        <xsl:text>javascript:loadReport(</xsl:text>
        <xsl:value-of select="$Pos"/>
        <xsl:text>);</xsl:text>
      </xsl:attribute>up</a>
  </xsl:template>
  <xsl:template name="DrillDowns">
  </xsl:template>
  -->
</xsl:stylesheet>
