<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<!-- --> 
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- add xml:id to root -->
	<xsl:template match="*:TEI"> 
		<xsl:variable name="PID" select="//*:teiHeader/*:fileDesc/*:publicationStmt/*:idno[@type='PID']"/>
		<xsl:copy>
			<xsl:attribute name="xml:id" select="concat('inferior', substring-after($PID, '.'))"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- skip nasty attributes from schema -->
	<xsl:template match="@instant"/>
	<xsl:template match="@default"/>
	<xsl:template match="@full"/>
	<xsl:template match="@status"/>
	<xsl:template match="@part"/>
	<xsl:template match="@anchored"/>
	<xsl:template match="@sample"/>
	<!-- remove xml:id in tei:lb -->
	<xsl:template match="*:lb/@xml:id"/>
	
	<xsl:template match="*:TEI"> 
		<xsl:variable name="PID" select="//*:teiHeader/*:fileDesc/*:publicationStmt/*:idno[@type='PID']"/>
		<xsl:copy>
			<xsl:attribute name="xml:id" select="concat('inferior', substring-after($PID, '.'))"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- add <idno> next to <date> for 'Elektronische Ressourcen' -->
	<xsl:template match="*:body/*:div/*:listBibl/*:bibl[@type = 'EDCS' or @type = 'EDH' or @type = 'trismegistos' ]"> 
		<xsl:copy>
			<xsl:attribute name="type">
				<xsl:value-of select="@type"/>
			</xsl:attribute>
			<idno>
				<xsl:value-of select="text()"/>
			</idno>
			<xsl:text> </xsl:text>
			<date>
				<xsl:value-of select="*:date"/>
			</date>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>