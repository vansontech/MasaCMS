﻿<!--- This file is part of Mura CMS.

Mura CMS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, Version 2 of the License.

Mura CMS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Mura CMS. If not, see <http://www.gnu.org/licenses/>.

Linking Mura CMS statically or dynamically with other modules constitutes the preparation of a derivative work based on 
Mura CMS. Thus, the terms and conditions of the GNU General Public License version 2 ("GPL") cover the entire combined work.

However, as a special exception, the copyright holders of Mura CMS grant you permission to combine Mura CMS with programs
or libraries that are released under the GNU Lesser General Public License version 2.1.

In addition, as a special exception, the copyright holders of Mura CMS grant you permission to combine Mura CMS with 
independent software modules (plugins, themes and bundles), and to distribute these plugins, themes and bundles without 
Mura CMS under the license of your choice, provided that you follow these specific guidelines: 

Your custom code 

• Must not alter any default objects in the Mura CMS database and
• May not alter the default display of the Mura CMS logo within Mura CMS and
• Must not alter any files in the following directories.

 /admin/
 /tasks/
 /config/
 /requirements/mura/
 /Application.cfc
 /index.cfm
 /MuraProxy.cfc

You may copy and distribute Mura CMS with a plug-in, theme or bundle that meets the above guidelines as a combined work 
under the terms of GPL for Mura CMS, provided that you include the source code of that other code when and as the GNU GPL 
requires distribution of source code.

