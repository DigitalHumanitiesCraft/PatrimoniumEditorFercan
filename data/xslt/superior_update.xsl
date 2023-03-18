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
	
	<xsl:template match="*:listPerson">
		<xsl:copy>
			<xsl:if test="not(*:person/*:persName[@subtype = 'celtic_normalized'][@type ='divine'])">
				<person>
					<persName subtype="celtic_normalized" type="divine">
						<ref target="context:fercan.dcn." type="context"> </ref>
					</persName>
				</person>
			</xsl:if>
			<xsl:if test="not(*:person/*:persName[@subtype = 'celtic_normalized_other'][@type ='divine'])">
				<person>
					<persName subtype="celtic_normalized_other" type="divine">
						<ref target="context:fercan.dcn.other" type="context"> </ref>
					</persName>
				</person>
			</xsl:if>
			
			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*:keywords/*:list">
		<xsl:copy>
			<xsl:if test="not(*:item/*:ref[@target = 'context:fercan.dedication.'])">
				<item> <ref target="context:fercan.dedication." type="context"> </ref> </item>
			</xsl:if>
			<xsl:if test="not(*:item/*:ref[@target = 'context:fercan.character.'])">
				<item> <ref target="context:fercan.character." type="context"> </ref> </item>
			</xsl:if>
			<xsl:if test="not(*:item/*:ref[@target = 'context:fercan.other.'])">
				<item> <ref target="context:fercan.other." type="context"> </ref> </item>
			</xsl:if>
			<xsl:if test="not(*:item/*:ref[@target = 'context:fercan.rel.other.'])">
				<item> <ref target="context:fercan.rel.other." type="context"> </ref> </item>
			</xsl:if>
			<xsl:if test="not(*:item/*:ref[@target = 'context:fercan.divinepart.'])">
				<!-- Belegform gesamt  -->
				<item> <ref target="context:fercan.divinepart." type="context"> </ref> </item>
			</xsl:if>
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
	
	<xsl:template match="*:text/*:back">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<note type="ElektronischeRessourcen_note"/>
			<note type="Index_note"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>