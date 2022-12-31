<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!--Identity template, 
    provides default behavior that copies all content into the output -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!--More specific template for Node766 that provides custom behavior -->
	<xsl:template match="*:TEI"> 
		<xsl:variable name="PID" select="//*:teiHeader/*:fileDesc/*:publicationStmt/*:idno[@type='PID']"/>
		<xsl:copy>
			<xsl:attribute name="xml:id" select="concat('doc', substring-after($PID, '.'))"/>
			<!--<xsl:attribute name="xml:id" select="concat('fercan.', substring-after($PID, '.'))"/> -->
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>