For clarity, if you create a modified version of Mura CMS, you are not obligated to grant this special exception for your 
modified version; it is your choice whether to do so, or to make such modified version available under the GNU General Public License 
version 2 without this exception.  You may, if you choose, apply this exception to your own modified versions of Mura CMS.
--->
<cfcomponent displayname="FormBuilderManager" output="false">
	<cfset variables.fields		= StructNew()>

	<cffunction name="init" access="public" output="false" returntype="FormBuilderManager">
		<cfargument name="configBean" type="any" required="yes"/>
		
		<cfset variables.configBean = configBean />
				
		<cfset variables.filePath = "#expandPath("/muraWRM")#/admin/core/utilities/formbuilder/templates" />
		<cfset variables.templatePath = "/muraWRM/admin/core/utilities/formbuilder/templates" />
		<cfset variables.fields["en"] = StructNew()>
		
		<cfreturn this/>
	</cffunction>

	<cffunction name="createJSONForm" access="public" output="false" returntype="any">
		<cfargument name="formID" required="false" type="uuid" default="#createUUID()#" />

		<cfset var formStruct	= StructNew() />
		<cfset var formBean		= createObject('component','formBean').init(formID=formID) />

		<cfset formStruct['datasets']	= StructNew() />
		<cfset formStruct['form']		= formBean.getAsStruct() />

		<cfreturn serializeJSON( formStruct ) />
	</cffunction>

	<cffunction name="getFormBean" access="public" output="false" returntype="any">
		<cfargument name="formID" required="false" type="uuid" default="#createUUID()#" />
		<cfargument name="asJSON" required="false" type="boolean" default="false" />

		<cfset var formBean		= createObject('component','formBean').init(formID=arguments.formID) />

		<cfif arguments.asJSON>
			<cfreturn formBean.getasJSON() />
		<cfelse>
			<cfreturn formBean  />
		</cfif>
		
	</cffunction>

	<cffunction name="getFieldBean" access="public" output="false" returntype="any">
		<cfargument name="formID" required="true" type="uuid" />
		<cfargument name="fieldID" required="false" type="uuid" default="#createUUID()#" />
		<cfargument name="fieldType" required="false" type="string" default="field-textfield" />
		<cfargument name="asJSON" required="false" type="boolean" default="false" />

		<cfset var fieldBean		= createObject('component','fieldBean').init(formID=arguments.formID,fieldID=arguments.fieldID,isdirty=1) />
		<cfset var fieldTypeBean	= "" />
		<cfset var mmRBF			= application.rbFactory />
		<cfset var fieldTypeName	= rereplace(arguments.fieldType,".[^\-]*-","") />

		<cfset fieldTypeBean	= getFieldTypeBean( fieldType=fieldType,asJSON=arguments.asJSON ) />
		<cfset fieldBean.setFieldType( fieldTypeBean ) />
		<cfset fieldBean.setLabel( mmRBF.getKeyValue(session.rb,'formbuilder.new') & " " & mmRBF.getKeyValue(session.rb,'formbuilder.field.#fieldTypeName#') ) />

		<cfif arguments.asJSON>
			<cfreturn fieldBean.getasJSON() />
		<cfelse>
			<cfreturn fieldBean  />
		</cfif>
	</cffunction>

	<cffunction name="getDatasetBean" access="public" output="false" returntype="any">
		<cfargument name="datasetID" required="true" type="uuid" />
		<cfargument name="fieldID" required="false" type="uuid" default="#createUUID()#" />
		<cfargument name="asJSON" required="false" type="boolean" default="false" />
		<cfargument name="modelBean" required="false" type="any" />

		<cfset var datasetBean		= createObject('component','datasetBean').init(datasetID=arguments.datasetID,fieldID=arguments.fieldID) />
		<cfset var mBean			= "" />

		<cfif not StructKeyExists( arguments,"modelBean" ) or isSimpleValue(arguments.modelBean)>
			<cfset mBean	= createObject('component','datarecordBean').init(datasetID=arguments.datasetID) />
		<cfelse>
			<cfset mBean	= arguments.modelBean />
		</cfif>

		<cfset datasetBean.setModel( mBean ) />

		<cfif arguments.asJSON>
			<cfreturn datasetBean.getasJSON() />
		<cfelse>
			<cfreturn datasetBean  />
		</cfif>
	</cffunction>

	<cffunction name="getFieldTypeBean" access="public" output="false" returntype="any">
		<cfargument name="fieldTypeID" required="false" type="uuid" default="#createUUID()#" />
		<cfargument name="fieldType" required="false" type="string" default="field-textfield" />
		<cfargument name="asJSON" required="false" type="boolean" default="false" />

		<cfset var aFieldTemplate		= ListToArray(rereplace(arguments.fieldType,"[^[:alnum:]|-]","","all"),"-") />
		<cfset var displayName			= lcase( aFieldTemplate[1] ) />
		<cfset var typeName				= lcase( aFieldTemplate[2] ) />
		<cfset var fieldTypeBean		= createObject('component','fieldtypeBean').init(fieldTypeID=arguments.fieldTypeID,fieldtype=typeName,displayType=displayName) />

		<cfswitch expression="#fieldTypeBean.getFieldType()#">
			<cfcase value="dropdown,checkbox,radio,multientity" >
				<cfset fieldTypeBean.setIsData( 1 ) />
			</cfcase>	
			<cfcase value="textarea,htmleditor" >
				<cfset fieldTypeBean.setIsLong( 1 ) />
			</cfcase>	
		</cfswitch>

		<cfif arguments.asJSON>
			<cfreturn fieldTypeBean.getasJSON() />
		<cfelse>
			<cfreturn fieldTypeBean  />
		</cfif>
	</cffunction>

	<cffunction name="getFieldTemplate" access="public" output="false" returntype="string">
		<cfargument name="fieldType" required="true" type="string" />
		<cfargument name="locale" required="false" type="string" default="en" />
		<cfargument name="reload" required="false" type="boolean" default="false" />

		<cfset var fieldTemplate		= lcase( rereplace(arguments.fieldType,"[^[:alnum:]|-]","","all") & ".cfm" ) />
		<cfset var filePath				= "#variables.filePath#/#fieldTemplate#" />
		<cfset var templatePath			= "#variables.templatePath#/#fieldTemplate#" />
		<cfset var strField				= "" />
		<cfset var mmRBF				= application.rbFactory />
		
		<cfif not StructKeyExists( variables.fields,arguments.locale)>
			<cfset variables.fields[arguments.locale] = StructNew()>
		</cfif>
		
		<cfif arguments.reload or not StructKeyExists( variables.fields[arguments.locale],fieldTemplate)>
			<cfif not fileExists( filePath )>
				<cfreturn mmRBF.getKeyValue(session.rb,'formbuilder.missingfieldtemplatefile') & ": " & fieldTemplate />
			</cfif>
			<cfsavecontent variable="strField"><cfinclude template="#templatePath#"></cfsavecontent>
			<cfset variables.fields[arguments.locale][arguments.fieldType] = trim(strField) />
		</cfif>
	
		<cfreturn variables.fields[arguments.locale][arguments.fieldType] />
	</cffunction>

	<cffunction name="getDialog" access="public" output="false" returntype="string">
		<cfargument name="dialog" required="true" type="string" />
		<cfargument name="locale" required="false" type="string" default="en" />
		<cfargument name="reload" required="false" type="boolean" default="false" />

		<cfset var dialogTemplate		= lcase( rereplace(arguments.dialog,"[^[:alnum:]|-]","","all") & ".cfm" ) />
		<cfset var filePath				= "#variables.filePath#/#dialogTemplate#" />
		<cfset var templatePath			= "#variables.templatePath#/#dialogTemplate#" />
		<cfset var strField				= "" />
		<cfset var mmRBF				= application.rbFactory />
		
		<cfif not StructKeyExists( variables.fields,arguments.locale)>
			<cfset variables.fields[arguments.locale] = StructNew()>
		</cfif>
		
		<cfif arguments.reload or not StructKeyExists( variables.fields[arguments.locale],dialogTemplate)>
			<cfif not fileExists( filePath )>
				<cfreturn mmRBF.getKeyValue(session.rb,'formbuilder.missingfieldtemplatefile') & ": " & dialogTemplate />
			</cfif>
			<cfsavecontent variable="strField"><cfinclude template="#templatePath#"></cfsavecontent>
			<cfset variables.fields[arguments.locale][arguments.dialog] = trim(strField) />
		</cfif>
	
		<cfreturn variables.fields[arguments.locale][arguments.dialog] />
	</cffunction>

	<cffunction name="renderFormJSON" access="public" output="false" returntype="struct">
		<cfargument name="formJSON" required="true" type="string" />

		<cfset var formStruct		= StructNew() />
		<cfset var dataStruct		= StructNew() />
		<cfset var return			= StructNew() />
		<cfset var formBean			= "" />
		<cfset var fieldBean		= "" />
		<cfset var mmRBF			= application.rbFactory />

		<cfif not isJSON( arguments.formJSON )>
			<cfthrow message="#mmRBF.getKeyValue(session.rb,"formbuilder.mustbejson")#" >
		</cfif>

		<cfset formStruct = deserializeJSON(arguments.formJSON) />

		<cfreturn formStruct />
	</cffunction>

	<cffunction name="processDataset" access="public" output="false" returntype="struct">
		<cfargument name="$" required="true" type="any" />
		<cfargument name="dataset" required="true" type="struct" />

		<cfset var return			= StructNew() />
		<cfset var srcData			= "" />
		<cfset var mmRBF			= application.rbFactory />
		<cfset var dataArray		= ArrayNew(1) />
		<cfset var x				= "" />
		
		<cfset var dataOrder		= ArrayNew(1) />
		<cfset var dataRecords		= StructNew() />
		<cfset var dataBean			= "" />
		<cfset var rsData			= "" />
		<cfset var primaryKey		= "" />
		<cfset var rowid			= "" />

		<cfif not StructKeyExists( arguments.dataset,"datasetID" )>			
			<cfthrow message="#mmRBF.getKeyValue(session.rb,"formbuilder.invaliddataset")#" >
		</cfif>

		<cfswitch expression="#arguments.dataset.sourcetype#">
			<cfcase value="manual,entered">
				<cfreturn arguments.dataset />
			</cfcase>
			<cfcase value="muraorm">
							
				<cfset dataBean = $.getBean( arguments.dataset.source ) /> 
				<cfset primaryKey = dataBean.getPrimaryKey() />
				<cfset rsData = dataBean
					.loadby( siteid = $.event('siteid'))
					.getFeed()
					.getQuery() />

				<cfloop query="#rsData#">
					<cfset rowid = rsdata[primaryKey] />
					<cfset ArrayAppend( arguments.dataset.datarecordorder,rowid )>
					<cfset arguments.dataset.datarecords[rowid] = $.getBean('utility').queryRowToStruct( rsData,currentrow )>
					<cfset arguments.dataset.datarecords[rowid]['value'] = rowid>
					<cfset arguments.dataset.datarecords[rowid]['datarecordid'] = rowid>
					<cfset arguments.dataset.datarecords[rowid]['datasetid'] = dataset.datasetid>
					<cfset arguments.dataset.datarecords[rowid]['isselected'] = 0>
				</cfloop>
				
				<cfreturn arguments.dataset />
			</cfcase>
			<cfcase value="object">
				<cfset arguments.dataset = createObject('component',$.siteConfig().getAssetMap() & "." & replacenocase(dataset.source,".cfc","") ).getData($,arguments.dataset) />
				<cfreturn arguments.dataset />
			</cfcase>
			<cfcase value="dsp">
				<cfif fileExists( expandPath( $.siteConfig().getIncludePath() ) & "/includes/display_objects/custom/#dataset.source#"  )>
					<cfinclude template="#$.siteConfig().getIncludePath()#/includes/display_objects/custom/#dataset.source#">
				<cfelse>
					<cfinclude template="#$.siteConfig().getIncludePath()##dataset.source#">
				</cfif>
				<cfreturn arguments.dataset />
			</cfcase>
			<cfdefaultcase>
				<!---<cfdump var="#dataset#" label="no list source chosen"><cfabort>--->
				<cfreturn arguments.dataset />
			</cfdefaultcase>

		</cfswitch>
	
	</cffunction>

	<cffunction name="getForms" access="public" output="false">
		<cfargument name="$" required="true" type="any" />
		<cfargument name="siteid" required="true" type="any" />
		<cfargument name="excludeformid" required="false" type="string" default="" />

		<cfquery name="rs" datasource="#variables.configBean.getReadOnlyDatasource()#" username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
			select contentid,title from tcontent
			where type='Form'
			and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#" />
			and active=1
			<cfif len(arguments.excludeformid)>
				and contentid != <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.excludeformid#" />
			</cfif>
			order by title
		</cfquery>

		<cfreturn rs />
	</cffunction>
	
	<cffunction name="renderNestedForm">
		<cfargument name="$" required="true" type="any" />
		<cfargument name="siteid" required="true" type="any" />
		<cfargument name="formid" required="true" type="any" />
		<cfargument name="prefix" required="false" type="string" default="" />

		<cfset var renderedForm = arguments.$.dspObject_Include(
						thefile='formbuilder/dsp_form.cfm',
						formid=arguments.formid,
						siteid=arguments.siteid,
						isNested=true,
						prefix=arguments.prefix
					)/>
					
		<cfreturn renderedForm />
	</cffunction>

	<cfscript>



	function generateFormObject($,event) {
		
		var content = arguments.event.getValue('contentBean');
		var objectname = rereplacenocase( content.getValue('filename'),"-([a-z])","\U\1","all" );
		var siteid = $.event('siteid');
		objectname = rereplacenocase( objectname,"[^[:alnum:]]","","all" );

		var formStruct = deserializeJSON( arguments.event.getValue('contentBean').getValue('body'));

		if( !structKeyExists(formStruct.form.formattributes,'muraormentities') || formStruct.form.formattributes.muraormentities neq 1 )
			return;

		var field = "";
		
		if(!directoryExists(#expandPath("/" & siteid)# & "/includes/model")) {
			directoryCreate(#expandPath("/" & siteid)# & "/includes/model");
		}

		if(!directoryExists(#expandPath("/" & siteid)# & "/includes/model/beans")) {
			directoryCreate(#expandPath("/" & siteid)# & "/includes/model/beans");
		}

		if(!directoryExists(#expandPath("/" & siteid)# & "/includes/model/archive")) {
			directoryCreate(#expandPath("/" & siteid)# & "/includes/model/archive");
		}
			

		var exists = fileExists( "#expandPath("/" & siteid)#/includes/model/beans/#lcase(objectname)#.cfc" );

		var param = "";
		var fieldcount = 0;
		
		var fieldorder = [];
		var listview = "";

		for(var i = 1;i <= ArrayLen(formStruct.form.pages);i++) {
			fieldorder.addAll(formStruct.form.pages[i]);
		}

		var fieldlist = formStruct.form.fields;

		// start CFC				
		var con = 'component contentid="#content.getContentID()#" extends="mura.bean.beanORM" table="fb_#lcase(objectname)#" entityName="#lcase(objectname)#" displayName="#objectname#" rendertype="form" access="public"';

		for(var i = 1;i <= ArrayLen(fieldorder);i++) {
			field = fieldlist[ fieldorder[i] ];
			if(field.fieldtype.fieldtype == 'textfield' and listLen(listview) < 5)
				listview = listAppend(listview,field.name);
		}

		if(listLen(listview) > 0) {
			con = con & ' listview="#listview#" ';
		}

		con = con & '{#chr(13)##chr(13)#';
		con = con & '	property name="#lcase(objectname)#id" fieldtype="id";#chr(13)##chr(13)#';

		var datasets = formStruct.datasets;

		for(var i = 1;i <= ArrayLen(fieldorder);i++) {
			field = fieldlist[ fieldorder[i] ];

			if( field.fieldtype.fieldtype != "section") {
				fieldcount++;
				param = '	property name="#field.name#"';
				param = param & ' displayname="#field.label#"';
				param = param & ' orderno="#fieldcount#"';
	
				param = param & '#getDataType(field,datasets,objectname)#';
	
				con = con & "#param#;#chr(13)#";
			}			
		}

		con = con & "#chr(13)##chr(13)#";
		
		// close CFC				
		con = con & "#chr(13)#}";
		
		if( exists ) {
			fileMove( "#expandPath("/" & siteid)#/includes/model/beans/#lcase(objectname)#.cfc","#expandPath("/" & siteid)#/includes/model/archive/#getTickCount()##lcase(objectname)#.cfc" );
		}
	
		fileWrite( "#expandPath("/" & siteid)#/includes/model/beans/#lcase(objectname)#.cfc",con );

		if(structKeyExists(application.objectMappings,objectname))
		try {
			StructDelete(application.objectMappings,objectname);
		}
		catch(any e) {

		}

		$.globalConfig().registerBean( "#siteid#.includes.model.beans.#lcase(objectname)#",siteid );
		$.getBean(objectname).checkSchema();
		
	}

	function getDataType( fieldData,datasets,objectname ) {
		var str = "";
		var fieldtype = fieldData.fieldtype.fieldtype; 
		var dataset = {sourcetype='manual'};
		var cfcBridgeName = "";
		
		if(StructKeyExists( arguments.datasets,arguments.fieldData.datasetid )) {
			dataset = arguments.datasets[arguments.fieldData.datasetid];
			cfcBridgeName = lcase("#arguments.objectname##dataset.source#");
		}
				
		switch(fieldtype) {
			case "nested":
				if( dataset.sourcetype == 'muraorm' ) {
					str = ' fieldtype="one-to-one" cfc="#dataset.source#" rendertype="#fieldtype#" fkcolumn="#lcase(dataset.source)#id"';
					createFieldOptionCFC(fieldData,objectname,cfcBridgeName,dataset,false,false);
				}
				else {
					str = ' datatype="varchar" length="250" rendertype="#fieldtype#"';
				}
			break;
			case "dropdown":
				if( dataset.sourcetype == 'muraorm' ) {
					str = ' fieldtype="one-to-one" cfc="#dataset.source#" rendertype="#fieldtype#" fkcolumn="#lcase(dataset.source)#id"';
					createFieldOptionCFC(fieldData,objectname,cfcBridgeName,dataset,false,true);
				}
				else {
					str = ' datatype="varchar" length="250" rendertype="#fieldtype#"';
				}
			break;
			case "radio":
				if( dataset.sourcetype == 'muraorm' ) {
					str = ' fieldtype="one-to-one" cfc="#dataset.source#" rendertype="#fieldtype#" fkcolumn="#lcase(dataset.source)#id"';
					createFieldOptionCFC(fieldData,objectname,cfcBridgeName,dataset,false,true);
				}
				else {
					str = ' datatype="varchar" length="250" rendertype="#fieldtype#"';
				}
			break;
			case "checkbox":
				str = ' fieldtype="one-to-many" cfc="#cfcBridgeName#" rendertype="#fieldtype#" source="#lcase(dataset.source)#"';
				createFieldOptionCFC(fieldData,objectname,cfcBridgeName,dataset,true,true);
			break;
			case "multiselect":
				str = ' fieldtype="one-to-many" cfc="#cfcBridgeName#" rendertype="dropdown" source="#lcase(dataset.source)#"';
				createFieldOptionCFC(fieldData,objectname,cfcBridgeName,dataset,true,true);
			break;
			case "textfield":
				str = ' datatype="varchar" length="250" rendertype="#fieldtype#" list=true';
			break;
			case "hidden":
				str = ' datatype="varchar" length="250" rendertype="#fieldtype#"';
			break;
			case "file":
				str = ' datatype="varchar" length="35" fieldtype="index" rendertype="#fieldtype#"';
			break;
			case "textarea":
				str = ' datatype="text" rendertype="#fieldtype#"';
			break;
		}

		return str;		
	}

	function createFieldOptionCFC( fieldData,parentObject,cfcBridgeName,dataset,createJoinentity=false,createDataentity=false ) {
		var objectname = fieldData.name;
		var exists = fileExists( "#expandPath("/" & siteid)#/includes/model/beans/#lcase(arguments.cfcBridgeName)#.cfc" );
		var param = "";
		
		objectname = rereplacenocase( objectname,"[^[:alnum:]]","","all" );

		if( !exists && arguments.createJoinEntity ) {
			// start relationship CFC				
			var con = 'component extends="mura.bean.beanORM" table="fb_#lcase(arguments.cfcBridgeName)#" entityName="#lcase(arguments.cfcBridgeName)#" displayName="#arguments.cfcBridgeName#" access="public" type="join" {#chr(13)##chr(13)#';
	
			var con = con & '	property name="#lcase(arguments.cfcBridgeName)#id" fieldtype="id";#chr(13)##chr(13)#';
			var con = con & '	property name="#lcase(arguments.parentobject)#id" fieldtype="one-to-one" cfc="#arguments.parentobject#";#chr(13)#';
			var con = con & '	property name="#lcase(dataset.source)#id" fieldtype="one-to-one" cfc="#objectname#";#chr(13)#';
	
			con = con & "#chr(13)##chr(13)#";
			
			// close relationship CFC				
			con = con & "#chr(13)#}";
			
			fileWrite( "#expandPath("/" & siteid)#/includes/model/beans/#lcase(dataset.source)#.cfc",con );
			if( structKeyExists(application.objectMappings,dataset.source))
			try {
				StructDelete(application.objectMappings,dataset.source);
			}
			catch(any e) {}

			$.globalConfig().registerBean( "#siteid#.includes.model.beans.#lcase(dataset.source)#",siteid );
			$.getBean(objectname).checkSchema();

			var bean = $.getBean(cfcBridgeName);
			bean.checkSchema();
		}
		
		if(arguments.createDataentity == false)
			return;

		exists = fileExists( expandPath("/" & siteid) & "/includes/model/beans/#lcase(dataset.source)#.cfc" );
		
		// data beans are never recreated
		if(exists || arguments.dataset.sourcetype != "muraorm")
			return;

		// start data CFC				
		var con = 'component extends="mura.formbuilder.fieldOptionBean" table="fb_#lcase(dataset.source)#" entityName="#lcase(dataset.source)#" displayName="#dataset.source#" access="public" {#chr(13)##chr(13)#';

		var con = con & '	property name="#lcase(dataset.source)#id" fieldtype="id";#chr(13)##chr(13)#';

		con = con & "#chr(13)##chr(13)#";
		
		// close data CFC				
		con = con & "#chr(13)#}";

		fileWrite( "#expandPath("/" & siteid)#/includes/model/beans/#lcase(dataset.source)#.cfc",con );

		if(structKeyExists(application.objectMappings,dataset.source))
		try {
			StructDelete(application.objectMappings,dataset.source);
		}
		catch(any e) {}

		$.globalConfig().registerBean( "#siteid#.includes.model.beans.#lcase(dataset.source)#",siteid );
		$.getBean(objectname).checkSchema();

	}

	function getFormFromObject( siteid,formName,nested=false) {
			
		return getFormProperties( argumentCollection=arguments );
	}

	function getModuleBeans( siteid ) {
		var $=getBean('$').init(arguments.siteid);
		var dirList = directoryList( #expandPath("/" & siteid)# & "/includes/model/beans",false,'query' );
		var beanArray = [];

		for(var i = 1; i <= dirList.recordCount;i++) {
			var name = replaceNoCase( dirList.name[i],".cfc","");
			arrayAppend(beanArray,{name=name});

		}

		return beanArray;
	}


	function getFormProperties( siteid,formName,nested=false,debug=false ) {

		var $=getBean('$').init(arguments.siteid);
		var formObj = $.getBean( arguments.formname );
		var util = $.getBean('fb2Utility');
		var props = formObj.getProperties();
		var formProps = {};
		var formArray = [];
		var formFields = [];
		var val = 100000;
		var x = "";
		
		for(var i in props) {
			if( !listFindNoCase("errors,fromMuraCache,instanceID,isnew,saveErrors,site",i) ) {
				formProps[i] = getFieldProperties( props[i] );
				
				if( formProps[i].rendertype == "form" ) {
					formProps[i]['nested'] = getFieldProperties( arguments.siteid,formProps[i].cfc,true );
				}
				
				if(!structKeyExists(formProps[i],"orderno"))
					formProps[i]['orderno'] = val++;

				if(structKeyExists(formProps[i],"cfc")) {
					var dataBean = $.getBean(i);
					
					if(dataBean.getProperty('source') != "") {
						var dataBean = $.getBean(dataBean.getProperty('source'));
					}

					var options = dataBean
						.getFeed()
						.addParam(field='siteid',relationship='equals',criteria='#arguments.siteid#')
						.getIterator();
									
					formProps[i]['options'] = util.queryToArray( options.getQuery(),dataBean.getPrimaryKey() );
				}
			}
		}

		formArray = structSort(formProps,"numeric","asc","orderno" );

		for( var i = 1;i <= ArrayLen(formArray);i++ ) {
			ArrayAppend(formFields,formProps[formArray[i]]);
		}

		if(arguments.debug) {
			writeDump(formFields);
			abort;
		}


		return formFields;
	}

	function getFieldProperties( prop ) {

		var fieldProp = {};
				
		for(var x in arguments.prop ) {
			fieldProp["#lcase(x)#"] = arguments.prop[x];
		}

		if( !structKeyExists(fieldProp,"rendertype")) {
			fieldProp['rendertype'] = getRenderType( fieldProp );
		}
		
		return fieldProp;
	}
	
	
	function getRenderType( formProp ) {
		var retType = "";

		if( structKeyExists(formProp,"cfc") ) {
			retType = "dropdown";
		}
		
		return retType;
		
	}

























	</cfscript>

</cfcomponent>