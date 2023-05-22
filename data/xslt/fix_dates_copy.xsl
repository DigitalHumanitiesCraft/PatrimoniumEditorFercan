<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="2.0">
	<!-- -->
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
	<!-- /default:TEI/default:text[1]/default:body[1]/default:div[2]/default:listBibl[1] -->
	<xsl:template match="*:div[@type = 'bibliography'][@subtype = 'concordances']/*:listBibl">
		<xsl:variable name="filename" select="substring-after(base-uri(), 'inferior_new/')"/>
		<xsl:variable name="document"
			select="document(concat('\data\inferior_old\', $filename))//*:div[@type = 'bibliography'][@subtype = 'concordances']/*:listBibl"/>
		<xsl:copy>
			<xsl:if test="*:bibl[@type = 'EDCS']">
				<bibl type="EDCS">
					<idno>
						<xsl:value-of select="$document//*:bibl[@type = 'EDCS']/*:idno"/>
					</idno>
					<date>
						<xsl:value-of select="*:bibl[@type = 'EDCS']/*:date"/>
					</date>
				</bibl>
			</xsl:if>
			<xsl:if test="*:bibl[@type = 'EDH']">
				<bibl type="EDH">
					<idno>
						<xsl:value-of select="$document//*:bibl[@type = 'EDH']/*:idno"/>
					</idno>
					<date>
						<xsl:value-of select="*:bibl[@type = 'EDH']/*:date"/>
					</date>
				</bibl>
			</xsl:if>
			<xsl:if test="*:bibl[@type = 'trismegistos']">
				<bibl type="trismegistos">
					<idno>
						<xsl:value-of select="$document//*:bibl[@type = 'trismegistos']/*:idno"/>
					</idno>
					<date>
						<xsl:value-of select="*:bibl[@type = 'trismegistos']/*:date"/>
					</date>
				</bibl>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
