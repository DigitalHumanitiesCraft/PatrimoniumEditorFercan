<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*:div[@subtype='concordances'][@type='bibliography']/*:listBibl">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<bibl type="lupa"><idno> </idno><date> </date></bibl>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*:text/*:back">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<note type="ElektronischeRessourcen_note"/>
			<note type="Index_note"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>